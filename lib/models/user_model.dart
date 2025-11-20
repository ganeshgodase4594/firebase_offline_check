// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? schoolId;
  final List<String>? assignedGrades;
  final String? phoneNumber;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.schoolId,
    this.assignedGrades,
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
      assignedGrades: List<String>.from(data['assignedGrades'] ?? []),
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
      'assignedGrades': assignedGrades,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

enum UserRole {
  teacher,
  coordinator,
  super_admin,
}
