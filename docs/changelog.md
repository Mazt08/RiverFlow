# Changelog

All notable changes to RiverFlow Sentinel are documented here, in reverse chronological order.

---

## [v1.0.0] — 2026-03-16

### Release: Production APK Configuration

- Configured release APK signing for RiverFlow Sentinel v1.0
- App is ready for deployment

---

## [Refactor] — Modularize into Screens / Services / Widgets

### Architecture Overhaul

- Split monolithic code into `lib/screens/`, `lib/services/`, `lib/widgets/`
- Introduced `RiverDataService` singleton with broadcast stream
- Introduced `MessageService` singleton for broadcast messages
- Introduced `AuthService` singleton with role-based sign-in
- Added `AppConfig` for app-wide constants
- All services architected to be swap-ready for Firebase

### New Screens

- `AnalyticsScreen` — fl_chart line graph with Today/Week/Month/Year range filters
- `BroadcastScreen` — Admin message composer with severity selector
- `MessagesScreen` — Stream-driven message inbox for all users

### New Widgets

- `AlertIndicator` — compact alert status badge
- `AlertLevelIndicator` — 4-tier color-coded alert bar
- `AnalyticsChart` — fl_chart wrapper with axis labels and tooltips
- `LogoutButton` — reusable logout action
- `MessageCard` — severity-colored broadcast message tile
- `RiverStatusCard` — main river status summary card
- `WaterLevelGauge` — visual percentage fill gauge

---

## [Feature] — Admin Dashboard UI

- Added Official Dashboard wireframe and UI specification
- Documented evacuation coordination components
- Added flood risk zone and evacuation center layouts
- Updated usage documentation

---

## [Feature] — Splash Screen + Login + Admin Navigation

- `SplashScreen` with fade-in animation and logo; auto-navigates to login after 2 s
- `LoginScreen` with email/password validation and role-based routing
- `AdminShellScreen` with bottom navigation (Dashboard, Analytics, Broadcast, Messages, Logout)
- `AdminDashboardView` with river status card, statistics grid, and sensor info
- `UserDashboardView` with live water level, alert indicator, and history graph
- `UserShellScreen` with navigation (Dashboard, Messages, Logout)
- Assets: `assets/images/logo.png` added to splash screen

---

## [Init] — Project Scaffold

- Initial Flutter project created
- Project renamed to **RiverFlow Sentinel**
- README created and revised with project description, technologies, and alert level table
- Material 3 theme configured (Deep Blue + Aqua color scheme)
- Early resident (user) dashboard page started
