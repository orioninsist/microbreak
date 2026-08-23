#!/usr/bin/env bash

display_init() {
    clear
    tput civis
}

display_center() {
    local text="$1"
    local width

    width=$(tput cols 2>/dev/null || echo 80)

    printf "%*s\n" $(((${#text} + width) / 2)) "$text"
}

display_vertical_center() {
    local height

    height=$(tput lines 2>/dev/null || echo 24)

    printf '\n%.0s' $(seq 1 $((height / 4)))
}

display_header() {
    printf '\n'
    display_center "$1"
    printf '\n'
}

display_controls() {
    printf '\n'
    display_center "[1] RESUME        [2] PAUSE"
    printf '\n'
    display_center "[3] RESET         [4] EXIT"
    printf '\n'
    display_center "[5] SAVE"
}

display_progress() {
    local percent="$1"
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    printf '['
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf '%*s' "$empty" '' | tr ' ' '-'
    printf '] %s%%\n' "$percent"
}

display_session() {
    local title="$1"
    local cycle="$2"
    local mode="$3"
    local time="$4"
    local percent="$5"

    tput cup 0 0

    display_vertical_center

    display_header "$title"

    printf '\n'

    display_center "CYCLE"
    display_center "$cycle"

    printf '\n'

    display_center "MODE"
    display_center "$mode"

    printf '\n'

    display_center "TIME"
    display_center "$time"

    printf '\n'

    display_center "PROGRESS"

    printf '\n'
    display_center "$(display_progress "$percent")"

    display_controls
}

display_exit() {
    tput cnorm
}
