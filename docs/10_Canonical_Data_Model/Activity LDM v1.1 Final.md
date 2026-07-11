# Activity LDM v1.1 Final

## Position

One activity = one record.

`activity` is the core activity-level fact table. It stores activity-level Raw, Manual, and Reference observations.

Derived and Analysis data are excluded by default according to:

- `Metadata Design Standard v1.0` Rule 06: Derived Data Is Not Core Fact Data
- `Metadata Design Standard v1.0` Rule 07: Analysis Output Stays Out of Core Facts

## Design Philosophy

`activity` records what happened during one activity.

It stores:

- Raw observations
- Manual inputs
- Reference links
- Stable activity-level summaries

It does not store:

- Derived metrics
- Analysis outputs
- Coaching decisions
- ETL/import workflow state

## Schema

### Identity

```text
id
fit_sha256
garmin_activity_id
```

### Source

```text
excel_schema_version
source_file_name
data_source
```

### Activity

```text
activity_start_time
activity_type
activity_name
distance_km
duration_sec
workout_type_id
shoe_id
```

### Environment

```text
temperature_c
humidity_pct
wind_speed_mps
wind_direction_deg
weather_description
```

### Performance

```text
max_hr
avg_hr
critical_power_w
training_effect_aerobic
training_effect_anaerobic
training_load
recovery_time_hr
stamina_start_pct
stamina_end_pct
```

### Running Economy

```text
avg_cadence_spm
avg_stride_length_mm
avg_gct_ms
avg_vertical_oscillation_mm
avg_vertical_ratio_pct
```

### Subjective

```text
garmin_feeling
garmin_perceived_effort
nutrition
notes
```

### System

```text
created_at
updated_at
```

## Excluded Fields

| Field | Reason | Replacement |
|---|---|---|
| avg_pace_sec_per_km | Lifecycle = Derived. It is calculated from `duration_sec` and `distance_km`. | View / query |
| import_batch_id | ETL / System layer, not core activity domain. | Future `import_batch` system model |

## Derived View Fields

These fields may be exposed by views or query layer:

| Field | Formula |
|---|---|
| avg_pace_sec_per_km | `ROUND(duration_sec * 1.0 / distance_km)` |

## Source Naming Note

`source_file_name` stores the original FIT file name.

`data_source` should describe the source system or source type, such as `FIT`, `Garmin Connect`, `Manual`, or future source labels.

This naming should be finalized during SQLite Physical Model design.

## Metadata Updates Required Before SQLite

The following items must be added to `Running Analytics Metadata Repository v1.1` before SQLite schema generation:

| Data Item | SQLite Field | Reason |
|---|---|---|
| Avg HR | avg_hr | Present in Activity LDM v1.1 and FIT session data |
| Created At | created_at | System metadata |
| Updated At | updated_at | System metadata |

## Compliance

Validated against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `LDM Validation Round 1 - activity`

Status: Final

