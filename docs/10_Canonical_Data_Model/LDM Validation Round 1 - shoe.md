# LDM Validation Round 1 | shoe

## Purpose

Validate `Shoe LDM v1` against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`

The goal is to promote the draft shoe dimension into a production-ready canonical model while preserving the platform rule that dimensions describe what an entity is, not how it performed.

## Validation Criteria

1. Field exists in Metadata Repository.
2. Granularity is compatible with `shoe`.
3. Lifecycle is allowed in a dimension/reference table.
4. Data Type is consistent.
5. Required / Nullable is consistent.
6. Context-dependent defaults and performance metrics are excluded.

## Summary

`Shoe LDM v1` is valid as a dimension table after metadata backfill and a small scope tightening.

| Finding | Decision |
|---|---|
| Shoe fields were not fully represented in Metadata Repository | Added `SHOE-002` through `SHOE-017` |
| `shoe_code` is the stable business key | Keep as required unique code; do not rename to UID |
| `category` should not be free text | Keep as required controlled enum |
| `status` can grow into unclear states | Replace with required `is_active` boolean |
| `rotation_order` and `default_workout` are coaching strategy | Exclude from v1.1; revisit in AI Coach / planning layer |
| Shoe efficiency metrics are derived from activity and split data | Exclude from `shoe`; provide through views/analysis |
| `first_run_date` and `retire_actual_distance_km` can be derived from activity history | Keep as nullable manual lifecycle fields because historical data may be incomplete; derived observed values can be provided by views |

## Field Validation

| LDM Field | Metadata ID | Repository Field | Granularity | Lifecycle | Data Type | Required | Nullable | Validation Result | Decision |
|---|---|---|---|---|---|---|---|---|---|
| id | N/A | N/A | System | System | INTEGER | YES | NO | Physical surrogate PK | Keep as physical model field |
| shoe_code | SHOE-002 | shoe_code | Shoe | Reference | TEXT | YES | NO | Valid stable business key | Keep required unique |
| brand | SHOE-003 | brand | Shoe | Manual | TEXT | YES | NO | Valid static attribute | Keep required |
| model | SHOE-004 | model | Shoe | Manual | TEXT | YES | NO | Valid static attribute | Keep required |
| nickname | SHOE-005 | nickname | Shoe | Manual | TEXT | NO | YES | Valid optional display attribute | Keep nullable |
| category | SHOE-006 | category | Shoe | Reference | ENUM | YES | NO | Valid controlled classification | Keep required enum |
| size_us | SHOE-007 | size_us | Shoe | Manual | DECIMAL | NO | YES | Valid optional specification | Keep nullable |
| width | SHOE-008 | width | Shoe | Manual | ENUM | NO | YES | Valid optional specification | Keep nullable |
| drop_mm | SHOE-009 | drop_mm | Shoe | Manual | DECIMAL | NO | YES | Valid optional specification | Keep nullable |
| weight_g | SHOE-010 | weight_g | Shoe | Manual | INTEGER | NO | YES | Valid optional specification | Keep nullable |
| purchase_date | SHOE-011 | purchase_date | Shoe | Manual | DATE | NO | YES | Valid optional lifecycle field | Keep nullable |
| first_run_date | SHOE-012 | first_run_date | Shoe | Manual | DATE | NO | YES | Valid as manual lifecycle field; observed value may also be derived | Keep nullable |
| retire_date | SHOE-013 | retire_date | Shoe | Manual | DATE | NO | YES | Valid optional lifecycle field | Keep nullable |
| retire_target_distance_km | SHOE-014 | retire_target_distance_km | Shoe | Manual | DECIMAL | NO | YES | Valid optional lifecycle target | Keep nullable |
| retire_actual_distance_km | SHOE-015 | retire_actual_distance_km | Shoe | Manual | DECIMAL | NO | YES | Valid as manual lifecycle outcome; observed value may also be derived | Keep nullable |
| is_active | SHOE-016 | is_active | Shoe | Manual | BOOLEAN | YES | NO | Valid lifecycle flag | Keep required |
| notes | SHOE-017 | notes | Shoe | Manual | TEXT | NO | YES | Valid optional notes | Keep nullable |
| created_at | SYS-005 | created_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |
| updated_at | SYS-006 | updated_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |

## Revised Shoe LDM v1.1 Candidate

```text
Shoe LDM v1.1 Candidate

Position:
One running shoe = one record.
Dimension table for shoe static attributes and lifecycle.

Identity:
id
shoe_code

Basic:
brand
model
nickname
category

Specification:
size_us
width
drop_mm
weight_g

Lifecycle:
purchase_date
first_run_date
retire_date
retire_target_distance_km
retire_actual_distance_km
is_active

Notes:
notes

System:
created_at
updated_at
```

## Excluded From Shoe v1.1

| Field | Reason | Replacement |
|---|---|---|
| status | Open-ended lifecycle states are not needed for v1 and can become inconsistent | `is_active` |
| rotation_order | Context-dependent coaching/rotation strategy | Future planning or AI Coach layer |
| default_workout | Context-dependent coaching strategy and can change by training cycle | Future planning or AI Coach layer |
| avg_hr | Performance metric derived from activities using the shoe | View / query |
| avg_power | Performance metric derived from activities using the shoe | View / query |
| avg_gct | Running dynamics metric derived from split/activity data | View / query |
| efficiency_score | Analysis output | Analysis layer |
| stack_height | Useful product spec, but not required for v1 analytics | Future metadata item |
| foam_type | Useful product spec, but not required for v1 analytics | Future metadata item |
| plate_type | Useful product spec, but not required for v1 analytics | Future metadata item |
| purchase_price | Not needed for current running intelligence workflows | Future metadata item |
| store | Not needed for current running intelligence workflows | Future metadata item |
| color | Covered by nullable `nickname` for v1 | Future explicit field if needed |

## Controlled Values

### category

`category` should use a controlled vocabulary.

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

### width

`width` is nullable. Recommended values:

```text
D
2E
Wide
Narrow
```

## Derived View Candidates

These values should be produced by views/query layer instead of stored in `shoe`:

| Field | Source |
|---|---|
| total_distance_km | `activity.distance_km` grouped by `shoe_id` |
| observed_first_run_date | `MIN(activity.activity_start_time)` grouped by `shoe_id` |
| observed_last_run_date | `MAX(activity.activity_start_time)` grouped by `shoe_id` |
| observed_run_count | `COUNT(activity.id)` grouped by `shoe_id` |
| average_hr | `AVG(activity.avg_hr)` grouped by `shoe_id` |
| running_dynamics_summary | `activity` / `kilometer_split` grouped by `shoe_id` |

## Round 1 Decision

Status: `Shoe LDM v1` can be promoted to `Shoe LDM v1.1 Final`.

Decision:

- Keep `shoe` as a dimension table.
- Store static attributes and lifecycle fields only.
- Exclude performance, efficiency, and coaching strategy fields.
- Use `shoe_code` as the stable business key.
- Use `is_active` instead of open-ended `status`.
- Keep nullable manual lifecycle fields where historical activity data may be incomplete.
