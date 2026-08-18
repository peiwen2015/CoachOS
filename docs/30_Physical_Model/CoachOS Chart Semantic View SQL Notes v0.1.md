# CoachOS Chart Semantic View SQL Notes v0.1

## Purpose

This note records the calculation dependencies and current draft assumptions for the chart semantic SQL layer.

It exists so the SQL draft does not accidentally become treated as the final metric definition.

## Dependency List

The following metrics should be treated as governed dependencies before the SQL draft is considered final:

- `Training Load`
- `Acute / Chronic Load`
- `Heart-rate Drift`
- `Aerobic Decoupling`
- `Target Compliance`
- `Late-session Fade`
- `Intensity Zone Distribution`

## Current Draft Assumptions

### Training Load

- Current schema already stores `activity.training_load`.
- Weekly charts can roll this up directly.
- If a source activity has no training load, the weekly chart should surface the gap rather than inventing a substitute.

### Acute / Chronic Load

- Acute load is treated as the current week value.
- Chronic load is treated as a trailing 4-week average in the SQL draft.
- This formula is practical for a chart draft, but it should still be reviewed against the product's coaching policy.

### Heart-rate Drift

- The draft uses kilometer split rows and compares first half versus second half.
- This requires enough split rows with valid heart-rate values.
- Sparse heart-rate sampling should suppress the stronger decoupling verdict.

### Aerobic Decoupling

- The draft expresses decoupling as a combined pace-change plus heart-rate-change signal.
- This is a charting proxy, not a final physiological definition.
- The final definition should be validated against the coaching team’s preferred interpretation.

### Target Compliance

- The current schema has planned workout steps and workout splits, but it does not provide a guaranteed one-to-one execution mapping.
- The draft therefore uses a best-effort step-index alignment.
- If that alignment proves unstable in real data, the execution segment view should be reworked before implementation.

### Late-session Fade

- The draft does not write verdict text into SQL.
- It only exposes first-half and second-half metrics so the rendering layer can judge fade.

### Intensity Zone Distribution

- The current schema governs `workout_type.intensity_category`.
- It does not yet govern a dedicated heart-rate-zone or power-zone table.
- The SQL draft therefore treats intensity category as the available periodized distribution source and defers true zone work to a later schema step.

## Known Gaps Exposed By The Draft

1. There is no governed race / recovery / taper flag in the current schema.
2. There is no canonical zone table for heart-rate or power zones.
3. There is no guaranteed execution-to-plan segment mapping for every workout structure.
4. There is no sample-level stream in the current draft beyond kilometer splits.
5. The current weekly rollups are rolling windows, not calendar weeks.

## Recommended Follow-Up

Before moving to the rendering contract, the following should be clarified:

- whether weekly charts should use rolling windows or calendar weeks
- whether target compliance should be judged by time, distance, pace, or a weighted blend
- whether intensity distribution should be based on workout type, heart rate zones, or power zones
- whether the execution segment model needs a dedicated alignment table

## Status

`CoachOS Chart Semantic View SQL Notes v0.1`

- Status: Draft
- Scope: Calculation dependencies and semantic assumptions
- Classification: Governance / Metric Notes
