#!/usr/bin/env bash

send_break_reminder() {
    local message="$1"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Microbreak" "$message"
    else
        echo "Microbreak: $message"
    fi

    sleep "$notification_timeout"

    stop_sound
}
