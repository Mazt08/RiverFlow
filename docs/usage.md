# Usage Guide

---

## App Flow Overview

```
App Start
   ?
Splash Screen (2 seconds)
   ?
Login Screen
   ?  (credentials determine role)
Admin Role  ?  Dashboard / Analytics / Broadcast / Messages / Logout
Resident    ?  Dashboard / Messages / Logout
```

---

## Login

Enter your email and password on the login screen. The app validates:
- Both fields must be filled
- Email must be a valid format (name@domain.com)

On success, you are routed automatically to your role''s dashboard.

**Demo credentials** (no backend required):

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@riverflow.app | riverflow123 |
| Resident | user@riverflow.app | riverflow123 |

---

## Admin Dashboard

File: `lib/screens/admin_dashboard.dart`

The admin dashboard gives a real-time overview of the monitored river and sensor system.

**River Status Card** — station name, current water level in metres, percentage of capacity, alert level badge, rise rate (m/hr), sensor online/offline, last updated time. Pull down to refresh manually.

**System Statistics** — accuracy, false alert rate, uptime, and total data points in a responsive grid.

**Sensor Information** — hardware and connection details for the deployed IoT sensor.

---

## Analytics Screen

File: `lib/screens/analytics_screen.dart`

Displays a water-level line chart with selectable time ranges: **Today**, **Week**, **Month**, **Year**. Shows peak, current, and average level summaries above the chart.

---

## Broadcast Screen (Admin only)

File: `lib/screens/broadcast_screen.dart`

Compose and send emergency messages to all residents:
1. Type your message
2. Select severity: Info, Advisory, Warning, or Emergency
3. Tap Send Broadcast

The message appears immediately in the Messages screen for all users.

---

## Messages Screen

File: `lib/screens/messages_screen.dart`

Available to both admins and residents. Shows a live stream of all broadcast messages, newest first — severity-colored header, title, body, and timestamp. Shows an empty state when no messages exist.

---

## Resident Dashboard

File: `lib/screens/user_dashboard.dart`

Simplified view for residents: current water level and alert status, color-coded alert level indicator, mini line graph of the last 20 readings, advisory text, and last updated time. Pull down to refresh.

---

## Alert Levels Reference

| Color | Level | Water Capacity | Action |
|-------|-------|---------------|--------|
| Green | SAFE | Below 30% | Normal conditions |
| Yellow | MONITOR | 30-60% | Stay informed |
| Orange | PREPARE TO EVACUATE | 60-80% | Get ready to leave |
| Red | EVACUATE NOW | Above 80% | Leave immediately |

---

## Logout

Tap **Logout** in the navigation bar/rail. A confirmation dialog appears — tap **Logout** to confirm and return to the login screen.
