import 'package:flutter/material.dart';
import '../services/river_data_service.dart';
import 'alert_level_indicator.dart';
import 'water_level_gauge.dart';

/// Card that shows a complete river status overview:
/// water level gauge, alert indicator, height, rise rate, and last update.
class RiverStatusCard extends StatelessWidget {
  const RiverStatusCard({super.key, required this.reading});

  final RiverReading reading;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(reading.timestamp);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.water, color: Color(0xFF2196F3), size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'River Water Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                // Sensor status dot
                Icon(
                  Icons.circle,
                  size: 10,
                  color: reading.sensorOnline
                      ? const Color(0xFF10B981)
                      : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  reading.sensorOnline ? 'Sensor Online' : 'Sensor Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: reading.sensorOnline ? Colors.grey : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Alert badge
            AlertLevelIndicator(alertLevel: reading.alertLevel),
            const SizedBox(height: 20),
            // Water gauge
            WaterLevelGauge(reading: reading),
            const SizedBox(height: 20),
            // Details row
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _detail(
                  'Height',
                  '${reading.waterLevelMeters} / ${reading.maxLevelMeters} m',
                ),
                _detail(
                  'Rise Rate',
                  '${reading.riseRatePerHour >= 0 ? "▲" : "▼"} '
                      '${reading.riseRatePerHour.abs()} m/hr',
                ),
                _detail('Last Updated', timeAgo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} hr ago';
  }
}
