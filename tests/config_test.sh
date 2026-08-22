#!/usr/bin/env bash

source "$(dirname "$0")/../core/config_loader.sh"

load_config || exit 1

test_result=0

check_value() {
    local name="$1"
    local expected="$2"
    local actual="${!name}"

    if [ "$actual" != "$expected" ]; then
        echo "FAIL: $name"
        test_result=1
    else
        echo "PASS: $name"
    fi
}

check_value "microbreak_timer" "true"
check_value "focus_mode" "true"
check_value "pomodoro_mode" "true"
check_value "statistics" "true"

exit "$test_result"
