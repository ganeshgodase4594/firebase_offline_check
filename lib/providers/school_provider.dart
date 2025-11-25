// lib/providers/school_provider.dart
import 'package:flutter/material.dart';
import '../models/school_model.dart';
import '../models/academic_config_model.dart';
import '../service/firebase_service.dart';
import '../service/firebase_service_extension.dart';
import 'dart:async';

class SchoolProvider with ChangeNotifier {
  // State
  List<SchoolModel> _schools = [];
  SchoolModel? _currentSchool;
  AcademicConfigModel? _academicConfig;
  bool _isLoading = false;
  bool _isLoadingConfig = false;
  String? _errorMessage;

  StreamSubscription? _schoolsSubscription;
  StreamSubscription? _configSubscription;

  // Getters
  List<SchoolModel> get schools => _schools;
  SchoolModel? get currentSchool => _currentSchool;
  AcademicConfigModel? get academicConfig => _academicConfig;
  bool get isLoading => _isLoading;
  bool get isLoadingConfig => _isLoadingConfig;
  String? get errorMessage => _errorMessage;

  // Load all schools
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

  // Set current school
  void setCurrentSchool(SchoolModel school) {
    _currentSchool = school;
    loadAcademicConfig(school.id);
    notifyListeners();
  }

  // Load academic config for school
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

  // CRUD Operations
  Future<void> addSchool(SchoolModel school) async {
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

      // Update local state if it's the current school
      if (_currentSchool?.id == schoolId) {
        final updated = await FirebaseService.getSchool(schoolId);
        if (updated != null) {
          _currentSchool = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _schoolsSubscription?.cancel();
    _configSubscription?.cancel();
    super.dispose();
  }
}
