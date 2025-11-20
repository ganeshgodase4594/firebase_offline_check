// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/school_model.dart';
import '../models/student_model.dart';
import '../models/assessment_model.dart';
import '../models/assessment_question_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize offline persistence
  static Future<void> initializeOfflineSettings() async {
    await _firestore.settings.persistenceEnabled;
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Authentication
  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<UserCredential> createUserWithEmailPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Users Collection
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  static Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Schools Collection
  static Future<String> createSchool(SchoolModel school) async {
    final docRef =
        await _firestore.collection('schools').add(school.toFirestore());
    return docRef.id;
  }

  static Future<SchoolModel?> getSchool(String schoolId) async {
    final doc = await _firestore.collection('schools').doc(schoolId).get();
    if (doc.exists) {
      return SchoolModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Stream<List<SchoolModel>> getSchoolsStream() {
    return _firestore.collection('schools').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SchoolModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> updateSchool(
      String schoolId, Map<String, dynamic> data) async {
    await _firestore.collection('schools').doc(schoolId).update(data);
  }

  static Future<void> deleteSchool(String schoolId) async {
    await _firestore.collection('schools').doc(schoolId).delete();
  }

  // Students Collection
  static Future<String> createStudent(StudentModel student) async {
    final docRef =
        await _firestore.collection('students').add(student.toFirestore());
    return docRef.id;
  }

  static Future<List<String>> createStudentsBatch(
      List<StudentModel> students) async {
    final batch = _firestore.batch();
    final List<String> ids = [];

    for (var student in students) {
      final docRef = _firestore.collection('students').doc();
      batch.set(docRef, student.toFirestore());
      ids.add(docRef.id);
    }

    await batch.commit();
    return ids;
  }

  static Future<StudentModel?> getStudent(String studentId) async {
    final doc = await _firestore.collection('students').doc(studentId).get();
    if (doc.exists) {
      return StudentModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Stream<List<StudentModel>> getStudentsBySchoolStream(String schoolId) {
    return _firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Stream<List<StudentModel>> getStudentsByGradeStream(
      String schoolId, String grade) {
    return _firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('grade', isEqualTo: grade)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> updateStudent(
      String studentId, Map<String, dynamic> data) async {
    await _firestore.collection('students').doc(studentId).update(data);
  }

  static Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('students').doc(studentId).delete();
  }

  static Future<void> markStudentAbsent(String studentId, bool isAbsent) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .update({'isAbsent': isAbsent});
  }

  static Future<void> markStudentLeftSchool(String studentId) async {
    // Soft delete by setting isActive to false
    await _firestore
        .collection('students')
        .doc(studentId)
        .update({'isActive': false});
  }

  // Assessment Questions Collection
  static Future<String> createAssessmentQuestion(
      AssessmentQuestionModel question) async {
    final docRef = await _firestore
        .collection('assessment_questions')
        .add(question.toFirestore());
    return docRef.id;
  }

  static Future<List<String>> createAssessmentQuestionsBatch(
      List<AssessmentQuestionModel> questions) async {
    final batch = _firestore.batch();
    final List<String> ids = [];

    for (var question in questions) {
      final docRef = _firestore.collection('assessment_questions').doc();
      batch.set(docRef, question.toFirestore());
      ids.add(docRef.id);
    }

    await batch.commit();
    return ids;
  }

  static Future<List<AssessmentQuestionModel>> getQuestionsByLevel(
      int level) async {
    final snapshot = await _firestore
        .collection('assessment_questions')
        .where('level', isEqualTo: level)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => AssessmentQuestionModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Stream<List<AssessmentQuestionModel>> getQuestionsByLevelStream(
      int level) {
    return _firestore
        .collection('assessment_questions')
        .where('level', isEqualTo: level)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              AssessmentQuestionModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> updateAssessmentQuestion(
      String questionId, Map<String, dynamic> data) async {
    await _firestore
        .collection('assessment_questions')
        .doc(questionId)
        .update(data);
  }

  static Future<void> deleteAssessmentQuestion(String questionId) async {
    await _firestore
        .collection('assessment_questions')
        .doc(questionId)
        .delete();
  }

  // Assessments Collection
  static Future<String> createAssessment(AssessmentModel assessment) async {
    final docRef = await _firestore
        .collection('assessments')
        .add(assessment.toFirestore());
    return docRef.id;
  }

  static Future<AssessmentModel?> getAssessment(String assessmentId) async {
    final doc =
        await _firestore.collection('assessments').doc(assessmentId).get();
    if (doc.exists) {
      return AssessmentModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Future<List<AssessmentModel>> getAssessmentsByStudent(
      String studentId) async {
    final snapshot = await _firestore
        .collection('assessments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('assessmentDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AssessmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<List<AssessmentModel>> getAssessmentsBySchool(
      String schoolId) async {
    final snapshot = await _firestore
        .collection('assessments')
        .where('schoolId', isEqualTo: schoolId)
        .get();

    return snapshot.docs
        .map((doc) => AssessmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<List<AssessmentModel>> getAssessmentsBySchoolAndGrade(
      String schoolId, String grade) async {
    // First get all students of that grade
    final studentsSnapshot = await _firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('grade', isEqualTo: grade)
        .get();

    final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();

    if (studentIds.isEmpty) return [];

    // Then get assessments for those students
    final assessmentsSnapshot = await _firestore
        .collection('assessments')
        .where('studentId', whereIn: studentIds)
        .get();

    return assessmentsSnapshot.docs
        .map((doc) => AssessmentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Stream<List<AssessmentModel>> getUnsyncedAssessmentsStream(
      String teacherId) {
    return _firestore
        .collection('assessments')
        .where('teacherId', isEqualTo: teacherId)
        .where('isSynced', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssessmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> updateAssessment(
      String assessmentId, Map<String, dynamic> data) async {
    await _firestore.collection('assessments').doc(assessmentId).update(data);
  }

  static Future<void> markAssessmentSynced(String assessmentId) async {
    await _firestore.collection('assessments').doc(assessmentId).update({
      'isSynced': true,
      'syncedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteAssessment(String assessmentId) async {
    await _firestore.collection('assessments').doc(assessmentId).delete();
  }

  // Teachers by School
  static Stream<List<UserModel>> getTeachersBySchoolStream(String schoolId) {
    return _firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Sync Status Listener
  static Stream<void> snapshotsInSyncStream() {
    return _firestore.snapshotsInSync();
  }

  // Check if data is from cache
  static bool isFromCache(DocumentSnapshot doc) {
    return doc.metadata.isFromCache;
  }

  static bool isQueryFromCache(QuerySnapshot query) {
    return query.metadata.isFromCache;
  }
}
