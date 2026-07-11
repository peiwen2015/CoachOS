from __future__ import annotations

import sqlite3
from datetime import date, datetime, timedelta


def _latest_activity_date(connection: sqlite3.Connection) -> date | None:
    row = connection.execute("SELECT DATE(MAX(activity_start_time)) AS latest_date FROM activity").fetchone()
    if not row or not row["latest_date"]:
        return None
    return date.fromisoformat(str(row["latest_date"]))


def _week_window(anchor: date, week_offset: int) -> tuple[date, date]:
    end_date = anchor - timedelta(days=week_offset * 7)
    start_date = end_date - timedelta(days=6)
    return start_date, end_date


def _week_summary(connection: sqlite3.Connection, week_offset: int) -> dict | None:
    latest_date = _latest_activity_date(connection)
    if latest_date is None:
        return None
    start_date, end_date = _week_window(latest_date, week_offset)
    row = connection.execute(
        """
        SELECT
            ? AS week_offset,
            ? AS start_date,
            ? AS end_date,
            COUNT(activity_id) AS activities,
            COALESCE(ROUND(SUM(distance_km), 2), 0) AS total_km,
            COALESCE(SUM(duration_sec), 0) AS total_time_sec,
            CASE
                WHEN SUM(distance_km) > 0
                THEN CAST(ROUND(SUM(duration_sec) * 1.0 / SUM(distance_km)) AS INTEGER)
                ELSE NULL
            END AS avg_pace_sec_per_km,
            CAST(ROUND(AVG(avg_hr)) AS INTEGER) AS avg_hr,
            COALESCE(ROUND(SUM(training_load), 1), 0) AS training_load,
            COUNT(DISTINCT activity_date) AS active_days,
            MAX(CASE WHEN is_long_run = 1 THEN 1 ELSE 0 END) AS long_run_present,
            MAX(CASE WHEN is_quality_session = 1 THEN 1 ELSE 0 END) AS key_session_present
        FROM activity_review_view
        WHERE activity_date BETWEEN ? AND ?
        """,
        (
            week_offset,
            start_date.isoformat(),
            end_date.isoformat(),
            start_date.isoformat(),
            end_date.isoformat(),
        ),
    ).fetchone()
    if not row:
        return None

    active_dates = [
        date.fromisoformat(str(item["activity_date"]))
        for item in connection.execute(
            """
            SELECT DISTINCT activity_date
            FROM activity_review_view
            WHERE activity_date BETWEEN ? AND ?
            ORDER BY activity_date
            """,
            (start_date.isoformat(), end_date.isoformat()),
        ).fetchall()
        if item["activity_date"]
    ]
    streak = 0
    best_streak = 0
    previous = None
    for current in active_dates:
        if previous and (current - previous).days == 1:
            streak += 1
        else:
            streak = 1
        best_streak = max(best_streak, streak)
        previous = current

    data = dict(row)
    data["consecutive_training_days"] = best_streak
    data["start_date"] = start_date.isoformat()
    data["end_date"] = end_date.isoformat()
    data["long_run_present"] = bool(data["long_run_present"])
    data["key_session_present"] = bool(data["key_session_present"])
    return data


def _month_summary(connection: sqlite3.Connection, month_key: str | None) -> dict | None:
    if month_key:
        row = connection.execute(
            """
            WITH latest_activity AS (
                SELECT DATE(MAX(activity_start_time)) AS latest_date
                FROM activity
            )
            SELECT
                monthly_summary_view.*,
                latest_activity.latest_date,
                CASE
                    WHEN monthly_summary_view.month_start = DATE(latest_activity.latest_date, 'start of month')
                         AND latest_activity.latest_date < monthly_summary_view.month_end
                    THEN 1 ELSE 0
                END AS is_partial_month
            FROM monthly_summary_view
            CROSS JOIN latest_activity
            WHERE monthly_summary_view.month_key = ?
            """,
            (month_key,),
        ).fetchone()
    else:
        row = connection.execute("SELECT * FROM current_month_summary_view").fetchone()
    return dict(row) if row else None


def _previous_month_key(connection: sqlite3.Connection, month_key: str) -> str | None:
    row = connection.execute(
        """
        WITH ranked AS (
            SELECT month_key, ROW_NUMBER() OVER (ORDER BY month_start DESC) AS month_rank
            FROM monthly_summary_view
        )
        SELECT previous.month_key AS previous_month_key
        FROM ranked AS current
        LEFT JOIN ranked AS previous
          ON previous.month_rank = current.month_rank + 1
        WHERE current.month_key = ?
        """,
        (month_key,),
    ).fetchone()
    return str(row["previous_month_key"]) if row and row["previous_month_key"] else None


def fetch_weekly_signals(connection: sqlite3.Connection, week_offset: int = 0) -> dict | None:
    current = _week_summary(connection, week_offset)
    if current is None:
        return None

    baseline_rows = [_week_summary(connection, week_offset + index) for index in range(1, 5)]
    baseline_rows = [row for row in baseline_rows if row is not None]
    baseline_complete = len(baseline_rows) >= 3

    def avg(key: str) -> float | None:
        values = [float(row[key]) for row in baseline_rows if row[key] is not None]
        if not values:
            return None
        return sum(values) / len(values)

    baseline_distance = avg("total_km")
    baseline_load = avg("training_load")
    baseline_activities = avg("activities")
    baseline_active_days = avg("active_days")
    current_load_per_km = (
        round(float(current["training_load"]) / float(current["total_km"]), 1)
        if current["total_km"]
        else None
    )
    baseline_load_per_km_values = [
        (float(row["training_load"]) / float(row["total_km"]))
        for row in baseline_rows
        if row["total_km"]
    ]
    baseline_load_per_km = (
        sum(baseline_load_per_km_values) / len(baseline_load_per_km_values)
        if baseline_load_per_km_values
        else None
    )
    previous_week = _week_summary(connection, week_offset + 1)

    def delta(current_value: float | int | None, baseline_value: float | None) -> float | None:
        if current_value is None or baseline_value in (None, 0):
            return None
        return round(((float(current_value) - baseline_value) / baseline_value) * 100, 1)

    return {
        "period_type": "WEEK",
        "period_start": current["start_date"],
        "period_end": current["end_date"],
        "week_offset": week_offset,
        "weekly_activity_count": int(current["activities"] or 0),
        "weekly_distance_km": float(current["total_km"] or 0),
        "weekly_training_load": float(current["training_load"] or 0),
        "weekly_load_per_km": current_load_per_km,
        "distance_vs_4w_avg_pct": delta(current["total_km"], baseline_distance),
        "load_vs_4w_avg_pct": delta(current["training_load"], baseline_load),
        "activity_count_vs_4w_avg_pct": delta(current["activities"], baseline_activities),
        "load_per_km_vs_4w_avg_pct": delta(current_load_per_km, baseline_load_per_km),
        "long_run_present": bool(current["long_run_present"]),
        "key_session_present": bool(current["key_session_present"]),
        "active_days": int(current["active_days"] or 0),
        "consecutive_training_days": int(current["consecutive_training_days"] or 0),
        "previous_week_load": float(previous_week["training_load"]) if previous_week and previous_week["training_load"] is not None else None,
        "previous_week_distance_km": float(previous_week["total_km"]) if previous_week and previous_week["total_km"] is not None else None,
        "baseline_distance_km": round(baseline_distance, 2) if baseline_distance is not None else None,
        "baseline_training_load": round(baseline_load, 1) if baseline_load is not None else None,
        "baseline_active_days": round(baseline_active_days, 1) if baseline_active_days is not None else None,
        "baseline_complete": baseline_complete,
    }


def fetch_monthly_signals(connection: sqlite3.Connection, month_key: str | None = None) -> dict | None:
    current = _month_summary(connection, month_key)
    if current is None:
        return None

    ranked = connection.execute(
        """
        WITH ranked AS (
            SELECT
                month_key,
                month_start,
                month_end,
                activities,
                total_km,
                training_load,
                ROW_NUMBER() OVER (ORDER BY month_start DESC) AS month_rank
            FROM monthly_summary_view
        )
        SELECT *
        FROM ranked
        WHERE month_key = ?
        """,
        (current["month_key"],),
    ).fetchone()
    if not ranked:
        return None

    month_rank = int(ranked["month_rank"])
    baseline_rows = connection.execute(
        """
        WITH ranked AS (
            SELECT
                month_key,
                month_start,
                month_end,
                activities,
                total_km,
                training_load,
                ROW_NUMBER() OVER (ORDER BY month_start DESC) AS month_rank
            FROM monthly_summary_view
        )
        SELECT *
        FROM ranked
        WHERE month_rank BETWEEN ? AND ?
        ORDER BY month_rank
        """,
        (month_rank + 1, month_rank + 3),
    ).fetchall()
    baseline_complete = len(baseline_rows) >= 2

    def avg(rows: list[sqlite3.Row], key: str) -> float | None:
        values = [float(row[key]) for row in rows if row[key] is not None]
        if not values:
            return None
        return sum(values) / len(values)

    baseline_distance = avg(baseline_rows, "total_km")
    baseline_load = avg(baseline_rows, "training_load")
    baseline_activities = avg(baseline_rows, "activities")

    story = connection.execute(
        """
        SELECT *
        FROM journey_month_story_view
        WHERE month_key = ?
        """,
        (current["month_key"],),
    ).fetchone()
    previous_month_key = _previous_month_key(connection, current["month_key"])
    previous_story = (
        connection.execute(
            "SELECT * FROM journey_month_story_view WHERE month_key = ?",
            (previous_month_key,),
        ).fetchone()
        if previous_month_key
        else None
    )

    progress_pct = 100.0
    if current.get("is_partial_month"):
        latest_date = date.fromisoformat(str(current["latest_date"]))
        month_end = date.fromisoformat(str(current["month_end"]))
        progress_pct = round((latest_date.day / month_end.day) * 100, 1)

    def delta(current_value: float | int | None, baseline_value: float | None) -> float | None:
        if current_value is None or baseline_value in (None, 0):
            return None
        return round(((float(current_value) - baseline_value) / baseline_value) * 100, 1)

    return {
        "period_type": "MONTH",
        "period_start": str(current["month_start"]),
        "period_end": str(current["month_end"]),
        "month_key": str(current["month_key"]),
        "month_completeness_pct": progress_pct,
        "monthly_distance_km": float(current["total_km"] or 0),
        "monthly_training_load": float(current["training_load"] or 0),
        "monthly_activity_count": int(current["activities"] or 0),
        "distance_vs_3m_reference_pct": delta(current["total_km"], baseline_distance),
        "load_vs_3m_reference_pct": delta(current["training_load"], baseline_load),
        "activity_count_vs_3m_reference_pct": delta(current["activities"], baseline_activities),
        "long_run_count": int(story["long_runs"] or 0) if story else 0,
        "key_session_count": int(story["quality_sessions"] or 0) if story else 0,
        "previous_month_theme": str(previous_story["chapter_code"]) if previous_story else None,
        "previous_month_verdict": str(previous_story["coach_verdict"]) if previous_story else None,
        "is_partial_month": bool(current.get("is_partial_month")),
        "baseline_distance_km": round(baseline_distance, 2) if baseline_distance is not None else None,
        "baseline_training_load": round(baseline_load, 1) if baseline_load is not None else None,
        "baseline_activity_count": round(baseline_activities, 1) if baseline_activities is not None else None,
        "baseline_complete": baseline_complete,
    }


def fetch_journey_signals(connection: sqlite3.Connection, month_key: str | None = None) -> dict | None:
    target = _month_summary(connection, month_key)
    if target is None:
        return None
    story = connection.execute(
        "SELECT * FROM journey_month_story_view WHERE month_key = ?",
        (target["month_key"],),
    ).fetchone()
    if not story:
        return None
    previous_month_key = _previous_month_key(connection, str(target["month_key"]))
    previous_story = (
        connection.execute("SELECT * FROM journey_month_story_view WHERE month_key = ?", (previous_month_key,)).fetchone()
        if previous_month_key
        else None
    )
    turning_points = connection.execute(
        """
        SELECT milestone_code, milestone_title
        FROM journey_turning_point_view
        WHERE month_key = ?
        ORDER BY milestone_code
        """,
        (target["month_key"],),
    ).fetchall()
    return {
        "period_type": "JOURNEY",
        "period_start": str(story["month_start"]),
        "period_end": str(story["month_end"]),
        "month_key": str(story["month_key"]),
        "selected_month_theme": str(story["chapter_code"]),
        "monthly_distance_trend": float(story["km_delta_pct"]) if story["km_delta_pct"] is not None else None,
        "monthly_load_trend": float(story["load_delta_pct"]) if story["load_delta_pct"] is not None else None,
        "long_run_continuity": bool((story["long_runs"] or 0) >= 1 and previous_story and (previous_story["long_runs"] or 0) >= 1),
        "key_session_continuity": bool((story["quality_sessions"] or 0) >= 1 and previous_story and (previous_story["quality_sessions"] or 0) >= 1),
        "turning_points": tuple(f"{row['milestone_code']}:{row['milestone_title']}" for row in turning_points),
        "previous_chapter": str(previous_story["chapter_code"]) if previous_story else None,
        "current_chapter": str(story["chapter_code"]),
        "quality_sessions": int(story["quality_sessions"] or 0),
        "long_runs": int(story["long_runs"] or 0),
        "is_partial_month": bool(story["is_partial_month"]),
        "baseline_complete": story["baseline_load"] is not None,
    }


def fetch_latest_week_offsets(connection: sqlite3.Connection, count: int = 8) -> list[int]:
    latest = _latest_activity_date(connection)
    if latest is None:
        return []
    return list(range(count))


def fetch_latest_month_keys(connection: sqlite3.Connection, count: int = 6) -> list[str]:
    rows = connection.execute(
        """
        SELECT month_key
        FROM monthly_summary_view
        ORDER BY month_start DESC
        LIMIT ?
        """,
        (count,),
    ).fetchall()
    return [str(row["month_key"]) for row in rows]
