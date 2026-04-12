import 'dart:async';
import 'package:flutter/material.dart';

import '../services/realtime_river_data_service.dart';
import '../widgets/analytics_chart.dart';

enum AnalyticsRange { today, week, month, year }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _riverService = RealtimeRiverDataService.instance;
  StreamSubscription<SensorReading>? _sub;

  AnalyticsRange _range = AnalyticsRange.today;

  final List<double> _values = <double>[];
  static const int _maxSamples = 240;

  SensorReading? _latest;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _sub = _riverService.readings.listen(
      (r) {
        setState(() {
          _latest = r;
          _hasError = false;
          _values.add(r.distance);

          if (_values.length > _maxSamples) {
            _values.removeAt(0);
          }
        });
      },
      onError: (_) {
        setState(() {
          _hasError = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // --- ACCURATE STATUS LOGIC (Synced with Admin Dashboard) ---
  // Ginamit ang alertLevel mula sa service para sa 100% accuracy

  String _getStatus(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return 'SAFE';
      case SensorAlertLevel.monitor:
        return 'MONITOR';
      case SensorAlertLevel.prepare:
        return 'PREPARE';
      case SensorAlertLevel.evacuate:
        return 'EVACUATE';
    }
  }

  Color _getStatusColor(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return const Color(0xFF2E7D32); // Dark Green mula sa Dashboard
      case SensorAlertLevel.monitor:
        return const Color(0xFFF9A825); // Yellow mula sa Dashboard
      case SensorAlertLevel.prepare:
        return const Color(0xFFEF6C00); // Orange mula sa Dashboard
      case SensorAlertLevel.evacuate:
        return const Color(0xFFC62828); // Dark Red mula sa Dashboard
    }
  }

  // --- ACCURATE TREND DIRECTION (Inverted for Sensor Distance) ---

  String _getTrend(List<double> values) {
    if (values.length < 5) return 'Stable';

    // Kinukuha ang huling 5 readings para mas maging accurate
    final recent = values.sublist(values.length - 5);
    final first = recent.first;
    final last = recent.last;
    final diff = last - first;

    // INVERTED LOGIC: 
    // Kapag ang distance ay LUMILIIT (negative diff), ang tubig ay RISING.
    if (diff < -1.0) return 'Rising'; 

    // Kapag ang distance ay LUMALAKI (positive diff), ang tubig ay FALLING.
    if (diff > 1.0) return 'Falling';

    return 'Stable';
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'Rising':
        return Icons.trending_up_rounded;
      case 'Falling':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'Rising':
        return const Color(0xFFC62828); // Pula (Danger)
      case 'Falling':
        return const Color(0xFF2E7D32); // Berde (Safe)
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_hasError) return _errorState(context);
    if (_latest == null) return _emptyState(context);

    final filtered = _filteredValues();
    final highest = filtered.isEmpty ? 0.0 : filtered.reduce((a, b) => a > b ? a : b);
    final average = filtered.isEmpty ? 0.0 : filtered.reduce((a, b) => a + b) / filtered.length;

    final latestDistance = _latest!.distance;
    final statusText = _getStatus(_latest!.alertLevel);
    final statusColor = _getStatusColor(_latest!.alertLevel);
    
    final trend = _getTrend(filtered);
    final trendIcon = _getTrendIcon(trend);
    final trendColor = _getTrendColor(trend);

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
                  'River Analytics',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Real-time water level insights and trend monitoring.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),

                _buildHeroCard(
                  latestDistance: latestDistance,
                  statusText: statusText,
                  statusColor: statusColor,
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Time Range'),
                const SizedBox(height: 10),
                _rangeSelector(context),
                const SizedBox(height: 20),

                _buildSectionTitle('Trend Overview'),
                const SizedBox(height: 10),
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Water Level Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 280,
                          child: AnalyticsChart(values: filtered, maxY: 100, color: scheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Quick Statistics'),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    final cards = [
                      _statCard(icon: Icons.height_rounded, label: 'Current Height', value: '${latestDistance.toStringAsFixed(2)} cm', subtitle: 'Raw sensor reading'),
                      _statCard(icon: Icons.analytics_outlined, label: 'Average Distance', value: '${average.toStringAsFixed(2)} cm', subtitle: 'Mean for selected range'),
                      _statCard(icon: trendIcon, label: 'Water Trend', value: trend, subtitle: trend == 'Rising' ? 'Water is rising!' : 'Water is stable/receding', accentColor: trendColor),
                    ];

                    return isWide 
                        ? Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList())
                        : Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({required double latestDistance, required String statusText, required Color statusColor}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [statusColor.withOpacity(0.18), statusColor.withOpacity(0.08)]),
        border: Border.all(color: statusColor.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(Icons.water_rounded, color: statusColor, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(statusText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: statusColor)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(999)),
              child: Text('${latestDistance.toStringAsFixed(1)} cm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

  Widget _rangeSelector(BuildContext context) {
    return SegmentedButton<AnalyticsRange>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: AnalyticsRange.today, label: Text('Today')),
        ButtonSegment(value: AnalyticsRange.week, label: Text('Week')),
        ButtonSegment(value: AnalyticsRange.month, label: Text('Month')),
        ButtonSegment(value: AnalyticsRange.year, label: Text('Year')),
      ],
      selected: <AnalyticsRange>{_range},
      onSelectionChanged: (value) => setState(() => _range = value.first),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required String subtitle, Color? accentColor}) {
    final iconColor = accentColor ?? Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.10), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No data yet.')));
  Widget _errorState(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Unable to load analytics.')));

  List<double> _filteredValues() {
    if (_values.isEmpty) return const <double>[];
    switch (_range) {
      case AnalyticsRange.today: return _tail(48);
      case AnalyticsRange.week: return _tail(96);
      case AnalyticsRange.month: return _tail(160);
      case AnalyticsRange.year: return List<double>.from(_values);
    }
  }

  List<double> _tail(int n) => _values.length <= n ? List<double>.from(_values) : _values.sublist(_values.length - n);
}