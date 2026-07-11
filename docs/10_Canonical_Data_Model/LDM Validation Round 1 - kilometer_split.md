# LDM Validation Round 1 | kilometer_split

## Purpose

Validate `kilometer_split LDM v1` against:

- `Running Analytics Metadata Repository v1.1`
- `Metadata Design Standard v1.0`

This validation is the first repeat test of the Metadata-First governance process after `activity`.

## Validation Criteria

1. Field exists in Metadata Repository.
2. Granularity is compatible with `kilometer_split`.
3. Lifecycle is allowed in a split-level fact table.
4. Data Type is consistent.
5. Required / Nullable is consistent.
6. Derived fields are reviewed for view/query placement.
7. Research-only fields are excluded from Final LDM until source confidence improves.

## Summary

`kilometer_split LDM v1` is directionally valid, but Round 1 identifies several corrections:

| Finding | Decision |
|---|---|
| `elapsed_pace_sec_per_km` is `Derived` | Remove from core `kilometer_split`; expose through view/query |
| `moving_time_sec` is `Research` and not currently parsed | Exclude from v1.1 Final |
| `moving_pace_sec_per_km` is `Research` and depends on moving time | Exclude from v1.1 Final |
| `gap_pace_sec_per_km` is `Research` | Exclude from v1.1 Final until source is confirmed |
| `elevation_loss_m` exists in FIT lap data but is not currently in Excel | Keep in LDM v1.1 candidate; parser should add it later |
| Split-level Stamina exists only for some files/devices | Keep only nullable split stamina start/end fields after Metadata Repository update |
| `potential_stamina_pct` is not clearly verified in current parser | Exclude from v1.1 Final until field mapping is confirmed |
| Running Dynamics fields are Raw observations | Keep in core `kilometer_split` |

## Local Evidence

Recent FIT sample check:

| Item | Result |
|---|---|
| `total_descent` in lap messages | Present in 18 of 20 sampled FIT files |
| `enhanced_avg_speed` in lap messages | Present in 20 of 20 sampled FIT files |
| Explicit moving time field | Not found in sampled lap keys |
| Split-level Stamina record fields | Present in 5 of 20 sampled FIT files |

Observed lap time/speed-related keys:

```text
enhanced_avg_speed
enhanced_max_speed
start_time
timestamp
total_elapsed_time
total_timer_time
```

## Field Validation

| LDM Field | Metadata ID | Repository Field | Granularity | Lifecycle | Data Type | Required | Nullable | Validation Result | Decision |
|---|---|---|---|---|---|---|---|---|---|
| id | N/A | N/A | System | System | INTEGER | YES | NO | Physical PK not currently represented in repository | Keep as physical model field; add standard convention later |
| activity_id | Missing | Missing | Activity/Split relationship | Reference | FK | YES | NO | Required FK to parent activity, but missing from Metadata Repository | Add metadata; keep |
| split_index | SPL-001 | split_index | Split | Raw | INTEGER | YES | NO | Valid | Keep |
| split_distance_m | SPL-002 | split_distance_m | Split | Raw | DECIMAL | YES | NO | Valid | Keep |
| elapsed_time_sec | SPL-003 | elapsed_time_sec | Split | Raw | INTEGER | YES | NO | Valid | Keep |
| moving_time_sec | SPL-004 | moving_time_sec | Split | Raw / Research | INTEGER | NO | YES | Source not confirmed; not currently parsed | Exclude from v1.1 Final |
| elapsed_pace_sec_per_km | SPL-005 | elapsed_pace_sec_per_km | Split | Derived | DECIMAL | NO | YES | Conflicts with Design Standard Rule 06 if stored by default | Remove from core table; provide via view |
| moving_pace_sec_per_km | SPL-006 | moving_pace_sec_per_km | Split | Raw / Research | DECIMAL | NO | YES | Depends on unverified moving time/source | Exclude from v1.1 Final |
| gap_pace_sec_per_km | SPL-007 | gap_pace_sec_per_km | Split | Raw / Research | DECIMAL | NO | YES | Source not confirmed as FIT Native or Garmin algorithm output | Exclude from v1.1 Final |
| avg_hr | SPL-008 | avg_hr | Split | Raw | INTEGER | NO | YES | Valid | Keep nullable |
| max_hr | SPL-009 | max_hr | Split | Raw | INTEGER | NO | YES | Valid | Keep nullable |
| avg_power_w | SPL-010 | avg_power_w | Split | Raw | INTEGER | NO | YES | Valid | Keep nullable |
| avg_cadence_spm | RDY-001 | avg_cadence_spm | Activity / Split | Raw | DECIMAL | NO | YES | Valid split-level observation | Keep nullable |
| avg_stride_length_mm | RDY-002 | avg_stride_length_mm | Activity / Split | Raw | DECIMAL | NO | YES | Valid split-level observation | Keep nullable |
| avg_gct_ms | RDY-003 | avg_gct_ms | Activity / Split | Raw | DECIMAL | NO | YES | Valid split-level observation | Keep nullable |
| avg_vertical_ratio_pct | RDY-004 | avg_vertical_ratio_pct | Activity / Split | Raw | DECIMAL | NO | YES | Valid split-level observation | Keep nullable |
| avg_vertical_oscillation_mm | RDY-005 | avg_vertical_oscillation_mm | Activity / Split | Raw | DECIMAL | NO | YES | Valid split-level observation | Keep nullable |
| elevation_gain_m | SPL-011 | elevation_gain_m | Split | Raw | DECIMAL | NO | YES | Valid | Keep nullable |
| elevation_loss_m | SPL-012 | elevation_loss_m | Split | Raw | DECIMAL | NO | YES | FIT lap `total_descent` exists; parser/Excel do not currently expose it | Keep nullable; parser update needed |
| stamina_pct | Missing | Missing | Split | Raw | INTEGER | NO | YES | Naming unclear; current parser exposes start/end, not a single split stamina value | Replace with `stamina_start_pct` and `stamina_end_pct` |
| potential_stamina_pct | Missing | Missing | Split | Raw / Research | INTEGER | NO | YES | Not clearly mapped in current parser | Exclude from v1.1 Final until verified |
| created_at | N/A | N/A | System | System | DATETIME | YES | NO | Physical/system field not currently represented in repository | Keep as physical convention; add system metadata later |
| updated_at | N/A | N/A | System | System | DATETIME | YES | NO | Physical/system field not currently represented in repository | Keep as physical convention; add system metadata later |

## Revised Kilometer Split LDM v1.1 Candidate

This is the corrected `kilometer_split` LDM after Round 1 validation.

```text
Kilometer Split LDM v1.1 Candidate

Position:
One activity split = one record.
Core split-level fact table for raw split observations.

Identity:
id
activity_id
split_index

Distance:
split_distance_m

Time:
elapsed_time_sec

Heart Rate:
avg_hr
max_hr

Power:
avg_power_w

Running Dynamics:
avg_cadence_spm
avg_stride_length_mm
avg_gct_ms
avg_vertical_ratio_pct
avg_vertical_oscillation_mm

Elevation:
elevation_gain_m
elevation_loss_m

Stamina:
stamina_start_pct
stamina_end_pct

System:
created_at
updated_at
```

## Removed From Core Kilometer Split

| Field | Reason | Replacement |
|---|---|---|
| elapsed_pace_sec_per_km | Lifecycle = Derived. It is calculated from `elapsed_time_sec` and `split_distance_m`. | View / query |
| moving_time_sec | Source not confirmed; not currently parsed | Future metadata/parser research |
| moving_pace_sec_per_km | Source not confirmed and depends on moving time | Future metadata/parser research or view |
| gap_pace_sec_per_km | Source not confirmed as FIT Native / Garmin algorithm output | Future metadata/parser research |
| potential_stamina_pct | Current parser does not clearly distinguish potential stamina | Future field mapping research |

## Metadata Repository Updates Needed

Before finalizing `Kilometer Split LDM v1.1`, add or update these metadata items:

| Proposed Metadata ID | Domain | Data Item | SQLite Field | Granularity | Lifecycle | Data Type | Required | Nullable | Source of Truth |
|---|---|---|---|---|---|---|---|---|---|
| SPL-013 | Kilometer Split | Activity ID | activity_id | Split | Reference | FK | YES | NO | activity |
| SPL-014 | Stamina | Split Stamina Start | stamina_start_pct | Split | Raw | INTEGER | NO | YES | FIT |
| SPL-015 | Stamina | Split Stamina End | stamina_end_pct | Split | Raw | INTEGER | NO | YES | FIT |

Optional later:

| Metadata Item | Reason |
|---|---|
| Split Moving Time | Need source confirmation |
| Split Moving Pace | Need source confirmation |
| Split GAP Pace | Need source confirmation |
| Split Potential Stamina | Need field mapping confirmation |

## Derived View Candidate

`elapsed_pace_sec_per_km` should be exposed through a view:

```sql
CAST(ROUND(elapsed_time_sec * 1000.0 / split_distance_m) AS INTEGER) AS elapsed_pace_sec_per_km
```

Optional speed view:

```sql
split_distance_m * 1.0 / elapsed_time_sec AS avg_speed_mps
```

## Architecture DoD Status

```text
[x] Metadata Verified
[x] Standard Compliant
[x] Validation Completed
[ ] Release Notes Updated
[ ] Final LDM Published
```

## Round 1 Decision

Status: `kilometer_split LDM v1` requires revision before Final.

Decision:

- Promote revised table to `Kilometer Split LDM v1.1 Candidate`.
- Remove pace fields from core table unless later proven to be source-native observations.
- Keep raw heart rate, power, running dynamics, elevation, and nullable split Stamina observations.
- Add missing metadata for `activity_id`, `stamina_start_pct`, and `stamina_end_pct`.
- Do not publish Final LDM until Metadata Repository updates are applied.

