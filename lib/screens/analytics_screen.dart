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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_hasError) {
      return _errorState(context);
    }

    if (_latest == null) {
      return _emptyState(context);
    }

    final filtered = _filteredValues();
    final highest = filtered.isEmpty
        ? 0.0
        : filtered.reduce((a, b) => a > b ? a : b);

    final average = filtered.isEmpty
        ? 0.0
        : filtered.reduce((a, b) => a + b) / filtered.length;

    final latestDistance = _latest!.distance;
    final statusText = _getStatus(latestDistance);
    final statusColor = _getStatusColor(latestDistance);
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Real-time water level insights and trend monitoring.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Level Trend',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitoring recent river distance readings.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 280,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnalyticsChart(
                              values: filtered,
                              maxY: 100,
                              color: scheme.primary,
                            ),
                          ),
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
                      _statCard(
                        icon: Icons.arrow_upward_rounded,
                        label: 'Highest Distance',
                        value: '${highest.toStringAsFixed(2)} cm',
                        subtitle: 'Peak recorded in current range',
                      ),
                      _statCard(
                        icon: Icons.analytics_outlined,
                        label: 'Average Distance',
                        value: '${average.toStringAsFixed(2)} cm',
                        subtitle: 'Mean reading for selected range',
                      ),
                      _statCard(
                        icon: trendIcon,
                        label: 'Trend Direction',
                        value: trend,
                        subtitle: 'Based on recent readings',
                        accentColor: trendColor,
                      ),
                    ];

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[1]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[2]),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                        const SizedBox(height: 12),
                        cards[2],
                      ],
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

  Widget _buildHeroCard({
    required double latestDistance,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.18),
            statusColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: statusColor.withOpacity(0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTight = constraints.maxWidth < 500;

            final left = Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_rounded,
                    color: statusColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current River Reading',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${latestDistance.toStringAsFixed(2)} cm',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final badge = Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            );

            if (isTight) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  left,
                  const SizedBox(height: 16),
                  badge,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: left),
                const SizedBox(width: 16),
                badge,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _rangeSelector(BuildContext context) {
    return SegmentedButton<AnalyticsRange>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: AnalyticsRange.today,
          label: Text('Today'),
          icon: Icon(Icons.today_outlined),
        ),
        ButtonSegment(
          value: AnalyticsRange.week,
          label: Text('Week'),
          icon: Icon(Icons.view_week_outlined),
        ),
        ButtonSegment(
          value: AnalyticsRange.month,
          label: Text('Month'),
          icon: Icon(Icons.calendar_month_outlined),
        ),
        ButtonSegment(
          value: AnalyticsRange.year,
          label: Text('Year'),
          icon: Icon(Icons.date_range_outlined),
        ),
      ],
      selected: <AnalyticsRange>{_range},
      onSelectionChanged: (value) {
        setState(() {
          _range = value.first;
        });
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    Color? accentColor,
  }) {
    final iconColor = accentColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No analytics data yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Once the sensor starts sending readings, analytics will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
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
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load analytics',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection or sensor status, then try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () async {
                await _riverService.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatus(double value) {
    if (value < 30) return 'SAFE';
    if (value < 60) return 'MONITOR';
    if (value < 80) return 'WARNING';
    return 'DANGER';
  }

  Color _getStatusColor(double value) {
    if (value < 30) return Colors.green;
    if (value < 60) return Colors.amber.shade700;
    if (value < 80) return Colors.orange;
    return Colors.red;
  }

  String _getTrend(List<double> values) {
    if (values.length < 2) return 'Stable';

    final recent = values.length >= 5
        ? values.sublist(values.length - 5)
        : values;

    final first = recent.first;
    final last = recent.last;
    final diff = last - first;

    if (diff > 2) return 'Rising';
    if (diff < -2) return 'Falling';
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
        return Colors.red;
      case 'Falling':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  List<double> _filteredValues() {
    if (_values.isEmpty) return const <double>[];

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