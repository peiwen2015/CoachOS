from __future__ import annotations

import sqlite3
import threading
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PROJECT_ROOT = ROOT.parent
SEMANTIC_LAYER_SQL_PATH = PROJECT_ROOT / "docs" / "30_Physical_Model" / "Semantic Layer v1.0.sql"
_SEMANTIC_LAYER_LOCK = threading.Lock()
_READY_DATABASES: set[str] = set()


def _database_identity(connection: sqlite3.Connection) -> str:
    row = connection.execute("PRAGMA database_list").fetchone()
    if not row:
        return "<unknown>"
    # seq, name, file
    return str(row[2] or "<memory>")


def ensure_semantic_layer(connection: sqlite3.Connection) -> None:
    connection.execute("PRAGMA foreign_keys = ON")
    database_id = _database_identity(connection)
    if database_id in _READY_DATABASES:
        return
    with _SEMANTIC_LAYER_LOCK:
        if database_id in _READY_DATABASES:
            return
        connection.executescript(SEMANTIC_LAYER_SQL_PATH.read_text(encoding="utf-8"))
        _READY_DATABASES.add(database_id)
