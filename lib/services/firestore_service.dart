import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:river_flow/models/user_model.dart';
import 'package:river_flow/models/river_data_model.dart';
import 'package:river_flow/models/message_model.dart';

/// Main Firestore service for all database operations.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _riverDataCollection = 'river_data';
  static const String _messagesCollection = 'messages';
  static const String _notificationTokensCollection = 'notification_tokens';

  // ==================== User Operations ====================

  /// Create or update a user profile in Firestore.
  /// Called during user registration.
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(userModel.toFirestore());
    } catch (e) {
      throw FirestoreException(
        code: 'user-creation-failed',
        message: 'Failed to create user profile: $e',
      );
    }
  }

  /// Fetch a user's profile and role from Firestore.
  /// Returns null if user profile doesn't exist.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreException(
        code: 'fetch-user-failed',
        message: 'Failed to fetch user profile: $e',
      );
    }
  }

  /// Update user profile information.
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;

      await _firestore.collection(_usersCollection).doc(uid).update(updates);
    } catch (e) {
      throw FirestoreException(
        code: 'update-user-failed',
        message: 'Failed to update user profile: $e',
      );
    }
  }

  /// Watch user profile changes in real-time.
  /// Useful for listening to role changes or profile updates.
  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    });
  }

  // ==================== River Data Operations ====================

  /// Add new river sensor reading to Firestore.
  /// Called by sensors or admin to log new readings.
  Future<String> addRiverReading(RiverDataModel reading) async {
    try {
      final docRef = await _firestore
          .collection(_riverDataCollection)
          .add(reading.toFirestore());
      return docRef.id;
    } catch (e) {
      throw FirestoreException(
        code: 'add-river-data-failed',
        message: 'Failed to add river reading: $e',
      );
    }
  }

  /// Fetch the latest river reading.
  /// Useful for displaying current water level.
  Future<RiverDataModel?> getLatestRiverReading() async {
    try {
      final query = await _firestore
          .collection(_riverDataCollection)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return RiverDataModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw FirestoreException(
        code: 'fetch-river-data-failed',
        message: 'Failed to fetch latest river reading: $e',
      );
    }
  }

  /// Get historical river readings with pagination.
  /// Limit defaults to 100 records per page.
  Future<List<RiverDataModel>> getRiverReadingsHistory({
    int limit = 100,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_riverDataCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RiverDataModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException(
        code: 'fetch-river-history-failed',
        message: 'Failed to fetch river readings history: $e',
      );
    }
  }

  /// Listen to real-time updates of river readings.
  /// Useful for live dashboard displaying latest sensor data.
  /// Returns a stream of the latest reading every time it updates.
  Stream<RiverDataModel?> watchLatestRiverReading() {
    return _firestore
        .collection(_riverDataCollection)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((query) {
          if (query.docs.isEmpty) {
            return null;
          }
          return RiverDataModel.fromFirestore(query.docs.first);
        });
  }

  /// Listen to all river readings as they arrive (real-time stream).
  /// Useful for live monitoring of all sensor updates.
  Stream<List<RiverDataModel>> watchAllRiverReadings() {
    return _firestore
        .collection(_riverDataCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) {
          return query.docs
              .map((doc) => RiverDataModel.fromFirestore(doc))
              .toList();
        });
  }

  // ==================== Message Operations ====================

  /// Send a broadcast message from admin to all users.
  /// Only admins should have write access to this collection.
  Future<String> sendBroadcastMessage({
    required String message,
    required MessageSeverity severity,
    String sender = 'admin',
  }) async {
    try {
      final messageModel = MessageModel(
        messageId: '', // Firestore will generate this
        message: message,
        sender: sender,
        severity: severity,
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_messagesCollection)
          .add(messageModel.toFirestore());

      return docRef.id;
    } catch (e) {
      throw FirestoreException(
        code: 'send-message-failed',
        message: 'Failed to send broadcast message: $e',
      );
    }
  }

  /// Fetch all broadcast messages with optional pagination.
  /// Limit defaults to 50 messages per fetch.
  Future<List<MessageModel>> getAllMessages({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_messagesCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException(
        code: 'fetch-messages-failed',
        message: 'Failed to fetch messages: $e',
      );
    }
  }

  /// Listen to real-time updates of broadcast messages.
  /// Useful for displaying messages as they arrive in the app.
  Stream<List<MessageModel>> watchAllMessages() {
    return _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) {
          return query.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Listen to new messages only (recent ones).
  /// Returns a stream that emits whenever a new message arrives.
  Stream<MessageModel> watchNewMessages() {
    return _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .where((query) => query.docs.isNotEmpty)
        .map((query) => MessageModel.fromFirestore(query.docs.first));
  }

  /// Delete a message (only for admin cleanup).
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_messagesCollection).doc(messageId).delete();
    } catch (e) {
      throw FirestoreException(
        code: 'delete-message-failed',
        message: 'Failed to delete message: $e',
      );
    }
  }

  // ==================== Notification Token Operations ====================

  /// Save a device FCM token for a specific user.
  Future<void> saveNotificationToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _firestore.collection(_notificationTokensCollection).doc(uid).set({
        'tokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException(
        code: 'save-notification-token-failed',
        message: 'Failed to save notification token: $e',
      );
    }
  }

  /// Remove a device FCM token for a specific user.
  Future<void> removeNotificationToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _firestore.collection(_notificationTokensCollection).doc(uid).set({
        'tokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException(
        code: 'remove-notification-token-failed',
        message: 'Failed to remove notification token: $e',
      );
    }
  }

  /// Watch notification tokens for a specific user.
  Stream<List<String>> watchNotificationTokens(String uid) {
    return _firestore
        .collection(_notificationTokensCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return <String>[];
          final tokens = data['tokens'];
          if (tokens is List) {
            return tokens.map((e) => e.toString()).toList();
          }
          return <String>[];
        });
  }
}

/// Custom exception for Firestore operations.
class FirestoreException implements Exception {
  FirestoreException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'FirestoreException($code): $message';
}
