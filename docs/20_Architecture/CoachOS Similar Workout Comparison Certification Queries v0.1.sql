-- CoachOS Similar Workout Comparison Certification Queries v0.1
-- Purpose: fixture-driven certification queries for similar workout comparison SQL
-- Prerequisite order:
--   1. SQLite Schema v1.0.sql
--   2. Semantic Layer v1.0.sql
--   3. CoachOS Similar Workout Comparison Fixture Data v0.1.sql
--   4. CoachOS Similar Workout Comparison SQL Draft v0.1.sql

INSERT OR REPLACE INTO similar_workout_comparison_definition (
    comparison_definition_id,
    comparison_name,
    workout_family,
    structure_type,
    primary_training_purpose,
    tolerance_basis,
    reference_distance_m,
    reference_duration_s,
    distance_tolerance_pct,
    duration_tolerance_pct,
    include_current_activity_in_baseline,
    exclude_stride,
    exclude_progression,
    exclude_fast_finish,
    exclude_quality_segments,
    minimum_comparison_samples,
    minimum_trend_samples
) VALUES
    ('easy-continuous-aerobic-base-distance-10pct', 'Easy Continuous Aerobic Base', 'easy_run', 'continuous', 'aerobic_base', 'distance', 8000, NULL, 10.0, 10.0, 0, 1, 1, 1, 0, 3, 5),
    ('recovery-continuous-recovery-distance-10pct', 'Recovery Continuous', 'recovery_run', 'continuous', 'recovery', 'distance', 5000, NULL, 10.0, 10.0, 0, 1, 1, 1, 0, 3, 5),
    ('tempo-structured-tempo-distance-10pct', 'Tempo Structured', 'tempo_run', 'tempo_structured', 'tempo', 'distance', 10000, NULL, 10.0, 10.0, 0, 0, 0, 0, 0, 3, 5),
    ('interval-structured-interval-distance-10pct', 'Interval Structured', 'interval_run', 'interval_structured', 'interval', 'distance', 9000, NULL, 10.0, 10.0, 0, 0, 0, 0, 0, 3, 5);

DROP VIEW IF EXISTS certification_results;
DROP TABLE IF EXISTS certification_anchor_results;
DROP TABLE IF EXISTS certification_metric_results;
DROP TABLE IF EXISTS certification_comparison_results;

CREATE TEMP TABLE certification_anchor_results AS
SELECT *
FROM activity_comparison_anchor_view;

CREATE TEMP TABLE certification_metric_results AS
SELECT *
FROM activity_comparison_metric_view;

CREATE TEMP TABLE certification_comparison_results AS
SELECT *
FROM similar_workout_comparison_view;

CREATE TEMP VIEW certification_results AS
WITH case_map AS (
    SELECT NULL AS activity_id, 'GLOBAL' AS case_id UNION ALL
    SELECT 101 AS activity_id, 'E01' AS case_id UNION ALL
    SELECT 102, 'E02' UNION ALL
    SELECT 103, 'E03' UNION ALL
    SELECT 104, 'E04' UNION ALL
    SELECT 105, 'E05' UNION ALL
    SELECT 106, 'E06' UNION ALL
    SELECT 107, 'E07' UNION ALL
    SELECT 108, 'E08' UNION ALL
    SELECT 109, 'E09' UNION ALL
    SELECT 110, 'E10' UNION ALL
    SELECT 111, 'R1' UNION ALL
    SELECT 112, 'R2' UNION ALL
    SELECT 113, 'R3' UNION ALL
    SELECT 114, 'R4' UNION ALL
    SELECT 115, 'T1' UNION ALL
    SELECT 116, 'T2' UNION ALL
    SELECT 117, 'I1' UNION ALL
    SELECT 118, 'I2'
),
assertions AS (
    SELECT
        'E01' AS case_id,
        'anchor' AS validation_area,
        'start_anchor' AS validation_name,
        '1' AS expected_value,
        CAST(av.start_anchor_split_index AS TEXT) AS actual_value,
        CASE WHEN av.start_anchor_split_index = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
        'Easy 8K should start at split 1.' AS notes
    FROM certification_anchor_results av
    WHERE av.activity_id = 101

    UNION ALL
    SELECT
        'E01', 'anchor', 'mid_anchor', '4',
        CAST(av.mid_anchor_split_index AS TEXT),
        CASE WHEN av.mid_anchor_split_index = 4 THEN 'PASS' ELSE 'FAIL' END,
        'Lower midpoint policy should land on split 4.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 101

    UNION ALL
    SELECT
        'E01', 'anchor', 'finish_anchor', '8',
        CAST(av.finish_anchor_split_index AS TEXT),
        CASE WHEN av.finish_anchor_split_index = 8 THEN 'PASS' ELSE 'FAIL' END,
        'Easy 8K should finish at split 8.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 101

    UNION ALL
    SELECT
        'E10', 'anchor', 'finish_anchor', '8',
        CAST(av.finish_anchor_split_index AS TEXT),
        CASE WHEN av.finish_anchor_split_index = 8 THEN 'PASS' ELSE 'FAIL' END,
        'Tail fragment must not become the finish anchor.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 110

    UNION ALL
    SELECT
        'E10', 'anchor', 'finish_position_pct', '100.0',
        printf('%.1f', av.finish_anchor_position_pct),
        CASE WHEN ABS(av.finish_anchor_position_pct - 100.0) < 0.01 THEN 'PASS' ELSE 'FAIL' END,
        'Finish anchor should map to 100 percent of representative scope.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 110

    UNION ALL
    SELECT
        'T1', 'anchor', 'analysis_scope', 'main_segment',
        av.analysis_scope,
        CASE WHEN av.analysis_scope = 'main_segment' THEN 'PASS' ELSE 'FAIL' END,
        'Tempo should analyze main segment.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 115

    UNION ALL
    SELECT
        'T1', 'anchor', 'scope_resolution_status', 'resolved',
        av.scope_resolution_status,
        CASE WHEN av.scope_resolution_status = 'resolved' THEN 'PASS' ELSE 'FAIL' END,
        'Structured tempo should resolve its main segment.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 115

    UNION ALL
    SELECT
        'T2', 'anchor', 'analysis_scope', 'main_segment',
        av.analysis_scope,
        CASE WHEN av.analysis_scope = 'main_segment' THEN 'PASS' ELSE 'FAIL' END,
        'Tempo without structure still carries main-segment intent.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 116

    UNION ALL
    SELECT
        'T2', 'anchor', 'scope_resolution_status', 'insufficient',
        av.scope_resolution_status,
        CASE WHEN av.scope_resolution_status = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Tempo without structure should be marked insufficient.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 116

    UNION ALL
    SELECT
        'I1', 'anchor', 'analysis_scope', 'work_intervals',
        av.analysis_scope,
        CASE WHEN av.analysis_scope = 'work_intervals' THEN 'PASS' ELSE 'FAIL' END,
        'Interval workout should analyze work intervals.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 117

    UNION ALL
    SELECT
        'I1', 'anchor', 'scope_resolution_status', 'resolved',
        av.scope_resolution_status,
        CASE WHEN av.scope_resolution_status = 'resolved' THEN 'PASS' ELSE 'FAIL' END,
        'Structured interval should resolve work-interval scope.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 117

    UNION ALL
    SELECT
        'I2', 'anchor', 'scope_resolution_status', 'insufficient',
        av.scope_resolution_status,
        CASE WHEN av.scope_resolution_status = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Incomplete interval structure should remain insufficient.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 118

    UNION ALL
    SELECT
        'E04', 'comparison', 'seed_eligibility', '0',
        CAST(cv.seed_is_cohort_eligible AS TEXT),
        CASE WHEN cv.seed_is_cohort_eligible = 0 THEN 'PASS' ELSE 'FAIL' END,
        '8.81K should be excluded by reference-distance tolerance.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 104

    UNION ALL
    SELECT
        'E04', 'comparison', 'exclusion_reason', 'outside distance tolerance',
        cv.seed_exclusion_reason,
        CASE WHEN cv.seed_exclusion_reason = 'outside distance tolerance' THEN 'PASS' ELSE 'FAIL' END,
        'Distance exclusion reason should be explicit.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 104

    UNION ALL
    SELECT
        'E05', 'comparison', 'seed_eligibility', '0',
        CAST(cv.seed_is_cohort_eligible AS TEXT),
        CASE WHEN cv.seed_is_cohort_eligible = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Stride session should be excluded.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 105

    UNION ALL
    SELECT
        'E05', 'comparison', 'comparison_validity', 'excluded',
        cv.comparison_validity,
        CASE WHEN cv.comparison_validity = 'excluded' THEN 'PASS' ELSE 'FAIL' END,
        'Stride session should not generate a formal comparison baseline.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 105

    UNION ALL
    SELECT
        'E07', 'comparison', 'seed_eligibility', '0',
        CAST(cv.seed_is_cohort_eligible AS TEXT),
        CASE WHEN cv.seed_is_cohort_eligible = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Fast-finish session should be excluded.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 107

    UNION ALL
    SELECT
        'E07', 'comparison', 'exclusion_reason', 'fast finish present',
        cv.seed_exclusion_reason,
        CASE WHEN cv.seed_exclusion_reason = 'fast finish present' THEN 'PASS' ELSE 'FAIL' END,
        'Fast-finish exclusion reason should be explicit.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 107

    UNION ALL
    SELECT
        'E02', 'comparison', 'seed_eligibility', '1',
        CAST(cv.seed_is_cohort_eligible AS TEXT),
        CASE WHEN cv.seed_is_cohort_eligible = 1 THEN 'PASS' ELSE 'FAIL' END,
        '7.8K should remain eligible within distance tolerance.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 102

    UNION ALL
    SELECT
        'E03', 'comparison', 'seed_eligibility', '1',
        CAST(cv.seed_is_cohort_eligible AS TEXT),
        CASE WHEN cv.seed_is_cohort_eligible = 1 THEN 'PASS' ELSE 'FAIL' END,
        '8.8K should remain eligible at the upper tolerance boundary.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 103

    UNION ALL
    SELECT
        'E06', 'comparison', 'seed_eligibility', '0',
        CAST(cv.seed_is_cohort_eligible AS TEXT),
        CASE WHEN cv.seed_is_cohort_eligible = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Progression session should be excluded.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 106

    UNION ALL
    SELECT
        'E06', 'comparison', 'exclusion_reason', 'progression work present',
        cv.seed_exclusion_reason,
        CASE WHEN cv.seed_exclusion_reason = 'progression work present' THEN 'PASS' ELSE 'FAIL' END,
        'Progression exclusion reason should be explicit.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 106

    UNION ALL
    SELECT
        'E06', 'comparison', 'comparison_validity', 'excluded',
        cv.comparison_validity,
        CASE WHEN cv.comparison_validity = 'excluded' THEN 'PASS' ELSE 'FAIL' END,
        'Progression session should not generate a formal comparison baseline.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 106

    UNION ALL
    SELECT
        'E01', 'comparison', 'eligible_cohort_sample_count', '6',
        CAST(cv.eligible_cohort_sample_count AS TEXT),
        CASE WHEN cv.eligible_cohort_sample_count = 6 THEN 'PASS' ELSE 'FAIL' END,
        'Easy comparison set should contain six eligible activities including seed.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 101

    UNION ALL
    SELECT
        'E01', 'comparison', 'baseline_sample_count', '5',
        CAST(cv.baseline_sample_count AS TEXT),
        CASE WHEN cv.baseline_sample_count = 5 THEN 'PASS' ELSE 'FAIL' END,
        'Easy baseline should exclude current activity.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 101

    UNION ALL
    SELECT
        'E01', 'comparison', 'pace_language_level', 'recent_trend',
        cv.pace_language_level,
        CASE WHEN cv.pace_language_level = 'recent_trend' THEN 'PASS' ELSE 'FAIL' END,
        'Five baseline pace samples should yield recent-trend language.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 101

    UNION ALL
    SELECT
        'E10', 'comparison', 'condition_note_required', '1',
        CAST(cv.condition_note_required AS TEXT),
        CASE WHEN cv.condition_note_required = 1 THEN 'PASS' ELSE 'FAIL' END,
        'Hot-weather Easy run should require a condition note.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 110

    UNION ALL
    SELECT
        'E08', 'comparison', 'power_validity', 'unavailable',
        cv.power_validity,
        CASE WHEN cv.power_validity = 'unavailable' THEN 'PASS' ELSE 'FAIL' END,
        'Missing activity power should remain unavailable, not fail whole comparison.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 108

    UNION ALL
    SELECT
        'E09', 'comparison', 'power_validity', 'reference_only',
        cv.power_validity,
        CASE WHEN cv.power_validity = 'reference_only' THEN 'PASS' ELSE 'FAIL' END,
        'Incompatible power provenance should degrade to reference-only.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 109

    UNION ALL
    SELECT
        'E01', 'comparison', 'pace_percentile_direction', '100.0',
        printf('%.1f', cv.pace_baseline_percentile),
        CASE WHEN ABS(cv.pace_baseline_percentile - 100.0) < 0.01 THEN 'PASS' ELSE 'FAIL' END,
        'Fastest Easy baseline case should rank at the top.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 101

    UNION ALL
    SELECT
        'R1', 'comparison', 'analysis_scope', 'whole_activity',
        cv.analysis_scope,
        CASE WHEN cv.analysis_scope = 'whole_activity' THEN 'PASS' ELSE 'FAIL' END,
        'Recovery runs should compare at whole-activity scope.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 111

    UNION ALL
    SELECT
        'R2', 'comparison', 'baseline_sample_count', '3',
        CAST(cv.baseline_sample_count AS TEXT),
        CASE WHEN cv.baseline_sample_count = 3 THEN 'PASS' ELSE 'FAIL' END,
        'Recovery baseline should exclude current activity and keep the other three samples.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 112

    UNION ALL
    SELECT
        'R3', 'comparison', 'pace_language_level', 'current_observation',
        cv.pace_language_level,
        CASE WHEN cv.pace_language_level = 'current_observation' THEN 'PASS' ELSE 'FAIL' END,
        'Three baseline pace samples should yield current-observation language.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 113

    UNION ALL
    SELECT
        'R4', 'comparison', 'comparison_validity', 'valid',
        cv.comparison_validity,
        CASE WHEN cv.comparison_validity = 'valid' THEN 'PASS' ELSE 'FAIL' END,
        'Recovery cohort should have enough baseline samples for a valid comparison.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 114

    UNION ALL
    SELECT
        'R4', 'comparison', 'pace_percentile_range', '0_to_100',
        printf('%.1f', cv.pace_baseline_percentile),
        CASE
            WHEN cv.pace_baseline_percentile BETWEEN 0 AND 100 THEN 'PASS'
            ELSE 'FAIL'
        END,
        'Recovery pace percentile should stay within a valid percentile range.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 114

    UNION ALL
    SELECT
        'T1', 'anchor', 'start_anchor', '2',
        CAST(av.start_anchor_split_index AS TEXT),
        CASE WHEN av.start_anchor_split_index = 2 THEN 'PASS' ELSE 'FAIL' END,
        'Current Tempo fixture resolves to the governed tempo split.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 115

    UNION ALL
    SELECT
        'T1', 'anchor', 'finish_anchor', '2',
        CAST(av.finish_anchor_split_index AS TEXT),
        CASE WHEN av.finish_anchor_split_index = 2 THEN 'PASS' ELSE 'FAIL' END,
        'Single representative tempo split should anchor both start and finish.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 115

    UNION ALL
    SELECT
        'T2', 'anchor', 'anchor_validity_status', 'insufficient',
        av.anchor_validity_status,
        CASE WHEN av.anchor_validity_status = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Tempo without a resolved main segment should produce insufficient anchors.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 116

    UNION ALL
    SELECT
        'T2', 'metric', 'metric_validity_status', 'insufficient',
        mv.metric_validity_status,
        CASE WHEN mv.metric_validity_status = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Tempo without resolved anchors should remain metric-insufficient.'
    FROM certification_metric_results mv
    WHERE mv.activity_id = 116

    UNION ALL
    SELECT
        'T2', 'comparison', 'comparison_validity', 'insufficient',
        cv.comparison_validity,
        CASE WHEN cv.comparison_validity = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Tempo cohort with only one baseline sample should remain insufficient.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 116

    UNION ALL
    SELECT
        'I1', 'anchor', 'start_anchor', '1',
        CAST(av.start_anchor_split_index AS TEXT),
        CASE WHEN av.start_anchor_split_index = 1 THEN 'PASS' ELSE 'FAIL' END,
        'Interval start anchor should be the first work rep.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 117

    UNION ALL
    SELECT
        'I1', 'anchor', 'mid_anchor', '3',
        CAST(av.mid_anchor_split_index AS TEXT),
        CASE WHEN av.mid_anchor_split_index = 3 THEN 'PASS' ELSE 'FAIL' END,
        'Lower-midpoint policy should land on the second work rep.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 117

    UNION ALL
    SELECT
        'I1', 'anchor', 'finish_anchor', '7',
        CAST(av.finish_anchor_split_index AS TEXT),
        CASE WHEN av.finish_anchor_split_index = 7 THEN 'PASS' ELSE 'FAIL' END,
        'Interval finish anchor should be the final work rep.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 117

    UNION ALL
    SELECT
        'I2', 'anchor', 'anchor_validity_status', 'insufficient',
        av.anchor_validity_status,
        CASE WHEN av.anchor_validity_status = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Incomplete interval structure should produce insufficient anchors.'
    FROM certification_anchor_results av
    WHERE av.activity_id = 118

    UNION ALL
    SELECT
        'I2', 'metric', 'metric_validity_status', 'insufficient',
        mv.metric_validity_status,
        CASE WHEN mv.metric_validity_status = 'insufficient' THEN 'PASS' ELSE 'FAIL' END,
        'Incomplete interval structure should remain metric-insufficient.'
    FROM certification_metric_results mv
    WHERE mv.activity_id = 118

    UNION ALL
    SELECT
        'I2', 'comparison', 'comparison_validity', 'excluded',
        cv.comparison_validity,
        CASE WHEN cv.comparison_validity = 'excluded' THEN 'PASS' ELSE 'FAIL' END,
        'I2 currently fails eligibility before formal comparison because it falls outside interval distance tolerance.'
    FROM certification_comparison_results cv
    WHERE cv.activity_id = 118

    UNION ALL
    SELECT
        'T1', 'metric', 'heart_rate_scope_status', 'EXPECTED_UNAVAILABLE',
        CASE WHEN mv.heart_rate_delta_bpm IS NULL THEN 'EXPECTED_UNAVAILABLE' ELSE 'FAIL' END,
        CASE WHEN mv.heart_rate_delta_bpm IS NULL THEN 'EXPECTED_UNAVAILABLE' ELSE CAST(mv.heart_rate_delta_bpm AS TEXT) END,
        'Tempo scope HR is not yet implemented for structure segments.'
    FROM certification_metric_results mv
    WHERE mv.activity_id = 115

    UNION ALL
    SELECT
        'T1', 'metric', 'power_scope_status', 'EXPECTED_UNAVAILABLE',
        CASE WHEN mv.power_delta_w IS NULL THEN 'EXPECTED_UNAVAILABLE' ELSE 'FAIL' END,
        CASE WHEN mv.power_delta_w IS NULL THEN 'EXPECTED_UNAVAILABLE' ELSE CAST(mv.power_delta_w AS TEXT) END,
        'Tempo scope power is not yet implemented for structure segments.'
    FROM certification_metric_results mv
    WHERE mv.activity_id = 115

    UNION ALL
    SELECT
        'I1', 'metric', 'pace_direction', 'faster',
        mv.pace_change_direction,
        CASE WHEN mv.pace_change_direction = 'faster' THEN 'PASS' ELSE 'FAIL' END,
        'Interval case should preserve faster late-work direction.'
    FROM certification_metric_results mv
    WHERE mv.activity_id = 117

    UNION ALL
    SELECT
        'GLOBAL', 'invariant', 'excluded_seed_not_valid', '0',
        CAST(COUNT(*) AS TEXT),
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Excluded seeds must not surface as valid comparisons.'
    FROM certification_comparison_results cv
    WHERE cv.seed_is_cohort_eligible = 0
      AND cv.comparison_validity = 'valid'

    UNION ALL
    SELECT
        'GLOBAL', 'invariant', 'baseline_not_greater_than_eligible', '0',
        CAST(COUNT(*) AS TEXT),
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
        'Baseline sample count must never exceed eligible cohort sample count.'
    FROM certification_comparison_results cv
    WHERE cv.baseline_sample_count > cv.eligible_cohort_sample_count

    UNION ALL
    SELECT
        'GLOBAL', 'invariant', 'pace_percentile_in_range', '0',
        CAST(COUNT(*) AS TEXT),
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
        'All non-null pace percentiles must remain within 0 to 100.'
    FROM certification_comparison_results cv
    WHERE cv.pace_baseline_percentile IS NOT NULL
      AND (cv.pace_baseline_percentile < 0 OR cv.pace_baseline_percentile > 100)
)
SELECT
    assertions.case_id,
    assertions.validation_area,
    assertions.validation_name,
    assertions.expected_value,
    assertions.actual_value,
    assertions.result,
    assertions.notes
FROM assertions
JOIN case_map
    ON case_map.case_id = assertions.case_id;

-- Suggested run helpers:
-- SELECT * FROM certification_results ORDER BY case_id, validation_area, validation_name;
-- SELECT result, COUNT(*) AS case_count FROM certification_results GROUP BY result ORDER BY result;
