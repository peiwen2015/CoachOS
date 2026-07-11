# LDM Validation Round 1 | workout_type

## Purpose

Validate `Workout Type LDM v1` against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `ADR-003 Separate Workout Type and Training Purpose`

The goal is to promote the draft workout type dimension into a production-ready canonical model while preserving the separation between workout structure and training intent.

## Validation Criteria

1. Field exists in Metadata Repository.
2. Granularity is compatible with `workout_type`.
3. Lifecycle is allowed in a dimension/reference table.
4. Data Type is consistent.
5. Required / Nullable is consistent.
6. Context-dependent defaults and training-purpose fields are excluded.

## Summary

`Workout Type LDM v1` is valid after metadata backfill and confirmation that no coaching defaults are stored.

| Finding | Decision |
|---|---|
| Workout type fields were not fully represented in Metadata Repository | Added `WKT-001` through `WKT-010` |
| `workout_type` must answer How, not Why | Keep structure/classification fields; exclude purpose defaults |
| `intensity_category` should not be free text | Keep as required controlled enum |
| Classification booleans are stable structural hints | Keep `is_quality_session`, `is_long_run`, `is_recovery_focused` |
| `default_training_purpose` would duplicate `training_purpose` and bridge model | Exclude from v1.1 |
| `default_shoe` and `default_intensity` are coaching strategy | Exclude from v1.1 |

## Field Validation

| LDM Field | Metadata ID | Repository Field | Granularity | Lifecycle | Data Type | Required | Nullable | Validation Result | Decision |
|---|---|---|---|---|---|---|---|---|---|
| id | N/A | N/A | System | System | INTEGER | YES | NO | Physical surrogate PK | Keep as physical model field |
| workout_type_code | WKT-001 | workout_type_code | Workout Type | Reference | TEXT | YES | NO | Valid stable business key | Keep required unique |
| name_en | WKT-002 | name_en | Workout Type | Reference | TEXT | YES | NO | Valid display name | Keep required |
| name_zh | WKT-003 | name_zh | Workout Type | Reference | TEXT | YES | NO | Valid display name | Keep required |
| description | WKT-004 | description | Workout Type | Reference | TEXT | NO | YES | Valid optional description | Keep nullable |
| intensity_category | WKT-005 | intensity_category | Workout Type | Reference | ENUM | YES | NO | Valid controlled classification | Keep required enum |
| is_quality_session | WKT-006 | is_quality_session | Workout Type | Reference | BOOLEAN | YES | NO | Valid structural classification flag | Keep required |
| is_long_run | WKT-007 | is_long_run | Workout Type | Reference | BOOLEAN | YES | NO | Valid structural classification flag | Keep required |
| is_recovery_focused | WKT-008 | is_recovery_focused | Workout Type | Reference | BOOLEAN | YES | NO | Valid structural classification flag | Keep required |
| sort_order | WKT-009 | sort_order | Workout Type | Reference | INTEGER | NO | YES | Valid optional display hint | Keep nullable |
| display_color | WKT-010 | display_color | Workout Type | Reference | TEXT | NO | YES | Valid optional display hint | Keep nullable |
| created_at | SYS-005 | created_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |
| updated_at | SYS-006 | updated_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |

## Revised Workout Type LDM v1.1 Candidate

```text
Workout Type LDM v1.1 Candidate

Position:
One workout structure type = one record.
Dimension table for standardized workout structure classification.

Identity:
id
workout_type_code

Basic:
name_en
name_zh
description

Classification:
intensity_category
is_quality_session
is_long_run
is_recovery_focused

Display:
sort_order
display_color

System:
created_at
updated_at
```

## Excluded From Workout Type v1.1

| Field | Reason | Replacement |
|---|---|---|
| default_training_purpose | Context-dependent coaching strategy; duplicates `training_purpose` and bridge model | `activity_training_purpose` |
| training_purpose_id | Workout structure and training intent must stay separate | `activity_training_purpose` |
| default_shoe | Context-dependent coaching strategy | Future planning or AI Coach layer |
| default_intensity | Context-dependent coaching strategy | Future planning or AI Coach layer |
| target_pace | Workout execution prescription, not workout type | Future workout plan/session prescription model |
| target_hr | Workout execution prescription, not workout type | Future workout plan/session prescription model |
| target_power | Workout execution prescription, not workout type | Future workout plan/session prescription model |
| actual_training_effect | Activity result / analysis output | `activity` raw Garmin fields or analysis layer |

## Controlled Values

### intensity_category

Recommended v1 values:

```text
Recovery
Easy
Moderate
Quality
Race
Rest
Cross Training
```

## Recommended Seed Values

Recommended initial `workout_type_code` values:

```text
recovery_run
easy_run
easy_run_strides
steady_run
progression_run
tempo_run
threshold_run
interval
cruise_interval
fartlek
hill_run
lsd
long_run
race
rest
cross_training
```

## Round 1 Decision

Status: `Workout Type LDM v1` can be promoted to `Workout Type LDM v1.1 Final`.

Decision:

- Keep `workout_type` as a dimension/reference table.
- Store stable workout structure classification only.
- Exclude training purpose, coaching defaults, and workout prescription targets.
- Use `workout_type_code` as the stable business key.
- Keep `intensity_category` as a required enum.
- Keep structural booleans as required flags for dashboard and AI Coach filtering.
