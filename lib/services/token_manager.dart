import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Manages JWT tokens and user data storage
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save access and refresh tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(
      key: ApiConfig.accessTokenKey,
      value: accessToken,
    );
    await _secureStorage.write(
      key: ApiConfig.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: ApiConfig.accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: ApiConfig.refreshTokenKey);
  }

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await init();
    await _prefs!.setString(ApiConfig.userDataKey, jsonEncode(userData));
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    await init();
    final userDataString = _prefs!.getString(ApiConfig.userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Check if user is guest
  Future<bool> isGuest() async {
    final userData = await getUserData();
    return userData?['isGuest'] == true;
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    final userData = await getUserData();
    return userData?['isAdmin'] == true;
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    final userData = await getUserData();
    return userData?['userId'];
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await init();
    await _prefs!.clear();
  }

  /// Clear only tokens but keep user data
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: ApiConfig.accessTokenKey);
    await _secureStorage.delete(key: ApiConfig.refreshTokenKey);
  }
}
