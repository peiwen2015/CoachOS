# Kilometer Split LDM v1.1 Final

## Position

One activity split = one record.

`kilometer_split` is the core split-level fact table. It stores raw split observations for each activity split.

Derived and Analysis data are excluded by default according to:

- `Metadata Design Standard v1.0` Rule 06: Derived Data Is Not Core Fact Data
- `Metadata Design Standard v1.0` Rule 07: Analysis Output Stays Out of Core Facts
- `ADR-005 Derived Pace via Views`

## Design Philosophy

`kilometer_split` records what happened within each split.

It stores:

- Split identity and parent activity reference
- Raw split distance and elapsed time
- Raw heart rate observations
- Raw power observations
- Raw running dynamics observations
- Raw elevation observations
- Nullable Garmin Stamina observations when available

It does not store:

- Derived pace metrics
- Analysis outputs
- Coaching decisions
- Research-only fields whose source is not confirmed

## Schema

### Identity

```text
id
activity_id
split_index
```

### Distance

```text
split_distance_m
```

### Time

```text
elapsed_time_sec
```

### Heart Rate

```text
avg_hr
max_hr
```

### Power

```text
avg_power_w
```

### Running Dynamics

```text
avg_cadence_spm
avg_stride_length_mm
avg_gct_ms
avg_vertical_ratio_pct
avg_vertical_oscillation_mm
```

### Elevation

```text
elevation_gain_m
elevation_loss_m
```

### Stamina

```text
stamina_start_pct
stamina_end_pct
```

### System

```text
created_at
updated_at
```

## Excluded Fields

| Field | Reason | Replacement |
|---|---|---|
| elapsed_pace_sec_per_km | Lifecycle = Derived. It is calculated from `elapsed_time_sec` and `split_distance_m`. | View / query |
| moving_time_sec | Source not confirmed; not currently parsed. | Future metadata/parser research |
| moving_pace_sec_per_km | Source not confirmed and depends on moving time. | Future metadata/parser research or view |
| gap_pace_sec_per_km | Source not confirmed as FIT Native or Garmin algorithm output. | Future metadata/parser research |
| potential_stamina_pct | Current parser does not clearly distinguish potential stamina at split level. | Future field mapping research |

## Derived View Fields

These fields may be exposed by views or query layer:

| Field | Formula |
|---|---|
| elapsed_pace_sec_per_km | `ROUND(elapsed_time_sec * 1000.0 / split_distance_m)` |
| avg_speed_mps | `split_distance_m * 1.0 / elapsed_time_sec` |

## Source Notes

- `elapsed_time_sec` maps to FIT lap timer/elapsed time used by the current parser.
- `elevation_gain_m` maps to FIT lap `total_ascent`.
- `elevation_loss_m` maps to FIT lap `total_descent`; parser/Excel alignment is still needed.
- `stamina_start_pct` and `stamina_end_pct` are nullable because split-level Stamina is available only for supported devices/activities.

## Compliance

Validated against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `LDM Validation Round 1 - kilometer_split`
- `ADR-005 Derived Pace via Views`

Architecture DoD:

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Final

