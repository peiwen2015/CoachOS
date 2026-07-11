# LDM Validation Round 1 | activity

## Purpose

Validate `activity LDM v1` against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`

The goal is not to redesign everything, but to make `activity` provably consistent with the platform metadata rules.

## Validation Criteria

1. Field exists in Metadata Repository.
2. Granularity is compatible with `activity`.
3. Lifecycle is allowed in an activity fact table.
4. Data Type is consistent.
5. Required / Nullable is consistent.
6. Derived fields are reviewed for view/query placement.

## Summary

`activity LDM v1` is mostly valid, but Round 1 identifies several corrections:

| Finding | Decision |
|---|---|
| `avg_pace_sec_per_km` is `Derived` | Remove from core `activity`; expose through view unless materialization is explicitly justified |
| `avg_hr` is in LDM but missing from Metadata Repository | Add to Metadata Repository before keeping in `activity` |
| `import_batch_id` belongs to System/ETL layer | Remove from core activity LDM v1; revisit when designing `import_batch` |
| `id`, `created_at`, `updated_at` are physical/system fields | Allowed, but should be represented as system metadata or physical model convention |
| Running Dynamics summary fields have `Activity / Split` granularity | Allowed in `activity` as activity-level summaries and in `kilometer_split` as split-level facts |

## Field Validation

| LDM Field | Metadata ID | Repository Field | Granularity | Lifecycle | Data Type | Required | Nullable | Validation Result | Decision |
|---|---|---|---|---|---|---|---|---|---|
| id | N/A | N/A | System | System | INTEGER | YES | NO | Physical PK not currently represented in repository | Keep as physical model field; add standard convention later |
| fit_sha256 | SYS-004 | fit_sha256 | System | Raw | HASH | YES | NO | Valid | Keep |
| garmin_activity_id | SYS-003 | garmin_activity_id | System | Raw | INTEGER | CONDITIONAL | YES | Valid | Keep nullable |
| data_source | SYS-002 | data_source / source_file_name | System | Raw | TEXT | YES | NO | Valid but naming overlaps with `source_file_name` | Keep concept; normalize naming before SQLite |
| excel_schema_version | SYS-001 | excel_schema_version | System | Raw | TEXT | YES | NO | Valid | Keep |
| source_file_name | SYS-002 | data_source / source_file_name | System | Raw | TEXT | YES | NO | Valid but overlaps with `data_source` | Prefer `source_file_name`; define `data_source` as source system if needed |
| import_batch_id | Missing | Missing | System | System | FK | NO | YES | Not in Metadata Repository v1.1; ETL/system layer | Remove from core `activity` LDM v1; revisit with `import_batch` |
| activity_start_time | ACT-001 | activity_start_time | Activity | Raw | DATETIME | YES | NO | Valid | Keep |
| activity_type | ACT-002 | activity_type | Activity | Raw | TEXT | YES | NO | Valid | Keep |
| activity_name | ACT-003 | activity_name | Activity | Manual | TEXT | NO | YES | Valid | Keep nullable |
| distance_km | ACT-004 | distance_km | Activity | Raw | DECIMAL | YES | NO | Valid | Keep |
| duration_sec | ACT-005 | duration_sec | Activity | Raw | INTEGER | YES | NO | Valid | Keep |
| avg_pace_sec_per_km | ACT-006 | avg_pace_sec_per_km | Activity | Derived | DECIMAL | NO | YES | Conflicts with Design Standard Rule 06 if stored by default | Remove from core `activity`; provide via view |
| workout_type_id | ACT-007 | workout_type_id | Workout Type | Reference | FK | CONDITIONAL | YES | Valid as FK to dimension | Keep nullable/conditional |
| shoe_id | SHOE-001 | shoe_id | Shoe | Reference | FK | CONDITIONAL | YES | Valid as FK to dimension | Keep nullable/conditional |
| temperature_c | ENV-001 | temperature_c | Activity | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| humidity_pct | ENV-002 | humidity_pct | Activity | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| wind_speed_mps | ENV-004 | wind_speed_mps | Activity | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| wind_direction_deg | ENV-003 | wind_direction_deg | Activity | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| weather_description | ENV-005 | weather_description | Activity | Raw | TEXT | NO | YES | Valid | Keep nullable |
| max_hr | PERF-001 | max_hr | Activity | Raw | INTEGER | NO | YES | Valid | Keep nullable |
| avg_hr | Missing | Missing | Activity | Raw | INTEGER | NO | YES | FIT session field exists, but metadata item is missing | Add to Metadata Repository before keeping |
| critical_power_w | PERF-002 | critical_power_w | Activity | Raw | INTEGER | NO | YES | Valid | Keep nullable |
| training_effect_aerobic | PERF-003 | training_effect_aerobic | Activity | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| training_effect_anaerobic | PERF-004 | training_effect_anaerobic | Activity | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| training_load | PERF-005 | training_load | Activity | Raw | INTEGER | NO | YES | Valid | Keep nullable |
| recovery_time_hr | PERF-006 | recovery_time_hr | Activity | Raw | DECIMAL | NO | YES | Valid but source is still Research | Keep nullable; do not make required |
| stamina_start_pct | STA-001 | stamina_start_pct | Activity | Raw | INTEGER | NO | YES | Valid; partially verified | Keep nullable |
| stamina_end_pct | STA-002 | stamina_end_pct | Activity | Raw | INTEGER | NO | YES | Valid; partially verified | Keep nullable |
| avg_cadence_spm | RDY-001 | avg_cadence_spm | Activity / Split | Raw | DECIMAL | NO | YES | Valid as activity-level summary | Keep nullable |
| avg_stride_length_mm | RDY-002 | avg_stride_length_mm | Activity / Split | Raw | DECIMAL | NO | YES | Valid as activity-level summary | Keep nullable |
| avg_gct_ms | RDY-003 | avg_gct_ms | Activity / Split | Raw | DECIMAL | NO | YES | Valid as activity-level summary | Keep nullable |
| avg_vertical_oscillation_mm | RDY-005 | avg_vertical_oscillation_mm | Activity / Split | Raw | DECIMAL | NO | YES | Valid as activity-level summary | Keep nullable |
| avg_vertical_ratio_pct | RDY-004 | avg_vertical_ratio_pct | Activity / Split | Raw | DECIMAL | NO | YES | Valid as activity-level summary | Keep nullable |
| garmin_feeling | SUB-001 | garmin_feeling | Activity | Raw | ENUM | NO | YES | Valid | Keep nullable |
| garmin_perceived_effort | SUB-002 | garmin_perceived_effort | Activity | Raw | ENUM | NO | YES | Valid | Keep nullable |
| nutrition | SUB-003 | nutrition | Activity | Manual | TEXT | NO | YES | Valid | Keep nullable |
| notes | SUB-004 | notes | Activity | Manual | TEXT | NO | YES | Valid | Keep nullable |
| created_at | N/A | N/A | System | System | DATETIME | YES | NO | Physical/system field not currently represented in repository | Keep as physical convention; add system metadata later |
| updated_at | N/A | N/A | System | System | DATETIME | YES | NO | Physical/system field not currently represented in repository | Keep as physical convention; add system metadata later |

## Revised Activity LDM v1.1 Candidate

This is the corrected `activity` LDM after Round 1 validation.

```text
Activity LDM v1.1 Candidate

Position:
One activity = one record.
Core activity fact table for activity-level raw/manual observations and stable summaries.

Identity:
id
fit_sha256
garmin_activity_id

Source:
excel_schema_version
source_file_name
data_source

Activity:
activity_start_time
activity_type
activity_name
distance_km
duration_sec
workout_type_id
shoe_id

Environment:
temperature_c
humidity_pct
wind_speed_mps
wind_direction_deg
weather_description

Performance:
max_hr
avg_hr
critical_power_w
training_effect_aerobic
training_effect_anaerobic
training_load
recovery_time_hr
stamina_start_pct
stamina_end_pct

Running Economy:
avg_cadence_spm
avg_stride_length_mm
avg_gct_ms
avg_vertical_oscillation_mm
avg_vertical_ratio_pct

Subjective:
garmin_feeling
garmin_perceived_effort
nutrition
notes

System:
created_at
updated_at
```

## Removed From Core Activity

| Field | Reason | Replacement |
|---|---|---|
| avg_pace_sec_per_km | Derived from distance and duration | View/query: `duration_sec / distance_km` |
| import_batch_id | ETL/system metadata, not core domain | Add later with `import_batch` system model |

## Metadata Repository Updates Needed

Before finalizing `activity LDM v1.1`, add these metadata items:

| Proposed Metadata ID | Domain | Data Item | SQLite Field | Granularity | Lifecycle | Data Type | Required | Nullable | Source of Truth |
|---|---|---|---|---|---|---|---|---|---|
| PERF-007 | Performance | Avg HR | avg_hr | Activity | Raw | INTEGER | NO | YES | FIT |
| SYS-005 | Metadata | Created At | created_at | System | Raw | DATETIME | YES | NO | System |
| SYS-006 | Metadata | Updated At | updated_at | System | Raw | DATETIME | YES | NO | System |

Optional later:

| Proposed Metadata ID | Domain | Data Item | Notes |
|---|---|---|
| SYS-007 | Metadata | Import Batch ID | Add only when `import_batch` system table is designed |

## Derived View Candidate

`avg_pace_sec_per_km` should be exposed through a view:

```sql
CAST(ROUND(duration_sec * 1.0 / distance_km) AS INTEGER) AS avg_pace_sec_per_km
```

This preserves dashboard convenience while keeping the core fact table aligned with the Metadata Design Standard.

## Round 1 Decision

Status: `activity LDM v1` requires minor revision before final SQLite design.

Decision:

- Promote revised table to `Activity LDM v1.1 Candidate`.
- Remove `avg_pace_sec_per_km` from core table.
- Remove `import_batch_id` from core domain table for now.
- Add missing metadata for `avg_hr`, `created_at`, and `updated_at`.
- Revisit `source_file_name` vs `data_source` naming before physical SQLite schema.

