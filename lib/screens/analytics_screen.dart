import 'dart:async';

import 'package:flutter/material.dart';

import '../services/river_data_service.dart';
import '../widgets/analytics_chart.dart';

enum AnalyticsRange { today, week, month, year }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _riverService = RiverDataService.instance;
  StreamSubscription<RiverReading>? _sub;

  AnalyticsRange _range = AnalyticsRange.today;

  final List<double> _values = <double>[];
  static const int _maxSamples = 240;

  RiverReading? _latest;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _sub = _riverService.readings.listen((r) {
      setState(() {
        _latest = r;
        _hasError = false;
        _values.add(r.waterLevelMeters);
        if (_values.length > _maxSamples) _values.removeAt(0);
      });
    }, onError: (_) => setState(() => _hasError = true));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _errorState(context);
    }

    if (_latest == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredValues();
    final highest = filtered.isEmpty
        ? 0.0
        : filtered.reduce((a, b) => a > b ? a : b);
    final average = filtered.isEmpty
        ? 0.0
        : filtered.reduce((a, b) => a + b) / filtered.length;

    final scheme = Theme.of(context).colorScheme;

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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Water level trends for the monitored river',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                _rangeSelector(context),
                const SizedBox(height: 16),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 280,
                      child: AnalyticsChart(
                        values: filtered,
                        maxY: _latest!.maxLevelMeters,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    final children = <Widget>[
                      _statCard(
                        'Highest Level',
                        '${highest.toStringAsFixed(2)} m',
                      ),
                      _statCard(
                        'Average Level',
                        '${average.toStringAsFixed(2)} m',
                      ),
                      _statCard(
                        'Latest Reading',
                        '${_latest!.waterLevelMeters.toStringAsFixed(2)} m',
                      ),
                    ];

                    if (isWide) {
                      return Row(
                        children: [
                          for (final c in children) ...[
                            Expanded(child: c),
                            const SizedBox(width: 12),
                          ],
                        ]..removeLast(),
                      );
                    }

                    return Column(
                      children: [
                        for (final c in children) ...[
                          c,
                          const SizedBox(height: 12),
                        ],
                      ]..removeLast(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rangeSelector(BuildContext context) {
    return SegmentedButton<AnalyticsRange>(
      segments: const [
        ButtonSegment(value: AnalyticsRange.today, label: Text('Today')),
        ButtonSegment(value: AnalyticsRange.week, label: Text('Week')),
        ButtonSegment(value: AnalyticsRange.month, label: Text('Month')),
        ButtonSegment(value: AnalyticsRange.year, label: Text('Year')),
      ],
      selected: <AnalyticsRange>{_range},
      onSelectionChanged: (value) {
        setState(() => _range = value.first);
      },
    );
  }

  Widget _statCard(String label, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Unable to load analytics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  List<double> _filteredValues() {
    if (_values.isEmpty) return const <double>[];

    // Since real timestamps aren't persisted yet, filters are simulated by
    // taking the most recent N samples.
    switch (_range) {
      case AnalyticsRange.today:
        return _tail(48);
      case AnalyticsRange.week:
        return _tail(96);
      case AnalyticsRange.month:
        return _tail(160);
      case AnalyticsRange.year:
        return List<double>.from(_values);
    }
  }

  List<double> _tail(int n) {
    if (_values.length <= n) return List<double>.from(_values);
    return _values.sublist(_values.length - n);
  }
}
