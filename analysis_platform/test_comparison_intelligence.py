#!/usr/bin/env python3
import sqlite3
import unittest
from datetime import datetime, timedelta

from dashboard_app import _segment_behavior_evidence, build_comparison_context, build_longitudinal_behavior_summary, calculate_conditional_baseline, detect_comparison_anomalies, find_similar_activities, render_dashboard


class SimilarActivitiesTests(unittest.TestCase):
    def setUp(self):
        self.connection = sqlite3.connect(":memory:")
        self.connection.row_factory = sqlite3.Row
        self.connection.execute(
            """
            CREATE TABLE activity_review_view (
                activity_id INTEGER,
                activity_start_time TEXT,
                activity_type TEXT,
                activity_name TEXT,
                distance_km REAL,
                workout_type_code TEXT,
                primary_training_purpose_code TEXT,
                avg_power_w INTEGER
            )
            """
        )
        self.connection.execute(
            "CREATE TABLE activity_workout_step (activity_id INTEGER, step_index INTEGER, repeat_steps INTEGER)"
        )
        anchor_time = datetime(2026, 9, 7, 5, 2, 14)
        rows = [
            (254, anchor_time, "Run", "6K Recovery Run", 6.01, "RECOVERY_RUN", "RECOVERY", 217),
            (249, anchor_time - timedelta(days=7), "Run", "6K Recovery Run", 6.01, "RECOVERY_RUN", "RECOVERY", 222),
            (244, anchor_time - timedelta(days=14), "Run", "6K Recovery Run", 6.8, "RECOVERY_RUN", "RECOVERY", None),
            (243, anchor_time - timedelta(days=10), "Run", "6K Recovery Run with Strides", 6.01, "RECOVERY_RUN", "RECOVERY", 230),
            (238, anchor_time - timedelta(days=11), "Run", "6K Easy Run", 6.01, "EASY_RUN", "EASY", 230),
            (242, anchor_time - timedelta(days=21), "Run", "Recovery", 8.0, "RECOVERY_RUN", "RECOVERY", 220),
            (241, anchor_time - timedelta(days=100), "Run", "6K Recovery Run", 6.01, "RECOVERY_RUN", "RECOVERY", 219),
            (240, anchor_time - timedelta(days=28), "Run", "6K Recovery Run", 6.01, "RECOVERY_RUN", "RECOVERY", 218),
            (239, anchor_time - timedelta(days=35), "Run", "6K Recovery Run", 6.01, "RECOVERY_RUN", "RECOVERY", 218),
        ]
        self.connection.executemany(
            "INSERT INTO activity_review_view VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            [(activity_id, start.isoformat(timespec="seconds"), activity_type, name, distance, workout, purpose, power) for activity_id, start, activity_type, name, distance, workout, purpose, power in rows],
        )
        self.connection.executemany(
            "INSERT INTO activity_workout_step VALUES (?, ?, ?)",
            [(243, 1, 1), (243, 2, 1)],
        )

    def tearDown(self):
        self.connection.close()

    def test_context_is_rebuildable_and_versioned(self):
        context = build_comparison_context(self.connection, 254)
        self.assertEqual(context["status"], "ok")
        self.assertEqual(context["comparison_intent"], "longitudinal")
        self.assertEqual(context["rule_version"], "similar-activities-v2")
        self.assertEqual(context["anchor_snapshot"]["distance_km"], 6.01)
        self.assertIn("data_snapshot_reference", context)

    def test_same_type_purpose_and_distance_are_included(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        included_ids = [item["activity_id"] for item in result["included"]]
        self.assertEqual(included_ids, [254, 249, 243, 244, 240, 239])
        self.assertTrue(all(item["match_status"] == "included" for item in result["included"]))

    def test_exclusions_explain_the_failed_rule(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        excluded = {item["activity_id"]: item for item in result["excluded"]}
        self.assertIn(238, excluded)
        self.assertIn(242, excluded)
        self.assertIn(241, excluded)
        self.assertIn("workout_type_code", {item["rule"] for item in excluded[238]["evidence"] if item["status"] == "fail"})
        self.assertIn("distance_tolerance_pct", {item["rule"] for item in excluded[242]["evidence"] if item["status"] == "fail"})
        self.assertIn("lookback", str(excluded[241]["evidence"]))

    def test_structure_is_context_but_does_not_exclude_multi_step_workout(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        included = {item["activity_id"]: item for item in result["included"]}
        self.assertEqual(
            next(item["status"] for item in included[243]["evidence"] if item["rule"] == "segment_structure"),
            "pass",
        )
        self.assertIn(243, included)

    def test_missing_metric_does_not_exclude_activity(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        self.assertIn(244, [item["activity_id"] for item in result["included"]])

    def test_conditional_baseline_uses_included_set_and_linear_percentiles(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        baseline = calculate_conditional_baseline(self.connection, result)
        self.assertEqual(baseline["status"], "ready")
        self.assertEqual(baseline["baseline_rule_version"], "conditional-baseline-v1")
        self.assertEqual(baseline["comparison_set_size"], 6)
        self.assertEqual(baseline["metrics"]["avg_power_w"]["available_count"], 5)
        self.assertEqual(baseline["metrics"]["avg_power_w"]["metric_scope"], "primary_work")
        self.assertEqual(baseline["metrics"]["training_load"]["metric_scope"], "whole_activity")
        self.assertEqual(baseline["metrics"]["avg_power_w"]["sample_count"], 6)
        self.assertAlmostEqual(baseline["metrics"]["avg_power_w"]["median"], 218.0)
        self.assertEqual(baseline["metrics"]["avg_power_w"]["data_completeness"], 5 / 6)

    def test_conditional_baseline_sample_boundary(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        result["included"] = result["included"][:2]
        baseline = calculate_conditional_baseline(self.connection, result)
        self.assertEqual(baseline["status"], "insufficient_baseline")
        self.assertEqual(baseline["metrics"]["avg_power_w"]["status"], "insufficient_data")

    def test_anomaly_detection_keeps_data_context_and_performance_separate(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        baseline = calculate_conditional_baseline(self.connection, result)
        anomalies = detect_comparison_anomalies(result, baseline)
        self.assertEqual(anomalies["status"], "ready")
        self.assertEqual(anomalies["summary"]["context"], "not_assessable")
        activity_244 = next(item for item in anomalies["activities"] if item["activity_id"] == 244)
        power_evidence = [item for item in activity_244["evidence"] if item["metric"] == "avg_power_w"]
        self.assertEqual(next(item for item in power_evidence if item["anomaly_type"] == "data")["status"], "flagged")
        self.assertEqual(next(item for item in power_evidence if item["anomaly_type"] == "performance")["status"], "not_assessable")

    def test_anomaly_detection_uses_tukey_fence_without_requerying(self):
        result = find_similar_activities(self.connection, build_comparison_context(self.connection, 254))
        baseline = calculate_conditional_baseline(self.connection, result)
        result["activity_snapshots"] = [dict(result["activity_snapshots"][0], avg_power_w=999)]
        anomalies = detect_comparison_anomalies(result, baseline)
        power = next(item for item in anomalies["activities"][0]["evidence"] if item["metric"] == "avg_power_w" and item["anomaly_type"] == "performance")
        self.assertEqual(power["status"], "flagged")
        self.assertEqual(power["reason_code"], "outside_tukey_fence")
        self.assertEqual(power["metric_scope"], "primary_work")
        self.assertIn("practical_threshold", power)
        self.assertTrue(power["statistical_flagged"])
        load = next(item for item in anomalies["activities"][0]["evidence"] if item["metric"] == "training_load" and item["anomaly_type"] == "performance")
        self.assertEqual(load["metric_scope"], "whole_activity")

    def test_result_limit_and_tie_break_are_deterministic(self):
        context = build_comparison_context(self.connection, 254)
        context["result_limit"] = 2
        result = find_similar_activities(self.connection, context)
        self.assertEqual([item["activity_id"] for item in result["included"]], [254, 249])
        self.assertTrue(result["truncation"]["truncated"])
        self.assertEqual(result["truncation"]["included_before_limit"], 6)

    def test_missing_anchor_context_is_explicit(self):
        self.connection.execute("UPDATE activity_review_view SET primary_training_purpose_code = NULL WHERE activity_id = 254")
        context = build_comparison_context(self.connection, 254)
        self.assertEqual(context["status"], "insufficient_anchor_context")
        self.assertIn("primary_purpose_code", context["missing_required_fields"])

    def test_compare_page_renders_similar_result_and_handoff(self):
        page = render_dashboard(page="compare", anchor_activity="254")
        self.assertIn("相近活動", page)
        self.assertIn("查看納入依據", page)
        self.assertIn("規則版本", page)
        self.assertIn("AI 延伸分析", page)
        self.assertIn("活動數據比較", page)
        self.assertIn("比較資料提醒", page)

    def test_segment_behavior_separates_same_power_and_last_rep_spike(self):
        snapshot = {
            "segment_metrics": {
                "primary_work": {
                    "first_half": {"status": "ready", "metrics": {"avg_power_w": 235, "avg_hr": 134, "avg_pace_sec_per_km": 400, "avg_gct_ms": 260}},
                    "second_half": {"status": "ready", "metrics": {"avg_power_w": 237, "avg_hr": 140, "avg_pace_sec_per_km": 390, "avg_gct_ms": 262}},
                },
                "strides": {"reps": [
                    {"status": "ready", "metrics": {"avg_pace_sec_per_km": 260, "avg_power_w": 320, "avg_gct_ms": 225}},
                    {"status": "ready", "metrics": {"avg_pace_sec_per_km": 255, "avg_power_w": 325, "avg_gct_ms": 222}},
                    {"status": "ready", "metrics": {"avg_pace_sec_per_km": 258, "avg_power_w": 323, "avg_gct_ms": 224}},
                    {"status": "ready", "metrics": {"avg_pace_sec_per_km": 220, "avg_power_w": 370, "avg_gct_ms": 195}},
                ]},
            }
        }
        behavior = _segment_behavior_evidence(snapshot)
        self.assertEqual(behavior["primary_work"]["comparison"], "same_power_band")
        self.assertEqual(behavior["primary_work"]["execution_pattern"], "stable_power_faster_second_half")
        self.assertEqual(behavior["strides"]["execution_consistency"], "variable")
        self.assertTrue(behavior["strides"]["last_rep_spike"])
        self.assertEqual(behavior["strides"]["intent"], "activation")
        self.assertEqual(behavior["strides"]["role_fit"], "review")
        self.assertEqual(behavior["strides"]["rep_consistency"], "late_acceleration")

    def test_longitudinal_behavior_summary_counts_recent_behavior_without_score(self):
        result = build_longitudinal_behavior_summary({
            "status": "ready",
            "activities": [
                {"behavior": {"primary_work": {"execution_pattern": "stable_power_faster_second_half"}, "strides": {"role_fit": "fits_role", "rep_consistency": "consistent"}}},
                {"behavior": {"primary_work": {"execution_pattern": "higher_power_faster_second_half"}, "strides": {"role_fit": "review", "rep_consistency": "late_acceleration"}}},
            ],
        }, limit=6)
        self.assertEqual(result["status"], "ready")
        self.assertEqual(result["primary_execution_pattern_counts"]["stable_power_faster_second_half"], 1)
        self.assertEqual(result["late_acceleration_count"], 1)
        self.assertNotIn("score", result)

    def test_activity_page_exposes_similar_activities_entry(self):
        page = render_dashboard(page="activity", activity_id="254")
        self.assertIn("找相似活動", page)
        self.assertIn("anchor_activity=254", page)


if __name__ == "__main__":
    unittest.main()
