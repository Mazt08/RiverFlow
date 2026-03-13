import 'package:flutter/material.dart';
import '../services/river_data_service.dart';

/// Visual gauge that displays the current water level as a filled bar with
/// percentage and height labels. Adapts to the available width.
class WaterLevelGauge extends StatelessWidget {
  const WaterLevelGauge({super.key, required this.reading});

  final RiverReading reading;

  @override
  Widget build(BuildContext context) {
    final pct = reading.percentage;
    final color = _colorFor(reading.alertLevel);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a max height proportional to available width, capped at 260
        final gaugeHeight = (constraints.maxWidth * 0.65).clamp(180.0, 260.0);
        final gaugeWidth = (constraints.maxWidth * 0.45).clamp(120.0, 180.0);

        return Center(
          child: SizedBox(
            width: gaugeWidth,
            height: gaugeHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 2),
                  ),
                ),
                // Filled portion
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
                // Percentage label
                Center(
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                // Height badge
                Positioned(
                  bottom: gaugeHeight * pct - 20,
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
                      '${reading.waterLevelMeters} m',
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

  Color _colorFor(AlertLevel level) {
    switch (level) {
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
}
