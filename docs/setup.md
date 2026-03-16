# Setup Guide

Step-by-step instructions for getting the RiverFlow Sentinel project running on your machine.

---

## Prerequisites

Make sure you have the following installed before cloning the repo:

| Tool                              | Version               | Download                                     |
| --------------------------------- | --------------------- | -------------------------------------------- |
| **Flutter SDK**                   | 3.10 or higher        | https://docs.flutter.dev/get-started/install |
| **Dart SDK**                      | Included with Flutter | —                                            |
| **Git**                           | Any recent version    | https://git-scm.com                          |
| **Android Studio** or **VS Code** | Latest                | For running the emulator / device            |

Verify your Flutter installation is working:

```bash
flutter doctor
```

All items should show a green checkmark. Fix any issues it reports before proceeding.

---

## 1. Clone the Repository

```bash
git clone https://github.com/Mazt08/RiverFlow.git
cd RiverFlow
```

---

## 2. Install Dependencies

Run this command inside the project folder. It reads `pubspec.yaml` and downloads all required packages:

```bash
flutter pub get
```

You should see output ending with `exit code 0`. This must be done every time you pull changes that add or update packages.

---

## 3. Run the App

### On an Android emulator or connected Android device:

```bash
flutter run
```

### On a specific device (if you have multiple):

```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

### On Chrome (web):

```bash
flutter run -d chrome
```

---

## 4. Demo Login Credentials

The app uses a built-in demo user store (no backend required to run locally).

| Role                | Email                 | Password       |
| ------------------- | --------------------- | -------------- |
| **Admin**           | `admin@riverflow.app` | `riverflow123` |
| **Resident / User** | `user@riverflow.app`  | `riverflow123` |

- **Admin** gets access to: Dashboard, Analytics, Broadcast, Messages
- **User** gets access to: Dashboard, Messages

---

## 5. Project Structure

```
lib/
├── main.dart                  # App entry point, routing, Material 3 theme
├── app_config.dart            # App-wide constants (river name, etc.)
├── screens/
│   ├── splash_screen.dart     # Animated splash screen
│   ├── login_screen.dart      # Unified login with role-based routing
│   ├── admin_shell.dart       # Admin navigation shell
│   ├── admin_dashboard.dart   # Admin overview + sensor health
│   ├── analytics_screen.dart  # Water-level charts (Today/Week/Month/Year)
│   ├── broadcast_screen.dart  # Admin message broadcaster
│   ├── messages_screen.dart   # Message inbox (admin + user)
│   ├── user_shell.dart        # User navigation shell
│   └── user_dashboard.dart    # Resident water-level monitor
├── services/
│   ├── auth_service.dart      # Auth logic, role management
│   ├── river_data_service.dart# Sensor data stream (simulated → Firebase-ready)
│   └── message_service.dart   # Broadcast message store (in-memory → Firebase-ready)
└── widgets/
	├── alert_indicator.dart       # Alert status badge
	├── alert_level_indicator.dart # Color-coded alert level bar
	├── analytics_chart.dart       # fl_chart line graph
	├── logout_button.dart         # Reusable logout button
	├── message_card.dart          # Broadcast message list tile
	├── river_status_card.dart     # Main river status summary card
	└── water_level_gauge.dart     # Visual water level gauge

assets/
└── images/
	└── logo.png               # App logo used on splash screen

test/
└── widget_test.dart           # Basic widget smoke tests
```

---

## 6. Firebase Setup (When Ready)

Firebase is currently commented out so the app runs fully offline with simulated data. When you're ready to connect a real backend:

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app (package name: check `android/app/build.gradle.kts`)
3. Download `google-services.json` and place it in `android/app/`
4. In `pubspec.yaml`, uncomment the Firebase packages:
   ```yaml
   firebase_core: ^3.15.2
   firebase_auth: ^5.7.0
   cloud_firestore: ^5.6.12
   firebase_database: ^11.3.10
   firebase_messaging: ^15.2.10
   ```
5. Run `flutter pub get` again
6. Replace the demo store in `auth_service.dart` with `FirebaseAuth`
7. Replace the simulated stream in `river_data_service.dart` with your MQTT/HTTP polling

---

## 7. Troubleshooting

### "Package not found" errors after pulling

You need to re-run `flutter pub get` whenever `pubspec.yaml` changes:

```bash
flutter pub get
```

### Merge conflict in `widget_test.dart` (shows `=======` in the file)

1. Open the file in VS Code — click **"Resolve in Merge Editor"** in the editor toolbar
2. Accept the **Incoming** (remote) version
3. Save the file
4. Stage and commit the resolved file:
   ```bash
   git add test/widget_test.dart
   git commit -m "resolve merge conflict in widget_test.dart"
   ```

### `flutter doctor` shows Android SDK issues

Open Android Studio → SDK Manager → install the required SDK platform and build tools.

### App shows blank / stuck on splash

Make sure `assets/images/logo.png` exists. It is tracked in git, so it should be there after cloning. If missing, ask the repo owner for the asset.
