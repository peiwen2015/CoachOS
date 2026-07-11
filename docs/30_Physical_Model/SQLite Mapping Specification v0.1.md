# SQLite Mapping Specification v0.1

## Purpose

Define how Final LDM fields map to SQLite physical columns, types, constraints, indexes, and views.

This is not the final SQLite `CREATE TABLE` schema. It is the Logical-to-Physical mapping layer between:

```text
Metadata Repository
        ↓
Final LDM
        ↓
SQLite Mapping Specification
        ↓
SQLite Schema
        ↓
Parser / Excel Exporter Metadata Compliance
```

## Scope

Included:

- `activity`
- `kilometer_split`

Excluded:

- `shoe`
- `workout_type`
- `training_purpose`
- `activity_training_purpose`
- `import_batch`
- `health_daily`

## Logical Type to SQLite Type Mapping

| Metadata Logical Type | SQLite Physical Type | Notes |
|---|---|---|
| UUID | TEXT | Store canonical UUID string |
| HASH | TEXT | Store SHA/hash string |
| INTEGER | INTEGER | Whole number |
| DECIMAL | REAL | Floating-point numeric value |
| BOOLEAN | INTEGER | Use `CHECK (value IN (0, 1))` |
| TEXT | TEXT | Free text / short text |
| ENUM | TEXT | Use `CHECK` or reference table later |
| DATETIME | TEXT | ISO8601 datetime |
| DATE | TEXT | ISO8601 date |
| FK | INTEGER | Foreign key reference |
| JSON | TEXT | JSON string |

## General SQLite Conventions

| Rule | Decision |
|---|---|
| Primary key | `id INTEGER PRIMARY KEY` |
| Datetime storage | `TEXT` in ISO8601 format |
| Created timestamp | `created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| Updated timestamp | `updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| Nullable | Follow Metadata Repository `Nullable` |
| Required | Use `NOT NULL` when `Required = YES` and `Nullable = NO` |
| Derived data | Prefer views, not core table columns |
| Foreign keys | Use `INTEGER REFERENCES target(id)` when target table is in scope |

## Primary Key Strategy

SQLite `id` is an internal surrogate key.

Business identity is maintained by governed business keys:

- `activity.fit_sha256`
- `activity.garmin_activity_id` when available

No business logic, dashboard logic, parser behavior, or AI Coach behavior should depend on SQLite `id` values as stable business identifiers.

## Foreign Key Enforcement

SQLite runtime must enable foreign key enforcement:

```sql
PRAGMA foreign_keys = ON;
```

Without this setting, SQLite accepts foreign key declarations but does not enforce them.

## Datetime Format

Datetime values must be stored as ISO8601 text:

```text
YYYY-MM-DDTHH:MM:SS
```

Do not store mixed formats such as:

```text
YYYY/MM/DD
YYYY-MM-DD HH:MM:SS
```

## Validation Strategy

Business validation belongs primarily in the parser/application layer.

SQLite `CHECK` constraints should enforce basic sanity rules only.

Examples:

| Data Item | SQLite Validation |
|---|---|
| Distance | `> 0` |
| Heart rate | `30-240` |
| Humidity | `0-100` |
| Training Effect | `0-5` |

## ENUM Strategy

| Version | Strategy |
|---|---|
| v0.1 | Store enum-like values as `TEXT` |
| v0.2+ | Move stable controlled vocabularies to reference tables where appropriate |

## Core View Strategy

Core views expose derived fields without duplicating them in core fact tables.

v0.1 core views:

- `activity_view`
- `kilometer_split_view`

Future analysis views may include:

- `shoe_statistics_view`
- `weekly_summary_view`
- `fatigue_view`

## Activity Mapping

Source LDM: `Activity LDM v1.1 Final`

| LDM Field | SQLite Column | SQLite Type | Constraint / Rule | Notes |
|---|---|---|---|---|
| id | id | INTEGER | PRIMARY KEY | Physical PK |
| fit_sha256 | fit_sha256 | TEXT | NOT NULL UNIQUE | Business key for duplicate prevention |
| garmin_activity_id | garmin_activity_id | INTEGER | UNIQUE NULL | Nullable because non-Garmin/future sources may not have it |
| excel_schema_version | excel_schema_version | TEXT | NOT NULL | Current source workbook schema version |
| source_file_name | source_file_name | TEXT | NOT NULL | Original FIT/source filename |
| data_source | data_source | TEXT | NOT NULL | Source type/system, e.g. `FIT` |
| activity_start_time | activity_start_time | TEXT | NOT NULL | Local time ISO8601 |
| activity_type | activity_type | TEXT | NOT NULL | Activity/sport type |
| activity_name | activity_name | TEXT | NULL | Optional manual/source activity name |
| distance_km | distance_km | REAL | NOT NULL CHECK (distance_km > 0) | Raw activity distance |
| duration_sec | duration_sec | INTEGER | NOT NULL CHECK (duration_sec > 0) | Raw activity duration in seconds |
| workout_type_id | workout_type_id | INTEGER | NULL | FK to `workout_type(id)` after dimension table exists |
| shoe_id | shoe_id | INTEGER | NULL | FK to `shoe(id)` after dimension table exists |
| temperature_c | temperature_c | REAL | NULL CHECK (temperature_c IS NULL OR temperature_c BETWEEN -20 AND 50) | Weather API/manual |
| humidity_pct | humidity_pct | REAL | NULL CHECK (humidity_pct IS NULL OR humidity_pct BETWEEN 0 AND 100) | Weather API/manual |
| wind_speed_mps | wind_speed_mps | REAL | NULL CHECK (wind_speed_mps IS NULL OR wind_speed_mps >= 0) | Store numeric m/s |
| wind_direction_deg | wind_direction_deg | REAL | NULL CHECK (wind_direction_deg IS NULL OR wind_direction_deg BETWEEN 0 AND 360) | Store numeric degrees |
| weather_description | weather_description | TEXT | NULL | Weather description |
| max_hr | max_hr | INTEGER | NULL CHECK (max_hr IS NULL OR max_hr BETWEEN 30 AND 240) | Max HR setting/source value |
| avg_hr | avg_hr | INTEGER | NULL CHECK (avg_hr IS NULL OR avg_hr BETWEEN 30 AND 240) | Activity average HR |
| critical_power_w | critical_power_w | INTEGER | NULL CHECK (critical_power_w IS NULL OR critical_power_w > 0) | Critical power / FTP-like value |
| training_effect_aerobic | training_effect_aerobic | REAL | NULL CHECK (training_effect_aerobic IS NULL OR training_effect_aerobic BETWEEN 0 AND 5) | Garmin TE aerobic |
| training_effect_anaerobic | training_effect_anaerobic | REAL | NULL CHECK (training_effect_anaerobic IS NULL OR training_effect_anaerobic BETWEEN 0 AND 5) | Garmin TE anaerobic |
| training_load | training_load | INTEGER | NULL CHECK (training_load IS NULL OR training_load >= 0) | Garmin training load |
| recovery_time_hr | recovery_time_hr | REAL | NULL CHECK (recovery_time_hr IS NULL OR recovery_time_hr >= 0) | Source still research/manual |
| stamina_start_pct | stamina_start_pct | INTEGER | NULL CHECK (stamina_start_pct IS NULL OR stamina_start_pct BETWEEN 0 AND 100) | Nullable device-dependent field |
| stamina_end_pct | stamina_end_pct | INTEGER | NULL CHECK (stamina_end_pct IS NULL OR stamina_end_pct BETWEEN 0 AND 100) | Nullable device-dependent field |
| avg_cadence_spm | avg_cadence_spm | REAL | NULL CHECK (avg_cadence_spm IS NULL OR avg_cadence_spm >= 0) | Activity-level running dynamics summary |
| avg_stride_length_mm | avg_stride_length_mm | REAL | NULL CHECK (avg_stride_length_mm IS NULL OR avg_stride_length_mm >= 0) | Activity-level running dynamics summary |
| avg_gct_ms | avg_gct_ms | REAL | NULL CHECK (avg_gct_ms IS NULL OR avg_gct_ms >= 0) | Activity-level running dynamics summary |
| avg_vertical_oscillation_mm | avg_vertical_oscillation_mm | REAL | NULL CHECK (avg_vertical_oscillation_mm IS NULL OR avg_vertical_oscillation_mm >= 0) | Activity-level running dynamics summary |
| avg_vertical_ratio_pct | avg_vertical_ratio_pct | REAL | NULL CHECK (avg_vertical_ratio_pct IS NULL OR avg_vertical_ratio_pct >= 0) | Activity-level running dynamics summary |
| garmin_feeling | garmin_feeling | TEXT | NULL | ENUM/check later |
| garmin_perceived_effort | garmin_perceived_effort | TEXT | NULL | ENUM/check later |
| nutrition | nutrition | TEXT | NULL | Manual input |
| notes | notes | TEXT | NULL | Manual input |
| created_at | created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |
| updated_at | updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |

### Activity Indexes / Constraints

| Name | Type | Definition |
|---|---|---|
| activity_pk | Primary key | `id` |
| activity_fit_sha256_uq | Unique | `fit_sha256` |
| activity_garmin_activity_id_uq | Unique | `garmin_activity_id` |
| activity_start_time_idx | Index | `activity_start_time` |
| activity_shoe_id_idx | Index | `shoe_id` |
| activity_workout_type_id_idx | Index | `workout_type_id` |

## Kilometer Split Mapping

Source LDM: `Kilometer Split LDM v1.1 Final`

| LDM Field | SQLite Column | SQLite Type | Constraint / Rule | Notes |
|---|---|---|---|---|
| id | id | INTEGER | PRIMARY KEY | Physical PK |
| activity_id | activity_id | INTEGER | NOT NULL REFERENCES activity(id) | Parent activity |
| split_index | split_index | INTEGER | NOT NULL CHECK (split_index > 0) | Split order within activity |
| split_distance_m | split_distance_m | REAL | NOT NULL CHECK (split_distance_m > 0) | Split distance |
| elapsed_time_sec | elapsed_time_sec | INTEGER | NOT NULL CHECK (elapsed_time_sec > 0) | Split elapsed/timer time |
| avg_hr | avg_hr | INTEGER | NULL CHECK (avg_hr IS NULL OR avg_hr BETWEEN 30 AND 240) | Split average HR |
| max_hr | max_hr | INTEGER | NULL CHECK (max_hr IS NULL OR max_hr BETWEEN 30 AND 240) | Split max HR |
| avg_power_w | avg_power_w | INTEGER | NULL CHECK (avg_power_w IS NULL OR avg_power_w >= 0) | Split average power |
| avg_cadence_spm | avg_cadence_spm | REAL | NULL CHECK (avg_cadence_spm IS NULL OR avg_cadence_spm >= 0) | Split running dynamics |
| avg_stride_length_mm | avg_stride_length_mm | REAL | NULL CHECK (avg_stride_length_mm IS NULL OR avg_stride_length_mm >= 0) | Split running dynamics |
| avg_gct_ms | avg_gct_ms | REAL | NULL CHECK (avg_gct_ms IS NULL OR avg_gct_ms >= 0) | Split running dynamics |
| avg_vertical_ratio_pct | avg_vertical_ratio_pct | REAL | NULL CHECK (avg_vertical_ratio_pct IS NULL OR avg_vertical_ratio_pct >= 0) | Split running dynamics |
| avg_vertical_oscillation_mm | avg_vertical_oscillation_mm | REAL | NULL CHECK (avg_vertical_oscillation_mm IS NULL OR avg_vertical_oscillation_mm >= 0) | Split running dynamics |
| elevation_gain_m | elevation_gain_m | REAL | NULL CHECK (elevation_gain_m IS NULL OR elevation_gain_m >= 0) | FIT lap total_ascent |
| elevation_loss_m | elevation_loss_m | REAL | NULL CHECK (elevation_loss_m IS NULL OR elevation_loss_m >= 0) | FIT lap total_descent |
| stamina_start_pct | stamina_start_pct | INTEGER | NULL CHECK (stamina_start_pct IS NULL OR stamina_start_pct BETWEEN 0 AND 100) | Nullable device-dependent field |
| stamina_end_pct | stamina_end_pct | INTEGER | NULL CHECK (stamina_end_pct IS NULL OR stamina_end_pct BETWEEN 0 AND 100) | Nullable device-dependent field |
| created_at | created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |
| updated_at | updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |

### Kilometer Split Indexes / Constraints

| Name | Type | Definition |
|---|---|---|
| kilometer_split_pk | Primary key | `id` |
| kilometer_split_activity_split_uq | Unique | `(activity_id, split_index)` |
| kilometer_split_activity_id_idx | Index | `activity_id` |
| kilometer_split_activity_fk | Foreign key | `activity_id REFERENCES activity(id)` |

## Views

### activity_view

Purpose: expose dashboard-friendly derived fields without storing them in core fact tables.

Derived fields:

| Field | Formula |
|---|---|
| avg_pace_sec_per_km | `CAST(ROUND(duration_sec * 1.0 / distance_km) AS INTEGER)` |

### kilometer_split_view

Purpose: expose split pace and speed without storing derived values in `kilometer_split`.

Derived fields:

| Field | Formula |
|---|---|
| elapsed_pace_sec_per_km | `CAST(ROUND(elapsed_time_sec * 1000.0 / split_distance_m) AS INTEGER)` |
| avg_speed_mps | `split_distance_m * 1.0 / elapsed_time_sec` |

## Deferred Physical Model Items

These are intentionally not included in SQLite Mapping v0.1:

| Item | Reason |
|---|---|
| `shoe` foreign key enforcement | `shoe` LDM not final yet |
| `workout_type` foreign key enforcement | `workout_type` LDM not final yet |
| `activity_training_purpose` | Bridge LDM not final yet |
| `import_batch_id` | System layer not modeled yet |
| Moving pace/time fields | Source not confirmed |
| GAP pace | Source not confirmed |
| Health daily fields | Health data source research pending |

## Next Step

After this mapping specification is reviewed, generate:

```text
SQLite Schema v0.1
```

Only `activity`, `kilometer_split`, and derived views are in scope for the first physical schema.
