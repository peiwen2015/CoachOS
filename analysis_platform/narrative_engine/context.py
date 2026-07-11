from __future__ import annotations


def weekly_context(signals: dict) -> dict:
    load_delta = signals.get("load_vs_4w_avg_pct")
    previous_week_load = signals.get("previous_week_load")
    baseline_load = signals.get("baseline_training_load")
    baseline_days = signals.get("baseline_active_days")
    return {
        "baseline_ready": bool(signals.get("baseline_complete")),
        "had_recent_high_load": (
            previous_week_load is not None
            and baseline_load is not None
            and previous_week_load > baseline_load * 1.05
        ),
        "maintained_continuity": (
            bool(signals.get("long_run_present"))
            or (
                baseline_days is not None
                and signals.get("active_days", 0) >= max(int(round(baseline_days)) - 1, 2)
            )
        ),
        "recovery_before_stimulus": (
            previous_week_load is not None
            and baseline_load is not None
            and previous_week_load < baseline_load * 0.9
            and bool(signals.get("key_session_present"))
        ),
        "sustained_decline": (
            load_delta is not None
            and load_delta <= -15
            and previous_week_load is not None
            and baseline_load is not None
            and previous_week_load < baseline_load * 0.9
            and (signals.get("previous_week_distance_km") or 0) < (signals.get("baseline_distance_km") or 0)
        ),
    }


def monthly_context(
    signals: dict,
    *,
    include_period_completeness: bool = True,
    include_previous_theme: bool = True,
) -> dict:
    load_delta = signals.get("load_vs_3m_reference_pct")
    previous_theme = signals.get("previous_month_theme") if include_previous_theme else None
    partial_period = bool(signals.get("is_partial_month")) if include_period_completeness else False
    injected_contexts: list[str] = []
    if include_previous_theme and signals.get("previous_month_theme") is not None:
        injected_contexts.append("previous_theme")
    if include_period_completeness and signals.get("is_partial_month"):
        injected_contexts.append("period_completeness")
    return {
        "baseline_ready": bool(signals.get("baseline_complete")),
        "partial_period": partial_period,
        "had_recent_high_load": previous_theme in {"load_build", "balanced_build", "steady_build"},
        "maintained_continuity": (
            (signals.get("long_run_count") or 0) >= 1
            or (signals.get("monthly_activity_count") or 0) >= 12
        ),
        "recovery_before_stimulus": previous_theme == "absorb" and (signals.get("key_session_count") or 0) >= 1,
        "sustained_decline": (
            load_delta is not None
            and load_delta <= -15
            and signals.get("distance_vs_3m_reference_pct") is not None
            and signals.get("distance_vs_3m_reference_pct") <= -15
            and previous_theme not in {"absorb", "load_build", "balanced_build", "steady_build"}
        ),
        "previous_theme": previous_theme,
        "injected_contexts": tuple(injected_contexts),
    }


def journey_context(signals: dict) -> dict:
    return {
        "baseline_ready": bool(signals.get("baseline_complete")),
        "partial_period": bool(signals.get("is_partial_month")),
        "recovery_before_stimulus": signals.get("previous_chapter") == "absorb" and bool(signals.get("key_session_continuity")),
        "maintained_continuity": bool(signals.get("long_run_continuity")) or bool(signals.get("key_session_continuity")),
        "sustained_decline": (
            signals.get("monthly_distance_trend") is not None
            and signals.get("monthly_load_trend") is not None
            and signals["monthly_distance_trend"] <= -15
            and signals["monthly_load_trend"] <= -15
            and signals.get("previous_chapter") not in {"absorb"}
        ),
    }
