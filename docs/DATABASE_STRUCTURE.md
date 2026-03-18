# Firebase Cloud Firestore Structure

## Overview

RiverFlow Sentinel uses Firebase Cloud Firestore as the primary operational data store for user profiles, river telemetry, and broadcast messages.

## Recommended Collection Layout

```text
users (collection)
  {uid} (document)
    name: string
    email: string
    role: "admin" | "user"
    createdAt: ISO8601 string

river_data (collection)
  {record_id} (document)
    waterLevel: number
    percentage: number
    alertLevel: "safe" | "monitor" | "prepare" | "evacuate"
    riseRatePerHour: number
    sensorOnline: boolean
    timestamp: Firestore Timestamp

messages (collection)
  {message_id} (document)
    title: string
    message: string
    severity: "info" | "advisory" | "warning" | "emergency"
    sender: string (uid or system)
    timestamp: Firestore Timestamp

notification_tokens (collection)
  {uid} (document)
    tokens: map<string, string>
```

## Example Firestore Documents

```json
{
  "users": {
    "uid_001": {
      "name": "RiverFlow Admin",
      "email": "admin@riverflow.app",
      "role": "admin",
      "createdAt": "2026-03-18T08:00:00Z"
    }
  },
  "river_data": {
    "rec_1742275510": {
      "waterLevel": 3.42,
      "percentage": 0.68,
      "alertLevel": "prepare",
      "riseRatePerHour": 0.21,
      "sensorOnline": true,
      "timestamp": "2026-03-18T08:11:50Z"
    }
  },
  "messages": {
    "msg_1742275522": {
      "title": "⚠️ RiverFlow Alert",
      "message": "River level rising rapidly. Prepare evacuation.",
      "severity": "warning",
      "sender": "uid_001",
      "timestamp": "2026-03-18T08:12:02Z"
    }
  }
}
```

## Collection Purpose

### `users`

Stores account profile metadata and role assignment.

- Used for role-based authorization in app and security rules.
- `role` determines dashboard access and broadcast permissions.

### `river_data`

Stores time-series telemetry from river sensors.

- Primary source for real-time dashboards.
- Supports historical analytics and trend computation.
- Should be indexed by `timestamp` and `alertLevel`.

### `messages`

Stores admin/system broadcast communications.

- Used to show in-app message feed for residents.
- Can trigger push notifications through FCM.

### `notification_tokens`

Stores FCM registration tokens per authenticated user.

- Required for targeted push notifications.
- User should only access their own token records.

## Data Retention Recommendations

- Keep high-frequency raw sensor data for 30–90 days.
- Archive/aggregate older readings for long-term analytics.
- Retain critical alert records for incident audit reports.

## Naming and Validation Conventions

- Use lowercase snake/camel consistently for field names.
- Keep `timestamp` as Firestore `Timestamp` (server-generated when possible).
- Validate alert/severity fields against fixed enums.
- Prefer server-generated timestamps for authoritative ordering.
