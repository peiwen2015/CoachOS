# ADR-002 Metadata Repository as SSOT

## Status

Accepted

## Context

The same data item may appear in multiple places: FIT, Garmin Connect, Weather API, manual input, SQLite, Excel, dashboard, and AI Coach outputs.

Without a single source of truth, later implementations may disagree on source precedence, data type, nullability, lifecycle, and table placement.

## Decision

`Running Analytics Metadata Repository` is the single source of truth for platform data definitions.

It governs:

- Source of Truth
- Granularity
- Acquisition Method
- Data Type
- Required / Nullable
- Lifecycle
- Priority
- Business Rule
- Validation Rule

## Consequences

- LDM and SQLite schema must be validated against the Metadata Repository.
- Parser behavior must follow Metadata Repository definitions.
- Dashboard and AI Coach should not invent ungoverned fields.
- Any future conflict between implementation and metadata should be resolved by updating or validating against the Metadata Repository first.

