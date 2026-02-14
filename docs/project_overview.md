# Project Overview

## Project Name

RiverFlow: IoT-Based River Water Level Monitoring System

## Description

RiverFlow Sentinel is a specialized IoT solution designed for precise river water level monitoring to provide early flood warnings. The system uses submersible ultrasonic and float sensors deployed at critical points along rivers to deliver real-time water level measurements with millimeter accuracy.

## Technologies Used

- C++ (IoT firmware)
- Flutter (Mobile app)
- Dart (App logic)
- IoT (Sensors)
- Git & GitHub (Version control)

## Features

- Real-Time River Monitoring
- Multi-Tier Alert System

## Alert Levels

| Status | Level    | Description                              |
| ------ | -------- | ---------------------------------------- |
| 🟢     | NORMAL   | Below 30% capacity                       |
| 🟡     | ADVISORY | 31% – 60% capacity                       |
| 🟠     | WARNING  | 61% – 80% capacity, prepare to evacuate  |
| 🔴     | DANGER   | Above 80% capacity, evacuate immediately |

---

Refer to the other documentation files for API, architecture, setup, usage, contributing, and changelog details.
