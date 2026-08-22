#!/usr/bin/env bash

usage_tracker_loop() {
    while true; do
        usage_track_once 10
        sleep 10
    done
}

run_daemon() {
    source "$(dirname "${BASH_SOURCE[0]}")/../features/reminder.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../features/sound.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../features/voice.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../features/screen_rest.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../features/usage_tracker.sh"

    usage_tracker_init

    usage_tracker_loop &

    while true; do
        echo "Microbreak daemon running"


        run_timer "$timer_seconds"

        if [ "$sound_enabled" = "true" ] && [ -n "$sound_file" ]; then
            play_sound "$sound_file"
        fi

        send_break_reminder "Time for a microbreak"

        if [ "$screen_rest" = true ]; then
            screen_rest_start
        fi

        sleep 1
    done
}
