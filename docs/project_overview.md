# Project Overview

## Project Name

**RiverFlow Sentinel** — IoT-Based River Water Level Monitoring System

---

## Description

RiverFlow Sentinel is a cross-platform Flutter application designed for **real-time river water level monitoring** and **early flood warnings**. It is built to serve two distinct user roles:

- **Admins (Barangay Officials)** — monitor sensor health, view analytics, send emergency broadcast messages, and manage evacuation coordination.
- **Residents / Users** — receive live water level updates, alert statuses, and official broadcast messages.

The system is designed with a swap-ready service layer, meaning the current simulated sensor data and in-memory auth can be replaced with real IoT backends (MQTT/HTTP) and Firebase without rewriting any UI code.

---

## Technologies Used

| Technology                           | Purpose                                       |
| ------------------------------------ | --------------------------------------------- |
| **Flutter 3.10+**                    | Cross-platform mobile/web UI framework        |
| **Dart**                             | Application logic                             |
| **Material 3**                       | Design system (Deep Blue + Aqua theme)        |
| **fl_chart**                         | Water-level analytics charts                  |
| **Firebase** (ready, not yet active) | Auth, Firestore, Realtime DB, Messaging       |
| **C++ / IoT**                        | Arduino firmware for ultrasonic/float sensors |
| **Git & GitHub**                     | Version control, branching, pull requests     |

---

## Features

- 🌊 **Real-Time River Monitoring** — live water level readings streamed to both dashboards
- 🚨 **4-Tier Alert System** — color-coded alerts (Safe → Monitor → Prepare → Evacuate)
- 📊 **Analytics Dashboard** — historical water-level charts with Today / Week / Month / Year range filters
- 📢 **Broadcast Messaging** — admins send emergency messages with severity levels to all resident users
- 🔐 **Role-Based Access** — separate admin and resident dashboards with protected routes
- 🎨 **Material 3 UI** — custom Deep Blue + Aqua color scheme, responsive layout (mobile + tablet/web)
- 🔄 **Firebase-Ready Architecture** — all services are behind interfaces, swappable without UI changes

---

## Alert Levels

| Status | Level                   | Water Capacity | Action               |
| ------ | ----------------------- | -------------- | -------------------- |
| 🟢     | **SAFE**                | Below 30%      | Normal monitoring    |
| 🟡     | **MONITOR**             | 31% – 60%      | Watch for changes    |
| 🟠     | **PREPARE TO EVACUATE** | 61% – 80%      | Prepare residents    |
| 🔴     | **EVACUATE NOW**        | Above 80%      | Immediate evacuation |

---

## Contributions

> This entire project was built from scratch by **John Rex Aspiras** ([@Mazt08](https://github.com/Mazt08)).

### Flutter Application (built from scratch)

**Entry Point & Configuration**

- `lib/main.dart` — App entry point, Named route setup (`/splash`, `/login`, `/admin`, `/user`), Material 3 theme with custom color scheme
- `lib/app_config.dart` — App-wide constants

**Screens (9 screens)**

- `splash_screen.dart` — Animated fade-in splash screen with logo and loading indicator; auto-navigates to login after 2 seconds
- `login_screen.dart` — Unified email/password login screen with form validation, loading state, error handling, and role-based routing (admin → `/admin`, user → `/user`)
- `admin_shell.dart` — Adaptive navigation shell for admins; NavigationBar on mobile, NavigationRail on wider screens; includes logout confirmation dialog
- `admin_dashboard.dart` — Admin overview: live river status card, system statistics grid (accuracy, false alert rate, uptime, data points), sensor information card; pull-to-refresh support
- `analytics_screen.dart` — Water-level line chart with time-range filter (Today / Week / Month / Year); shows peak, current, and average levels; powered by `fl_chart`
- `broadcast_screen.dart` — Admin-only message broadcaster; compose message with severity selector (Info / Advisory / Warning / Emergency); sends via `MessageService`
- `messages_screen.dart` — Stream-driven message inbox for both admins and residents; real-time updates; empty state UI
- `user_shell.dart` — Navigation shell for residents (Dashboard + Messages + Logout)
- `user_dashboard.dart` — Resident dashboard: live water level, alert level indicator, recent level mini-graph (last 20 readings), flood advisory text, pull-to-refresh

**Services (3 services)**

- `auth_service.dart` — Singleton auth service with `AuthUser` model, `UserRole` enum, simulated sign-in with network latency; architected to swap for `FirebaseAuth`
- `river_data_service.dart` — Singleton that emits `RiverReading` snapshots on a broadcast `Stream`; simulates sensor data with realistic randomization; architected to swap for MQTT/HTTP polling from Arduino backend
- `message_service.dart` — In-memory message store with broadcast `Stream`; supports `sendBroadcast()` with severity levels; architected to swap for Firestore + Firebase Cloud Messaging

**Widgets (7 reusable widgets)**

- `river_status_card.dart` — Main summary card showing station name, water level, percentage bar, alert badge, rise rate, and last update time
- `alert_level_indicator.dart` — Color-coded horizontal indicator bar showing the current 4-tier alert level
- `alert_indicator.dart` — Compact alert status badge used in cards
- `water_level_gauge.dart` — Visual gauge displaying water level as a percentage fill
- `analytics_chart.dart` — `fl_chart` line chart widget; accepts a list of readings and renders with axis labels and tooltips
- `message_card.dart` — List tile for broadcast messages; color-coded by severity; shows title, body, and timestamp
- `logout_button.dart` — Reusable logout action button

**Assets**

- `assets/images/logo.png` — App logo used on the splash screen

**Testing**

- `test/widget_test.dart` — Widget smoke tests: verifies `MaterialApp` and `CircularProgressIndicator` render on splash

**Documentation (all docs)**

- `README.md`, `docs/setup.md`, `docs/project_overview.md`, `docs/architecture.md`, `docs/api.md`, `docs/usage.md`, `docs/contributing.md`, `docs/changelog.md`

### Commit History Summary

| Commit                                   | Description                                 |
| ---------------------------------------- | ------------------------------------------- |
| Initial commit                           | Project scaffold                            |
| Resident page                            | Early user dashboard work                   |
| File structure refactor                  | Reorganized project layout                  |
| Rename to RiverFlow Sentinel             | Project branding                            |
| Splash screen + login + admin nav        | Core screens                                |
| Assets: logo on splash                   | Logo integration                            |
| Admin Dashboard UI + docs                | Official dashboard wireframe and usage docs |
| PR merges (×3)                           | Feature branch integrations                 |
| Modularize into screens/services/widgets | Full refactor into layered architecture     |
| Configure release APK v1.0               | Production build configuration              |

---

Refer to the other documentation files for [API reference](api.md), [architecture](architecture.md), [setup guide](setup.md), [usage guide](usage.md), [contributing guidelines](contributing.md), and the [changelog](changelog.md).
