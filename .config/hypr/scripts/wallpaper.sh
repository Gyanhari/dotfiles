#!/usr/bin/env bash

WALLPATH="$1"

# If no wallpaper passed → pick random from your cyberpunk folder
[[ -z "$WALLPATH" ]] && WALLPATH="$(find ~/Pictures/Wallpaper/cyberpunk -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n1)"

# Ensure daemon is running (with retry)
if ! swww query &>/dev/null; then
    echo "Starting swww-daemon..."
    swww-daemon &  # Fire it up in background
    sleep 1  # Give it a sec to breathe
fi

# Wait for socket with timeout (fixes the "not found" error)
for i in {1..10}; do
    if swww query &>/dev/null; then
        break
    fi
    echo "Waiting for swww socket... ($i/10)"
    sleep 0.5
done

if ! swww query &>/dev/null; then
    echo "Socket still MIA—restart Hyprland or check logs with journalctl --user -u swww.socket"
    exit 1
fi

# Cyberpunk transition roulette (matches your overshot/bouncy curves)
TRANS_TYPE=("grow" "wipe" "outer" "center" "random" "wave")
TRANS="${TRANS_TYPE[$RANDOM % ${#TRANS_TYPE[@]}]}"

swww img "$WALLPATH" \
  --transition-type "$TRANS" \
  --transition-duration 1.8 \
  --transition-fps 120 \
  --transition-step 120 \
  --transition-bezier .05,0.9,.1,1.05 \
  --transition-angle $((RANDOM % 360)) \
  --transition-wave 20,30

# Optional: regenerate your pywal/catppuccin colors from the new wall
if command -v wal &>/dev/null; then
    wal -i "$WALLPATH" -q
else
    echo "pywal not installed—skipping color gen. Run 'yay -S python-pywal' if you want it."
fi

echo "Wall set: $WALLPATH (Transition: $TRANS)"
