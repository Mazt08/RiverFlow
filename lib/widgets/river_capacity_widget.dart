import 'package:flutter/material.dart';
import '../services/realtime_river_data_service.dart';

class RiverCapacityWidget extends StatelessWidget {
  final SensorReading reading;
  final DateTime? lastUpdate;

  const RiverCapacityWidget({
    super.key,
    required this.reading,
    this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _alertColor(reading.alertLevel);
    final fillPercent = (reading.percentage / 100).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                reading.status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: 150,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.8),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  height: 280 * fillPercent,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.35),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${reading.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'River Capacity',
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 10,
          children: [
            _infoItem('Height', '${reading.distance.toStringAsFixed(2)} cm'),
            _infoItem('Status', reading.status),
            _infoItem(
              'Last Updated',
              lastUpdate == null ? 'Just now' : _formatTime(lastUpdate!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Color _alertColor(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return const Color(0xFF10B981);
      case SensorAlertLevel.monitor:
        return const Color(0xFFF59E0B);
      case SensorAlertLevel.prepare:
        return const Color(0xFFF97316);
      case SensorAlertLevel.evacuate:
        return const Color(0xFFEF4444);
    }
  }
}