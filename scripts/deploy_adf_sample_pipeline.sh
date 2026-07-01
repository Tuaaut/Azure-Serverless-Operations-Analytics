#!/usr/bin/env bash
set -euo pipefail

subscription_id="$(az account show --query id -o tsv)"
resource_group="rg-azure-serverless-operations-analytics"
factory="adf-aso-analytics-wora"
base="https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.DataFactory/factories/${factory}"
api="api-version=2018-06-01"

az rest --method put --uri "${base}/linkedservices/ls_adls_aso_analytics?${api}" --body @adf/linked_service_adls.json --output none
az rest --method put --uri "${base}/datasets/ds_raw_qr_sample_binary?${api}" --body @adf/dataset_raw_sample_binary.json --output none
az rest --method put --uri "${base}/datasets/ds_curated_qr_sample_binary?${api}" --body @adf/dataset_curated_sample_binary.json --output none
az rest --method put --uri "${base}/pipelines/pl_copy_raw_sample_to_curated?${api}" --body @adf/pipeline_copy_raw_sample_to_curated.json --output none

az rest --method post --uri "${base}/pipelines/pl_copy_raw_sample_to_curated/createRun?${api}" --body '{}' --query runId -o tsv

