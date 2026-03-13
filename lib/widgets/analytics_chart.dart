import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Reusable line chart widget for water level analytics.
class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({
    super.key,
    required this.values,
    required this.maxY,
    required this.color,
  });

  final List<double> values;
  final double maxY;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return const Center(child: Text('Not enough data yet.'));
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outlineVariant,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: color.withAlpha(30)),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}
