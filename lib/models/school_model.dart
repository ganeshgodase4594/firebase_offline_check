// lib/models/school_model.dart
class SchoolModel {
  final String id;
  final String name;
  final String code;
  final String address;
  final String principalName;
  final String? phoneNumber;
  final String? email;
  final String city;
  final String area;
  final Map<String, int>
      gradeToLevelMap; // e.g., {"Nursery": 1, "UKG Rigel": 2}
  final DateTime createdAt;
  final String createdBy;

  SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.principalName,
    this.phoneNumber,
    this.email,
    required this.city,
    required this.area,
    required this.gradeToLevelMap,
    required this.createdAt,
    required this.createdBy,
  });

  factory SchoolModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SchoolModel(
      id: id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      address: data['address'] ?? '',
      principalName: data['principalName'] ?? '',
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      city: data['city'] ?? '',
      area: data['area'] ?? '',
      gradeToLevelMap: Map<String, int>.from(data['gradeToLevelMap'] ?? {}),
      createdAt:
          DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'address': address,
      'principalName': principalName,
      'phoneNumber': phoneNumber,
      'email': email,
      'city': city,
      'area': area,
      'gradeToLevelMap': gradeToLevelMap,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
