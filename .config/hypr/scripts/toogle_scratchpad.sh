#!/bin/bash
if hyprctl -j clients | grep -q '"title": "scratchpad"'; then
    hyprctl dispatch togglespecialworkspace scratchpad
else
    kitty --title scratchpad &
    sleep 0.15
    hyprctl dispatch togglespecialworkspace scratchpad
fi
