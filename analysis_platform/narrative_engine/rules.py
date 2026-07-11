from __future__ import annotations

from .models import Confidence, EvidenceItem, NarrativeObject


THEME_STABLE_BUILD = "STABLE_BUILD"
THEME_RECOVERY = "RECOVERY_ABSORPTION"
THEME_LOAD_BUILD = "LOAD_BUILD"
THEME_QUALITY_RETURN = "QUALITY_REINTRODUCTION"
THEME_NEEDS_ATTENTION = "NEEDS_ATTENTION"


def _confidence(evidence: list[EvidenceItem], baseline_ready: bool, has_conflict: bool, period_type: str, start: str, end: str, theme: str, verdict: str, learning: str, recommendation: str, rule_code: str) -> NarrativeObject:
    score = 0.35 + min(len(evidence), 4) * 0.15 + (0.12 if baseline_ready else 0.0) - (0.18 if has_conflict else 0.0)
    score = max(0.2, min(score, 0.95))
    if has_conflict or len(evidence) <= 1:
        level = "LOW"
        reason = "Signals are limited or partially conflicting."
    elif baseline_ready and len(evidence) >= 3:
        level = "HIGH"
        reason = "Multiple consistent signals and sufficient baseline."
    else:
        level = "MEDIUM"
        reason = "Signals are directionally useful, but baseline or consistency is incomplete."
    return NarrativeObject(
        theme=theme,
        verdict=verdict,
        learning=learning,
        recommendation=recommendation,
        evidence=tuple(evidence),
        confidence=Confidence(level=level, score=round(score, 2), reason=reason),
        rule_codes=(rule_code,),
        period_type=period_type,
        period_start=start,
        period_end=end,
    )


def _ev(signal: str, value, interpretation: str) -> EvidenceItem:
    return EvidenceItem(signal=signal, value=value, interpretation=interpretation)


def evaluate_weekly(signals: dict, context: dict) -> NarrativeObject:
    start = signals["period_start"]
    end = signals["period_end"]
    load_delta = signals.get("load_vs_4w_avg_pct")
    km_delta = signals.get("distance_vs_4w_avg_pct")
    load_per_km = signals.get("load_per_km_vs_4w_avg_pct")

    if not context["baseline_ready"]:
        return _confidence(
            [_ev("baseline_complete", signals.get("baseline_complete"), "Weekly baseline is still forming.")],
            False,
            False,
            "WEEK",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "INSUFFICIENT_CONTEXT",
            "CONTEXT_IS_STILL_FORMING",
            "GATHER_MORE_CONTEXT",
            "NE-WK-CTX-001",
        )

    if (load_delta is not None and load_delta > 25) or (load_per_km is not None and load_per_km > 20):
        return _confidence(
            [
                _ev("load_vs_4w_avg_pct", load_delta, "Load is meaningfully above recent baseline."),
                _ev("load_per_km_vs_4w_avg_pct", load_per_km, "Training density is also elevated."),
            ],
            True,
            False,
            "WEEK",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "OVERLOAD_RISK",
            "RECOVERY_MARGIN_IS_THIN",
            "PROTECT_RECOVERY",
            "NE-WK-RISK-001",
        )

    if context["sustained_decline"]:
        return _confidence(
            [
                _ev("load_vs_4w_avg_pct", load_delta, "Load is below baseline for more than one week."),
                _ev("distance_vs_4w_avg_pct", km_delta, "Distance is also below recent rhythm."),
            ],
            True,
            False,
            "WEEK",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "DETRAINING_RISK",
            "RHYTHM_IS_SLIPPING",
            "RESTORE_TRAINING_RHYTHM",
            "NE-WK-RISK-002",
        )

    if load_delta is not None and load_delta <= -10 and context["had_recent_high_load"] and context["maintained_continuity"]:
        return _confidence(
            [
                _ev("load_vs_4w_avg_pct", load_delta, "Load is below recent baseline."),
                _ev("long_run_present", signals.get("long_run_present"), "Long-run or continuity signal stayed alive."),
                _ev("previous_week_load", signals.get("previous_week_load"), "The previous week carried more load."),
            ],
            True,
            False,
            "WEEK",
            start,
            end,
            THEME_RECOVERY,
            "INTENTIONAL_RECOVERY",
            "RECOVERY_IS_TRAINING",
            "REINTRODUCE_QUALITY_GRADUALLY",
            "NE-WK-REC-001",
        )

    if context["recovery_before_stimulus"] and bool(signals.get("key_session_present")) and (load_delta is None or load_delta <= 15):
        return _confidence(
            [
                _ev("previous_week_load", signals.get("previous_week_load"), "The previous week was lighter."),
                _ev("key_session_present", signals.get("key_session_present"), "Quality stimulus returned this week."),
            ],
            True,
            False,
            "WEEK",
            start,
            end,
            THEME_QUALITY_RETURN,
            "QUALITY_RETURNING",
            "STIMULUS_IS_RETURNING",
            "KEEP_RECOVERY_AROUND_QUALITY",
            "NE-WK-QLT-001",
        )

    if load_delta is not None and 10 <= load_delta <= 25 and km_delta is not None and km_delta >= 5 and (signals.get("consecutive_training_days") or 0) <= 5:
        return _confidence(
            [
                _ev("load_vs_4w_avg_pct", load_delta, "Load is above baseline but still controlled."),
                _ev("distance_vs_4w_avg_pct", km_delta, "Distance rose together with load."),
            ],
            True,
            False,
            "WEEK",
            start,
            end,
            THEME_LOAD_BUILD,
            "CONTROLLED_BUILD",
            "CAPACITY_IS_EXPANDING",
            "HOLD_BEFORE_NEXT_INCREASE",
            "NE-WK-BLD-001",
        )

    return _confidence(
        [
            _ev("load_vs_4w_avg_pct", load_delta, "Load is close to recent baseline."),
            _ev("distance_vs_4w_avg_pct", km_delta, "Distance is also staying near baseline."),
            _ev("active_days", signals.get("active_days"), "Training frequency stayed stable."),
        ],
        True,
        False,
        "WEEK",
        start,
        end,
        THEME_STABLE_BUILD,
        "ON_TRACK",
        "CONSISTENCY_IS_BUILDING",
        "MAINTAIN_CURRENT_RHYTHM",
        "NE-WK-STB-001",
    )


def evaluate_monthly(signals: dict, context: dict) -> NarrativeObject:
    start = signals["period_start"]
    end = signals["period_end"]
    load_delta = signals.get("load_vs_3m_reference_pct")
    km_delta = signals.get("distance_vs_3m_reference_pct")

    if not context["baseline_ready"]:
        return _confidence(
            [_ev("baseline_complete", signals.get("baseline_complete"), "Monthly baseline is still forming.")],
            False,
            False,
            "MONTH",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "INSUFFICIENT_CONTEXT",
            "CONTEXT_IS_STILL_FORMING",
            "GATHER_MORE_CONTEXT",
            "NE-MON-CTX-001",
        )

    if load_delta is not None and load_delta > 25:
        return _confidence(
            [
                _ev("load_vs_3m_reference_pct", load_delta, "Monthly load is well above recent baseline."),
                _ev("key_session_count", signals.get("key_session_count"), "Quality sessions increased around the same period."),
            ],
            True,
            False,
            "MONTH",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "OVERLOAD_RISK",
            "RECOVERY_MARGIN_IS_THIN",
            "PROTECT_RECOVERY",
            "NE-MON-RISK-001",
        )

    if context["sustained_decline"]:
        return _confidence(
            [
                _ev("load_vs_3m_reference_pct", load_delta, "Load is below recent monthly rhythm."),
                _ev("distance_vs_3m_reference_pct", km_delta, "Volume is also below recent baseline."),
            ],
            True,
            False,
            "MONTH",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "DETRAINING_RISK",
            "RHYTHM_IS_SLIPPING",
            "RESTORE_TRAINING_RHYTHM",
            "NE-MON-RISK-002",
        )

    if load_delta is not None and load_delta <= -10 and context["had_recent_high_load"] and context["maintained_continuity"]:
        return _confidence(
            [
                _ev("load_vs_3m_reference_pct", load_delta, "Load is lower than recent baseline."),
                _ev("long_run_count", signals.get("long_run_count"), "Endurance continuity stayed in place."),
                _ev("previous_month_theme", signals.get("previous_month_theme"), "The previous month came from a higher-load chapter."),
            ],
            True,
            False,
            "MONTH",
            start,
            end,
            THEME_RECOVERY,
            "INTENTIONAL_RECOVERY",
            "RECOVERY_IS_TRAINING",
            "REINTRODUCE_QUALITY_GRADUALLY",
            "NE-MON-REC-001",
        )

    if context["partial_period"] and context["recovery_before_stimulus"] and context["maintained_continuity"]:
        return _confidence(
            [
                _ev("month_completeness_pct", signals.get("month_completeness_pct"), "This month is still being written and should not be read like a closed month."),
                _ev("previous_month_theme", signals.get("previous_month_theme"), "The previous month was recovery-oriented, so this month is best read as transition rather than conclusion."),
                _ev("key_session_count", signals.get("key_session_count"), "Quality stimulus has started to return inside the partial month."),
            ],
            True,
            False,
            "MONTH",
            start,
            end,
            THEME_STABLE_BUILD,
            "ON_TRACK",
            "CONSISTENCY_IS_BUILDING",
            "MAINTAIN_CURRENT_RHYTHM",
            "NE-MON-STB-CTX-001",
        )

    if context["recovery_before_stimulus"] and (signals.get("key_session_count") or 0) >= 1 and (load_delta is None or load_delta <= 15):
        return _confidence(
            [
                _ev("previous_month_theme", signals.get("previous_month_theme"), "The previous month was recovery-oriented."),
                _ev("key_session_count", signals.get("key_session_count"), "Quality sessions returned this month."),
            ],
            True,
            False,
            "MONTH",
            start,
            end,
            THEME_QUALITY_RETURN,
            "QUALITY_RETURNING",
            "STIMULUS_IS_RETURNING",
            "KEEP_RECOVERY_AROUND_QUALITY",
            "NE-MON-QLT-001",
        )

    if load_delta is not None and 10 <= load_delta <= 25 and km_delta is not None and km_delta >= 5 and not context["partial_period"]:
        return _confidence(
            [
                _ev("load_vs_3m_reference_pct", load_delta, "Load is rising in a controlled range."),
                _ev("distance_vs_3m_reference_pct", km_delta, "Volume is climbing with it."),
                _ev("monthly_activity_count", signals.get("monthly_activity_count"), "Activity count stayed active enough to support the build."),
            ],
            True,
            False,
            "MONTH",
            start,
            end,
            THEME_LOAD_BUILD,
            "CONTROLLED_BUILD",
            "CAPACITY_IS_EXPANDING",
            "HOLD_BEFORE_NEXT_INCREASE",
            "NE-MON-BLD-001",
        )

    return _confidence(
        [
            _ev("load_vs_3m_reference_pct", load_delta, "Load is within a stable band."),
            _ev("distance_vs_3m_reference_pct", km_delta, "Distance stayed near recent baseline."),
            _ev("month_completeness_pct", signals.get("month_completeness_pct"), "The current month context is accounted for."),
        ],
        True,
        False,
        "MONTH",
        start,
        end,
        THEME_STABLE_BUILD,
        "ON_TRACK",
        "CONSISTENCY_IS_BUILDING",
        "MAINTAIN_CURRENT_RHYTHM",
        "NE-MON-STB-001",
    )


def evaluate_journey(signals: dict, context: dict) -> NarrativeObject:
    start = signals["period_start"]
    end = signals["period_end"]
    load_trend = signals.get("monthly_load_trend")
    distance_trend = signals.get("monthly_distance_trend")

    if not context["baseline_ready"]:
        return _confidence(
            [_ev("baseline_complete", signals.get("baseline_complete"), "Journey baseline is still forming.")],
            False,
            False,
            "JOURNEY",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "INSUFFICIENT_CONTEXT",
            "CONTEXT_IS_STILL_FORMING",
            "GATHER_MORE_CONTEXT",
            "NE-JNY-CTX-001",
        )

    if context["sustained_decline"]:
        return _confidence(
            [
                _ev("monthly_load_trend", load_trend, "Load trend is down across chapters."),
                _ev("monthly_distance_trend", distance_trend, "Distance trend also moved down."),
            ],
            True,
            False,
            "JOURNEY",
            start,
            end,
            THEME_NEEDS_ATTENTION,
            "DETRAINING_RISK",
            "RHYTHM_IS_SLIPPING",
            "RESTORE_TRAINING_RHYTHM",
            "NE-JNY-RISK-001",
        )

    if load_trend is not None and load_trend <= -10 and context["maintained_continuity"]:
        return _confidence(
            [
                _ev("monthly_load_trend", load_trend, "Chapter load softened relative to recent history."),
                _ev("long_run_continuity", signals.get("long_run_continuity"), "Endurance continuity still stayed alive."),
                _ev("previous_chapter", signals.get("previous_chapter"), "This chapter follows a more loaded one."),
            ],
            True,
            False,
            "JOURNEY",
            start,
            end,
            THEME_RECOVERY,
            "INTENTIONAL_RECOVERY",
            "RECOVERY_IS_TRAINING",
            "REINTRODUCE_QUALITY_GRADUALLY",
            "NE-JNY-REC-001",
        )

    if context["recovery_before_stimulus"]:
        return _confidence(
            [
                _ev("previous_chapter", signals.get("previous_chapter"), "The previous chapter was recovery-oriented."),
                _ev("key_session_continuity", signals.get("key_session_continuity"), "Stimulus has started to return."),
            ],
            True,
            False,
            "JOURNEY",
            start,
            end,
            THEME_QUALITY_RETURN,
            "QUALITY_RETURNING",
            "STIMULUS_IS_RETURNING",
            "KEEP_RECOVERY_AROUND_QUALITY",
            "NE-JNY-QLT-001",
        )

    if load_trend is not None and 10 <= load_trend <= 25 and distance_trend is not None and distance_trend >= 5:
        return _confidence(
            [
                _ev("monthly_load_trend", load_trend, "Load trend is rising in a controlled way."),
                _ev("monthly_distance_trend", distance_trend, "Distance trend supports the same story."),
            ],
            True,
            False,
            "JOURNEY",
            start,
            end,
            THEME_LOAD_BUILD,
            "CONTROLLED_BUILD",
            "CAPACITY_IS_EXPANDING",
            "HOLD_BEFORE_NEXT_INCREASE",
            "NE-JNY-BLD-001",
        )

    return _confidence(
        [
            _ev("current_chapter", signals.get("current_chapter"), "The chapter is holding its current direction."),
            _ev("turning_points", len(signals.get("turning_points", ())), "Milestones are accumulating without breaking rhythm."),
        ],
        True,
        False,
        "JOURNEY",
        start,
        end,
        THEME_STABLE_BUILD,
        "ON_TRACK",
        "CONSISTENCY_IS_BUILDING",
        "MAINTAIN_CURRENT_RHYTHM",
        "NE-JNY-STB-001",
    )
