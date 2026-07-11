from __future__ import annotations

import sqlite3
import sys
from pathlib import Path

from .adapters import journey as journey_adapter
from .adapters import monthly as monthly_adapter
from .adapters import weekly as weekly_adapter
from .engine import NarrativeEngine
from .signals import fetch_latest_month_keys, fetch_latest_week_offsets


ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from analysis_platform import dashboard_app  # noqa: E402


def connect(db_path: str) -> sqlite3.Connection:
    connection = sqlite3.connect(db_path)
    connection.row_factory = sqlite3.Row
    return connection


def _legacy_weekly(connection: sqlite3.Connection, week_offset: int) -> dict | None:
    weekly = dashboard_app.selected_week_summary(connection, week_offset if week_offset <= 4 else 4)
    intelligence = dashboard_app.selected_week_intelligence(connection, week_offset if week_offset <= 4 else 4)
    if week_offset > 4:
        # Reuse current page language but on generic signals for shadow comparison.
        from analysis_platform.narrative_engine.signals import fetch_weekly_signals

        signals = fetch_weekly_signals(connection, week_offset)
        if not signals:
            return None
        load_delta = signals["load_vs_4w_avg_pct"]
        km_delta = signals["distance_vs_4w_avg_pct"]
        recovery_status = "Balanced"
        if load_delta is None or km_delta is None:
            verdict = "先穩住節奏"
        elif load_delta > 15:
            verdict = "刺激偏高"
        elif load_delta < -15:
            verdict = "吸收週"
        elif recovery_status.lower() == "balanced":
            verdict = "節奏穩住了"
        else:
            verdict = "整體可控"
        return {"verdict": verdict, "rule_source": "legacy-dashboard-like"}
    if not weekly or not intelligence:
        return None
    review = dashboard_app.weekly_review_payload(weekly, intelligence)
    return {"verdict": review["verdict"], "rule_source": "dashboard_app.weekly_review_payload"}


def _legacy_monthly(connection: sqlite3.Connection, month_key: str) -> dict | None:
    monthly = dashboard_app.selected_month_summary(connection, month_key)
    intelligence = dashboard_app.selected_month_intelligence(connection, month_key)
    progress = dashboard_app.selected_month_progress(connection, month_key)
    if not monthly or not intelligence:
        return None
    overview = dashboard_app.monthly_overview_payload(monthly, intelligence, progress)
    plan_key, recommendation = dashboard_app.monthly_recommendation_plan(intelligence)
    return {
        "verdict": overview["verdict"] if overview else "",
        "recommendation": recommendation,
        "rule_source": plan_key,
    }


def _legacy_journey(connection: sqlite3.Connection, month_key: str) -> dict | None:
    story = dashboard_app.journey_story(connection, month_key)
    if not story:
        return None
    return {
        "theme": str(story["chapter_label"]),
        "verdict": str(story["coach_verdict"]),
        "rule_source": str(story["chapter_code"]),
    }


def _monthly_time_context_trace(engine: NarrativeEngine, month_key: str) -> dict[str, object] | None:
    baseline = engine.monthly(
        month_key,
        include_period_completeness=False,
        include_previous_theme=False,
    )
    previous_theme_only = engine.monthly(
        month_key,
        include_period_completeness=False,
        include_previous_theme=True,
    )
    full = engine.monthly(
        month_key,
        include_period_completeness=True,
        include_previous_theme=True,
    )
    if not baseline or not previous_theme_only or not full:
        return None

    changed_by: list[str] = []
    if baseline.verdict != previous_theme_only.verdict or baseline.theme != previous_theme_only.theme:
        changed_by.append("previous_theme")
    if previous_theme_only.verdict != full.verdict or previous_theme_only.theme != full.theme:
        changed_by.append("period_completeness")

    return {
        "baseline": baseline,
        "previous_theme_only": previous_theme_only,
        "full": full,
        "changed_by": tuple(changed_by),
    }


def generate_shadow_report(db_path: str) -> str:
    with connect(db_path) as connection:
        engine = NarrativeEngine(connection)
        week_offsets = fetch_latest_week_offsets(connection, count=8)
        month_keys = fetch_latest_month_keys(connection, count=6)

        lines: list[str] = []
        lines.append("# Narrative Engine Shadow Report v0.1")
        lines.append("")
        lines.append("Shadow mode comparison only. Current dashboard-visible narratives remain unchanged.")
        lines.append("")

        lines.append("## Weekly | Latest 8 Weeks")
        lines.append("")
        lines.append("| Period | Current Verdict | Engine Verdict | Rule | Confidence | Evidence | Match | Human Review |")
        lines.append("|---|---|---|---|---|---|---|---|")
        for week_offset in week_offsets:
            engine_obj = engine.weekly(week_offset)
            current = _legacy_weekly(connection, week_offset)
            adapted = weekly_adapter.adapt(engine_obj) if engine_obj else None
            period = (
                f"{engine_obj.period_start} → {engine_obj.period_end}"
                if engine_obj
                else f"week-{week_offset}"
            )
            evidence = (
                "; ".join(f"{item.signal}={item.value} ({item.interpretation})" for item in engine_obj.evidence[:2])
                if engine_obj
                else ""
            )
            match = "YES" if current and adapted and current["verdict"] == adapted["verdict"] else "NO"
            lines.append(
                f"| {period} | {current['verdict'] if current else '—'} | "
                f"{adapted['verdict'] if adapted else '—'} | "
                f"{', '.join(engine_obj.rule_codes) if engine_obj else '—'} | "
                f"{engine_obj.confidence.level if engine_obj else '—'} ({engine_obj.confidence.score if engine_obj else '—'}) | {evidence} | {match} | TODO |"
            )

        lines.append("")
        lines.append("## Monthly | Latest 6 Months")
        lines.append("")
        lines.append("| Period | Current Verdict | Engine Verdict | Rule | Confidence | Evidence | Match | Why Changed | Human Review |")
        lines.append("|---|---|---|---|---|---|---|---|---|")
        monthly_total = 0
        monthly_match = 0
        for month_key in month_keys:
            trace = _monthly_time_context_trace(engine, month_key)
            engine_obj = trace["full"] if trace else engine.monthly(month_key)
            current = _legacy_monthly(connection, month_key)
            adapted = monthly_adapter.adapt(engine_obj) if engine_obj else None
            evidence = (
                "; ".join(f"{item.signal}={item.value} ({item.interpretation})" for item in engine_obj.evidence[:2])
                if engine_obj
                else ""
            )
            match = "YES" if current and adapted and current["verdict"] == adapted["verdict"] else "NO"
            monthly_total += 1
            if match == "YES":
                monthly_match += 1
            why_changed = "—"
            if trace:
                changed_by = list(trace["changed_by"])
                if changed_by:
                    why_changed = ", ".join(changed_by)
            lines.append(
                f"| {month_key} | {current['verdict'] if current else '—'} | "
                f"{adapted['verdict'] if adapted else '—'} | "
                f"{', '.join(engine_obj.rule_codes) if engine_obj else '—'} | "
                f"{engine_obj.confidence.level if engine_obj else '—'} ({engine_obj.confidence.score if engine_obj else '—'}) | {evidence} | {match} | {why_changed} | TODO |"
            )

        lines.append("")
        lines.append("## Monthly Time Context Trace")
        lines.append("")
        lines.append("| Period | Without Time Context | + previous_theme | + period_completeness | Changed By |")
        lines.append("|---|---|---|---|---|")
        for month_key in month_keys:
            trace = _monthly_time_context_trace(engine, month_key)
            if not trace:
                continue
            baseline = trace["baseline"]
            previous_theme_only = trace["previous_theme_only"]
            full = trace["full"]
            changed_by = ", ".join(trace["changed_by"]) if trace["changed_by"] else "—"
            lines.append(
                f"| {month_key} | {monthly_adapter.adapt(baseline)['verdict']} | "
                f"{monthly_adapter.adapt(previous_theme_only)['verdict']} | "
                f"{monthly_adapter.adapt(full)['verdict']} | {changed_by} |"
            )

        lines.append("")
        lines.append("## Monthly Gap Closure")
        lines.append("")
        lines.append(f"- Monthly matches after Time First injection: {monthly_match} / {monthly_total}")
        lines.append(f"- Monthly mismatches after Time First injection: {monthly_total - monthly_match}")

        lines.append("")
        lines.append("## Journey | Latest 6 Months")
        lines.append("")
        lines.append("| Chapter | Current Theme | Engine Theme | Rule | Confidence | Evidence | Match | Human Review |")
        lines.append("|---|---|---|---|---|---|---|---|")
        for month_key in month_keys:
            engine_obj = engine.journey(month_key)
            current = _legacy_journey(connection, month_key)
            adapted = journey_adapter.adapt(engine_obj) if engine_obj else None
            evidence = (
                "; ".join(f"{item.signal}={item.value} ({item.interpretation})" for item in engine_obj.evidence[:2])
                if engine_obj
                else ""
            )
            match = "YES" if current and adapted and current["theme"] == adapted["theme"] else "NO"
            lines.append(
                f"| {month_key} | {current['theme'] if current else '—'} | "
                f"{adapted['theme'] if adapted else '—'} | "
                f"{', '.join(engine_obj.rule_codes) if engine_obj else '—'} | "
                f"{engine_obj.confidence.level if engine_obj else '—'} ({engine_obj.confidence.score if engine_obj else '—'}) | {evidence} | {match} | TODO |"
            )

        lines.append("")
        lines.append("## Notes")
        lines.append("")
        lines.append("- Weekly and Monthly compare current page-facing verdicts against Narrative Engine v0.1 shadow outputs.")
        lines.append("- Journey compares current story chapter naming against engine-derived chapter understanding.")
        lines.append("- This report is for rule tuning only and does not change dashboard-visible copy.")
        lines.append("")
        return "\n".join(lines)


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Usage: python -m analysis_platform.narrative_engine.shadow_report <sqlite_db> [output.md]")
        return 1
    db_path = argv[1]
    report = generate_shadow_report(db_path)
    if len(argv) >= 3:
        Path(argv[2]).write_text(report, encoding="utf-8")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
