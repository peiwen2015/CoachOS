# Training Purpose LDM v1.1 Final

## Position

One training purpose = one record.

`training_purpose` is a dimension/reference table used to standardize training intent classification.

It is connected to `activity` through the `activity_training_purpose` bridge and supports dashboard filtering, training review, weekly balance analysis, and future AI Coach reasoning about why a workout was performed.

## Design Philosophy

`training_purpose` answers:

```text
Why was this workout performed?
```

It does not answer:

```text
How was this workout structured?
```

Workout structure belongs to `workout_type`.

Training purpose describes coaching intent, not training outcome.

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
training_purpose_code
```

### Basic

```text
name_en
name_zh
description
```

### Classification

```text
purpose_category
is_primary_physiological
is_recovery_related
is_performance_related
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

### training_purpose_code

`training_purpose_code` is the stable human-readable business key.

Rules:

- lowercase
- snake_case
- unique
- stable after creation

Examples:

```text
aerobic_base
running_economy
heat_adaptation
race_specific
```

### purpose_category

`purpose_category` is a controlled vocabulary.

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

### Classification Flags

The following fields are intent classification flags:

```text
is_primary_physiological
is_recovery_related
is_performance_related
```

They describe the training purpose itself and may be used for dashboard grouping, weekly review, and AI Coach filtering.

They are not coaching recommendations.

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

## Race Purpose Definitions

`race_specific` and `race` are intentionally separate.

| Code | Meaning |
|---|---|
| race_specific | Race-specific preparation or ability development |
| race | Formal race activity |

Examples of `race_specific` training include tempo runs, progression runs, half-marathon pace work, and marathon pace work.

## Excluded Fields

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

## Compliance

Validated against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`
- `ADR-003 Separate Workout Type and Training Purpose`
- `LDM Validation Round 1 - training_purpose`

Architecture DoD:

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[x] Release Notes Updated
[x] Final LDM Published
```

Status: Final
