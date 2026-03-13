import 'dart:async';

import 'package:flutter/foundation.dart';

/// Severity for broadcast messages.
enum MessageSeverity { info, advisory, warning, emergency }

class BroadcastMessage {
  const BroadcastMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.timestamp,
  });

  final String id;
  final String title;
  final String body;
  final MessageSeverity severity;
  final DateTime timestamp;
}

/// In-memory message store.
///
/// This is intentionally implemented behind a small API so it can be swapped
/// for Firebase (Firestore + FCM) without rewriting UI.
class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  final List<BroadcastMessage> _messages = <BroadcastMessage>[];
  final _controller = StreamController<List<BroadcastMessage>>.broadcast();

  Stream<List<BroadcastMessage>> get messageStream {
    // Emit a snapshot on first listen.
    scheduleMicrotask(() {
      if (!_controller.isClosed) _controller.add(List.unmodifiable(_messages));
    });
    return _controller.stream;
  }

  List<BroadcastMessage> get currentMessages => List.unmodifiable(_messages);

  Future<void> sendBroadcast({
    required String body,
    MessageSeverity severity = MessageSeverity.warning,
  }) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message body cannot be empty');
    }

    final message = BroadcastMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleFor(severity),
      body: trimmed,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _messages.insert(0, message);
    _controller.add(List.unmodifiable(_messages));
    debugPrint('MessageService: broadcast message sent');

    // Firebase TODO:
    // - Save message to Firestore
    // - Trigger push notification (FCM)
  }

  String _titleFor(MessageSeverity severity) {
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

  void dispose() {
    _controller.close();
  }
}
