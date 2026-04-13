import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:river_flow/services/firestore_service.dart';
import 'package:river_flow/models/message_model.dart';

export 'package:river_flow/models/message_model.dart' show MessageSeverity;

/// Legacy compatibility wrapper for BroadcastMessage.
/// Use MessageModel instead for new code.
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

  /// Convert to MessageModel for Firestore operations.
  MessageModel toMessageModel() {
    return MessageModel(
      messageId: id,
      message: body,
      sender: 'admin',
      severity: severity,
      timestamp: timestamp,
    );
  }

  /// Create from MessageModel.
  factory BroadcastMessage.fromMessageModel(MessageModel model) {
    return BroadcastMessage(
      id: model.messageId,
      title: model.title,
      body: model.message,
      severity: model.severity,
      timestamp: model.timestamp,
    );
  }
}

/// Manages broadcast messages from Firestore.
/// Messages are sent by admins and received by all authenticated users.
class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  final FirestoreService _firestoreService = FirestoreService.instance;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  final _controller = StreamController<List<BroadcastMessage>>.broadcast();
  List<BroadcastMessage> _latestMessages = const [];

  Stream<List<BroadcastMessage>> get messageStream {
    _ensureListening();
    return Stream<List<BroadcastMessage>>.multi((emitter) {
      // Replay latest cached value for each new subscriber (e.g., after logout/login).
      emitter.add(_latestMessages);

      final sub = _controller.stream.listen(
        emitter.add,
        onError: emitter.addError,
        onDone: emitter.close,
      );

      emitter.onCancel = sub.cancel;
    });
  }

  List<BroadcastMessage> get currentMessages {
    return _latestMessages;
  }

  /// Ensure we're listening to Firestore messages.
  void _ensureListening() {
    if (_messagesSubscription != null) return;

    _messagesSubscription = _firestoreService.watchAllMessages().listen(
      (messageModels) {
        final messages = messageModels
            .map((m) => BroadcastMessage.fromMessageModel(m))
            .toList();
        _latestMessages = messages;
        if (!_controller.isClosed) {
          _controller.add(messages);
        }
      },
      onError: (error) {
        debugPrint('MessageService: stream error: $error');
        _messagesSubscription?.cancel();
        _messagesSubscription = null;
        _latestMessages = const [];
        if (!_controller.isClosed) {
          _controller.add(_latestMessages);
        }
      },
    );

    if (!_controller.isClosed) {
      _controller.add(_latestMessages);
    }
  }

  Future<void> sendBroadcast({
    required String body,
    MessageSeverity severity = MessageSeverity.warning,
  }) async {
    // Trim and validate message.
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message body cannot be empty');
    }

    // Send to Firestore.
    try {
      await _firestoreService.sendBroadcastMessage(
        message: trimmed,
        severity: severity,
      );
      debugPrint('MessageService: broadcast message sent to Firestore');
    } catch (e) {
      throw Exception('Failed to send broadcast message: $e');
    }
  }

  /// Clean up resources when the service is no longer needed.
  void dispose() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _controller.close();
  }
}
