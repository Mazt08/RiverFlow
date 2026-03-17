<div align="center">

# RiverFlow Sentinel
### *IoT-Based River Water Level Monitoring System*

</div>

---

## Description

**RiverFlow Sentinel** is a cross-platform Flutter application for **real-time river water level monitoring** and **early flood warnings**. It serves two roles: **Admins (Barangay Officials)** who monitor sensors, view analytics, and send emergency broadcasts, and **Residents** who receive live water level updates and official alerts.

---

## Technologies Used

- **Flutter 3.10+** - Cross-platform mobile/web UI
- **Dart** - Application logic
- **Material 3** - Design system with Deep Blue + Aqua theme
- **fl_chart** - Water-level analytics charts
- **Firebase** _(ready, not yet active)_ - Auth, Firestore, Realtime DB, Messaging
- **C++ / IoT** - Arduino firmware for ultrasonic/float sensors
- **Git & GitHub** - Version control and collaboration

---

## Features

- **Real-Time River Monitoring** - Live sensor data streamed to both dashboards
- **4-Tier Alert System** - Color-coded (Safe -> Monitor -> Prepare -> Evacuate)
- **Analytics Dashboard** - Line charts with Today / Week / Month / Year filters
- **Broadcast Messaging** - Admins send emergency messages to all residents
- **Role-Based Access** - Separate admin and resident dashboards
- **Responsive Material 3 UI** - Works on mobile, tablet, and web
- **Firebase-Ready Architecture** - Swap services without rewriting UI

---

## Alert Levels

| Status | Level                   | Water Capacity | Action               |
| ------ | ----------------------- | -------------- | -------------------- |
| Green  | **SAFE**                | Below 30%      | Normal monitoring    |
| Yellow | **MONITOR**             | 31% - 60%      | Watch for changes    |
| Orange | **PREPARE TO EVACUATE** | 61% - 80%      | Prepare residents    |
| Red    | **EVACUATE NOW**        | Above 80%      | Immediate evacuation |

---

## Quick Start (for teammates)

```bash
# 1. Clone
git clone https://github.com/Mazt08/RiverFlow.git
cd RiverFlow

# 2. Install packages
flutter pub get

# 3. Run
flutter run
```

Login with:
- **Admin**: `admin@riverflow.app` / `riverflow123`
- **Resident**: `user@riverflow.app` / `riverflow123`

See [docs/setup.md](docs/setup.md) for the full setup guide including Firebase configuration and troubleshooting.

---

## Documentation

| File                                                 | Description                                   |
| ---------------------------------------------------- | --------------------------------------------- |
| [docs/setup.md](docs/setup.md)                       | Step-by-step setup guide for teammates        |
| [docs/project_overview.md](docs/project_overview.md) | Full project overview and contribution list   |
| [docs/architecture.md](docs/architecture.md)         | App architecture, data flow, navigation model |
| [docs/api.md](docs/api.md)                           | Services and data model reference             |
| [docs/usage.md](docs/usage.md)                       | How to use each screen                        |
| [docs/contributing.md](docs/contributing.md)         | Branching strategy and coding conventions     |
| [docs/changelog.md](docs/changelog.md)               | Version history                               |

---

<div align="center">

*Early flood detection saves lives.*

</div>
