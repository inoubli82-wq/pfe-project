import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===========================================
// AUTH PROVIDER - STATE MANAGEMENT FOR ROLES
// ===========================================

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  UserRole? get currentRole => _currentUser?.role;

  // Check permissions shortcuts
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAgentExport => _currentUser?.isAgentExport ?? false;
  bool get isAgentImport => _currentUser?.isAgentImport ?? false;

  // Initialize - Check if user is already logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        final userData = json.decode(userJson);
        _currentUser = User.fromJson(userData, token: token);
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);

      if (response['success'] == true) {
        final token = response['token'];
        _currentUser = User.fromJson(response['user'], token: token);

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', json.encode(response['user']));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Erreur de connexion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String countryCode,
    required String userType,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        countryCode: countryCode,
        userType: userType,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response['success'] == true) {
        final token = response['token'];
        _currentUser = User.fromJson(response['user'], token: token);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Erreur d\'inscription';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
