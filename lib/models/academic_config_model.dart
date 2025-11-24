// lib/models/academic_config_model.dart
class AcademicConfigModel {
  final String id;
  final String schoolId; // Different schools can have different years
  final String currentYear; // "2024-2025"
  final String currentTerm; // "Term 1" or "Term 2"
  final DateTime yearStartDate;
  final DateTime yearEndDate;
  final DateTime? term1EndDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AcademicConfigModel({
    required this.id,
    required this.schoolId,
    required this.currentYear,
    required this.currentTerm,
    required this.yearStartDate,
    required this.yearEndDate,
    this.term1EndDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademicConfigModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return AcademicConfigModel(
      id: id,
      schoolId: data['schoolId'] ?? '',
      currentYear: data['currentYear'] ?? '',
      currentTerm: data['currentTerm'] ?? 'Term 1',
      yearStartDate: DateTime.parse(data['yearStartDate']),
      yearEndDate: DateTime.parse(data['yearEndDate']),
      term1EndDate: data['term1EndDate'] != null
          ? DateTime.parse(data['term1EndDate'])
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'currentYear': currentYear,
      'currentTerm': currentTerm,
      'yearStartDate': yearStartDate.toIso8601String(),
      'yearEndDate': yearEndDate.toIso8601String(),
      'term1EndDate': term1EndDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
