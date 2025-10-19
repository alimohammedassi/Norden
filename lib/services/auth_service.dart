import 'package:flutter/foundation.dart';
import 'backend_auth_service.dart';
import 'api_service.dart';

/// Authentication service wrapper for backward compatibility
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final BackendAuthService _backendAuth = BackendAuthService();

  /// Get current user data
  Map<String, dynamic>? get currentUser => _backendAuth.currentUser;

  /// Auth state changes stream
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _backendAuth.authStateChanges;

  /// Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _backendAuth.login(
        email: email,
        password: password,
      );
      return userData;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<Map<String, dynamic>?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userData = await _backendAuth.register(
        email: email,
        password: password,
        displayName: displayName ?? '',
      );
      return userData;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final userData = await _backendAuth.signInWithGoogle();
      return userData;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  /// Sign in anonymously (Guest mode)
  Future<Map<String, dynamic>?> signInAnonymously() async {
    try {
      final userData = await _backendAuth.guestLogin();
      return userData;
    } catch (e) {
      debugPrint('Anonymous sign in error: $e');
      rethrow;
    }
  }

  /// Check if current user is anonymous (guest)
  bool get isAnonymous => _backendAuth.isAnonymous;

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _backendAuth.logout();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(dynamic e) {
    if (e is ApiException) {
      return _backendAuth.getErrorMessage(e);
    }
    return e.toString();
  }

  /// Check if user is admin
  bool get isAdmin => _backendAuth.isAdmin;

  /// Send password reset email (placeholder implementation)
  Future<void> sendPasswordResetEmail(String email) async {
    // TODO: Implement password reset in backend API
    throw UnimplementedError(
      'Password reset not yet implemented in backend API',
    );
  }
}
