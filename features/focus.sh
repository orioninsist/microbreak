#!/usr/bin/env bash

FOCUS_STATE_FILE="/tmp/microbreak_focus.state"

source "$(dirname "${BASH_SOURCE[0]}")/statistics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/notification.sh"

source "$(dirname "${BASH_SOURCE[0]}")/../core/break_trigger.sh"

focus_start() {
    echo "active" > "$FOCUS_STATE_FILE"

    echo "Focus started"
    echo "Duration: ${focus_duration} minutes"

    focus_timer_loop "$(focus_get_seconds)"

    statistics_increment focus_sessions

    send_notification "Focus completed"

    echo "Focus completed"

    trigger_microbreak
}

focus_stop() {
    rm -f "$FOCUS_STATE_FILE"
    echo "Focus stopped"
}

focus_status() {
    if [ -f "$FOCUS_STATE_FILE" ]; then
        echo "Focus active"
        echo "Duration: ${focus_duration} minutes"
    else
        echo "Focus inactive"
    fi
}

focus_get_seconds() {
    echo $((focus_duration * 60))
}

focus_progress() {
    local percent="$1"
    local remaining="$2"

    clear

    echo "Focus Progress"
    echo
    echo "Mode: FOCUS"
    echo
    echo "Session Duration: $(pomodoro_format_time "$(focus_get_seconds)")"
    echo
    echo -n "Current: "
    pomodoro_progress_bar "$percent"
    echo
    echo
    echo "Remaining: $(pomodoro_format_time "$remaining")"
}

focus_timer_loop() {
    local total_seconds="$1"

    local current=0

    while [ "$current" -lt "$total_seconds" ]; do
        local remaining=$((total_seconds - current))
        local percent=$((current * 100 / total_seconds))

        focus_progress "$percent" "$remaining"

        sleep 1

        current=$((current + 1))
    done

    focus_progress "100" "0"
}
