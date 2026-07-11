# Activity Training Purpose LDM v1.1 Final

## Position

One activity-to-training-purpose relationship = one record.

`activity_training_purpose` is a bridge table connecting `activity` and `training_purpose`.

It represents the coaching intent assigned to an activity and supports many-to-many relationships between activities and training purposes.

## Design Philosophy

`activity_training_purpose` answers:

```text
Which training purposes were intended for this activity, and what role did each purpose play?
```

It does not answer:

```text
What physiological outcome actually happened?
```

Training intent is preserved even if the actual workout outcome differs.

This table completes the relationship:

```text
activity
  ↓
activity_training_purpose
  ↓
training_purpose
```

This relationship is governed by `ADR-003 Separate Workout Type and Training Purpose`.

## Schema

### Identity

```text
id
```

### Relationship

```text
activity_id
training_purpose_id
```

### Classification

```text
purpose_role
```

### System

```text
created_at
updated_at
```

## Field Notes

### activity_id

`activity_id` references one activity.

It is required because every bridge record must belong to an activity.

### training_purpose_id

`training_purpose_id` references one training purpose.

It is required because every bridge record must assign one intent.

### purpose_role

`purpose_role` is a controlled vocabulary.

Recommended v1 values:

```text
PRIMARY
SECONDARY
```

`purpose_role` describes the role of the intent, not a numeric weight.

## Relationship Rules

- One activity may have one or more training purposes.
- One activity should have at least one `PRIMARY` purpose once the training-purpose workflow is enabled.
- One activity may have zero or more `SECONDARY` purposes.
- The same activity must not repeat the same training purpose.
- `purpose_role` does not represent percentage contribution.

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

## Excluded Fields

| Field | Reason | Replacement |
|---|---|---|
| purpose_weight | Percentage split is subjective and hard to maintain consistently | Future v2 load attribution model if needed |
| target_pace | Workout execution prescription, not bridge relationship | Future workout plan/session prescription model |
| target_hr | Workout execution prescription, not bridge relationship | Future workout plan/session prescription model |
| target_power | Workout execution prescription, not bridge relationship | Future workout plan/session prescription model |
| actual_training_effect | Activity result / analysis output | `activity` raw Garmin fields or analysis layer |
| actual_training_outcome | Analysis result; may differ from intended purpose | Analysis layer or future `ai_analysis` |
| ai_detected_purpose | AI interpretation, not coaching intent | Future `ai_analysis` |

## Compliance

Validated against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `ADR-003 Separate Workout Type and Training Purpose`
- `LDM Validation Round 1 - activity_training_purpose`

Architecture DoD:

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Final
