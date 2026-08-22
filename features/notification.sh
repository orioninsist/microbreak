#!/usr/bin/env bash

send_notification() {
    local message="$1"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Microbreak" "$message"
    else
        echo "Notification: $message"
    fi
}
