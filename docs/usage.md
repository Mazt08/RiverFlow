# Usage Guide

## Official Dashboard UI

The Official Dashboard is the main interface for barangay officials to monitor river levels, issue alerts, and coordinate evacuations. Below is a wireframe and description of the UI components:

### Wireframe Overview

```
---------------------------------------------------
| Official                                        |
|-------------------------------------------------|
| Barangay Official Dashboard                     |
| All Monitoring Stations                         |
| +-------------------+   +-------------------+   |
| | Upstream Station  |   | Midstream Station |   |
| | Level, Alert, etc |   | Level, Alert, etc |   |
| +-------------------+   +-------------------+   |
| +-------------------+                           |
| | Downstream Station|                           |
| | Level, Alert, etc |                           |
| +-------------------+                           |
|-------------------------------------------------|
| [Issue Evacuation Order] [Send SMS Blast]       |
| [Activate Sirens]                               |
|-------------------------------------------------|
| Evacuation Coordination (map, centers, routes)  |
|-------------------------------------------------|
| Flood Risk Zones (A, B, C, D)                   |
| Evacuation Centers (list, capacity, distance)   |
| Safe Routes (status)                            |
|-------------------------------------------------|
| Component Library (alert cards, buttons, etc)   |
---------------------------------------------------
```

### UI Components

- **Monitoring Station Cards**: Show station name, ID, alert status, water level, trend, Arduino status, battery, and last update.
- **Action Buttons**: For issuing evacuation orders, sending SMS, and activating sirens.
- **Evacuation Coordination**: Map with evacuation centers, safe routes, and danger zones.
- **Flood Risk Zones**: List of zones with risk level and evacuation status.
- **Evacuation Centers**: List with capacity and distance.
- **Safe Routes**: List with status (open, congested, closed).
- **Component Library**: Alert cards, emergency buttons, dashboard layouts.

See `lib/official_dashboard.dart` for the full Flutter implementation.
