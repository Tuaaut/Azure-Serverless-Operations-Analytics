# Validation Results

Last validated: 2026-07-01 Bangkok time.

## Synapse Serverless SQL

Database: `aso_analytics`

| Object | Row count |
|---|---:|
| `silver_qr_printing.fact_print_event` | 240 |
| `silver_qr_printing.fact_machine_telemetry_minute` | 1440 |
| `silver_qr_printing.fact_machine_log` | 59 |
| `gold_qr_printing.hourly_kpi_summary` | 24 |
| `gold_qr_printing.machine_health_summary` | 24 |
| `gold_qr_printing.downtime_fault_summary` | 20 |

Sample Gold query returned rows from `gold_qr_printing.hourly_kpi_summary`.

## Azure Data Factory

Pipeline: `pl_copy_raw_sample_to_curated`

Run ID:

```text
34a0c724-6e85-400b-9957-839ee23a0fef
```

Status: `Succeeded`

Activity:

| Activity | Status |
|---|---|
| `CopyRawSampleToCurated` | `Succeeded` |

Curated output:

```text
abfss://curated@stasoanalyticswora.dfs.core.windows.net/qr_printing/business_date=2026-06-30/machine_api_response.json
```

Confirmed size: `458408` bytes.
