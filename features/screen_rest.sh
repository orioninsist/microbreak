#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/statistics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/notification.sh"

screen_rest_start() {
    echo "Screen Rest started"

    send_notification "Please take a screen break"

    voice_say "Please take a screen break"

    swaymsg "output * dpms off"

    sleep "$screen_rest_seconds"

    swaymsg "output * dpms on"

    send_notification "Screen break finished"

    voice_say "Screen break finished"

    statistics_increment screen_rests

    echo "Screen Rest completed"
}
