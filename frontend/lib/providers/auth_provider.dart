import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

/// ============================================
/// AUTH PROVIDER - STATE MANAGEMENT FOR AUTHENTICATION
/// ============================================
///
/// Responsibilities:
/// - Manage authentication state
/// - Handle login/register/logout
/// - Persist user session
/// - Token management with auto-refresh

enum AuthStatus {
  initial, // App just started
  loading, // Processing auth request
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
  error, // An error occurred
}

class AuthProvider extends ChangeNotifier {
  // ==================== STATE ====================
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  final ApiClient _api = ApiClient();

  // ==================== GETTERS ====================
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn =>
      _status == AuthStatus.authenticated && _currentUser != null;
  bool get isInitialized => _status != AuthStatus.initial;

  UserRole? get currentRole => _currentUser?.role;

  // Role-based shortcuts
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAgentExport => _currentUser?.isAgentExport ?? false;
  bool get isAgentImport => _currentUser?.isAgentImport ?? false;
  bool get isAgentStock => _currentUser?.isAgentStock ?? false;
  bool get isPartenaire => _currentUser?.isPartenaire ?? false;

  // ==================== INITIALIZATION ====================

  /// Initialize auth state from stored data
  Future<void> init() async {
    if (_status != AuthStatus.initial) return; // Already initialized

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Check for stored token
      final token = await StorageService.getToken();

      if (token != null && token.isNotEmpty) {
        // Check if token is expired
        if (!JwtDecoder.isExpired(token)) {
          // Token is valid, restore user data
          await _restoreUserFromStorage();

          if (_currentUser != null) {
            _status = AuthStatus.authenticated;
          } else {
            // Token exists but no user data, try to fetch profile
            await _fetchAndSaveProfile();
          }
        } else {
          // Token expired, clear storage
          await StorageService.clearAll();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  /// Restore user from storage
  Future<void> _restoreUserFromStorage() async {
    try {
      final userId = await StorageService.getUserId();
      final email = await StorageService.getUserEmail();
      final role = await StorageService.getUserRole();
      final name = await StorageService.getUserName();
      final token = await StorageService.getToken();

      if (userId != null && email != null && role != null) {
        _currentUser = User(
          id: int.tryParse(userId) ?? 0,
          fullName: name ?? '',
          email: email,
          phone: '',
          transporter: await StorageService.getUserTransporter(),
          role: User.stringToRole(role),
          token: token,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('❌ Error restoring user: $e');
    }
  }

  /// Fetch profile from API and save to storage
  Future<void> _fetchAndSaveProfile() async {
    try {
      final response = await _api.get(ApiEndpoints.profile);

      if (response.data['success'] == true) {
        final userData = response.data['user'];
        final token = await StorageService.getToken();

        _currentUser = User.fromJson(userData, token: token);
        await _saveUserToStorage(_currentUser!);
        _status = AuthStatus.authenticated;
      } else {
        await StorageService.clearAll();
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      await StorageService.clearAll();
      _status = AuthStatus.unauthenticated;
    }
  }

  // ==================== LOGIN ====================

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        // Create user model
        _currentUser = User.fromJson(userData, token: token);

        // Save to secure storage
        await StorageService.saveToken(token);
        await _saveUserToStorage(_currentUser!);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Erreur de connexion';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ==================== REGISTER ====================

  /// Register a new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String countryCode,
    required String userType,
    required String password,
    required String confirmPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'countryCode': countryCode,
          'userType': userType,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        // Create user model
        _currentUser = User.fromJson(userData, token: token);

        // Save to secure storage
        await StorageService.saveToken(token);
        await _saveUserToStorage(_currentUser!);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Erreur d\'inscription';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioError(e).message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ==================== LOGOUT ====================

  /// Logout and clear all stored data
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Optionally call logout API endpoint
      // await _api.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore logout API errors
    }

    // Clear local storage
    await StorageService.clearAll();

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ==================== HELPERS ====================

  /// Save user data to storage
  Future<void> _saveUserToStorage(User user) async {
    await StorageService.saveUserData(
      id: user.id.toString(),
      email: user.email,
      role: User.roleToApiString(user.role),
      name: user.fullName,
      transporter: user.transporter,
    );
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Reset to unauthenticated state (for error recovery)
  void resetState() {
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (permission) {
      case 'create_export':
        return _currentUser!.canCreateExport();
      case 'create_import':
        return _currentUser!.canCreateImport();
      case 'manage_users':
        return _currentUser!.canManageUsers();
      case 'view_reports':
        return _currentUser!.canViewReports();
      case 'approve_requests':
        return _currentUser!.canApproveRequests();
      default:
        return false;
    }
  }
}
