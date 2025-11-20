// lib/services/local_database_service.dart
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/assessment_model.dart';
import '../models/student_model.dart';

class LocalDatabaseService {
  static Database? _database;
  static const String _dbName = 'brainmoto_local.db';
  static const int _dbVersion = 1;

  // Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  static Future<void> _onCreate(Database db, int version) async {
    // Assessments table
    await db.execute('''
      CREATE TABLE assessments (
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        teacherId TEXT NOT NULL,
        schoolId TEXT NOT NULL,
        level INTEGER NOT NULL,
        responses TEXT NOT NULL,
        assessmentDate TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncedAt TEXT,
        assessmentType TEXT NOT NULL
      )
    ''');

    // Students cache table
    await db.execute('''
      CREATE TABLE students_cache (
        id TEXT PRIMARY KEY,
        uid TEXT NOT NULL,
        name TEXT NOT NULL,
        schoolId TEXT NOT NULL,
        grade TEXT NOT NULL,
        division TEXT NOT NULL,
        level INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        isAbsent INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        cachedAt TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_assessments_student ON assessments(studentId)');
    await db.execute(
        'CREATE INDEX idx_assessments_synced ON assessments(isSynced)');
    await db.execute(
        'CREATE INDEX idx_students_school ON students_cache(schoolId)');
  }

  // Upgrade database
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Save assessment locally
  static Future<int> saveAssessment(AssessmentModel assessment) async {
    final db = await database;
    final data = assessment.toFirestore();
    data['responses'] = jsonEncode(data['responses']);
    data['isSynced'] = assessment.isSynced ? 1 : 0;

    return await db.insert('assessments', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get unsynced assessments
  static Future<List<AssessmentModel>> getUnsyncedAssessments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assessments',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return maps.map((map) {
      final data = Map<String, dynamic>.from(map);
      data['responses'] = jsonDecode(data['responses']);
      data['isSynced'] = data['isSynced'] == 1;
      return AssessmentModel.fromFirestore(data, data['id']);
    }).toList();
  }

  // Update assessment sync status
  static Future<int> markAssessmentSynced(String assessmentId) async {
    final db = await database;
    return await db.update(
      'assessments',
      {'isSynced': 1, 'syncedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [assessmentId],
    );
  }

  // Cache students
  static Future<void> cacheStudents(List<StudentModel> students) async {
    final db = await database;
    final batch = db.batch();

    for (var student in students) {
      final data = student.toFirestore();
      data['cachedAt'] = DateTime.now().toIso8601String();
      data['isActive'] = student.isActive ? 1 : 0;
      data['isAbsent'] = student.isAbsent ? 1 : 0;

      batch.insert('students_cache', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  // Get cached students
  static Future<List<StudentModel>> getCachedStudents(String schoolId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students_cache',
      where: 'schoolId = ? AND isActive = ?',
      whereArgs: [schoolId, 1],
    );

    return maps.map((map) {
      final data = Map<String, dynamic>.from(map);
      data['isActive'] = data['isActive'] == 1;
      data['isAbsent'] = data['isAbsent'] == 1;
      return StudentModel.fromFirestore(data, data['id']);
    }).toList();
  }

  // Clear all cached data
  static Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('students_cache');
    await db.delete('assessments', where: 'isSynced = ?', whereArgs: [1]);
  }

  // Close database
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
