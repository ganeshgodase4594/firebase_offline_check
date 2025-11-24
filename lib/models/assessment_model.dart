// lib/models/assessment_model_updated.dart
class AssessmentModel {
  final String id;
  final String studentId;
  final String teacherId;
  final String schoolId;
  final int level;
  final Map<String, dynamic> responses;
  final DateTime assessmentDate;

  // NEW: Academic year and term tracking
  final String academicYear; // "2024-2025"
  final String term; // "Term 1" or "Term 2"

  final bool isSynced;
  final DateTime? syncedAt;
  final String assessmentType;

  AssessmentModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.schoolId,
    required this.level,
    required this.responses,
    required this.assessmentDate,
    required this.academicYear,
    required this.term,
    this.isSynced = false,
    this.syncedAt,
    required this.assessmentType,
  });

  factory AssessmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AssessmentModel(
      id: id,
      studentId: data['studentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      schoolId: data['schoolId'] ?? '',
      level: data['level'] ?? 1,
      responses: Map<String, dynamic>.from(data['responses'] ?? {}),
      assessmentDate: DateTime.parse(
          data['assessmentDate'] ?? DateTime.now().toIso8601String()),
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? 'Term 1',
      isSynced: data['isSynced'] ?? false,
      syncedAt:
          data['syncedAt'] != null ? DateTime.parse(data['syncedAt']) : null,
      assessmentType: data['assessmentType'] ?? 'by_student',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'teacherId': teacherId,
      'schoolId': schoolId,
      'level': level,
      'responses': responses,
      'assessmentDate': assessmentDate.toIso8601String(),
      'academicYear': academicYear,
      'term': term,
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
      'assessmentType': assessmentType,
    };
  }
}
