import 'package:flutter/material.dart';
import '../services/river_data_service.dart';
import 'alert_level_indicator.dart';

/// Compatibility wrapper matching the name in the UI spec.
/// Prefer using [AlertLevelIndicator] directly for new code.
class AlertIndicator extends StatelessWidget {
  const AlertIndicator({super.key, required this.level});

  final AlertLevel level;

  @override
  Widget build(BuildContext context) {
    return AlertLevelIndicator(alertLevel: level);
  }
}
