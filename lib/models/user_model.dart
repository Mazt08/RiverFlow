import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, user }

/// Represents a user profile in Firestore.
class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  /// Convert UserModel to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.name, // 'admin' or 'user'
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create UserModel from Firestore document.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Copy with method for immutability.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role, createdAt: $createdAt)';
  }
}
