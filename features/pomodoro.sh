#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../core/paths.sh"


source "$(dirname "${BASH_SOURCE[0]}")/voice.sh"
source "$(dirname "${BASH_SOURCE[0]}")/statistics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/notification.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/session_tracker.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/display.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/config_loader.sh"
load_config

pomodoro_start() {
    trap pomodoro_stop INT TERM
    display_init

    echo "active" > "$POMODORO_STATE_FILE"
    echo "0" > "$POMODORO_CYCLE_FILE"

    pomodoro_run
}

pomodoro_run() {
    local cycle=1

    export POMODORO_CURRENT_CYCLE="$cycle"
    export POMODORO_COMPLETED=0

    while [ "$cycle" -le "$pomodoro_cycles" ]; do
        pomodoro_timer_loop "$cycle" "WORK" "$(pomodoro_get_work_seconds)"

        voice_say "Work session finished"

        echo "Break cycle: $cycle"

        pomodoro_timer_loop "$cycle" "BREAK" "$(pomodoro_get_break_seconds)"

        voice_say "Break finished"

        echo "$cycle" > "$POMODORO_CYCLE_FILE"

        pomodoro_session_progress_bar "$cycle" "$pomodoro_cycles"

        POMODORO_COMPLETED="$cycle"
        export POMODORO_COMPLETED

        cycle=$((cycle + 1))
    done

    statistics_increment pomodoro_cycles

    send_notification "Pomodoro completed"

    echo "Pomodoro completed"
}

pomodoro_stop() {
    if [ -f "$POMODORO_PID_FILE" ]; then
        local pid
        pid="$(cat "$POMODORO_PID_FILE")"

        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
        fi

        rm -f "$POMODORO_PID_FILE"
    fi

    rm -f "$POMODORO_STATE_FILE"
    rm -f "$POMODORO_CYCLE_FILE"
    rm -f "$POMODORO_PROGRESS_FILE"

    echo "Pomodoro stopped"
    exit 0
}

pomodoro_status() {
    if [ -f "$POMODORO_STATE_FILE" ]; then
        echo "Pomodoro active"

        if [ -f "$POMODORO_CYCLE_FILE" ]; then
            echo "Completed cycles: $(cat "$POMODORO_CYCLE_FILE")"
        fi
    else
        echo "Pomodoro inactive"
    fi
}

pomodoro_get_work_seconds() {
    echo $((pomodoro_work_duration * 60))
}

pomodoro_get_break_seconds() {
    echo $((pomodoro_break_duration * 60))
}

pomodoro_timer_loop() {
    local cycle="$1"
    local mode="$2"
    local total_seconds="$3"

    if [ "$mode" = "WORK" ] || [ "$mode" = "BREAK" ]; then
        session_start "POMODORO_$mode" "$total_seconds"
    fi

    local current=0

    while [ "$current" -lt "$total_seconds" ]; do

        while [ "$SESSION_PAUSED" = true ]; do
            read -rsn1 -t 1 key

            if [ "$key" = "1" ]; then
                SESSION_PAUSED=false
            fi
        done
        local remaining=$((total_seconds - current))
        local percent=$((current * 100 / total_seconds))

        display_session \
            "POMODORO" \
            "${cycle}/${pomodoro_cycles}" \
            "$mode" \
            "$(pomodoro_format_time "$remaining")" \
            "$percent"

        read -rsn1 -t 1 key


        case "$key" in
            1)
                SESSION_PAUSED=false
                ;;

            2)
                SESSION_PAUSED=true
                ;;

            3)
                session_reset
                echo "Pomodoro reset"
                exit 0
                ;;

            4)
                pomodoro_stop
                ;;

            5)
                session_save
                exit 0
                ;;
        esac

        SESSION_ACTIVE=$((SESSION_ACTIVE + 1))

        current=$((current + 1))
    done


    if [ "$mode" = "WORK" ] || [ "$mode" = "BREAK" ]; then
        session_finish "$total_seconds"
    fi
}

pomodoro_format_time() {
    local seconds="$1"

    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))

    printf "%02dm %02ds" "$minutes" "$secs"
}

pomodoro_progress_bar() {
    local percent="$1"
    local width=20

    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    printf "["

    printf "%${filled}s" | tr " " "#"
    printf "%${empty}s" | tr " " "-"

    printf "] %s%%" "$percent"
}

pomodoro_session_progress_bar() {
    local completed="$1"
    local total="$2"

    local percent=$((completed * 100 / total))

    echo -n "Session: "
    pomodoro_progress_bar "$percent"
    echo
    echo "Completed: ${completed}/${total}"
}

pomodoro_reset() {
    rm -f "$POMODORO_STATE_FILE"
    rm -f "$POMODORO_CYCLE_FILE"
    rm -f "$POMODORO_PROGRESS_FILE"

    echo "Pomodoro reset"
}
