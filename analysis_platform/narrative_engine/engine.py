from __future__ import annotations

import sqlite3

from . import context, rules, signals
from .models import NarrativeObject


class NarrativeEngine:
    def __init__(self, connection: sqlite3.Connection):
        self.connection = connection

    def weekly(self, week_offset: int = 0) -> NarrativeObject | None:
        signal_bundle = signals.fetch_weekly_signals(self.connection, week_offset=week_offset)
        if signal_bundle is None:
            return None
        return rules.evaluate_weekly(signal_bundle, context.weekly_context(signal_bundle))

    def monthly(
        self,
        month_key: str | None = None,
        *,
        include_period_completeness: bool = True,
        include_previous_theme: bool = True,
    ) -> NarrativeObject | None:
        signal_bundle = signals.fetch_monthly_signals(self.connection, month_key=month_key)
        if signal_bundle is None:
            return None
        return rules.evaluate_monthly(
            signal_bundle,
            context.monthly_context(
                signal_bundle,
                include_period_completeness=include_period_completeness,
                include_previous_theme=include_previous_theme,
            ),
        )

    def journey(self, month_key: str | None = None) -> NarrativeObject | None:
        signal_bundle = signals.fetch_journey_signals(self.connection, month_key=month_key)
        if signal_bundle is None:
            return None
        return rules.evaluate_journey(signal_bundle, context.journey_context(signal_bundle))
