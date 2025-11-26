#!/usr/bin/env bash

WALLDIR="$HOME/Pictures/Wallpaper/cyberpunk"
CACHE_DIR="$HOME/.cache/wofi-wallpaper-thumbs"
mkdir -p "$CACHE_DIR"

# Generate PNG thumb (wofi loves PNG, resize to config's image_size)
generate_thumb() {
    local src="$1"
    local thumb_hash=$(basename "$src" | md5sum | cut -d' ' -f1)
    local thumb="$CACHE_DIR/${thumb_hash}.png"
    if [[ ! -f "$thumb" ]]; then
        echo "Generating thumb for $(basename "$src")..."
        convert "$src" -resize 180x120^ -gravity center -extent 180x120 -format png "$thumb" 2>/dev/null || {
            echo "Error: convert failed on $src (need imagemagick?)"
            return 1
        }
    fi
    echo "$thumb"
}

export -f generate_thumb
export WALLDIR CACHE_DIR

# Pipe correctly formatted dmenu lines: img:thumb:text:<pango markup with filename + path>
{
    mapfile -t walls < <(find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)
    for wall in "${walls[@]}"; do
        thumb=$(generate_thumb "$wall") || continue  # Skip busted thumbs
        filename=$(basename "$wall")
        # Exact syntax: img:path: text:<bold name>\n<small path>  (no outer markup!)
        printf "img:%s:text:<span weight='bold' size='larger'>%s</span>\n<span size='small' foreground='#666'>%s</span>\n" \
               "$thumb" "$filename" "$wall"
    done
} | wofi --show dmenu \
        --allow-images \
        --allow-markup \
        --cache-file /dev/null \
        --prompt "󰏢  Cyberpunk Walls (Previews On)" \
        --lines 6 || exit 0  # Exit if canceled

# wofi outputs clean path (thanks to dmenu-parse_action=true)
selected_path=$(cat)  # Read selected output
[[ -n "$selected_path" && -f "$selected_path" ]] && ~/.config/hypr/scripts/wallpaper.sh "$selected_path"

# Optional: Clean cache weekly or whatever (uncomment)
# find "$CACHE_DIR" -mtime +7 -delete
