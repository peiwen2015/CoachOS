-- CoachOS Similar Workout Comparison Fixture Data v0.1
-- Purpose: minimal fixture set for validating similar workout comparison SQL
-- Status: fixture draft only

PRAGMA foreign_keys = ON;

DELETE FROM activity_training_purpose;
DELETE FROM activity_workout_step;
DELETE FROM activity_workout_split;
DELETE FROM activity_workout_structure;
DELETE FROM activity;
DELETE FROM workout_type;
DELETE FROM training_purpose;
DELETE FROM shoe;

INSERT INTO shoe (
    id, shoe_code, brand, model, nickname, category, size_us, width, drop_mm, weight_g,
    purchase_date, first_run_date, retire_date, retire_target_distance_km, retire_actual_distance_km,
    is_active, notes
) VALUES
    (1, 'shoe-a', 'Nike', 'Pegasus 41', 'Daily', 'daily', 10.5, 'D', 10, 255, '2026-01-01', '2026-01-05', NULL, NULL, NULL, 1, 'primary easy-run shoe'),
    (2, 'shoe-b', 'Asics', 'Metaspeed Edge', 'Tempo', 'quality', 10.5, 'D', 5, 210, '2026-01-02', '2026-01-08', NULL, NULL, NULL, 1, 'faster workout shoe');

INSERT INTO workout_type (
    id, workout_type_code, name_en, name_zh, description, intensity_category,
    is_quality_session, is_long_run, is_recovery_focused, sort_order, display_color
) VALUES
    (1, 'easy_run', 'Easy Run', '輕鬆跑', 'continuous easy run', 'continuous', 0, 0, 0, 10, '#4caf50'),
    (2, 'recovery_run', 'Recovery Run', '恢復跑', 'recovery run', 'continuous', 0, 0, 1, 20, '#8bc34a'),
    (3, 'tempo_run', 'Tempo Run', '節奏跑', 'tempo workout', 'continuous', 1, 0, 0, 30, '#ff9800'),
    (4, 'interval_run', 'Interval', '間歇', 'interval workout', 'interval', 1, 0, 0, 40, '#f44336'),
    (5, 'progression_run', 'Progression Run', '漸速跑', 'progression workout', 'continuous', 1, 0, 0, 50, '#2196f3');

INSERT INTO training_purpose (
    id, training_purpose_code, name_en, name_zh, description, purpose_category,
    is_primary_physiological, is_recovery_related, is_performance_related, sort_order, display_color
) VALUES
    (1, 'aerobic_base', 'Aerobic Base', '有氧基礎', 'easy aerobic development', 'aerobic', 1, 0, 1, 10, '#4caf50'),
    (2, 'recovery', 'Recovery', '恢復', 'recovery and absorption', 'recovery', 0, 1, 0, 20, '#8bc34a'),
    (3, 'tempo', 'Tempo', '節奏', 'threshold / tempo development', 'quality', 1, 0, 1, 30, '#ff9800'),
    (4, 'interval', 'Interval', '間歇', 'interval development', 'quality', 1, 0, 1, 40, '#f44336');

INSERT INTO activity (
    id, fit_sha256, garmin_activity_id, excel_schema_version, source_file_name, data_source,
    activity_start_time, activity_type, activity_name, distance_km, duration_sec, workout_type_id, shoe_id,
    temperature_c, humidity_pct, wind_speed_mps, wind_direction_deg, weather_description,
    max_hr, avg_hr, avg_power_w, critical_power_w, training_effect_aerobic, training_effect_anaerobic,
    training_load, recovery_time_hr, stamina_start_pct, stamina_end_pct,
    avg_cadence_spm, avg_stride_length_mm, avg_gct_ms, avg_vertical_oscillation_mm, avg_vertical_ratio_pct,
    garmin_feeling, garmin_perceived_effort, nutrition, notes, start_latitude, start_longitude, end_latitude, end_longitude
) VALUES
    (101, 'sha-e01', 1001, 'v1', 'E01.fit', 'FIT', '2026-01-02T06:00:00', 'running', 'E01 Easy 8.0K', 8.00, 2400, 1, 1, 24.0, 70.0, 2.0, 180.0, 'clear', 152, 138, 234, 240, 3.0, 1.0, 132, 12.0, 96, 72, 176, 1030, 245, 88, 6.4, 'good', 'moderate', 'none', 'baseline easy run', 25.0330, 121.5654, 25.0340, 121.5660),
    (102, 'sha-e02', 1002, 'v1', 'E02.fit', 'FIT', '2026-01-05T06:00:00', 'running', 'E02 Easy 7.8K', 7.80, 2340, 1, 1, 25.0, 72.0, 2.0, 180.0, 'clear', 151, 137, 232, 240, 3.0, 1.0, 128, 11.0, 97, 73, 175, 1028, 244, 87, 6.5, 'good', 'moderate', 'none', 'within distance tolerance', 25.0330, 121.5654, 25.0340, 121.5660),
    (103, 'sha-e03', 1003, 'v1', 'E03.fit', 'FIT', '2026-01-08T06:00:00', 'running', 'E03 Easy 8.8K', 8.80, 2673, 1, 1, 26.0, 74.0, 2.5, 180.0, 'clear', 154, 140, 236, 241, 3.1, 1.0, 138, 12.5, 98, 74, 176, 1032, 246, 89, 6.4, 'good', 'moderate', 'none', 'upper distance boundary', 25.0330, 121.5654, 25.0340, 121.5660),
    (104, 'sha-e04', 1004, 'v1', 'E04.fit', 'FIT', '2026-01-11T06:00:00', 'running', 'E04 Easy 8.81K', 8.81, 2676, 1, 1, 26.0, 74.0, 2.5, 180.0, 'clear', 154, 140, 236, 241, 3.1, 1.0, 138, 12.5, 98, 74, 176, 1032, 246, 89, 6.4, 'good', 'moderate', 'none', 'outside tolerance', 25.0330, 121.5654, 25.0340, 121.5660),
    (105, 'sha-e05', 1005, 'v1', 'E05.fit', 'FIT', '2026-01-14T06:00:00', 'running', 'E05 Easy + Strides', 8.00, 2435, 1, 1, 25.0, 73.0, 2.0, 180.0, 'clear', 156, 141, 238, 242, 3.2, 1.0, 140, 12.0, 97, 74, 177, 1030, 247, 90, 6.3, 'good', 'moderate', 'none', 'contains strides', 25.0330, 121.5654, 25.0340, 121.5660),
    (106, 'sha-e06', 1006, 'v1', 'E06.fit', 'FIT', '2026-01-17T06:00:00', 'running', 'E06 Progression', 8.00, 2450, 5, 1, 25.0, 73.0, 2.0, 180.0, 'clear', 158, 142, 240, 243, 3.3, 1.1, 145, 12.0, 97, 73, 176, 1030, 246, 90, 6.3, 'good', 'moderate', 'none', 'progression session', 25.0330, 121.5654, 25.0340, 121.5660),
    (107, 'sha-e07', 1007, 'v1', 'E07.fit', 'FIT', '2026-01-20T06:00:00', 'running', 'E07 Fast Finish', 8.00, 2390, 1, 1, 26.0, 74.0, 2.0, 180.0, 'clear', 159, 141, 239, 242, 3.1, 1.0, 139, 12.0, 97, 73, 176, 1030, 246, 90, 6.3, 'good', 'moderate', 'none', 'fast finish runner', 25.0330, 121.5654, 25.0340, 121.5660),
    (108, 'sha-e08', 1008, 'v1', 'E08.fit', 'FIT', '2026-01-23T06:00:00', 'running', 'E08 Easy no power', 8.00, 2410, 1, 1, 24.5, 71.0, 2.0, 180.0, 'clear', 153, 139, NULL, 241, 3.0, 1.0, 133, 12.0, 96, 72, 176, 1030, 245, 88, 6.4, 'good', 'moderate', 'none', 'missing activity power', 25.0330, 121.5654, 25.0340, 121.5660),
    (109, 'sha-e09', 1009, 'v1', 'E09.fit', 'FIT', '2026-01-26T06:00:00', 'running', 'E09 Easy different power source', 8.00, 2420, 1, 2, 24.0, 70.0, 2.0, 180.0, 'clear', 154, 139, 231, 241, 3.0, 1.0, 134, 12.0, 96, 72, 176, 1030, 245, 88, 6.4, 'good', 'moderate', 'none', 'different power source case [power_origin:estimated] [power_source_system:stryd] [power_measurement_method:external_sensor]', 25.0330, 121.5654, 25.0340, 121.5660),
    (110, 'sha-e10', 1010, 'v1', 'E10.fit', 'FIT', '2026-01-29T06:00:00', 'running', 'E10 Easy hot', 8.00, 2445, 1, 1, 31.5, 78.0, 2.0, 180.0, 'hot', 160, 144, 238, 242, 3.1, 1.1, 141, 13.0, 97, 72, 176, 1030, 245, 88, 6.4, 'good', 'moderate', 'none', 'high temperature note', 25.0330, 121.5654, 25.0340, 121.5660),

    (111, 'sha-r1', 1011, 'v1', 'R1.fit', 'FIT', '2026-02-02T06:00:00', 'running', 'R1 Recovery', 5.00, 1800, 2, 1, 23.0, 68.0, 1.5, 180.0, 'clear', 140, 128, 198, 220, 2.0, 0.0, 72, 8.0, 98, 82, 174, 1018, 242, 87, 6.6, 'good', 'easy', 'none', 'recovery sample 1', 25.0330, 121.5654, 25.0340, 121.5660),
    (112, 'sha-r2', 1012, 'v1', 'R2.fit', 'FIT', '2026-02-05T06:00:00', 'running', 'R2 Recovery', 5.10, 1830, 2, 1, 24.0, 69.0, 1.5, 180.0, 'clear', 141, 129, 199, 221, 2.0, 0.0, 74, 8.0, 98, 82, 174, 1018, 242, 87, 6.6, 'good', 'easy', 'none', 'recovery sample 2', 25.0330, 121.5654, 25.0340, 121.5660),
    (113, 'sha-r3', 1013, 'v1', 'R3.fit', 'FIT', '2026-02-08T06:00:00', 'running', 'R3 Recovery', 5.20, 1860, 2, 1, 25.0, 70.0, 1.5, 180.0, 'clear', 142, 130, 201, 222, 2.1, 0.0, 76, 8.0, 98, 82, 174, 1018, 242, 87, 6.6, 'good', 'easy', 'none', 'recovery sample 3', 25.0330, 121.5654, 25.0340, 121.5660),
    (114, 'sha-r4', 1014, 'v1', 'R4.fit', 'FIT', '2026-02-11T06:00:00', 'running', 'R4 Recovery', 5.20, 1865, 2, 1, 25.0, 70.0, 1.5, 180.0, 'clear', 143, 130, 202, 223, 2.1, 0.0, 78, 8.0, 98, 82, 174, 1018, 242, 87, 6.6, 'good', 'easy', 'none', 'recovery sample 4', 25.0330, 121.5654, 25.0340, 121.5660),

    (115, 'sha-t1', 1015, 'v1', 'T1.fit', 'FIT', '2026-02-15T06:00:00', 'running', 'T1 Tempo', 10.00, 3000, 3, 2, 24.0, 68.0, 2.0, 180.0, 'clear', 168, 150, 250, 245, 3.8, 2.0, 165, 14.0, 95, 78, 178, 1040, 248, 90, 6.1, 'good', 'hard', 'none', 'tempo with main segment', 25.0330, 121.5654, 25.0340, 121.5660),
    (116, 'sha-t2', 1016, 'v1', 'T2.fit', 'FIT', '2026-02-18T06:00:00', 'running', 'T2 Tempo missing structure', 10.20, 3060, 3, 2, 24.0, 68.0, 2.0, 180.0, 'clear', 169, 151, 251, 246, 3.8, 2.0, 166, 14.0, 95, 78, 178, 1040, 248, 90, 6.1, 'good', 'hard', 'none', 'tempo missing structure rows', 25.0330, 121.5654, 25.0340, 121.5660),
    (117, 'sha-i1', 1017, 'v1', 'I1.fit', 'FIT', '2026-02-22T06:00:00', 'running', 'I1 Interval', 9.00, 2700, 4, 2, 23.5, 67.0, 2.0, 180.0, 'clear', 172, 152, 256, 247, 4.0, 2.2, 178, 15.0, 94, 76, 180, 1042, 250, 91, 6.0, 'good', 'hard', 'none', 'interval 4x1k', 25.0330, 121.5654, 25.0340, 121.5660),
    (118, 'sha-i2', 1018, 'v1', 'I2.fit', 'FIT', '2026-02-25T06:00:00', 'running', 'I2 Interval missing one rep', 8.00, 2550, 4, 2, 23.5, 67.0, 2.0, 180.0, 'clear', 171, 153, 255, 247, 4.0, 2.1, 176, 15.0, 94, 76, 180, 1042, 250, 91, 6.0, 'good', 'hard', 'none', 'interval with one missing rep', 25.0330, 121.5654, 25.0340, 121.5660);

INSERT INTO activity_training_purpose (
    id, activity_id, training_purpose_id, purpose_role
) VALUES
    (1001, 101, 1, 'PRIMARY'),
    (1002, 102, 1, 'PRIMARY'),
    (1003, 103, 1, 'PRIMARY'),
    (1004, 104, 1, 'PRIMARY'),
    (1005, 105, 1, 'PRIMARY'),
    (1006, 106, 1, 'PRIMARY'),
    (1007, 107, 1, 'PRIMARY'),
    (1008, 108, 1, 'PRIMARY'),
    (1009, 109, 1, 'PRIMARY'),
    (1010, 110, 1, 'PRIMARY'),
    (1011, 111, 2, 'PRIMARY'),
    (1012, 112, 2, 'PRIMARY'),
    (1013, 113, 2, 'PRIMARY'),
    (1014, 114, 2, 'PRIMARY'),
    (1015, 115, 3, 'PRIMARY'),
    (1016, 116, 3, 'PRIMARY'),
    (1017, 117, 4, 'PRIMARY'),
    (1018, 118, 4, 'PRIMARY');

INSERT INTO activity_workout_structure (
    activity_id, has_workout_structure, source, sport, sub_sport, workout_name, workout_description, num_valid_steps
) VALUES
    (101, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (102, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (103, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (104, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (105, 1, 'fit', 'running', 'road', 'Easy + Strides', 'easy run with strides', 2),
    (106, 1, 'fit', 'running', 'road', 'Progression', 'progression run', 3),
    (107, 1, 'fit', 'running', 'road', 'Fast Finish', 'easy run with fast finish', 2),
    (108, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (109, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (110, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (111, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (112, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (113, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (114, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (115, 1, 'fit', 'running', 'road', 'Tempo', 'WU + main + CD', 3),
    (116, 0, 'fit', 'running', 'road', NULL, NULL, NULL),
    (117, 1, 'fit', 'running', 'road', 'Interval', '4 x 1K', 4),
    (118, 1, 'fit', 'running', 'road', 'Interval', '3 x 1K incomplete', 3);

INSERT INTO activity_workout_step (
    id, activity_id, step_index, source_message_index, intensity, duration_type, duration_value,
    duration_distance_m, duration_time_sec, target_type, target_value, target_value_low, target_value_high,
    target_hr_zone, repeat_steps, secondary_target_value, custom_target_value_low, custom_target_value_high
) VALUES
    (2001, 115, 1, 1, 'warmup', 'distance', 2000, 2000, NULL, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2002, 115, 2, 2, 'tempo', 'distance', 6000, 6000, NULL, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2003, 115, 3, 3, 'cooldown', 'distance', 2000, 2000, NULL, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2004, 117, 1, 1, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL),
    (2005, 117, 2, 2, 'recovery', 'time', 300, NULL, 300, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2006, 117, 3, 3, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL),
    (2007, 117, 4, 4, 'recovery', 'time', 300, NULL, 300, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2008, 117, 5, 5, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL),
    (2009, 117, 6, 6, 'recovery', 'time', 300, NULL, 300, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2010, 117, 7, 7, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL),
    (2011, 118, 1, 1, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL),
    (2012, 118, 2, 2, 'recovery', 'time', 300, NULL, 300, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2013, 118, 3, 3, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL),
    (2014, 118, 4, 4, 'recovery', 'time', 300, NULL, 300, 'pace', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2015, 118, 5, 5, 'work', 'distance', 1000, 1000, NULL, 'pace', NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL);

INSERT INTO activity_workout_split (
    id, activity_id, split_index, source_message_index, split_type, num_splits,
    total_distance_m, total_timer_time_sec, avg_speed_mps, sport, sub_sport
) VALUES
    (3001, 115, 1, 1, 'work', 3, 2000, 620, 3.226, 'running', 'road'),
    (3002, 115, 2, 2, 'work', 3, 2000, 600, 3.333, 'running', 'road'),
    (3003, 115, 3, 3, 'work', 3, 6000, 1780, 3.371, 'running', 'road'),
    (3004, 117, 1, 1, 'work', 4, 1000, 310, 3.226, 'running', 'road'),
    (3005, 117, 2, 2, 'recovery', 4, 300, 120, 2.500, 'running', 'road'),
    (3006, 117, 3, 3, 'work', 4, 1000, 308, 3.247, 'running', 'road'),
    (3007, 117, 4, 4, 'recovery', 4, 300, 120, 2.500, 'running', 'road'),
    (3008, 117, 5, 5, 'work', 4, 1000, 306, 3.268, 'running', 'road'),
    (3009, 117, 6, 6, 'recovery', 4, 300, 120, 2.500, 'running', 'road'),
    (3010, 117, 7, 7, 'work', 4, 1000, 304, 3.289, 'running', 'road'),
    (3011, 118, 1, 1, 'work', 3, 1000, 312, 3.205, 'running', 'road'),
    (3012, 118, 2, 2, 'recovery', 3, 300, 120, 2.500, 'running', 'road'),
    (3013, 118, 3, 3, 'work', 3, 1000, 315, 3.175, 'running', 'road'),
    (3014, 118, 4, 4, 'recovery', 3, 300, 120, 2.500, 'running', 'road'),
    (3015, 118, 5, 5, 'work', 3, 1000, 318, 3.145, 'running', 'road'),
    (3016, 101, 1, 1, 'km', 8, 1000, 375, 2.667, 'running', 'road'),
    (3017, 101, 2, 2, 'km', 8, 1000, 370, 2.703, 'running', 'road'),
    (3018, 101, 3, 3, 'km', 8, 1000, 366, 2.732, 'running', 'road'),
    (3019, 101, 4, 4, 'km', 8, 1000, 361, 2.770, 'running', 'road'),
    (3020, 101, 5, 5, 'km', 8, 1000, 357, 2.801, 'running', 'road'),
    (3021, 101, 6, 6, 'km', 8, 1000, 352, 2.841, 'running', 'road'),
    (3022, 101, 7, 7, 'km', 8, 1000, 348, 2.874, 'running', 'road'),
    (3023, 101, 8, 8, 'km', 8, 1000, 344, 2.907, 'running', 'road'),
    (3024, 102, 1, 1, 'km', 8, 1000, 378, 2.646, 'running', 'road'),
    (3025, 102, 2, 2, 'km', 8, 1000, 372, 2.688, 'running', 'road'),
    (3026, 102, 3, 3, 'km', 8, 1000, 368, 2.717, 'running', 'road'),
    (3027, 102, 4, 4, 'km', 8, 1000, 364, 2.747, 'running', 'road'),
    (3028, 102, 5, 5, 'km', 8, 1000, 359, 2.786, 'running', 'road'),
    (3029, 102, 6, 6, 'km', 8, 1000, 355, 2.817, 'running', 'road'),
    (3030, 102, 7, 7, 'km', 8, 1000, 350, 2.857, 'running', 'road'),
    (3031, 102, 8, 8, 'km', 8, 800, 295, 2.712, 'running', 'road'),
    (3032, 103, 1, 1, 'km', 9, 1000, 380, 2.632, 'running', 'road'),
    (3033, 103, 2, 2, 'km', 9, 1000, 375, 2.667, 'running', 'road'),
    (3034, 103, 3, 3, 'km', 9, 1000, 370, 2.703, 'running', 'road'),
    (3035, 103, 4, 4, 'km', 9, 1000, 366, 2.732, 'running', 'road'),
    (3036, 103, 5, 5, 'km', 9, 1000, 362, 2.762, 'running', 'road'),
    (3037, 103, 6, 6, 'km', 9, 1000, 358, 2.793, 'running', 'road'),
    (3038, 103, 7, 7, 'km', 9, 1000, 354, 2.824, 'running', 'road'),
    (3039, 103, 8, 8, 'km', 9, 1000, 350, 2.857, 'running', 'road'),
    (3040, 103, 9, 9, 'km', 9, 800, 288, 2.778, 'running', 'road'),
    (3041, 104, 1, 1, 'km', 9, 1000, 380, 2.632, 'running', 'road'),
    (3042, 104, 2, 2, 'km', 9, 1000, 375, 2.667, 'running', 'road'),
    (3043, 104, 3, 3, 'km', 9, 1000, 370, 2.703, 'running', 'road'),
    (3044, 104, 4, 4, 'km', 9, 1000, 366, 2.732, 'running', 'road'),
    (3045, 104, 5, 5, 'km', 9, 1000, 362, 2.762, 'running', 'road'),
    (3046, 104, 6, 6, 'km', 9, 1000, 358, 2.793, 'running', 'road'),
    (3047, 104, 7, 7, 'km', 9, 1000, 354, 2.824, 'running', 'road'),
    (3048, 104, 8, 8, 'km', 9, 1000, 350, 2.857, 'running', 'road'),
    (3049, 104, 9, 9, 'km', 9, 810, 289, 2.803, 'running', 'road'),
    (3050, 105, 1, 1, 'km', 8, 1000, 375, 2.667, 'running', 'road'),
    (3051, 105, 2, 2, 'km', 8, 1000, 370, 2.703, 'running', 'road'),
    (3052, 105, 3, 3, 'km', 8, 1000, 366, 2.732, 'running', 'road'),
    (3053, 105, 4, 4, 'km', 8, 1000, 361, 2.770, 'running', 'road'),
    (3054, 105, 5, 5, 'km', 8, 1000, 357, 2.801, 'running', 'road'),
    (3055, 105, 6, 6, 'km', 8, 1000, 352, 2.841, 'running', 'road'),
    (3056, 105, 7, 7, 'km', 8, 1000, 348, 2.874, 'running', 'road'),
    (3057, 105, 8, 8, 'km', 8, 1000, 344, 2.907, 'running', 'road'),
    (3058, 106, 1, 1, 'km', 8, 1000, 374, 2.674, 'running', 'road'),
    (3059, 106, 2, 2, 'km', 8, 1000, 368, 2.717, 'running', 'road'),
    (3060, 106, 3, 3, 'km', 8, 1000, 363, 2.755, 'running', 'road'),
    (3061, 106, 4, 4, 'km', 8, 1000, 358, 2.793, 'running', 'road'),
    (3062, 106, 5, 5, 'km', 8, 1000, 354, 2.824, 'running', 'road'),
    (3063, 106, 6, 6, 'km', 8, 1000, 350, 2.857, 'running', 'road'),
    (3064, 106, 7, 7, 'km', 8, 1000, 345, 2.899, 'running', 'road'),
    (3065, 106, 8, 8, 'km', 8, 1000, 341, 2.933, 'running', 'road'),
    (3066, 107, 1, 1, 'km', 8, 1000, 376, 2.660, 'running', 'road'),
    (3067, 107, 2, 2, 'km', 8, 1000, 371, 2.695, 'running', 'road'),
    (3068, 107, 3, 3, 'km', 8, 1000, 366, 2.732, 'running', 'road'),
    (3069, 107, 4, 4, 'km', 8, 1000, 360, 2.778, 'running', 'road'),
    (3070, 107, 5, 5, 'km', 8, 1000, 355, 2.817, 'running', 'road'),
    (3071, 107, 6, 6, 'km', 8, 1000, 350, 2.857, 'running', 'road'),
    (3072, 107, 7, 7, 'km', 8, 1000, 346, 2.890, 'running', 'road'),
    (3073, 107, 8, 8, 'km', 8, 1000, 342, 2.924, 'running', 'road'),
    (3074, 108, 1, 1, 'km', 8, 1000, 375, 2.667, 'running', 'road'),
    (3075, 108, 2, 2, 'km', 8, 1000, 370, 2.703, 'running', 'road'),
    (3076, 108, 3, 3, 'km', 8, 1000, 366, 2.732, 'running', 'road'),
    (3077, 108, 4, 4, 'km', 8, 1000, 361, 2.770, 'running', 'road'),
    (3078, 108, 5, 5, 'km', 8, 1000, 357, 2.801, 'running', 'road'),
    (3079, 108, 6, 6, 'km', 8, 1000, 352, 2.841, 'running', 'road'),
    (3080, 108, 7, 7, 'km', 8, 1000, 348, 2.874, 'running', 'road'),
    (3081, 108, 8, 8, 'km', 8, 1000, 344, 2.907, 'running', 'road'),
    (3082, 109, 1, 1, 'km', 8, 1000, 375, 2.667, 'running', 'road'),
    (3083, 109, 2, 2, 'km', 8, 1000, 370, 2.703, 'running', 'road'),
    (3084, 109, 3, 3, 'km', 8, 1000, 366, 2.732, 'running', 'road'),
    (3085, 109, 4, 4, 'km', 8, 1000, 361, 2.770, 'running', 'road'),
    (3086, 109, 5, 5, 'km', 8, 1000, 357, 2.801, 'running', 'road'),
    (3087, 109, 6, 6, 'km', 8, 1000, 352, 2.841, 'running', 'road'),
    (3088, 109, 7, 7, 'km', 8, 1000, 348, 2.874, 'running', 'road'),
    (3089, 109, 8, 8, 'km', 8, 1000, 344, 2.907, 'running', 'road'),
    (3090, 110, 1, 1, 'km', 8, 1000, 375, 2.667, 'running', 'road'),
    (3091, 110, 2, 2, 'km', 8, 1000, 370, 2.703, 'running', 'road'),
    (3092, 110, 3, 3, 'km', 8, 1000, 366, 2.732, 'running', 'road'),
    (3093, 110, 4, 4, 'km', 8, 1000, 361, 2.770, 'running', 'road'),
    (3094, 110, 5, 5, 'km', 8, 1000, 357, 2.801, 'running', 'road'),
    (3095, 110, 6, 6, 'km', 8, 1000, 352, 2.841, 'running', 'road'),
    (3096, 110, 7, 7, 'km', 8, 1000, 348, 2.874, 'running', 'road'),
    (3097, 110, 8, 8, 'km', 8, 1000, 344, 2.907, 'running', 'road'),
    (3098, 110, 9, 9, 'tail', 9, 11, 5, 2.200, 'running', 'road'),
    (3099, 111, 1, 1, 'km', 5, 1000, 370, 2.703, 'running', 'road'),
    (3100, 111, 2, 2, 'km', 5, 1000, 368, 2.717, 'running', 'road'),
    (3101, 111, 3, 3, 'km', 5, 1000, 366, 2.732, 'running', 'road'),
    (3102, 111, 4, 4, 'km', 5, 1000, 365, 2.740, 'running', 'road'),
    (3103, 111, 5, 5, 'km', 5, 1000, 364, 2.747, 'running', 'road'),
    (3104, 112, 1, 1, 'km', 5, 1000, 369, 2.710, 'running', 'road'),
    (3105, 112, 2, 2, 'km', 5, 1000, 367, 2.724, 'running', 'road'),
    (3106, 112, 3, 3, 'km', 5, 1000, 365, 2.740, 'running', 'road'),
    (3107, 112, 4, 4, 'km', 5, 1000, 364, 2.747, 'running', 'road'),
    (3108, 112, 5, 5, 'km', 5, 1000, 363, 2.755, 'running', 'road'),
    (3109, 113, 1, 1, 'km', 5, 1000, 368, 2.717, 'running', 'road'),
    (3110, 113, 2, 2, 'km', 5, 1000, 366, 2.732, 'running', 'road'),
    (3111, 113, 3, 3, 'km', 5, 1000, 365, 2.740, 'running', 'road'),
    (3112, 113, 4, 4, 'km', 5, 1000, 364, 2.747, 'running', 'road'),
    (3113, 113, 5, 5, 'km', 5, 1000, 363, 2.755, 'running', 'road'),
    (3114, 114, 1, 1, 'km', 5, 1000, 367, 2.724, 'running', 'road'),
    (3115, 114, 2, 2, 'km', 5, 1000, 366, 2.732, 'running', 'road'),
    (3116, 114, 3, 3, 'km', 5, 1000, 365, 2.740, 'running', 'road'),
    (3117, 114, 4, 4, 'km', 5, 1000, 364, 2.747, 'running', 'road'),
    (3118, 114, 5, 5, 'km', 5, 1000, 363, 2.755, 'running', 'road');
