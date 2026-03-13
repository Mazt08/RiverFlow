import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Alert levels for the monitored river.
enum AlertLevel { safe, monitor, prepare, evacuate }

/// Snapshot of the river sensor reading.
class RiverReading {
  const RiverReading({
    required this.waterLevelMeters,
    required this.maxLevelMeters,
    required this.alertLevel,
    required this.timestamp,
    required this.riseRatePerHour,
    required this.sensorOnline,
  });

  final double waterLevelMeters;
  final double maxLevelMeters;
  final AlertLevel alertLevel;
  final DateTime timestamp;
  final double riseRatePerHour;
  final bool sensorOnline;

  /// Water level as 0.0 – 1.0 fraction.
  double get percentage => (waterLevelMeters / maxLevelMeters).clamp(0.0, 1.0);

  /// Human‑readable label for the current alert.
  String get alertLabel {
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

/// Provides a stream of simulated river sensor data.
/// Replace with real MQTT / HTTP polling when the Arduino backend is ready.
class RiverDataService {
  RiverDataService._();
  static final RiverDataService instance = RiverDataService._();

  static const double _maxLevel = 5.0; // metres

  final _random = Random();
  Timer? _timer;
  final _controller = StreamController<RiverReading>.broadcast();

  /// Emits a new reading every [interval].
  Stream<RiverReading> get readings {
    _ensurePolling();
    return _controller.stream;
  }

  /// Most recent reading (useful for one‑shot display).
  RiverReading? _lastReading;
  RiverReading? get lastReading => _lastReading;

  /// Manually request a new reading (useful for pull‑to‑refresh).
  Future<void> refresh() async {
    _ensurePolling();
    // Simulate a short request.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _emit();
  }

  void _ensurePolling() {
    if (_timer != null) return;
    // Emit an initial reading immediately
    _emit();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _emit());
  }

  void _emit() {
    final level = 1.5 + _random.nextDouble() * 3.2; // 1.5 – 4.7 m
    final rate = (_random.nextDouble() * 0.5) - 0.1; // -0.1 – 0.4 m/hr
    final alert = _alertFor(level);

    final reading = RiverReading(
      waterLevelMeters: double.parse(level.toStringAsFixed(2)),
      maxLevelMeters: _maxLevel,
      alertLevel: alert,
      timestamp: DateTime.now(),
      riseRatePerHour: double.parse(rate.toStringAsFixed(2)),
      sensorOnline: _random.nextDouble() > 0.05, // 95 % uptime
    );

    _lastReading = reading;
    _controller.add(reading);
  }

  AlertLevel _alertFor(double level) {
    final pct = level / _maxLevel;
    if (pct >= 0.85) return AlertLevel.evacuate;
    if (pct >= 0.65) return AlertLevel.prepare;
    if (pct >= 0.45) return AlertLevel.monitor;
    return AlertLevel.safe;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller.close();
    debugPrint('RiverDataService: disposed');
  }
}
