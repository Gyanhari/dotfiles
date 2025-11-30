#!/usr/bin/env bash
# File: /usr/local/bin/brightness
# Usage: brightness +10%   brightness -5%   brightness 70%

brightnessctl -q set "$1" >/dev/null

# Get raw current and max values
CURRENT=$(brightnessctl g)
MAX=$(brightnessctl m)

# Calculate percentage for the notification
PERCENT=$(( CURRENT * 100 / MAX ))

notify-send "Brightness" "$PERCENT%" \
    -h int:value:"$PERCENT" \
    -h string:synchronous:brightness \
    -i display-brightness-symbolic \
    -t 1200 \
    --app-name="Brightness"

echo "$PERCENT%"
