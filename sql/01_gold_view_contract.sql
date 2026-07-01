-- Dashboard-facing Synapse Serverless SQL view contract.
-- These names and columns define the standardized BI/reporting Gold layer.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold_qr_printing')
    EXEC('CREATE SCHEMA gold_qr_printing');
GO

CREATE OR ALTER VIEW gold_qr_printing.hourly_kpi_summary AS
SELECT
    DATEADD(hour, DATEDIFF(hour, 0, event_ts), 0) AS production_hour,
    machine_id,
    COUNT_BIG(*) AS items_processed,
    SUM(CASE WHEN print_status = 'PRINTED' THEN 1 ELSE 0 END) AS printed_items,
    SUM(CASE WHEN is_reject = 1 THEN 1 ELSE 0 END) AS reject_count,
    CAST(ROUND(100.0 * SUM(CASE WHEN is_reject = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT_BIG(*), 0), 2) AS decimal(10,2)) AS reject_rate_pct,
    SUM(CASE WHEN qr_read_success = 1 THEN 1 ELSE 0 END) AS qr_read_success_count,
    SUM(CASE WHEN qr_read_success = 0 THEN 1 ELSE 0 END) AS qr_read_fail_count,
    CAST(ROUND(100.0 * SUM(CASE WHEN qr_read_success = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT_BIG(*), 0), 2) AS decimal(10,2)) AS qr_read_rate_pct,
    CAST(ROUND(AVG(CAST(qr_grade_score AS float)), 2) AS decimal(10,2)) AS avg_qr_grade_score,
    CAST(ROUND(AVG(CAST(position_error_mm AS float)), 3) AS decimal(10,3)) AS avg_position_error_mm,
    CAST(ROUND(100.0 * SUM(CASE WHEN qr_read_success = 1 AND is_reject = 0 THEN 1 ELSE 0 END) / NULLIF(COUNT_BIG(*), 0), 2) AS decimal(10,2)) AS quality_pct
FROM silver_qr_printing.fact_print_event
GROUP BY DATEADD(hour, DATEDIFF(hour, 0, event_ts), 0), machine_id;
GO

CREATE OR ALTER VIEW gold_qr_printing.machine_health_summary AS
SELECT
    DATEADD(hour, DATEDIFF(hour, 0, telemetry_ts), 0) AS production_hour,
    machine_id,
    CAST(ROUND(AVG(CAST(actual_speed_cpm AS float)), 2) AS decimal(10,2)) AS avg_actual_speed_cpm,
    CAST(ROUND(AVG(CAST(planned_speed_cpm AS float)), 2) AS decimal(10,2)) AS avg_planned_speed_cpm,
    CAST(ROUND(100.0 * AVG(CAST(actual_speed_cpm AS float)) / NULLIF(AVG(CAST(planned_speed_cpm AS float)), 0), 2) AS decimal(10,2)) AS performance_pct,
    CAST(ROUND(AVG(CAST(printhead_temp_c AS float)), 2) AS decimal(10,2)) AS avg_printhead_temp_c,
    CAST(ROUND(AVG(CAST(vibration_mm_s AS float)), 3) AS decimal(10,3)) AS avg_vibration_mm_s,
    CAST(ROUND(1000.0 * SUM(CAST(ink_used_ml AS float)) / NULLIF(SUM(CAST(actual_speed_cpm AS float)), 0), 2) AS decimal(10,2)) AS ink_ml_per_1000_prints
FROM silver_qr_printing.fact_machine_telemetry_minute
GROUP BY DATEADD(hour, DATEDIFF(hour, 0, telemetry_ts), 0), machine_id;
GO

CREATE OR ALTER VIEW gold_qr_printing.downtime_fault_summary AS
SELECT
    DATEADD(hour, DATEDIFF(hour, 0, log_ts), 0) AS production_hour,
    machine_id,
    SUM(CASE WHEN severity = 'FAULT' THEN 1 ELSE 0 END) AS fault_count,
    SUM(CASE WHEN severity = 'WARNING' THEN 1 ELSE 0 END) AS warning_count,
    SUM(COALESCE(CAST(downtime_minutes AS float), 0)) AS downtime_minutes
FROM silver_qr_printing.fact_machine_log
GROUP BY DATEADD(hour, DATEDIFF(hour, 0, log_ts), 0), machine_id;
GO
