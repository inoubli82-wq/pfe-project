import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:import_export_app/models/export_data.dart';
import 'package:import_export_app/models/agent_export_data.dart';
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

  static Future<Map<String, dynamic>> getHistoryRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/history-requests'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération historique: $e');
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

  static Future<Map<String, dynamic>> createExport(
      AgentExportData exportData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/exports'),
        headers: headers,
        body: jsonEncode(exportData.toJson()),
      );
      return jsonDecode(response.body);
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
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['exports'] != null) {
        final exports = (data['exports'] as List)
            .map((item) => AgentExportData.fromJson(item))
            .toList();
        return {
          'success': true,
          'exports': exports,
        };
      }
      return data;
    } catch (e) {
      debugPrint('❌ Erreur récupération exports: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> updateExport(
      int id, AgentExportData exportData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/exports/$id'),
        headers: headers,
        body: jsonEncode(exportData.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur mise à jour export: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> deleteExport(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/exports/$id'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur suppression export: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> updateExportStatus(
      int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/exports/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur mise à jour statut export: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> updateArrivalInfo({
    required int id,
    required String containerNumber,
    required String expectedArrivalDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/exports/$id/arrival'),
        headers: headers,
        body: jsonEncode({
          'containerNumber': containerNumber,
          'expectedArrivalDate': expectedArrivalDate,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur mise à jour info arrivée: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> receiveExport({
    required int id,
    required int receivedBars,
    required int receivedSingles,
    required int receivedSuctionCups,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/exports/$id/receive'),
        headers: headers,
        body: jsonEncode({
          'receivedBars': receivedBars,
          'receivedSingles': receivedSingles,
          'receivedSuctionCups': receivedSuctionCups,
          'notes': notes,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur réception export: $e');
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

  static Future<Map<String, dynamic>> getDashboardStats({String? startDate, String? endDate}) async {
    try {
      final headers = await _getHeaders();
      
      String url = '$baseUrl/admin/dashboard';
      if (startDate != null && endDate != null) {
        url += '?startDate=$startDate&endDate=$endDate';
      }

      final response = await http.get(
        Uri.parse(url),
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

  // ========== PARTENAIRE EXPORTS ==========

  static Future<Map<String, dynamic>> createExportData(
      ExportData exportData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/export-data'),
        headers: headers,
        body: jsonEncode(exportData.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur création export data: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getAllExportData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/export-data'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final exports = (data['data'] as List)
            .map((item) => ExportData.fromJson(item))
            .toList();
        return {
          'success': true,
          'data': exports,
        };
      }
      return data;
    } catch (e) {
      debugPrint('❌ Erreur récupération export data: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> getExportDataById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/export-data/$id'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return {
          'success': true,
          'data': ExportData.fromJson(data['data']),
        };
      }
      return data;
    } catch (e) {
      debugPrint('❌ Erreur récupération export data: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> updateExportData(
    int id,
    ExportData exportData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/export-data/$id'),
        headers: headers,
        body: jsonEncode(exportData.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur mise à jour export data: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> deleteExportData(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/export-data/$id'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur suppression export data: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ===========================================
  // ADMIN API
  // ===========================================
  

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur createUser: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> updateUserRole(int userId, String newRole) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/role'),
        headers: headers,
        body: json.encode({'userType': newRole}),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur updateUserRole: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur deleteUser: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  // ========== STOCKS ==========

  static Future<Map<String, dynamic>> getStocks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stocks'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur récupération stocks: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }

  static Future<Map<String, dynamic>> updateStock({
    required String transporter,
    required int barsCount,
    required int singlesCount,
    required int suctionCupsCount,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/stocks/$transporter'),
        headers: headers,
        body: json.encode({
          'bars_count': barsCount,
          'singles_count': singlesCount,
          'suction_cups_count': suctionCupsCount,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Erreur mise à jour stock: $e');
      return {'success': false, 'message': 'Erreur serveur'};
    }
  }
}
