import 'package:flutter/material.dart';
import '../services/message_service.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message});

  final BroadcastMessage message;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(message.severity);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_severityIcon(message.severity), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.body,
                    style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime ts) {
    final m = ts.month.toString().padLeft(2, '0');
    final d = ts.day.toString().padLeft(2, '0');
    final hour = (ts.hour % 12 == 0 ? 12 : ts.hour % 12).toString().padLeft(
      2,
      '0',
    );
    final min = ts.minute.toString().padLeft(2, '0');
    final ampm = ts.hour >= 12 ? 'PM' : 'AM';
    return '$m/$d $hour:$min $ampm';
  }

  IconData _severityIcon(MessageSeverity severity) {
    switch (severity) {
      case MessageSeverity.info:
        return Icons.info_outline_rounded;
      case MessageSeverity.advisory:
        return Icons.notifications_active_outlined;
      case MessageSeverity.warning:
        return Icons.warning_amber_rounded;
      case MessageSeverity.emergency:
        return Icons.report_rounded;
    }
  }

  Color _severityColor(MessageSeverity severity) {
    switch (severity) {
      case MessageSeverity.info:
        return const Color(0xFF2196F3);
      case MessageSeverity.advisory:
        return const Color(0xFFF59E0B);
      case MessageSeverity.warning:
        return const Color(0xFFF97316);
      case MessageSeverity.emergency:
        return const Color(0xFFEF4444);
    }
  }
}
