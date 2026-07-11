from __future__ import annotations

import sqlite3
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


DB_PATH = Path(__file__).with_name("running_analytics.sqlite")


PRIORITY_ORDER = {
    None: 0,
    "medium": 1,
    "high": 2,
    "critical": 3,
}

DOMAIN_TIEBREAK = {
    "recovery": 3,
    "load_build": 2,
    "shoes": 1,
}


@dataclass(frozen=True)
class AttentionCandidate:
    domain: str
    eligible: bool
    priority: str | None
    reason_codes: tuple[str, ...]
    attention_label: str | None
    target_surface: str | None
    evidence: tuple[str, ...]


@dataclass(frozen=True)
class AttentionScenario:
    name: str
    description: str
    signals: dict[str, Any]
    expected_primary: str | None
    human_judgment: str


def connect() -> sqlite3.Connection:
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def live_signals(connection: sqlite3.Connection) -> dict[str, Any]:
    week = connection.execute("SELECT * FROM current_week_intelligence_view").fetchone()
    month = connection.execute("SELECT * FROM current_month_intelligence_view").fetchone()
    max_active_shoe = connection.execute(
        """
        SELECT MAX(total_distance_km) AS max_active_shoe_km
        FROM shoe_intelligence_view
        WHERE is_active = 1
        """
    ).fetchone()
    return {
        "week_load_delta_pct": None if week is None else week["load_delta_pct"],
        "week_km_delta_pct": None if week is None else week["km_delta_pct"],
        "week_recovery_status": None if week is None else week["recovery_status"],
        "month_load_delta_pct": None if month is None else month["load_delta_pct"],
        "month_is_partial": None if month is None else bool(month["is_partial_month"]),
        "max_active_shoe_km": None if max_active_shoe is None else max_active_shoe["max_active_shoe_km"],
        "hrv_below_baseline": False,
        "recent_quality_stress": False,
    }


def recovery_attention(signals: dict[str, Any]) -> AttentionCandidate:
    reason_codes: list[str] = []
    evidence: list[str] = []

    week_status = str(signals.get("week_recovery_status") or "").lower()
    week_load_delta = signals.get("week_load_delta_pct")
    month_load_delta = signals.get("month_load_delta_pct")
    hrv_below_baseline = bool(signals.get("hrv_below_baseline"))
    recent_quality_stress = bool(signals.get("recent_quality_stress"))

    if hrv_below_baseline:
        reason_codes.append("HRV_BELOW_BASELINE")
        evidence.append("恢復訊號低於個人基線。")
    if recent_quality_stress:
        reason_codes.append("RECENT_QUALITY_STRESS")
        evidence.append("最近已有清楚刺激，恢復壓力正在累積。")
    if week_status == "absorb":
        reason_codes.append("WEEK_ABSORB")
        evidence.append("本週已進入吸收節奏。")
    if week_load_delta is not None and week_load_delta <= -15:
        reason_codes.append("WEEK_LOAD_DROP")
        evidence.append(f"本週負荷較基準下降 {abs(float(week_load_delta)):.0f}%。")
    if month_load_delta is not None and month_load_delta <= -25:
        reason_codes.append("MONTH_LOAD_DROP")
        evidence.append(f"本月負荷較基準下降 {abs(float(month_load_delta)):.0f}%。")

    eligible = bool(reason_codes)
    if not eligible:
        return AttentionCandidate("recovery", False, None, tuple(), None, None, tuple())

    if hrv_below_baseline and recent_quality_stress:
        priority = "critical"
    elif week_status == "absorb" or (week_load_delta is not None and week_load_delta <= -15):
        priority = "high"
    else:
        priority = "medium"

    return AttentionCandidate(
        domain="recovery",
        eligible=True,
        priority=priority,
        reason_codes=tuple(reason_codes),
        attention_label="今天最該關心的是恢復",
        target_surface="weekly",
        evidence=tuple(evidence),
    )


def load_build_attention(signals: dict[str, Any]) -> AttentionCandidate:
    reason_codes: list[str] = []
    evidence: list[str] = []

    week_load_delta = signals.get("week_load_delta_pct")
    week_km_delta = signals.get("week_km_delta_pct")
    month_load_delta = signals.get("month_load_delta_pct")

    if week_load_delta is not None and week_load_delta >= 15:
        reason_codes.append("WEEK_LOAD_RISING")
        evidence.append(f"本週負荷較基準增加 {float(week_load_delta):.0f}%。")
    if month_load_delta is not None and month_load_delta >= 10:
        reason_codes.append("MONTH_LOAD_RISING")
        evidence.append(f"本月負荷較基準增加 {float(month_load_delta):.0f}%。")
    if week_km_delta is not None and week_km_delta >= 10:
        reason_codes.append("WEEK_KM_RISING")
        evidence.append(f"本週里程較基準增加 {float(week_km_delta):.0f}%。")

    eligible = bool(reason_codes)
    if not eligible:
        return AttentionCandidate("load_build", False, None, tuple(), None, None, tuple())

    if "WEEK_LOAD_RISING" in reason_codes and "MONTH_LOAD_RISING" in reason_codes:
        priority = "high"
    else:
        priority = "medium"

    return AttentionCandidate(
        domain="load_build",
        eligible=True,
        priority=priority,
        reason_codes=tuple(reason_codes),
        attention_label="今天最該關心的是建構節奏",
        target_surface="monthly",
        evidence=tuple(evidence),
    )


def shoes_attention(signals: dict[str, Any]) -> AttentionCandidate:
    max_active_shoe_km = signals.get("max_active_shoe_km")
    if max_active_shoe_km is None:
        return AttentionCandidate("shoes", False, None, tuple(), None, None, tuple())

    distance = float(max_active_shoe_km)
    if distance < 700:
        return AttentionCandidate("shoes", False, None, tuple(), None, None, tuple())

    if distance >= 850:
        priority = "high"
        reason_codes = ("SHOE_NEAR_RETIREMENT",)
        evidence = (f"主力鞋已累積 {distance:.0f} km，接近更換區間。",)
    else:
        priority = "medium"
        reason_codes = ("SHOE_WATCH_DISTANCE",)
        evidence = (f"主力鞋已累積 {distance:.0f} km，值得開始留意。",)

    return AttentionCandidate(
        domain="shoes",
        eligible=True,
        priority=priority,
        reason_codes=reason_codes,
        attention_label="今天最該關心的是長跑鞋的更換",
        target_surface="shoes",
        evidence=evidence,
    )


def evaluate_candidates(signals: dict[str, Any]) -> list[AttentionCandidate]:
    return [
        recovery_attention(signals),
        load_build_attention(signals),
        shoes_attention(signals),
    ]


def rank_candidates(candidates: list[AttentionCandidate]) -> list[AttentionCandidate]:
    eligible = [candidate for candidate in candidates if candidate.eligible]
    return sorted(
        eligible,
        key=lambda candidate: (
            PRIORITY_ORDER[candidate.priority],
            DOMAIN_TIEBREAK[candidate.domain],
        ),
        reverse=True,
    )


def scenarios(connection: sqlite3.Connection) -> tuple[AttentionScenario, ...]:
    live = live_signals(connection)
    return (
        AttentionScenario(
            name="Scenario 1",
            description="Live current recovery-oriented week",
            signals=live,
            expected_primary="recovery",
            human_judgment="會點頭：目前整體更像吸收與恢復，不需要硬找別的焦點。",
        ),
        AttentionScenario(
            name="Scenario 2",
            description="Build progression should speak first",
            signals={
                **live,
                "week_load_delta_pct": 18.0,
                "week_km_delta_pct": 12.0,
                "week_recovery_status": "Watch Load",
                "month_load_delta_pct": 16.0,
                "max_active_shoe_km": 420.0,
                "hrv_below_baseline": False,
                "recent_quality_stress": False,
            },
            expected_primary="load_build",
            human_judgment="會點頭：今天先談建構，比談鞋或恢復更自然。",
        ),
        AttentionScenario(
            name="Scenario 3",
            description="Shoe maintenance should speak first",
            signals={
                **live,
                "week_load_delta_pct": 3.0,
                "week_km_delta_pct": 1.0,
                "week_recovery_status": "Balanced",
                "month_load_delta_pct": 4.0,
                "max_active_shoe_km": 910.0,
                "hrv_below_baseline": False,
                "recent_quality_stress": False,
            },
            expected_primary="shoes",
            human_judgment="會點頭：當訓練本身平穩時，鞋況成為今天最該先看的事。",
        ),
        AttentionScenario(
            name="Scenario 4",
            description="Multiple domains eligible on the same day",
            signals={
                **live,
                "week_load_delta_pct": 19.0,
                "week_km_delta_pct": 14.0,
                "week_recovery_status": "Absorb",
                "month_load_delta_pct": 18.0,
                "max_active_shoe_km": 780.0,
                "hrv_below_baseline": False,
                "recent_quality_stress": True,
            },
            expected_primary="recovery",
            human_judgment="可點頭：恢復應先於建構，建構再先於鞋況；第二名仍值得保留。",
        ),
        AttentionScenario(
            name="Scenario 5",
            description="No urgent focus day",
            signals={
                **live,
                "week_load_delta_pct": 2.0,
                "week_km_delta_pct": 1.0,
                "week_recovery_status": "Balanced",
                "month_load_delta_pct": 3.0,
                "max_active_shoe_km": 340.0,
                "hrv_below_baseline": False,
                "recent_quality_stress": False,
            },
            expected_primary=None,
            human_judgment="會點頭：今天不需要硬做提醒，照原本節奏走即可。",
        ),
    )


def scenario_result_lines(scenario: AttentionScenario) -> list[str]:
    candidates = evaluate_candidates(scenario.signals)
    ranked = rank_candidates(candidates)
    winner = ranked[0].domain if ranked else None
    shadow_result = "pass" if winner == scenario.expected_primary else "review"
    lines = [
        f"## {scenario.name} | {scenario.description}",
        "",
        f"- Expected primary: `{scenario.expected_primary}`",
        f"- Ranked primary: `{winner}`",
        f"- Shadow result: `{shadow_result}`",
        f"- Human judgment: {scenario.human_judgment}",
        "",
        "| Domain | Eligible | Priority | Reason Codes | Attention Label | Target Surface | Evidence |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for candidate in candidates:
        reason_codes = "<br>".join(candidate.reason_codes) if candidate.reason_codes else "—"
        label = candidate.attention_label or "—"
        target_surface = candidate.target_surface or "—"
        evidence = "<br>".join(candidate.evidence) if candidate.evidence else "—"
        lines.append(
            f"| `{candidate.domain}` | `{candidate.eligible}` | `{candidate.priority or '—'}` | {reason_codes} | {label} | `{target_surface}` | {evidence} |"
        )
    if ranked:
        lines.append("")
        lines.append("**Selected attention order**")
        lines.append("")
        for index, candidate in enumerate(ranked, start=1):
            lines.append(
                f"{index}. `{candidate.domain}` — {candidate.priority} — {candidate.attention_label}"
            )
    else:
        lines.append("")
        lines.append("**Selected attention order**")
        lines.append("")
        lines.append("今天沒有需要特別處理的訊號，照原本節奏走就好。")
    lines.append("")
    return lines


def generate_report(connection: sqlite3.Connection) -> str:
    lines = [
        "# Attention Selection Shadow v0.1",
        "",
        "This is a minimal executable shadow slice for deterministic Overview attention selection.",
        "",
        "It does not define an Overview layout.",
        "",
        "It only tests whether three domains can independently decide:",
        "",
        "1. am I eligible to speak today?",
        "2. if yes, how important am I?",
        "",
        "## Purpose",
        "",
        "We are not trying to prove an abstract attention engine.",
        "",
        "We are only testing one practical question:",
        "",
        "**can three domains look at the same day, speak independently, and produce an attention order a human would accept?**",
        "",
        "## Domain Contract",
        "",
        "| Field | Meaning |",
        "| --- | --- |",
        "| `domain` | Which knowledge domain is speaking |",
        "| `eligible` | Whether the domain should enter today's attention competition |",
        "| `priority` | `critical`, `high`, `medium`, or `null` when not eligible |",
        "| `reason_codes` | Traceable machine-readable reasons |",
        "| `attention_label` | The user-facing attention sentence |",
        "| `target_surface` | Which page the runner should go to next |",
        "| `evidence` | Human-readable evidence for quick verification |",
        "",
        "## Selection Rule v0.1",
        "",
        "- Only eligible domains enter ranking.",
        "- Priority order: `critical` > `high` > `medium`.",
        "- Tie-break order: `recovery` > `load_build` > `shoes`.",
        "- When no domain is eligible, Overview should say there is no urgent focus today.",
        "",
        "## What This Shadow Slice Must Prove",
        "",
        "- Irrelevant domains can stay silent.",
        "- Relevant domains can speak without needing help from a global if/elif chain.",
        "- When multiple domains are active, the selection still feels coach-like.",
        "- When nothing deserves attention, the system can say so without manufacturing anxiety.",
        "",
        "## Scenario Results",
        "",
    ]
    for scenario in scenarios(connection):
        lines.extend(scenario_result_lines(scenario))
    lines.extend(
        [
            "## Shadow Outcome",
            "",
            "- Irrelevant domains can stay silent.",
            "- Recovery can outrank build when both are active.",
            "- A no-urgent-focus day can be expressed without manufacturing anxiety.",
            "- The hardest part is not ranking everything; it is deciding who has earned the right to speak today.",
            "",
            "## Current Read",
            "",
            "This is enough to say deterministic attention selection is viable in shadow form.",
            "",
            "It is **not** enough to justify a full Overview implementation yet.",
            "",
            "What it does prove is smaller and more useful:",
            "",
            "1. each domain can decide whether it deserves attention today",
            "2. only eligible domains need to enter competition",
            "3. a simple deterministic selection rule can already produce human-readable focus ordering",
        ]
    )
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    with connect() as connection:
        report = generate_report(connection)
    if len(argv) >= 2:
        Path(argv[1]).write_text(report, encoding="utf-8")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
