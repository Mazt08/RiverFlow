# Architecture

This document describes the architecture of RiverFlow Sentinel, including its layers, data flow, navigation model, and design decisions.

---

## Overview

RiverFlow Sentinel follows a **layered architecture** with three clear layers:

```
┌─────────────────────────────────────┐
│             Screens (UI)             │  ← what the user sees
├─────────────────────────────────────┤
│           Widgets (Components)       │  ← reusable UI building blocks
├─────────────────────────────────────┤
│            Services (Logic)          │  ← data, auth, messages
└─────────────────────────────────────┘
```

Screens depend on Services for data. Screens use Widgets for rendering. Services are all singletons and expose `Stream`-based APIs so the UI reacts to data changes in real time.

---

## Navigation Model

The app uses **named routes** defined in `main.dart`:

```
/splash  →  SplashScreen
	      ↓ (after 2s)
/login   →  LoginScreen
	      ↓ (on success)
	 ┌────┴────┐
     admin      user
	 ↓          ↓
/admin  AdminShellScreen    /user  UserShellScreen
	 ├── AdminDashboardView          ├── UserDashboardView
	 ├── AnalyticsScreen             └── MessagesScreen
	 ├── BroadcastScreen
	 └── MessagesScreen
```

Role-based routing is determined by `AuthService` — after login, the `UserRole` enum (`admin` or `user`) decides which shell the user is navigated to. Unauthorized direct access is prevented by the fact that both shells call `AuthService.instance.currentUser` to verify session.

---

## Service Layer

All services follow the **singleton pattern** (`ServiceName._()` private constructor + `static final instance`). This ensures a single source of truth throughout the app's lifecycle.

### AuthService

- Holds the currently logged-in `AuthUser`
- Exposes `signIn()` and `signOut()`
- Currently uses an in-memory demo store; designed to be swapped for `FirebaseAuth`

### RiverDataService

- Emits `RiverReading` objects on a broadcast `Stream<RiverReading>`
- Polls on a timer (simulated); designed to be swapped for MQTT subscriptions or HTTP polling from the Arduino backend
- `AlertLevel` is derived from the water level percentage inside `RiverReading`

### MessageService

- Holds a `List<BroadcastMessage>` in memory
- Exposes `messageStream` (a broadcast `Stream`) and `currentMessages` getter
- `sendBroadcast()` adds a message and pushes the updated list to all listeners
- Designed to be swapped for Firestore + Firebase Cloud Messaging

---

## Data Flow

```
[Arduino Sensor]
	↓  (MQTT / HTTP — future)
RiverDataService.readings  (Stream<RiverReading>)
	↓
AdminDashboardView / UserDashboardView / AnalyticsScreen
	↓
RiverStatusCard / WaterLevelGauge / AnalyticsChart

[Admin User]
	↓  types message in BroadcastScreen
MessageService.sendBroadcast()
	↓  pushes to Stream<List<BroadcastMessage>>
MessagesScreen (admin + user both receive it)
```

---

## Adaptive Layout

Both `AdminShellScreen` and `UserShellScreen` use a `LayoutBuilder` to switch between:

- **`NavigationBar`** (bottom) on narrow screens (mobile)
- **`NavigationRail`** (side) on wider screens (tablet / web)

This makes the app responsive without any platform-specific code.

---

## Theme System

The Material 3 theme is defined once in `main.dart` and flows through the entire widget tree via `Theme.of(context)`:

- **Primary color**: `#0C3B7A` (Deep Blue)
- **Secondary color**: `#119DA4` (Aqua / Teal)
- All cards have 16 px rounded corners, elevation 1
- AppBar is transparent (elevation 0), left-aligned title
- NavigationBar and NavigationRail have matching indicator colors from the scheme

---

## Firebase-Ready Design

The three services (`AuthService`, `RiverDataService`, `MessageService`) are intentionally thin wrappers. The swap plan is:

| Service            | Current (Demo)            | Future (Firebase)                                    |
| ------------------ | ------------------------- | ---------------------------------------------------- |
| `AuthService`      | In-memory user list       | `FirebaseAuth.instance.signInWithEmailAndPassword()` |
| `RiverDataService` | `Timer`-based random data | `FirebaseDatabase` RTDB listener or MQTT             |
| `MessageService`   | In-memory `List`          | `FirebaseFirestore` collection + `FirebaseMessaging` |

No UI files need to change — only the service implementations.
