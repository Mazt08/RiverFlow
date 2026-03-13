import 'package:flutter/foundation.dart';

enum UserRole { admin, user }

/// Authenticated user model.
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
}

/// Handles authentication state and credentials.
/// Replace the demo database with a real backend when ready.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Demo user store (swap for Firebase / REST later) ──────────────
  static final List<_DemoRecord> _demoUsers = [
    _DemoRecord(
      user: const AuthUser(
        id: '10001',
        name: 'RiverFlow Admin',
        email: 'admin@riverflow.app',
        role: UserRole.admin,
      ),
      password: 'riverflow123',
    ),
    _DemoRecord(
      user: const AuthUser(
        id: '10002',
        name: 'Resident Monitor',
        email: 'user@riverflow.app',
        role: UserRole.user,
      ),
      password: 'riverflow123',
    ),
  ];

  /// Attempt sign‑in. Returns the user on success, `null` on failure.
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 650));

    try {
      final record = _demoUsers.firstWhere(
        (r) =>
            r.user.email.toLowerCase() == email.toLowerCase() &&
            r.password == password,
      );
      _currentUser = record.user;
      return _currentUser;
    } on StateError {
      return null;
    }
  }

  /// Clear session and return to unauthenticated state.
  void signOut() {
    _currentUser = null;
    debugPrint('AuthService: user signed out');
  }
}

class _DemoRecord {
  const _DemoRecord({required this.user, required this.password});
  final AuthUser user;
  final String password;
}
