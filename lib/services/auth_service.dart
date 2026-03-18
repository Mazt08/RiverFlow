import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:river_flow/services/firestore_service.dart';
import 'package:river_flow/models/user_model.dart';

export 'package:river_flow/models/user_model.dart' show UserRole;

/// Authenticated user state model.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Convert from UserModel (Firestore).
  factory AuthUser.fromUserModel(UserModel userModel) {
    return AuthUser(
      id: userModel.uid,
      name: userModel.name,
      email: userModel.email,
      role: userModel.role,
    );
  }
}

/// Handles authentication state and credentials.
/// Uses Cloud Firestore for user profiles and role management.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  StreamSubscription<String>? _tokenRefreshSubscription;

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null && _currentUser != null;

  /// Attempt sign‑in. Returns the user on success, `null` on failure.
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthServiceException(
          code: 'user-not-found',
          message: 'Account not found. Please register first.',
        );
      }

      await firebaseUser.reload().timeout(const Duration(seconds: 10));
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        throw const AuthServiceException(
          code: 'session-error',
          message: 'Unable to refresh account session. Please try again.',
        );
      }

      // Fetch user profile from Firestore
      UserModel? userProfile = await _firestoreService
          .getUserProfile(refreshedUser.uid)
          .timeout(const Duration(seconds: 15));

      if (userProfile == null) {
        final fallbackName = (refreshedUser.displayName ?? '').trim();
        final fallbackEmail = (refreshedUser.email ?? '').trim();

        await _firestoreService
            .createUserProfile(
              uid: refreshedUser.uid,
              name: fallbackName.isNotEmpty ? fallbackName : 'User',
              email: fallbackEmail.isNotEmpty ? fallbackEmail : email,
            )
            .timeout(const Duration(seconds: 15));

        userProfile = await _firestoreService
            .getUserProfile(refreshedUser.uid)
            .timeout(const Duration(seconds: 15));

        if (userProfile == null) {
          await _auth.signOut();
          throw const AuthServiceException(
            code: 'profile-not-found',
            message: 'User profile not found. Please contact support.',
          );
        }
      }

      // Require verified email for non-admin users only.
      // Admin users can login without email verification.
      if (!refreshedUser.emailVerified && userProfile.role != UserRole.admin) {
        await _auth.signOut();
        throw const AuthServiceException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }

      _currentUser = AuthUser(
        id: userProfile.uid,
        name: userProfile.name,
        email: userProfile.email,
        role: userProfile.role,
      );

      unawaited(_syncNotificationToken(refreshedUser.uid));

      return _currentUser;
    } on TimeoutException {
      throw const AuthServiceException(
        code: 'timeout',
        message: 'Login timed out. Please check your connection and try again.',
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForAuthCode(error.code),
      );
    } on FirebaseException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForDatabaseCode(error.code),
      );
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final normalizedName = name.trim();
      final normalizedEmail = email.trim();

      final credential = await _auth
          .createUserWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      final user = credential.user;
      if (user == null) {
        throw const AuthServiceException(
          code: 'registration-failed',
          message: 'Unable to create your account. Please try again.',
        );
      }

      await user.updateDisplayName(normalizedName);

      // Save user profile to Firestore
      try {
        await _firestoreService
            .createUserProfile(
              uid: user.uid,
              name: normalizedName,
              email: normalizedEmail,
            )
            .timeout(const Duration(seconds: 15));
      } on FirestoreException {
        await _firestoreService
            .createUserProfile(
              uid: user.uid,
              name: normalizedName,
              email: normalizedEmail,
            )
            .timeout(const Duration(seconds: 15));
      }

      final createdProfile = await _firestoreService
          .getUserProfile(user.uid)
          .timeout(const Duration(seconds: 15));

      if (createdProfile == null) {
        throw const AuthServiceException(
          code: 'profile-not-found',
          message:
              'Account created but profile was not saved. Please try again.',
        );
      }

      await user.sendEmailVerification().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AuthServiceException(
        code: 'timeout',
        message:
            'Registration timed out while saving your profile. Please try again.',
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForAuthCode(error.code),
      );
    } on FirestoreException catch (error) {
      throw AuthServiceException(code: error.code, message: error.message);
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Registration failed. Please try again.',
      );
    }
  }

  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthServiceException(
          code: 'user-not-found',
          message: 'Account not found. Please register first.',
        );
      }

      await user.sendEmailVerification();
      await _auth.signOut();
      _currentUser = null;
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForAuthCode(error.code),
      );
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Unable to resend verification email. Please try again.',
      );
    }
  }

  Future<void> sendVerificationForCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthServiceException(
          code: 'session-error',
          message: 'Session expired. Please login again.',
        );
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        code: error.code,
        message: _messageForAuthCode(error.code),
      );
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException(
        code: 'unknown',
        message: 'Unable to send verification email. Please try again.',
      );
    }
  }

  Future<bool> checkCurrentUserEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Clear session and return to unauthenticated state.
  Future<void> signOut() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _currentUser = null;
    await _auth.signOut();
    debugPrint('AuthService: user signed out');
  }

  Future<void> _syncNotificationToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _firestoreService.saveNotificationToken(uid: uid, token: token);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((newToken) {
            _firestoreService
                .saveNotificationToken(uid: uid, token: newToken)
                .catchError((error) {
                  debugPrint('AuthService: token refresh save failed: $error');
                });
          });
    } catch (error) {
      debugPrint('AuthService: notification token sync failed: $error');
    }
  }

  String _messageForAuthCode(String code) {
    switch (code) {
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in Firebase Authentication.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'app-not-authorized':
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'Firebase app configuration is invalid. Please update Firebase setup.';
      case 'network-request-failed':
      case 'network-error':
        return 'Network error. Please check your internet connection.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _messageForDatabaseCode(String code) {
    switch (code) {
      case 'network-error':
      case 'unavailable':
        return 'Network error while saving your profile. Please try again.';
      case 'permission-denied':
        return 'Permission denied while saving user profile.';
      default:
        return 'Unable to save account data. Please try again.';
    }
  }
}

/// Custom exception for authentication operations.
class AuthServiceException implements Exception {
  const AuthServiceException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'AuthServiceException($code): $message';
}
