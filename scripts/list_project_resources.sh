#!/usr/bin/env bash
set -euo pipefail

az resource list \
  --resource-group rg-azure-serverless-operations-analytics \
  --query "[].{name:name,type:type,location:location,tags:tags}" \
  --output table

