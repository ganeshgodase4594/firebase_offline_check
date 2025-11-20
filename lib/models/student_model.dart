// lib/models/student_model.dart
class StudentModel {
  final String id;
  final String uid; // Unique ID: schoolCode + number
  final String name;
  final String schoolId;
  final String grade;
  final String division;
  final int level;
  final bool isActive;
  final bool isAbsent;
  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.schoolId,
    required this.grade,
    required this.division,
    required this.level,
    this.isActive = true,
    this.isAbsent = false,
    required this.createdAt,
  });

  factory StudentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StudentModel(
      id: id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      schoolId: data['schoolId'] ?? '',
      grade: data['grade'] ?? '',
      division: data['division'] ?? '',
      level: data['level'] ?? 1,
      isActive: data['isActive'] ?? true,
      isAbsent: data['isAbsent'] ?? false,
      createdAt:
          DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'schoolId': schoolId,
      'grade': grade,
      'division': division,
      'level': level,
      'isActive': isActive,
      'isAbsent': isAbsent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
