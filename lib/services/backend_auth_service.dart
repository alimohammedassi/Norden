import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'token_manager.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Authentication service using custom Backend API
class BackendAuthService {
  static final BackendAuthService _instance = BackendAuthService._internal();
  factory BackendAuthService() => _instance;
  BackendAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web Client ID from Google Cloud Console
    // Required to get an ID token that your backend can verify
    serverClientId: '202089577282-pe5qa8vci7o9i4q6vsjk7sk76bib694k.apps.googleusercontent.com',
  );
  
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
      // 1. Try to load persisted user from TokenManager
      final savedUser = await _tokenManager.getUserData();
      final token = await _tokenManager.getAccessToken();

      if (token != null && token.isNotEmpty && savedUser != null) {
        _currentUser = savedUser;
        _currentUser!['token'] = token; // Ensure token is in the map
        _authStateController.add(_currentUser);
        debugPrint('Auth service: Loaded persisted user: ${_currentUser!['email']}');
      } else {
        debugPrint('Auth service: No persisted user found');
        _authStateController.add(null);
      }
    } catch (e) {
      debugPrint('Auth service init error: $e');
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  /// Initialize auth service with timeout and fallback
  Future<void> initWithTimeout() async {
    try {
      debugPrint('Auth service: Starting initialization...');
      await init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Auth service init timed out (10s) - using offline mode');
          if (_currentUser == null) {
            _authStateController.add(null);
          }
        },
      );
    } catch (e) {
      debugPrint('Auth service init failed: $e - using offline mode');
      if (_currentUser == null) {
        _authStateController.add(null);
      }
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
        ApiConfig.registerEndpoint,
        body: {
          'email': email.trim(),
          'password': password,
          'displayName': displayName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      final data = response['data'] != null
          ? response['data'] as Map<String, dynamic>
          : response;
      final token = data['token'] ?? '';

      final userData = {
        'userId': data['userId'] ?? data['id'] ?? '',
        'email': data['email'] ?? email.trim(),
        'displayName': data['displayName'] ?? displayName,
        'isGuest': false,
        'isAdmin': data['isAdmin'] ?? false,
        'token': token,
      };

      await _tokenManager.saveTokens(token, '');
      await _tokenManager.saveUserData(userData);
      _currentUser = userData;
      _authStateController.add(_currentUser);
      return userData;
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
        ApiConfig.loginEndpoint,
        body: {'email': email.trim(), 'password': password},
      );

      final data = response['data'] != null
          ? response['data'] as Map<String, dynamic>
          : response;
      final token = data['token'] ?? '';

      final userData = {
        'userId': data['userId'] ?? data['id'] ?? '',
        'email': data['email'] ?? email.trim(),
        'displayName': data['displayName'] ?? '',
        'isGuest': false,
        'isAdmin': data['isAdmin'] ?? false,
        'token': token,
      };

      await _tokenManager.saveTokens(token, '');
      await _tokenManager.saveUserData(userData);
      _currentUser = userData;
      _authStateController.add(_currentUser);
      return userData;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      debugPrint('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('Google auth tokens obtained, sending to backend...');
      
      // The idToken is what your backend will use to verify against Google
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception("Could not retrieve ID token from Google.");
      }

      final response = await ApiService.post(
        ApiConfig.googleLoginEndpoint,
        body: {'idToken': idToken},
      );

      debugPrint('Google login response received: $response');

      final data = response['data'] != null
          ? response['data'] as Map<String, dynamic>
          : response;
      final token = data['token'] ?? '';

      final userData = {
        'userId': data['userId'] ?? data['id'] ?? '',
        'email': data['email'] ?? googleUser.email,
        'displayName': data['displayName'] ?? googleUser.displayName,
        'isGuest': false,
        'isAdmin': data['isAdmin'] ?? false,
        'token': token,
      };

      debugPrint('User data created: ${userData['email']}');

      await _tokenManager.saveTokens(token, '');
      await _tokenManager.saveUserData(userData);
      _currentUser = userData;
      _authStateController.add(_currentUser);
      return userData;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      if (e is ApiException) {
        debugPrint('API Error details: ${e.details}');
        debugPrint('API Error code: ${e.code}');
        debugPrint('API Error message: ${e.message}');
      }
      rethrow;
    }
  }

  /// Refresh access token
  Future<String?> refreshToken() async {
    // Requires your backend to have a refresh token mechanism.
    // Placeholder returning null for now unless implemented.
    return null;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _tokenManager.clearAll();
      await _googleSignIn.signOut();
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  /// Get authenticated headers for API calls
  Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getValidAccessToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return null;
  }

  /// Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    // Return token from memory if available
    if (_currentUser != null && _currentUser!['token'] != null) {
      return _currentUser!['token'] as String;
    }

    // Check storage
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      // Update memory
      if (_currentUser == null) {
        _currentUser = await _tokenManager.getUserData();
      }
      if (_currentUser != null) {
        _currentUser!['token'] = token;
      }
      return token;
    }

    return null;
  }

  /// Check if user is anonymous (guest)
  bool get isAnonymous => _currentUser?['isGuest'] == true;

  /// Check if user is admin
  bool get isAdmin => _currentUser?['isAdmin'] == true;

  /// Get user-friendly error message
  String getErrorMessage(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '');
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
