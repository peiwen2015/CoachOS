# CoachOS Similar Workout Comparison Expected Results v0.1

## Purpose

This document records the expected outputs for the fixture data in `CoachOS Similar Workout Comparison Fixture Data v0.1.sql`.

It is used to verify:

- cohort membership
- anchor selection
- scope handling
- metric direction and magnitude
- sample-count gating
- missing data behavior
- language level gating

## Fixture Assumptions

- `comparison_definition_id` is not yet seeded as a runtime table row in this fixture file.
- the expected outputs below assume a governed comparison definition equivalent to the following:

```text
easy-continuous-aerobic-base-distance-10pct
```

- `tolerance_basis = distance`
- `distance_tolerance_pct = 10`
- `include_current_activity_in_baseline = false`
- `minimum_comparison_samples = 3`
- `minimum_trend_samples = 5`

## Cohort Definitions

### Cohort A | Easy Run

Intended rule:

- workout family: `easy_run`
- structure type: `continuous`
- primary training purpose: `aerobic_base`
- distance tolerance: ±10%
- exclusions: stride, progression, fast finish, quality segments

Expected eligible activities:

- E01
- E02
- E03
- E08
- E09
- E10

Expected excluded activities:

- E04 outside distance tolerance
- E05 stride session
- E06 progression session
- E07 fast finish session

### Cohort B | Recovery Run

Expected eligible activities:

- R1
- R2
- R3
- R4

### Cohort C | Tempo

Expected eligible activities:

- T1
- T2

Expected scope:

- `main_segment`

### Cohort D | Interval

Expected eligible activities:

- I1
- I2

Expected scope:

- `work_intervals`

## Expected Results Table

### Easy Run Cases

| activity_id | case | expected eligibility | exclusion reason | analysis_scope | expected validity | expected language level | expected notes |
|---|---|---|---|---|---|---|---|
| 101 | E01 | true | none | whole_activity | valid | recent_trend | baseline easy run |
| 102 | E02 | true | none | whole_activity | valid | recent_trend | within distance tolerance |
| 103 | E03 | true | none | whole_activity | valid | recent_trend | upper distance boundary |
| 104 | E04 | false | outside distance tolerance | whole_activity | excluded | data_only | outside tolerance |
| 105 | E05 | false | stride work present | whole_activity | excluded | data_only | contains strides |
| 106 | E06 | false | progression work present | whole_activity | excluded | data_only | progression session |
| 107 | E07 | false | fast finish present | whole_activity | excluded | data_only | fast finish runner |
| 108 | E08 | true | none | whole_activity | partial | recent_trend | power missing |
| 109 | E09 | true | none | whole_activity | partial | recent_trend | different power source |
| 110 | E10 | true | none | whole_activity | valid | recent_trend | high temperature note |

### Recovery Cases

| activity_id | case | expected eligibility | exclusion reason | analysis_scope | expected validity | expected language level | expected notes |
|---|---|---|---|---|---|---|---|
| 111 | R1 | true | none | whole_activity | valid | current_observation | recovery sample 1 |
| 112 | R2 | true | none | whole_activity | valid | current_observation | recovery sample 2 |
| 113 | R3 | true | none | whole_activity | valid | current_observation | recovery sample 3 |
| 114 | R4 | true | none | whole_activity | valid | current_observation | recovery sample 4 |

### Tempo Cases

| activity_id | case | expected eligibility | exclusion reason | analysis_scope | expected validity | expected language level | expected notes |
|---|---|---|---|---|---|---|---|
| 115 | T1 | true | none | main_segment | valid | data_only | tempo with main segment |
| 116 | T2 | true | none | main_segment | insufficient | data_only | tempo missing structure rows |

### Interval Cases

| activity_id | case | expected eligibility | exclusion reason | analysis_scope | expected validity | expected language level | expected notes |
|---|---|---|---|---|---|---|---|
| 117 | I1 | true | none | work_intervals | valid | data_only | interval 4x1k |
| 118 | I2 | true | none | work_intervals | partial | data_only | interval with one missing rep |

## Anchor Expectations

### E01 Normal 8K

Expected split anchors:

- start anchor: split 1
- mid anchor: split 4
- finish anchor: split 8

Expected finish behavior:

- the last full kilometer is valid as the finish anchor

### E10 8K With Tail Fragment

Expected split anchors:

- start anchor: split 1
- mid anchor: split 4
- finish anchor: split 8

Expected finish behavior:

- the 11 m tail fragment must not become the finish anchor

### E04 Outside Tolerance

Expected:

- excluded before anchor reasoning is used for comparison output

### Tempo Anchor Expectations

For T1:

- start anchor: warmup stable section or first meaningful scope split
- mid anchor: middle of main segment
- finish anchor: end of main segment or final cooldown-adjacent representative split depending on scope rule

For T2:

- scope should be insufficient if the governed main segment cannot be determined from the structure

### Interval Anchor Expectations

For I1:

- start anchor: first work rep
- mid anchor: second or third work rep, depending on governed midpoint logic
- finish anchor: final work rep

For I2:

- if the missing rep makes the work set incomplete, the activity remains comparable only as a partial record

## Metric Expectations

### Easy Run Representative Values

For E01:

- `pace_delta_sec`: negative
- `pace_change_direction`: `faster`
- `pace_change_magnitude_sec`: positive integer
- `comparison_validity_status`: `valid`

For E08:

- `average_power_w`: `NULL`
- `valid_power_sample_count`: lower than eligible cohort size
- `comparison_validity_status`: `partial`
- power-based comparison should be reference-only

For E09:

- `average_power_w`: present
- `average_power_origin`: not equal to `official_activity` or `governed_derived`
- `valid_power_sample_count`: reduced or partial depending on governed power provenance rule

For E10:

- `condition_note_required`: `1`
- heat note must be visible because temperature is materially higher than the rest of Cohort A

### Recovery Run Sample-Count Gating

- 2 activities: `data_only`
- 3 activities: `current_observation`
- 4 activities: `current_observation`

### Metric Delta Threshold

The fixture assumes:

- `pace_stability_threshold_sec = 3`

Expected threshold behavior:

- `-3` → `stable`
- `+3` → `stable`
- `-4` → `faster`
- `+4` → `slower`

## Cohort Count Expectations

### Easy Run Cohort

If the comparison definition is applied to the Easy Run cohort and current activity is excluded from baseline:

- eligible comparison set should contain 6 activities
- excluded activities should be 4 activities
- valid comparison text should be allowed
- recent-trend language should be allowed

### Recovery Run Cohort

- valid sample count should be 4
- current-observation language should be allowed

### Tempo Cohort

- valid sample count should be 2
- data-only language should remain in effect for cohort copy

### Interval Cohort

- valid sample count should be 2
- data-only language should remain in effect for cohort copy

## Expected Failure Modes

The fixture is also designed to fail clearly if the implementation is wrong.

### Cohort Failures

- activity name matching creates a different cohort than workout family matching
- E04 is included despite being outside tolerance
- E05, E06, or E07 are included despite explicit exclusions

### Anchor Failures

- the 11 m tail fragment becomes the finish anchor
- the finish anchor is inferred from the last row without a governed rule

### Scope Failures

- T1 or T2 is not mapped to `main_segment`
- I1 or I2 is not mapped to `work_intervals`
- continuous easy runs are not mapped to `whole_activity`

### Percentile Failures

- a cohort of 4 activities is described as a long-term distribution
- a cohort of 2 activities is described as a recent trend
- power percentile is computed from missing power values

### Missing Data Failures

- E08 is treated as fully valid power comparison
- E09 is treated as an official-power record when provenance is not official
- E10 is not marked with a condition note

## Validation Notes

This fixture set is intentionally small and overlapping.

Its goal is not to model every real workout type.

Its goal is to force the contract to answer the governed questions with the smallest possible amount of data.

## Status

`CoachOS Similar Workout Comparison Expected Results v0.1`

- Status: Draft
- Scope: Expected outputs for fixture-based validation
- Classification: Architecture / Validation Working Document
