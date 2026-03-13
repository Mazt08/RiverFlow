import 'package:flutter/material.dart';

import '../services/message_service.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _messageCtrl = TextEditingController();
  MessageSeverity _severity = MessageSeverity.warning;
  bool _isSending = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a message first.')));
      return;
    }

    setState(() => _isSending = true);

    try {
      await MessageService.instance.sendBroadcast(
        body: text,
        severity: _severity,
      );

      if (!mounted) return;
      setState(() {
        _isSending = false;
        _messageCtrl.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Broadcast message sent.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Broadcast Message',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Send a message to all monitoring users.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<MessageSeverity>(
                        initialValue: _severity,
                        decoration: const InputDecoration(
                          labelText: 'Severity',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: MessageSeverity.info,
                            child: Text('Info'),
                          ),
                          DropdownMenuItem(
                            value: MessageSeverity.advisory,
                            child: Text('Advisory'),
                          ),
                          DropdownMenuItem(
                            value: MessageSeverity.warning,
                            child: Text('Warning'),
                          ),
                          DropdownMenuItem(
                            value: MessageSeverity.emergency,
                            child: Text('Emergency'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _severity = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _messageCtrl,
                        minLines: 4,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          hintText: 'Type your broadcast message here…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSending ? null : _send,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(_isSending ? 'Sending…' : 'Send Message'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Firebase + Push notifications are stubbed in the current demo service.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
