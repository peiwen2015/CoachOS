# SQLite Mapping Specification v1.0

## Purpose

Define how Final LDM fields map to SQLite physical columns, types, constraints, indexes, and core views.

This is the Logical-to-Physical mapping layer between:

```text
Metadata Repository
        ↓
Final LDM
        ↓
SQLite Mapping Specification
        ↓
SQLite Schema
        ↓
Parser Metadata Compliance
```

## Scope

Included Core Canonical Data Layer v1.0 models:

- `shoe`
- `workout_type`
- `training_purpose`
- `activity`
- `activity_training_purpose`
- `kilometer_split`

Excluded:

- `import_batch`
- `health_daily`
- `race`
- `ai_analysis`

## Logical Type to SQLite Type Mapping

| Metadata Logical Type | SQLite Physical Type | Notes |
|---|---|---|
| UUID | TEXT | Store canonical UUID string |
| HASH | TEXT | Store SHA/hash string |
| INTEGER | INTEGER | Whole number |
| DECIMAL | REAL | Floating-point numeric value |
| BOOLEAN | INTEGER | Use `CHECK (value IN (0, 1))` |
| TEXT | TEXT | Free text / short text |
| ENUM | TEXT | Use `CHECK` for small stable enums or reference tables for dimensions |
| DATETIME | TEXT | ISO8601 datetime |
| DATE | TEXT | ISO8601 date |
| FK | INTEGER | Foreign key reference |
| JSON | TEXT | JSON string |

## General SQLite Conventions

| Rule | Decision |
|---|---|
| Primary key | `id INTEGER PRIMARY KEY` |
| Surrogate key | SQLite `id` is internal and not a business key |
| Datetime storage | `TEXT` in ISO8601 format |
| Created timestamp | `created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| Updated timestamp | `updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| Nullable | Follow Metadata Repository `Nullable` |
| Required | Use `NOT NULL` when `Required = YES` and `Nullable = NO` |
| Derived data | Prefer views, not core table columns |
| Foreign keys | Use `INTEGER REFERENCES target(id)` |
| Naming | lowercase `snake_case` for tables, columns, indexes, and views |

## Primary Key Strategy

SQLite `id` is an internal surrogate key.

Business identity is maintained by governed business keys:

- `activity.fit_sha256`
- `activity.garmin_activity_id` when available
- `shoe.shoe_code`
- `workout_type.workout_type_code`
- `training_purpose.training_purpose_code`

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

Date values must be stored as ISO8601 text:

```text
YYYY-MM-DD
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
| Percentage | `0-100` |

## ENUM Strategy

| Enum Type | v1.0 Strategy |
|---|---|
| Stable dimensions | Reference tables: `shoe`, `workout_type`, `training_purpose` |
| Small table-local roles | `TEXT CHECK`, for example `purpose_role IN ('PRIMARY', 'SECONDARY')` |
| Display/category hints | `TEXT CHECK` when values are stable enough; otherwise parser/application validation |

## Recommended Table Creation Order

```text
shoe
workout_type
training_purpose
activity
activity_training_purpose
kilometer_split
views
```

## Shoe Mapping

Source LDM: `Shoe LDM v1.1 Final`

| LDM Field | SQLite Column | SQLite Type | Constraint / Rule | Notes |
|---|---|---|---|---|
| id | id | INTEGER | PRIMARY KEY | Physical PK |
| shoe_code | shoe_code | TEXT | NOT NULL UNIQUE | Stable human-readable business key |
| brand | brand | TEXT | NOT NULL | Static shoe attribute |
| model | model | TEXT | NOT NULL | Static shoe attribute |
| nickname | nickname | TEXT | NULL | Optional user nickname/colorway |
| category | category | TEXT | NOT NULL | Controlled usage category |
| size_us | size_us | REAL | NULL CHECK (size_us IS NULL OR size_us > 0) | Optional spec |
| width | width | TEXT | NULL | Optional spec |
| drop_mm | drop_mm | REAL | NULL CHECK (drop_mm IS NULL OR drop_mm >= 0) | Optional spec |
| weight_g | weight_g | INTEGER | NULL CHECK (weight_g IS NULL OR weight_g > 0) | Optional spec |
| purchase_date | purchase_date | TEXT | NULL | ISO8601 date |
| first_run_date | first_run_date | TEXT | NULL | ISO8601 date; manual lifecycle field |
| retire_date | retire_date | TEXT | NULL | ISO8601 date |
| retire_target_distance_km | retire_target_distance_km | REAL | NULL CHECK (retire_target_distance_km IS NULL OR retire_target_distance_km >= 0) | Optional lifecycle target |
| retire_actual_distance_km | retire_actual_distance_km | REAL | NULL CHECK (retire_actual_distance_km IS NULL OR retire_actual_distance_km >= 0) | Optional lifecycle outcome |
| is_active | is_active | INTEGER | NOT NULL CHECK (is_active IN (0, 1)) | Active rotation flag |
| notes | notes | TEXT | NULL | Optional notes |
| created_at | created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |
| updated_at | updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |

### Shoe Indexes / Constraints

| Name | Type | Definition |
|---|---|---|
| shoe_pk | Primary key | `id` |
| shoe_code_uq | Unique | `shoe_code` |
| shoe_category_idx | Index | `category` |
| shoe_is_active_idx | Index | `is_active` |

## Workout Type Mapping

Source LDM: `Workout Type LDM v1.1 Final`

| LDM Field | SQLite Column | SQLite Type | Constraint / Rule | Notes |
|---|---|---|---|---|
| id | id | INTEGER | PRIMARY KEY | Physical PK |
| workout_type_code | workout_type_code | TEXT | NOT NULL UNIQUE | Stable business key |
| name_en | name_en | TEXT | NOT NULL | Display name |
| name_zh | name_zh | TEXT | NOT NULL | Display name |
| description | description | TEXT | NULL | Optional description |
| intensity_category | intensity_category | TEXT | NOT NULL | Controlled category |
| is_quality_session | is_quality_session | INTEGER | NOT NULL CHECK (is_quality_session IN (0, 1)) | Structural flag |
| is_long_run | is_long_run | INTEGER | NOT NULL CHECK (is_long_run IN (0, 1)) | Structural flag |
| is_recovery_focused | is_recovery_focused | INTEGER | NOT NULL CHECK (is_recovery_focused IN (0, 1)) | Structural flag |
| sort_order | sort_order | INTEGER | NULL | Optional display order |
| display_color | display_color | TEXT | NULL | Optional UI token/hex color |
| created_at | created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |
| updated_at | updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |

### Workout Type Indexes / Constraints

| Name | Type | Definition |
|---|---|---|
| workout_type_pk | Primary key | `id` |
| workout_type_code_uq | Unique | `workout_type_code` |
| workout_type_intensity_category_idx | Index | `intensity_category` |
| workout_type_sort_order_idx | Index | `sort_order` |

## Training Purpose Mapping

Source LDM: `Training Purpose LDM v1.1 Final`

| LDM Field | SQLite Column | SQLite Type | Constraint / Rule | Notes |
|---|---|---|---|---|
| id | id | INTEGER | PRIMARY KEY | Physical PK |
| training_purpose_code | training_purpose_code | TEXT | NOT NULL UNIQUE | Stable business key |
| name_en | name_en | TEXT | NOT NULL | Display name |
| name_zh | name_zh | TEXT | NOT NULL | Display name |
| description | description | TEXT | NULL | Optional description |
| purpose_category | purpose_category | TEXT | NOT NULL | Controlled category |
| is_primary_physiological | is_primary_physiological | INTEGER | NOT NULL CHECK (is_primary_physiological IN (0, 1)) | Intent classification flag |
| is_recovery_related | is_recovery_related | INTEGER | NOT NULL CHECK (is_recovery_related IN (0, 1)) | Intent classification flag |
| is_performance_related | is_performance_related | INTEGER | NOT NULL CHECK (is_performance_related IN (0, 1)) | Intent classification flag |
| sort_order | sort_order | INTEGER | NULL | Optional display order |
| display_color | display_color | TEXT | NULL | Optional UI token/hex color |
| created_at | created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |
| updated_at | updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |

### Training Purpose Indexes / Constraints

| Name | Type | Definition |
|---|---|---|
| training_purpose_pk | Primary key | `id` |
| training_purpose_code_uq | Unique | `training_purpose_code` |
| training_purpose_category_idx | Index | `purpose_category` |
| training_purpose_sort_order_idx | Index | `sort_order` |

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
| workout_type_id | workout_type_id | INTEGER | NULL REFERENCES workout_type(id) | Workout structure dimension |
| shoe_id | shoe_id | INTEGER | NULL REFERENCES shoe(id) | Shoe dimension |
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
| recovery_time_hr | recovery_time_hr | REAL | NULL CHECK (recovery_time_hr IS NULL OR recovery_time_hr >= 0) | Nullable source-dependent field |
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
| start_latitude | start_latitude | REAL | NULL | FIT start location latitude |
| start_longitude | start_longitude | REAL | NULL | FIT start location longitude |
| end_latitude | end_latitude | REAL | NULL | FIT end location latitude |
| end_longitude | end_longitude | REAL | NULL | FIT end location longitude |
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
| activity_shoe_fk | Foreign key | `shoe_id REFERENCES shoe(id)` |
| activity_workout_type_fk | Foreign key | `workout_type_id REFERENCES workout_type(id)` |

## Activity Training Purpose Mapping

Source LDM: `Activity Training Purpose LDM v1.1 Final`

| LDM Field | SQLite Column | SQLite Type | Constraint / Rule | Notes |
|---|---|---|---|---|
| id | id | INTEGER | PRIMARY KEY | Physical PK |
| activity_id | activity_id | INTEGER | NOT NULL REFERENCES activity(id) | Parent activity |
| training_purpose_id | training_purpose_id | INTEGER | NOT NULL REFERENCES training_purpose(id) | Training purpose intent |
| purpose_role | purpose_role | TEXT | NOT NULL CHECK (purpose_role IN ('PRIMARY', 'SECONDARY')) | Intent role |
| created_at | created_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |
| updated_at | updated_at | TEXT | NOT NULL DEFAULT CURRENT_TIMESTAMP | System timestamp |

### Activity Training Purpose Indexes / Constraints

| Name | Type | Definition |
|---|---|---|
| activity_training_purpose_pk | Primary key | `id` |
| activity_training_purpose_activity_purpose_uq | Unique | `(activity_id, training_purpose_id)` |
| activity_training_purpose_activity_id_idx | Index | `activity_id` |
| activity_training_purpose_training_purpose_id_idx | Index | `training_purpose_id` |
| activity_training_purpose_role_idx | Index | `purpose_role` |
| activity_training_purpose_activity_fk | Foreign key | `activity_id REFERENCES activity(id)` |
| activity_training_purpose_training_purpose_fk | Foreign key | `training_purpose_id REFERENCES training_purpose(id)` |

### Activity Training Purpose Business Rule

Once the training-purpose workflow is enabled, each activity should have at least one `PRIMARY` purpose.

This is a business validation rule for importer/application/tests. SQLite `CHECK` constraints cannot enforce this cross-row rule directly.

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

## Core Views

### activity_view

Purpose: expose dashboard-friendly derived fields without storing them in core fact tables.

Derived fields:

| Field | Formula |
|---|---|
| avg_pace_sec_per_km | `CAST(ROUND(duration_sec * 1.0 / distance_km) AS INTEGER)` |

Recommended joins:

- `activity` to `shoe`
- `activity` to `workout_type`

### kilometer_split_view

Purpose: expose split pace and speed without storing derived values in `kilometer_split`.

Derived fields:

| Field | Formula |
|---|---|
| elapsed_pace_sec_per_km | `CAST(ROUND(elapsed_time_sec * 1000.0 / split_distance_m) AS INTEGER)` |
| avg_speed_mps | `split_distance_m * 1.0 / elapsed_time_sec` |

### activity_training_purpose_view

Purpose: expose activity training intent with readable purpose codes and names.

Recommended joins:

- `activity_training_purpose` to `activity`
- `activity_training_purpose` to `training_purpose`

### shoe_statistics_view

Purpose: expose derived shoe lifecycle and usage summaries without storing them in `shoe`.

Derived fields may include:

| Field | Formula / Source |
|---|---|
| total_distance_km | `SUM(activity.distance_km)` grouped by `shoe_id` |
| run_count | `COUNT(activity.id)` grouped by `shoe_id` |
| observed_first_run_date | `MIN(activity.activity_start_time)` grouped by `shoe_id` |
| observed_last_run_date | `MAX(activity.activity_start_time)` grouped by `shoe_id` |

## Deferred Physical Model Items

These are intentionally not included in SQLite Mapping v1.0:

| Item | Reason |
|---|---|
| `import_batch_id` | System/ETL layer not modeled yet |
| Moving pace/time fields | Source not confirmed |
| GAP pace | Source not confirmed |
| Health daily fields | Health data source research pending |
| Race fields | Race domain not modeled yet |
| AI analysis fields | Analysis layer not modeled yet |

## Next Step

Generate:

```text
SQLite Schema v1.0
```

The first v1.0 physical schema should include all six Core Canonical Data Layer tables and core views from this mapping specification.
