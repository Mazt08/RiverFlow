import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';

enum SensorAlertLevel {
  safe,
  monitor,
  prepare,
  evacuate,
}

class SensorReading {
  final double distance;
  final double percentage;
  final String status;
  final SensorAlertLevel alertLevel;

  const SensorReading({
    required this.distance,
    required this.percentage,
    required this.status,
    required this.alertLevel,
  });
}

class RealtimeRiverDataService {
  RealtimeRiverDataService._();

  static final RealtimeRiverDataService instance =
      RealtimeRiverDataService._();

  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
  );

  DatabaseReference get _ref => _database.ref('river_data');

  Stream<SensorReading> get readings => _ref.onValue.map((event) {
        print('RTDB value: ${event.snapshot.value}');
        final raw = event.snapshot.value;

        if (raw == null) {
          return const SensorReading(
            distance: 0,
            percentage: 0,
            status: 'SAFE',
            alertLevel: SensorAlertLevel.safe,
          );
        }

        final map = Map<Object?, Object?>.from(raw as Map);

        final distance = _toDouble(map['distance']);
        final percentage = _toDouble(map['percentage']);
        final status = (map['status'] ?? 'SAFE').toString().toUpperCase();

        return SensorReading(
          distance: distance,
          percentage: percentage,
          status: status,
          alertLevel: _mapStatus(status),
        );
      });

  Future<void> refresh() async {
    final snapshot = await _ref.get();
    print('RTDB refresh value: ${snapshot.value}');
  }

  static double _toDouble(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  static SensorAlertLevel _mapStatus(String status) {
    switch (status) {
      case 'SAFE':
        return SensorAlertLevel.safe;
      case 'MONITOR':
        return SensorAlertLevel.monitor;
      case 'PREPARE':
        return SensorAlertLevel.prepare;
      case 'EVACUATE':
        return SensorAlertLevel.evacuate;
      default:
        return SensorAlertLevel.safe;
    }
  }
}