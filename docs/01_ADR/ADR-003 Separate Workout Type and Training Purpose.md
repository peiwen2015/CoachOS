# ADR-003 Separate Workout Type and Training Purpose

## Status

Accepted

## Context

Workout classification can mix two different concepts:

- How the workout is structured
- Why the workout is performed

For example, an `easy_run` can support recovery, aerobic base, or maintenance. An `easy_run_strides` can support both aerobic base and neuromuscular stimulus.

## Decision

Separate `workout_type` and `training_purpose`.

- `workout_type` answers: How is this workout structured?
- `training_purpose` answers: Why is this workout performed?

Activities may have multiple training purposes through `activity_training_purpose`.

## Consequences

- `activity` stores `workout_type_id` as the workout structure reference.
- Training intent is represented through a bridge table.
- AI Coach can compare intended purpose with actual outcome later without mutating the original training intent.

