#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sqlite3
from pathlib import Path

try:
    from semantic_layer import ensure_semantic_layer
except ModuleNotFoundError:
    from analysis_platform.semantic_layer import ensure_semantic_layer


def connect(db_path: Path):
    connection = sqlite3.connect(db_path)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    ensure_semantic_layer(connection)
    return connection


def print_table(rows):
    rows = list(rows)
    if not rows:
        print("(no rows)")
        return

    headers = rows[0].keys()
    widths = {
        header: max(len(str(header)), *(len("" if row[header] is None else str(row[header])) for row in rows))
        for header in headers
    }
    print(" | ".join(str(header).ljust(widths[header]) for header in headers))
    print("-+-".join("-" * widths[header] for header in headers))
    for row in rows:
        print(" | ".join(("" if row[header] is None else str(row[header])).ljust(widths[header]) for header in headers))


def summary(connection):
    rows = connection.execute(
        """
        SELECT
            activities,
            total_km,
            total_time_sec,
            avg_pace_sec_per_km,
            avg_hr
        FROM platform_summary_view
        """
    )
    print_table(rows)


def recent(connection, limit):
    rows = connection.execute(
        """
        SELECT
            activity_id,
            activity_start_time,
            distance_km,
            avg_pace_sec_per_km,
            avg_hr,
            training_load,
            workout_type_name_en,
            shoe_display_name
        FROM recent_activity_view
        ORDER BY activity_start_time DESC
        LIMIT ?
        """,
        (limit,),
    )
    print_table(rows)


def splits(connection, activity_id):
    rows = connection.execute(
        """
        SELECT
            split_index,
            split_distance_m,
            elapsed_pace_sec_per_km,
            avg_hr,
            avg_power_w
        FROM kilometer_split_view
        WHERE activity_id = ?
        ORDER BY split_index
        """,
        (activity_id,),
    )
    print_table(rows)


def week(connection):
    rows = connection.execute(
        """
        SELECT
            week_offset,
            start_date,
            end_date,
            activities,
            total_km,
            total_time_sec,
            avg_pace_sec_per_km,
            avg_hr,
            training_load
        FROM weekly_summary_view
        ORDER BY week_offset
        """
    )
    print_table(rows)


def shoes(connection):
    rows = connection.execute(
        """
        SELECT
            shoe_code,
            category,
            run_count,
            total_distance_km,
            avg_pace_sec_per_km,
            avg_hr,
            avg_training_load
        FROM shoe_comparison_view
        ORDER BY total_distance_km DESC, run_count DESC
        """
    )
    print_table(rows)


def distribution(connection):
    rows = connection.execute(
        """
        SELECT
            workout_type_name_en,
            primary_training_purpose_name_en,
            activity_count,
            total_km,
            avg_training_load
        FROM training_distribution_view
        ORDER BY total_km DESC, activity_count DESC
        """
    )
    print_table(rows)


def main():
    parser = argparse.ArgumentParser(description="Query the Running Analytics SQLite database.")
    parser.add_argument("db", type=Path, help="SQLite database path.")

    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("summary", help="Show total activity count and total distance.")

    recent_parser = subparsers.add_parser("recent", help="Show recent activities.")
    recent_parser.add_argument("--limit", type=int, default=10)

    splits_parser = subparsers.add_parser("splits", help="Show split details for one activity.")
    splits_parser.add_argument("activity_id", type=int)

    subparsers.add_parser("week", help="Show rolling 7-day weekly summary view.")
    subparsers.add_parser("shoes", help="Show shoe comparison view.")
    subparsers.add_parser("distribution", help="Show workout / purpose distribution view.")

    args = parser.parse_args()
    with connect(args.db) as connection:
        if args.command == "summary":
            summary(connection)
        elif args.command == "recent":
            recent(connection, args.limit)
        elif args.command == "splits":
            splits(connection, args.activity_id)
        elif args.command == "week":
            week(connection)
        elif args.command == "shoes":
            shoes(connection)
        elif args.command == "distribution":
            distribution(connection)


if __name__ == "__main__":
    main()
