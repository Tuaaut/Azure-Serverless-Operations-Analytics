SELECT 'fact_print_event' AS object_name, COUNT_BIG(*) AS row_count
FROM silver_qr_printing.fact_print_event;
GO

SELECT 'fact_machine_telemetry_minute' AS object_name, COUNT_BIG(*) AS row_count
FROM silver_qr_printing.fact_machine_telemetry_minute;
GO

SELECT 'fact_machine_log' AS object_name, COUNT_BIG(*) AS row_count
FROM silver_qr_printing.fact_machine_log;
GO

SELECT 'hourly_kpi_summary' AS object_name, COUNT_BIG(*) AS row_count
FROM gold_qr_printing.hourly_kpi_summary;
GO

SELECT 'machine_health_summary' AS object_name, COUNT_BIG(*) AS row_count
FROM gold_qr_printing.machine_health_summary;
GO

SELECT 'downtime_fault_summary' AS object_name, COUNT_BIG(*) AS row_count
FROM gold_qr_printing.downtime_fault_summary;
GO

SELECT TOP 5
    production_hour,
    machine_id,
    items_processed,
    reject_rate_pct,
    qr_read_rate_pct,
    quality_pct
FROM gold_qr_printing.hourly_kpi_summary
ORDER BY production_hour;
GO

