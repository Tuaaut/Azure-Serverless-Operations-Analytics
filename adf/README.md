# Azure Data Factory

ADF is used only for orchestration and movement.

Initial pipeline:

```text
Manual trigger
-> copy sample/source JSON
-> land file in ADLS raw path
```

Default schedule: manual first, daily later.

Avoid Mapping Data Flows until needed; they add more compute cost and setup.

