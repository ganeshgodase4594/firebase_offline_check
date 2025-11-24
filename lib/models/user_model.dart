// ============================================
// UPDATED USER MODEL for Teacher Assignments
// ============================================

// lib/models/user_model_updated.dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? schoolId;

  // NEW: More flexible grade-division mapping
  final Map<String, List<String>>? gradeAssignments;
  // Example: {
  //   "Nursery": ["A", "B"],
  //   "UKG": ["Rigel"],
  //   "LKG": [] // empty = all divisions or no divisions
  // }

  final String? phoneNumber;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.schoolId,
    this.gradeAssignments,
    this.phoneNumber,
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.teacher,
      ),
      schoolId: data['schoolId'],
      gradeAssignments: data['gradeAssignments'] != null
          ? Map<String, List<String>>.from(
              (data['gradeAssignments'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  List<String>.from(value ?? []),
                ),
              ),
            )
          : null,
      phoneNumber: data['phoneNumber'],
      createdAt:
          DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'schoolId': schoolId,
      'gradeAssignments': gradeAssignments,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Helper method to get all grades
  List<String> getAllGrades() {
    return gradeAssignments?.keys.toList() ?? [];
  }

  // Helper method to get divisions for a grade
  List<String> getDivisionsForGrade(String grade) {
    return gradeAssignments?[grade] ?? [];
  }

  // Helper method to check if teacher has access to grade-division
  bool hasAccessTo(String grade, String? division) {
    if (gradeAssignments == null) return false;
    if (!gradeAssignments!.containsKey(grade)) return false;

    final divisions = gradeAssignments![grade]!;
    // Empty divisions list means all divisions
    if (divisions.isEmpty) return true;
    // Check specific division
    return division != null && divisions.contains(division);
  }
}

enum UserRole {
  teacher,
  coordinator,
  super_admin,
}
