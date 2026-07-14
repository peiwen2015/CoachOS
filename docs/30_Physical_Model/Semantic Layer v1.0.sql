-- Semantic Layer v1.0
-- Scope: Product-facing review and intelligence views
-- Source: Core Canonical Data Layer v1.0 + SQLite Schema v1.0

DROP VIEW IF EXISTS journey_turning_point_view;
DROP VIEW IF EXISTS journey_month_story_view;
DROP VIEW IF EXISTS recent_activity_view;
DROP VIEW IF EXISTS recent_training_intent_view;
DROP VIEW IF EXISTS training_assignment_quality_view;
DROP VIEW IF EXISTS current_month_assignment_quality_view;
DROP VIEW IF EXISTS training_balance_view;
DROP VIEW IF EXISTS training_distribution_view;
DROP VIEW IF EXISTS current_month_key_sessions_view;
DROP VIEW IF EXISTS current_month_progress_view;
DROP VIEW IF EXISTS current_month_training_distribution_view;
DROP VIEW IF EXISTS current_month_intelligence_view;
DROP VIEW IF EXISTS current_month_summary_view;
DROP VIEW IF EXISTS monthly_summary_view;
DROP VIEW IF EXISTS shoe_workout_comparison_view;
DROP VIEW IF EXISTS shoe_intelligence_view;
DROP VIEW IF EXISTS shoe_comparison_view;
DROP VIEW IF EXISTS current_week_intelligence_view;
DROP VIEW IF EXISTS current_week_summary_view;
DROP VIEW IF EXISTS weekly_summary_view;
DROP VIEW IF EXISTS platform_summary_view;
DROP VIEW IF EXISTS activity_review_view;

CREATE VIEW activity_review_view AS
WITH primary_purpose AS (
    SELECT
        activity_id,
        training_purpose_id,
        training_purpose_code,
        training_purpose_name_en,
        training_purpose_name_zh,
        purpose_category
    FROM activity_training_purpose_view
    WHERE purpose_role = 'PRIMARY'
),
secondary_purpose AS (
    SELECT
        activity_id,
        GROUP_CONCAT(training_purpose_code, ', ') AS secondary_training_purpose_codes,
        GROUP_CONCAT(training_purpose_name_en, ', ') AS secondary_training_purpose_names_en,
        GROUP_CONCAT(training_purpose_name_zh, ', ') AS secondary_training_purpose_names_zh
    FROM activity_training_purpose_view
    WHERE purpose_role = 'SECONDARY'
    GROUP BY activity_id
)
SELECT
    activity_view.id AS activity_id,
    activity_view.activity_start_time,
    DATE(activity_view.activity_start_time) AS activity_date,
    activity_view.activity_type,
    activity_view.activity_name,
    activity_view.distance_km,
    activity_view.duration_sec,
    activity_view.avg_pace_sec_per_km,
    activity_view.avg_hr,
    activity_view.max_hr,
    activity_view.training_load,
    activity_view.training_effect_aerobic,
    activity_view.training_effect_anaerobic,
    activity_view.recovery_time_hr,
    activity_view.stamina_start_pct,
    activity_view.stamina_end_pct,
    activity_view.temperature_c,
    activity_view.humidity_pct,
    activity_view.wind_speed_mps,
    activity_view.wind_direction_deg,
    activity_view.weather_description,
    activity_view.avg_cadence_spm,
    activity_view.avg_stride_length_mm,
    activity_view.avg_gct_ms,
    activity_view.avg_vertical_oscillation_mm,
    activity_view.avg_vertical_ratio_pct,
    activity_view.garmin_feeling,
    activity_view.garmin_perceived_effort,
    activity_view.nutrition,
    activity_view.notes,
    activity_view.start_latitude,
    activity_view.start_longitude,
    activity_view.end_latitude,
    activity_view.end_longitude,
    activity_view.shoe_id,
    activity_view.shoe_code,
    activity_view.shoe_brand,
    activity_view.shoe_model,
    activity_view.shoe_nickname,
    TRIM(
        COALESCE(activity_view.shoe_brand || ' ', '') ||
        COALESCE(activity_view.shoe_model, '') ||
        CASE
            WHEN activity_view.shoe_nickname IS NULL OR activity_view.shoe_nickname = ''
            THEN ''
            ELSE ' ' || activity_view.shoe_nickname
        END
    ) AS shoe_display_name,
    activity_view.workout_type_id,
    activity_view.workout_type_code,
    activity_view.workout_type_name_en,
    activity_view.workout_type_name_zh,
    activity_view.intensity_category,
    activity_view.is_quality_session,
    activity_view.is_long_run,
    activity_view.is_recovery_focused,
    primary_purpose.training_purpose_id AS primary_training_purpose_id,
    primary_purpose.training_purpose_code AS primary_training_purpose_code,
    primary_purpose.training_purpose_name_en AS primary_training_purpose_name_en,
    primary_purpose.training_purpose_name_zh AS primary_training_purpose_name_zh,
    primary_purpose.purpose_category AS primary_purpose_category,
    secondary_purpose.secondary_training_purpose_codes,
    secondary_purpose.secondary_training_purpose_names_en,
    secondary_purpose.secondary_training_purpose_names_zh
FROM activity_view
LEFT JOIN primary_purpose
    ON activity_view.id = primary_purpose.activity_id
LEFT JOIN secondary_purpose
    ON activity_view.id = secondary_purpose.activity_id;

CREATE VIEW platform_summary_view AS
SELECT
    COUNT(*) AS activities,
    ROUND(SUM(distance_km), 2) AS total_km,
    SUM(duration_sec) AS total_time_sec,
    CAST(ROUND(SUM(duration_sec) * 1.0 / SUM(distance_km)) AS INTEGER) AS avg_pace_sec_per_km,
    CAST(ROUND(AVG(avg_hr)) AS INTEGER) AS avg_hr,
    MAX(activity_start_time) AS latest_activity_start_time
FROM activity_review_view;

CREATE VIEW weekly_summary_view AS
WITH RECURSIVE week_offsets(week_offset) AS (
    VALUES (0)
    UNION ALL
    SELECT week_offset + 1
    FROM week_offsets
    WHERE week_offset < 4
),
anchor AS (
    SELECT DATE(MAX(activity_start_time)) AS latest_date
    FROM activity
),
weeks AS (
    SELECT
        week_offsets.week_offset,
        DATE(anchor.latest_date, printf('-%d day', week_offsets.week_offset * 7 + 6)) AS start_date,
        DATE(anchor.latest_date, printf('-%d day', week_offsets.week_offset * 7)) AS end_date
    FROM week_offsets
    CROSS JOIN anchor
)
SELECT
    weeks.week_offset,
    weeks.start_date,
    weeks.end_date,
    COUNT(activity_review_view.activity_id) AS activities,
    COALESCE(ROUND(SUM(activity_review_view.distance_km), 2), 0) AS total_km,
    COALESCE(SUM(activity_review_view.duration_sec), 0) AS total_time_sec,
    CASE
        WHEN SUM(activity_review_view.distance_km) > 0
        THEN CAST(ROUND(SUM(activity_review_view.duration_sec) * 1.0 / SUM(activity_review_view.distance_km)) AS INTEGER)
        ELSE NULL
    END AS avg_pace_sec_per_km,
    CAST(ROUND(AVG(activity_review_view.avg_hr)) AS INTEGER) AS avg_hr,
    COALESCE(SUM(activity_review_view.training_load), 0) AS training_load
FROM weeks
LEFT JOIN activity_review_view
    ON activity_review_view.activity_date BETWEEN weeks.start_date AND weeks.end_date
GROUP BY
    weeks.week_offset,
    weeks.start_date,
    weeks.end_date
ORDER BY weeks.week_offset;

CREATE VIEW current_week_summary_view AS
SELECT *
FROM weekly_summary_view
WHERE week_offset = 0;

CREATE VIEW current_week_intelligence_view AS
WITH current_week AS (
    SELECT *
    FROM weekly_summary_view
    WHERE week_offset = 0
),
baseline AS (
    SELECT
        AVG(total_km) AS baseline_km,
        AVG(training_load) AS baseline_load,
        AVG(
            CASE
                WHEN total_km > 0
                THEN training_load * 1.0 / total_km
                ELSE NULL
            END
        ) AS baseline_load_per_km
    FROM weekly_summary_view
    WHERE week_offset BETWEEN 1 AND 4
)
SELECT
    current_week.start_date,
    current_week.end_date,
    current_week.activities,
    current_week.total_km,
    current_week.total_time_sec,
    current_week.avg_pace_sec_per_km,
    current_week.avg_hr,
    current_week.training_load,
    CASE
        WHEN current_week.total_km > 0
        THEN ROUND(current_week.training_load * 1.0 / current_week.total_km, 1)
        ELSE NULL
    END AS current_load_per_km,
    ROUND(baseline.baseline_km, 2) AS baseline_km,
    ROUND(baseline.baseline_load, 1) AS baseline_load,
    ROUND(baseline.baseline_load_per_km, 1) AS baseline_load_per_km,
    CASE
        WHEN baseline.baseline_km > 0
        THEN ROUND(((current_week.total_km - baseline.baseline_km) / baseline.baseline_km) * 100, 1)
        ELSE NULL
    END AS km_delta_pct,
    CASE
        WHEN baseline.baseline_load > 0
        THEN ROUND(((current_week.training_load - baseline.baseline_load) / baseline.baseline_load) * 100, 1)
        ELSE NULL
    END AS load_delta_pct,
    CASE
        WHEN baseline.baseline_load_per_km > 0 AND current_week.total_km > 0
        THEN ROUND((((current_week.training_load * 1.0 / current_week.total_km) - baseline.baseline_load_per_km) / baseline.baseline_load_per_km) * 100, 1)
        ELSE NULL
    END AS load_per_km_delta_pct,
    CASE
        WHEN baseline.baseline_load IS NULL OR baseline.baseline_load = 0 THEN 'Building baseline'
        WHEN ((current_week.training_load - baseline.baseline_load) / baseline.baseline_load) * 100 > 15 THEN 'Watch Load'
        WHEN ((current_week.training_load - baseline.baseline_load) / baseline.baseline_load) * 100 < -15 THEN 'Absorb'
        ELSE 'Balanced'
    END AS recovery_status
FROM current_week
CROSS JOIN baseline;

CREATE VIEW monthly_summary_view AS
SELECT
    DATE(activity_date, 'start of month') AS month_start,
    DATE(activity_date, 'start of month', '+1 month', '-1 day') AS month_end,
    STRFTIME('%Y-%m', activity_date) AS month_key,
    COUNT(activity_id) AS activities,
    COALESCE(ROUND(SUM(distance_km), 2), 0) AS total_km,
    COALESCE(SUM(duration_sec), 0) AS total_time_sec,
    CASE
        WHEN SUM(distance_km) > 0
        THEN CAST(ROUND(SUM(duration_sec) * 1.0 / SUM(distance_km)) AS INTEGER)
        ELSE NULL
    END AS avg_pace_sec_per_km,
    CAST(ROUND(AVG(avg_hr)) AS INTEGER) AS avg_hr,
    COALESCE(ROUND(SUM(training_load), 1), 0) AS training_load
FROM activity_review_view
GROUP BY
    DATE(activity_date, 'start of month'),
    DATE(activity_date, 'start of month', '+1 month', '-1 day'),
    STRFTIME('%Y-%m', activity_date)
ORDER BY month_start DESC;

CREATE VIEW current_month_summary_view AS
WITH latest_activity AS (
    SELECT DATE(MAX(activity_start_time)) AS latest_date
    FROM activity
)
SELECT
    monthly_summary_view.*,
    latest_activity.latest_date,
    CASE
        WHEN latest_activity.latest_date IS NOT NULL
             AND latest_activity.latest_date < monthly_summary_view.month_end
        THEN 1
        ELSE 0
    END AS is_partial_month
FROM monthly_summary_view
CROSS JOIN latest_activity
WHERE monthly_summary_view.month_start = DATE(latest_activity.latest_date, 'start of month');

CREATE VIEW current_month_intelligence_view AS
WITH ranked_months AS (
    SELECT
        monthly_summary_view.*,
        ROW_NUMBER() OVER (ORDER BY month_start DESC) AS month_rank
    FROM monthly_summary_view
),
current_month AS (
    SELECT *
    FROM current_month_summary_view
),
baseline AS (
    SELECT
        AVG(total_km) AS baseline_km,
        AVG(training_load) AS baseline_load,
        AVG(activities) AS baseline_activities,
        AVG(
            CASE
                WHEN total_km > 0
                THEN training_load * 1.0 / total_km
                ELSE NULL
            END
        ) AS baseline_load_per_km
    FROM ranked_months
    WHERE month_rank BETWEEN 2 AND 4
)
SELECT
    current_month.month_start,
    current_month.month_end,
    current_month.month_key,
    current_month.activities,
    current_month.total_km,
    current_month.total_time_sec,
    current_month.avg_pace_sec_per_km,
    current_month.avg_hr,
    current_month.training_load,
    current_month.is_partial_month,
    CASE
        WHEN current_month.total_km > 0
        THEN ROUND(current_month.training_load * 1.0 / current_month.total_km, 1)
        ELSE NULL
    END AS current_load_per_km,
    ROUND(baseline.baseline_km, 2) AS baseline_km,
    ROUND(baseline.baseline_load, 1) AS baseline_load,
    ROUND(baseline.baseline_activities, 1) AS baseline_activities,
    ROUND(baseline.baseline_load_per_km, 1) AS baseline_load_per_km,
    CASE
        WHEN baseline.baseline_km > 0
        THEN ROUND(((current_month.total_km - baseline.baseline_km) / baseline.baseline_km) * 100, 1)
        ELSE NULL
    END AS km_delta_pct,
    CASE
        WHEN baseline.baseline_load > 0
        THEN ROUND(((current_month.training_load - baseline.baseline_load) / baseline.baseline_load) * 100, 1)
        ELSE NULL
    END AS load_delta_pct,
    CASE
        WHEN baseline.baseline_activities > 0
        THEN ROUND(((current_month.activities - baseline.baseline_activities) / baseline.baseline_activities) * 100, 1)
        ELSE NULL
    END AS activities_delta_pct,
    CASE
        WHEN baseline.baseline_load_per_km > 0 AND current_month.total_km > 0
        THEN ROUND((((current_month.training_load * 1.0 / current_month.total_km) - baseline.baseline_load_per_km) / baseline.baseline_load_per_km) * 100, 1)
        ELSE NULL
    END AS load_per_km_delta_pct
FROM current_month
CROSS JOIN baseline;

CREATE VIEW current_month_training_distribution_view AS
WITH current_month AS (
    SELECT month_start, month_end
    FROM current_month_summary_view
)
SELECT
    COALESCE(activity_review_view.workout_type_code, 'unassigned') AS workout_type_code,
    COALESCE(activity_review_view.workout_type_name_en, 'Unassigned') AS workout_type_name_en,
    COALESCE(activity_review_view.primary_training_purpose_code, 'unassigned') AS primary_training_purpose_code,
    COALESCE(activity_review_view.primary_training_purpose_name_en, 'Unassigned') AS primary_training_purpose_name_en,
    COUNT(*) AS activity_count,
    ROUND(SUM(activity_review_view.distance_km), 2) AS total_km,
    SUM(activity_review_view.duration_sec) AS total_time_sec,
    ROUND(AVG(activity_review_view.training_load), 1) AS avg_training_load
FROM activity_review_view
JOIN current_month
    ON activity_review_view.activity_date BETWEEN current_month.month_start AND current_month.month_end
GROUP BY
    COALESCE(activity_review_view.workout_type_code, 'unassigned'),
    COALESCE(activity_review_view.workout_type_name_en, 'Unassigned'),
    COALESCE(activity_review_view.primary_training_purpose_code, 'unassigned'),
    COALESCE(activity_review_view.primary_training_purpose_name_en, 'Unassigned')
ORDER BY total_km DESC, activity_count DESC;

CREATE VIEW current_month_assignment_quality_view AS
WITH current_month AS (
    SELECT month_start, month_end
    FROM current_month_summary_view
)
SELECT
    COUNT(*) AS total_activities,
    SUM(CASE WHEN workout_type_id IS NOT NULL THEN 1 ELSE 0 END) AS workout_tagged_activities,
    SUM(CASE WHEN primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) AS purpose_tagged_activities,
    SUM(CASE WHEN workout_type_id IS NOT NULL AND primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) AS fully_tagged_activities,
    ROUND(
        SUM(CASE WHEN workout_type_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS workout_tagged_pct,
    ROUND(
        SUM(CASE WHEN primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS purpose_tagged_pct,
    ROUND(
        SUM(CASE WHEN workout_type_id IS NOT NULL AND primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS fully_tagged_pct
FROM activity_review_view
JOIN current_month
    ON activity_review_view.activity_date BETWEEN current_month.month_start AND current_month.month_end;

CREATE VIEW current_month_progress_view AS
WITH current_month AS (
    SELECT *
    FROM current_month_summary_view
),
progress AS (
    SELECT
        CAST(STRFTIME('%d', latest_date) AS INTEGER) AS day_of_month,
        CAST(STRFTIME('%d', month_end) AS INTEGER) AS days_in_month,
        CAST(STRFTIME('%d', latest_date) AS REAL) / CAST(STRFTIME('%d', month_end) AS REAL) AS progress_ratio
    FROM current_month
),
month_session_counts AS (
    SELECT
        DATE(activity_date, 'start of month') AS month_start,
        SUM(CASE WHEN is_quality_session = 1 THEN 1 ELSE 0 END) AS quality_sessions,
        SUM(CASE WHEN is_long_run = 1 THEN 1 ELSE 0 END) AS long_runs
    FROM activity_review_view
    GROUP BY DATE(activity_date, 'start of month')
),
current_session_counts AS (
    SELECT
        COALESCE(quality_sessions, 0) AS quality_sessions,
        COALESCE(long_runs, 0) AS long_runs
    FROM month_session_counts
    WHERE month_start = (SELECT month_start FROM current_month)
),
ranked_months AS (
    SELECT
        month_start,
        ROW_NUMBER() OVER (ORDER BY month_start DESC) AS month_rank
    FROM monthly_summary_view
),
baseline_months AS (
    SELECT month_start
    FROM ranked_months
    WHERE month_rank BETWEEN 2 AND 4
),
baseline_summary AS (
    SELECT
        AVG(total_km) AS baseline_km,
        AVG(training_load) AS baseline_load,
        AVG(activities) AS baseline_activities
    FROM monthly_summary_view
    WHERE month_start IN (SELECT month_start FROM baseline_months)
),
baseline_session_counts AS (
    SELECT
        AVG(quality_sessions) AS baseline_quality_sessions,
        AVG(long_runs) AS baseline_long_runs
    FROM month_session_counts
    WHERE month_start IN (SELECT month_start FROM baseline_months)
)
SELECT
    current_month.month_key,
    progress.day_of_month,
    progress.days_in_month,
    ROUND(progress.progress_ratio * 100, 1) AS progress_pct,
    current_month.activities AS current_activities,
    current_month.total_km AS current_km,
    current_month.training_load AS current_load,
    COALESCE(current_session_counts.quality_sessions, 0) AS current_quality_sessions,
    COALESCE(current_session_counts.long_runs, 0) AS current_long_runs,
    ROUND(baseline_summary.baseline_activities, 1) AS baseline_activities,
    ROUND(baseline_summary.baseline_km, 2) AS baseline_km,
    ROUND(baseline_summary.baseline_load, 1) AS baseline_load,
    ROUND(baseline_session_counts.baseline_quality_sessions, 1) AS baseline_quality_sessions,
    ROUND(baseline_session_counts.baseline_long_runs, 1) AS baseline_long_runs,
    ROUND(baseline_summary.baseline_activities * progress.progress_ratio, 1) AS target_activities_to_date,
    ROUND(baseline_summary.baseline_km * progress.progress_ratio, 1) AS target_km_to_date,
    ROUND(baseline_summary.baseline_load * progress.progress_ratio, 1) AS target_load_to_date,
    ROUND(baseline_session_counts.baseline_quality_sessions * progress.progress_ratio, 1) AS target_quality_to_date,
    ROUND(baseline_session_counts.baseline_long_runs * progress.progress_ratio, 1) AS target_long_runs_to_date
FROM current_month
LEFT JOIN current_session_counts ON 1 = 1
LEFT JOIN baseline_summary ON 1 = 1
LEFT JOIN baseline_session_counts ON 1 = 1
CROSS JOIN progress;

CREATE VIEW current_month_key_sessions_view AS
WITH current_month AS (
    SELECT month_start, month_end
    FROM current_month_summary_view
),
current_rows AS (
    SELECT *
    FROM activity_review_view
    WHERE activity_date BETWEEN
        (SELECT month_start FROM current_month)
        AND
        (SELECT month_end FROM current_month)
),
longest AS (
    SELECT
        'Longest Run' AS key_session_type,
        *
    FROM current_rows
    ORDER BY distance_km DESC, duration_sec DESC, activity_start_time DESC
    LIMIT 1
),
highest_load AS (
    SELECT
        'Highest Load' AS key_session_type,
        *
    FROM current_rows
    WHERE training_load IS NOT NULL
    ORDER BY training_load DESC, distance_km DESC, activity_start_time DESC
    LIMIT 1
),
fastest_quality AS (
    SELECT
        'Fastest Quality' AS key_session_type,
        *
    FROM current_rows
    WHERE is_quality_session = 1
      AND avg_pace_sec_per_km IS NOT NULL
    ORDER BY avg_pace_sec_per_km ASC, distance_km DESC, activity_start_time DESC
    LIMIT 1
),
lowest_hr_easy AS (
    SELECT
        'Lowest HR Easy' AS key_session_type,
        *
    FROM current_rows
    WHERE intensity_category IN ('Recovery', 'Easy')
      AND avg_hr IS NOT NULL
    ORDER BY avg_hr ASC, distance_km DESC, activity_start_time DESC
    LIMIT 1
)
SELECT * FROM longest
UNION ALL
SELECT * FROM highest_load
UNION ALL
SELECT * FROM fastest_quality
UNION ALL
SELECT * FROM lowest_hr_easy;

CREATE VIEW journey_month_story_view AS
WITH latest_activity AS (
    SELECT DATE(MAX(activity_start_time)) AS latest_date
    FROM activity
),
ranked_months AS (
    SELECT
        monthly_summary_view.*,
        ROW_NUMBER() OVER (ORDER BY month_start DESC) AS month_rank
    FROM monthly_summary_view
),
month_session_counts AS (
    SELECT
        DATE(activity_date, 'start of month') AS month_start,
        SUM(CASE WHEN is_quality_session = 1 THEN 1 ELSE 0 END) AS quality_sessions,
        SUM(CASE WHEN is_long_run = 1 THEN 1 ELSE 0 END) AS long_runs
    FROM activity_review_view
    GROUP BY DATE(activity_date, 'start of month')
),
month_assignment_quality AS (
    SELECT
        DATE(activity_date, 'start of month') AS month_start,
        ROUND(
            SUM(CASE WHEN workout_type_id IS NOT NULL AND primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
            1
        ) AS fully_tagged_pct
    FROM activity_review_view
    GROUP BY DATE(activity_date, 'start of month')
),
story_base AS (
    SELECT
        ranked_months.month_start,
        ranked_months.month_end,
        ranked_months.month_key,
        ranked_months.activities,
        ranked_months.total_km,
        ranked_months.total_time_sec,
        ranked_months.avg_pace_sec_per_km,
        ranked_months.avg_hr,
        ranked_months.training_load,
        ranked_months.month_rank,
        latest_activity.latest_date,
        CASE
            WHEN ranked_months.month_start = DATE(latest_activity.latest_date, 'start of month')
                 AND latest_activity.latest_date < ranked_months.month_end
            THEN 1
            ELSE 0
        END AS is_partial_month,
        COALESCE(month_session_counts.quality_sessions, 0) AS quality_sessions,
        COALESCE(month_session_counts.long_runs, 0) AS long_runs,
        COALESCE(month_assignment_quality.fully_tagged_pct, 0) AS fully_tagged_pct,
        (
            SELECT ROUND(AVG(previous_month.total_km), 2)
            FROM ranked_months AS previous_month
            WHERE previous_month.month_rank BETWEEN ranked_months.month_rank + 1 AND ranked_months.month_rank + 3
        ) AS baseline_km,
        (
            SELECT ROUND(AVG(previous_month.training_load), 1)
            FROM ranked_months AS previous_month
            WHERE previous_month.month_rank BETWEEN ranked_months.month_rank + 1 AND ranked_months.month_rank + 3
        ) AS baseline_load,
        (
            SELECT previous_month.month_key
            FROM ranked_months AS previous_month
            WHERE previous_month.month_rank = ranked_months.month_rank + 1
        ) AS previous_month_key
    FROM ranked_months
    CROSS JOIN latest_activity
    LEFT JOIN month_session_counts
        ON month_session_counts.month_start = ranked_months.month_start
    LEFT JOIN month_assignment_quality
        ON month_assignment_quality.month_start = ranked_months.month_start
)
SELECT
    story_base.month_start,
    story_base.month_end,
    story_base.month_key,
    story_base.activities,
    story_base.total_km,
    story_base.total_time_sec,
    story_base.avg_pace_sec_per_km,
    story_base.avg_hr,
    story_base.training_load,
    story_base.month_rank,
    story_base.latest_date,
    story_base.is_partial_month,
    story_base.quality_sessions,
    story_base.long_runs,
    story_base.fully_tagged_pct,
    story_base.baseline_km,
    story_base.baseline_load,
    story_base.previous_month_key,
    CASE
        WHEN story_base.baseline_km > 0
        THEN ROUND(((story_base.total_km - story_base.baseline_km) / story_base.baseline_km) * 100, 1)
        ELSE NULL
    END AS km_delta_pct,
    CASE
        WHEN story_base.baseline_load > 0
        THEN ROUND(((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100, 1)
        ELSE NULL
    END AS load_delta_pct,
    CASE
        WHEN story_base.is_partial_month = 1 AND story_base.quality_sessions >= 1 AND story_base.long_runs >= 1
        THEN 'balanced_build'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 < -15
        THEN 'absorb'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 > 15
        THEN 'load_build'
        WHEN story_base.quality_sessions >= 2 AND story_base.long_runs >= 1
        THEN 'balanced_build'
        WHEN story_base.long_runs >= 2
        THEN 'endurance_build'
        WHEN story_base.activities >= 20
        THEN 'steady_build'
        ELSE 'foundation'
    END AS chapter_code,
    CASE
        WHEN story_base.is_partial_month = 1 AND story_base.quality_sessions >= 1 AND story_base.long_runs >= 1
        THEN '平衡建構中'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 < -15
        THEN '吸收調整'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 > 15
        THEN '負荷建構'
        WHEN story_base.quality_sessions >= 2 AND story_base.long_runs >= 1
        THEN '平衡建構'
        WHEN story_base.long_runs >= 2
        THEN '耐力累積'
        WHEN story_base.activities >= 20
        THEN '穩定累積'
        ELSE '基礎建立'
    END AS chapter_label,
    CASE
        WHEN story_base.is_partial_month = 1
        THEN '正常'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 < -15
        THEN '吸收月'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 > 15
        THEN '負荷建構'
        ELSE '平衡建構'
    END AS coach_verdict,
    CASE
        WHEN story_base.is_partial_month = 1
        THEN '這個月仍在進行中，先把它當成旅程中的進度點，月底再做完整評估。'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 < -15
        THEN '這個月更像吸收與整理的一章，負荷低於近期平均，但方向本身沒有問題。'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 > 15
        THEN '這個月是明顯的建構期，負荷拉高，代表你正在往更高刺激推進。'
        WHEN story_base.quality_sessions >= 2 AND story_base.long_runs >= 1
        THEN '這個月兼顧品質課與長跑，代表訓練正在往更成熟的平衡建構前進。'
        WHEN story_base.long_runs >= 2
        THEN '這個月長跑比重明顯，旅程焦點偏向耐力累積。'
        ELSE '這個月仍以穩定累積為主，像是在為下一階段鋪底。'
    END AS coach_note,
    CASE
        WHEN story_base.is_partial_month = 1
        THEN '先把目前節奏走穩，保留一次長跑，月底再決定是否切進下一個刺激週期。'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 < -15
        THEN '下一章可以慢慢把品質刺激拉回來，讓吸收後的能量重新轉成推進力。'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 > 15
        THEN '下一章優先保護恢復，把建構成果吸收下來，再決定是否繼續加碼。'
        WHEN story_base.quality_sessions >= 2 AND story_base.long_runs >= 1
        THEN '下一章可以延續現在的平衡建構，逐步把節奏推向更專項的刺激。'
        WHEN story_base.long_runs >= 2
        THEN '下一章可以開始加入更多品質課，讓耐力累積慢慢轉成速度表現。'
        ELSE '下一章先維持穩定累積，等節奏站穩後再提高品質課比例。'
    END AS next_chapter_note,
    CASE
        WHEN story_base.is_partial_month = 1
        THEN '繼續平衡建構'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 < -15
        THEN '重新拉回刺激'
        WHEN story_base.baseline_load > 0 AND ((story_base.training_load - story_base.baseline_load) / story_base.baseline_load) * 100 > 15
        THEN '保護恢復'
        WHEN story_base.quality_sessions >= 2 AND story_base.long_runs >= 1
        THEN '進入專項建構'
        WHEN story_base.long_runs >= 2
        THEN '加入更多品質課'
        ELSE '延續穩定累積'
    END AS next_chapter_label
FROM story_base
ORDER BY story_base.month_start DESC;

CREATE VIEW journey_turning_point_view AS
WITH story AS (
    SELECT *
    FROM journey_month_story_view
),
milestones AS (
    SELECT
        month_key,
        month_start,
        'distance_200' AS milestone_code,
        '穩定累積開始成形' AS milestone_title,
        '這是第一次跨過 200 公里月，代表你已經不只是偶爾跑得多，而是開始有穩定承接訓練的能力。' AS milestone_note
    FROM story AS current_story
    WHERE total_km >= 200
      AND NOT EXISTS (
          SELECT 1
          FROM story AS previous_story
          WHERE previous_story.month_start < current_story.month_start
            AND previous_story.total_km >= 200
      )
    UNION ALL
    SELECT
        month_key,
        month_start,
        'distance_250' AS milestone_code,
        '第一次真正建立訓練承載力' AS milestone_title,
        '這是第一次突破 250 公里月。被記住的，不只是數字，而是你開始有能力承受更大的訓練量。' AS milestone_note
    FROM story AS current_story
    WHERE total_km >= 250
      AND NOT EXISTS (
          SELECT 1
          FROM story AS previous_story
          WHERE previous_story.month_start < current_story.month_start
            AND previous_story.total_km >= 250
      )
    UNION ALL
    SELECT
        month_key,
        month_start,
        'load_4000' AS milestone_code,
        '開始穩定承受更高刺激' AS milestone_title,
        '這是第一次突破 4000 訓練負荷。代表你已經開始接觸更高強度的訓練壓力，也更需要學會恢復。' AS milestone_note
    FROM story AS current_story
    WHERE training_load >= 4000
      AND NOT EXISTS (
          SELECT 1
          FROM story AS previous_story
          WHERE previous_story.month_start < current_story.month_start
            AND previous_story.training_load >= 4000
      )
    UNION ALL
    SELECT
        month_key,
        month_start,
        'quality_steady' AS milestone_code,
        '品質刺激不再只是偶爾出現' AS milestone_title,
        '這個月品質課開始穩定出現，代表訓練不只是在累積，也開始有更明確的方向。' AS milestone_note
    FROM story AS current_story
    WHERE quality_sessions >= 2
      AND NOT EXISTS (
          SELECT 1
          FROM story AS previous_story
          WHERE previous_story.month_start < current_story.month_start
            AND previous_story.quality_sessions >= 2
      )
    UNION ALL
    SELECT
        month_key,
        month_start,
        'long_run_shape' AS milestone_code,
        '長距離耐力開始變成熟' AS milestone_title,
        '長跑頻率開始站穩。這不只是多跑幾公里，而是耐力開始從一次完成，慢慢變成穩定能力。' AS milestone_note
    FROM story AS current_story
    WHERE long_runs >= 2
      AND NOT EXISTS (
          SELECT 1
          FROM story AS previous_story
          WHERE previous_story.month_start < current_story.month_start
            AND previous_story.long_runs >= 2
      )
    UNION ALL
    SELECT
        month_key,
        month_start,
        'metadata_ready' AS milestone_code,
        '訓練故事開始變得更清楚' AS milestone_title,
        '本月大部分活動已完成標註。之後被記住的，不只會是數據，還會是更完整的訓練脈絡。' AS milestone_note
    FROM story AS current_story
    WHERE fully_tagged_pct >= 80
      AND NOT EXISTS (
          SELECT 1
          FROM story AS previous_story
          WHERE previous_story.month_start < current_story.month_start
            AND previous_story.fully_tagged_pct >= 80
      )
)
SELECT
    month_key,
    month_start,
    milestone_code,
    milestone_title,
    milestone_note
FROM milestones
ORDER BY month_start DESC, milestone_code;

CREATE VIEW training_distribution_view AS
SELECT
    COALESCE(workout_type_code, 'unassigned') AS workout_type_code,
    COALESCE(workout_type_name_en, 'Unassigned') AS workout_type_name_en,
    COALESCE(primary_training_purpose_code, 'unassigned') AS primary_training_purpose_code,
    COALESCE(primary_training_purpose_name_en, 'Unassigned') AS primary_training_purpose_name_en,
    COUNT(*) AS activity_count,
    ROUND(SUM(distance_km), 2) AS total_km,
    SUM(duration_sec) AS total_time_sec,
    ROUND(AVG(training_load), 1) AS avg_training_load
FROM activity_review_view
GROUP BY
    COALESCE(workout_type_code, 'unassigned'),
    COALESCE(workout_type_name_en, 'Unassigned'),
    COALESCE(primary_training_purpose_code, 'unassigned'),
    COALESCE(primary_training_purpose_name_en, 'Unassigned')
ORDER BY total_km DESC, activity_count DESC;

CREATE VIEW training_balance_view AS
SELECT
    COALESCE(intensity_category, 'Unassigned') AS intensity_category,
    COUNT(*) AS activity_count,
    ROUND(SUM(distance_km), 2) AS total_km,
    SUM(duration_sec) AS total_time_sec,
    ROUND(AVG(training_load), 1) AS avg_training_load,
    ROUND(SUM(training_load), 1) AS total_training_load
FROM activity_review_view
GROUP BY COALESCE(intensity_category, 'Unassigned')
ORDER BY total_km DESC, activity_count DESC;

CREATE VIEW training_assignment_quality_view AS
SELECT
    COUNT(*) AS total_activities,
    SUM(CASE WHEN workout_type_id IS NOT NULL THEN 1 ELSE 0 END) AS workout_tagged_activities,
    SUM(CASE WHEN primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) AS purpose_tagged_activities,
    SUM(CASE WHEN workout_type_id IS NOT NULL AND primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) AS fully_tagged_activities,
    SUM(CASE WHEN workout_type_id IS NULL AND primary_training_purpose_id IS NULL THEN 1 ELSE 0 END) AS unassigned_activities,
    ROUND(
        SUM(CASE WHEN workout_type_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS workout_tagged_pct,
    ROUND(
        SUM(CASE WHEN primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS purpose_tagged_pct,
    ROUND(
        SUM(CASE WHEN workout_type_id IS NOT NULL AND primary_training_purpose_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS fully_tagged_pct
FROM activity_review_view;

CREATE VIEW recent_training_intent_view AS
SELECT
    activity_id,
    activity_start_time,
    activity_name,
    activity_type,
    distance_km,
    training_load,
    workout_type_name_en,
    primary_training_purpose_name_en,
    secondary_training_purpose_names_en,
    intensity_category,
    shoe_display_name
FROM activity_review_view
ORDER BY activity_start_time DESC;

CREATE VIEW shoe_comparison_view AS
WITH shoe_activity AS (
    SELECT
        shoe_id,
        ROUND(AVG(avg_pace_sec_per_km), 1) AS avg_pace_sec_per_km,
        ROUND(AVG(training_load), 1) AS avg_training_load,
        ROUND(AVG(avg_cadence_spm), 1) AS avg_cadence_spm
    FROM activity_review_view
    WHERE shoe_id IS NOT NULL
    GROUP BY shoe_id
)
SELECT
    shoe_statistics_view.shoe_id,
    shoe_statistics_view.shoe_code,
    shoe_statistics_view.brand,
    shoe_statistics_view.model,
    shoe_statistics_view.nickname,
    shoe_statistics_view.category,
    shoe_statistics_view.is_active,
    shoe_statistics_view.run_count,
    shoe_statistics_view.total_distance_km,
    shoe_statistics_view.observed_first_run_time,
    shoe_statistics_view.observed_last_run_time,
    shoe_statistics_view.avg_hr,
    shoe_activity.avg_pace_sec_per_km,
    shoe_activity.avg_training_load,
    shoe_activity.avg_cadence_spm
FROM shoe_statistics_view
LEFT JOIN shoe_activity
    ON shoe_statistics_view.shoe_id = shoe_activity.shoe_id
ORDER BY
    shoe_statistics_view.total_distance_km DESC,
    shoe_statistics_view.run_count DESC,
    shoe_statistics_view.shoe_id;

CREATE VIEW shoe_intelligence_view AS
SELECT
    shoe_comparison_view.shoe_id,
    shoe_comparison_view.shoe_code,
    TRIM(
        COALESCE(shoe_comparison_view.brand || ' ', '') ||
        COALESCE(shoe_comparison_view.model, '') ||
        CASE
            WHEN shoe_comparison_view.nickname IS NULL OR shoe_comparison_view.nickname = ''
            THEN ''
            ELSE ' ' || shoe_comparison_view.nickname
        END
    ) AS shoe_display_name,
    shoe_comparison_view.category,
    shoe_comparison_view.is_active,
    shoe_comparison_view.run_count,
    shoe_comparison_view.total_distance_km,
    shoe_comparison_view.avg_pace_sec_per_km,
    shoe_comparison_view.avg_hr,
    shoe_comparison_view.avg_training_load,
    shoe_comparison_view.avg_cadence_spm,
    COALESCE(SUM(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN 1
            ELSE 0
        END
    ), 0) AS tagged_activity_count,
    ROUND(COALESCE(SUM(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.distance_km
            ELSE 0
        END
    ), 0), 2) AS tagged_total_km,
    ROUND(AVG(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.avg_hr
            ELSE NULL
        END
    ), 1) AS tagged_avg_hr,
    ROUND(AVG(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.avg_pace_sec_per_km
            ELSE NULL
        END
    ), 1) AS tagged_avg_pace_sec_per_km,
    ROUND(AVG(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.training_load
            ELSE NULL
        END
    ), 1) AS tagged_avg_training_load,
    ROUND(AVG(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.avg_cadence_spm
            ELSE NULL
        END
    ), 1) AS tagged_avg_cadence_spm,
    ROUND(AVG(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.avg_gct_ms
            ELSE NULL
        END
    ), 1) AS tagged_avg_gct_ms,
    ROUND(AVG(
        CASE
            WHEN activity_review_view.workout_type_id IS NOT NULL
            THEN activity_review_view.avg_stride_length_mm
            ELSE NULL
        END
    ), 1) AS tagged_avg_stride_length_mm
FROM shoe_comparison_view
LEFT JOIN activity_review_view
    ON shoe_comparison_view.shoe_id = activity_review_view.shoe_id
GROUP BY
    shoe_comparison_view.shoe_id,
    shoe_comparison_view.shoe_code,
    shoe_display_name,
    shoe_comparison_view.category,
    shoe_comparison_view.is_active,
    shoe_comparison_view.run_count,
    shoe_comparison_view.total_distance_km,
    shoe_comparison_view.avg_pace_sec_per_km,
    shoe_comparison_view.avg_hr,
    shoe_comparison_view.avg_training_load,
    shoe_comparison_view.avg_cadence_spm
ORDER BY shoe_comparison_view.total_distance_km DESC, shoe_comparison_view.run_count DESC;

CREATE VIEW shoe_workout_comparison_view AS
SELECT
    shoe_id,
    shoe_code,
    shoe_display_name,
    workout_type_id,
    workout_type_code,
    workout_type_name_en,
    COUNT(*) AS activity_count,
    ROUND(SUM(distance_km), 2) AS total_km,
    ROUND(AVG(avg_pace_sec_per_km), 1) AS avg_pace_sec_per_km,
    ROUND(AVG(avg_hr), 1) AS avg_hr,
    ROUND(AVG(training_load), 1) AS avg_training_load,
    ROUND(AVG(avg_cadence_spm), 1) AS avg_cadence_spm,
    ROUND(AVG(avg_gct_ms), 1) AS avg_gct_ms,
    ROUND(AVG(avg_stride_length_mm), 1) AS avg_stride_length_mm
FROM activity_review_view
WHERE shoe_id IS NOT NULL
  AND workout_type_id IS NOT NULL
GROUP BY
    shoe_id,
    shoe_code,
    shoe_display_name,
    workout_type_id,
    workout_type_code,
    workout_type_name_en
ORDER BY total_km DESC, activity_count DESC, shoe_id;

CREATE VIEW recent_activity_view AS
SELECT
    ROW_NUMBER() OVER (ORDER BY activity_start_time DESC) AS recency_rank,
    activity_review_view.*
FROM activity_review_view;
