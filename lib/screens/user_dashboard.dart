import 'dart:async';

import 'package:flutter/material.dart';
import '../services/river_data_service.dart';
import '../widgets/river_status_card.dart';
import '../widgets/alert_level_indicator.dart';

/// User (resident) monitoring dashboard.
/// Displays water level, alert status, flood warning, and last update.
class UserDashboardView extends StatefulWidget {
  const UserDashboardView({super.key});

  @override
  State<UserDashboardView> createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView> {
  final _riverService = RiverDataService.instance;
  StreamSubscription<RiverReading>? _sub;
  RiverReading? _reading;
  bool _hasError = false;

  // Simple history for the mini water‑level graph
  final List<double> _history = [];
  static const int _maxHistory = 20;

  @override
  void initState() {
    super.initState();
    _sub = _riverService.readings.listen(
      (r) => setState(() {
        _reading = r;
        _hasError = false;
        _history.add(r.waterLevelMeters);
        if (_history.length > _maxHistory) _history.removeAt(0);
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
                  'River Status',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Live water level monitoring for your area',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                RiverStatusCard(reading: _reading!),
                const SizedBox(height: 16),
                _buildFloodWarning(),
                const SizedBox(height: 16),

                if (_history.length >= 2) ...[
                  const Text(
                    'Water Level Trend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _buildMiniGraph(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Colored banner that adapts its message and color to the alert level.
  Widget _buildFloodWarning() {
    final alert = _reading!.alertLevel;
    final color = _alertColor(alert);
    final message = _alertMessage(alert);

    return Card(
      color: color.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              alert == AlertLevel.safe
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlertLevelIndicator(alertLevel: alert),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple sparkline‑style graph drawn with a CustomPainter.
  Widget _buildMiniGraph() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 120,
          child: CustomPaint(
            size: Size.infinite,
            painter: _SparklinePainter(
              values: _history,
              maxValue: _reading!.maxLevelMeters,
              color: _alertColor(_reading!.alertLevel),
            ),
          ),
        ),
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

  Color _alertColor(AlertLevel level) {
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

  String _alertMessage(AlertLevel level) {
    switch (level) {
      case AlertLevel.safe:
        return 'River levels are normal. No action needed.';
      case AlertLevel.monitor:
        return 'River levels are rising. Stay alert and monitor updates.';
      case AlertLevel.prepare:
        return 'Prepare to evacuate. Gather emergency supplies.';
      case AlertLevel.evacuate:
        return 'Evacuate immediately! Move to higher ground now.';
    }
  }
}

// ── Simple sparkline painter ────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.maxValue,
    required this.color,
  });

  final List<double> values;
  final double maxValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withAlpha(80), color.withAlpha(10)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxValue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values.length != values.length ||
      (values.isNotEmpty && old.values.last != values.last);
}
