# LDM Validation Round 1 | training_purpose

## Purpose

Validate `Training Purpose LDM v1` against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `ADR-003 Separate Workout Type and Training Purpose`

The goal is to promote the draft training purpose dimension into a production-ready canonical model while preserving the separation between workout structure, training intent, and training outcome.

## Validation Criteria

1. Field exists in Metadata Repository.
2. Granularity is compatible with `training_purpose`.
3. Lifecycle is allowed in a dimension/reference table.
4. Data Type is consistent.
5. Required / Nullable is consistent.
6. Workout structure, coaching prescriptions, and analysis outcome fields are excluded.

## Summary

`Training Purpose LDM v1` is valid after metadata backfill and confirmation that it stores training intent only.

| Finding | Decision |
|---|---|
| Training purpose fields were not fully represented in Metadata Repository | Added `TP-001` through `TP-010` |
| `training_purpose` must answer Why, not How | Keep intent/stimulus fields; exclude workout structure fields |
| Training purpose describes intent, not outcome | Exclude actual physiological result and AI analysis fields |
| `purpose_category` should not be free text | Keep as required controlled enum |
| Classification booleans are stable reference attributes | Keep `is_primary_physiological`, `is_recovery_related`, `is_performance_related` |
| Target pace, HR, and power are coaching prescriptions | Exclude from v1.1 |

## Field Validation

| LDM Field | Metadata ID | Repository Field | Granularity | Lifecycle | Data Type | Required | Nullable | Validation Result | Decision |
|---|---|---|---|---|---|---|---|---|---|
| id | N/A | N/A | System | System | INTEGER | YES | NO | Physical surrogate PK | Keep as physical model field |
| training_purpose_code | TP-001 | training_purpose_code | Training Purpose | Reference | TEXT | YES | NO | Valid stable business key | Keep required unique |
| name_en | TP-002 | name_en | Training Purpose | Reference | TEXT | YES | NO | Valid display name | Keep required |
| name_zh | TP-003 | name_zh | Training Purpose | Reference | TEXT | YES | NO | Valid display name | Keep required |
| description | TP-004 | description | Training Purpose | Reference | TEXT | NO | YES | Valid optional description | Keep nullable |
| purpose_category | TP-005 | purpose_category | Training Purpose | Reference | ENUM | YES | NO | Valid controlled classification | Keep required enum |
| is_primary_physiological | TP-006 | is_primary_physiological | Training Purpose | Reference | BOOLEAN | YES | NO | Valid classification flag | Keep required |
| is_recovery_related | TP-007 | is_recovery_related | Training Purpose | Reference | BOOLEAN | YES | NO | Valid classification flag | Keep required |
| is_performance_related | TP-008 | is_performance_related | Training Purpose | Reference | BOOLEAN | YES | NO | Valid classification flag | Keep required |
| sort_order | TP-009 | sort_order | Training Purpose | Reference | INTEGER | NO | YES | Valid optional display hint | Keep nullable |
| display_color | TP-010 | display_color | Training Purpose | Reference | TEXT | NO | YES | Valid optional display hint | Keep nullable |
| created_at | SYS-005 | created_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |
| updated_at | SYS-006 | updated_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |

## Revised Training Purpose LDM v1.1 Candidate

```text
Training Purpose LDM v1.1 Candidate

Position:
One training purpose = one record.
Dimension table for standardized training intent classification.

Identity:
id
training_purpose_code

Basic:
name_en
name_zh
description

Classification:
purpose_category
is_primary_physiological
is_recovery_related
is_performance_related

Display:
sort_order
display_color

System:
created_at
updated_at
```

## Excluded From Training Purpose v1.1

| Field | Reason | Replacement |
|---|---|---|
| workout_type_id | Workout structure and training intent must stay separate | `activity.workout_type_id` and `activity_training_purpose` |
| default_workout_type | Context-dependent coaching strategy | Future planning or AI Coach layer |
| target_pace | Workout execution prescription, not training purpose | Future workout plan/session prescription model |
| target_hr | Workout execution prescription, not training purpose | Future workout plan/session prescription model |
| target_power | Workout execution prescription, not training purpose | Future workout plan/session prescription model |
| actual_training_effect | Activity result / analysis output | `activity` raw Garmin fields or analysis layer |
| actual_training_outcome | Analysis result; may differ from intended purpose | Analysis layer or future `ai_analysis` |
| training_domain | Useful higher-level grouping, but not required for v1.1 | Future Metadata Repository / v1.2 field if needed |

## Controlled Values

### purpose_category

Recommended v1 values:

```text
Recovery
Aerobic
Endurance
Threshold
VO2max
Speed
Technique
Environmental
Race
Maintenance
```

## Recommended Seed Values

Recommended initial `training_purpose_code` values:

```text
recovery
aerobic_base
endurance
maintenance
threshold
vo2max
speed
running_economy
neuromuscular
heat_adaptation
race_specific
race
```

## Notes

`race_specific` and `race` are intentionally separate.

- `race_specific` means training intended to improve race-specific ability, such as tempo, progression, half-marathon pace, or marathon pace work.
- `race` means a formal race activity.

`training_purpose` records coaching intent. If the intended purpose was `threshold` but the actual stimulus became VO2max-like because of heat or fatigue, this table is not changed. The outcome belongs to analysis.

## Architecture DoD

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Completed
