# ADR-004 Remove Derived Pace from Activity

## Status

Accepted

## Context

`avg_pace_sec_per_km` was included in early `activity` LDM drafts for dashboard convenience.

Metadata Repository v1.1 classifies average pace as:

- Acquisition Method: FIT Derived
- Lifecycle: Derived

Metadata Design Standard Rule 06 says derived data should not be stored in core fact tables by default.

## Decision

Remove `avg_pace_sec_per_km` from the core `activity` fact table.

Expose average pace through a view, query, or analysis layer:

```sql
ROUND(duration_sec * 1.0 / distance_km) AS avg_pace_sec_per_km
```

## Consequences

- Core `activity` stores raw distance and duration.
- Dashboard can still display average pace via view/query.
- If a future performance reason requires materialization, it must be explicitly justified and documented.

