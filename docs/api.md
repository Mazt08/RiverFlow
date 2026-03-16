# API / Services Reference

This document covers all data models, enums, and service APIs in the RiverFlow Sentinel Flutter app.

---

## Data Models

### `AuthUser`

Defined in `lib/services/auth_service.dart`

```dart
class AuthUser {
	final String id;
	final String name;
	final String email;
	final UserRole role;  // UserRole.admin | UserRole.user
}
```

### `RiverReading`

Defined in `lib/services/river_data_service.dart`

```dart
class RiverReading {
	final double waterLevelMeters;   // current water level in metres
	final double maxLevelMeters;     // river capacity (default: 5.0 m)
	final AlertLevel alertLevel;     // derived alert tier
	final DateTime timestamp;        // time of reading
	final double riseRatePerHour;    // metres/hour change
	final bool sensorOnline;         // sensor health status

	double get percentage;           // waterLevelMeters / maxLevelMeters (0.0–1.0)
	String get alertLabel;           // human-readable alert string
}
```

### `BroadcastMessage`

Defined in `lib/services/message_service.dart`

```dart
class BroadcastMessage {
	final String id;                    // epoch milliseconds as string
	final String title;                 // derived from severity
	final String body;                  // message text
	final MessageSeverity severity;     // info | advisory | warning | emergency
	final DateTime timestamp;
}
```

---

## Enums

### `UserRole`

```dart
enum UserRole { admin, user }
```

### `AlertLevel`

| Value      | Water % | Label               |
| ---------- | ------- | ------------------- |
| `safe`     | < 30%   | SAFE                |
| `monitor`  | 30–60%  | MONITOR             |
| `prepare`  | 60–80%  | PREPARE TO EVACUATE |
| `evacuate` | > 80%   | EVACUATE NOW        |

### `MessageSeverity`

| Value       | Color  | Auto-title      |
| ----------- | ------ | --------------- |
| `info`      | Blue   | River Update    |
| `advisory`  | Yellow | Advisory Notice |
| `warning`   | Orange | Flood Warning   |
| `emergency` | Red    | EMERGENCY ALERT |

---

## AuthService

`lib/services/auth_service.dart` · Singleton: `AuthService.instance`

### `signIn({required String email, required String password})`

```dart
Future<AuthUser?> signIn({required String email, required String password})
```

- Simulates ~650 ms network latency
- Returns `AuthUser` on success, `null` if credentials don't match
- Sets `currentUser` internally on success

### `signOut()`

```dart
void signOut()
```

- Clears `currentUser`

### Getters

```dart
AuthUser? get currentUser   // currently logged-in user, null if signed out
bool get isLoggedIn         // true if currentUser != null
```

### Demo credentials

| Email                 | Password       | Role  |
| --------------------- | -------------- | ----- |
| `admin@riverflow.app` | `riverflow123` | admin |
| `user@riverflow.app`  | `riverflow123` | user  |

---

## RiverDataService

`lib/services/river_data_service.dart` · Singleton: `RiverDataService.instance`

### `readings`

```dart
Stream<RiverReading> get readings
```

- Returns a broadcast stream that emits a new `RiverReading` every polling interval
- Starts the internal timer on first listen
- Safe to subscribe to from multiple widgets simultaneously

### `refresh()`

```dart
Future<void> refresh()
```

- Triggers an immediate new reading emission (used by pull-to-refresh)

### Usage example

```dart
final _sub = RiverDataService.instance.readings.listen((reading) {
	setState(() => _reading = reading);
});

// In dispose():
_sub.cancel();
```

---

## MessageService

`lib/services/message_service.dart` · Singleton: `MessageService.instance`

### `messageStream`

```dart
Stream<List<BroadcastMessage>> get messageStream
```

- Broadcast stream; emits the full message list every time a new message is sent
- Immediately emits the current list on first listen (via `scheduleMicrotask`)

### `currentMessages`

```dart
List<BroadcastMessage> get currentMessages
```

- Synchronous snapshot of the current message list (unmodifiable)

### `sendBroadcast({required String body, MessageSeverity severity})`

```dart
Future<void> sendBroadcast({
	required String body,
	MessageSeverity severity = MessageSeverity.warning,
})
```

- Simulates ~500 ms network latency
- Creates a `BroadcastMessage` with auto-generated `id` and `title` from severity
- Throws `ArgumentError` if `body` is empty after trimming
- Pushes updated list to all stream listeners

---

## AppConfig

`lib/app_config.dart`

```dart
class AppConfig {
	static const String riverName = 'RiverFlow River';
}
```

Update `riverName` to match the actual river being monitored.
