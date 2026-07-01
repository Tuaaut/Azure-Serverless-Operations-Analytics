-- Synapse Serverless SQL Silver views over raw QR printing JSON.
-- Run after sql/00_external_setup_template.sql.

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver_qr_printing')
    EXEC('CREATE SCHEMA silver_qr_printing');
GO

CREATE OR ALTER VIEW silver_qr_printing.raw_payload AS
SELECT payload_json
FROM OPENROWSET(
    BULK 'qr_printing/business_date=*/machine_api_response.json',
    DATA_SOURCE = 'qr_lake',
    FORMAT = 'CSV',
    FIELDQUOTE = '0x0b',
    FIELDTERMINATOR = '0x0b',
    ROWTERMINATOR = '0x0b'
) WITH (
    payload_json varchar(max)
) AS source_file;
GO

CREATE OR ALTER VIEW silver_qr_printing.fact_print_event AS
SELECT
    event_id,
    CAST(event_ts AS datetime2) AS event_ts,
    CAST(event_ts AS date) AS event_date,
    machine_id,
    product_id,
    product_name,
    qr_code,
    print_status,
    CAST(qr_read_success AS bit) AS qr_read_success,
    CAST(is_reject AS bit) AS is_reject,
    CAST(qr_grade_score AS float) AS qr_grade_score,
    CAST(position_error_mm AS float) AS position_error_mm
FROM silver_qr_printing.raw_payload
CROSS APPLY OPENJSON(payload_json, '$.print_events')
WITH (
    event_id varchar(100) '$.event_id',
    event_ts varchar(40) '$.event_ts',
    machine_id varchar(50) '$.machine_id',
    product_id varchar(50) '$.product_id',
    product_name varchar(200) '$.product_name',
    qr_code varchar(200) '$.qr_code',
    print_status varchar(50) '$.print_status',
    qr_read_success bit '$.qr_read_success',
    is_reject bit '$.is_reject',
    qr_grade_score float '$.qr_grade_score',
    position_error_mm float '$.position_error_mm'
) AS event_rows;
GO

CREATE OR ALTER VIEW silver_qr_printing.fact_machine_telemetry_minute AS
SELECT
    CAST(telemetry_ts AS datetime2) AS telemetry_ts,
    DATEADD(minute, DATEDIFF(minute, 0, CAST(telemetry_ts AS datetime2)), 0) AS telemetry_minute,
    machine_id,
    CAST(actual_speed_cpm AS float) AS actual_speed_cpm,
    CAST(planned_speed_cpm AS float) AS planned_speed_cpm,
    CAST(printhead_temp_c AS float) AS printhead_temp_c,
    CAST(vibration_mm_s AS float) AS vibration_mm_s,
    CAST(ink_used_ml AS float) AS ink_used_ml
FROM silver_qr_printing.raw_payload
CROSS APPLY OPENJSON(payload_json, '$.machine_telemetry')
WITH (
    telemetry_ts varchar(40) '$.telemetry_ts',
    machine_id varchar(50) '$.machine_id',
    actual_speed_cpm float '$.actual_speed_cpm',
    planned_speed_cpm float '$.planned_speed_cpm',
    printhead_temp_c float '$.printhead_temp_c',
    vibration_mm_s float '$.vibration_mm_s',
    ink_used_ml float '$.ink_used_ml'
) AS telemetry_rows;
GO

CREATE OR ALTER VIEW silver_qr_printing.fact_machine_log AS
SELECT
    log_id,
    CAST(log_ts AS datetime2) AS log_ts,
    machine_id,
    severity,
    fault_code,
    message,
    CAST(downtime_minutes AS float) AS downtime_minutes
FROM silver_qr_printing.raw_payload
CROSS APPLY OPENJSON(payload_json, '$.machine_logs')
WITH (
    log_id varchar(100) '$.log_id',
    log_ts varchar(40) '$.log_ts',
    machine_id varchar(50) '$.machine_id',
    severity varchar(50) '$.severity',
    fault_code varchar(100) '$.fault_code',
    message varchar(500) '$.message',
    downtime_minutes float '$.downtime_minutes'
) AS log_rows;
GO
