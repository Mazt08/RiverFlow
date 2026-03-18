# Project Structure

## Root Overview

```text
RiverFlow/
├── lib/
├── assets/
├── docs/
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── test/
├── firebase.json
├── firestore.rules
└── pubspec.yaml
```

## `lib/` Application Source

### `lib/main.dart`

Application entry point, theme setup, route table, and Firebase initialization.

### `lib/screens/`

UI screens for user flows:

- `splash_screen.dart` - startup routing gate
- `login_screen.dart` - authentication UI
- `admin_shell.dart` - admin bottom-nav shell
- `user_shell.dart` - resident bottom-nav shell
- `admin_dashboard.dart` - admin monitoring view
- `user_dashboard.dart` - resident monitoring view
- `analytics_screen.dart` - historical chart analytics
- `broadcast_screen.dart` - admin message composer
- `messages_screen.dart` - resident/admin message history

### `lib/services/`

Business logic and data abstraction:

- `auth_service.dart` - login/session and role model logic
- `river_data_service.dart` - river telemetry stream provider
- `message_service.dart` - broadcast message service
- `firestore_service.dart` - Firestore collection operations and streams

### `lib/widgets/`

Reusable UI components:

- `river_status_card.dart` - status summary card
- `water_level_gauge.dart` - visual level indicator
- `alert_indicator.dart` / `alert_level_indicator.dart` - risk state badges
- `analytics_chart.dart` - chart rendering widget
- `message_card.dart` - broadcast message UI element
- `logout_button.dart` - session termination action

## `assets/`

Static project resources:

- `assets/images/` - logos and graphics
- `assets/fonts/` - optional custom font resources

## `docs/`

Project documentation for setup, architecture, APIs, usage, and governance.

## Platform Folders

- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`
- Contain platform-specific build, configuration, and runner files generated/managed by Flutter.

## Backend and Firebase Configuration

- `firebase.json` - Firebase project/runtime config
- `firestore.rules` - Firestore security rules

## `test/`

Widget/unit tests and automated quality checks.

## Structure Principles

- Keep UI components in `screens/` and reusable elements in `widgets/`.
- Keep backend-facing logic in `services/`.
- Avoid placing business logic directly inside widgets.
- Maintain clear separation between demo/mock data and production integrations.
