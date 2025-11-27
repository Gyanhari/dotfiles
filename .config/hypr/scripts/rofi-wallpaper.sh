#!/usr/bin/env bash

# --- Configuration ---
WALLDIR="$HOME/Pictures/Wallpaper/cyberpunk"
CACHE_DIR="$HOME/.cache/rofi-wallpaper-thumbs" 
mkdir -p "$CACHE_DIR"

# --- Function to Generate Thumbnail ---
generate_thumb() {
    local src="$1"
    local wall_path_hash=$(echo "$src" | md5sum | cut -d' ' -f1)
    local thumb="$CACHE_DIR/${wall_path_hash}.png"

    if [[ ! -f "$thumb" ]]; then
        echo "Generating thumb for $(basename "$src")..." >/dev/stderr
        # Using 128x128 to match the element-icon size suggested for your theme
        convert "$src" -resize 128x128^ -gravity center -extent 128x128 -format png "$thumb" 2>/dev/null || {
            echo "Error: convert failed on $src (need imagemagick?)" >/dev/stderr
            return 1
        }
    fi
    echo "$thumb"
}

export -f generate_thumb
export WALLDIR CACHE_DIR

# --- Generate Rofi Input List ---
# Format: icon_path\x00display_text\x00return_data\n
{
    mapfile -t walls < <(find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)
    for wall in "${walls[@]}"; do
        thumb=$(generate_thumb "$wall") || continue 

        filename=$(basename "$wall")
        
        # Use a single printf string with two \x00 separators
        printf "%s\x00<span weight='bold'>%s</span>\n<span size='small' foreground='#888'>%s</span>\x00%s\n" \
               "$thumb" \
               "$filename" \
               "$wall" \
               "$wall"
    done
} | rofi -dmenu \
    -theme ~/.config/rofi/cyberpunk-preview.rasi \
    -format 'i-text\0data' \
    -separator '\x00' \
    -p "󰏢  Cyberpunk Walls (Previews)" \
    -lines 5 || exit 0 

# Read selected output (which is the 'data' field, the clean path)
selected_path=$(cat) 

# --- Apply Wallpaper ---
[[ -n "$selected_path" && -f "$selected_path" ]] && ~/.config/hypr/scripts/wallpaper.sh "$selected_path"

# Optional: Clean cache weekly or whatever (uncomment)
# find "$CACHE_DIR" -mtime +7 -delete
