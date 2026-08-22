#!/usr/bin/env bash

window_is_active() {
    local target_app="$1"

    command -v swaymsg >/dev/null 2>&1 || return 1
    command -v jq >/dev/null 2>&1 || return 1

    swaymsg -t get_tree |
        jq -e '.. | objects | select(.focused == true) | .app_id == "'"$target_app"'"' >/dev/null
}
