// lib/providers/question_provider.dart
import 'package:flutter/material.dart';
import '../models/assessment_question_model.dart';
import '../service/firebase_service.dart';
import 'dart:async';

class QuestionProvider with ChangeNotifier {
  // State
  final Map<int, List<AssessmentQuestionModel>> _questionsByLevel = {};
  int? _selectedLevel;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _questionsSubscription;

  // Getters
  List<AssessmentQuestionModel> get questions =>
      _selectedLevel != null ? (_questionsByLevel[_selectedLevel] ?? []) : [];

  int? get selectedLevel => _selectedLevel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get questionCount => questions.length;
  bool get isComplete => questionCount == 6;

  // Load questions for a level
  void loadQuestionsForLevel(int level) {
    _selectedLevel = level;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _questionsSubscription?.cancel();
    _questionsSubscription =
        FirebaseService.getQuestionsByLevelStream(level).listen(
      (questions) {
        _questionsByLevel[level] = questions;
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

  // Get questions for specific level (without changing selected)
  Future<List<AssessmentQuestionModel>> getQuestionsForLevel(int level) async {
    if (_questionsByLevel.containsKey(level)) {
      return _questionsByLevel[level]!;
    }

    try {
      final questions = await FirebaseService.getQuestionsByLevel(level);
      _questionsByLevel[level] = questions;
      notifyListeners();
      return questions;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // CRUD Operations
  Future<bool> addQuestion(AssessmentQuestionModel question) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseService.createAssessmentQuestion(question);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuestion(
    String questionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await FirebaseService.updateAssessmentQuestion(questionId, data);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteQuestion(String questionId) async {
    try {
      await FirebaseService.deleteAssessmentQuestion(questionId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reorderQuestions(List<AssessmentQuestionModel> reordered) async {
    try {
      for (int i = 0; i < reordered.length; i++) {
        await FirebaseService.updateAssessmentQuestion(
          reordered[i].id,
          {'order': i, 'questionNumber': i},
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCache() {
    _questionsByLevel.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _questionsSubscription?.cancel();
    super.dispose();
  }
}
