import 'package:flutter/material.dart';

import '../services/message_service.dart';
import '../widgets/message_card.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BroadcastMessage>>(
      stream: MessageService.instance.messageStream,
      builder: (context, snapshot) {
        final messages =
            snapshot.data ?? MessageService.instance.currentMessages;

        if (snapshot.connectionState == ConnectionState.waiting &&
            messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (messages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_chat_unread_outlined,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Broadcast updates from admins will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) =>
              MessageCard(message: messages[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemCount: messages.length,
        );
      },
    );
  }
}
