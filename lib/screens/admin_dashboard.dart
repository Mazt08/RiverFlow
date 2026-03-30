import 'dart:async';
import 'package:flutter/material.dart';
import '../services/realtime_river_data_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView>
    with SingleTickerProviderStateMixin {
  final _riverService = RealtimeRiverDataService.instance;
  StreamSubscription<SensorReading>? _sub;

  SensorReading? _reading;
  bool _hasError = false;
  bool _isLoading = true;
  DateTime? _lastUpdate;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _sub = _riverService.readings.listen(
      (reading) {
        setState(() {
          _reading = reading;
          _hasError = false;
          _isLoading = false;
          _lastUpdate = DateTime.now();
        });

        if (reading.alertLevel == SensorAlertLevel.prepare ||
            reading.alertLevel == SensorAlertLevel.evacuate) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      },
      onError: (_) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStatusColor(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return const Color(0xFF2E7D32);
      case SensorAlertLevel.monitor:
        return const Color(0xFFF9A825);
      case SensorAlertLevel.prepare:
        return const Color(0xFFEF6C00);
      case SensorAlertLevel.evacuate:
        return const Color(0xFFC62828);
    }
  }

  IconData _getStatusIcon(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return Icons.check_circle_rounded;
      case SensorAlertLevel.monitor:
        return Icons.visibility_rounded;
      case SensorAlertLevel.prepare:
        return Icons.warning_amber_rounded;
      case SensorAlertLevel.evacuate:
        return Icons.notifications_active_rounded;
    }
  }

  String _getStatusMessage(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return 'River level is stable and within safe range.';
      case SensorAlertLevel.monitor:
        return 'River level is rising. Continuous monitoring is advised.';
      case SensorAlertLevel.prepare:
        return 'Warning level reached. Prepare for possible response actions.';
      case SensorAlertLevel.evacuate:
        return 'Critical level detected. Immediate evacuation is advised.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reading = _reading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : reading == null
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => _riverService.refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(
                          children: [
                            _buildStatusChip(reading),
                            const SizedBox(height: 20),

                            const Text(
                              'River Capacity Progress',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B1F24),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getStatusMessage(reading.alertLevel),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 26),

                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: _buildCapacityMonitor(reading),
                            ),

                            const SizedBox(height: 24),

                            _buildBottomInfo(reading),

                            const SizedBox(height: 24),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Live Monitoring Overview',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B1F24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.05,
                              children: [
                                _metricCard(
                                  title: 'Distance',
                                  value:
                                      '${reading.distance.toStringAsFixed(2)} cm',
                                  icon: Icons.straighten_rounded,
                                  color: const Color(0xFF1E88E5),
                                ),
                                _metricCard(
                                  title: 'Water Level',
                                  value:
                                      '${reading.percentage.toStringAsFixed(1)}%',
                                  icon: Icons.water_drop_rounded,
                                  color: const Color(0xFF00ACC1),
                                ),
                                _metricCard(
                                  title: 'System Status',
                                  value: reading.status,
                                  icon: _getStatusIcon(reading.alertLevel),
                                  color: _getStatusColor(reading.alertLevel),
                                ),
                                _metricCard(
                                  title: 'Alert Level',
                                  value:
                                      reading.alertLevel.name.toUpperCase(),
                                  icon: Icons.shield_rounded,
                                  color: _getStatusColor(reading.alertLevel),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            _buildInsightsSection(reading),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatusChip(SensorReading reading) {
    final color = _getStatusColor(reading.alertLevel);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 6),
            Text(
              reading.status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityMonitor(SensorReading reading) {
    final color = _getStatusColor(reading.alertLevel);
    final fillPercent = (reading.percentage / 100).clamp(0.0, 1.0);

    return Container(
      width: 180,
      height: 330,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  height: 310 * fillPercent,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        color.withOpacity(0.55),
                        color.withOpacity(0.22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${reading.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current Level',
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(SensorReading reading) {
    final isOnline = _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!).inSeconds < 10;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 14,
      children: [
        _infoItem('Height', '${reading.distance.toStringAsFixed(2)} cm'),
        _infoItem('Sensor', isOnline ? 'ONLINE' : 'OFFLINE'),
        _infoItem(
          'Last Updated',
          _lastUpdate == null ? 'Just now' : _formatTime(_lastUpdate!),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1B1F24),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(SensorReading reading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(16, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Insight',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1F24),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The RiverFlow Sentinel system is actively monitoring river conditions in real time. '
            'The current measured distance is ${reading.distance.toStringAsFixed(2)} cm, while the detected water level is '
            '${reading.percentage.toStringAsFixed(1)}%. Based on the latest reading, the system status is ${reading.status}, '
            'which corresponds to a ${reading.alertLevel.name.toUpperCase()} alert level.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF4A5560),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F7FB),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 12),
              Text(
                'Failed to load river data from Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1F24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F7FB),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No sensor data available yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1F24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(15, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1F24),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}