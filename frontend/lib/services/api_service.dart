import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Configuration des URLs - Auto-detect platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api'; // For Web
    } else {
      return 'http://10.0.2.2:5000/api'; // For Android Emulator
    }
  }

  // ========== INSCRIPTION ==========
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String countryCode,
    required String userType,
    required String password,
    required String confirmPassword,
    String? transporter,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'countryCode': countryCode,
          'userType': userType,
          'password': password,
          'confirmPassword': confirmPassword,
          if (transporter != null) 'transporter': transporter,
        }),
      );

      final data = json.decode(response.body);

      // Sauvegarder token si succès
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', json.encode(data['user']));
      }

      return data;
    } catch (e) {
      debugPrint('❌ Erreur inscription: $e');
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  // ========== CONNEXION ==========
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', json.encode(data['user']));
      }

      return data;
    } catch (e) {
      debugPrint('❌ Erreur connexion: $e');
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  // ========== UTILITAIRES ==========

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur récupération profil'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // ========== NOTIFICATIONS ==========

  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération notifications: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération compteur: $e');
      return {'success': false, 'unreadCount': 0};
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/pending-requests'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération demandes: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> handleDecision({
    required String requestType,
    required int requestId,
    required String decision,
    String? reason,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'requestType': requestType,
        'requestId': requestId,
        'decision': decision,
        'reason': reason,
      };

      if (extraData != null) {
        body.addAll(extraData);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/decision'),
        headers: headers,
        body: json.encode(body),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur décision: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ========== EXPORTS ==========

  static Future<Map<String, dynamic>> createExport({
    required String trailerNumber,
    required String date,
    required String clientName,
    required String country,
    String? transporter,
    int? barsCount,
    int? singlesCount,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/exports'),
        headers: headers,
        body: json.encode({
          'trailerNumber': trailerNumber,
          'date': date,
          'clientName': clientName,
          'country': country,
          'transporter': transporter,
          'barsCount': barsCount ?? 0,
          'singlesCount': singlesCount ?? 0,
          'notes': notes,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur création export: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getExports() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/exports'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération exports: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ========== IMPORTS ==========

  static Future<Map<String, dynamic>> createImport({
    required String trailerNumber,
    required String date,
    required String supplierName,
    required String country,
    String? transporter,
    int? itemsCount,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/imports'),
        headers: headers,
        body: json.encode({
          'trailerNumber': trailerNumber,
          'date': date,
          'supplierName': supplierName,
          'country': country,
          'transporter': transporter,
          'itemsCount': itemsCount ?? 0,
          'notes': notes,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur création import: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getImports() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/imports'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération imports: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ========== ADMIN ==========

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération dashboard: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération utilisateurs: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }
}
