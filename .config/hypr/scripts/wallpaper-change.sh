#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/current_wallpaper"

declare -A WALLS=(
    ["wall1"]="$HOME/Pictures/Wallpaper/character_in_right/wall1.jpg"
    ["wall2"]="$HOME/Pictures/Wallpaper/violet_lockscreen.png"
)

declare -A TRANSITIONS=(
    ["wall1"]="--transition-type wipe --transition-fps 60 --transition-duration 1.5 --transition-angle 45 --transition-step 90 --resize crop"
    ["wall2"]="--transition-type wipe --transition-fps 60 --transition-duration 1.5 --transition-angle 225 --transition-step 90 --resize crop"
)

# Get current wallpaper
CURRENT=$(swww query | awk -F'image path: ' '{print $2}' | head -n1)
[[ -z "$CURRENT" && -f "$STATE_FILE" ]] && CURRENT=$(cat "$STATE_FILE")

# Determine current key
for key in "${!WALLS[@]}"; do
    [[ "${WALLS[$key]}" == "$CURRENT" ]] && CUR_KEY="$key"
done

# Rotate wallpapers
KEYS=("${!WALLS[@]}")
NEXT_KEY="${KEYS[0]}"

for i in "${!KEYS[@]}"; do
    if [[ "${KEYS[$i]}" == "$CUR_KEY" ]]; then
        NEXT_KEY="${KEYS[$(( (i+1) % ${#KEYS[@]} ))]}"
        break
    fi
done

NEXT="${WALLS[$NEXT_KEY]}"
TRANSITION="${TRANSITIONS[$NEXT_KEY]}"

# Apply
swww img "$NEXT" $TRANSITION

echo "$NEXT" > "$STATE_FILE"

