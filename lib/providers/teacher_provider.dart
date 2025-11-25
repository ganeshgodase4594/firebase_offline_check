// lib/providers/teacher_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../service/firebase_service.dart';
import 'dart:async';

class TeacherProvider with ChangeNotifier {
  // State
  List<UserModel> _allTeachers = [];
  List<UserModel> _filteredTeachers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedGrade;
  String _searchQuery = '';

  StreamSubscription? _teachersSubscription;

  // Getters
  List<UserModel> get allTeachers => _allTeachers;
  List<UserModel> get filteredTeachers => _filteredTeachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedGrade => _selectedGrade;
  String get searchQuery => _searchQuery;

  List<String> get assignedGrades {
    final grades = <String>{};
    for (var teacher in _allTeachers) {
      if (teacher.gradeAssignments != null) {
        grades.addAll(teacher.gradeAssignments!.keys);
      }
    }
    return grades.toList()..sort();
  }

  // Load teachers by school
  void loadTeachersBySchool(String schoolId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _teachersSubscription?.cancel();
    _teachersSubscription =
        FirebaseService.getTeachersBySchoolStream(schoolId).listen(
      (teachers) {
        _allTeachers = teachers;
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
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _selectedGrade = null;
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allTeachers;

    // Grade filter
    if (_selectedGrade != null) {
      filtered = filtered.where((t) {
        if (t.gradeAssignments == null) return false;
        return t.gradeAssignments!.containsKey(_selectedGrade);
      }).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.name.toLowerCase().contains(search) ||
            t.email.toLowerCase().contains(search);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    _filteredTeachers = filtered;
    notifyListeners();
  }

  // CRUD Operations
  Future<void> updateTeacher(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseService.updateUser(uid, data);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deactivateTeacher(String uid) async {
    try {
      await FirebaseService.updateUser(uid, {'isActive': false});
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reactivateTeacher(String uid) async {
    try {
      await FirebaseService.updateUser(uid, {'isActive': true});
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
    _teachersSubscription?.cancel();
    super.dispose();
  }
}
