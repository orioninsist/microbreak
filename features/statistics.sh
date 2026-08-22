#!/usr/bin/env bash

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
