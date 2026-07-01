# Data Layout

Target ADLS layout:

```text
raw/
  qr_printing/
    business_date=YYYY-MM-DD/
      machine_api_response.json

curated/
  qr_printing/
    business_date=YYYY-MM-DD/
      machine_api_response.json
```

Curated Parquet is intentionally optional for this starter build. Add it when file volume grows enough that repeated raw JSON scans become wasteful.

Local starter sample:

```text
data/raw/qr_printing/business_date=2026-06-30/start_date=2026-06-30/machine_api_response.json
```
