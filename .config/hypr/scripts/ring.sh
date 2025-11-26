# ~/.config/hypr/scripts/ring.sh
#!/usr/bin/env bash
# Neon rotating ring made of unicode segments
frames=("󰇛" "󰇜" "󰇝" "󰇞" "󰇟" "󰇠" "󰇡" "󰇢")
idx=$(( $(date +%s) % ${#frames[@]} ))
echo "${frames[$idx]}"
