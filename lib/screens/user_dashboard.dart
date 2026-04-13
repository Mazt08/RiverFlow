import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // Audio player instance for emergency alerts
  final AudioPlayer _audioPlayer = AudioPlayer();

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
      end: 1.05,
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
        // Trigger alerts based on the reading
        await _handleEmergencyAlerts(r);

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

  /// Handles vibration and sound for critical levels
  Future<void> _handleEmergencyAlerts(SensorReading reading) async {
    if (reading.alertLevel == SensorAlertLevel.evacuate) {
      if (!_didVibrateForEvacuate) {
        // 1. Vibration: Continuous until cancelled
        final hasVibrator = await Vibration.hasVibrator() ?? false;
        if (hasVibrator) {
          Vibration.vibrate(pattern: [0, 500, 200, 700], repeat: 0);
        }

        // 2. Sound: Loop your specific sounds.wav file
        try {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          // FIX: Corrected path and filename from your image
          await _audioPlayer.play(AssetSource('sounds/sounds.wav'));
        } catch (e) {
          debugPrint("Sound error: $e");
        }

        _didVibrateForEvacuate = true;
      }
    } else {
      // Level is safe: Stop vibration and audio
      Vibration.cancel();
      _audioPlayer.stop();
      _didVibrateForEvacuate = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseController.dispose();
    _blinkController.dispose();
    _audioPlayer.dispose(); 
    Vibration.cancel();    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _buildErrorState();
    if (_reading == null) return _buildLoadingState();

    final reading = _reading!;
    final color = _alertColor(reading.alertLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _riverService.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(reading),
                    const SizedBox(height: 20),
                    _buildHeroStatusCard(reading),
                    const SizedBox(height: 20),
                    Center(
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: _buildCapacityMonitor(reading),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildQuickStats(reading),
                    const SizedBox(height: 18),
                    _buildSafetyCard(reading),
                    const SizedBox(height: 18),
                    _buildTipsCard(reading, color),
                  ],
                ),
              ),
            ),
          ),
          if (_showEmergencyOverlay &&
              reading.alertLevel == SensorAlertLevel.evacuate)
            _buildEmergencyOverlay(),
        ],
      ),
    );
  }

  Widget _buildEmergencyOverlay() {
    return Container(
      color: Colors.red.withOpacity(0.94),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 110),
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
              'Critical river level detected.\nMove immediately to a safer area.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Vibration.cancel();
                  _audioPlayer.stop();
                  setState(() => _showEmergencyOverlay = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Dismiss Alert', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SensorReading reading) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RiverFlow Sentinel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              Text(
                'Stay informed with real-time river level monitoring.',
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildLiveBadge(),
      ],
    );
  }

  Widget _buildLiveBadge() {
    final isOnline = _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!).inSeconds < 10;
    final color = isOnline ? const Color(0xFF10B981) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'LIVE' : 'OFFLINE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatusCard(SensorReading reading) {
    final color = _alertColor(reading.alertLevel);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.16), color.withOpacity(0.07)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
            child: Icon(_alertIcon(reading.alertLevel), color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusChip(reading),
                const SizedBox(height: 10),
                Text(
                  _alertMessage(reading.alertLevel),
                  style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Current river level is at ${reading.percentage.toStringAsFixed(0)}% capacity.',
                  style: TextStyle(fontSize: 13.5, height: 1.5, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
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
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 6),
            Text(
              reading.status.toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.w800, letterSpacing: 0.3),
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
        final borderColor = isEvacuate ? Colors.red.withOpacity(_blinkAnimation.value) : color.withOpacity(0.9);
        final glowColor = isEvacuate ? Colors.red.withOpacity(0.28 * _blinkAnimation.value) : color.withOpacity(0.15);

        return Container(
          width: 210,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: isEvacuate ? 3 : 2),
            boxShadow: [
              BoxShadow(color: glowColor, blurRadius: isEvacuate ? 26 : 18, offset: const Offset(0, 10)),
              const BoxShadow(color: Color.fromARGB(12, 0, 0, 0), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          const Text('River Capacity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          Container(
            width: 150, height: 320,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        height: 300 * fillPercent,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [color.withOpacity(0.75), color.withOpacity(0.30)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${reading.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: color)),
                    const SizedBox(height: 8),
                    Text('Current Level', style: TextStyle(fontSize: 13, color: color.withOpacity(0.95), fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(SensorReading reading) {
    final isOnline = _lastUpdate != null && DateTime.now().difference(_lastUpdate!).inSeconds < 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _infoCard(icon: Icons.height_rounded, title: 'Height', value: '${reading.distance.toStringAsFixed(2)} cm')),
            const SizedBox(width: 12),
            Expanded(child: _infoCard(icon: Icons.sensors_rounded, title: 'Sensor', value: isOnline ? 'ONLINE' : 'OFFLINE')),
          ],
        ),
        const SizedBox(height: 12),
        _wideInfoCard(icon: Icons.access_time_rounded, title: 'Last Updated', value: _lastUpdate == null ? 'Just now' : _formatTime(_lastUpdate!)),
      ],
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color.fromARGB(10, 0, 0, 0), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2563EB)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _wideInfoCard({required IconData icon, required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color.fromARGB(10, 0, 0, 0), blurRadius: 12, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Text('$title: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(SensorReading reading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color.fromARGB(12, 0, 0, 0), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Action', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 10),
          Text(_safetyAction(reading.alertLevel), style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }

  Widget _buildTipsCard(SensorReading reading, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pull down to refresh. Monitor updates closely as conditions can change rapidly.',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F7FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Waiting for sensor data...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 62, color: Colors.grey),
            const Text('Unable to load sensor data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: () => _riverService.refresh(), child: const Text('Retry')),
          ],
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

  IconData _alertIcon(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe: return Icons.verified_rounded;
      case SensorAlertLevel.monitor: return Icons.visibility_rounded;
      case SensorAlertLevel.prepare: return Icons.notifications_active_rounded;
      case SensorAlertLevel.evacuate: return Icons.warning_amber_rounded;
    }
  }

  Color _alertColor(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe: return const Color(0xFF10B981);
      case SensorAlertLevel.monitor: return const Color(0xFFF59E0B);
      case SensorAlertLevel.prepare: return const Color(0xFFF97316);
      case SensorAlertLevel.evacuate: return const Color(0xFFEF4444);
    }
  }

  String _alertMessage(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe: return 'River levels are normal and currently stable.';
      case SensorAlertLevel.monitor: return 'Water levels are rising. Stay alert.';
      case SensorAlertLevel.prepare: return 'Prepare your essential items now.';
      case SensorAlertLevel.evacuate: return 'Evacuate immediately to a safer area.';
    }
  }

  String _safetyAction(SensorAlertLevel level) {
    switch (level) {
      case SensorAlertLevel.safe: return 'Stay informed. No urgent action needed.';
      case SensorAlertLevel.monitor: return 'Charge phones and monitor announcements.';
      case SensorAlertLevel.prepare: return 'Gather documents and coordinate evacuation plans.';
      case SensorAlertLevel.evacuate: return 'Leave immediately. Prioritize children and the elderly.';
    }
  }
}