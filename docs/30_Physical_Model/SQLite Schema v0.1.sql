-- SQLite Schema v0.1
-- Scope: activity, kilometer_split, activity_view, kilometer_split_view
-- Source: SQLite Mapping Specification v0.1

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS activity (
    id INTEGER PRIMARY KEY,

    fit_sha256 TEXT NOT NULL UNIQUE,
    garmin_activity_id INTEGER UNIQUE,

    excel_schema_version TEXT NOT NULL,
    source_file_name TEXT NOT NULL,
    data_source TEXT NOT NULL,

    activity_start_time TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    activity_name TEXT,
    distance_km REAL NOT NULL CHECK (distance_km > 0),
    duration_sec INTEGER NOT NULL CHECK (duration_sec > 0),
    workout_type_id INTEGER,
    shoe_id INTEGER,

    temperature_c REAL CHECK (temperature_c IS NULL OR temperature_c BETWEEN -20 AND 50),
    humidity_pct REAL CHECK (humidity_pct IS NULL OR humidity_pct BETWEEN 0 AND 100),
    wind_speed_mps REAL CHECK (wind_speed_mps IS NULL OR wind_speed_mps >= 0),
    wind_direction_deg REAL CHECK (wind_direction_deg IS NULL OR wind_direction_deg BETWEEN 0 AND 360),
    weather_description TEXT,

    max_hr INTEGER CHECK (max_hr IS NULL OR max_hr BETWEEN 30 AND 240),
    avg_hr INTEGER CHECK (avg_hr IS NULL OR avg_hr BETWEEN 30 AND 240),
    critical_power_w INTEGER CHECK (critical_power_w IS NULL OR critical_power_w > 0),
    training_effect_aerobic REAL CHECK (
        training_effect_aerobic IS NULL OR training_effect_aerobic BETWEEN 0 AND 5
    ),
    training_effect_anaerobic REAL CHECK (
        training_effect_anaerobic IS NULL OR training_effect_anaerobic BETWEEN 0 AND 5
    ),
    training_load INTEGER CHECK (training_load IS NULL OR training_load >= 0),
    recovery_time_hr REAL CHECK (recovery_time_hr IS NULL OR recovery_time_hr >= 0),
    stamina_start_pct INTEGER CHECK (stamina_start_pct IS NULL OR stamina_start_pct BETWEEN 0 AND 100),
    stamina_end_pct INTEGER CHECK (stamina_end_pct IS NULL OR stamina_end_pct BETWEEN 0 AND 100),

    avg_cadence_spm REAL CHECK (avg_cadence_spm IS NULL OR avg_cadence_spm >= 0),
    avg_stride_length_mm REAL CHECK (avg_stride_length_mm IS NULL OR avg_stride_length_mm >= 0),
    avg_gct_ms REAL CHECK (avg_gct_ms IS NULL OR avg_gct_ms >= 0),
    avg_vertical_oscillation_mm REAL CHECK (
        avg_vertical_oscillation_mm IS NULL OR avg_vertical_oscillation_mm >= 0
    ),
    avg_vertical_ratio_pct REAL CHECK (avg_vertical_ratio_pct IS NULL OR avg_vertical_ratio_pct >= 0),

    garmin_feeling TEXT,
    garmin_perceived_effort TEXT,
    nutrition TEXT,
    notes TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_activity_start_time
    ON activity(activity_start_time);

CREATE INDEX IF NOT EXISTS idx_activity_shoe_id
    ON activity(shoe_id);

CREATE INDEX IF NOT EXISTS idx_activity_workout_type_id
    ON activity(workout_type_id);

CREATE TABLE IF NOT EXISTS kilometer_split (
    id INTEGER PRIMARY KEY,

    activity_id INTEGER NOT NULL REFERENCES activity(id),
    split_index INTEGER NOT NULL CHECK (split_index > 0),

    split_distance_m REAL NOT NULL CHECK (split_distance_m > 0),
    elapsed_time_sec INTEGER NOT NULL CHECK (elapsed_time_sec > 0),

    avg_hr INTEGER CHECK (avg_hr IS NULL OR avg_hr BETWEEN 30 AND 240),
    max_hr INTEGER CHECK (max_hr IS NULL OR max_hr BETWEEN 30 AND 240),
    avg_power_w INTEGER CHECK (avg_power_w IS NULL OR avg_power_w >= 0),

    avg_cadence_spm REAL CHECK (avg_cadence_spm IS NULL OR avg_cadence_spm >= 0),
    avg_stride_length_mm REAL CHECK (avg_stride_length_mm IS NULL OR avg_stride_length_mm >= 0),
    avg_gct_ms REAL CHECK (avg_gct_ms IS NULL OR avg_gct_ms >= 0),
    avg_vertical_ratio_pct REAL CHECK (avg_vertical_ratio_pct IS NULL OR avg_vertical_ratio_pct >= 0),
    avg_vertical_oscillation_mm REAL CHECK (
        avg_vertical_oscillation_mm IS NULL OR avg_vertical_oscillation_mm >= 0
    ),

    elevation_gain_m REAL CHECK (elevation_gain_m IS NULL OR elevation_gain_m >= 0),
    elevation_loss_m REAL CHECK (elevation_loss_m IS NULL OR elevation_loss_m >= 0),

    stamina_start_pct INTEGER CHECK (stamina_start_pct IS NULL OR stamina_start_pct BETWEEN 0 AND 100),
    stamina_end_pct INTEGER CHECK (stamina_end_pct IS NULL OR stamina_end_pct BETWEEN 0 AND 100),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (activity_id, split_index)
);

CREATE INDEX IF NOT EXISTS idx_kilometer_split_activity_id
    ON kilometer_split(activity_id);

CREATE VIEW IF NOT EXISTS activity_view AS
SELECT
    activity.*,
    CAST(ROUND(duration_sec * 1.0 / distance_km) AS INTEGER) AS avg_pace_sec_per_km
FROM activity;

CREATE VIEW IF NOT EXISTS kilometer_split_view AS
SELECT
    kilometer_split.*,
    CAST(ROUND(elapsed_time_sec * 1000.0 / split_distance_m) AS INTEGER) AS elapsed_pace_sec_per_km,
    split_distance_m * 1.0 / elapsed_time_sec AS avg_speed_mps
FROM kilometer_split;

