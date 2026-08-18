# CoachOS Chart Requirements Specification v0.1

## Purpose

This document defines the minimum specification structure for CoachOS charts.

It turns chart priorities into implementable requirements.

It should be used after `CoachOS Chart Priorities v0.1` and before any dashboard implementation work.

## Scope

This specification applies to:

- dashboard charts
- review charts
- future coaching charts
- chart-driven summaries that rely on semantic views

It does not define visual polish in detail.

It defines what each chart must be able to answer, measure, and validate.

## Standard Requirement Fields

Every chart specification should define the following fields.

### 1. Decision Question

State the single coaching question the chart must answer.

This question is the chart's purpose.

### 2. Eligible Activities

State which workout types, run types, or activity contexts can appear in the chart.

Examples:

- easy runs
- long runs
- interval sessions
- recovery weeks
- race weeks

### 3. Required Data

State the minimum fields needed for the chart to render correctly.

Examples:

- date
- duration
- distance
- pace
- heart rate
- power
- elevation
- workout type
- training purpose

### 4. Derived Metrics

State which calculated values the chart needs.

Examples:

- weekly load
- acute / chronic ratio
- heart-rate drift
- decoupling percentage
- split variance
- completion rate

### 5. Comparison Baseline

State what the chart compares against.

Examples:

- previous week
- previous 4-week average
- target pace
- target range
- similar past runs

### 6. Chart Encoding

State how the data should be encoded visually.

Examples:

- x-axis
- y-axis
- background phase bands
- target bands
- annotations
- threshold lines
- highlight state

### 7. Verdict Rules

State how the chart should generate an automatic interpretation.

This should include:

- positive case
- warning case
- caution case
- confidence level

### 8. Missing Data Behavior

State how the chart should degrade when data is incomplete.

Examples:

- hide the chart
- show a partial-view warning
- remove a secondary metric
- lower confidence
- explain why the verdict is weaker

### 9. Drill-down Fields

State what should be shown when the user clicks into the chart.

Examples:

- pace
- heart rate
- power
- cadence
- elevation
- kilometer splits

### 10. Validation Cases

State which real or synthetic cases will be used to verify the chart.

Validation should confirm:

- the chart answers the intended question
- the verdict is reasonable
- the chart does not mislead when data is incomplete
- the chart remains stable across the intended activity types

### 11. Comparison Cohort Rules

State the exact rules for which activities are allowed into the comparison set.

This must include:

- required inclusion fields
- explicit exclusions
- acceptable tolerance ranges
- minimum sample size for comparison text
- minimum sample size for trend text

### 12. Analysis Scope

State which part of the activity the chart is analyzing.

Examples:

- whole activity
- main segment
- work intervals
- final 20 percent

The scope must match the workout structure.

### 13. Data Availability And Degradation Rules

State how data availability affects rendering, comparison, and verdicts.

Data availability rules must distinguish between:

- missing
- zero
- partial
- estimated

### 14. Output Language Rules

State what language the product may use at different sample sizes.

Examples:

- 1 to 2 samples: show data only, no trend claim
- 3 to 4 samples: current observation
- 5 to 9 samples: recent trend
- 10 or more samples: long-term distribution

Trend statements must not imply causation.

## Platform Chart MVP

The first chart release should define these four charts.

### 1. Weekly Training Load Trend

- Decision Question: Am I progressing steadily, undertraining, or increasing load too fast?
- Eligible Activities: all training weeks with sufficient volume history
- Required Data: date, distance, duration, training load, weekly grouping
- Derived Metrics: weekly load, weekly load change, acute / chronic ratio, abnormal jump detection
- Comparison Baseline: previous week and recent 8 to 12 week trend
- Chart Encoding: line chart with background phase bands and annotation markers
- Verdict Rules: label steady build, caution on abrupt jumps, warn on uncontrolled spikes
- Missing Data Behavior: show distance and duration only if training load is unavailable
- Drill-down Fields: workout list, daily load, weekly split by workout type
- Validation Cases: stable build, recovery week, race week, sudden spike, incomplete month

### 2. Goal vs Actual Workout Completion

- Decision Question: Did I complete the session the way it was intended?
- Eligible Activities: structured workouts, interval sessions, target-paced long runs
- Required Data: planned target, actual pace or effort, interval structure, completion status
- Derived Metrics: target deviation, set average, late-session fade, completion rate
- Comparison Baseline: workout plan or target range
- Chart Encoding: target band plus actual line or bar sequence
- Verdict Rules: label on-target, slightly off-target, and missed target patterns
- Missing Data Behavior: fall back to actual-only view if target plan is missing
- Drill-down Fields: each interval, split detail, heart rate, cadence, power
- Validation Cases: clean execution, early fast start, mid-session fade, skipped interval

### 3. Pace and Heart Rate Decoupling

- Decision Question: Did the run stay stable, or did efficiency fall apart late?
- Eligible Activities: easy runs and long runs with steady pacing
- Required Data: pace, heart rate, time or split sequence
- Derived Metrics: first-half versus second-half pace change, heart-rate drift, decoupling percentage
- Comparison Baseline: first half of the same run, or a comparable recent run
- Chart Encoding: dual-axis trend or split comparison view
- Verdict Rules: label stable, moderate drift, or clear late-session loss of efficiency
- Missing Data Behavior: hide drift verdict if heart-rate sampling is too sparse
- Drill-down Fields: segment pace, segment heart rate, elevation, temperature if available
- Validation Cases: steady long run, hot-weather drift, route-change distortion, negative split

### 4. Weekly Intensity Distribution

- Decision Question: Is my training really low-intensity dominant, or am I accumulating too much hard work?
- Eligible Activities: weekly and rolling-period summaries
- Required Data: workout classification, time in zone, pace zone or heart-rate zone
- Derived Metrics: zone percentage, low / moderate / high share, weekly change
- Comparison Baseline: last 7 days, last 4 weeks, or this workout
- Chart Encoding: horizontal stacked bar chart
- Verdict Rules: label low-dominant, balanced, or high-intensity heavy
- Missing Data Behavior: switch to the best available zone system and explain the fallback
- Drill-down Fields: time in zone by activity, workout type mix, weekly hard sessions
- Validation Cases: recovery week, polarized week, threshold-heavy week, missing zone data

## Comparison Cohort Rules

Charts that compare "similar workouts" must not rely on workout name alone.

The comparison cohort should be defined by:

- workout family
- structure type
- primary purpose
- acceptable distance or duration tolerance
- explicit exclusions

Recommended defaults:

- required inclusion fields: workout family, structure type, primary purpose
- tolerance range: distance or duration within plus or minus 10 percent
- exclusions: stride work, progression work, fast-finish sessions, quality segments unless explicitly included
- optional filters: temperature, humidity, shoe, route, terrain, sequence role, training block position
- minimum sample count for showing comparison text: 3
- minimum sample count for trend language: 5

Example comparison cohort for an 8K Easy Run:

- workout_family = Easy Run
- structure_type = Continuous Run
- primary_purpose = Aerobic Base
- distance_km between 7.2 and 8.8
- stride_count = 0
- quality_segment_count = 0
- fast_finish = false

## Analysis Scope Rules

The analysis scope must match the workout structure and the chart label.

Recommended scope values:

- `whole_activity`
- `main_segment`
- `work_intervals`
- `final_20_percent`

Examples:

- Easy Run: `whole_activity`
- Tempo: `main_segment`
- Interval: `work_intervals`
- LSD: `whole_activity` plus `final_20_percent`

Do not label a scope as "main segment" when the workout does not have a meaningful main segment.

## Delta And Direction Rules

Delta fields must store direction and magnitude separately when the business meaning depends on "faster" versus "slower".

Recommended fields:

- `pace_delta_sec`
- `pace_change_direction`
- `pace_change_magnitude_sec`

Direction values:

- `faster`
- `slower`
- `stable`

Display rules:

- negative pace delta should render as "later faster" when faster means a smaller pace value
- positive pace delta should render as "later slower"
- absolute change less than or equal to 3 seconds should render as "roughly even"

## Data Validity Rules

Heart rate, power, and pace relationships should only be compared when the underlying data is comparable.

Comparison is valid only when:

- the power field is an official activity-level value or a governed derived value
- power source is consistent across the comparison set
- workout structure matches
- terrain differences are acceptable
- temperature differences are within the configured range or clearly labeled
- sample count is sufficient

If those conditions are not met, the product should show the data as reference only and avoid claiming improvement.

## Missing Data Rules

When a metric is missing:

- do not substitute zero
- do not backfill with unofficial estimates unless the field is explicitly marked estimated
- do not derive an official activity average from incomplete segment data unless that is the governed definition
- exclude the activity from the relevant chart calculation
- show `not provided` or `unavailable` in the tooltip or fallback text
- show the number of valid samples in the chart header when partial inclusion is possible

Example:

- `Power-Heart Rate Relationship`
- `Valid samples: 8 / 12 activities`

## Similar Workout Comparison MVP

The comparison feature release should be split into two stages.

### MVP 1

1. Similar workout list
2. Single-metric time trend chart
3. Comparison summary cards
4. Single activity versus cohort median comparison

### MVP 2

5. Start-mid-finish comparison chart
6. Power-versus-heart-rate scatter chart
7. Percentile band overlay
8. Environment and shoe filters

## Output Language Rules

The product should not claim progress from only one or two samples.

Recommended language by valid sample count:

| Valid samples | Allowed language |
|---:|---|
| 1 to 2 | show data only, no trend claim |
| 3 to 4 | current observation, initial pattern |
| 5 to 9 | recent trend, compare to personal median |
| 10+ | long-term distribution, percentile-based language |

Trend statements must not be written as causal claims.
High heat, terrain, shoe, or sequence differences must add a condition note.

## Semantic View Expectations

When a chart becomes reusable, its source data should be mapped to a semantic view rather than reassembled ad hoc in the dashboard.

This mapping should define:

- required base fields
- grouping rules
- window rules
- filter rules
- verdict inputs

## Validation Rules

Before a chart is considered ready, it should pass the following checks:

1. The chart answers exactly one decision question.
2. The required data is available from governed sources.
3. The verdict can be explained in one sentence.
4. The chart has a clear fallback when data is missing.
5. The validation cases include both a normal case and an edge case.

## Relationship to Other Documents

This document should be read together with:

- [`CoachOS Chart Priorities v0.1.md`](./CoachOS%20Chart%20Priorities%20v0.1.md)
- [`CoachOS Chart Semantic View and Data Field Mapping v0.1.md`](./CoachOS%20Chart%20Semantic%20View%20and%20Data%20Field%20Mapping%20v0.1.md)
- [`CoachOS Chart Rendering Contract v0.1.md`](../20_Architecture/CoachOS%20Chart%20Rendering%20Contract%20v0.1.md)
- [`Product Design Principles v1.0.md`](./Product%20Design%20Principles%20v1.0.md)
- [`CoachOS Interaction Principles v1.0.md`](./CoachOS%20Interaction%20Principles%20v1.0.md)
- [`Product UX Polish Sprint v1.0.md`](./Product%20UX%20Polish%20Sprint%20v1.0.md)
- [`Monthly Coach Briefing v0.1.md`](../20_Architecture/Monthly%20Coach%20Briefing%20v0.1.md)

## Status

`CoachOS Chart Requirements Specification v0.1`

- Status: Draft
- Scope: Chart definition, semantic mapping, and validation structure
- Classification: Governance / Chart Specification
