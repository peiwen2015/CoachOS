#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sqlite3
from copy import copy
from pathlib import Path

from openpyxl import load_workbook


ROOT = Path(__file__).resolve().parent
DEFAULT_EXCEL_DIR = ROOT / "EXCEL"
DEFAULT_DB_PATH = ROOT / "analysis_platform" / "running_analytics.sqlite"

ACTIVITY_ID_PATTERN = re.compile(r"_(\d+)\.xlsx$")


def backfill_sqlite_activity_max_hr(db_path: Path, month: str | None = None) -> int:
    params: tuple[str, ...] = ()
    sql = f"""
    WITH split_max AS (
      SELECT activity_id, MAX(max_hr) AS split_max_hr
      FROM kilometer_split
      GROUP BY activity_id
    )
    UPDATE activity
    SET max_hr = (
      SELECT split_max_hr
      FROM split_max
      WHERE split_max.activity_id = activity.id
    )
    WHERE id IN (
      SELECT activity_id
      FROM split_max
      WHERE split_max_hr IS NOT NULL
    );
    """
    if month:
        params = (f"{month}-%",)
        sql = f"""
        WITH split_max AS (
          SELECT ks.activity_id, MAX(ks.max_hr) AS split_max_hr
          FROM kilometer_split ks
          JOIN activity a ON a.id = ks.activity_id
          WHERE a.activity_start_time LIKE ?
          GROUP BY ks.activity_id
        )
        UPDATE activity
        SET max_hr = (
          SELECT split_max_hr
          FROM split_max
          WHERE split_max.activity_id = activity.id
        )
        WHERE id IN (
          SELECT activity_id
          FROM split_max
          WHERE split_max_hr IS NOT NULL
        );
        """
    with sqlite3.connect(db_path) as connection:
        cursor = connection.cursor()
        cursor.execute(sql, params)
        connection.commit()
        return connection.total_changes


def load_activity_max_hr_by_garmin_id(db_path: Path, month: str | None = None) -> dict[str, int]:
    query = """
        SELECT garmin_activity_id, max_hr
        FROM activity
        WHERE garmin_activity_id IS NOT NULL
          AND max_hr IS NOT NULL
    """
    params: tuple[str, ...] = ()
    if month:
        query += " AND activity_start_time LIKE ?"
        params = (f"{month}-%",)
    with sqlite3.connect(db_path) as connection:
        rows = connection.execute(query, params).fetchall()
    return {str(garmin_activity_id): int(max_hr) for garmin_activity_id, max_hr in rows}


def parse_garmin_activity_id(path: Path) -> str | None:
    match = ACTIVITY_ID_PATTERN.search(path.name)
    return match.group(1) if match else None


def clone_row_style(ws, source_row: int, target_row: int) -> None:
    for col in range(1, 3):
        source = ws.cell(source_row, col)
        target = ws.cell(target_row, col)
        if source.has_style:
            target._style = copy(source._style)
        if source.number_format:
            target.number_format = source.number_format
        if source.alignment:
            target.alignment = copy(source.alignment)
        if source.font:
            target.font = copy(source.font)
        if source.fill:
            target.fill = copy(source.fill)
        if source.border:
            target.border = copy(source.border)


def ensure_activity_hr_row(workbook_path: Path, activity_max_hr: int) -> bool:
    wb = load_workbook(workbook_path)
    if "活動資訊" not in wb.sheetnames:
        return False

    ws = wb["活動資訊"]
    personal_row = None
    activity_row = None
    changed = False

    for row in range(1, ws.max_row + 1):
        label = ws.cell(row, 1).value
        if label == "最大心率":
            ws.cell(row, 1, "個人最大心率")
            changed = True
            personal_row = row
        elif label == "個人最大心率":
            personal_row = row
        elif label == "活動最高心率":
            activity_row = row
        elif label == "Critical Power (W)":
            ws.cell(row, 1, "個人臨界功率")
            changed = True
        elif label == "Critical Power(W)":
            ws.cell(row, 1, "個人臨界功率")
            changed = True
        elif label == "Training Effect (Aerobic)":
            ws.cell(row, 1, "有氧訓練效果")
            changed = True
        elif label == "Training Effect (Anaerobic)":
            ws.cell(row, 1, "無氧訓練效果")
            changed = True
        elif label == "Training Load":
            ws.cell(row, 1, "訓練負荷")
            changed = True
        elif label == "Recovery Time (hr)":
            ws.cell(row, 1, "恢復時間（小時）")
            changed = True
        elif label == "Stamina 起始 (%)":
            ws.cell(row, 1, "體力起始 (%)")
            changed = True
        elif label == "Stamina 結束 (%)":
            ws.cell(row, 1, "體力結束 (%)")
            changed = True

    if personal_row is None:
        return False

    if activity_row is None:
        insert_at = personal_row + 1
        ws.insert_rows(insert_at)
        clone_row_style(ws, personal_row, insert_at)
        ws.cell(insert_at, 1, "活動最高心率")
        ws.cell(insert_at, 2, activity_max_hr)
        changed = True
    else:
        if ws.cell(activity_row, 2).value != activity_max_hr:
            ws.cell(activity_row, 2, activity_max_hr)
            changed = True

    if changed or ws.cell(personal_row, 1).value != "個人最大心率":
        wb.save(workbook_path)
        return True
    return False


def repair_excel_workbooks(excel_dir: Path, db_path: Path, month: str | None = None) -> tuple[int, int]:
    hr_by_garmin_id = load_activity_max_hr_by_garmin_id(db_path, month)
    target_dir = excel_dir / month if month else excel_dir
    scanned = 0
    updated = 0
    for workbook_path in target_dir.rglob("*.xlsx"):
        garmin_activity_id = parse_garmin_activity_id(workbook_path)
        if not garmin_activity_id:
            continue
        activity_max_hr = hr_by_garmin_id.get(garmin_activity_id)
        if activity_max_hr is None:
            continue
        scanned += 1
        if ensure_activity_hr_row(workbook_path, activity_max_hr):
            updated += 1
    return scanned, updated


def main() -> None:
    parser = argparse.ArgumentParser(description="Repair activity max heart rate artifacts in SQLite and Excel workbooks.")
    parser.add_argument("--sqlite-db", type=Path, default=DEFAULT_DB_PATH)
    parser.add_argument("--excel-dir", type=Path, default=DEFAULT_EXCEL_DIR)
    parser.add_argument("--month", help="Repair only one month, e.g. 2026-07")
    parser.add_argument("--skip-sqlite", action="store_true")
    parser.add_argument("--skip-excel", action="store_true")
    args = parser.parse_args()

    if not args.skip_sqlite:
        sqlite_changes = backfill_sqlite_activity_max_hr(args.sqlite_db, args.month)
        print(f"SQLite repaired: {sqlite_changes} row updates")

    if not args.skip_excel:
        scanned, updated = repair_excel_workbooks(args.excel_dir, args.sqlite_db, args.month)
        print(f"Excel repaired: {updated}/{scanned} workbooks updated")


if __name__ == "__main__":
    main()
