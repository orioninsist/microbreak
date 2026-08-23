#!/usr/bin/env bash

MOUSE_POSITION_FILE="/tmp/microbreak_mouse_position"

mouse_tracker_start() {
    while read -r line; do
        if echo "$line" | grep -q "motion:"; then
            position=$(echo "$line" | sed -n 's/.*x, y: *\([^,]*\), *\([^ ]*\).*$/\1 \2/p')
            [ -n "$position" ] && echo "$position" > "$MOUSE_POSITION_FILE"
        fi
    done < <(wev 2>/dev/null)
}

mouse_tracker_ensure() {
    if ! pgrep -f "wev" >/dev/null 2>&1; then
        mouse_tracker_start &
        sleep 1
    fi
}

mouse_get_position() {
    if [ ! -f "$MOUSE_POSITION_FILE" ]; then
        return
    fi

    cat "$MOUSE_POSITION_FILE"
}

mouse_get_window_app() {
    local position
    position="$(mouse_get_position)"

    [ -n "$position" ] || return

    local mouse_x
    local mouse_y

    mouse_x="${position% *}"
    mouse_y="${position#* }"

    swaymsg -t get_tree |
        jq -r --argjson x "$mouse_x" --argjson y "$mouse_y" '
        .. | objects |
        select(.rect != null and .app_id != null) |
        select(
            $x >= .rect.x and
            $x <= (.rect.x + .rect.width) and
            $y >= .rect.y and
            $y <= (.rect.y + .rect.height)
        ) |
        .app_id
        ' |
        grep -Ev '^(wev|swaybar|xdg-desktop-portal-gtk)$' |
        head -n 1
}
