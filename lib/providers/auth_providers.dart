// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
      debugPrint('👤 [AuthProvider] Auth state changed: ${user?.email ?? "No user"}');
    });

    // Set initial user
    _user = _authService.currentUser;
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔐 [AuthProvider] Starting Google Sign In...');

      final userCredential = await _authService.signInWithGoogle();

      _isLoading = false;

      if (userCredential == null) {
        debugPrint('⚠️ [AuthProvider] Google Sign In cancelled');
        _errorMessage = 'Sign in cancelled';
        notifyListeners();
        return false;
      }

      _user = userCredential.user;
      debugPrint('✅ [AuthProvider] Successfully signed in: ${_user?.email}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [AuthProvider] Google Sign In error: $e');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🍎 [AuthProvider] Starting Apple Sign In...');

      final userCredential = await _authService.signInWithApple();

      _isLoading = false;

      if (userCredential == null) {
        debugPrint('⚠️ [AuthProvider] Apple Sign In cancelled');
        _errorMessage = 'Sign in cancelled';
        notifyListeners();
        return false;
      }

      _user = userCredential.user;
      debugPrint('✅ [AuthProvider] Successfully signed in with Apple');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [AuthProvider] Apple Sign In error: $e');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🚪 [AuthProvider] Signing out...');

      await _authService.signOut();

      _user = null;
      _isLoading = false;
      _errorMessage = null;

      debugPrint('✅ [AuthProvider] Signed out successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [AuthProvider] Sign out error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to sign out. Please try again.';
      notifyListeners();
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🗑️ [AuthProvider] Deleting account...');

      await _authService.deleteAccount();

      _user = null;
      _isLoading = false;

      debugPrint('✅ [AuthProvider] Account deleted successfully');
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthProvider] Delete account error: ${e.code}');
      _isLoading = false;

      if (e.code == 'requires-recent-login') {
        _errorMessage = 'Please sign in again before deleting your account';
      } else {
        _errorMessage = _getErrorMessage(e);
      }

      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ [AuthProvider] Delete account error: $e');
      _isLoading = false;
      _errorMessage = 'Failed to delete account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Re-authenticate (for sensitive operations like delete)
  Future<bool> reauthenticate() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔄 [AuthProvider] Re-authenticating...');

      if (_authService.isGoogleUser()) {
        await _authService.reauthenticateWithGoogle();
      } else if (_authService.isAppleUser()) {
        await _authService.reauthenticateWithApple();
      } else {
        throw Exception('Unknown sign-in provider');
      }

      _isLoading = false;
      debugPrint('✅ [AuthProvider] Re-authenticated successfully');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [AuthProvider] Re-authentication error: $e');
      _isLoading = false;
      _errorMessage = 'Re-authentication failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Get user display name
  String getUserDisplayName() {
    return _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';
  }

  // Get user email
  String getUserEmail() {
    return _user?.email ?? 'No email';
  }

  // Get user photo URL
  String? getUserPhotoUrl() {
    return _user?.photoURL;
  }

  // Check if signed in with Google
  bool isGoogleUser() {
    return _authService.isGoogleUser();
  }

  // Check if signed in with Apple
  bool isAppleUser() {
    return _authService.isAppleUser();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return 'An account already exists with this email using a different sign-in method.';
        case 'invalid-credential':
          return 'Invalid credentials. Please try again.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-verification-code':
          return 'Invalid verification code.';
        case 'invalid-verification-id':
          return 'Invalid verification ID.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }

    if (error is UnsupportedError) {
      return error.message ?? 'This feature is not supported on your device.';
    }

    return error.toString();
  }
}