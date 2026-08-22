#!/usr/bin/env bash

DB_DIR="$(dirname "${BASH_SOURCE[0]}")/../storage"
DB_FILE="$DB_DIR/microbreak.db"

database_init() {
    mkdir -p "$DB_DIR"

    sqlite3 "$DB_FILE" <<SQL
CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mode TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT,
    active_seconds INTEGER DEFAULT 0,
    pause_seconds INTEGER DEFAULT 0,
    status TEXT DEFAULT 'running',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
SQL
}
