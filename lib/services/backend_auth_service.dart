import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'token_manager.dart';

/// Authentication service using the custom backend API
class BackendAuthService {
  static final BackendAuthService _instance = BackendAuthService._internal();
  factory BackendAuthService() => _instance;
  BackendAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TokenManager _tokenManager = TokenManager();

  // Stream controller for auth state changes
  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  /// Stream of authentication state changes
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;

  /// Current user data
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Initialize auth service
  Future<void> init() async {
    await _tokenManager.init();

    try {
      // Check if user is already logged in
      if (await _tokenManager.isLoggedIn()) {
        final userData = await _tokenManager.getUserData();
        _currentUser = userData;
        _authStateController.add(_currentUser);
      } else {
        _authStateController.add(null);
      }
    } catch (e) {
      debugPrint('Auth service init error: $e');
      // If there's any error during init, just show login screen
      _authStateController.add(null);
    }
  }

  /// Initialize auth service with timeout and fallback
  Future<void> initWithTimeout() async {
    try {
      await init().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Auth service init timed out - using offline mode');
          _authStateController.add(null);
        },
      );
    } catch (e) {
      debugPrint('Auth service init failed: $e - using offline mode');
      _authStateController.add(null);
    }
  }

  /// Guest login for offline mode
  Future<Map<String, dynamic>?> guestLogin() async {
    try {
      // Create a guest user
      final guestUser = {
        'userId': 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'guest@norden.com',
        'displayName': 'Guest User',
        'isGuest': true,
        'isAdmin': false,
        'token': 'guest_token_${DateTime.now().millisecondsSinceEpoch}',
      };

      _currentUser = guestUser;
      _authStateController.add(_currentUser);

      // Save guest token locally
      await _tokenManager.saveTokens(guestUser['token'] as String, '');
      await _tokenManager.saveUserData(guestUser);

      return guestUser;
    } catch (e) {
      debugPrint('Error in guest login: $e');
      return null;
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.authEndpoint}/register',
        body: {
          'email': email.trim(),
          'password': password,
          'displayName': displayName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      final data = response['data'] as Map<String, dynamic>;

      // Save tokens and user data
      await _tokenManager.saveTokens(data['token'], data['refreshToken']);
      await _tokenManager.saveUserData(data);

      _currentUser = data;
      _authStateController.add(_currentUser);

      return data;
    } catch (e) {
      debugPrint('Register error: $e');
      rethrow;
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.authEndpoint}/login',
        body: {'email': email.trim(), 'password': password},
      );

      final data = response['data'] as Map<String, dynamic>;

      // Save tokens and user data
      await _tokenManager.saveTokens(data['token'], data['refreshToken']);
      await _tokenManager.saveUserData(data);

      _currentUser = data;
      _authStateController.add(_currentUser);

      return data;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw ApiException('GOOGLE_ERROR', 'Failed to get Google ID token');
      }

      // Send ID token to backend
      final response = await ApiService.post(
        '${ApiConfig.authEndpoint}/google',
        body: {'idToken': googleAuth.idToken},
      );

      final data = response['data'] as Map<String, dynamic>;

      // Save tokens and user data
      await _tokenManager.saveTokens(data['token'], data['refreshToken'] ?? '');
      await _tokenManager.saveUserData(data);

      _currentUser = data;
      _authStateController.add(_currentUser);

      return data;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  /// Refresh access token
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await ApiService.post(
        '${ApiConfig.authEndpoint}/refresh',
        body: {'refreshToken': refreshToken},
      );

      final data = response['data'] as Map<String, dynamic>;

      // Save new tokens
      await _tokenManager.saveTokens(data['token'], data['refreshToken']);
      await _tokenManager.saveUserData(data);

      _currentUser = data;
      _authStateController.add(_currentUser);

      return data['token'];
    } catch (e) {
      debugPrint('Token refresh error: $e');
      // If refresh fails, logout user
      await logout();
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final refreshToken = await _tokenManager.getRefreshToken();

      if (accessToken != null) {
        // Call logout endpoint
        await ApiService.post(
          '${ApiConfig.authEndpoint}/logout',
          headers: {
            'Authorization': 'Bearer $accessToken',
            if (refreshToken != null) 'X-Refresh-Token': refreshToken,
          },
        );
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
      // Continue with local logout even if API call fails
    } finally {
      // Clear local data
      await _tokenManager.clearAll();
      await _googleSignIn.signOut();

      _currentUser = null;
      _authStateController.add(null);
    }
  }

  /// Get authenticated headers for API calls
  Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getValidAccessToken();
    if (token != null) {
      return ApiConfig.getAuthHeaders(token);
    }
    return null;
  }

  /// Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      // TODO: Check token expiry and refresh if needed
      return token;
    }
    return null;
  }

  /// Check if user is anonymous (guest)
  bool get isAnonymous => _currentUser?['isGuest'] == true;

  /// Check if user is admin
  bool get isAdmin => _currentUser?['isAdmin'] == true;

  /// Get user-friendly error message
  String getErrorMessage(ApiException e) {
    switch (e.code) {
      case 'DUPLICATE_EMAIL':
        return 'This email is already registered. Please use a different email or try logging in.';
      case 'INVALID_CREDENTIALS':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'INVALID_TOKEN':
        return 'Your session has expired. Please log in again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your internet connection and try again.';
      case 'GOOGLE_ERROR':
        return 'Google sign-in failed. Please try again.';
      default:
        return e.message;
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
