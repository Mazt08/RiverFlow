import 'dart:async';

import 'package:flutter/material.dart';
import '../services/river_data_service.dart';
import '../widgets/river_status_card.dart';

/// Admin dashboard — shows river status, sensor info, and system stats.
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final _riverService = RiverDataService.instance;
  StreamSubscription<RiverReading>? _sub;
  RiverReading? _reading;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _sub = _riverService.readings.listen(
      (r) => setState(() {
        _reading = r;
        _hasError = false;
      }),
      onError: (_) => setState(() => _hasError = true),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasError
        ? _buildError()
        : _reading == null
        ? const Center(child: CircularProgressIndicator())
        : _buildContent();
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () => _riverService.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Single‑river monitoring status and sensor health',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                RiverStatusCard(reading: _reading!),
                const SizedBox(height: 16),

                _buildSectionTitle('System Statistics'),
                const SizedBox(height: 10),
                _buildStatsGrid(),
                const SizedBox(height: 16),

                _buildSectionTitle('Sensor Information'),
                const SizedBox(height: 10),
                _buildSensorCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: const [
            _StatTile(
              label: 'System Accuracy',
              value: '98.2%',
              color: Color(0xFF10B981),
            ),
            _StatTile(
              label: 'False Alert Rate',
              value: '1.3%',
              color: Color(0xFFF59E0B),
            ),
            _StatTile(
              label: 'Avg Warning Time',
              value: '4.2 hrs',
              color: Color(0xFF2196F3),
            ),
            _StatTile(
              label: 'Sensor Uptime',
              value: '99.7%',
              color: Color(0xFF10B981),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSensorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Arduino ESP32 Sensor',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Icon(
                  Icons.circle,
                  size: 10,
                  color: (_reading?.sensorOnline ?? false)
                      ? const Color(0xFF10B981)
                      : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  (_reading?.sensorOnline ?? false) ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (_reading?.sensorOnline ?? false)
                        ? const Color(0xFF10B981)
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _infoChip('ID', 'ARD-ESP32-001'),
                _infoChip('Firmware', 'v2.4.1'),
                _infoChip('Data Rate', '10 sec'),
                _infoChip('Battery', '85%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Unable to load sensor data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your network connection or sensor status.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small stat tile widget ──────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
