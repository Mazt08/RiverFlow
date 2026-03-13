import 'package:flutter/material.dart';

/// Reusable logout button. Place in AppBar actions or wherever needed.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      icon: const Icon(Icons.logout_rounded),
      onPressed: () {
        showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ).then((confirmed) {
          if (confirmed == true) onPressed();
        });
      },
    );
  }
}
