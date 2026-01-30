# -condition_monitoring
# Industrial Pump Condition Monitoring System (OT/IT Convergence)

##  Project Overview

This project demonstrates a realistic industrial condition monitoring system similar to what is used in manufacturing plants, energy systems, and process industries.

The system collects pump sensor data (vibration, temperature, motor current), stores it in a SQL database, and performs condition monitoring & alert detection using SQL queries.

 Problem Statement (Industry Context)

In real industries:

* Pumps and motors run continuously
* Sudden failures cause production loss
* Faults usually start slowly (vibration rise, temperature rise)
* Engineers cannot manually watch sensor values all the time

Goal: Detect early warning signs before equipment failure.

Solution Summary

This system:

* Collects sensor data automatically
* Stores time-series data safely
* Analyzes trends and rate-of-change
* Generates alerts for abnormal conditions

The system **supports engineers** in decision-making (human-in-the-loop), which aligns with modern **Industry 4.0 / 5.0 practices.

Technology Stack

| Layer              | Technology              |
| ------------------ | ----------------------- |
| Sensor Simulation  | Python                  |
| Data Transport     | REST API (Flask) / MQTT |
| Messaging (IIoT)   | Mosquitto MQTT          |
| Backend Processing | Python                  |
| Database           | MySQL                   |
| Analytics          | SQL (Window Functions)  |
| OS                 | Windows / Linux         |

System Architecture


Pump Sensor (Simulated)
        ↓
   API / MQTT Gateway
        ↓
 Python Data Ingestion
        ↓
   SQL Database (Historian)
        ↓
 Condition Monitoring Logic
        ↓
     Alert Generation

Database Schema

sensor_readings

Stores raw time-series sensor data.

| Column          | Description     |
| --------------- | --------------- |
| asset_id        | Equipment ID    |
| vibration_mm_s  | Vibration value |
| temperature_c   | Temperature     |
| motor_current_a | Motor current   |
| reading_time    | Timestamp       |

alert_log

Stores generated alerts.

| Column     | Description        |
| ---------- | ------------------ |
| asset_id   | Equipment ID       |
| alert_type | WARNING / CRITICAL |
| message    | Alert description  |
| alert_time | Alert timestamp    |

 Data Flow Explanation

Option 1: REST API (Flask)

* Flask exposes sensor data through an API endpoint
* Python ingestion service requests data periodically
* Data is inserted into MySQL

Option 2: MQTT (Recommended for IIoT)

* Sensor publishes data to MQTT topic
* Python subscriber listens continuously
* Each message is stored in MySQL


Condition Monitoring Logic (SQL)

Latest Sensor Reading

```sql
SELECT *
FROM sensor_readings
ORDER BY reading_time DESC
LIMIT 1;
```

### Rate-of-Change Detection

```sql
SELECT
  asset_id,
  reading_time,
  vibration_mm_s -
  LAG(vibration_mm_s) OVER (
    PARTITION BY asset_id
    ORDER BY reading_time
  ) AS vibration_change
FROM sensor_readings;
```

### Moving Average (Trend Analysis)

```sql
SELECT
  asset_id,
  reading_time,
  AVG(vibration_mm_s) OVER (
    PARTITION BY asset_id
    ORDER BY reading_time
    ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
  ) AS moving_avg_vibration
FROM sensor_readings;
```

---

 Alert Generation

Sudden Vibration Increase Alert

```sql
INSERT INTO alert_log (asset_id, alert_type, message, alert_time)
SELECT
  asset_id,
  'WARNING',
  'Sudden vibration increase detected',
  NOW()
FROM (
  SELECT
    asset_id,
    vibration_mm_s -
    LAG(vibration_mm_s) OVER (
      PARTITION BY asset_id ORDER BY reading_time
    ) AS diff
  FROM sensor_readings
) t
WHERE diff > 1.5;

Future Enhancements

* Add multiple assets
* Add health score calculation
* Add simple ML anomaly detection
* Visual dashboard (Grafana / Power BI)


Author

Instrumentation & Control Engineering | Python | SQL | Linux | IIoT
