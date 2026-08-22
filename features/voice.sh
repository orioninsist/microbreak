#!/usr/bin/env bash

VOICE_MODEL="$HOME/piper-voices/en_US-amy-medium.onnx"

voice_say() {
    local text="$1"
    local output="/tmp/microbreak_voice.wav"

    echo "$text" | \
    piper \
        -m "$VOICE_MODEL" \
        -f "$output"

    paplay "$output"
}
