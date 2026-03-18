import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSeverity { info, advisory, warning, emergency }

/// Represents a broadcast message sent by admins.
class MessageModel {
  const MessageModel({
    required this.messageId,
    required this.message,
    required this.sender,
    required this.severity,
    required this.timestamp,
  });

  final String messageId;
  final String message;
  final String sender; // typically 'admin'
  final MessageSeverity severity;
  final DateTime timestamp;

  /// Title based on severity level.
  String get title {
    switch (severity) {
      case MessageSeverity.info:
        return 'Update';
      case MessageSeverity.advisory:
        return 'Advisory';
      case MessageSeverity.warning:
        return 'Warning';
      case MessageSeverity.emergency:
        return 'Emergency';
    }
  }

  /// Convert MessageModel to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'sender': sender,
      'severity': severity.name, // 'info', 'advisory', 'warning', 'emergency'
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create MessageModel from Firestore document.
  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    String parseSeverity(dynamic value) {
      if (value is String) {
        return value;
      }
      return 'warning';
    }

    final severityStr = parseSeverity(data['severity']);
    final severity = MessageSeverity.values.firstWhere(
      (e) => e.name == severityStr,
      orElse: () => MessageSeverity.warning,
    );

    return MessageModel(
      messageId: doc.id,
      message: data['message'] ?? '',
      sender: data['sender'] ?? 'admin',
      severity: severity,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Copy with method for immutability.
  MessageModel copyWith({
    String? messageId,
    String? message,
    String? sender,
    MessageSeverity? severity,
    DateTime? timestamp,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, message: $message, sender: $sender, severity: $severity, timestamp: $timestamp)';
  }
}
