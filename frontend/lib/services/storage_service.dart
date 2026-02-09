import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================
/// STORAGE SERVICE - Secure & Local Storage
/// ============================================
///
/// Uses:
/// - FlutterSecureStorage for sensitive data (tokens)
/// - SharedPreferences for non-sensitive data (settings)

class StorageService {
  // Secure storage for sensitive data
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _rememberMeKey = 'remember_me';
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _firstLaunchKey = 'first_launch';
  static const String _lastSyncKey = 'last_sync';

  // ==================== SECURE STORAGE (Tokens) ====================

  /// Save auth token
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get auth token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Delete auth token
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Check if user has token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== USER DATA ====================

  /// Save user data to secure storage
  static Future<void> saveUserData({
    required String id,
    required String email,
    required String role,
    String? name,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _userIdKey, value: id),
      _secureStorage.write(key: _userEmailKey, value: email),
      _secureStorage.write(key: _userRoleKey, value: role),
      if (name != null) _secureStorage.write(key: _userNameKey, value: name),
    ]);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _userEmailKey);
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    return await _secureStorage.read(key: _userRoleKey);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    return await _secureStorage.read(key: _userNameKey);
  }

  /// Delete user data
  static Future<void> deleteUserData() async {
    await Future.wait([
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _userEmailKey),
      _secureStorage.delete(key: _userRoleKey),
      _secureStorage.delete(key: _userNameKey),
    ]);
  }

  // ==================== SHARED PREFERENCES (Settings) ====================

  /// Save remember me preference
  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  /// Get remember me preference
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Save theme preference (0 = system, 1 = light, 2 = dark)
  static Future<void> setTheme(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, value);
  }

  /// Get theme preference
  static Future<int> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ?? 0;
  }

  /// Save language preference
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Get language preference
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'fr';
  }

  /// Check if first launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Set first launch complete
  static Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  /// Save last sync time
  static Future<void> setLastSync(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, dateTime.toIso8601String());
  }

  /// Get last sync time
  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSyncKey);
    return value != null ? DateTime.tryParse(value) : null;
  }

  // ==================== CLEAR ALL ====================

  /// Clear all secure storage
  static Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  /// Clear all preferences
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep some settings like theme and language
    final theme = await getTheme();
    final language = await getLanguage();
    await prefs.clear();
    await setTheme(theme);
    await setLanguage(language);
  }

  /// Clear everything (for logout)
  static Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      deleteUserData(),
    ]);
  }

  /// Full clear (for reset app)
  static Future<void> fullClear() async {
    await Future.wait([
      clearSecureStorage(),
      clearPreferences(),
    ]);
  }
}
