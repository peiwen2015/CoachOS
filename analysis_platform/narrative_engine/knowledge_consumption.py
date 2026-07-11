from __future__ import annotations

from dataclasses import dataclass


RECOVERY_PLANNED = "PLANNED_RECOVERY"
RECOVERY_REACTIVE = "REACTIVE_RECOVERY"
RECOVERY_FORCED = "FORCED_RECOVERY"
RECOVERY_MAINTENANCE = "MAINTENANCE_WEEK"
RECOVERY_HEAT = "HEAT_RECOVERY"

BUILD_CONTROLLED = "CONTROLLED_BUILD"
BUILD_PROGRESSIVE = "PROGRESSIVE_BUILD"
BUILD_AGGRESSIVE = "AGGRESSIVE_BUILD"
BUILD_OVERLOAD = "OVERLOAD"
BUILD_UNSUSTAINABLE = "UNSUSTAINABLE_BUILD"


@dataclass(frozen=True)
class BuildConsumptionScenario:
    name: str
    recovery_type: str
    load_delta_pct: float
    recovery_completed: bool
    long_run_continuity: bool
    quality_distributed: bool
    weekly_rhythm_stable: bool
    multi_period_direction: str


@dataclass(frozen=True)
class BuildConsumptionResult:
    build_type: str
    explanation: str
    used_recovery_domain: bool
    used_build_domain: bool
    rule_code: str


def evaluate_build_consumption(scenario: BuildConsumptionScenario) -> BuildConsumptionResult:
    """
    Smallest possible engine-consumption slice:
    build interpretation must depend on both recovery context and load-build context.
    """

    if scenario.multi_period_direction == "fragile_rising":
        return BuildConsumptionResult(
            build_type=BUILD_UNSUSTAINABLE,
            explanation="Load is still rising, but the direction is no longer repeatable across periods.",
            used_recovery_domain=False,
            used_build_domain=True,
            rule_code="KC-BLD-001",
        )

    if scenario.recovery_type == RECOVERY_FORCED and scenario.load_delta_pct >= 10:
        return BuildConsumptionResult(
            build_type=BUILD_OVERLOAD,
            explanation="Build cannot be treated as productive because recovery was externally interrupted before load rose again.",
            used_recovery_domain=True,
            used_build_domain=True,
            rule_code="KC-BLD-002",
        )

    if scenario.recovery_type == RECOVERY_REACTIVE and scenario.load_delta_pct >= 15:
        return BuildConsumptionResult(
            build_type=BUILD_OVERLOAD,
            explanation="Stress rose before the prior fatigue signal was truly absorbed.",
            used_recovery_domain=True,
            used_build_domain=True,
            rule_code="KC-BLD-003",
        )

    if (
        scenario.recovery_type in {RECOVERY_PLANNED, RECOVERY_MAINTENANCE, RECOVERY_HEAT}
        and scenario.recovery_completed
        and scenario.long_run_continuity
        and scenario.quality_distributed
        and scenario.weekly_rhythm_stable
        and 10 <= scenario.load_delta_pct <= 25
    ):
        return BuildConsumptionResult(
            build_type=BUILD_CONTROLLED,
            explanation="Recovery has been absorbed and the new load is still arriving in a stable, repeatable structure.",
            used_recovery_domain=True,
            used_build_domain=True,
            rule_code="KC-BLD-004",
        )

    if (
        scenario.recovery_type in {RECOVERY_PLANNED, RECOVERY_MAINTENANCE}
        and scenario.recovery_completed
        and scenario.weekly_rhythm_stable
        and 5 <= scenario.load_delta_pct < 15
        and scenario.multi_period_direction == "rising_gradually"
    ):
        return BuildConsumptionResult(
            build_type=BUILD_PROGRESSIVE,
            explanation="Load is climbing steadily from block to block without forcing abrupt change.",
            used_recovery_domain=True,
            used_build_domain=True,
            rule_code="KC-BLD-005",
        )

    if scenario.load_delta_pct >= 15 and (
        not scenario.recovery_completed
        or not scenario.quality_distributed
        or not scenario.long_run_continuity
    ):
        return BuildConsumptionResult(
            build_type=BUILD_AGGRESSIVE,
            explanation="Stress is still rising, but the recovery or structure margin is getting thin.",
            used_recovery_domain=True,
            used_build_domain=True,
            rule_code="KC-BLD-006",
        )

    return BuildConsumptionResult(
        build_type=BUILD_PROGRESSIVE,
        explanation="Stress is moving forward, but only in a modest and still-manageable way.",
        used_recovery_domain=True,
        used_build_domain=True,
        rule_code="KC-BLD-007",
    )

