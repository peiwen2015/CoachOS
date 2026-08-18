# CoachOS Chart Semantic View and Data Field Mapping v0.1

## Purpose

This document defines the semantic contract between chart requirements and the actual data model.

It connects:

- chart priorities
- chart requirements
- semantic views
- normalized fields
- derived metrics
- front-end presentation needs

The goal is to make every chart traceable from user question to source data.

## Scope

This document covers:

- the MVP chart set
- semantic view responsibilities
- field naming and unit conventions
- data quality and fallback behavior
- chart-to-view mapping

It does not define pixel-level UI design.

It does define which layer is responsible for each piece of chart logic.

## Semantic Layer Principles

1. Chart surfaces must not depend on vendor-specific field names.
2. Units must be normalized before chart logic runs.
3. A metric should have one governed definition.
4. Auto-generated verdicts must only use fields with known quality status.
5. Missing values and zero values must remain distinct.
6. Raw values, normalized values, and estimated values must not be mixed in one field.
7. Time series must preserve timezone, sampling cadence, and source provenance.
8. Reusable chart logic belongs in semantic views, not repeated in front-end code.

## Data Layer Contract

### Source Layer

This layer contains the original provider or user-supplied data.

Examples:

- Garmin activity data
- Strava activity data
- FIT samples
- manual workout plans
- coach targets

Source fields remain source-specific.

They are not the chart contract.

### Normalized Layer

This layer converts all sources into CoachOS standard units and names.

Examples:

- `distance_m`
- `duration_s`
- `moving_duration_s`
- `heart_rate_bpm`
- `speed_mps`
- `power_w`
- `elevation_m`
- `timestamp_utc`

### Derived Layer

This layer computes reusable measures.

Examples:

- `pace_s_per_km`
- `weekly_distance_m`
- `weekly_training_load`
- `heart_rate_drift_pct`
- `aerobic_decoupling_pct`
- `target_compliance_pct`
- `intensity_zone_duration_s`

### Presentation Layer

This layer prepares chart-facing values.

Examples:

- display labels
- verdict text
- confidence text
- fallback text
- highlighted ranges

## Standard Field Metadata

Every semantic field should be documentable with the following metadata.

| Field | Meaning |
|---|---|
| Semantic Field | Governed CoachOS field name |
| Business Definition | Human-readable meaning |
| Data Type | integer, decimal, timestamp, enum, boolean |
| Canonical Unit | Standard unit used across the product |
| Source Field | Originating raw field or input |
| Transformation | Normalization or calculation rule |
| Grain | activity, lap, sample, day, week |
| Required / Optional | Whether the field is mandatory |
| Nullable | Whether missing values are allowed |
| Quality Rule | Range or validity check |
| Confidence | measured, derived, estimated |
| Used By | Charts, pages, or verdicts that consume the field |
| Fallback | How the system behaves if the field is missing |

## Shared Semantic Field Set

These fields should be used consistently across chart views.

### Activity Identity

- `activity_id`
- `athlete_id`
- `source_system`
- `source_activity_id`
- `activity_type`
- `activity_subtype`
- `workout_type`
- `training_purpose`
- `primary_training_purpose`
- `secondary_training_purpose`

### Time and Duration

- `started_at_utc`
- `started_at_local`
- `local_date`
- `duration_s`
- `moving_duration_s`
- `elapsed_time_s`

### Distance and Pace

- `distance_m`
- `pace_s_per_km`
- `split_index`
- `split_distance_m`
- `split_pace_s_per_km`

### Heart Rate and Effort

- `heart_rate_bpm`
- `average_heart_rate_bpm`
- `maximum_heart_rate_bpm`
- `heart_rate_zone`

### Power and Motion

- `power_w`
- `average_power_w`
- `cadence_spm`
- `speed_mps`

### Terrain and Context

- `elevation_m`
- `elevation_gain_m`
- `grade_pct`
- `temperature_c`
- `weather_condition`

### Quality and Confidence

- `data_completeness_score`
- `sample_quality_status`
- `verdict_confidence`
- `is_partial_period`
- `is_estimated`

## MVP Semantic View Map

The MVP charts should be supported by reusable semantic views.

Some of these can be satisfied by existing views in `Semantic Layer v1.0`.
Others should be added as chart-specific views if the current layer does not yet expose the needed grain.

## 1. Weekly Training Load Trend

### Decision Question

Am I progressing steadily, undertraining, or increasing load too fast?

### Recommended Semantic Views

- existing: `weekly_summary_view`
- existing: `current_week_intelligence_view`
- proposed: `weekly_training_load_view`

### Required Fields

- `week_start_date`
- `week_end_date`
- `week_index`
- `weekly_distance_m`
- `weekly_duration_s`
- `weekly_training_load`
- `weekly_load_delta`
- `weekly_load_delta_pct`
- `acute_load`
- `chronic_load`
- `acute_chronic_ratio`
- `is_recovery_week`
- `is_race_week`
- `is_taper_week`
- `data_completeness_score`

### Source Mapping

- `activity_view` or activity-level canonical rows for weekly rollup
- `training_load` from governed source or derived load logic
- week grouping from calendar or rolling 7-day rule

### Derived Rules

- weekly totals should be computed in semantic SQL, not in front-end code
- weekly change should be compared against the previous week and recent baseline
- acute / chronic ratio should only appear when the load history is sufficient

### Fallback Behavior

- if `weekly_training_load` is missing, show distance and duration only
- if chronic load cannot be trusted, hide the ratio and explain why

## 2. Goal vs Actual Workout Completion

### Decision Question

Did I complete the session the way it was intended?

### Recommended Semantic Views

- proposed: `planned_workout_segment_view`
- proposed: `workout_execution_segment_view`
- existing support: `activity_review_view`

### Required Fields

- `activity_id`
- `workout_id`
- `segment_id`
- `segment_order`
- `segment_type`
- `target_metric`
- `target_min`
- `target_max`
- `target_unit`
- `planned_duration_s`
- `planned_distance_m`
- `actual_duration_s`
- `actual_distance_m`
- `average_pace_s_per_km`
- `average_heart_rate_bpm`
- `average_power_w`
- `target_compliance_pct`
- `within_target_duration_pct`
- `deviation_from_target_pct`
- `segment_status`

### Source Mapping

- planned targets from coach or workout plan data
- execution data from activity summary and timeseries views
- split-level execution from activity samples when needed

### Derived Rules

- compare actual values against the plan at the segment grain
- compute compliance only when the target is defined
- show per-set averages for repeat structures

### Fallback Behavior

- if the workout plan is missing, fall back to actual-only execution
- if only partial targets exist, show the known segments and mark the rest as incomplete

## 3. Pace and Heart Rate Decoupling

### Decision Question

Did the run stay stable, or did efficiency fall apart late?

### Recommended Semantic Views

- proposed: `activity_timeseries_view`
- proposed: `activity_half_split_view`
- existing support: `activity_review_view`

### Required Fields

- `activity_id`
- `elapsed_time_s`
- `split_index`
- `distance_m`
- `split_distance_m`
- `pace_s_per_km`
- `split_pace_s_per_km`
- `heart_rate_bpm`
- `average_heart_rate_bpm`
- `sample_quality_status`
- `elevation_m`
- `grade_pct`
- `temperature_c`

### Source Mapping

- sample-level FIT or normalized provider stream
- route and terrain context from activity metadata

### Derived Rules

- decoupling should compare the first half and second half of the same run
- drift should only be computed when sample quality is adequate
- route or terrain distortion should be detectable through context fields

### Fallback Behavior

- if heart rate is sparse, suppress the decoupling verdict and show a lighter stability note
- if elevation context is missing, avoid strong claims about pace drift

## 4. Weekly Intensity Distribution

### Decision Question

Is my training really low-intensity dominant, or am I accumulating too much hard work?

### Recommended Semantic Views

- existing: `training_balance_view`
- existing: `training_distribution_view`
- existing: `recent_training_intent_view`
- proposed: `weekly_intensity_distribution_view`

### Required Fields

- `period_start_date`
- `period_end_date`
- `activity_id`
- `activity_type`
- `workout_type`
- `training_purpose`
- `intensity_zone`
- `intensity_zone_duration_s`
- `zone_share_pct`
- `weekly_zone_share_pct`
- `period_type`

### Source Mapping

- activity classification from governed metadata
- zone duration from heart rate, pace, or power systems
- week or rolling-period grouping from semantic SQL

### Derived Rules

- intensity distribution should support multiple zone systems
- the chart should clearly state which zone system is active
- compare one workout, 7 days, and 4 weeks using the same semantic shape

### Fallback Behavior

- if one zone system is missing, switch to the best available governed zone system
- if no zone system is reliable, show classification mix instead of zone percentages

## Proposed Reusable Semantic Views

These are recommended chart-oriented views if the current semantic layer does not already expose the needed grain.

### `weekly_training_load_view`

One row per week.

Use for:

- load trend
- weekly comparisons
- recovery and taper annotation

### `planned_workout_segment_view`

One row per planned segment.

Use for:

- targets
- interval structure
- planned execution comparisons

### `workout_execution_segment_view`

One row per executed segment.

Use for:

- completion analysis
- deviation from target
- interval-level verdicts

### `activity_timeseries_view`

One row per sample or normalized time slice.

Use for:

- pace / heart-rate decoupling
- drift
- split-level stability

### `weekly_intensity_distribution_view`

One row per period and intensity bucket.

Use for:

- zone distribution
- training balance
- intensity mix review

## Quality And Confidence Rules

Chart verdicts should only be generated when the underlying fields meet the minimum quality threshold.

Recommended confidence states:

- `measured`
- `derived`
- `estimated`
- `partial`
- `insufficient`

Rules:

1. Measured values outrank estimated values.
2. Derived metrics must disclose their inputs when shown to the user.
3. Partial periods must be labeled explicitly.
4. Insufficient data should suppress strong verdicts.
5. Fallbacks should be visible in the chart copy.

## Comparison Cohort Semantics

Chart comparisons that use "similar workouts" must be built from governed cohort rules rather than activity name matching alone.

### Cohort Inputs

Recommended cohort inputs:

- `workout_family`
- `structure_type`
- `primary_training_purpose`
- `distance_m`
- `duration_s`
- `stride_count`
- `quality_segment_count`
- `fast_finish_flag`
- `temperature_c`
- `humidity_pct`
- `shoe_id`
- `route_id`
- `terrain_type`
- `sequence_role`
- `training_block_position`

### Cohort Rules

- inclusion should require workout family, structure type, and primary purpose
- distance or duration should be within the governed tolerance range
- stride work, progression work, fast-finish sessions, and quality segments should be excluded unless explicitly requested
- environment and shoe fields should be optional filters, not hard requirements
- cohort size must be surfaced in the presentation layer

### Cohort Fallback

- if the cohort is smaller than the minimum comparison threshold, show a note that the set is too small for trend language
- if the cohort is smaller than the minimum comparison threshold but still useful for inspection, keep the list view and suppress inferential copy
- if only one activity is available, show the activity record without comparison language

## Semantic Contracts By Chart

### Weekly Load Trend Contract

- period grain: week
- core source: weekly rollup from activity summary
- key outputs: trend, deltas, ratio, phase markers

### Workout Completion Contract

- period grain: segment
- core source: plan plus execution
- key outputs: compliance, deviation, fade, completion status

### Workout Structure Comparison Contract

- period grain: activity plus cohort
- core source: activity-level canonical rows plus filtered cohort set
- key outputs: cohort median, percentile band, delta direction, sample count, comparison validity

### Comparison Scope Contract

- period grain: whole activity, main segment, work intervals, or final 20 percent
- core source: activity structure metadata plus analysis scope rules
- key outputs: scope label, scope-specific metric selection, segment alignment

### Decoupling Contract

- period grain: sample or split
- core source: activity timeseries
- key outputs: pace trend, heart-rate drift, stability verdict

### Intensity Distribution Contract

- period grain: workout, week, or rolling 4-week window
- core source: activity classification and zone totals
- key outputs: zone share, mix, dominant intensity label

## Metric Definition Rules

### Pace Delta

Pace delta fields must preserve both sign and magnitude.

Recommended semantic fields:

- `pace_delta_sec`
- `pace_change_direction`
- `pace_change_magnitude_sec`

Direction rules:

- `pace_change_direction = faster` when later pace is smaller
- `pace_change_direction = slower` when later pace is larger
- `pace_change_direction = stable` when absolute change is within the governed stability threshold

### Analysis Scope

The semantic layer should expose the analysis scope used by each chart.

Recommended semantic values:

- `whole_activity`
- `main_segment`
- `work_intervals`
- `final_20_percent`

Scope mapping examples:

- easy run -> `whole_activity`
- tempo -> `main_segment`
- interval -> `work_intervals`
- long run -> `whole_activity` with `final_20_percent`

### Sample Count And Copy Rules

Presentation logic should use the validated sample count to decide whether trend language is allowed.

Recommended sample thresholds:

- `1-2`: data only
- `3-4`: current observation
- `5-9`: recent trend
- `10+`: long-term distribution

Trend copy must not imply causation when environment or sequence conditions differ materially.

## Validation Cases

Each mapping should be validated against at least one of the following cases:

- stable easy-run week
- recovery week
- race week
- long-run build phase
- interval session with clean targets
- interval session with missing targets
- steady long run with low drift
- long run with heat-driven drift
- missing heart-rate sample case
- missing zone-system case
- small cohort comparison case
- cohort with excluded quality segments
- missing power field case
- missing environment field case

## Relationship to Other Documents

This document should be read together with:

- [`CoachOS Chart Priorities v0.1.md`](./CoachOS%20Chart%20Priorities%20v0.1.md)
- [`CoachOS Chart Requirements Specification v0.1.md`](./CoachOS%20Chart%20Requirements%20Specification%20v0.1.md)
- [`CoachOS Chart Semantic View SQL Draft v0.1.sql`](../30_Physical_Model/CoachOS%20Chart%20Semantic%20View%20SQL%20Draft%20v0.1.sql)
- [`CoachOS Chart Semantic View SQL Notes v0.1.md`](../30_Physical_Model/CoachOS%20Chart%20Semantic%20View%20SQL%20Notes%20v0.1.md)
- [`CoachOS Chart Rendering Contract v0.1.md`](../20_Architecture/CoachOS%20Chart%20Rendering%20Contract%20v0.1.md)
- [`Semantic Layer v1.0.md`](../30_Physical_Model/Semantic%20Layer%20v1.0.md)
- [`Product Design Principles v1.0.md`](./Product%20Design%20Principles%20v1.0.md)
- [`Product UX Polish Sprint v1.0.md`](./Product%20UX%20Polish%20Sprint%20v1.0.md)

## Status

`CoachOS Chart Semantic View and Data Field Mapping v0.1`

- Status: Draft
- Scope: Chart-to-semantic-view mapping, field contract, and fallback rules
- Classification: Governance / Semantic Contract
