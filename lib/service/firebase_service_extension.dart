import 'package:brainmoto_app/models/academic_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServiceExtensions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Academic Config Management
  static Future<AcademicConfigModel?> getAcademicConfig(String schoolId) async {
    final snapshot = await _firestore
        .collection('academic_config')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AcademicConfigModel.fromFirestore(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  static Stream<AcademicConfigModel?> getAcademicConfigStream(String schoolId) {
    return _firestore
        .collection('academic_config')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return AcademicConfigModel.fromFirestore(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    });
  }

  static Future<String> createAcademicConfig(AcademicConfigModel config) async {
    // Deactivate old configs for this school
    final oldConfigs = await _firestore
        .collection('academic_config')
        .where('schoolId', isEqualTo: config.schoolId)
        .where('isActive', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in oldConfigs.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    // Create new config
    final docRef = _firestore.collection('academic_config').doc();
    batch.set(docRef, config.toFirestore());

    await batch.commit();
    return docRef.id;
  }

  static Future<void> updateAcademicConfig(
    String configId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore.collection('academic_config').doc(configId).update(data);
  }

  // Archive/Delete Academic Year Data
  static Future<void> archiveAcademicYearData(
    String schoolId,
    String academicYear,
  ) async {
    // This will move data to an archive collection
    // or mark it as archived
    final assessments = await _firestore
        .collection('assessments')
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYear', isEqualTo: academicYear)
        .get();

    final batch = _firestore.batch();

    for (var doc in assessments.docs) {
      // Move to archive collection
      final archiveRef =
          _firestore.collection('assessments_archive').doc(doc.id);
      batch.set(archiveRef, doc.data());

      // Delete from main collection
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get unique grades from uploaded students
  static Future<List<String?>> getUniqueGradesFromSchool(
      String schoolId) async {
    final students = await _firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .get();

    final grades = students.docs
        .map((doc) => doc.data()['grade'] as String?)
        .where((grade) => grade != null && grade.isNotEmpty)
        .toSet()
        .toList();

    grades.sort();
    return grades;
  }

  // Update student levels after grade mapping
  static Future<void> updateStudentLevelsFromMapping(
    String schoolId,
    Map<String, int> gradeToLevelMap,
  ) async {
    final students = await _firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .get();

    final batch = _firestore.batch();

    for (var doc in students.docs) {
      final grade = doc.data()['grade'] as String;
      final level = gradeToLevelMap[grade];

      if (level != null) {
        batch.update(doc.reference, {'level': level});
      }
    }

    await batch.commit();
  }
}
