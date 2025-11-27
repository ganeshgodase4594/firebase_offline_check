// lib/providers/coordinator_provider.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/school_model.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/academic_config_model.dart';
import '../service/firebase_service.dart';
import '../service/firebase_service_extension.dart';
import 'dart:async';

class CoordinatorProvider with ChangeNotifier {
  // State
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  AcademicConfigModel? _academicConfig;
  List<UserModel> _teachers = [];
  List<StudentModel> _students = [];

  // Filters
  String? _selectedGrade;
  String? _selectedDivision;
  String _searchQuery = '';

  // UI State
  bool _isLoading = false;
  bool _isLoadingConfig = false;
  bool _isUploadingData = false;
  String? _errorMessage;

  // Subscriptions
  StreamSubscription? _schoolsSubscription;
  StreamSubscription? _configSubscription;
  StreamSubscription? _teachersSubscription;
  StreamSubscription? _studentsSubscription;

  // Getters
  List<SchoolModel> get schools => _schools;
  SchoolModel? get selectedSchool => _selectedSchool;
  AcademicConfigModel? get academicConfig => _academicConfig;
  List<UserModel> get teachers => _teachers;
  List<StudentModel> get students => _students;
  String? get selectedGrade => _selectedGrade;
  String? get selectedDivision => _selectedDivision;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingConfig => _isLoadingConfig;
  bool get isUploadingData => _isUploadingData;
  String? get errorMessage => _errorMessage;

  // Available options
  List<String> get availableGrades {
    if (_selectedSchool == null) return [];
    return _selectedSchool!.gradeToLevelMap.keys.toList()..sort();
  }

  List<String> get availableDivisions {
    if (_selectedGrade == null) return [];
    return _students
        .where((s) => s.grade == _selectedGrade)
        .map((s) => s.division)
        .toSet()
        .toList()
      ..sort();
  }

  // ========================================
  // SCHOOLS MANAGEMENT
  // ========================================

  void loadSchools() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _schoolsSubscription?.cancel();
    _schoolsSubscription = FirebaseService.getSchoolsStream().listen(
      (schools) {
        _schools = schools;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void selectSchool(SchoolModel school) {
    _selectedSchool = school;
    _clearFilters();
    loadAcademicConfig(school.id);
    loadTeachers(school.id);
    loadStudents(school.id);
    notifyListeners();
  }

  void clearSchoolSelection() {
    _selectedSchool = null;
    _academicConfig = null;
    _teachers = [];
    _students = [];
    _clearFilters();
    _configSubscription?.cancel();
    _teachersSubscription?.cancel();
    _studentsSubscription?.cancel();
    notifyListeners();
  }

  Future<void> createSchool(SchoolModel school) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseService.createSchool(school);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSchool(String schoolId, Map<String, dynamic> data) async {
    try {
      await FirebaseService.updateSchool(schoolId, data);

      if (_selectedSchool?.id == schoolId) {
        final updated = await FirebaseService.getSchool(schoolId);
        if (updated != null) {
          _selectedSchool = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ========================================
  // ACADEMIC CONFIG
  // ========================================

  void loadAcademicConfig(String schoolId) {
    _isLoadingConfig = true;
    notifyListeners();

    _configSubscription?.cancel();
    _configSubscription =
        FirebaseServiceExtensions.getAcademicConfigStream(schoolId).listen(
      (config) {
        _academicConfig = config;
        _isLoadingConfig = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoadingConfig = false;
        notifyListeners();
      },
    );
  }

  Future<void> createAcademicConfig(AcademicConfigModel config) async {
    try {
      _isLoadingConfig = true;
      notifyListeners();

      await FirebaseServiceExtensions.createAcademicConfig(config);

      _isLoadingConfig = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingConfig = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAcademicConfig(
      String configId, Map<String, dynamic> data) async {
    try {
      await FirebaseServiceExtensions.updateAcademicConfig(configId, data);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> archiveAcademicYear(String schoolId, String year) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseServiceExtensions.archiveAcademicYearData(schoolId, year);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ========================================
  // TEACHERS MANAGEMENT
  // ========================================

  void loadTeachers(String schoolId) {
    _teachersSubscription?.cancel();
    _teachersSubscription =
        FirebaseService.getTeachersBySchoolStream(schoolId).listen(
      (teachers) {
        _teachers = teachers;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  List<UserModel> get filteredTeachers {
    var filtered = _teachers;

    if (_selectedGrade != null) {
      filtered = filtered.where((t) {
        if (t.gradeAssignments == null) return false;
        return t.gradeAssignments!.containsKey(_selectedGrade);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.name.toLowerCase().contains(search) ||
            t.email.toLowerCase().contains(search);
      }).toList();
    }

    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  Future<void> createTeacher(UserModel teacher) async {
    try {
      await FirebaseService.createUser(teacher);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTeacher(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseService.updateUser(uid, data);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ========================================
  // STUDENTS MANAGEMENT
  // ========================================

  void loadStudents(String schoolId) {
    _studentsSubscription?.cancel();
    _studentsSubscription =
        FirebaseService.getStudentsBySchoolStream(schoolId).listen(
      (students) {
        _students = students;
        log("Student is : $students");
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  List<StudentModel> get filteredStudents {
    var filtered = _students;

    if (_selectedGrade != null) {
      filtered = filtered.where((s) => s.grade == _selectedGrade).toList();
    }

    if (_selectedDivision != null) {
      filtered =
          filtered.where((s) => s.division == _selectedDivision).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(search) ||
            s.uid.toLowerCase().contains(search);
      }).toList();
    }

    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  Future<void> createStudent(StudentModel student) async {
    try {
      await FirebaseService.createStudent(student);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStudent(
      String studentId, Map<String, dynamic> data) async {
    try {
      await FirebaseService.updateStudent(studentId, data);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markStudentAbsent(String studentId, bool isAbsent) async {
    try {
      await FirebaseService.markStudentAbsent(studentId, isAbsent);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markStudentLeftSchool(String studentId) async {
    try {
      await FirebaseService.markStudentLeftSchool(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ========================================
  // GRADE MAPPING
  // ========================================

  Future<void> updateGradeMapping(Map<String, int> mapping) async {
    if (_selectedSchool == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Update school mapping
      await FirebaseService.updateSchool(
        _selectedSchool!.id,
        {'gradeToLevelMap': mapping},
      );

      // Update student levels
      await FirebaseServiceExtensions.updateStudentLevelsFromMapping(
        _selectedSchool!.id,
        mapping,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ========================================
  // BULK UPLOAD
  // ========================================

  // Future<void> uploadStudentsBatch(
  //   List<StudentModel> students,
  //   Map<String, int> gradeMapping,
  // ) async {
  //   if (_selectedSchool == null) return;

  //   try {
  //     _isUploadingData = true;
  //     notifyListeners();

  //     // Update school mapping
  //     await FirebaseService.updateSchool(
  //       _selectedSchool!.id,
  //       {'gradeToLevelMap': gradeMapping},
  //     );

  //     // Create students
  //     await FirebaseService.createStudentsBatch(students);

  //     _isUploadingData = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _isUploadingData = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  // Add this updated method to coordinator_provider.dart
// Replace the existing uploadStudentsBatch method

  // Future<void> uploadStudentsBatch(
  //   List<StudentModel> students,
  //   Map<String, int> gradeMapping,
  // ) async {
  //   if (_selectedSchool == null) return;

  //   try {
  //     _isUploadingData = true;
  //     notifyListeners();

  //     // CRITICAL FIX: Merge new mappings with existing ones
  //     // Get current school mapping
  //     final currentMapping =
  //         Map<String, int>.from(_selectedSchool!.gradeToLevelMap);

  //     // Merge with new mappings (only add new grades, don't overwrite existing)
  //     final mergedMapping = Map<String, int>.from(currentMapping);

  //     // Add only new grades from the gradeMapping parameter
  //     gradeMapping.forEach((grade, level) {
  //       if (!currentMapping.containsKey(grade)) {
  //         // This is a new grade, add it
  //         mergedMapping[grade] = level;
  //       }
  //       // If grade already exists in currentMapping, we keep the existing value
  //     });

  //     // Update school mapping with merged data
  //     await FirebaseService.updateSchool(
  //       _selectedSchool!.id,
  //       {'gradeToLevelMap': mergedMapping},
  //     );

  //     // Create students - they already have correct levels from parsing
  //     await FirebaseService.createStudentsBatch(students);

  //     _isUploadingData = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _isUploadingData = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  // ========================================
  // BULK UPLOAD - FIXED VERSION
  // ========================================

  Future<void> uploadStudentsBatch(
    List<StudentModel> students,
    Map<String, int> gradeMapping,
  ) async {
    if (_selectedSchool == null) return;

    try {
      _isUploadingData = true;
      notifyListeners();

      // CRITICAL FIX: Fetch fresh school data from Firestore
      final freshSchool = await FirebaseService.getSchool(_selectedSchool!.id);
      if (freshSchool == null) {
        throw Exception('Could not fetch school data');
      }

      // Get current mapping from fresh data
      final currentMapping = Map<String, int>.from(freshSchool.gradeToLevelMap);

      // Merge with new mappings (only add new grades)
      final mergedMapping = Map<String, int>.from(currentMapping);

      gradeMapping.forEach((grade, level) {
        if (!currentMapping.containsKey(grade)) {
          // This is a new grade, add it
          mergedMapping[grade] = level;
        }
        // If grade already exists, keep the existing value
      });

      // Update school mapping with merged data
      await FirebaseService.updateSchool(
        _selectedSchool!.id,
        {'gradeToLevelMap': mergedMapping},
      );

      // Create students
      await FirebaseService.createStudentsBatch(students);

      _isUploadingData = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isUploadingData = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadTeachersBatch(
    List<Map<String, dynamic>> teachersData,
  ) async {
    if (_selectedSchool == null) {
      throw Exception('No school selected');
    }

    _isUploadingData = true;
    notifyListeners();

    int successCount = 0;
    int errorCount = 0;
    List<String> errors = [];
    List<String> credentials = [];

    for (var data in teachersData) {
      try {
        final userCredential =
            await FirebaseService.createUserWithEmailPassword(
          data['email'],
          data['password'],
        );

        final user = UserModel(
          uid: userCredential.user!.uid,
          email: data['email'],
          name: data['name'],
          role: UserRole.teacher,
          schoolId: _selectedSchool!.id,
          gradeAssignments: data['gradeAssignments'],
          phoneNumber: data['phone'],
          createdAt: DateTime.now(),
          isActive: true,
        );

        await FirebaseService.createUser(user);
        successCount++;
        credentials.add('${data['email']} : ${data['password']}');
      } catch (e) {
        errorCount++;
        errors.add('${data['email']}: $e');
      }
    }

    _isUploadingData = false;
    notifyListeners();

    return {
      'success': successCount,
      'errors': errorCount,
      'errorMessages': errors,
      'credentials': credentials,
    };
  }

  // ========================================
  // FILTERS
  // ========================================

  void setGradeFilter(String? grade) {
    _selectedGrade = grade;
    _selectedDivision = null; // Reset division when grade changes
    notifyListeners();
  }

  void setDivisionFilter(String? division) {
    _selectedDivision = division;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _clearFilters() {
    _selectedGrade = null;
    _selectedDivision = null;
    _searchQuery = '';
  }

  void clearFilters() {
    _clearFilters();
    notifyListeners();
  }

  // ========================================
  // ERROR HANDLING
  // ========================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========================================
  // CLEANUP
  // ========================================

  @override
  void dispose() {
    _schoolsSubscription?.cancel();
    _configSubscription?.cancel();
    _teachersSubscription?.cancel();
    _studentsSubscription?.cancel();
    super.dispose();
  }
}
