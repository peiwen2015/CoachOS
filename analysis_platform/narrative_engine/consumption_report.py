from __future__ import annotations

import sys
from pathlib import Path

from .knowledge_consumption import (
    RECOVERY_FORCED,
    RECOVERY_MAINTENANCE,
    RECOVERY_PLANNED,
    RECOVERY_REACTIVE,
    BuildConsumptionScenario,
    evaluate_build_consumption,
)


SCENARIOS: tuple[BuildConsumptionScenario, ...] = (
    BuildConsumptionScenario(
        name="Scenario 1",
        recovery_type=RECOVERY_PLANNED,
        load_delta_pct=15.0,
        recovery_completed=True,
        long_run_continuity=True,
        quality_distributed=True,
        weekly_rhythm_stable=True,
        multi_period_direction="stable_rising",
    ),
    BuildConsumptionScenario(
        name="Scenario 2",
        recovery_type=RECOVERY_REACTIVE,
        load_delta_pct=15.0,
        recovery_completed=False,
        long_run_continuity=True,
        quality_distributed=True,
        weekly_rhythm_stable=True,
        multi_period_direction="stable_rising",
    ),
    BuildConsumptionScenario(
        name="Scenario 3",
        recovery_type=RECOVERY_FORCED,
        load_delta_pct=20.0,
        recovery_completed=False,
        long_run_continuity=False,
        quality_distributed=False,
        weekly_rhythm_stable=False,
        multi_period_direction="stable_rising",
    ),
    BuildConsumptionScenario(
        name="Scenario 4",
        recovery_type=RECOVERY_MAINTENANCE,
        load_delta_pct=9.0,
        recovery_completed=True,
        long_run_continuity=True,
        quality_distributed=True,
        weekly_rhythm_stable=True,
        multi_period_direction="rising_gradually",
    ),
    BuildConsumptionScenario(
        name="Scenario 5",
        recovery_type=RECOVERY_PLANNED,
        load_delta_pct=22.0,
        recovery_completed=False,
        long_run_continuity=False,
        quality_distributed=False,
        weekly_rhythm_stable=False,
        multi_period_direction="stable_rising",
    ),
    BuildConsumptionScenario(
        name="Scenario 6",
        recovery_type=RECOVERY_MAINTENANCE,
        load_delta_pct=18.0,
        recovery_completed=True,
        long_run_continuity=True,
        quality_distributed=True,
        weekly_rhythm_stable=True,
        multi_period_direction="fragile_rising",
    ),
)


def generate_consumption_report() -> str:
    lines: list[str] = []
    lines.append("# Engine Consumption Report v0.1")
    lines.append("")
    lines.append("This report proves the first minimal Narrative Engine consumption slice for Recovery + Load Build.")
    lines.append("")
    lines.append("| Scenario | Recovery Domain Input | Build Inputs | Engine Output | Rule | Domain Consumption |")
    lines.append("|---|---|---|---|---|---|")
    for scenario in SCENARIOS:
        result = evaluate_build_consumption(scenario)
        build_inputs = (
            f"load={scenario.load_delta_pct:+.0f}%"
            f"; recovery_completed={scenario.recovery_completed}"
            f"; long_run_continuity={scenario.long_run_continuity}"
            f"; quality_distributed={scenario.quality_distributed}"
            f"; rhythm_stable={scenario.weekly_rhythm_stable}"
            f"; multi_period={scenario.multi_period_direction}"
        )
        domain_use = "recovery + build" if result.used_recovery_domain and result.used_build_domain else "build only"
        lines.append(
            f"| {scenario.name} | {scenario.recovery_type} | {build_inputs} | "
            f"{result.build_type}<br>{result.explanation} | {result.rule_code} | {domain_use} |"
        )
    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append("- This is a minimal executable proof, not a full production rule set.")
    lines.append("- The goal is to show that build interpretation changes when recovery knowledge changes.")
    lines.append("- New knowledge domains should only be added after current domains fail to explain observed scenarios.")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    report = generate_consumption_report()
    if len(argv) >= 2:
        Path(argv[1]).write_text(report, encoding="utf-8")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
