#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../core/paths.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/window_tracker.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/display.sh"

source "$(dirname "${BASH_SOURCE[0]}")/statistics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/notification.sh"

source "$(dirname "${BASH_SOURCE[0]}")/../core/break_trigger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/config_loader.sh"
load_config

focus_start() {
    display_init

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

focus_timer_loop() {
    local total_seconds="$1"

    local current=0

    while [ "$current" -lt "$total_seconds" ]; do
        local remaining=$((total_seconds - current))
        local percent=$((current * 100 / total_seconds))

        display_session \
            "FOCUS" \
            "-" \
            "FOCUS" \
            "$(pomodoro_format_time "$remaining")" \
            "$percent"

        read -rsn1 -t 1 key

        case "$key" in
            1)
                FOCUS_PAUSED=false
                ;;

            2)
                FOCUS_PAUSED=true
                ;;

            3)
                display_exit
                echo "Focus reset"
                exit 0
                ;;

            4)
                display_exit
                focus_stop
                exit 0
                ;;

            5)
                display_exit
                echo "Focus saved"
                exit 0
                ;;
        esac

        while [ "$FOCUS_PAUSED" = true ]; do
            read -rsn1 -t 1 key

            if [ "$key" = "1" ]; then
                FOCUS_PAUSED=false
            fi
        done

        sleep 1

        current=$((current + 1))
    done

    display_session \
        "FOCUS" \
        "-" \
        "FOCUS" \
        "00m 00s" \
        "100"
}
