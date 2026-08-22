#!/usr/bin/env bash

source "$(dirname "$0")/../core/timer.sh"

output="$(run_timer 1)"

if [ "$output" = "Timer completed" ]; then
    echo "PASS: timer"
    exit 0
else
    echo "FAIL: timer"
    exit 1
fi
