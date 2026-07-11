from __future__ import annotations

import unittest

from .knowledge_consumption import (
    BUILD_AGGRESSIVE,
    BUILD_CONTROLLED,
    BUILD_OVERLOAD,
    BUILD_PROGRESSIVE,
    BUILD_UNSUSTAINABLE,
    RECOVERY_FORCED,
    RECOVERY_MAINTENANCE,
    RECOVERY_PLANNED,
    RECOVERY_REACTIVE,
    BuildConsumptionScenario,
    evaluate_build_consumption,
)


class KnowledgeConsumptionTests(unittest.TestCase):
    def test_controlled_build_requires_recovery_completion(self) -> None:
        scenario = BuildConsumptionScenario(
            name="controlled",
            recovery_type=RECOVERY_PLANNED,
            load_delta_pct=15.0,
            recovery_completed=True,
            long_run_continuity=True,
            quality_distributed=True,
            weekly_rhythm_stable=True,
            multi_period_direction="stable_rising",
        )
        result = evaluate_build_consumption(scenario)
        self.assertEqual(result.build_type, BUILD_CONTROLLED)
        self.assertTrue(result.used_recovery_domain)
        self.assertTrue(result.used_build_domain)

    def test_same_load_becomes_overload_when_recovery_was_reactive(self) -> None:
        scenario = BuildConsumptionScenario(
            name="reactive-overload",
            recovery_type=RECOVERY_REACTIVE,
            load_delta_pct=15.0,
            recovery_completed=False,
            long_run_continuity=True,
            quality_distributed=True,
            weekly_rhythm_stable=True,
            multi_period_direction="stable_rising",
        )
        result = evaluate_build_consumption(scenario)
        self.assertEqual(result.build_type, BUILD_OVERLOAD)

    def test_forced_recovery_plus_rising_load_is_not_productive_build(self) -> None:
        scenario = BuildConsumptionScenario(
            name="forced-overload",
            recovery_type=RECOVERY_FORCED,
            load_delta_pct=20.0,
            recovery_completed=False,
            long_run_continuity=False,
            quality_distributed=False,
            weekly_rhythm_stable=False,
            multi_period_direction="stable_rising",
        )
        result = evaluate_build_consumption(scenario)
        self.assertEqual(result.build_type, BUILD_OVERLOAD)

    def test_gradual_rise_after_maintenance_reads_as_progressive(self) -> None:
        scenario = BuildConsumptionScenario(
            name="progressive",
            recovery_type=RECOVERY_MAINTENANCE,
            load_delta_pct=9.0,
            recovery_completed=True,
            long_run_continuity=True,
            quality_distributed=True,
            weekly_rhythm_stable=True,
            multi_period_direction="rising_gradually",
        )
        result = evaluate_build_consumption(scenario)
        self.assertEqual(result.build_type, BUILD_PROGRESSIVE)

    def test_same_load_can_be_aggressive_when_structure_breaks(self) -> None:
        scenario = BuildConsumptionScenario(
            name="aggressive",
            recovery_type=RECOVERY_PLANNED,
            load_delta_pct=22.0,
            recovery_completed=False,
            long_run_continuity=False,
            quality_distributed=False,
            weekly_rhythm_stable=False,
            multi_period_direction="stable_rising",
        )
        result = evaluate_build_consumption(scenario)
        self.assertEqual(result.build_type, BUILD_AGGRESSIVE)

    def test_fragile_rising_direction_becomes_unsustainable(self) -> None:
        scenario = BuildConsumptionScenario(
            name="unsustainable",
            recovery_type=RECOVERY_MAINTENANCE,
            load_delta_pct=18.0,
            recovery_completed=True,
            long_run_continuity=True,
            quality_distributed=True,
            weekly_rhythm_stable=True,
            multi_period_direction="fragile_rising",
        )
        result = evaluate_build_consumption(scenario)
        self.assertEqual(result.build_type, BUILD_UNSUSTAINABLE)


if __name__ == "__main__":
    unittest.main()
