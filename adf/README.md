# Azure Data Factory

ADF is used only for orchestration and movement.

Initial pipeline:

```text
Manual trigger
-> copy sample JSON from ADLS raw
-> land the same file in ADLS curated
```

Default schedule: manual only.

Avoid Mapping Data Flows until needed; they add more compute cost and setup.
