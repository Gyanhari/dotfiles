#!/bin/bash
set -euo pipefail  # safer bash

# --- CONFIGURATION ---
VOLUME_STEP="5%"
MAX_VOLUME_LIMIT="1.5"    # 150% max
NOTIFICATION_ID=9910
SINK="@DEFAULT_SINK@"     # shorthand works with newer wpctl

# Dependencies check
command -v wpctl     >/dev/null || { echo "Error: wpctl not found (pipewire/wireplumber)" >&2; exit 1; }
command -v notify-send >/dev/null || { echo "Error: notify-send not found (libnotify-bin)" >&2; exit 1; }

get_volume() {
    local info
    info=$(wpctl get-volume "$SINK" 2>/dev/null) || { VOLUME=0; MUTED="yes"; return 1; }

    VOLUME_FLOAT=$(echo "$info" | awk '{print $2}')
    VOLUME=$(printf "%.0f" "$(echo "$VOLUME_FLOAT * 100" | bc -l 2>/dev/null || echo 0)")

    if echo "$info" | grep -q '\[MUTED\]'; then
        MUTED="yes"
    else
        MUTED="no"
    fi

    # Safety: ensure VOLUME is a valid number
    [[ $VOLUME =~ ^[0-9]+$ ]] || VOLUME=0
}

send_notification() {
    get_volume

    local icon urgency
    if [[ $MUTED == "yes" ]]; then
        icon="audio-volume-muted"
        message="Muted"
        value=0
        urgency="normal"
    elif (( VOLUME == 0 )); then
        icon="audio-volume-off"
        message="Volume: ${VOLUME}%"
        value=0
        urgency="low"
    elif (( VOLUME < 33 )); then
        icon="audio-volume-low"
        message="Volume: ${VOLUME}%"
        value=$VOLUME
        urgency="low"
    elif (( VOLUME < 66 )); then
        icon="audio-volume-medium"
        message="Volume: ${VOLUME}%"
        value=$VOLUME
        urgency="low"
    else
        icon="audio-volume-high"
        message="Volume: ${VOLUME}%"
        value=$VOLUME
        urgency="normal"  # slightly more noticeable when loud
    fi

    # Use replace ID + progress bar
    notify-send "Volume" "$message" \
        -a "Volume Control" \
        -i "$icon" \
        -h "int:value:$value" \
        -h "string:synchronous:volume" \
        -u "$urgency" \
        -t 1500 \
        -r "$NOTIFICATION_ID"   # This replaces previous notification
}

case "${1:-}" in
    up)
        wpctl set-volume "$SINK" "${VOLUME_STEP}+" --limit "$MAX_VOLUME_LIMIT"
        send_notification
        ;;
    down)
        wpctl set-volume "$SINK" "${VOLUME_STEP}-"
        send_notification
        ;;
    mute)
        wpctl set-mute "$SINK" toggle
        send_notification
        ;;
    "")
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
    *)
        echo "Invalid argument: $1"
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac

exit 0

