# CoachOS Comparison Certification Checklist v0.1

## Purpose

This document is not a comparison feature spec.

It is a certification checklist for verifying that the governed comparison contract can be executed reliably against real or fixture data.

The goal is to confirm that the current contract can actually be computed before expanding API or presentation layers.

## Scope

This checklist applies to:

- similar workout comparison cohort logic
- comparison anchor selection
- comparison metric calculation
- percentile and cohort statistics
- missing data behavior
- output language gating
- SQLite draft views and fixture queries

It does not define new metrics.

It does not define new product copy beyond validation expectations.

## Certification Rule

A comparison implementation is not certified until every required case passes.

Passing means:

- the SQL produces the expected grain
- the cohort rules behave as governed
- the anchor rules do not drift into guesswork
- the metric direction and magnitude are consistent
- the sample-count language is correct
- missing values degrade without inventing facts

## Required Test Set

The certification run should include both fixture data and real historical data where available.

Minimum validation set:

- one activity only
- three activities
- five activities
- distance outside tolerance
- duration outside tolerance
- stride work present
- fast finish present
- quality segments present
- average power missing
- segment power present but activity average missing
- high temperature sample
- different power sources
- no valid anchor
- tail fragment should not become finish anchor

## Cohort Certification

### Required Checks

☐ `workout_family` is the primary grouping field

☐ `structure_type` is the primary grouping field

☐ `primary_training_purpose` is the primary grouping field

☐ activity name is not used as the join key for similarity

☐ distance tolerance is applied when `tolerance_basis = distance`

☐ duration tolerance is applied when `tolerance_basis = duration`

☐ tolerance logic does not require both distance and duration unless explicitly configured

☐ `stride` sessions are excluded when governed rules say they should be excluded

☐ `progression` sessions are excluded when governed rules say they should be excluded

☐ `fast finish` sessions are excluded when governed rules say they should be excluded

☐ `quality segments` are excluded when governed rules say they should be excluded

☐ the comparison set reports the correct `cohort_sample_count`

☐ the comparison set reports metric-specific valid sample counts

### Failure Signals

Certify as failed if any of the following occurs:

- cohort membership changes only because of activity name differences
- the current activity is counted incorrectly
- tolerance rules behave differently across equivalent cohorts
- excluded workout types leak into the cohort
- sample counts disagree with the visible cohort size

## Anchor Certification

### Required Checks

☐ `start_anchor` is selected from an early stable section

☐ `mid_anchor` reflects approximate halfway position

☐ `finish_anchor` reflects a real finish section, not a tail fragment

☐ anchor selection uses completion position rather than fixed kilometer labels

☐ anchor validity is explicit

☐ invalid anchors suppress stronger metric claims

### Failure Signals

Certify as failed if any of the following occurs:

- a short tail fragment is accepted as the finish anchor
- a 7.8 km and an 8.0 km activity force the same fixed kilometer anchors when the split structure does not support it
- anchor validity is inferred in the front-end instead of coming from the governed layer

## Scope Certification

### Required Checks

☐ `whole_activity` is used for continuous easy runs

☐ `main_segment` is used only when a meaningful main segment exists

☐ `work_intervals` is used only for interval work

☐ `final_20_percent` is used only for late-run comparison

☐ scope selection matches workout structure

☐ scope label is exposed in the output

### Failure Signals

Certify as failed if any of the following occurs:

- a single continuous run is labeled as `main_segment`
- interval sessions are collapsed into whole-activity averages without warning
- scope changes between SQL and API layers

## Metric Certification

### Required Checks

☐ pace delta direction is correct

☐ pace delta magnitude is separate from direction

☐ `stable` is used when the delta is within the governed stability threshold

☐ heart-rate delta sign is consistent

☐ power delta sign is consistent

☐ pace range is computed from the selected scope

☐ pace variability does not use a hidden or undocumented formula

☐ stamina drop is computed consistently with the governed definition

### Direction Rules

- lower pace later in the activity means `faster`
- higher pace later in the activity means `slower`
- absolute change within the threshold means `stable`

### Failure Signals

Certify as failed if any of the following occurs:

- faster and slower are flipped
- a negative delta is shown without explanation
- a magnitude is shown without a direction
- the SQL formula and presentation copy disagree

## Percentile Certification

### Required Checks

☐ percentile is computed from the correct cohort

☐ percentile direction is documented for every metric

☐ pace percentile does not get interpreted as a generic quality score

☐ heart-rate percentile is treated as distribution position only

☐ stamina drop percentile is treated as distribution position only

☐ power percentile uses only valid power samples

☐ current activity inclusion or exclusion follows the governed baseline rule

### Failure Signals

Certify as failed if any of the following occurs:

- higher percentile is treated as better for every metric
- low heart rate automatically becomes a better score
- current activity contaminates the baseline when the rule says it should not

## Missing Data Certification

### Required Checks

☐ missing values are not replaced with zero

☐ estimated values are clearly labeled

☐ partial data is distinguishable from unavailable data

☐ unsupported activities are excluded from the relevant calculation

☐ the chart or API response exposes valid sample counts

☐ power-missing cases fall back to reference-only behavior

☐ heart-rate-missing cases suppress strong verdicts

☐ environment-missing cases add a condition note when needed

### Failure Signals

Certify as failed if any of the following occurs:

- zero is used as a fake missing value
- incomplete power data is treated as fully measured
- partial data is presented as fully valid
- missing values silently disappear without any note or count

## Language Certification

### Required Checks

☐ sample count 1 to 2 yields data-only language

☐ sample count 3 to 4 yields current-observation language

☐ sample count 5 to 9 yields recent-trend language

☐ sample count 10 or more yields long-term-distribution language

☐ trend language does not imply causation

☐ condition notes are shown when heat, terrain, shoe, or sequence differences matter

### Failure Signals

Certify as failed if any of the following occurs:

- sample count 4 is described as a trend
- sample count 2 is described as a long-term pattern
- the copy claims improvement without supported evidence

## SQL View Certification

### View 1: `activity_comparison_base_view`

☐ activity-level comparison fields are normalized

☐ workout family and structure type are exposed

☐ power provenance fields are present

☐ stamina start and end are preserved

☐ cohort inputs are surfaced without front-end reconstruction

### View 2: `activity_comparison_anchor_view`

☐ start, mid, and finish anchors are produced

☐ anchor validity is explicit

☐ tail fragments do not become finish anchors

☐ anchor positions are percentage-based rather than fixed kilometer labels

### View 3: `activity_comparison_metric_view`

☐ scope metrics are computed from the governed anchors or selected scope

☐ delta fields are present

☐ validity is explicit

☐ variability metrics are based on the selected scope

### View 4: `similar_workout_comparison_view`

☐ cohort statistics are exposed

☐ sample counts are metric-specific

☐ percentile output is present

☐ comparison validity is present

☐ language level is present

## Certification Threshold

The comparison stack is considered ready for API shaping only when:

- all required checks pass
- no failure signals are observed in the fixture set
- at least one real historical cohort produces a valid comparison
- at least one small cohort correctly degrades language and confidence

If the stack passes fixture validation but fails real-data validation, the SQL draft is not certified.

## Status

`CoachOS Comparison Certification Checklist v0.1`

- Status: Draft
- Scope: Validation-first certification for similar workout comparison SQL and semantics
- Classification: Architecture / Validation Working Document
