# CoachOS Chart Priorities v0.1

## Purpose

This document defines which chart types CoachOS should prioritize when adding statistical visuals to the product.

The goal is not to maximize the number of charts.

The goal is to prioritize charts that help runners and coaches make better training decisions.

This document should be read as a product and design guidance note for dashboard surfaces, review surfaces, and future coaching surfaces.

## Core Principle

Every chart should answer one coaching question.

If a chart does not help the user decide what to do, understand what happened, or judge whether training is on track, it should not be prioritized early.

## Priority Order

### 1. Weekly Training Load Trend

This is the first chart to build.

Recommended form:

- line chart with background phase bands
- optional annotations for recovery week, race week, or taper week

Recommended signals:

- weekly mileage
- weekly training time
- heart-rate load or training load
- acute / chronic load ratio, if the data is reliable enough
- weekly change percentage
- abnormal jump warning

Primary question:

`Am I progressing steadily, undertraining, or increasing load too fast?`

Suggested default view:

- last 8 to 12 weeks
- one-line interpretation below the chart

### 2. Goal vs Actual Workout Completion

This is the second chart to build.

Recommended form:

- target range band plus actual line
- per-interval or per-set comparison when the workout has repeats

Recommended signals:

- target pace or target effort range
- actual pace
- average by set or block
- set-to-set variance
- completion count
- late-session fade

Primary question:

`Did I complete the session the way it was intended?`

This chart should help the user see whether the workout was executed well, not just whether it was finished.

### 3. Pace and Heart Rate Decoupling

This is the third chart to build.

Recommended form:

- dual-axis line chart, or
- split first-half versus second-half comparison

Recommended signals:

- pace trend
- heart-rate trend
- first-half and second-half efficiency difference
- aerobic drift or decoupling percentage

Primary question:

`Did the run stay stable, or did efficiency fall apart late?`

This chart is especially valuable for easy runs and long runs.

### 4. Weekly Intensity Distribution

This is the fourth chart to build.

Recommended form:

- horizontal stacked bar chart

Recommended toggles:

- heart-rate zone distribution
- pace zone distribution
- power zone distribution, if available

Recommended time ranges:

- this workout
- last 7 days
- last 4 weeks

Primary question:

`Is my training really low-intensity dominant, or am I accumulating too much hard work?`

This chart should make the balance of low, moderate, and high intensity easy to compare across time windows.

## Secondary Priority

These charts are useful, but they should come after the four core charts above.

### 5. Long-Term Running Efficiency Trend

Recommended form:

- scatter plot with trend line

Useful comparisons:

- same pace versus average heart rate
- same heart rate versus average pace
- pace versus power
- heart rate versus power
- efficiency factor

Primary question:

`Am I becoming more economical over time?`

This chart needs filtering rules.

It should only compare similar runs, such as:

- easy runs
- flat routes
- similar temperatures
- 30 to 60 minute runs
- excluding races and interval sessions

### 6. Pace Stability and Split View

Recommended form:

- kilometer split bar chart

Recommended signals:

- split pace
- split heart rate
- split power
- elevation change
- difference from target pace

Primary question:

`Was my pacing even, or did I go out too fast and fade later?`

This chart is intuitive and shareable, but it is more useful once the core decision charts already exist.

## MVP Recommendation

The first release should include these four charts:

1. Weekly training load trend
2. Goal vs actual workout completion
3. Pace and heart-rate decoupling
4. Weekly intensity distribution

Together, these charts answer:

- am I doing enough
- am I doing too much
- is my intensity structure reasonable
- did I execute today's workout well
- is endurance holding up late in the run

## Design Rules

### One Chart, One Question

Each chart should answer one primary question.

Do not stack unrelated metrics into the same visual just because the data exists.

### Verdict Before Detail

Each chart should include a one-line interpretation.

Examples:

- `Training load has risen steadily for 6 weeks.`
- `This session matched target pace in the first half but faded late.`
- `Aerobic stability remains good, with minimal decoupling.`

### Progressive Disclosure

Users should be able to click a chart section to inspect the underlying segment.

Useful drill-down fields include:

- pace
- heart rate
- power
- cadence
- elevation

### Prefer Comparison Over Raw Density

Where possible, show change, range, or comparison instead of isolated values.

This makes the chart more useful as a decision aid.

### Avoid Decorative Charts

Do not add charts that look rich but do not change a decision.

If a chart does not help with training judgment, it should not be in the MVP.

## Product Position

CoachOS charts should support the product's coaching stance:

`observe -> understand -> decide -> improve`

Charts are evidence.

They are not the product outcome by themselves.

## Relationship to Other Documents

This document should be read together with:

- [`Product Design Principles v1.0.md`](./Product%20Design%20Principles%20v1.0.md)
- [`CoachOS Interaction Principles v1.0.md`](./CoachOS%20Interaction%20Principles%20v1.0.md)
- [`Product UX Polish Sprint v1.0.md`](./Product%20UX%20Polish%20Sprint%20v1.0.md)
- [`Monthly Coach Briefing v0.1.md`](../20_Architecture/Monthly%20Coach%20Briefing%20v0.1.md)

## Status

`CoachOS Chart Priorities v0.1`

- Status: Draft
- Scope: Dashboard App, review surfaces, and future coaching surfaces
- Classification: Governance / Chart Prioritization Standard
