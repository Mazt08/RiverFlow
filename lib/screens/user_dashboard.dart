import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/realtime_river_data_service.dart';

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({super.key});

  @override
  State<UserDashboardView> createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView>
    with TickerProviderStateMixin {
  final _riverService = RealtimeRiverDataService.instance;
  StreamSubscription<SensorReading>? _sub;

  SensorReading? _reading;
  bool _hasError = false;
  bool _didVibrateForEvacuate = false;
  bool _showEmergencyOverlay = false;
  DateTime? _lastUpdate;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _blinkAnimation = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _blinkController,
        curve: Curves.easeInOut,
      ),
    );

    _sub = _riverService.readings.listen(
      (r) async {
        await _handleEmergencyVibration(r);

        if (!mounted) return;

        setState(() {
          _reading = r;
          _hasError = false;
          _lastUpdate = DateTime.now();

          if (r.alertLevel == SensorAlertLevel.evacuate) {
            _showEmergencyOverlay = true;
          }
        });

        if (r.alertLevel == SensorAlertLevel.evacuate) {
          _pulseController.repeat(reverse: true);
          _blinkController.repeat(reverse: true);
        } else if (r.alertLevel == SensorAlertLevel.prepare) {
          _pulseController.repeat(reverse: true);
          _blinkController.stop();
          _blinkController.reset();
        } else {
          _pulseController.stop();
          _pulseController.reset();
          _blinkController.stop();
          _blinkController.reset();
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
        });
      },
    );
  }

  Future<void> _handleEmergencyVibration(SensorReading reading) async {
    if (reading.alertLevel == SensorAlertLevel.evacuate) {
      if (!_didVibrateForEvacuate) {
        final hasVibrator = await Vibration.hasVibrator() ?? false;
        if (hasVibrator) {
          await Vibration.vibrate(pattern: [0, 500, 200, 700]);
        }
        _didVibrateForEvacuate = true;
      }
    } else {
      _didVibrateForEvacuate = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    if (_reading == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FB),
        body: Center(
          child: Text(
            'Waiting for sensor data...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1F24),
            ),
          ),
        ),
      );
    }

    final reading = _reading!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _riverService.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: SafeArea(
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
                      _alertMessage(reading.alertLevel),
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
                    const SizedBox(height: 20),
                    _buildActionCard(reading),
                  ],
                ),
              ),
            ),
          ),

          if (_showEmergencyOverlay && reading.alertLevel == SensorAlertLevel.evacuate)
            _buildEmergencyOverlay(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SensorReading reading) {
    final color = _alertColor(reading.alertLevel);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.5)),
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
    final color = _alertColor(reading.alertLevel);
    final fillPercent = (reading.percentage / 100).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        final isEvacuate = reading.alertLevel == SensorAlertLevel.evacuate;

        final borderColor = isEvacuate
            ? Colors.red.withOpacity(_blinkAnimation.value)
            : color.withOpacity(0.9);

        final glowColor = isEvacuate
            ? Colors.red.withOpacity(0.28 * _blinkAnimation.value)
            : color.withOpacity(0.15);

        return Container(
          width: 170,
          height: 320,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
              width: isEvacuate ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: isEvacuate ? 24 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  height: 300 * fillPercent,
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
                  fontSize: 42,
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
      spacing: 22,
      runSpacing: 14,
      children: [
        _infoItem(
          'Height',
          '${reading.distance.toStringAsFixed(2)} cm',
        ),
        _infoItem(
          'Sensor',
          isOnline ? 'ONLINE' : 'OFFLINE',
        ),
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

  Widget _buildActionCard(SensorReading reading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          const Text(
            'Recommended Action',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1F24),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _safetyAction(reading.alertLevel),
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

  Widget _buildEmergencyOverlay() {
    return Container(
      color: Colors.red.withOpacity(0.92),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 110,
            ),
            const SizedBox(height: 24),
            const Text(
              'EVACUATE NOW',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Critical river level detected.\nMove immediately to a safer area or evacuation center.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showEmergencyOverlay = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                Icons.cloud_off_rounded,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'Unable to load sensor data',
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

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Color _alertColor(SensorAlertLevel level) {
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

  String _alertMessage(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return 'River levels are normal and currently stable.';
      case SensorAlertLevel.monitor:
        return 'Water levels are rising. Stay alert and monitor updates.';
      case SensorAlertLevel.prepare:
        return 'Prepare your essential items and get ready if evacuation is needed.';
      case SensorAlertLevel.evacuate:
        return 'Evacuate immediately and move to a safer area now.';
    }
  }

  String _safetyAction(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe:
        return 'Stay informed and continue checking updates from time to time. No urgent action is needed right now.';
      case SensorAlertLevel.monitor:
        return 'Charge your phone, secure important belongings, and keep monitoring announcements in case conditions worsen.';
      case SensorAlertLevel.prepare:
        return 'Prepare emergency supplies, gather important documents, and coordinate with your family for possible evacuation.';
      case SensorAlertLevel.evacuate:
        return 'Leave immediately for the nearest safe area or evacuation center. Prioritize children, elderly family members, and emergency essentials.';
    }
  }
}