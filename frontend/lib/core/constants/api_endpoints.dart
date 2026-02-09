import 'package:flutter/foundation.dart' show kIsWeb;

/// ============================================
/// API ENDPOINTS - Centralized API Configuration
/// ============================================
///
/// Usage: ApiEndpoints.baseUrl, ApiEndpoints.login, etc.

class ApiEndpoints {
  ApiEndpoints._(); // Private constructor

  // ==================== BASE URL ====================
  /// Auto-detect platform for correct base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://10.0.2.2:5000/api'; // Android Emulator
    }
  }

  // ==================== AUTH ENDPOINTS ====================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // ==================== USER ENDPOINTS ====================
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String userById = '/users'; // + /{id}
  static const String updateUser = '/users'; // + /{id}
  static const String deleteUser = '/users'; // + /{id}

  // ==================== IMPORT ENDPOINTS ====================
  static const String imports = '/imports';
  static const String importById = '/imports'; // + /{id}
  static const String importCreate = '/imports';
  static const String importUpdate = '/imports'; // + /{id}
  static const String importDelete = '/imports'; // + /{id}
  static const String importsByStatus = '/imports/status'; // + /{status}

  // ==================== EXPORT ENDPOINTS ====================
  static const String exports = '/exports';
  static const String exportById = '/exports'; // + /{id}
  static const String exportCreate = '/exports';
  static const String exportUpdate = '/exports'; // + /{id}
  static const String exportDelete = '/exports'; // + /{id}
  static const String exportsByStatus = '/exports/status'; // + /{status}

  // ==================== NOTIFICATION ENDPOINTS ====================
  static const String notifications = '/notifications';
  static const String notificationById = '/notifications'; // + /{id}
  static const String notificationsUnread = '/notifications/unread';
  static const String notificationMarkRead = '/notifications'; // + /{id}/read
  static const String notificationMarkAllRead = '/notifications/read-all';

  // ==================== DASHBOARD ENDPOINTS ====================
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardRecent = '/dashboard/recent';
  static const String dashboardCharts = '/dashboard/charts';

  // ==================== PARTNER ENDPOINTS ====================
  static const String partnerRequests = '/partner/requests';
  static const String partnerVerify = '/partner/verify';
  static const String partnerHistory = '/partner/history';

  // ==================== HELPER METHODS ====================

  /// Build full URL from endpoint
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  /// Build URL with ID parameter
  static String withId(String endpoint, int id) => '$baseUrl$endpoint/$id';

  /// Build URL with query parameters
  static String withParams(String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters:
            params.map((key, value) => MapEntry(key, value.toString())));
    return uri.toString();
  }
}
