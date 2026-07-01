#!/usr/bin/env bash
set -euo pipefail

subscription_id="$(az account show --query id -o tsv)"
from_date="$(date -u +%Y-%m-01)"
to_date="$(date -u +%Y-%m-%d)"

body="{
    \"type\": \"ActualCost\",
    \"timeframe\": \"Custom\",
    \"timePeriod\": {\"from\": \"${from_date}\", \"to\": \"${to_date}\"},
    \"dataset\": {
      \"granularity\": \"None\",
      \"aggregation\": {\"totalCost\": {\"name\": \"PreTaxCost\", \"function\": \"Sum\"}},
      \"filter\": {\"dimensions\": {\"name\": \"ResourceGroupName\", \"operator\": \"In\", \"values\": [\"rg-azure-serverless-operations-analytics\"]}},
      \"grouping\": [{\"type\": \"Dimension\", \"name\": \"ServiceName\"}]
    }
  }"

for attempt in 1 2 3; do
  if az rest \
    --method post \
    --uri "https://management.azure.com/subscriptions/${subscription_id}/providers/Microsoft.CostManagement/query?api-version=2024-08-01" \
    --body "$body" \
    --output table; then
    exit 0
  fi
  sleep 10
done

echo "Cost query still throttled by Azure Cost Management. Retry later." >&2
exit 1
