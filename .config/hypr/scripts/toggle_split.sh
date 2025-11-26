#!/bin/bash

# Get current split direction for the active container
DIR=$(hyprctl -j activewindow | jq -r '.split')

# DIR is usually "1" or "0": (1 = horizontal, 0 = vertical)
# Toggle logic:
if [[ "$DIR" == "1" ]]; then
    # currently horizontal → switch to vertical
    hyprctl dispatch layoutmsg "orientation v"
else
    # currently vertical → switch to horizontal
    hyprctl dispatch layoutmsg "orientation h"
fi

