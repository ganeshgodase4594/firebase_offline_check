// lib/providers/student_provider.dart
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../service/firebase_service.dart';
import 'dart:async';

class StudentProvider with ChangeNotifier {
  // State
  List<StudentModel> _allStudents = [];
  List<StudentModel> _filteredStudents = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedGrade;
  String? _selectedDivision;
  String _searchQuery = '';

  StreamSubscription? _studentsSubscription;

  // Getters
  List<StudentModel> get allStudents => _allStudents;
  List<StudentModel> get filteredStudents => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedGrade => _selectedGrade;
  String? get selectedDivision => _selectedDivision;
  String get searchQuery => _searchQuery;

  List<String> get availableGrades {
    return _allStudents.map((s) => s.grade).toSet().toList()..sort();
  }

  List<String> get availableDivisions {
    if (_selectedGrade == null) return [];
    return _allStudents
        .where((s) => s.grade == _selectedGrade)
        .map((s) => s.division)
        .toSet()
        .toList()
      ..sort();
  }

  // Load students by school
  void loadStudentsBySchool(String schoolId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _studentsSubscription?.cancel();
    _studentsSubscription =
        FirebaseService.getStudentsBySchoolStream(schoolId).listen(
      (students) {
        _allStudents = students;
        _applyFilters();
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

  // Load students by grade
  void loadStudentsByGrade(String schoolId, String grade) {
    _isLoading = true;
    _errorMessage = null;
    _selectedGrade = grade;
    notifyListeners();

    _studentsSubscription?.cancel();
    _studentsSubscription =
        FirebaseService.getStudentsByGradeStream(schoolId, grade).listen(
      (students) {
        _allStudents = students;
        _applyFilters();
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

  // Filters
  void setGradeFilter(String? grade) {
    _selectedGrade = grade;
    _selectedDivision = null; // Reset division when grade changes
    _applyFilters();
  }

  void setDivisionFilter(String? division) {
    _selectedDivision = division;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _selectedGrade = null;
    _selectedDivision = null;
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allStudents;

    // Grade filter
    if (_selectedGrade != null) {
      filtered = filtered.where((s) => s.grade == _selectedGrade).toList();
    }

    // Division filter
    if (_selectedDivision != null) {
      filtered =
          filtered.where((s) => s.division == _selectedDivision).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(search) ||
            s.uid.toLowerCase().contains(search);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    _filteredStudents = filtered;
    notifyListeners();
  }

  // CRUD Operations
  Future<void> addStudent(StudentModel student) async {
    try {
      await FirebaseService.createStudent(student);
      // Stream will automatically update
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

  Future<void> markAbsent(String studentId, bool isAbsent) async {
    try {
      await FirebaseService.markStudentAbsent(studentId, isAbsent);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markLeftSchool(String studentId) async {
    try {
      await FirebaseService.markStudentLeftSchool(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    super.dispose();
  }
}
