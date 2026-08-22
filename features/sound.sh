#!/usr/bin/env bash

SOUND_PID_FILE="/tmp/microbreak_sound.pid"

play_sound() {
    local sound_file="$1"

    if [ -z "$sound_file" ]; then
        echo "Sound file missing"
        return 1
    fi

    if command -v paplay >/dev/null 2>&1; then
        paplay "$sound_file" &
        echo $! > "$SOUND_PID_FILE"
    else
        echo "Sound: $sound_file"
    fi
}

stop_sound() {
    if [ -f "$SOUND_PID_FILE" ]; then
        kill "$(cat "$SOUND_PID_FILE")" 2>/dev/null || true
        rm -f "$SOUND_PID_FILE"
    fi
}
