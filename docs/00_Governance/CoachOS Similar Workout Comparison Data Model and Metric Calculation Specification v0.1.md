# CoachOS Similar Workout Comparison Data Model and Metric Calculation Specification v0.1

## Purpose

This document defines the governed data model and metric calculation contract for similar workout comparison features.

It exists so that:

- comparison cohorts are generated consistently
- metric calculations are performed in one governed layer
- front-end surfaces consume already-resolved comparison output
- charts, summaries, and drill-down views use the same definitions

This document is the engineering contract between semantic rules and comparison-facing presentation.

## Scope

This specification covers:

- cohort construction
- analysis scope
- anchor definition
- metric calculation
- cohort statistics
- relative position fields
- missing data behavior
- API response shape
- validation matrix

It does not define pixel-level UI design.

It does not redefine the chart requirements already governed elsewhere.

## Core Entity

Each comparison record represents:

- one athlete
- one activity
- one comparison definition
- one analysis scope

Recommended comparison grain:

```text
athlete_id
comparison_definition_id
activity_id
analysis_scope
```

## Comparison Definition Model

Each comparison definition should be governed by explicit fields.

Recommended fields:

- `comparison_definition_id`
- `comparison_name`
- `workout_family`
- `structure_type`
- `primary_training_purpose`
- `distance_tolerance_pct`
- `duration_tolerance_pct`
- `exclude_stride`
- `exclude_progression`
- `exclude_fast_finish`
- `exclude_quality_segments`
- `minimum_comparison_samples`
- `minimum_trend_samples`
- `temperature_filter_enabled`
- `humidity_filter_enabled`
- `shoe_filter_enabled`
- `route_filter_enabled`
- `terrain_filter_enabled`
- `sequence_role_filter_enabled`
- `training_block_position_filter_enabled`

## Activity Eligibility Model

Each activity must receive an eligibility status before it enters comparison output.

Recommended fields:

- `is_cohort_eligible`
- `cohort_exclusion_reason`
- `comparison_validity_status`
- `comparison_validity_notes`

Recommended validity statuses:

- `valid`
- `partial`
- `insufficient`
- `excluded`

Common exclusion reasons:

- wrong workout family
- wrong structure type
- wrong primary purpose
- outside distance tolerance
- outside duration tolerance
- stride work present
- progression work present
- fast finish present
- quality segments present
- environment mismatch
- insufficient sample count
- missing governed source

## Analysis Scope Model

The comparison layer must preserve which part of the activity was analyzed.

Recommended values:

- `whole_activity`
- `main_segment`
- `work_intervals`
- `final_20_percent`

Scope must be selected according to workout structure.

Examples:

- Easy Run uses `whole_activity`
- Tempo uses `main_segment`
- Interval uses `work_intervals`
- LSD uses `whole_activity` plus `final_20_percent`

## Anchor Model

Comparison charts that reference start, middle, and finish must use governed anchors.

Recommended fields:

- `start_anchor_type`
- `start_anchor_position_pct`
- `start_anchor_split_index`
- `mid_anchor_type`
- `mid_anchor_position_pct`
- `mid_anchor_split_index`
- `finish_anchor_type`
- `finish_anchor_position_pct`
- `finish_anchor_split_index`

### Anchor Rules

- anchors should be based on completion position, not fixed kilometer labels
- `finish_anchor` must not use a tail fragment that is too short to represent the workout finish
- `mid_anchor` should target the approximate halfway position of the selected scope
- `start_anchor` should target the early stable section after initial settling when possible

## Core Metric Definitions

The following metrics should be computed in the semantic or derived layer, not in the front-end.

Recommended fields:

- `scope_average_pace_s_per_km`
- `scope_average_heart_rate_bpm`
- `scope_average_power_w`
- `pace_delta_sec`
- `pace_change_direction`
- `pace_change_magnitude_sec`
- `heart_rate_delta_bpm`
- `power_delta_w`
- `pace_range_sec`
- `pace_cv_pct`
- `power_cv_pct`
- `stamina_drop`
- `training_load`

### Pace Delta Rules

Pace delta must preserve direction and magnitude separately.

Recommended direction values:

- `faster`
- `slower`
- `stable`

Display rules:

- smaller pace later in the activity should render as `faster`
- larger pace later in the activity should render as `slower`
- absolute change within the governed stability threshold should render as `stable`

## Cohort Statistics

Each comparison set must expose its size and central tendency.

Recommended fields:

- `cohort_sample_count`
- `valid_pace_sample_count`
- `valid_hr_sample_count`
- `valid_power_sample_count`
- `cohort_median_pace`
- `cohort_p25_pace`
- `cohort_p75_pace`
- `cohort_median_hr`
- `cohort_median_power`
- `cohort_median_stamina_drop`

## Relative Position Fields

Relative position fields should express where the activity sits inside the cohort distribution.

Recommended fields:

- `pace_percentile`
- `heart_rate_percentile`
- `power_percentile`
- `stamina_drop_percentile`
- `training_load_percentile`

### Relative Position Semantics

- faster pace should sort toward the higher percentile end if the percentile is defined as better performance on the axis
- heart rate percentile should be treated as distribution position, not as a quality score
- stamina drop percentile should describe position only and must not be interpreted as inherently better

If the percentile axis differs by metric, the response must state that explicitly.

## Missing Data Contract

Every metric must define its own data contract.

Recommended fields:

- `required_inputs`
- `nullable`
- `fallback`
- `exclusion_behavior`
- `presentation_copy`

### Missing Data Rules

- do not substitute zero for missing governed values
- do not derive official averages from incomplete data unless that is the governed definition
- do not include unsupported activities in cohort statistics
- do not claim improvement when only partial data is available
- show `unavailable` or `not provided` in presentation copy when relevant
- expose valid sample count whenever a metric is partially populated

## Power Provenance Contract

Power-based comparison requires explicit provenance.

Recommended power fields:

- `average_power_w`
- `average_power_origin`
- `average_power_confidence`
- `power_source_system`
- `power_measurement_method`

Recommended `average_power_origin` values:

- `official_activity`
- `governed_derived`
- `estimated`
- `unavailable`

Power comparisons should only be treated as valid when source system and measurement method are consistent across the cohort or clearly labeled.

## Data Validity Rules

Comparison is valid only when:

- the workout family matches
- the structure type matches
- the primary purpose matches
- the governed tolerance range is satisfied
- the metric source is consistent
- terrain and environment differences are acceptable or labeled
- sample count is sufficient

If these conditions are not met, the system should provide inspection value without claiming comparison validity.

## API Response Shape

The comparison API should return resolved cohort and metric values together.

Example:

```json
{
  "activityId": "23670416465",
  "comparisonDefinitionId": "easy-continuous-aerobic-base-distance-10pct",
  "analysisScope": "whole_activity",
  "cohort": {
    "sampleCount": 12,
    "validPowerSampleCount": 9
  },
  "metrics": {
    "averagePaceSecPerKm": 396,
    "averageHeartRateBpm": 138,
    "averagePowerW": 234,
    "paceDeltaSec": -14,
    "paceChangeDirection": "faster",
    "paceChangeMagnitudeSec": 14,
    "staminaDrop": 24
  },
  "comparison": {
    "medianPaceSecPerKm": 400,
    "pacePercentile": 67,
    "heartRatePercentile": 54,
    "staminaDropPercentile": 82
  },
  "languageLevel": "long_term_distribution",
  "validity": "valid"
}
```

## Output Language Levels

Presentation copy should follow sample size and validity state.

Recommended levels:

- `data_only`
- `current_observation`
- `recent_trend`
- `long_term_distribution`

Recommended thresholds:

- 1 to 2 valid samples: `data_only`
- 3 to 4 valid samples: `current_observation`
- 5 to 9 valid samples: `recent_trend`
- 10 or more valid samples: `long_term_distribution`

Trend language must not imply causation.

High heat, terrain, shoe, or sequence differences must add a condition note when they materially affect comparison.

## Validation Matrix

The comparison model should be validated against at least the following cases:

- one activity only
- three activities
- five activities
- distance outside tolerance
- stride work present
- fast finish present
- average power missing
- segment power present but activity average missing
- high temperature sample
- different power sources
- no valid anchor
- tail fragment should not become finish anchor

## Relationship To Other Documents

This document should be read together with:

- [`CoachOS Chart Requirements Specification v0.1.md`](./CoachOS%20Chart%20Requirements%20Specification%20v0.1.md)
- [`CoachOS Chart Semantic View and Data Field Mapping v0.1.md`](./CoachOS%20Chart%20Semantic%20View%20and%20Data%20Field%20Mapping%20v0.1.md)
- [`CoachOS Chart Rendering Contract v0.1.md`](../20_Architecture/CoachOS%20Chart%20Rendering%20Contract%20v0.1.md)
- [`Semantic Layer v1.0.md`](../30_Physical_Model/Semantic%20Layer%20v1.0.md)
- [`CoachOS Chart API Payload Examples v0.1.md`](../20_Architecture/CoachOS%20Chart%20API%20Payload%20Examples%20v0.1.md)

## Status

`CoachOS Similar Workout Comparison Data Model and Metric Calculation Specification v0.1`

- Status: Draft
- Scope: Comparison cohort, anchor, metric, validity, and API contract
- Classification: Governance / Data Model Specification
