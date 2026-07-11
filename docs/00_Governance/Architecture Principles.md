# Architecture Principles

## Purpose

These principles define the long-term design philosophy of the Personal Running Intelligence Platform.

They are higher-level than implementation rules and broader than individual ADRs.

## Principle 1: Metadata Before Implementation

Every data element must be governed before it is implemented.

Parser, Excel, SQLite, Dashboard, and AI Coach changes should start from the Metadata Repository.

## Principle 2: One Fact, One Place

Each fact should have one authoritative source of truth.

When FIT, Garmin Connect, Weather API, manual input, or AI output overlap, the Metadata Repository decides precedence.

## Principle 3: Raw Over Derived

Core fact tables prioritize raw observations and manual inputs.

Derived metrics should be calculated through views, queries, or the analysis layer unless materialization is explicitly justified.

## Principle 4: Intent Is Immutable

Training intent must not be overwritten by training outcome.

For example, a workout intended as `threshold` remains `threshold` even if heat, fatigue, or pacing causes the actual stimulus to resemble VO2max.

## Principle 5: Views Over Duplicated Data

When a value can be reliably calculated from governed source fields, prefer a view or query over duplicating the value in a core table.

## Principle 6: Decisions Must Be Traceable

Important architecture decisions must be recorded as ADRs.

Future contributors should be able to understand not only what was decided, but why it was decided.

## Principle 7: Granularity Drives Modeling

Data belongs at its natural grain.

Activity-level data belongs in `activity`; split-level data belongs in `kilometer_split`; daily health data belongs in `health_daily`; analysis output belongs in the analysis layer.

## Principle 8: Governance Enables Speed

Architecture governance should reduce rework.

The goal is not slower development; the goal is fewer ambiguous decisions, fewer duplicate definitions, and faster implementation once the model is approved.

