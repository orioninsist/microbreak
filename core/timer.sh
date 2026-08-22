#!/usr/bin/env bash

run_timer() {
    local seconds="$1"

    if [ -z "$seconds" ]; then
        echo "Timer value missing"
        return 1
    fi

    sleep "$seconds"

    echo "Timer completed"
}
