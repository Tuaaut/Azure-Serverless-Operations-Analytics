#!/usr/bin/env bash
set -euo pipefail

: "${SYNAPSE_SQL_ADMIN_PASSWORD:?Set SYNAPSE_SQL_ADMIN_PASSWORD before running.}"

resource_group="rg-azure-serverless-operations-analytics"
workspace="synw-aso-analytics-wora"
storage="stasoanalyticswora"
filesystem="raw"
location="southeastasia"

az synapse workspace create \
  --name "$workspace" \
  --resource-group "$resource_group" \
  --storage-account "$storage" \
  --file-system "$filesystem" \
  --sql-admin-login-user synadmin \
  --sql-admin-login-password "$SYNAPSE_SQL_ADMIN_PASSWORD" \
  --location "$location" \
  --tags project=Azure-Serverless-Operations-Analytics purpose=serverless-ops-analytics owner=woraphu cost_scope=project-demo

principal_id="$(az synapse workspace show \
  --name "$workspace" \
  --resource-group "$resource_group" \
  --query identity.principalId \
  -o tsv)"

storage_id="$(az storage account show \
  --name "$storage" \
  --resource-group "$resource_group" \
  --query id \
  -o tsv)"

az role assignment create \
  --assignee-object-id "$principal_id" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "$storage_id"

