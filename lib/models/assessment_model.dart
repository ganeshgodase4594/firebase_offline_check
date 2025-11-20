// lib/models/assessment_model.dart
import 'package:brainmoto_app/models/student_model.dart';

class AssessmentModel {
  final String id;
  final String studentId;
  final String teacherId;
  final String schoolId;
  final int level;
  final Map<String, dynamic>
      responses; // {"response0": 10, "response1": 15, ...}
  final DateTime assessmentDate;
  final bool isSynced;
  final DateTime? syncedAt;
  final String assessmentType; // 'by_student' or 'by_skill'

  AssessmentModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.schoolId,
    required this.level,
    required this.responses,
    required this.assessmentDate,
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
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
      'assessmentType': assessmentType,
    };
  }

  // Convert to CSV format for export
  Map<String, dynamic> toCsvFormat(StudentModel student) {
    return {
      'Name': student.name,
      'UID': student.uid,
      'Grade': student.grade,
      'Division': student.division,
      'response0': responses['response0'] ?? '',
      'response1': responses['response1'] ?? '',
      'response2': responses['response2'] ?? '',
      'response3': responses['response3'] ?? '',
      'response4': responses['response4'] ?? '',
      'response5': responses['response5'] ?? '',
      'Level': level,
    };
  }
}
