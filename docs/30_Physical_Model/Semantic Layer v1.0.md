# Semantic Layer v1.0

## Purpose

This layer provides product-facing, reusable semantic views on top of the Core Canonical Data Layer and SQLite Schema v1.0.

It is the contract between:

- SQLite storage
- query tools
- Dashboard App
- future AI Coach / chat experiences

## Design Position

The Semantic Layer does not redefine facts.

It reorganizes governed canonical data into stable, reusable review and intelligence views so product code does not have to re-implement the same SQL logic repeatedly.

## Principles

- Semantic views read from governed canonical tables and core views only.
- Semantic views may calculate derived review metrics.
- Semantic views must not write back into core fact or dimension tables.
- Dashboard and product queries should prefer semantic views over direct table queries.
- If a product need can be solved once in SQL and reused many times, it belongs here.

## Scope

Included in v1.0:

- `activity_review_view`
- `platform_summary_view`
- `monthly_summary_view`
- `current_month_summary_view`
- `current_month_intelligence_view`
- `current_month_training_distribution_view`
- `current_month_progress_view`
- `current_month_key_sessions_view`
- `current_month_assignment_quality_view`
- `weekly_summary_view`
- `current_week_summary_view`
- `current_week_intelligence_view`
- `training_distribution_view`
- `training_balance_view`
- `training_assignment_quality_view`
- `recent_training_intent_view`
- `shoe_comparison_view`
- `shoe_intelligence_view`
- `shoe_workout_comparison_view`
- `recent_activity_view`

Excluded from v1.0:

- long-term block periodization views
- recovery / health views
- race views
- AI-generated narrative outputs

## View Roles

`activity_review_view`

- One activity per row
- Adds review-oriented semantics:
  - workout context
  - shoe display name
  - primary training purpose
  - secondary training purposes
  - weather / subjective / performance context

`platform_summary_view`

- One row
- Overall archive metrics for the full dataset

`monthly_summary_view`

- One month per row
- Aggregates activity count, distance, time, average pace, average heart rate, and training load by calendar month

`current_month_summary_view`

- Latest month only
- Adds `is_partial_month` so product surfaces can distinguish month-to-date from a complete month

`current_month_intelligence_view`

- Current month plus previous 3-month baseline comparison
- Exposes:
  - distance delta
  - load delta
  - activity delta
  - load/km delta

`current_month_training_distribution_view`

- Current month only
- Aggregates workout and primary purpose mix for the latest month

`current_month_progress_view`

- Current month only
- Adds month progress semantics:
  - day of month
  - days in month
  - progress percentage
  - to-date reference targets based on the previous 3-month average

`current_month_key_sessions_view`

- Current month only
- Surfaces representative sessions such as:
  - longest run
  - highest load
  - fastest quality
  - lowest HR easy

`current_month_assignment_quality_view`

- Current month only
- Measures how much of the latest month is fully tagged and therefore safe for stronger coaching interpretation

`weekly_summary_view`

- Five rolling 7-day windows relative to the latest activity date
- Supports dashboard trend and baseline comparison

`current_week_summary_view`

- Current rolling 7-day summary only

`current_week_intelligence_view`

- Current week plus four-week baseline comparison
- Exposes:
  - distance delta
  - load delta
  - load/km delta
  - recovery status

`training_distribution_view`

- Aggregates activity count, distance, time, and load by:
  - workout type
  - primary training purpose

`training_balance_view`

- Aggregates activities by intensity category
- Intended for balance and training-mix review

`training_assignment_quality_view`

- One row
- Measures tagged vs unassigned training metadata coverage

`recent_training_intent_view`

- Recent activities with workout / purpose / intensity / shoe context
- Intended for product surfaces that review current training semantics

`shoe_comparison_view`

- Compares shoes using governed activity-level observations
- Keeps `shoe` as reference data and performs comparison here

`shoe_intelligence_view`

- Extends shoe comparison into tagged shoe-context intelligence
- Only treats activities with explicit workout labels as directly comparable intelligence inputs

`shoe_workout_comparison_view`

- Groups activities by shoe + workout type
- Intended for same-workout shoe comparison surfaces

`recent_activity_view`

- Activity review rows ordered by recency
- Intended as the standard source for “recent activity” product surfaces

## Data Flow

```text
Core Tables
  ↓
Core Views
  - activity_view
  - kilometer_split_view
  - activity_training_purpose_view
  - shoe_statistics_view
  ↓
Semantic Views
  - activity_review_view
  - monthly_summary_view
  - current_month_summary_view
  - current_month_intelligence_view
  - current_month_training_distribution_view
  - current_month_progress_view
  - current_month_key_sessions_view
  - current_month_assignment_quality_view
  - weekly_summary_view
  - training_balance_view
  - training_assignment_quality_view
  - recent_training_intent_view
  - shoe_comparison_view
  - shoe_intelligence_view
  - shoe_workout_comparison_view
  - training_distribution_view
  ↓
Query Layer / Dashboard / AI Coach
```

## Product Rule

Product code should avoid embedding canonical aggregation logic directly in Python or HTML when the same logic can be expressed once in SQL and reused.

## Status

`Semantic Layer v1.0`

- Status: Active
- Depends on: `SQLite Schema v1.0`
- Next step: Query Layer alignment and Dashboard adoption
