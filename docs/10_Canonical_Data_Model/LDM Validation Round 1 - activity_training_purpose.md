# LDM Validation Round 1 | activity_training_purpose

## Purpose

Validate `Activity Training Purpose LDM v1` against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `ADR-003 Separate Workout Type and Training Purpose`

The goal is to promote the draft activity-training-purpose bridge into a production-ready canonical relationship model.

## Validation Criteria

1. Field exists in Metadata Repository.
2. Granularity is compatible with `activity_training_purpose`.
3. Lifecycle is allowed in a bridge table.
4. Data Type is consistent.
5. Required / Nullable is consistent.
6. Many-to-many relationship rules are explicit.
7. Training outcome, prescriptions, and subjective weights are excluded.

## Summary

`Activity Training Purpose LDM v1` is valid after metadata backfill and confirmation that it stores coaching intent relationships only.

| Finding | Decision |
|---|---|
| Bridge fields were not fully represented in Metadata Repository | Added `ATP-001` through `ATP-003` |
| Activity can have multiple training purposes | Use bridge table instead of single `training_purpose_id` on `activity` |
| Training purpose role is useful and stable | Keep `purpose_role` with `PRIMARY` / `SECONDARY` |
| Percentage weights are too subjective for v1 | Exclude `purpose_weight` |
| Bridge stores intent relationship, not outcome | Exclude actual stimulus, analysis result, and AI fields |

## Field Validation

| LDM Field | Metadata ID | Repository Field | Granularity | Lifecycle | Data Type | Required | Nullable | Validation Result | Decision |
|---|---|---|---|---|---|---|---|---|---|
| id | N/A | N/A | System | System | INTEGER | YES | NO | Physical surrogate PK | Keep as physical model field |
| activity_id | ATP-001 | activity_id | Activity Training Purpose | Manual | FK | YES | NO | Valid required bridge FK | Keep required |
| training_purpose_id | ATP-002 | training_purpose_id | Activity Training Purpose | Manual | FK | YES | NO | Valid required bridge FK | Keep required |
| purpose_role | ATP-003 | purpose_role | Activity Training Purpose | Manual | ENUM | YES | NO | Valid required role classification | Keep required enum |
| created_at | SYS-005 | created_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |
| updated_at | SYS-006 | updated_at | System | Raw | DATETIME | YES | NO | Valid system timestamp | Keep required |

## Revised Activity Training Purpose LDM v1.1 Candidate

```text
Activity Training Purpose LDM v1.1 Candidate

Position:
One activity-to-training-purpose relationship = one record.
Bridge table connecting activities to one or more training purposes.

Identity:
id

Relationship:
activity_id
training_purpose_id

Classification:
purpose_role

System:
created_at
updated_at
```

## Relationship Rules

- One activity may have one or more training purposes.
- One activity should have at least one `PRIMARY` purpose once the training-purpose workflow is enabled.
- One activity may have zero or more `SECONDARY` purposes.
- The same activity must not repeat the same training purpose.
- `purpose_role` does not represent percentage contribution.

## Controlled Values

### purpose_role

Recommended v1 values:

```text
PRIMARY
SECONDARY
```

## Examples

| workout_type | purpose_role | training_purpose |
|---|---|---|
| recovery_run | PRIMARY | recovery |
| easy_run | PRIMARY | aerobic_base |
| easy_run_strides | PRIMARY | aerobic_base |
| easy_run_strides | SECONDARY | neuromuscular |
| tempo_run | PRIMARY | threshold |
| tempo_run | SECONDARY | race_specific |
| lsd | PRIMARY | endurance |
| lsd | SECONDARY | aerobic_base |

## Excluded From Activity Training Purpose v1.1

| Field | Reason | Replacement |
|---|---|---|
| purpose_weight | Percentage split is subjective and hard to maintain consistently | Future v2 load attribution model if needed |
| target_pace | Workout execution prescription, not bridge relationship | Future workout plan/session prescription model |
| target_hr | Workout execution prescription, not bridge relationship | Future workout plan/session prescription model |
| target_power | Workout execution prescription, not bridge relationship | Future workout plan/session prescription model |
| actual_training_effect | Activity result / analysis output | `activity` raw Garmin fields or analysis layer |
| actual_training_outcome | Analysis result; may differ from intended purpose | Analysis layer or future `ai_analysis` |
| ai_detected_purpose | AI interpretation, not coaching intent | Future `ai_analysis` |

## Notes

`activity_training_purpose` records the intended relationship between an activity and one or more training purposes.

If the intended purpose was `threshold` but the actual stimulus became VO2max-like because of heat or fatigue, the bridge is not changed. The outcome belongs to analysis.

## Architecture DoD

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Completed
