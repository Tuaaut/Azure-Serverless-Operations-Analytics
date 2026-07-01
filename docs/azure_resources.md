# Azure Resources

## Active Resources

| Resource | Name | Purpose | Cost note |
|---|---|---|---|
| Resource group | `rg-azure-serverless-operations-analytics` | Project cost boundary | No direct cost |
| Storage account | `stasoanalyticswora` | ADLS Gen2 lake storage | Small storage cost |
| ADLS filesystem | `raw` | Raw JSON landing zone | Storage cost only |
| ADLS filesystem | `curated` | Curated output target | Storage cost only |
| Data Factory | `adf-aso-analytics-wora` | Pipeline orchestration | Pay when activities run |
| Synapse workspace | `synw-aso-analytics-wora` | Serverless SQL query layer | Serverless SQL charges only when queries scan data |

## Tags

All created project resources use:

```text
project=Azure-Serverless-Operations-Analytics
purpose=serverless-ops-analytics
owner=woraphu
cost_scope=project-demo
```

Use the resource group or `project` tag in Azure Cost Management to isolate this project.

## Uploaded Starter Data

```text
abfss://raw@stasoanalyticswora.dfs.core.windows.net/qr_printing/business_date=2026-06-30/machine_api_response.json
```

Confirmed size: `458408` bytes.

## Synapse Endpoints

```text
Serverless SQL endpoint:
synw-aso-analytics-wora-ondemand.sql.azuresynapse.net

Synapse Studio:
Open `synw-aso-analytics-wora` from the Azure portal.
```

The Synapse workspace managed identity has `Storage Blob Data Contributor` on `stasoanalyticswora`.

The SQL admin password was generated only for workspace creation and was not saved in this repo. Reset it in Azure if SQL password login is needed later.

## Data Factory Pipeline

| ADF object | Name |
|---|---|
| Linked service | `ls_adls_aso_analytics` |
| Source dataset | `ds_raw_qr_sample_binary` |
| Sink dataset | `ds_curated_qr_sample_binary` |
| Pipeline | `pl_copy_raw_sample_to_curated` |

The first run succeeded and copied the sample JSON from `raw` to `curated`.
