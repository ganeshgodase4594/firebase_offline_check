// lib/providers/app_provider.dart
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';
import '../models/school_model.dart';
import '../models/student_model.dart';
import '../models/assessment_question_model.dart';

class AppProvider with ChangeNotifier {
  final List<SchoolModel> _schools = [];
  final List<StudentModel> _students = [];
  List<AssessmentQuestionModel> _questions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SchoolModel> get schools => _schools;
  List<StudentModel> get students => _students;
  List<AssessmentQuestionModel> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSchools() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In real app, use stream
      // For now, using a simple approach
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentsByGrade(String schoolId, String grade) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would use Firebase stream in real implementation
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuestionsByLevel(int level) async {
    _isLoading = true;
    notifyListeners();

    try {
      _questions = await FirebaseService.getQuestionsByLevel(level);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
