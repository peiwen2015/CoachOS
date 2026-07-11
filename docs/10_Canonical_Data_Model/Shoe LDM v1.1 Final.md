# Shoe LDM v1.1 Final

## Position

One running shoe = one record.

`shoe` is a dimension table for shoe static attributes and lifecycle.

It is referenced by `activity.shoe_id` and supports mileage tracking, retirement management, and future shoe-efficiency analysis through joins and views.

## Design Philosophy

`shoe` describes what the shoe is.

It stores:

- Stable shoe identity
- Static attributes
- Basic specifications
- Lifecycle information
- Manual notes

It does not store:

- Activity performance metrics
- Running dynamics metrics
- Efficiency scores
- Coaching strategy
- Training recommendations

All shoe efficiency, heart rate, power, running dynamics, Stamina, and performance analysis should be calculated from `activity`, `kilometer_split`, and future analysis views.

## Schema

### Identity

```text
id
shoe_code
```

### Basic

```text
brand
model
nickname
category
```

### Specification

```text
size_us
width
drop_mm
weight_g
```

### Lifecycle

```text
purchase_date
first_run_date
retire_date
retire_target_distance_km
retire_actual_distance_km
is_active
```

### Notes

```text
notes
```

### System

```text
created_at
updated_at
```

## Field Notes

### shoe_code

`shoe_code` is the stable human-readable business key.

Examples:

```text
boston_13_green
rebel_v5_white
nimbus_28_wide
```

Rules:

- lowercase
- snake_case
- unique
- stable after creation

Display names may change later, but `shoe_code` should not change unless correcting a mistake.

### category

`category` is a controlled vocabulary describing the shoe's general usage category.

Recommended v1 values:

```text
Recovery
Daily Trainer
Tempo
Long Run
Race
Walking
Trail
```

This is not a coaching default. It describes the shoe, not what today's workout should be.

### is_active

`is_active` indicates whether the shoe is currently in rotation.

It replaces an open-ended `status` field in v1.1 to keep lifecycle management simple and consistent.

### first_run_date and retire_actual_distance_km

These are nullable manual lifecycle fields.

When activity history is complete, observed values can also be calculated by views:

- `observed_first_run_date`
- `observed_last_run_date`
- `observed_total_distance_km`

Manual lifecycle fields are still useful when historical data is incomplete.

## Excluded Fields

| Field | Reason | Replacement |
|---|---|---|
| status | Open-ended states are not needed for v1 and can become inconsistent | `is_active` |
| rotation_order | Context-dependent coaching/rotation strategy | Future planning or AI Coach layer |
| default_workout | Context-dependent coaching strategy and can change by training cycle | Future planning or AI Coach layer |
| avg_hr | Performance metric derived from activities using the shoe | View / query |
| avg_power | Performance metric derived from activities using the shoe | View / query |
| avg_gct | Running dynamics metric derived from activity/split data | View / query |
| efficiency_score | Analysis output | Analysis layer |
| stack_height | Useful product spec, but not required for v1 analytics | Future metadata item |
| foam_type | Useful product spec, but not required for v1 analytics | Future metadata item |
| plate_type | Useful product spec, but not required for v1 analytics | Future metadata item |
| purchase_price | Not needed for current running intelligence workflows | Future metadata item |
| store | Not needed for current running intelligence workflows | Future metadata item |
| color | Covered by nullable `nickname` for v1 | Future explicit field if needed |

## Derived View Fields

These fields may be exposed by views or query layer:

| Field | Formula / Source |
|---|---|
| total_distance_km | `SUM(activity.distance_km)` grouped by `shoe_id` |
| run_count | `COUNT(activity.id)` grouped by `shoe_id` |
| observed_first_run_date | `MIN(activity.activity_start_time)` grouped by `shoe_id` |
| observed_last_run_date | `MAX(activity.activity_start_time)` grouped by `shoe_id` |
| avg_hr | `AVG(activity.avg_hr)` grouped by `shoe_id` |
| avg_power_w | `AVG(kilometer_split.avg_power_w)` through activity join |
| avg_gct_ms | `AVG(kilometer_split.avg_gct_ms)` through activity join |

## Compliance

Validated against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `LDM Validation Round 1 - shoe`

Architecture DoD:

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Final
