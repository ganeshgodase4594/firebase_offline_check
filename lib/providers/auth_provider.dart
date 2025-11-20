// lib/providers/auth_provider.dart
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricEnabled = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get biometricEnabled => _biometricEnabled;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
      }
      await _loadBiometricSetting();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    _currentUser = await FirebaseService.getUser(uid);
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseService.signInWithEmailPassword(email, password);
      await _loadUserData(userCredential.user!.uid);

      // Save credentials for biometric login
      await _saveCredentials(email, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithBiometric() async {
    if (!_biometricEnabled) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Check if biometric is available
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _errorMessage = 'Biometric authentication not available';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Authenticate with biometric
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Brainmoto',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        _errorMessage = 'Biometric authentication failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get saved credentials
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final password = prefs.getString('user_password');

      if (email == null || password == null) {
        _errorMessage = 'No saved credentials found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign in with saved credentials
      return await signIn(email, password);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name, UserRole role,
      {String? schoolId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseService.createUserWithEmailPassword(email, password);

      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        schoolId: schoolId,
        createdAt: DateTime.now(),
      );

      await FirebaseService.createUser(newUser);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> enableBiometric() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _errorMessage = 'Biometric authentication not available on this device';
        notifyListeners();
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric login for Brainmoto',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);
        _biometricEnabled = true;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false);
    await prefs.remove('user_email');
    await prefs.remove('user_password');
    _biometricEnabled = false;
    notifyListeners();
  }

  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'email-already-in-use':
          return 'Email already in use';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        default:
          return error.message ?? 'Authentication error';
      }
    }
    return error.toString();
  }
}
