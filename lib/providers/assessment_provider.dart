// lib/providers/assessment_provider.dart
import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../models/assessment_question_model.dart';
import '../models/student_model.dart';
import '../models/academic_config_model.dart';
import '../service/firebase_service.dart';
import '../service/offline_service.dart';

class AssessmentProvider with ChangeNotifier {
  // State
  List<AssessmentQuestionModel> _questions = [];
  List<StudentModel> _students = [];
  int _currentQuestionIndex = 0;
  int _currentStudentIndex = 0;
  Map<String, dynamic> _allResponses = {}; // For by-skill mode
  Map<String, dynamic> _currentResponses = {}; // For by-student mode
  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;
  AcademicConfigModel? _academicConfig;

  // Getters
  List<AssessmentQuestionModel> get questions => _questions;
  List<StudentModel> get students => _students;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get currentStudentIndex => _currentStudentIndex;
  Map<String, dynamic> get allResponses => _allResponses;
  Map<String, dynamic> get currentResponses => _currentResponses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get timerSeconds => _timerSeconds;
  bool get isTimerRunning => _isTimerRunning;
  AcademicConfigModel? get academicConfig => _academicConfig;

  AssessmentQuestionModel? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentQuestionIndex];

  StudentModel? get currentStudent =>
      _students.isEmpty ? null : _students[_currentStudentIndex];

  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  bool get isLastStudent => _currentStudentIndex >= _students.length - 1;

  // Initialize for assessment
  Future<void> initializeAssessment({
    required List<StudentModel> students,
    required int level,
    required AcademicConfigModel academicConfig,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = students;
      _academicConfig = academicConfig;
      _questions = await FirebaseService.getQuestionsByLevel(level);
      _currentQuestionIndex = 0;
      _currentStudentIndex = 0;
      _allResponses = {};
      _currentResponses = {};

      // Initialize response maps for by-skill mode
      for (var student in students) {
        _allResponses[student.id] = {};
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Timer controls
  void startTimer() {
    _timerSeconds = 0;
    _isTimerRunning = true;
    notifyListeners();

    // Note: Actual timer increment should be handled by UI
    // using periodic timer that calls incrementTimer()
  }

  void incrementTimer() {
    if (_isTimerRunning) {
      _timerSeconds++;
      notifyListeners();
    }
  }

  void stopTimer() {
    _isTimerRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timerSeconds = 0;
    _isTimerRunning = false;
    notifyListeners();
  }

  // Response management
  void setResponse({
    required String studentId,
    required int questionIndex,
    required dynamic value,
  }) {
    if (_allResponses.containsKey(studentId)) {
      _allResponses[studentId]['response$questionIndex'] = value;
    }
    notifyListeners();
  }

  void setCurrentResponse(int questionIndex, dynamic value) {
    _currentResponses['response$questionIndex'] = value;
    notifyListeners();
  }

  dynamic getResponse(String studentId, int questionIndex) {
    return _allResponses[studentId]?['response$questionIndex'];
  }

  dynamic getCurrentResponse(int questionIndex) {
    return _currentResponses['response$questionIndex'];
  }

  // Navigation - By Skill Mode
  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      resetTimer();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      resetTimer();
      notifyListeners();
    }
  }

  // Navigation - By Student Mode
  void nextStudent() {
    if (!isLastStudent) {
      _currentStudentIndex++;
      _currentResponses = {};
      resetTimer();
      notifyListeners();
    }
  }

  void previousStudent() {
    if (_currentStudentIndex > 0) {
      _currentStudentIndex--;
      _currentResponses = {};
      resetTimer();
      notifyListeners();
    }
  }

  // Mark student absent
  Future<void> markStudentAbsent(String studentId) async {
    try {
      await FirebaseService.markStudentAbsent(studentId, true);
      _students.removeWhere((s) => s.id == studentId);
      _allResponses.remove(studentId);

      if (_students.isEmpty) {
        _errorMessage = 'All students marked absent';
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Validate responses
  bool validateCurrentStudentResponses() {
    return _currentResponses.length == _questions.length;
  }

  bool validateAllResponses() {
    for (var student in _students) {
      final responses = _allResponses[student.id] as Map<String, dynamic>;
      if (responses.length != _questions.length) {
        return false;
      }
    }
    return true;
  }

  // Save assessments - By Student Mode
  Future<bool> saveCurrentAssessment({
    required String teacherId,
    required bool isOnline,
  }) async {
    if (!validateCurrentStudentResponses()) {
      _errorMessage = 'Please complete all assessments';
      notifyListeners();
      return false;
    }

    final student = currentStudent;
    if (student == null || _academicConfig == null) {
      _errorMessage = 'Invalid state';
      notifyListeners();
      return false;
    }

    try {
      final assessment = AssessmentModel(
        id: '',
        studentId: student.id,
        teacherId: teacherId,
        schoolId: student.schoolId,
        level: student.level,
        responses: _currentResponses,
        assessmentDate: DateTime.now(),
        academicYear: _academicConfig!.currentYear,
        term: _academicConfig!.currentTerm,
        isSynced: isOnline,
        assessmentType: 'by_student',
      );

      if (isOnline) {
        await FirebaseService.createAssessment(assessment);
      } else {
        await OfflineService.saveAssessmentOffline(assessment);
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Save assessments - By Skill Mode
  Future<Map<String, int>> saveAllAssessments({
    required String teacherId,
    required bool isOnline,
  }) async {
    int savedCount = 0;
    int errorCount = 0;

    for (var student in _students) {
      if (student.isAbsent) continue;

      final responses = _allResponses[student.id] as Map<String, dynamic>;
      if (responses.length != _questions.length) {
        errorCount++;
        continue;
      }

      try {
        final assessment = AssessmentModel(
          id: '',
          studentId: student.id,
          teacherId: teacherId,
          schoolId: student.schoolId,
          level: student.level,
          responses: responses,
          assessmentDate: DateTime.now(),
          academicYear: _academicConfig!.currentYear,
          term: _academicConfig!.currentTerm,
          isSynced: isOnline,
          assessmentType: 'by_skill',
        );

        if (isOnline) {
          await FirebaseService.createAssessment(assessment);
        } else {
          await OfflineService.saveAssessmentOffline(assessment);
        }

        savedCount++;
      } catch (e) {
        errorCount++;
      }
    }

    return {'saved': savedCount, 'failed': errorCount};
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _questions = [];
    _students = [];
    _currentQuestionIndex = 0;
    _currentStudentIndex = 0;
    _allResponses = {};
    _currentResponses = {};
    _isLoading = false;
    _errorMessage = null;
    resetTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
