#!/usr/bin/env bash

POMODORO_STATE_FILE="/tmp/microbreak_pomodoro.state"
POMODORO_CYCLE_FILE="/tmp/microbreak_pomodoro.cycle"
POMODORO_PID_FILE="/tmp/microbreak_pomodoro.pid"

source "$(dirname "${BASH_SOURCE[0]}")/voice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/statistics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/notification.sh"

pomodoro_start() {
    echo "active" > "$POMODORO_STATE_FILE"
    echo "0" > "$POMODORO_CYCLE_FILE"

    echo "Pomodoro started"
    echo "Cycles: ${pomodoro_cycles}"

    pomodoro_run &
    echo $! > "$POMODORO_PID_FILE"
}

pomodoro_run() {
    local cycle=1

    while [ "$cycle" -le "$pomodoro_cycles" ]; do
        echo "Work cycle: $cycle"

        sleep "$(pomodoro_get_work_seconds)"

        voice_say "Work session finished"

        echo "Break cycle: $cycle"

        sleep "$(pomodoro_get_break_seconds)"

        voice_say "Break finished"

        echo "$cycle" > "$POMODORO_CYCLE_FILE"

        cycle=$((cycle + 1))
    done

    statistics_increment pomodoro_cycles

    send_notification "Pomodoro completed"

    echo "Pomodoro completed"
}

pomodoro_stop() {
    if [ -f "$POMODORO_PID_FILE" ]; then
        local pid
        pid="$(cat "$POMODORO_PID_FILE")"

        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
        fi

        rm -f "$POMODORO_PID_FILE"
    fi

    rm -f "$POMODORO_STATE_FILE"
    rm -f "$POMODORO_CYCLE_FILE"

    echo "Pomodoro stopped"
}

pomodoro_status() {
    if [ -f "$POMODORO_STATE_FILE" ]; then
        echo "Pomodoro active"

        if [ -f "$POMODORO_CYCLE_FILE" ]; then
            echo "Completed cycles: $(cat "$POMODORO_CYCLE_FILE")"
        fi
    else
        echo "Pomodoro inactive"
    fi
}

pomodoro_get_work_seconds() {
    echo $((pomodoro_work_duration * 60))
}

pomodoro_get_break_seconds() {
    echo $((pomodoro_break_duration * 60))
}
