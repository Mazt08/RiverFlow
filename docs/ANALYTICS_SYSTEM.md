# River Analytics System

## Overview

RiverFlow Sentinel provides historical analytics to help admins and communities understand trend behavior, surge patterns, and flood risk progression.

## Data Collection Model

- Sensor data is produced every **5 seconds** in production flow.
- Each record is stored in `river_data/{record_id}`.
- Core analytics fields:
  - `waterLevel`
  - `percentage`
  - `alertLevel`
  - `timestamp`

## Analytics Views

The app presents selectable analytics intervals:

- **Today**
- **Week**
- **Month**
- **Year**

## Chart Visualization

- Built with `fl_chart` line chart components.
- Typical visuals include:
  - water level over time
  - threshold overlays (safe/monitor/prepare/evacuate)
  - optional moving averages

## Aggregation Strategy

To keep charts readable and performant, RiverFlow Sentinel applies interval-based aggregation:

- **Day** → raw sensor data (5-second points)
- **Week** → hourly average
- **Month** → daily average
- **Year** → weekly average

This reduces noise and improves trend comprehension while preserving meaningful signal.

## Suggested Aggregation Pipeline

1. Query records by time window.
2. Bucket records by interval granularity.
3. Compute summary metrics per bucket:
   - average water level
   - min/max level
   - dominant alert level
4. Sort by time ascending.
5. Bind to chart series and labels.

## Performance Considerations

- Use indexed queries on `timestamp`.
- Consider pre-aggregation jobs for large datasets.
- Cache recent analytics locally for fast tab switching.
- Use pagination/windowed loading for year-scale views.

## Alert Analytics

Beyond visual trends, analytics can expose:

- number of threshold crossings
- duration in each alert level
- peak level within selected range
- rise-rate acceleration events

## Operational Outcome

Analytics helps admins justify advisories, improve evacuation timing, and support data-backed disaster preparedness planning.
