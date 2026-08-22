#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../core/database.sh"

STATS_FILE="$HOME/.local/state/microbreak/statistics"

statistics_init() {
    if [ ! -f "$STATS_FILE" ]; then
        cat > "$STATS_FILE" <<DATA
focus_sessions=0
pomodoro_cycles=0
screen_rests=0
DATA
    fi
}


statistics_increment() {
    local key="$1"

    statistics_init

    local value
    value=$(grep "^${key}=" "$STATS_FILE" | cut -d= -f2)

    value=$((value + 1))

    sed -i "s/^${key}=.*/${key}=${value}/" "$STATS_FILE"
}

statistics_daily() {
    sqlite3 "$DB_FILE" \
    "SELECT
        CASE
            WHEN mode = 'POMODORO' THEN 'POMODORO_WORK'
            ELSE mode
        END,
        COUNT(*),
        SUM(actual_seconds)
     FROM sessions
     WHERE date(created_at) = date('now')
     GROUP BY
    CASE
        WHEN mode = 'POMODORO' THEN 'POMODORO_WORK'
        ELSE mode
    END;" |
    while IFS="|" read -r mode sessions seconds; do
        echo
        echo "$mode"
        echo "Sessions: $sessions"
        echo "Time: $(format_duration "$seconds")"
    done
}

statistics_weekly() {
    sqlite3 "$DB_FILE" \
    "SELECT
        CASE
            WHEN mode = 'POMODORO' THEN 'POMODORO_WORK'
            ELSE mode
        END,
        COUNT(*),
        SUM(actual_seconds)
     FROM sessions
     WHERE strftime('%W', created_at) = strftime('%W', 'now')
     AND strftime('%Y', created_at) = strftime('%Y', 'now')
     GROUP BY
        CASE
            WHEN mode = 'POMODORO' THEN 'POMODORO_WORK'
            ELSE mode
        END;" |
    while IFS="|" read -r mode sessions seconds; do
        echo
        echo "$mode"
        echo "Sessions: $sessions"
        echo "Time: $(format_duration "$seconds")"
    done
}


statistics_monthly() {
    local month="${1:-$(date +%m)}"
    local year="${2:-$(date +%Y)}"

    sqlite3 "$DB_FILE" \
    "SELECT
        CASE
            WHEN mode = 'POMODORO' THEN 'POMODORO_WORK'
            ELSE mode
        END,
        COUNT(*),
        SUM(actual_seconds)
     FROM sessions
     WHERE strftime('%m', created_at) = '$month'
     AND strftime('%Y', created_at) = '$year'
     GROUP BY
        CASE
            WHEN mode = 'POMODORO' THEN 'POMODORO_WORK'
            ELSE mode
        END;" |
    while IFS="|" read -r mode sessions seconds; do
        echo
        echo "$mode"
        echo "Sessions: $sessions"
        echo "Time: $(format_duration "$seconds")"
    done
}

format_duration() {
    local seconds="$1"

    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [ "$hours" -gt 0 ]; then
        printf "%dh %02dm" "$hours" "$minutes"
    elif [ "$minutes" -gt 0 ]; then
        printf "%dm" "$minutes"
    else
        printf "%ds" "$secs"
    fi
}
