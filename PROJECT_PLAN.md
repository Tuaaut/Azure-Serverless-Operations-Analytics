# Azure Serverless Operations Analytics

## Purpose

Build a low-cost Azure-native analytics demo for QR printing and machine telemetry operations.

The main goal is a consistent operational Gold layer: each platform can process data differently, but the final business outputs should keep the same meaning and column names.

## Architecture

```text
Source API / sample telemetry JSON
-> Azure Data Factory
-> ADLS Gen2 raw files
-> ADLS Gen2 curated files
-> Synapse Serverless SQL external views
-> Gold operational views
```

## Product Roles

| Product | Role in this project |
|---|---|
| Azure Data Factory | Pipeline orchestration and file movement |
| ADLS Gen2 | Raw and curated data lake storage |
| Synapse Serverless SQL | SQL query layer over lake files |

## Cost Model

This design avoids always-on clusters.

| Component | Cost behavior | Pause needed? |
|---|---|---|
| Azure Data Factory | Pay when pipeline activities run | No, control schedule |
| ADLS Gen2 | Ongoing storage cost | No |
| Synapse Serverless SQL | Pay by data scanned when queries run | No |

Avoid these unless explicitly needed:

- Synapse Spark Pool
- Synapse Dedicated SQL Pool
- Always-on analytics cluster
- VM
- Always-on App Service or Container Apps

## Reused Business Schema

The project uses three operational source entities:

| Source entity | Meaning |
|---|---|
| `print_events` | QR print-level production and quality events |
| `machine_telemetry` | Minute-level machine speed, temperature, vibration, and ink usage |
| `machine_logs` | Warning/fault events and downtime |

## Layer Contract

| Layer | Azure serverless implementation |
|---|---|
| Raw | JSON files in ADLS Gen2 |
| Bronze | Raw JSON landing files |
| Silver | Cleaned Synapse Serverless SQL views |
| Gold | Business-ready Synapse Serverless SQL views |

## Gold View Contract

The project exposes these standardized Gold views:

| Gold view | Purpose |
|---|---|
| `gold_qr_printing.hourly_kpi_summary` | Production, reject rate, QR read rate, quality |
| `gold_qr_printing.machine_health_summary` | Speed, performance, temperature, vibration, ink usage |
| `gold_qr_printing.downtime_fault_summary` | Faults, warnings, downtime |

## Gold KPI Definitions

### `hourly_kpi_summary`

| Column | Meaning |
|---|---|
| `production_hour` | Hour bucket |
| `machine_id` | Machine identifier |
| `items_processed` | Count of print events |
| `printed_items` | Count where `print_status = 'PRINTED'` |
| `reject_count` | Count where `is_reject = true` |
| `reject_rate_pct` | Reject count / items processed |
| `qr_read_success_count` | Count where QR read succeeded |
| `qr_read_fail_count` | Count where QR read failed |
| `qr_read_rate_pct` | QR read success count / items processed |
| `avg_qr_grade_score` | Average QR score |
| `avg_position_error_mm` | Average QR position error |
| `quality_pct` | Successful QR reads with no reject / items processed |

### `machine_health_summary`

| Column | Meaning |
|---|---|
| `production_hour` | Hour bucket |
| `machine_id` | Machine identifier |
| `avg_actual_speed_cpm` | Average actual speed |
| `avg_planned_speed_cpm` | Average planned speed |
| `performance_pct` | Actual speed / planned speed |
| `avg_printhead_temp_c` | Average printhead temperature |
| `avg_vibration_mm_s` | Average vibration |
| `ink_ml_per_1000_prints` | Ink usage normalized per estimated output |

### `downtime_fault_summary`

| Column | Meaning |
|---|---|
| `production_hour` | Hour bucket |
| `machine_id` | Machine identifier |
| `fault_count` | Count where severity is `FAULT` |
| `warning_count` | Count where severity is `WARNING` |
| `downtime_minutes` | Sum of downtime minutes |

## Build Plan

1. Create the repo skeleton and project plan. Done.
2. Reuse the existing QR printing sample JSON shape. Done.
3. Land raw JSON under ADLS path like `raw/qr_printing/business_date=YYYY-MM-DD/`. Done for starter sample.
4. Add an ADF pipeline that copies source JSON to ADLS. Done for starter raw-to-curated sample.
5. Keep curated Parquet optional until data volume justifies it.
6. Create Synapse Serverless SQL external data source and file format. Done.
7. Create Silver and Gold views with the same business contract. Done and validated.
8. Validate row counts and KPI values. Done.
9. Document cost controls and resource names. Done.

## First Implementation Scope

Start small:

- One sample daily JSON file.
- One manual ADF pipeline.
- One ADLS raw container and one curated path.
- Three Gold views.
- No Spark, no Dedicated SQL Pool, no always-on compute.

## Validation Checklist

| Check | Expected result |
|---|---|
| Raw file landed | JSON exists in ADLS raw path |
| Silver view works | Clean rows query successfully |
| Gold views work | Three business-ready views return rows |
| Gold contract matches | Column names keep stable business meaning for reporting |
| Cost risk controlled | No Spark pool, Dedicated SQL Pool, VM, or always-on app |

## Current Azure Names

| Resource | Name |
|---|---|
| Resource group | `rg-azure-serverless-operations-analytics` |
| Storage account | `stasoanalyticswora` |
| Raw filesystem | `raw` |
| Curated filesystem | `curated` |
| Data Factory | `adf-aso-analytics-wora` |
| Synapse workspace | `synw-aso-analytics-wora` |
| Synapse Serverless SQL endpoint | `synw-aso-analytics-wora-ondemand.sql.azuresynapse.net` |
