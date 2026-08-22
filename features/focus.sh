#!/usr/bin/env bash

FOCUS_STATE_FILE="/tmp/microbreak_focus.state"

source "$(dirname "${BASH_SOURCE[0]}")/statistics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/notification.sh"

source "$(dirname "${BASH_SOURCE[0]}")/../core/break_trigger.sh"

focus_start() {
    echo "active" > "$FOCUS_STATE_FILE"

    echo "Focus started"
    echo "Duration: ${focus_duration} minutes"

    sleep "$focus_test_seconds"

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
