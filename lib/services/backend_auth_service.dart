import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'token_manager.dart';

/// Authentication service using Firebase Auth
class BackendAuthService {
  static final BackendAuthService _instance = BackendAuthService._internal();
  factory BackendAuthService() => _instance;
  BackendAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth? _firebaseAuth; // Initialized after Firebase.initializeApp()
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
      // Ensure Firebase is initialized
      try {
        Firebase.app();
      } catch (_) {
        await Firebase.initializeApp();
      }

      // Bind FirebaseAuth now that Firebase is initialized
      _firebaseAuth = FirebaseAuth.instance;

      // Listen to Firebase auth changes and map to our user map
      _firebaseAuth!.authStateChanges().listen((user) async {
        if (user == null) {
          _currentUser = null;
          _authStateController.add(null);
          return;
        }

        final idToken = await user.getIdToken() ?? '';
        final data = {
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'isGuest': false,
          'isAdmin': false,
          'token': idToken,
        };

        await _tokenManager.saveTokens(idToken, '');
        await _tokenManager.saveUserData(data);
        _currentUser = data;
        _authStateController.add(_currentUser);
      });
    } catch (e) {
      debugPrint('Auth service init error: $e');
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
      if (_firebaseAuth == null) {
        throw FirebaseException(plugin: 'core', code: 'no-app');
      }
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      final idToken = await credential.user!.getIdToken() ?? '';

      final data = {
        'userId': credential.user!.uid,
        'email': credential.user!.email,
        'displayName': credential.user!.displayName,
        'isGuest': false,
        'isAdmin': false,
        'token': idToken,
      };

      await _tokenManager.saveTokens(idToken, '');
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
      if (_firebaseAuth == null) {
        throw FirebaseException(plugin: 'core', code: 'no-app');
      }
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final idToken = await credential.user!.getIdToken() ?? '';
      final data = {
        'userId': credential.user!.uid,
        'email': credential.user!.email,
        'displayName': credential.user!.displayName,
        'isGuest': false,
        'isAdmin': false,
        'token': idToken,
      };
      await _tokenManager.saveTokens(idToken, '');
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

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      if (_firebaseAuth == null) {
        throw FirebaseException(plugin: 'core', code: 'no-app');
      }
      final userCred = await _firebaseAuth!.signInWithCredential(credential);

      final idToken = await userCred.user!.getIdToken() ?? '';
      final data = {
        'userId': userCred.user!.uid,
        'email': userCred.user!.email,
        'displayName': userCred.user!.displayName,
        'isGuest': false,
        'isAdmin': false,
        'token': idToken,
      };
      await _tokenManager.saveTokens(idToken, '');
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
      if (_firebaseAuth == null) return null;
      final user = _firebaseAuth!.currentUser;
      if (user == null) return null;
      final idToken = await user.getIdToken(true) ?? '';
      await _tokenManager.saveTokens(idToken, '');
      return idToken;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await logout();
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (_firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }
    } catch (e) {
      debugPrint('Firebase signOut error: $e');
    } finally {
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
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return null;
  }

  /// Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    if (_firebaseAuth == null) return null;
    final user = _firebaseAuth!.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Check if user is anonymous (guest)
  bool get isAnonymous => _currentUser?['isGuest'] == true;

  /// Check if user is admin
  bool get isAdmin => _currentUser?['isAdmin'] == true;

  /// Get user-friendly error message
  String getErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in.';
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Invalid email or password.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
      }
      return e.message ?? 'Authentication error. Please try again.';
    }
    return 'Unexpected error. Please try again.';
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
