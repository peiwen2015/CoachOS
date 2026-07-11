# Workout Type LDM v1.1 Final

## Position

One workout structure type = one record.

`workout_type` is a dimension/reference table used to standardize workout structure classification.

It is referenced by `activity.workout_type_id` and supports dashboard filtering, training review, and future AI Coach reasoning about how a workout was structured.

## Design Philosophy

`workout_type` answers:

```text
How is this workout structured?
```

It does not answer:

```text
Why was this workout performed?
```

Training intent belongs to `training_purpose` and the `activity_training_purpose` bridge.

Examples:

| workout_type | Possible training_purpose |
|---|---|
| easy_run | recovery / aerobic_base / maintenance |
| easy_run_strides | aerobic_base + neuromuscular |
| tempo_run | threshold / race_specific |
| lsd | endurance / aerobic_base |

This separation is governed by `ADR-003 Separate Workout Type and Training Purpose`.

## Schema

### Identity

```text
id
workout_type_code
```

### Basic

```text
name_en
name_zh
description
```

### Classification

```text
intensity_category
is_quality_session
is_long_run
is_recovery_focused
```

### Display

```text
sort_order
display_color
```

### System

```text
created_at
updated_at
```

## Field Notes

### workout_type_code

`workout_type_code` is the stable human-readable business key.

Rules:

- lowercase
- snake_case
- unique
- stable after creation

Examples:

```text
easy_run
tempo_run
cruise_interval
hill_run
```

### intensity_category

`intensity_category` is a controlled vocabulary.

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

### Classification Flags

The following fields are structural flags:

```text
is_quality_session
is_long_run
is_recovery_focused
```

They describe the workout type itself and may be used for dashboard grouping, weekly review, and AI Coach filtering.

They are not coaching recommendations.

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

## Excluded Fields

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

## Compliance

Validated against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `ADR-003 Separate Workout Type and Training Purpose`
- `LDM Validation Round 1 - workout_type`

Architecture DoD:

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Final
