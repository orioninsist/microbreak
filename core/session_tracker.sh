#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/database.sh"

SESSION_ID=""
SESSION_MODE=""
SESSION_TARGET=0
SESSION_START=0

session_start() {
    SESSION_MODE="$1"
    SESSION_TARGET="$2"
    SESSION_START="$(date +%s)"

    sqlite3 "$DB_FILE" <<SQL
INSERT INTO sessions (
    mode,
    start_time,
    target_seconds,
    actual_seconds,
    completion_percent,
    completed,
    cycles,
    status
)
VALUES (
    '$SESSION_MODE',
    datetime('now'),
    $SESSION_TARGET,
    0,
    0,
    0,
    1,
    'running'
);
SQL

    SESSION_ID="$(sqlite3 "$DB_FILE" "SELECT MAX(id) FROM sessions;")"
}

PAUSE_START=0
PAUSE_TOTAL=0
SESSION_PAUSED=false

session_pause() {
    PAUSE_START="$(date +%s)"
    SESSION_PAUSED=true
}

session_resume() {
    SESSION_PAUSED=false

    local now
    now="$(date +%s)"

    if [ "$PAUSE_START" -gt 0 ]; then
        PAUSE_TOTAL=$((PAUSE_TOTAL + now - PAUSE_START))
        PAUSE_START=0
    fi
}

session_finish() {
    local actual_seconds="$1"

    local percent=0
    local completed=0

    if [ "$SESSION_TARGET" -gt 0 ]; then
        percent=$((actual_seconds * 100 / SESSION_TARGET))
    fi

    if [ "$percent" -ge 100 ]; then
        percent=100
        completed=1
    fi

    sqlite3 "$DB_FILE" <<SQL
UPDATE sessions
SET
    end_time = datetime('now'),
    active_seconds = $actual_seconds,
    actual_seconds = $actual_seconds,
    pause_seconds = $PAUSE_TOTAL,
    completion_percent = $percent,
    completed = $completed,
    status = 'completed'
WHERE id = $SESSION_ID;
SQL
}

session_save() {
    local actual_seconds="${SESSION_ACTIVE:-0}"

    sqlite3 "$DB_FILE" <<SQL
UPDATE sessions
SET
    active_seconds = $actual_seconds,
    actual_seconds = $actual_seconds,
    pause_seconds = $PAUSE_TOTAL,
    end_time = datetime('now'),
    status = 'saved'
WHERE id = $SESSION_ID;
SQL

    echo "Session saved"
}

session_reset() {
    SESSION_ACTIVE=0
    SESSION_START=0
    SESSION_ID=""
    PAUSE_START=0
    PAUSE_TOTAL=0

}
