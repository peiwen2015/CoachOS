# ADR-005 Derived Pace via Views

## Status

Accepted

## Context

Pace values are convenient for dashboard and analysis, but activity-level and split-level pace can be derived from governed raw fields:

- Activity pace = duration / distance
- Split pace = elapsed split time / split distance

Metadata Repository v1.1 classifies pace fields as:

- Acquisition Method: FIT Derived
- Lifecycle: Derived

Metadata Design Standard Rule 06 says derived data should not be stored in core fact tables by default.

## Decision

Pace fields should not be stored in core fact tables by default.

They should be exposed through views, queries, or the analysis layer.

Examples:

```sql
-- Activity average pace
ROUND(duration_sec * 1.0 / distance_km) AS avg_pace_sec_per_km

-- Split elapsed pace
ROUND(elapsed_time_sec * 1000.0 / split_distance_m) AS elapsed_pace_sec_per_km
```

## Consequences

- Core fact tables preserve raw distance and time.
- Dashboard can still display pace through views.
- Parser does not need to materialize derived pace fields for canonical storage.
- If a platform-provided or Garmin-provided algorithmic pace such as GAP is later confirmed as source-native, it must be governed separately in the Metadata Repository before storage.

