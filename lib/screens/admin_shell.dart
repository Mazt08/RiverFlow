import 'package:flutter/material.dart';

import '../app_config.dart';
import '../services/auth_service.dart';
import 'admin_dashboard.dart';
import 'analytics_screen.dart';
import 'broadcast_screen.dart';
import 'messages_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _index = 0;

  static const _destinations = <NavigationDestinationData>[
    NavigationDestinationData('Dashboard', Icons.dashboard_rounded),
    NavigationDestinationData('Analytics', Icons.show_chart_rounded),
    NavigationDestinationData('Broadcast', Icons.campaign_rounded),
    NavigationDestinationData('Messages', Icons.message_rounded),
    NavigationDestinationData('Logout', Icons.logout_rounded),
  ];

  void _onDestinationSelected(int newIndex) {
    if (newIndex == 4) {
      _confirmLogout();
      return;
    }
    setState(() => _index = newIndex);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
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
    );

    if (confirmed == true && mounted) {
      AuthService.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;

    final pages = <Widget>[
      const AdminDashboardView(),
      const AnalyticsScreen(),
      const BroadcastScreen(),
      const MessagesScreen(),
      const SizedBox.shrink(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;

        if (useRail) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text(AppConfig.riverName),
                        centerTitle: false,
                      ),
                      body: SafeArea(
                        top: false,
                        child: IndexedStack(index: _index, children: pages),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(AppConfig.riverName)),
          body: SafeArea(
            top: false,
            child: IndexedStack(index: _index, children: pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              for (final d in destinations)
                NavigationDestination(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}

class NavigationDestinationData {
  const NavigationDestinationData(this.label, this.icon);
  final String label;
  final IconData icon;
}
