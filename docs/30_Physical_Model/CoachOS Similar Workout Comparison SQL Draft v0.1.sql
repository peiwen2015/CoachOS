-- CoachOS Similar Workout Comparison SQL Draft v0.1
-- Purpose: draft governed semantic SQL for similar workout comparison features
-- Status: draft only; this file surfaces schema gaps and calculation dependencies

DROP VIEW IF EXISTS similar_workout_comparison_view;
DROP VIEW IF EXISTS activity_comparison_metric_view;
DROP VIEW IF EXISTS activity_comparison_anchor_view;
DROP VIEW IF EXISTS activity_workout_segment_metric_view;
DROP VIEW IF EXISTS activity_workout_segment_boundary_view;
DROP VIEW IF EXISTS activity_comparison_base_view;
DROP TABLE IF EXISTS similar_workout_comparison_definition;

CREATE TABLE IF NOT EXISTS similar_workout_comparison_definition (
    comparison_definition_id TEXT PRIMARY KEY,
    comparison_name TEXT NOT NULL,
    workout_family TEXT NOT NULL,
    structure_type TEXT NOT NULL,
    primary_training_purpose TEXT NOT NULL,
    tolerance_basis TEXT NOT NULL DEFAULT 'distance'
        CHECK (tolerance_basis IN ('distance', 'duration')),
    reference_distance_m REAL,
    reference_duration_s REAL,
    distance_tolerance_pct REAL NOT NULL DEFAULT 10.0 CHECK (distance_tolerance_pct >= 0),
    duration_tolerance_pct REAL NOT NULL DEFAULT 10.0 CHECK (duration_tolerance_pct >= 0),
    cohort_window_type TEXT NOT NULL DEFAULT 'rolling_months'
        CHECK (cohort_window_type IN ('rolling_months', 'all_history', 'date_range')),
    cohort_window_value INTEGER,
    include_current_activity_in_baseline INTEGER NOT NULL DEFAULT 0 CHECK (include_current_activity_in_baseline IN (0, 1)),
    exclude_stride INTEGER NOT NULL DEFAULT 1 CHECK (exclude_stride IN (0, 1)),
    exclude_progression INTEGER NOT NULL DEFAULT 1 CHECK (exclude_progression IN (0, 1)),
    exclude_fast_finish INTEGER NOT NULL DEFAULT 1 CHECK (exclude_fast_finish IN (0, 1)),
    exclude_quality_segments INTEGER NOT NULL DEFAULT 1 CHECK (exclude_quality_segments IN (0, 1)),
    minimum_comparison_samples INTEGER NOT NULL DEFAULT 3 CHECK (minimum_comparison_samples >= 1),
    minimum_trend_samples INTEGER NOT NULL DEFAULT 5 CHECK (minimum_trend_samples >= 1),
    temperature_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (temperature_filter_enabled IN (0, 1)),
    humidity_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (humidity_filter_enabled IN (0, 1)),
    shoe_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (shoe_filter_enabled IN (0, 1)),
    route_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (route_filter_enabled IN (0, 1)),
    terrain_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (terrain_filter_enabled IN (0, 1)),
    sequence_role_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (sequence_role_filter_enabled IN (0, 1)),
    training_block_position_filter_enabled INTEGER NOT NULL DEFAULT 0 CHECK (training_block_position_filter_enabled IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE VIEW activity_comparison_base_view AS
SELECT
    ar.activity_id,
    ar.activity_start_time,
    ar.activity_date AS local_date,
    ar.activity_name,
    ar.workout_type_id,
    ar.workout_type_code AS workout_family,
    ar.workout_type_name_en AS workout_family_name_en,
    CASE
        WHEN ar.workout_type_code IN ('easy_run', 'recovery_run')
        THEN 'continuous'
        WHEN ar.workout_type_code = 'tempo_run'
        THEN 'tempo_structured'
        WHEN ar.workout_type_code = 'interval_run'
        THEN 'interval_structured'
        WHEN ar.workout_type_code = 'progression_run'
        THEN 'progression_structured'
        ELSE 'unknown'
    END AS structure_type,
    ar.primary_training_purpose_code AS primary_training_purpose,
    aws.has_workout_structure,
    aws.num_valid_steps,
    aws.workout_name AS planned_workout_name,
    aws.workout_description AS planned_workout_description,
    ar.distance_km * 1000.0 AS distance_m,
    ar.duration_sec,
    ar.avg_pace_sec_per_km AS average_pace_s_per_km,
    ar.avg_hr AS average_heart_rate_bpm,
    ar.avg_power_w AS average_power_w,
    CASE
        WHEN ar.avg_power_w IS NULL THEN 'unavailable'
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_origin:estimated]%' THEN 'estimated'
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_origin:governed_derived]%' THEN 'governed_derived'
        ELSE 'official_activity'
    END AS average_power_origin,
    CASE
        WHEN ar.avg_power_w IS NULL THEN 'insufficient'
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_origin:estimated]%' THEN 'estimated'
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_origin:governed_derived]%' THEN 'derived'
        ELSE 'measured'
    END AS average_power_confidence,
    CASE
        WHEN ar.avg_power_w IS NULL THEN NULL
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_source_system:stryd]%' THEN 'stryd'
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_source_system:garmin_or_equivalent]%' THEN 'garmin_or_equivalent'
        ELSE 'garmin_or_equivalent'
    END AS power_source_system,
    CASE
        WHEN ar.avg_power_w IS NULL THEN NULL
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_measurement_method:external_sensor]%' THEN 'external_sensor'
        WHEN LOWER(COALESCE(ar.notes, '')) LIKE '%[power_measurement_method:governed_derived]%' THEN 'governed_derived'
        ELSE 'activity_summary'
    END AS power_measurement_method,
    ar.training_load,
    ar.stamina_start_pct AS stamina_start,
    ar.stamina_end_pct AS stamina_end,
    CASE
        WHEN ar.stamina_start_pct IS NOT NULL AND ar.stamina_end_pct IS NOT NULL
        THEN ar.stamina_start_pct - ar.stamina_end_pct
        ELSE NULL
    END AS stamina_drop,
    ar.temperature_c,
    ar.humidity_pct,
    ar.shoe_id,
    ar.shoe_code,
    ar.shoe_display_name,
    ar.start_latitude,
    ar.start_longitude,
    ar.end_latitude,
    ar.end_longitude,
    ar.activity_type,
    ar.is_quality_session,
    ar.is_long_run,
    ar.is_recovery_focused,
    CASE
        WHEN LOWER(COALESCE(ar.activity_name, '')) LIKE '%stride%' THEN 1
        WHEN LOWER(COALESCE(aws.workout_name, '')) LIKE '%stride%' THEN 1
        WHEN LOWER(COALESCE(aws.workout_description, '')) LIKE '%stride%' THEN 1
        ELSE 0
    END AS stride_count,
    'fallback_keyword' AS structure_detection_origin,
    'inferred' AS structure_detection_confidence,
    CASE
        WHEN ar.is_quality_session = 1 OR ar.workout_type_code IN ('tempo_run', 'interval_run', 'progression_run') THEN 1
        ELSE 0
    END AS quality_segment_count,
    CASE
        WHEN LOWER(COALESCE(ar.activity_name, '')) LIKE '%progression%' THEN 1
        WHEN LOWER(COALESCE(aws.workout_name, '')) LIKE '%progression%' THEN 1
        WHEN LOWER(COALESCE(aws.workout_description, '')) LIKE '%progression%' THEN 1
        ELSE 0
    END AS progression_flag,
    CASE
        WHEN LOWER(COALESCE(ar.activity_name, '')) LIKE '%fast finish%' THEN 1
        WHEN LOWER(COALESCE(aws.workout_name, '')) LIKE '%fast finish%' THEN 1
        WHEN LOWER(COALESCE(aws.workout_description, '')) LIKE '%fast finish%' THEN 1
        ELSE 0
    END AS fast_finish_flag,
    CASE
        WHEN ar.is_recovery_focused = 1 THEN 'recovery'
        WHEN ar.is_long_run = 1 THEN 'long_run'
        WHEN ar.is_quality_session = 1 THEN 'quality'
        ELSE 'default'
    END AS sequence_role,
    CASE
        WHEN ar.is_long_run = 1 THEN 'long_run'
        WHEN ar.is_quality_session = 1 THEN 'quality'
        WHEN ar.is_recovery_focused = 1 THEN 'recovery'
        ELSE 'default'
    END AS training_block_position,
    CASE
        WHEN ar.avg_power_w IS NOT NULL THEN 1
        ELSE 0
    END AS has_official_power,
    CASE
        WHEN ar.avg_hr IS NOT NULL THEN 1
        ELSE 0
    END AS has_heart_rate,
    CASE
        WHEN ar.distance_km IS NOT NULL AND ar.duration_sec IS NOT NULL THEN 1
        ELSE 0
    END AS has_core_measurements
FROM activity_review_view ar
LEFT JOIN activity_workout_structure aws
    ON aws.activity_id = ar.activity_id;

CREATE VIEW activity_workout_segment_boundary_view AS
WITH scoped AS (
    SELECT
        base.activity_id,
        CASE
            WHEN base.workout_family IN ('easy_run', 'recovery_run') THEN 'whole_activity'
            WHEN base.workout_family = 'tempo_run' THEN 'main_segment'
            WHEN base.workout_family = 'interval_run' THEN 'work_intervals'
            WHEN base.is_long_run = 1 THEN 'whole_activity'
            ELSE 'whole_activity'
        END AS analysis_scope,
        CASE
            WHEN base.workout_family IN ('easy_run', 'recovery_run') THEN 'resolved'
            WHEN base.workout_family = 'tempo_run' AND COALESCE(base.has_workout_structure, 0) = 1 AND COALESCE(base.num_valid_steps, 0) >= 3 THEN 'resolved'
            WHEN base.workout_family = 'tempo_run' THEN 'insufficient'
            WHEN base.workout_family = 'interval_run' AND COALESCE(base.has_workout_structure, 0) = 1 AND COALESCE(base.num_valid_steps, 0) >= 4 THEN 'resolved'
            WHEN base.workout_family = 'interval_run' THEN 'insufficient'
            WHEN base.is_long_run = 1 THEN 'resolved'
            ELSE 'insufficient'
        END AS scope_resolution_status
    FROM activity_comparison_base_view base
),
full_workout_sequence AS (
    SELECT
        scoped.activity_id,
        scoped.analysis_scope,
        scoped.scope_resolution_status,
        aws.split_index AS executed_segment_index,
        aws.split_index AS source_split_index,
        step.step_index AS source_step_index,
        LOWER(COALESCE(step.intensity, 'unknown')) AS segment_role,
        aws.total_distance_m AS segment_distance_m,
        aws.total_timer_time_sec * 1.0 AS segment_duration_s,
        SUM(aws.total_timer_time_sec * 1.0) OVER (
            PARTITION BY scoped.activity_id
            ORDER BY aws.split_index
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_duration_s,
        SUM(aws.total_distance_m) OVER (
            PARTITION BY scoped.activity_id
            ORDER BY aws.split_index
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_distance_m
    FROM scoped
    JOIN activity_workout_split aws
        ON aws.activity_id = scoped.activity_id
    LEFT JOIN activity_workout_step step
        ON step.activity_id = aws.activity_id
       AND step.step_index = aws.split_index
),
segment_seed AS (
    SELECT
        scoped.activity_id,
        scoped.analysis_scope,
        scoped.scope_resolution_status,
        kv.split_index AS executed_segment_index,
        kv.split_index AS source_split_index,
        NULL AS source_step_index,
        'whole' AS segment_role,
        kv.split_distance_m AS segment_distance_m,
        kv.elapsed_time_sec * 1.0 AS segment_duration_s,
        SUM(kv.elapsed_time_sec * 1.0) OVER (
            PARTITION BY scoped.activity_id, scoped.analysis_scope
            ORDER BY kv.split_index
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_duration_s,
        SUM(kv.split_distance_m) OVER (
            PARTITION BY scoped.activity_id, scoped.analysis_scope
            ORDER BY kv.split_index
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_distance_m,
        'kilometer_split' AS boundary_origin,
        'direct' AS boundary_confidence
    FROM scoped
    JOIN kilometer_split kv
        ON kv.activity_id = scoped.activity_id
    WHERE scoped.analysis_scope = 'whole_activity'

    UNION ALL

    SELECT
        fws.activity_id,
        fws.analysis_scope,
        fws.scope_resolution_status,
        fws.executed_segment_index,
        fws.source_split_index,
        fws.source_step_index,
        'whole' AS segment_role,
        fws.segment_distance_m,
        fws.segment_duration_s,
        fws.prior_duration_s,
        fws.prior_distance_m,
        'activity_workout_split_fallback' AS boundary_origin,
        'fallback' AS boundary_confidence
    FROM full_workout_sequence fws
    WHERE fws.analysis_scope = 'whole_activity'
      AND NOT EXISTS (
            SELECT 1
            FROM kilometer_split ks
            WHERE ks.activity_id = fws.activity_id
      )

    UNION ALL

    SELECT
        fws.activity_id,
        fws.analysis_scope,
        fws.scope_resolution_status,
        fws.executed_segment_index,
        fws.source_split_index,
        fws.source_step_index,
        fws.segment_role,
        fws.segment_distance_m,
        fws.segment_duration_s,
        fws.prior_duration_s,
        fws.prior_distance_m,
        'activity_workout_split' AS boundary_origin,
        'best_effort_step_alignment' AS boundary_confidence
    FROM full_workout_sequence fws
    WHERE fws.analysis_scope = 'main_segment'
      AND fws.segment_role = 'tempo'

    UNION ALL

    SELECT
        fws.activity_id,
        fws.analysis_scope,
        fws.scope_resolution_status,
        fws.executed_segment_index,
        fws.source_split_index,
        fws.source_step_index,
        fws.segment_role,
        fws.segment_distance_m,
        fws.segment_duration_s,
        fws.prior_duration_s,
        fws.prior_distance_m,
        'activity_workout_split' AS boundary_origin,
        'best_effort_step_alignment' AS boundary_confidence
    FROM full_workout_sequence fws
    WHERE fws.analysis_scope = 'work_intervals'
      AND fws.segment_role = 'work'
)
SELECT
    segment_seed.activity_id,
    segment_seed.analysis_scope,
    segment_seed.scope_resolution_status,
    segment_seed.executed_segment_index,
    segment_seed.source_split_index,
    segment_seed.source_step_index,
    segment_seed.segment_role,
    COALESCE(segment_seed.prior_duration_s, 0.0) AS segment_start_offset_s,
    COALESCE(segment_seed.prior_duration_s, 0.0) + COALESCE(segment_seed.segment_duration_s, 0.0) AS segment_end_offset_s,
    COALESCE(segment_seed.prior_distance_m, 0.0) AS segment_start_distance_m,
    COALESCE(segment_seed.prior_distance_m, 0.0) + COALESCE(segment_seed.segment_distance_m, 0.0) AS segment_end_distance_m,
    segment_seed.segment_distance_m,
    segment_seed.segment_duration_s,
    segment_seed.boundary_origin,
    segment_seed.boundary_confidence
FROM segment_seed;

CREATE VIEW activity_workout_segment_metric_view AS
WITH boundary AS (
    SELECT *
    FROM activity_workout_segment_boundary_view
),
sample_aggregation AS (
    SELECT
        boundary.activity_id,
        boundary.analysis_scope,
        boundary.executed_segment_index,
        COUNT(sample.sample_index) AS sample_count,
        SUM(
            CASE
                WHEN sample.heart_rate_bpm IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                THEN 1 ELSE 0
            END
        ) AS valid_hr_sample_count,
        SUM(
            CASE
                WHEN sample.power_w IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                THEN 1 ELSE 0
            END
        ) AS valid_power_sample_count,
        AVG(
            CASE
                WHEN sample.heart_rate_bpm IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                THEN sample.heart_rate_bpm
            END
        ) AS average_heart_rate_bpm,
        AVG(
            CASE
                WHEN sample.power_w IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                THEN sample.power_w
            END
        ) AS average_power_w,
        COUNT(DISTINCT
            CASE
                WHEN sample.power_w IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                 AND sample.power_source_system IS NOT NULL
                THEN sample.power_source_system
            END
        ) AS power_source_system_count,
        MAX(
            CASE
                WHEN sample.power_w IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                THEN sample.power_source_system
            END
        ) AS single_power_source_system,
        COUNT(DISTINCT
            CASE
                WHEN sample.power_w IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                 AND sample.power_measurement_method IS NOT NULL
                THEN sample.power_measurement_method
            END
        ) AS power_measurement_method_count,
        MAX(
            CASE
                WHEN sample.power_w IS NOT NULL
                 AND sample.sample_quality_status <> 'invalid'
                THEN sample.power_measurement_method
            END
        ) AS single_power_measurement_method
    FROM activity_workout_segment_boundary_view boundary
    LEFT JOIN activity_sample sample
        ON sample.activity_id = boundary.activity_id
       AND sample.elapsed_offset_s >= boundary.segment_start_offset_s
       AND sample.elapsed_offset_s < boundary.segment_end_offset_s
    GROUP BY
        boundary.activity_id,
        boundary.analysis_scope,
        boundary.executed_segment_index
)
SELECT
    boundary.activity_id,
    boundary.analysis_scope,
    boundary.scope_resolution_status,
    boundary.executed_segment_index,
    boundary.source_split_index,
    boundary.source_step_index,
    boundary.segment_role,
    boundary.segment_start_offset_s,
    boundary.segment_end_offset_s,
    boundary.segment_start_distance_m,
    boundary.segment_end_distance_m,
    boundary.segment_distance_m,
    boundary.segment_duration_s,
    boundary.boundary_origin,
    boundary.boundary_confidence,
    CASE
        WHEN boundary.segment_distance_m > 0 AND boundary.segment_duration_s > 0
        THEN CAST(ROUND(boundary.segment_duration_s * 1000.0 / boundary.segment_distance_m) AS INTEGER)
        ELSE NULL
    END AS average_pace_s_per_km,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' THEN ks.avg_hr
        WHEN sample_aggregation.valid_hr_sample_count > 0
        THEN CAST(ROUND(sample_aggregation.average_heart_rate_bpm) AS INTEGER)
        ELSE NULL
    END AS average_heart_rate_bpm,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' THEN ks.avg_power_w
        WHEN sample_aggregation.valid_power_sample_count > 0
        THEN CAST(ROUND(sample_aggregation.average_power_w) AS INTEGER)
        ELSE NULL
    END AS average_power_w,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' AND ks.avg_hr IS NOT NULL THEN 'official_segment'
        WHEN sample_aggregation.valid_hr_sample_count > 0 THEN 'governed_derived'
        ELSE 'unavailable'
    END AS heart_rate_origin,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' AND ks.avg_hr IS NOT NULL THEN 'measured'
        WHEN sample_aggregation.valid_hr_sample_count > 0 THEN 'derived'
        ELSE 'unavailable'
    END AS heart_rate_quality_status,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' AND ks.avg_power_w IS NOT NULL THEN 'official_segment'
        WHEN sample_aggregation.valid_power_sample_count > 0 THEN 'governed_derived'
        ELSE 'unavailable'
    END AS power_origin,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' AND ks.avg_power_w IS NOT NULL THEN 'garmin_or_equivalent'
        WHEN sample_aggregation.valid_power_sample_count = 0 THEN 'unknown'
        WHEN sample_aggregation.power_source_system_count > 1 THEN 'mixed'
        WHEN sample_aggregation.power_source_system_count = 0 THEN 'unknown'
        ELSE COALESCE(sample_aggregation.single_power_source_system, 'unknown')
    END AS power_source_system,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' AND ks.avg_power_w IS NOT NULL THEN 'kilometer_split'
        WHEN sample_aggregation.valid_power_sample_count = 0 THEN 'unknown'
        WHEN sample_aggregation.power_measurement_method_count > 1 THEN 'mixed'
        WHEN sample_aggregation.power_measurement_method_count = 0 THEN 'unknown'
        ELSE COALESCE(sample_aggregation.single_power_measurement_method, 'unknown')
    END AS power_measurement_method,
    CASE
        WHEN boundary.boundary_origin = 'kilometer_split' AND ks.avg_power_w IS NOT NULL THEN 'measured'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_source_system_count > 1 THEN 'mixed'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_measurement_method_count > 1 THEN 'mixed'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND (
              sample_aggregation.power_source_system_count = 0
              OR sample_aggregation.power_measurement_method_count = 0
         ) THEN 'missing'
        WHEN sample_aggregation.valid_power_sample_count > 0 THEN 'derived'
        ELSE 'unavailable'
    END AS power_quality_status,
    sample_aggregation.sample_count,
    sample_aggregation.valid_hr_sample_count,
    sample_aggregation.valid_power_sample_count,
    NULL AS expected_sample_count,
    NULL AS sample_coverage_pct,
    CASE
        WHEN sample_aggregation.sample_count > 0 THEN 'observed'
        WHEN boundary.boundary_origin = 'kilometer_split' THEN 'not_required'
        ELSE 'unavailable'
    END AS sample_coverage_status,
    CASE
        WHEN boundary.scope_resolution_status <> 'resolved' THEN 'insufficient_scope'
        WHEN boundary.segment_duration_s IS NULL OR boundary.segment_distance_m IS NULL THEN 'invalid_boundary'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_source_system_count > 1 THEN 'mixed_power_provenance'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_measurement_method_count > 1 THEN 'mixed_power_provenance'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND (
              sample_aggregation.power_source_system_count = 0
              OR sample_aggregation.power_measurement_method_count = 0
         ) THEN 'missing_power_provenance'
        WHEN sample_aggregation.valid_hr_sample_count > 0
         AND sample_aggregation.valid_power_sample_count > 0 THEN 'valid'
        WHEN sample_aggregation.valid_hr_sample_count > 0
          OR sample_aggregation.valid_power_sample_count > 0 THEN 'partial'
        WHEN ks.avg_hr IS NOT NULL OR ks.avg_power_w IS NOT NULL THEN 'partial'
        ELSE 'pace_only'
    END AS segment_metric_validity,
    CASE
        WHEN boundary.scope_resolution_status <> 'resolved' THEN 'scope_not_resolved'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_source_system_count > 1 THEN 'mixed_power_source_system'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_measurement_method_count > 1 THEN 'mixed_power_measurement_method'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_source_system_count = 0 THEN 'missing_power_source_system'
        WHEN sample_aggregation.valid_power_sample_count > 0
         AND sample_aggregation.power_measurement_method_count = 0 THEN 'missing_power_measurement_method'
        WHEN sample_aggregation.valid_hr_sample_count > 0
          OR sample_aggregation.valid_power_sample_count > 0 THEN NULL
        WHEN boundary.boundary_origin <> 'kilometer_split' THEN 'sample_stream_required_for_hr_power'
        ELSE NULL
    END AS segment_metric_notes
FROM boundary
LEFT JOIN kilometer_split ks
    ON ks.activity_id = boundary.activity_id
   AND ks.split_index = boundary.source_split_index
   AND boundary.boundary_origin = 'kilometer_split'
LEFT JOIN sample_aggregation
    ON sample_aggregation.activity_id = boundary.activity_id
   AND sample_aggregation.analysis_scope = boundary.analysis_scope
   AND sample_aggregation.executed_segment_index = boundary.executed_segment_index;

CREATE VIEW activity_comparison_anchor_view AS
WITH scoped AS (
    SELECT
        base.*,
        CASE
            WHEN base.workout_family IN ('easy_run', 'recovery_run') THEN 'whole_activity'
            WHEN base.workout_family = 'tempo_run' THEN 'main_segment'
            WHEN base.workout_family = 'interval_run' THEN 'work_intervals'
            WHEN base.is_long_run = 1 THEN 'whole_activity'
            ELSE 'whole_activity'
        END AS analysis_scope
        ,
        CASE
            WHEN base.workout_family IN ('easy_run', 'recovery_run') THEN 'resolved'
            WHEN base.workout_family = 'tempo_run' AND COALESCE(base.has_workout_structure, 0) = 1 AND COALESCE(base.num_valid_steps, 0) >= 3 THEN 'resolved'
            WHEN base.workout_family = 'tempo_run' THEN 'insufficient'
            WHEN base.workout_family = 'interval_run' AND COALESCE(base.has_workout_structure, 0) = 1 AND COALESCE(base.num_valid_steps, 0) >= 4 THEN 'resolved'
            WHEN base.workout_family = 'interval_run' THEN 'insufficient'
            WHEN base.is_long_run = 1 THEN 'resolved'
            ELSE 'insufficient'
        END AS scope_resolution_status
    FROM activity_comparison_base_view base
),
activity_scope_segment_view AS (
    SELECT
        sm.activity_id,
        sm.analysis_scope,
        sm.scope_resolution_status,
        sm.executed_segment_index AS scope_segment_order,
        sm.source_split_index,
        sm.segment_role,
        sm.segment_distance_m,
        sm.average_pace_s_per_km AS pace_s_per_km,
        sm.average_heart_rate_bpm AS heart_rate_bpm,
        sm.average_power_w AS power_w
    FROM activity_workout_segment_metric_view sm
),
split_base AS (
    SELECT
        seg.activity_id,
        seg.analysis_scope,
        seg.scope_resolution_status,
        seg.scope_segment_order,
        seg.source_split_index,
        seg.segment_role,
        seg.segment_distance_m,
        seg.pace_s_per_km,
        seg.heart_rate_bpm,
        seg.power_w,
        COUNT(*) OVER (PARTITION BY seg.activity_id, seg.analysis_scope) AS split_count,
        AVG(seg.segment_distance_m) OVER (PARTITION BY seg.activity_id, seg.analysis_scope) AS avg_split_distance_m
    FROM activity_scope_segment_view seg
),
representative_splits AS (
    SELECT
        sb.*,
        CASE
            WHEN sb.segment_distance_m >= MAX(400.0, sb.avg_split_distance_m * 0.5) THEN 1
            ELSE 0
        END AS is_representative_split,
        ROW_NUMBER() OVER (
            PARTITION BY sb.activity_id, sb.analysis_scope
            ORDER BY
                CASE WHEN sb.segment_distance_m >= MAX(400.0, sb.avg_split_distance_m * 0.5) THEN 1 ELSE 0 END DESC,
                sb.scope_segment_order ASC
        ) AS representative_asc_rank,
        ROW_NUMBER() OVER (
            PARTITION BY sb.activity_id, sb.analysis_scope
            ORDER BY
                CASE WHEN sb.segment_distance_m >= MAX(400.0, sb.avg_split_distance_m * 0.5) THEN 1 ELSE 0 END DESC,
                sb.scope_segment_order DESC
        ) AS finish_rank
    FROM split_base sb
),
representative_counts AS (
    SELECT
        activity_id,
        analysis_scope,
        SUM(CASE WHEN is_representative_split = 1 THEN 1 ELSE 0 END) AS representative_count
    FROM representative_splits
    GROUP BY activity_id, analysis_scope
),
midpoint_choice AS (
    SELECT
        activity_id,
        analysis_scope,
        CAST((representative_count + 1) / 2 AS INTEGER) AS midpoint_rank
    FROM representative_counts
),
selected AS (
    SELECT
        scoped.activity_id,
        scoped.analysis_scope,
        scoped.scope_resolution_status,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.representative_asc_rank = 1 THEN rs.source_split_index END)
        END AS start_anchor_split_index,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.representative_asc_rank = 1 THEN ROUND(rs.representative_asc_rank * 100.0 / rc.representative_count, 1) END)
        END AS start_anchor_position_pct,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.representative_asc_rank = 1 THEN rs.pace_s_per_km END)
        END AS start_pace_s_per_km,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.representative_asc_rank = 1 THEN rs.heart_rate_bpm END)
        END AS start_heart_rate_bpm,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.representative_asc_rank = 1 THEN rs.power_w END)
        END AS start_power_w,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE
                WHEN rs.is_representative_split = 1
                 AND rs.representative_asc_rank = mc.midpoint_rank
                THEN rs.source_split_index END)
        END AS mid_anchor_split_index,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE
                WHEN rs.is_representative_split = 1
                 AND rs.representative_asc_rank = mc.midpoint_rank
                THEN ROUND(rs.representative_asc_rank * 100.0 / rc.representative_count, 1) END)
        END AS mid_anchor_position_pct,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE
                WHEN rs.is_representative_split = 1
                 AND rs.representative_asc_rank = mc.midpoint_rank
                THEN rs.pace_s_per_km END)
        END AS mid_pace_s_per_km,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE
                WHEN rs.is_representative_split = 1
                 AND rs.representative_asc_rank = mc.midpoint_rank
                THEN rs.heart_rate_bpm END)
        END AS mid_heart_rate_bpm,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE
                WHEN rs.is_representative_split = 1
                 AND rs.representative_asc_rank = mc.midpoint_rank
                THEN rs.power_w END)
        END AS mid_power_w,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN rs.source_split_index END)
        END AS finish_anchor_split_index,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN 100.0 END)
        END AS finish_anchor_position_pct,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN rs.pace_s_per_km END)
        END AS finish_pace_s_per_km,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN rs.heart_rate_bpm END)
        END AS finish_heart_rate_bpm,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN NULL
            ELSE MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN rs.power_w END)
        END AS finish_power_w,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN 'insufficient'
            WHEN MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN rs.source_split_index END) IS NULL THEN 'insufficient'
            ELSE 'valid'
        END AS anchor_validity_status,
        CASE
            WHEN scoped.scope_resolution_status = 'insufficient' THEN 'insufficient_scope'
            WHEN MAX(CASE WHEN rs.is_representative_split = 1 AND rs.finish_rank = 1 THEN rs.source_split_index END) IS NULL THEN 'missing_finish_anchor'
            ELSE NULL
        END AS anchor_validity_notes
    FROM scoped
    LEFT JOIN representative_splits rs
        ON rs.activity_id = scoped.activity_id
       AND rs.analysis_scope = scoped.analysis_scope
    LEFT JOIN representative_counts rc
        ON rc.activity_id = scoped.activity_id
       AND rc.analysis_scope = scoped.analysis_scope
    LEFT JOIN midpoint_choice mc
        ON mc.activity_id = scoped.activity_id
       AND mc.analysis_scope = scoped.analysis_scope
    GROUP BY
        scoped.activity_id,
        scoped.analysis_scope,
        scoped.scope_resolution_status
)
SELECT
    selected.*
FROM selected;

CREATE VIEW activity_comparison_metric_view AS
WITH base AS (
    SELECT
        scoped.*,
        anchor.analysis_scope,
        anchor.scope_resolution_status,
        anchor.start_anchor_split_index,
        anchor.start_anchor_position_pct,
        anchor.start_pace_s_per_km,
        anchor.start_heart_rate_bpm,
        anchor.start_power_w,
        anchor.mid_anchor_split_index,
        anchor.mid_anchor_position_pct,
        anchor.mid_pace_s_per_km,
        anchor.mid_heart_rate_bpm,
        anchor.mid_power_w,
        anchor.finish_anchor_split_index,
        anchor.finish_anchor_position_pct,
        anchor.finish_pace_s_per_km,
        anchor.finish_heart_rate_bpm,
        anchor.finish_power_w,
        anchor.anchor_validity_status,
        anchor.anchor_validity_notes
    FROM activity_comparison_base_view scoped
    LEFT JOIN activity_comparison_anchor_view anchor
        ON anchor.activity_id = scoped.activity_id
),
scoped AS (
    SELECT
        base.activity_id,
        base.analysis_scope,
        base.anchor_validity_status,
        sm.executed_segment_index AS scope_segment_order,
        sm.segment_distance_m,
        sm.average_pace_s_per_km AS pace_s_per_km,
        sm.average_heart_rate_bpm AS heart_rate_bpm,
        sm.average_power_w AS power_w
    FROM base
    JOIN activity_workout_segment_metric_view sm
        ON sm.activity_id = base.activity_id
       AND sm.analysis_scope = base.analysis_scope
),
split_base AS (
    SELECT
        scoped.*,
        COUNT(*) OVER (PARTITION BY scoped.activity_id, scoped.analysis_scope) AS split_count,
        AVG(scoped.segment_distance_m) OVER (PARTITION BY scoped.activity_id, scoped.analysis_scope) AS avg_split_distance_m
    FROM scoped
),
representative_splits AS (
    SELECT
        sb.*,
        CASE
            WHEN sb.segment_distance_m >= MAX(400.0, sb.avg_split_distance_m * 0.5) THEN 1
            ELSE 0
        END AS is_representative_split
    FROM split_base sb
),
stats AS (
    SELECT
        activity_id,
        COUNT(*) AS valid_split_count,
        MIN(pace_s_per_km) AS fastest_split_pace,
        MAX(pace_s_per_km) AS slowest_split_pace,
        AVG(pace_s_per_km) AS avg_split_pace,
        AVG(heart_rate_bpm) AS avg_split_hr,
        AVG(power_w) AS avg_split_power
    FROM representative_splits
    WHERE is_representative_split = 1
    GROUP BY activity_id
)
SELECT
    base.activity_id,
    base.activity_start_time,
    base.local_date,
    base.activity_name,
    base.workout_family,
    base.structure_type,
    base.primary_training_purpose,
    base.analysis_scope,
    base.distance_m,
    base.duration_sec,
    base.average_pace_s_per_km,
    base.average_heart_rate_bpm,
    base.average_power_w,
    base.average_power_origin,
    base.average_power_confidence,
    base.power_source_system,
    base.power_measurement_method,
    base.training_load,
    base.stamina_start,
    base.stamina_end,
    base.stamina_drop,
    base.temperature_c,
    base.humidity_pct,
    base.shoe_id,
    base.shoe_code,
    base.shoe_display_name,
    base.activity_type,
    base.is_quality_session,
    base.is_long_run,
    base.is_recovery_focused,
    base.stride_count,
    base.quality_segment_count,
    base.progression_flag,
    base.fast_finish_flag,
    base.sequence_role,
    base.training_block_position,
    base.has_official_power,
    base.has_heart_rate,
    base.has_core_measurements,
    base.anchor_validity_status,
    base.anchor_validity_notes,
    base.start_anchor_split_index,
    base.start_anchor_position_pct,
    base.start_pace_s_per_km,
    base.start_heart_rate_bpm,
    base.start_power_w,
    base.mid_anchor_split_index,
    base.mid_anchor_position_pct,
    base.mid_pace_s_per_km,
    base.mid_heart_rate_bpm,
    base.mid_power_w,
    base.finish_anchor_split_index,
    base.finish_anchor_position_pct,
    base.finish_pace_s_per_km,
    base.finish_heart_rate_bpm,
    base.finish_power_w,
    CASE
        WHEN base.anchor_validity_status <> 'valid' THEN NULL
        WHEN base.finish_pace_s_per_km IS NULL OR base.start_pace_s_per_km IS NULL THEN NULL
        ELSE base.finish_pace_s_per_km - base.start_pace_s_per_km
    END AS pace_delta_sec,
    CASE
        WHEN base.anchor_validity_status <> 'valid' THEN 'insufficient'
        WHEN base.finish_pace_s_per_km IS NULL OR base.start_pace_s_per_km IS NULL THEN 'insufficient'
        WHEN ABS(base.finish_pace_s_per_km - base.start_pace_s_per_km) <= 3 THEN 'stable'
        WHEN base.finish_pace_s_per_km < base.start_pace_s_per_km THEN 'faster'
        ELSE 'slower'
    END AS pace_change_direction,
    CASE
        WHEN base.anchor_validity_status <> 'valid' THEN NULL
        WHEN base.finish_pace_s_per_km IS NULL OR base.start_pace_s_per_km IS NULL THEN NULL
        ELSE ABS(base.finish_pace_s_per_km - base.start_pace_s_per_km)
    END AS pace_change_magnitude_sec,
    CASE
        WHEN base.anchor_validity_status <> 'valid' THEN NULL
        WHEN base.finish_heart_rate_bpm IS NULL OR base.start_heart_rate_bpm IS NULL THEN NULL
        ELSE base.finish_heart_rate_bpm - base.start_heart_rate_bpm
    END AS heart_rate_delta_bpm,
    CASE
        WHEN base.anchor_validity_status <> 'valid' THEN NULL
        WHEN base.finish_power_w IS NULL OR base.start_power_w IS NULL THEN NULL
        ELSE base.finish_power_w - base.start_power_w
    END AS power_delta_w,
    CASE
        WHEN stats.valid_split_count IS NULL OR stats.valid_split_count = 0 THEN NULL
        ELSE stats.slowest_split_pace - stats.fastest_split_pace
    END AS pace_range_sec,
    CASE
        WHEN stats.avg_split_pace IS NULL OR stats.avg_split_pace = 0 THEN NULL
        ELSE ROUND((stats.slowest_split_pace - stats.fastest_split_pace) * 100.0 / stats.avg_split_pace, 1)
    END AS pace_range_pct,
    CASE
        WHEN stats.avg_split_power IS NULL OR stats.avg_split_power = 0 THEN NULL
        ELSE ROUND((MAX(base.start_power_w, base.finish_power_w) - MIN(base.start_power_w, base.finish_power_w)) * 100.0 / stats.avg_split_power, 1)
    END AS power_range_pct,
    base.stamina_drop,
    base.training_load,
    CASE
        WHEN base.anchor_validity_status = 'valid'
             AND base.start_pace_s_per_km IS NOT NULL
             AND base.finish_pace_s_per_km IS NOT NULL
        THEN 'valid'
        ELSE 'insufficient'
    END AS metric_validity_status,
    CASE
        WHEN base.anchor_validity_status = 'valid' THEN NULL
        ELSE base.anchor_validity_notes
    END AS metric_validity_notes
FROM base
LEFT JOIN stats
    ON stats.activity_id = base.activity_id;

CREATE VIEW similar_workout_comparison_view AS
-- Eligibility gating takes precedence over comparison insufficiency.
-- Scope and metric validity remain independently observable in the
-- anchor and metric views even when a seed is excluded from comparison.
WITH definition_seed AS (
    SELECT
        metric.*,
        definition.comparison_definition_id,
        definition.comparison_name,
        definition.tolerance_basis,
        definition.reference_distance_m,
        definition.reference_duration_s,
        definition.distance_tolerance_pct,
        definition.duration_tolerance_pct,
        definition.include_current_activity_in_baseline,
        definition.exclude_stride,
        definition.exclude_progression,
        definition.exclude_fast_finish,
        definition.exclude_quality_segments,
        definition.minimum_comparison_samples,
        definition.minimum_trend_samples,
        CASE
            WHEN definition.tolerance_basis = 'distance'
             AND definition.reference_distance_m IS NOT NULL
             AND ABS(metric.distance_m - definition.reference_distance_m) > definition.reference_distance_m * definition.distance_tolerance_pct / 100.0
            THEN 0
            WHEN definition.tolerance_basis = 'duration'
             AND definition.reference_duration_s IS NOT NULL
             AND ABS(metric.duration_sec - definition.reference_duration_s) > definition.reference_duration_s * definition.duration_tolerance_pct / 100.0
            THEN 0
            WHEN definition.exclude_stride = 1 AND metric.stride_count = 1 THEN 0
            WHEN definition.exclude_progression = 1 AND metric.progression_flag = 1 THEN 0
            WHEN definition.exclude_fast_finish = 1 AND metric.fast_finish_flag = 1 THEN 0
            WHEN definition.exclude_quality_segments = 1 AND metric.quality_segment_count = 1 THEN 0
            ELSE 1
        END AS seed_is_cohort_eligible,
        CASE
            WHEN definition.tolerance_basis = 'distance'
             AND definition.reference_distance_m IS NOT NULL
             AND ABS(metric.distance_m - definition.reference_distance_m) > definition.reference_distance_m * definition.distance_tolerance_pct / 100.0
            THEN 'outside distance tolerance'
            WHEN definition.tolerance_basis = 'duration'
             AND definition.reference_duration_s IS NOT NULL
             AND ABS(metric.duration_sec - definition.reference_duration_s) > definition.reference_duration_s * definition.duration_tolerance_pct / 100.0
            THEN 'outside duration tolerance'
            WHEN definition.exclude_stride = 1 AND metric.stride_count = 1 THEN 'stride work present'
            WHEN definition.exclude_progression = 1 AND metric.progression_flag = 1 THEN 'progression work present'
            WHEN definition.exclude_fast_finish = 1 AND metric.fast_finish_flag = 1 THEN 'fast finish present'
            WHEN definition.exclude_quality_segments = 1 AND metric.quality_segment_count = 1 THEN 'quality segments present'
            ELSE NULL
        END AS seed_exclusion_reason
    FROM activity_comparison_metric_view metric
    JOIN similar_workout_comparison_definition definition
        ON definition.workout_family = metric.workout_family
       AND definition.structure_type = metric.structure_type
       AND definition.primary_training_purpose = metric.primary_training_purpose
),
cohort_member AS (
    SELECT
        seed.activity_id AS seed_activity_id,
        seed.comparison_definition_id,
        seed.comparison_name,
        seed.workout_family,
        seed.structure_type,
        seed.primary_training_purpose,
        seed.analysis_scope,
        seed.tolerance_basis,
        seed.reference_distance_m,
        seed.reference_duration_s,
        seed.distance_tolerance_pct,
        seed.duration_tolerance_pct,
        seed.include_current_activity_in_baseline,
        seed.exclude_stride,
        seed.exclude_progression,
        seed.exclude_fast_finish,
        seed.exclude_quality_segments,
        seed.minimum_comparison_samples,
        seed.minimum_trend_samples,
        seed.average_pace_s_per_km AS seed_average_pace_s_per_km,
        seed.average_heart_rate_bpm AS seed_average_heart_rate_bpm,
        seed.average_power_w AS seed_average_power_w,
        seed.average_power_origin AS seed_average_power_origin,
        seed.average_power_confidence AS seed_average_power_confidence,
        seed.power_source_system AS seed_power_source_system,
        seed.power_measurement_method AS seed_power_measurement_method,
        seed.stamina_drop AS seed_stamina_drop,
        seed.training_load AS seed_training_load,
        seed.temperature_c AS seed_temperature_c,
        seed.humidity_pct AS seed_humidity_pct,
        seed.shoe_id AS seed_shoe_id,
        candidate.activity_id AS cohort_activity_id,
        candidate.average_pace_s_per_km AS cohort_average_pace_s_per_km,
        candidate.average_heart_rate_bpm AS cohort_average_heart_rate_bpm,
        candidate.average_power_w AS cohort_average_power_w,
        candidate.average_power_origin AS cohort_average_power_origin,
        candidate.average_power_confidence AS cohort_average_power_confidence,
        candidate.power_source_system AS cohort_power_source_system,
        candidate.power_measurement_method AS cohort_power_measurement_method,
        candidate.stamina_drop AS cohort_stamina_drop,
        candidate.training_load AS cohort_training_load,
        candidate.temperature_c AS cohort_temperature_c,
        candidate.humidity_pct AS cohort_humidity_pct,
        candidate.shoe_id AS cohort_shoe_id
    FROM definition_seed seed
    LEFT JOIN activity_comparison_metric_view candidate
        ON candidate.workout_family = seed.workout_family
       AND candidate.structure_type = seed.structure_type
       AND candidate.primary_training_purpose = seed.primary_training_purpose
       AND candidate.metric_validity_status = 'valid'
       AND (
            seed.include_current_activity_in_baseline = 1
            OR candidate.activity_id <> seed.activity_id
       )
       AND (
            seed.tolerance_basis = 'distance'
            AND ABS(candidate.distance_m - COALESCE(seed.reference_distance_m, seed.distance_m)) <= COALESCE(seed.reference_distance_m, seed.distance_m) * seed.distance_tolerance_pct / 100.0
           OR seed.tolerance_basis = 'duration'
            AND ABS(candidate.duration_sec - COALESCE(seed.reference_duration_s, seed.duration_sec)) <= COALESCE(seed.reference_duration_s, seed.duration_sec) * seed.duration_tolerance_pct / 100.0
       )
       AND (
            seed.exclude_stride = 0
            OR candidate.stride_count = 0
       )
       AND (
            seed.exclude_progression = 0
            OR candidate.progression_flag = 0
       )
       AND (
            seed.exclude_fast_finish = 0
            OR candidate.fast_finish_flag = 0
       )
       AND (
            seed.exclude_quality_segments = 0
            OR candidate.quality_segment_count = 0
       )
),
cohort_stats AS (
    SELECT
        seed_activity_id AS activity_id,
        comparison_definition_id,
        comparison_name,
        workout_family,
        structure_type,
        primary_training_purpose,
        analysis_scope,
        tolerance_basis,
        reference_distance_m,
        reference_duration_s,
        distance_tolerance_pct,
        duration_tolerance_pct,
        include_current_activity_in_baseline,
        minimum_comparison_samples,
        minimum_trend_samples,
        COUNT(cohort_activity_id) + 1 AS eligible_cohort_sample_count,
        COUNT(cohort_activity_id) AS baseline_sample_count,
        SUM(CASE WHEN cohort_average_pace_s_per_km IS NOT NULL THEN 1 ELSE 0 END) AS baseline_valid_pace_sample_count,
        SUM(CASE WHEN cohort_average_heart_rate_bpm IS NOT NULL THEN 1 ELSE 0 END) AS baseline_valid_hr_sample_count,
        SUM(CASE
            WHEN cohort_average_power_w IS NOT NULL
             AND (
                (cohort_average_power_origin = 'official_activity' AND cohort_average_power_confidence = 'measured')
                OR (cohort_average_power_origin = 'governed_derived' AND cohort_average_power_confidence = 'derived')
             )
             AND cohort_power_source_system = seed_power_source_system
             AND cohort_power_measurement_method = seed_power_measurement_method
            THEN 1 ELSE 0 END) AS baseline_valid_power_sample_count,
        SUM(CASE WHEN cohort_stamina_drop IS NOT NULL THEN 1 ELSE 0 END) AS baseline_valid_stamina_sample_count,
        SUM(CASE WHEN cohort_training_load IS NOT NULL THEN 1 ELSE 0 END) AS baseline_valid_load_sample_count,
        SUM(CASE WHEN cohort_average_pace_s_per_km IS NOT NULL THEN 1 ELSE 0 END)
            + CASE WHEN seed_average_pace_s_per_km IS NOT NULL THEN 1 ELSE 0 END AS valid_pace_sample_count,
        SUM(CASE WHEN cohort_average_heart_rate_bpm IS NOT NULL THEN 1 ELSE 0 END)
            + CASE WHEN seed_average_heart_rate_bpm IS NOT NULL THEN 1 ELSE 0 END AS valid_hr_sample_count,
        SUM(CASE
            WHEN cohort_average_power_w IS NOT NULL
             AND (
                (cohort_average_power_origin = 'official_activity' AND cohort_average_power_confidence = 'measured')
                OR (cohort_average_power_origin = 'governed_derived' AND cohort_average_power_confidence = 'derived')
             )
             AND cohort_power_source_system = seed_power_source_system
             AND cohort_power_measurement_method = seed_power_measurement_method
            THEN 1 ELSE 0 END)
            + CASE
                WHEN seed_average_power_w IS NOT NULL
                 AND (
                    (seed_average_power_origin = 'official_activity' AND seed_average_power_confidence = 'measured')
                    OR (seed_average_power_origin = 'governed_derived' AND seed_average_power_confidence = 'derived')
                 )
                 AND seed_power_source_system IS NOT NULL
                 AND seed_power_measurement_method IS NOT NULL
                THEN 1 ELSE 0 END AS valid_power_sample_count,
        SUM(CASE WHEN cohort_stamina_drop IS NOT NULL THEN 1 ELSE 0 END)
            + CASE WHEN seed_stamina_drop IS NOT NULL THEN 1 ELSE 0 END AS valid_stamina_sample_count,
        SUM(CASE WHEN cohort_training_load IS NOT NULL THEN 1 ELSE 0 END)
            + CASE WHEN seed_training_load IS NOT NULL THEN 1 ELSE 0 END AS valid_load_sample_count
    FROM cohort_member
    GROUP BY
        seed_activity_id,
        comparison_definition_id,
        comparison_name,
        workout_family,
        structure_type,
        primary_training_purpose,
        analysis_scope,
        tolerance_basis,
        reference_distance_m,
        reference_duration_s,
        distance_tolerance_pct,
        duration_tolerance_pct,
        include_current_activity_in_baseline,
        minimum_comparison_samples,
        minimum_trend_samples
),
median_pace AS (
    SELECT seed_activity_id, AVG(cohort_average_pace_s_per_km) AS cohort_median_pace_s_per_km
    FROM (
        SELECT
            seed_activity_id,
            cohort_average_pace_s_per_km,
            ROW_NUMBER() OVER (PARTITION BY seed_activity_id ORDER BY cohort_average_pace_s_per_km) AS rn,
            COUNT(*) OVER (PARTITION BY seed_activity_id) AS cnt
        FROM cohort_member
        WHERE cohort_average_pace_s_per_km IS NOT NULL
    )
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY seed_activity_id
),
median_hr AS (
    SELECT seed_activity_id, AVG(cohort_average_heart_rate_bpm) AS cohort_median_heart_rate_bpm
    FROM (
        SELECT
            seed_activity_id,
            cohort_average_heart_rate_bpm,
            ROW_NUMBER() OVER (PARTITION BY seed_activity_id ORDER BY cohort_average_heart_rate_bpm) AS rn,
            COUNT(*) OVER (PARTITION BY seed_activity_id) AS cnt
        FROM cohort_member
        WHERE cohort_average_heart_rate_bpm IS NOT NULL
    )
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY seed_activity_id
),
median_power AS (
    SELECT seed_activity_id, AVG(cohort_average_power_w) AS cohort_median_power_w
    FROM (
        SELECT
            seed_activity_id,
            cohort_average_power_w,
            ROW_NUMBER() OVER (PARTITION BY seed_activity_id ORDER BY cohort_average_power_w) AS rn,
            COUNT(*) OVER (PARTITION BY seed_activity_id) AS cnt
        FROM cohort_member
        WHERE cohort_average_power_w IS NOT NULL
          AND (
                (cohort_average_power_origin = 'official_activity' AND cohort_average_power_confidence = 'measured')
                OR (cohort_average_power_origin = 'governed_derived' AND cohort_average_power_confidence = 'derived')
              )
          AND cohort_power_source_system = seed_power_source_system
          AND cohort_power_measurement_method = seed_power_measurement_method
    ) median_power_values
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY seed_activity_id
),
median_stamina AS (
    SELECT seed_activity_id, AVG(cohort_stamina_drop) AS cohort_median_stamina_drop
    FROM (
        SELECT
            seed_activity_id,
            cohort_stamina_drop,
            ROW_NUMBER() OVER (PARTITION BY seed_activity_id ORDER BY cohort_stamina_drop) AS rn,
            COUNT(*) OVER (PARTITION BY seed_activity_id) AS cnt
        FROM cohort_member
        WHERE cohort_stamina_drop IS NOT NULL
    )
    WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    GROUP BY seed_activity_id
)
SELECT
    seed.activity_id,
    seed.comparison_definition_id,
    seed.comparison_name,
    seed.workout_family,
    seed.structure_type,
    seed.primary_training_purpose,
    seed.analysis_scope,
    seed.tolerance_basis,
    seed.reference_distance_m,
    seed.reference_duration_s,
    seed.distance_tolerance_pct,
    seed.duration_tolerance_pct,
    seed.include_current_activity_in_baseline,
    seed.minimum_comparison_samples,
    seed.minimum_trend_samples,
    seed.seed_is_cohort_eligible,
    seed.seed_exclusion_reason,
    stats.eligible_cohort_sample_count,
    stats.baseline_sample_count,
    stats.baseline_valid_pace_sample_count,
    stats.baseline_valid_hr_sample_count,
    stats.baseline_valid_power_sample_count,
    stats.baseline_valid_stamina_sample_count,
    stats.baseline_valid_load_sample_count,
    stats.valid_pace_sample_count,
    stats.valid_hr_sample_count,
    stats.valid_power_sample_count,
    stats.valid_stamina_sample_count,
    stats.valid_load_sample_count,
    median_pace.cohort_median_pace_s_per_km,
    median_hr.cohort_median_heart_rate_bpm,
    median_power.cohort_median_power_w,
    median_stamina.cohort_median_stamina_drop,
    CASE
        WHEN stats.baseline_valid_pace_sample_count >= 10 THEN 'long_term_distribution'
        WHEN stats.baseline_valid_pace_sample_count >= seed.minimum_trend_samples THEN 'recent_trend'
        WHEN stats.baseline_valid_pace_sample_count >= seed.minimum_comparison_samples THEN 'current_observation'
        ELSE 'data_only'
    END AS pace_language_level,
    CASE
        WHEN stats.baseline_valid_hr_sample_count >= 10 THEN 'long_term_distribution'
        WHEN stats.baseline_valid_hr_sample_count >= seed.minimum_trend_samples THEN 'recent_trend'
        WHEN stats.baseline_valid_hr_sample_count >= seed.minimum_comparison_samples THEN 'current_observation'
        ELSE 'data_only'
    END AS heart_rate_language_level,
    CASE
        WHEN stats.baseline_valid_power_sample_count >= 10 THEN 'long_term_distribution'
        WHEN stats.baseline_valid_power_sample_count >= seed.minimum_trend_samples THEN 'recent_trend'
        WHEN stats.baseline_valid_power_sample_count >= seed.minimum_comparison_samples THEN 'current_observation'
        ELSE 'data_only'
    END AS power_language_level,
    CASE
        WHEN stats.baseline_valid_stamina_sample_count >= 10 THEN 'long_term_distribution'
        WHEN stats.baseline_valid_stamina_sample_count >= seed.minimum_trend_samples THEN 'recent_trend'
        WHEN stats.baseline_valid_stamina_sample_count >= seed.minimum_comparison_samples THEN 'current_observation'
        ELSE 'data_only'
    END AS stamina_language_level,
    CASE
        WHEN seed.seed_is_cohort_eligible = 0 THEN 'excluded'
        WHEN stats.baseline_sample_count >= seed.minimum_comparison_samples THEN 'valid'
        WHEN stats.baseline_sample_count >= 1 THEN 'partial'
        ELSE 'insufficient'
    END AS comparison_validity_status,
    CASE
        WHEN seed.seed_is_cohort_eligible = 0 THEN seed.seed_exclusion_reason
        WHEN stats.baseline_sample_count >= seed.minimum_comparison_samples THEN NULL
        ELSE 'cohort too small'
    END AS comparison_validity_notes,
    CASE
        WHEN seed.temperature_c IS NULL THEN 0
        WHEN EXISTS (
            SELECT 1
            FROM cohort_member cm
            WHERE cm.seed_activity_id = seed.activity_id
              AND cm.cohort_temperature_c IS NOT NULL
              AND ABS(cm.cohort_temperature_c - seed.temperature_c) >= 3
        ) THEN 1
        ELSE 0
    END AS condition_note_required,
    CASE
        WHEN seed.average_pace_s_per_km IS NULL OR stats.baseline_valid_pace_sample_count = 0 THEN NULL
        ELSE ROUND(
            100.0 * (
                SELECT COUNT(*)
                FROM cohort_member cm
                WHERE cm.seed_activity_id = seed.activity_id
                  AND cm.cohort_average_pace_s_per_km IS NOT NULL
                  AND cm.cohort_average_pace_s_per_km >= seed.average_pace_s_per_km
            ) / stats.baseline_valid_pace_sample_count,
            1
        )
    END AS pace_baseline_percentile,
    CASE
        WHEN seed.average_heart_rate_bpm IS NULL OR stats.baseline_valid_hr_sample_count = 0 THEN NULL
        ELSE ROUND(
            100.0 * (
                SELECT COUNT(*)
                FROM cohort_member cm
                WHERE cm.seed_activity_id = seed.activity_id
                  AND cm.cohort_average_heart_rate_bpm IS NOT NULL
                  AND cm.cohort_average_heart_rate_bpm <= seed.average_heart_rate_bpm
            ) / stats.baseline_valid_hr_sample_count,
            1
        )
    END AS heart_rate_baseline_percentile,
    CASE
        WHEN seed.average_power_w IS NULL
          OR stats.baseline_valid_power_sample_count = 0
          OR NOT (
                (seed.average_power_origin = 'official_activity' AND seed.average_power_confidence = 'measured')
                OR (seed.average_power_origin = 'governed_derived' AND seed.average_power_confidence = 'derived')
             )
        THEN NULL
        ELSE ROUND(
            100.0 * (
                SELECT COUNT(*)
                FROM cohort_member cm
                WHERE cm.seed_activity_id = seed.activity_id
                  AND cm.cohort_average_power_w IS NOT NULL
                  AND (
                        (cm.cohort_average_power_origin = 'official_activity' AND cm.cohort_average_power_confidence = 'measured')
                        OR (cm.cohort_average_power_origin = 'governed_derived' AND cm.cohort_average_power_confidence = 'derived')
                      )
                  AND cm.cohort_power_source_system = seed.power_source_system
                  AND cm.cohort_power_measurement_method = seed.power_measurement_method
                  AND cm.cohort_average_power_w <= seed.average_power_w
            ) / stats.baseline_valid_power_sample_count,
            1
        )
    END AS power_baseline_percentile,
    CASE
        WHEN seed.stamina_drop IS NULL OR stats.baseline_valid_stamina_sample_count = 0 THEN NULL
        ELSE ROUND(
            100.0 * (
                SELECT COUNT(*)
                FROM cohort_member cm
                WHERE cm.seed_activity_id = seed.activity_id
                  AND cm.cohort_stamina_drop IS NOT NULL
                  AND cm.cohort_stamina_drop <= seed.stamina_drop
            ) / stats.baseline_valid_stamina_sample_count,
            1
        )
    END AS stamina_drop_baseline_percentile,
    CASE
        WHEN seed.training_load IS NULL OR stats.baseline_valid_load_sample_count = 0 THEN NULL
        ELSE ROUND(
            100.0 * (
                SELECT COUNT(*)
                FROM cohort_member cm
                WHERE cm.seed_activity_id = seed.activity_id
                  AND cm.cohort_training_load IS NOT NULL
                  AND cm.cohort_training_load <= seed.training_load
            ) / stats.baseline_valid_load_sample_count,
            1
        )
    END AS training_load_baseline_percentile,
    CASE
        WHEN seed.seed_is_cohort_eligible = 0 THEN 'excluded'
        WHEN stats.baseline_sample_count < seed.minimum_comparison_samples THEN 'insufficient'
        ELSE 'valid'
    END AS comparison_validity,
    CASE
        WHEN seed.average_pace_s_per_km IS NULL THEN 'unavailable'
        ELSE 'valid'
    END AS pace_validity,
    CASE
        WHEN seed.average_heart_rate_bpm IS NULL THEN 'unavailable'
        ELSE 'valid'
    END AS heart_rate_validity,
    CASE
        WHEN seed.average_power_w IS NULL THEN 'unavailable'
        WHEN NOT (
            (seed.average_power_origin = 'official_activity' AND seed.average_power_confidence = 'measured')
            OR (seed.average_power_origin = 'governed_derived' AND seed.average_power_confidence = 'derived')
        ) THEN 'reference_only'
        WHEN stats.baseline_valid_power_sample_count = 0 THEN 'reference_only'
        ELSE 'valid'
    END AS power_validity,
    CASE
        WHEN seed.stamina_drop IS NULL THEN 'unavailable'
        ELSE 'valid'
    END AS stamina_validity
FROM definition_seed seed
LEFT JOIN cohort_stats stats
    ON stats.activity_id = seed.activity_id
LEFT JOIN median_pace
    ON median_pace.seed_activity_id = seed.activity_id
LEFT JOIN median_hr
    ON median_hr.seed_activity_id = seed.activity_id
LEFT JOIN median_power
    ON median_power.seed_activity_id = seed.activity_id
LEFT JOIN median_stamina
    ON median_stamina.seed_activity_id = seed.activity_id;
