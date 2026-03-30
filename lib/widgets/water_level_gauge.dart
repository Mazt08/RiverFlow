import 'package:flutter/material.dart';
import '../services/realtime_river_data_service.dart';

class WaterLevelGauge extends StatelessWidget {
  const WaterLevelGauge({super.key, required this.reading});

  final SensorReading reading;

  @override
  Widget build(BuildContext context) {
    final pct = (reading.percentage / 100).clamp(0.0, 1.0);
    final color = _colorFor(reading.alertLevel);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaugeHeight = (constraints.maxWidth * 0.65).clamp(180.0, 260.0);
        final gaugeWidth = (constraints.maxWidth * 0.45).clamp(120.0, 180.0);

        double badgeBottom = gaugeHeight * pct - 20;
        if (badgeBottom < 8) badgeBottom = 8;
        if (badgeBottom > gaugeHeight - 40) badgeBottom = gaugeHeight - 40;

        return Center(
          child: SizedBox(
            width: gaugeWidth,
            height: gaugeHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 2),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: pct,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withAlpha(70),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${reading.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                Positioned(
                  bottom: badgeBottom,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${reading.distance.toStringAsFixed(2)} cm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _colorFor(SensorAlertLevel level) {
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