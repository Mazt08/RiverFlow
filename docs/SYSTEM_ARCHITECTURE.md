# RiverFlow Sentinel System Architecture

## Overview

RiverFlow Sentinel is an IoT-enabled flood early warning platform that combines river sensors, edge devices, Firebase backend services, and a Flutter mobile application.

It is designed for near-real-time monitoring, operational alerting, and public information dissemination.

## Core Components

### 1. IoT Sensors

- Ultrasonic, pressure, or float sensors capture river water-level readings.
- Sensor station sampling target is every **5 seconds**.
- Each reading includes:
  - `waterLevel` (meters)
  - `timestamp`
  - optional health metadata (battery, signal, sensor status)

### 2. Microcontroller Layer (ESP32 / Arduino)

- ESP32/Arduino aggregates raw sensor input.
- Applies local smoothing/noise filtering before upload.
- Sends payloads to Cloud Firestore over Wi-Fi/LTE.
- Retries failed uploads to reduce data loss during network instability.

### 3. Firebase Backend

- **Firebase Cloud Firestore** stores live and historical river telemetry.
- **Firebase Authentication** identifies users and controls access by role.
- **Firebase Cloud Messaging (FCM)** delivers flood alerts and broadcasts.
- Security rules enforce role-based access for data and messaging.

### 4. Flutter Mobile Application

- Provides separate user experiences for:
  - **Admin** (monitor, analytics, broadcast)
  - **User/Resident** (status, alerts, message history)
- Subscribes to live data streams for dashboard updates.
- Displays visual risk indicators and analytics charts.

### 5. Notification System

- Alert events trigger message creation and FCM push notifications.
- Residents receive both in-app history and push alerts.
- Admins can issue manual advisories in addition to automatic alerts.

## Architecture Flow

```text
River Sensors
   ↓
IoT Microcontroller (ESP32/Arduino)
   ↓
Firebase Cloud Firestore
   ↓
Flutter Mobile App (Admin / User)
   ↓
Users & Admin Monitoring
```

## Real-Time Update Model (5-Second Pipeline)

1. Sensor samples water level every 5 seconds.
2. Microcontroller validates payload and timestamps reading.
3. Reading is pushed to `river_data/` in Cloud Firestore.
4. App listeners receive updates immediately via stream subscriptions.
5. UI updates status cards, alert indicators, and charts.

> Note: the current demo service may use a slower simulated interval during development. Production target remains 5 seconds from sensor ingestion.

## Flood Alert Triggering Logic

Flood alerts are derived from water-level percentage against configured river capacity thresholds:

- **SAFE**: below 45%
- **MONITOR**: 45% to <65%
- **PREPARE TO EVACUATE**: 65% to <85%
- **EVACUATE NOW**: 85%+

When a threshold crossing occurs:

1. System computes new `alertLevel`.
2. Alert event is written to the database and/or `messages/`.
3. FCM push is sent to affected users.
4. App dashboards immediately reflect the new risk level.

## Notification Delivery Path

1. Admin or automated rule creates a broadcast/alert record.
2. Backend (Cloud Function or trusted server) formats FCM payload.
3. Push notification is sent to topic/user tokens.
4. User taps notification and opens relevant in-app screen.
5. Message remains available in local history feed.

## Reliability and Security Considerations

- Store server-generated timestamps for ordering and audit trails.
- Use role-based Firestore security rules with custom admin claims.
- Restrict broadcast writes to admin-only channels.
- Prefer backend-mediated writes for trusted sensor ingestion.

## Future Improvements

- AI-assisted flood prediction from historical trend modeling.
- Rainfall + upstream station integration for better lead time.
- Edge failover buffering for disconnected sensor stations.
- Multi-barangay command center dashboard for LGU operations.
