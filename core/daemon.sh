#!/usr/bin/env bash

run_daemon() {
    source "$(dirname "${BASH_SOURCE[0]}")/../features/reminder.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../features/sound.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../features/voice.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../features/screen_rest.sh"

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
