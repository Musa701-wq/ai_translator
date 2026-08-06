// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔐 [Auth] Starting Google Sign In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ [Auth] User cancelled Google Sign In');
        return null;
      }

      debugPrint('✅ [Auth] Google user selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('✅ [Auth] Got Google authentication tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔑 [Auth] Signing in to Firebase with Google credentials...');

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint('✅ [Auth] Successfully signed in: ${userCredential.user?.email}');

      return userCredential;
    } catch (e, stackTrace) {
      debugPrint('❌ [Auth] Google Sign In error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if running on iOS or macOS
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw UnsupportedError('Apple Sign In is only available on iOS and macOS');
      }

      debugPrint('🍎 [Auth] Starting Apple Sign In...');

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint('✅ [Auth] Got Apple credentials');

      // Create an OAuthCredential from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      debugPrint('🔑 [Auth] Signing in to Firebase with Apple credentials...');

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Update display name if available from Apple
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
          debugPrint('✅ [Auth] Updated display name: $displayName');
        }
      }

      debugPrint('✅ [Auth] Successfully signed in with Apple');

      return userCredential;
    } catch (e, stackTrace) {
      debugPrint('❌ [Auth] Apple Sign In error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('🚪 [Auth] Signing out...');

      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        debugPrint('✅ [Auth] Signed out from Google');
      }

      // Sign out from Firebase
      await _auth.signOut();
      debugPrint('✅ [Auth] Signed out from Firebase');
    } catch (e) {
      debugPrint('❌ [Auth] Sign out error: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      debugPrint('🗑️ [Auth] Deleting account...');

      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Delete user from Firebase
      await user.delete();
      debugPrint('✅ [Auth] Account deleted successfully');

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [Auth] Delete account error: ${e.code}');

      if (e.code == 'requires-recent-login') {
        debugPrint('⚠️ [Auth] Requires recent login for deletion');
        throw Exception('Please sign in again before deleting your account');
      }

      rethrow;
    } catch (e) {
      debugPrint('❌ [Auth] Delete account error: $e');
      rethrow;
    }
  }

  // Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    try {
      debugPrint('🔄 [Auth] Re-authenticating with Google...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Re-authentication cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await currentUser?.reauthenticateWithCredential(credential);
      debugPrint('✅ [Auth] Re-authenticated successfully');
    } catch (e) {
      debugPrint('❌ [Auth] Re-authentication error: $e');
      rethrow;
    }
  }

  // Re-authenticate with Apple
  Future<void> reauthenticateWithApple() async {
    try {
      debugPrint('🔄 [Auth] Re-authenticating with Apple...');

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await currentUser?.reauthenticateWithCredential(oauthCredential);
      debugPrint('✅ [Auth] Re-authenticated successfully');
    } catch (e) {
      debugPrint('❌ [Auth] Re-authentication error: $e');
      rethrow;
    }
  }

  // Check if user signed in with Google
  bool isGoogleUser() {
    final user = currentUser;
    if (user == null) return false;

    return user.providerData.any(
          (provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID,
    );
  }

  // Check if user signed in with Apple
  bool isAppleUser() {
    final user = currentUser;
    if (user == null) return false;

    return user.providerData.any(
          (provider) => provider.providerId == 'apple.com',
    );
  }

  // Get user display name
  String? getUserDisplayName() {
    return currentUser?.displayName;
  }

  // Get user email
  String? getUserEmail() {
    return currentUser?.email;
  }

  // Get user photo URL
  String? getUserPhotoUrl() {
    return currentUser?.photoURL;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return currentUser != null;
  }
}