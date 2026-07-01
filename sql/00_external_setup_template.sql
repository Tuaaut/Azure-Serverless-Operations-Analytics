-- Synapse Serverless SQL setup template.
-- Run inside the Synapse serverless SQL endpoint after the workspace exists.

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<replace-with-strong-password>';

CREATE DATABASE SCOPED CREDENTIAL adls_credential
WITH IDENTITY = 'Managed Identity';

CREATE EXTERNAL DATA SOURCE qr_lake
WITH (
    LOCATION = 'https://stasoanalyticswora.dfs.core.windows.net/raw',
    CREDENTIAL = adls_credential
);

CREATE EXTERNAL FILE FORMAT parquet_format
WITH (
    FORMAT_TYPE = PARQUET
);
