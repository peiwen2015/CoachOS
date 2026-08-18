-- CoachOS Chart Semantic View SQL Draft v0.1
-- Purpose: draft chart-ready semantic views on top of the governed SQLite schema
-- Status: draft only; this file is intended to surface schema gaps and calculation dependencies

DROP VIEW IF EXISTS weekly_training_load_view;
DROP VIEW IF EXISTS planned_workout_segment_view;
DROP VIEW IF EXISTS workout_execution_segment_view;
DROP VIEW IF EXISTS activity_decoupling_view;
DROP VIEW IF EXISTS weekly_intensity_distribution_view;

CREATE VIEW weekly_training_load_view AS
WITH RECURSIVE week_offsets(week_offset) AS (
    VALUES (0)
    UNION ALL
    SELECT week_offset + 1
    FROM week_offsets
    WHERE week_offset < 11
),
anchor AS (
    SELECT DATE(MAX(activity_start_time)) AS latest_date
    FROM activity
),
weeks AS (
    SELECT
        week_offsets.week_offset,
        DATE(anchor.latest_date, printf('-%d day', week_offsets.week_offset * 7 + 6)) AS week_start_date,
        DATE(anchor.latest_date, printf('-%d day', week_offsets.week_offset * 7)) AS week_end_date
    FROM week_offsets
    CROSS JOIN anchor
),
weekly_rollup AS (
    SELECT
        weeks.week_offset,
        weeks.week_start_date,
        weeks.week_end_date,
        STRFTIME('%Y-W%W', weeks.week_start_date) AS week_key,
        COUNT(activity_review_view.activity_id) AS activities,
        COALESCE(ROUND(SUM(activity_review_view.distance_km), 2), 0) AS weekly_distance_km,
        COALESCE(SUM(activity_review_view.duration_sec), 0) AS weekly_duration_sec,
        COALESCE(ROUND(SUM(activity_review_view.training_load), 1), 0) AS weekly_training_load,
        CASE
            WHEN SUM(activity_review_view.distance_km) > 0
            THEN CAST(ROUND(SUM(activity_review_view.duration_sec) * 1.0 / SUM(activity_review_view.distance_km)) AS INTEGER)
            ELSE NULL
        END AS weekly_avg_pace_sec_per_km,
        CAST(ROUND(AVG(activity_review_view.avg_hr)) AS INTEGER) AS weekly_avg_hr,
        ROUND(
            COALESCE(SUM(activity_review_view.training_load), 0) * 1.0
            / NULLIF(COALESCE(SUM(activity_review_view.distance_km), 0), 0),
            1
        ) AS weekly_load_per_km,
        ROUND(
            (
                SUM(CASE WHEN activity_review_view.training_load IS NOT NULL THEN 1 ELSE 0 END) +
                SUM(CASE WHEN activity_review_view.avg_hr IS NOT NULL THEN 1 ELSE 0 END) +
                SUM(CASE WHEN activity_review_view.avg_pace_sec_per_km IS NOT NULL THEN 1 ELSE 0 END)
            ) * 100.0 / NULLIF(COUNT(activity_review_view.activity_id) * 3, 0),
            1
        ) AS data_completeness_score
    FROM weeks
    LEFT JOIN activity_review_view
        ON activity_review_view.activity_date BETWEEN weeks.week_start_date AND weeks.week_end_date
    GROUP BY
        weeks.week_offset,
        weeks.week_start_date,
        weeks.week_end_date
),
trend AS (
    SELECT
        weekly_rollup.*,
        LAG(weekly_training_load) OVER (ORDER BY week_start_date) AS previous_week_training_load,
        ROUND(
            AVG(weekly_training_load) OVER (
                ORDER BY week_start_date
                ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
            ),
            1
        ) AS chronic_load_4w
    FROM weekly_rollup
)
SELECT
    week_offset,
    week_key,
    week_start_date,
    week_end_date,
    activities,
    weekly_distance_km,
    weekly_duration_sec,
    weekly_avg_pace_sec_per_km,
    weekly_avg_hr,
    weekly_training_load,
    previous_week_training_load,
    CASE
        WHEN previous_week_training_load > 0
        THEN ROUND(((weekly_training_load - previous_week_training_load) / previous_week_training_load) * 100, 1)
        ELSE NULL
    END AS weekly_load_delta_pct,
    chronic_load_4w AS chronic_load,
    weekly_training_load AS acute_load,
    CASE
        WHEN chronic_load_4w > 0
        THEN ROUND(weekly_training_load * 1.0 / chronic_load_4w, 2)
        ELSE NULL
    END AS acute_chronic_ratio,
    weekly_load_per_km,
    data_completeness_score,
    NULL AS is_recovery_week,
    NULL AS is_race_week,
    NULL AS is_taper_week
FROM trend
ORDER BY week_start_date;

CREATE VIEW planned_workout_segment_view AS
SELECT
    activity_workout_step.activity_id,
    activity_workout_step.activity_id AS workout_id,
    activity_workout_structure.workout_name,
    activity_workout_structure.workout_description,
    activity_workout_structure.has_workout_structure,
    activity_workout_step.id AS segment_id,
    activity_workout_step.step_index AS segment_order,
    COALESCE(activity_workout_step.intensity, activity_workout_step.duration_type, 'unspecified') AS segment_type,
    activity_workout_step.target_type AS target_metric,
    CASE
        WHEN LOWER(COALESCE(activity_workout_step.target_type, '')) LIKE '%pace%' THEN 'sec_per_km'
        WHEN LOWER(COALESCE(activity_workout_step.target_type, '')) LIKE '%heart%' THEN 'bpm'
        WHEN LOWER(COALESCE(activity_workout_step.target_type, '')) LIKE '%hr%' THEN 'bpm'
        WHEN LOWER(COALESCE(activity_workout_step.target_type, '')) LIKE '%power%' THEN 'w'
        WHEN activity_workout_step.duration_time_sec IS NOT NULL THEN 'sec'
        WHEN activity_workout_step.duration_distance_m IS NOT NULL THEN 'm'
        ELSE NULL
    END AS target_unit,
    activity_workout_step.target_value_low AS target_min,
    activity_workout_step.target_value_high AS target_max,
    activity_workout_step.duration_time_sec AS planned_duration_s,
    activity_workout_step.duration_distance_m AS planned_distance_m,
    activity_workout_step.repeat_steps AS repetition_group_size,
    activity_workout_step.secondary_target_value,
    activity_workout_step.custom_target_value_low,
    activity_workout_step.custom_target_value_high
FROM activity_workout_step
LEFT JOIN activity_workout_structure
    ON activity_workout_step.activity_id = activity_workout_structure.activity_id;

CREATE VIEW workout_execution_segment_view AS
WITH planned AS (
    SELECT *
    FROM planned_workout_segment_view
),
execution AS (
    SELECT
        activity_workout_split.activity_id,
        activity_workout_split.split_index AS segment_order,
        activity_workout_split.split_type,
        activity_workout_split.num_splits,
        activity_workout_split.total_distance_m AS actual_distance_m,
        activity_workout_split.total_timer_time_sec AS actual_duration_s,
        CASE
            WHEN activity_workout_split.total_distance_m > 0 AND activity_workout_split.total_timer_time_sec > 0
            THEN CAST(ROUND(activity_workout_split.total_timer_time_sec * 1000.0 / activity_workout_split.total_distance_m) AS INTEGER)
            ELSE NULL
        END AS actual_pace_sec_per_km,
        activity_workout_split.avg_speed_mps AS actual_speed_mps
    FROM activity_workout_split
),
activity_summary AS (
    SELECT
        activity_id,
        activity_start_time,
        activity_date,
        avg_hr AS activity_avg_hr,
        avg_power_w AS activity_avg_power_w,
        training_load
    FROM activity_review_view
)
SELECT
    planned.activity_id,
    planned.workout_id,
    planned.workout_name,
    planned.workout_description,
    planned.has_workout_structure,
    planned.segment_id,
    planned.segment_order,
    planned.segment_type,
    planned.target_metric,
    planned.target_unit,
    planned.target_min,
    planned.target_max,
    planned.planned_duration_s,
    planned.planned_distance_m,
    execution.actual_duration_s,
    execution.actual_distance_m,
    execution.actual_pace_sec_per_km,
    activity_summary.activity_avg_hr AS average_heart_rate_bpm,
    activity_summary.activity_avg_power_w AS average_power_w,
    activity_summary.training_load,
    CASE
        WHEN planned.planned_duration_s IS NOT NULL
             AND execution.actual_duration_s IS NOT NULL
             AND planned.planned_duration_s > 0
        THEN ROUND((1.0 - ABS(execution.actual_duration_s - planned.planned_duration_s) / planned.planned_duration_s) * 100, 1)
        WHEN planned.planned_distance_m IS NOT NULL
             AND execution.actual_distance_m IS NOT NULL
             AND planned.planned_distance_m > 0
        THEN ROUND((1.0 - ABS(execution.actual_distance_m - planned.planned_distance_m) / planned.planned_distance_m) * 100, 1)
        ELSE NULL
    END AS target_compliance_pct,
    CASE
        WHEN planned.planned_duration_s IS NOT NULL
             AND execution.actual_duration_s IS NOT NULL
             AND planned.planned_duration_s > 0
        THEN ROUND(((execution.actual_duration_s - planned.planned_duration_s) / planned.planned_duration_s) * 100, 1)
        WHEN planned.planned_distance_m IS NOT NULL
             AND execution.actual_distance_m IS NOT NULL
             AND planned.planned_distance_m > 0
        THEN ROUND(((execution.actual_distance_m - planned.planned_distance_m) / planned.planned_distance_m) * 100, 1)
        ELSE NULL
    END AS deviation_from_target_pct,
    CASE
        WHEN execution.actual_duration_s IS NULL AND execution.actual_distance_m IS NULL THEN 'missing_execution'
        WHEN execution.actual_duration_s IS NULL OR execution.actual_distance_m IS NULL THEN 'partial_execution'
        WHEN planned.planned_duration_s IS NOT NULL THEN 'duration_aligned'
        WHEN planned.planned_distance_m IS NOT NULL THEN 'distance_aligned'
        ELSE 'best_effort'
    END AS segment_status,
    'best_effort_step_index' AS alignment_method
FROM planned
LEFT JOIN execution
    ON execution.activity_id = planned.activity_id
   AND execution.segment_order = planned.segment_order
LEFT JOIN activity_summary
    ON activity_summary.activity_id = planned.activity_id;

CREATE VIEW activity_decoupling_view AS
WITH split_base AS (
    SELECT
        kilometer_split_view.activity_id,
        activity_review_view.activity_start_time,
        activity_review_view.activity_date,
        activity_review_view.activity_type,
        activity_review_view.distance_km,
        activity_review_view.duration_sec,
        activity_review_view.avg_pace_sec_per_km AS activity_avg_pace_sec_per_km,
        activity_review_view.avg_hr AS activity_avg_hr,
        activity_review_view.avg_power_w AS activity_avg_power_w,
        activity_review_view.temperature_c,
        kilometer_split_view.split_index,
        kilometer_split_view.split_distance_m,
        kilometer_split_view.elapsed_time_sec,
        kilometer_split_view.elapsed_pace_sec_per_km,
        kilometer_split_view.avg_hr AS split_avg_hr,
        kilometer_split_view.avg_power_w AS split_avg_power_w,
        COUNT(*) OVER (PARTITION BY kilometer_split_view.activity_id) AS split_count
    FROM kilometer_split_view
    JOIN activity_review_view
        ON activity_review_view.activity_id = kilometer_split_view.activity_id
),
half_labeled AS (
    SELECT
        *,
        CASE
            WHEN split_index <= CAST(((split_count + 1) / 2.0) AS INTEGER)
            THEN 'first_half'
            ELSE 'second_half'
        END AS half_label
    FROM split_base
),
half_rollup AS (
    SELECT
        activity_id,
        half_label,
        COUNT(*) AS half_split_count,
        SUM(split_distance_m) AS half_distance_m,
        SUM(elapsed_time_sec) AS half_time_sec,
        CASE
            WHEN SUM(split_distance_m) > 0
            THEN CAST(ROUND(SUM(elapsed_time_sec) * 1000.0 / SUM(split_distance_m)) AS INTEGER)
            ELSE NULL
        END AS half_avg_pace_sec_per_km,
        ROUND(AVG(split_avg_hr), 1) AS half_avg_hr,
        ROUND(AVG(split_avg_power_w), 1) AS half_avg_power_w
    FROM half_labeled
    GROUP BY
        activity_id,
        half_label
),
pivoted AS (
    SELECT
        activity_id,
        MAX(CASE WHEN half_label = 'first_half' THEN half_split_count END) AS first_half_split_count,
        MAX(CASE WHEN half_label = 'first_half' THEN half_distance_m END) AS first_half_distance_m,
        MAX(CASE WHEN half_label = 'first_half' THEN half_time_sec END) AS first_half_time_sec,
        MAX(CASE WHEN half_label = 'first_half' THEN half_avg_pace_sec_per_km END) AS first_half_avg_pace_sec_per_km,
        MAX(CASE WHEN half_label = 'first_half' THEN half_avg_hr END) AS first_half_avg_hr,
        MAX(CASE WHEN half_label = 'first_half' THEN half_avg_power_w END) AS first_half_avg_power_w,
        MAX(CASE WHEN half_label = 'second_half' THEN half_split_count END) AS second_half_split_count,
        MAX(CASE WHEN half_label = 'second_half' THEN half_distance_m END) AS second_half_distance_m,
        MAX(CASE WHEN half_label = 'second_half' THEN half_time_sec END) AS second_half_time_sec,
        MAX(CASE WHEN half_label = 'second_half' THEN half_avg_pace_sec_per_km END) AS second_half_avg_pace_sec_per_km,
        MAX(CASE WHEN half_label = 'second_half' THEN half_avg_hr END) AS second_half_avg_hr,
        MAX(CASE WHEN half_label = 'second_half' THEN half_avg_power_w END) AS second_half_avg_power_w
    FROM half_rollup
    GROUP BY activity_id
)
SELECT
    activity_review_view.activity_id,
    activity_review_view.activity_start_time,
    activity_review_view.activity_date,
    activity_review_view.activity_type,
    activity_review_view.distance_km,
    activity_review_view.duration_sec,
    activity_review_view.avg_pace_sec_per_km,
    activity_review_view.avg_hr AS activity_avg_hr,
    activity_review_view.avg_power_w AS activity_avg_power_w,
    activity_review_view.temperature_c,
    activity_review_view.wind_speed_mps,
    activity_review_view.wind_direction_deg,
    activity_review_view.weather_description,
    activity_review_view.training_load,
    pivoted.first_half_split_count,
    pivoted.first_half_distance_m,
    pivoted.first_half_time_sec,
    pivoted.first_half_avg_pace_sec_per_km,
    pivoted.first_half_avg_hr,
    pivoted.first_half_avg_power_w,
    pivoted.second_half_split_count,
    pivoted.second_half_distance_m,
    pivoted.second_half_time_sec,
    pivoted.second_half_avg_pace_sec_per_km,
    pivoted.second_half_avg_hr,
    pivoted.second_half_avg_power_w,
    CASE
        WHEN pivoted.first_half_avg_pace_sec_per_km IS NOT NULL
             AND pivoted.second_half_avg_pace_sec_per_km IS NOT NULL
             AND pivoted.first_half_avg_pace_sec_per_km > 0
        THEN ROUND(
            ((pivoted.second_half_avg_pace_sec_per_km - pivoted.first_half_avg_pace_sec_per_km) * 100.0)
            / pivoted.first_half_avg_pace_sec_per_km,
            1
        )
        ELSE NULL
    END AS pace_change_pct,
    CASE
        WHEN pivoted.first_half_avg_hr IS NOT NULL
             AND pivoted.second_half_avg_hr IS NOT NULL
             AND pivoted.first_half_avg_hr > 0
        THEN ROUND(
            ((pivoted.second_half_avg_hr - pivoted.first_half_avg_hr) * 100.0)
            / pivoted.first_half_avg_hr,
            1
        )
        ELSE NULL
    END AS heart_rate_change_pct,
    CASE
        WHEN pivoted.first_half_avg_pace_sec_per_km IS NOT NULL
             AND pivoted.second_half_avg_pace_sec_per_km IS NOT NULL
             AND pivoted.first_half_avg_hr IS NOT NULL
             AND pivoted.second_half_avg_hr IS NOT NULL
             AND pivoted.first_half_avg_pace_sec_per_km > 0
             AND pivoted.first_half_avg_hr > 0
        THEN ROUND(
            (
                ((pivoted.second_half_avg_pace_sec_per_km - pivoted.first_half_avg_pace_sec_per_km) * 100.0)
                / pivoted.first_half_avg_pace_sec_per_km
            ) +
            (
                ((pivoted.second_half_avg_hr - pivoted.first_half_avg_hr) * 100.0)
                / pivoted.first_half_avg_hr
            ),
            1
        )
        ELSE NULL
    END AS aerobic_decoupling_pct,
    CASE
        WHEN pivoted.first_half_avg_pace_sec_per_km IS NULL OR pivoted.second_half_avg_pace_sec_per_km IS NULL THEN 'insufficient'
        WHEN pivoted.first_half_split_count < 2 OR pivoted.second_half_split_count < 2 THEN 'partial'
        ELSE 'sufficient'
    END AS sample_quality_status
FROM activity_review_view
LEFT JOIN pivoted
    ON activity_review_view.activity_id = pivoted.activity_id;

CREATE VIEW weekly_intensity_distribution_view AS
WITH current_week AS (
    SELECT *
    FROM current_week_summary_view
),
current_week_rows AS (
    SELECT
        'current_week' AS period_type,
        current_week.start_date AS period_start_date,
        current_week.end_date AS period_end_date,
        activity_review_view.intensity_category,
        COUNT(*) AS activity_count,
        ROUND(SUM(activity_review_view.distance_km), 2) AS total_km,
        SUM(activity_review_view.duration_sec) AS total_time_sec,
        ROUND(SUM(activity_review_view.training_load), 1) AS total_training_load
    FROM current_week
    JOIN activity_review_view
        ON activity_review_view.activity_date BETWEEN current_week.start_date AND current_week.end_date
    GROUP BY
        current_week.start_date,
        current_week.end_date,
        activity_review_view.intensity_category
),
rolling_4w_rows AS (
    SELECT
        'rolling_4w' AS period_type,
        MIN(weekly_summary_view.start_date) AS period_start_date,
        MAX(weekly_summary_view.end_date) AS period_end_date,
        activity_review_view.intensity_category,
        COUNT(*) AS activity_count,
        ROUND(SUM(activity_review_view.distance_km), 2) AS total_km,
        SUM(activity_review_view.duration_sec) AS total_time_sec,
        ROUND(SUM(activity_review_view.training_load), 1) AS total_training_load
    FROM weekly_summary_view
    JOIN activity_review_view
        ON activity_review_view.activity_date BETWEEN weekly_summary_view.start_date AND weekly_summary_view.end_date
    WHERE weekly_summary_view.week_offset BETWEEN 0 AND 3
    GROUP BY
        activity_review_view.intensity_category
)
SELECT
    period_type,
    period_start_date,
    period_end_date,
    intensity_category,
    activity_count,
    total_km,
    total_time_sec,
    total_training_load,
    ROUND(activity_count * 100.0 / NULLIF(SUM(activity_count) OVER (PARTITION BY period_type), 0), 1) AS activity_share_pct,
    ROUND(total_time_sec * 100.0 / NULLIF(SUM(total_time_sec) OVER (PARTITION BY period_type), 0), 1) AS time_share_pct,
    ROUND(total_training_load * 100.0 / NULLIF(SUM(total_training_load) OVER (PARTITION BY period_type), 0), 1) AS load_share_pct
FROM (
    SELECT * FROM current_week_rows
    UNION ALL
    SELECT * FROM rolling_4w_rows
)
ORDER BY
    period_type,
    CASE COALESCE(intensity_category, 'Unassigned')
        WHEN 'Recovery' THEN 1
        WHEN 'Easy' THEN 2
        WHEN 'Moderate' THEN 3
        WHEN 'Threshold' THEN 4
        WHEN 'Interval' THEN 5
        WHEN 'Unassigned' THEN 6
        ELSE 7
    END;
