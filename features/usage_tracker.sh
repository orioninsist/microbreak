#!/usr/bin/env bash

USAGE_DB="$HOME/.local/state/microbreak/usage.db"

usage_tracker_init() {
    mkdir -p "$(dirname "$USAGE_DB")"

    if [ ! -f "$USAGE_DB" ]; then
        touch "$USAGE_DB"
    fi
}

usage_get_open_apps() {
    swaymsg -t get_tree |
        jq -r '.. | objects | select(.app_id != null or .window_properties.class != null) | .app_id // .window_properties.class' |
        sort -u
}

usage_record_time() {
    local app="$1"
    local seconds="$2"

    [ -n "$app" ] || return

    local date
    date="$(date +%F)"

    if grep -q "^${date}|${app}|" "$USAGE_DB"; then
        local current
        current=$(grep "^${date}|${app}|" "$USAGE_DB" | cut -d'|' -f3)

        local total
        total=$((current + seconds))

        sed -i "s/^${date}|${app}|.*/${date}|${app}|${total}/" "$USAGE_DB"
    else
        echo "${date}|${app}|${seconds}" >> "$USAGE_DB"
    fi
}

usage_report() {
    local period="${1:-today}"
    local limit="${2:-10}"

    local start_date
    start_date="$(usage_get_start_date "$period")"

    echo "Usage Statistics"
    echo
    echo "Period: $period"
    echo

    local total_apps
    total_apps=$(usage_filter_records "$period" | cut -d'|' -f2 | sort -u | wc -l)

    echo "Total Applications: $total_apps"
    if [ "$limit" = "all" ]; then
        echo "Showing: All"
    else
        echo "Showing: Top $limit"
    fi
    echo

    if [ -n "$start_date" ]; then
        usage_filter_records "$period" |
            awk -F'|' '{sum[$2]+=$3} END {for (app in sum) print sum[app], app}' |
            sort -nr |
            if [ "$limit" = "all" ]; then
                cat
            else
                head -n "$limit"
            fi |
            while read -r seconds app; do
                printf "%-15s %s\n" "$app" "$(usage_format_time "$seconds")"
            done
    fi
}

usage_format_time() {
    local seconds="$1"

    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [ "$hours" -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    elif [ "$minutes" -gt 0 ]; then
        echo "${minutes}m"
    else
        echo "${secs}s"
    fi
}

usage_get_start_date() {
    local period="$1"

    case "$period" in
        today)
            date +%F
            ;;
        week)
            date -d "7 days ago" +%F
            ;;
        month)
            date -d "$(date +%Y-%m-01)" +%F
            ;;
        all)
            echo "0000-00-00"
            ;;
        *)
            date +%F
            ;;
    esac
}

usage_filter_records() {
    local period="$1"

    case "$period" in
        today)
            grep "$(date +%F)" "$USAGE_DB"
            ;;
        week)
            awk -F'|' -v start="$(date -d '7 days ago' +%F)" '$1 >= start' "$USAGE_DB"
            ;;
        month)
            awk -F'|' -v start="$(date +%Y-%m-01)" '$1 >= start' "$USAGE_DB"
            ;;
        all)
            cat "$USAGE_DB"
            ;;
    esac
}

usage_track_once() {
    local interval="${1:-10}"

    usage_get_open_apps |
    while read -r app; do
        [ -n "$app" ] || continue

        usage_record_time "$app" "$interval"
    done
}
