import 'package:flutter/material.dart';
import '../services/river_data_service.dart';

/// Color‑coded indicator chip that shows the current alert level.
class AlertLevelIndicator extends StatelessWidget {
  const AlertLevelIndicator({super.key, required this.alertLevel});

  final AlertLevel alertLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: _color),
          const SizedBox(width: 8),
          Text(
            _label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (alertLevel) {
      case AlertLevel.safe:
        return const Color(0xFF10B981);
      case AlertLevel.monitor:
        return const Color(0xFFF59E0B);
      case AlertLevel.prepare:
        return const Color(0xFFF97316);
      case AlertLevel.evacuate:
        return const Color(0xFFEF4444);
    }
  }

  String get _label {
    switch (alertLevel) {
      case AlertLevel.safe:
        return 'SAFE';
      case AlertLevel.monitor:
        return 'MONITOR';
      case AlertLevel.prepare:
        return 'PREPARE TO EVACUATE';
      case AlertLevel.evacuate:
        return 'EVACUATE NOW';
    }
  }
}
