import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertLevel { safe, monitor, prepare, evacuate }

/// Represents a river sensor reading stored in Firestore.
class RiverDataModel {
  const RiverDataModel({
    required this.recordId,
    required this.waterLevel,
    required this.percentage,
    required this.alertLevel,
    required this.timestamp,
    required this.riseRatePerHour,
    required this.sensorOnline,
    this.maxLevel = 5.0,
  });

  final String recordId;
  final double waterLevel; // in meters
  final double percentage; // 0.0 - 1.0
  final AlertLevel alertLevel;
  final DateTime timestamp;
  final double riseRatePerHour;
  final bool sensorOnline;
  final double maxLevel; // maximum water level in meters

  /// Human-readable label for the current alert.
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

  /// Convert RiverDataModel to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'waterLevel': waterLevel,
      'percentage': percentage,
      'alertLevel': alertLevel.name, // 'safe', 'monitor', 'prepare', 'evacuate'
      'riseRatePerHour': riseRatePerHour,
      'sensorOnline': sensorOnline,
      'maxLevel': maxLevel,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create RiverDataModel from Firestore document.
  factory RiverDataModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    String parseAlertLevel(dynamic value) {
      if (value is String) {
        return value;
      }
      return 'monitor';
    }

    final alertLevelStr = parseAlertLevel(data['alertLevel']);
    final alertLevel = AlertLevel.values.firstWhere(
      (e) => e.name == alertLevelStr,
      orElse: () => AlertLevel.monitor,
    );

    return RiverDataModel(
      recordId: doc.id,
      waterLevel: (data['waterLevel'] as num?)?.toDouble() ?? 0.0,
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0.0,
      alertLevel: alertLevel,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      riseRatePerHour: (data['riseRatePerHour'] as num?)?.toDouble() ?? 0.0,
      sensorOnline: data['sensorOnline'] as bool? ?? true,
      maxLevel: (data['maxLevel'] as num?)?.toDouble() ?? 5.0,
    );
  }

  /// Copy with method for immutability.
  RiverDataModel copyWith({
    String? recordId,
    double? waterLevel,
    double? percentage,
    AlertLevel? alertLevel,
    DateTime? timestamp,
    double? riseRatePerHour,
    bool? sensorOnline,
    double? maxLevel,
  }) {
    return RiverDataModel(
      recordId: recordId ?? this.recordId,
      waterLevel: waterLevel ?? this.waterLevel,
      percentage: percentage ?? this.percentage,
      alertLevel: alertLevel ?? this.alertLevel,
      timestamp: timestamp ?? this.timestamp,
      riseRatePerHour: riseRatePerHour ?? this.riseRatePerHour,
      sensorOnline: sensorOnline ?? this.sensorOnline,
      maxLevel: maxLevel ?? this.maxLevel,
    );
  }

  @override
  String toString() {
    return 'RiverDataModel(recordId: $recordId, waterLevel: $waterLevel, percentage: $percentage, alertLevel: $alertLevel, timestamp: $timestamp, sensorOnline: $sensorOnline)';
  }
}
