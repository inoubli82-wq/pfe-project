import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Configuration des URLs
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  // Pour émulateur Android: http://10.0.2.2:5000/api
  // Pour émulateur iOS: http://localhost:5000/api
  // Pour web: http://localhost:5000/api

  // ========== INSCRIPTION ==========
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String countryCode,
    required String userType,
    required String password,
    required String confirmPassword,
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
      print('❌ Erreur inscription: $e');
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
      print('❌ Erreur connexion: $e');
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
}
