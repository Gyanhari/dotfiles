#!/usr/bin/env bash

if ! pgrep -x "swww-daemon"> /dev/null; then
  swww-daemon --format xrgv &
fi


WALL1="$HOME/Pictures/Wallpaper/cyberpunk/city_1.jpg" # The Wide Cityscape
WALL2="$HOME/Pictures/Wallpaper/cyberpunk/city_2.jpg" # The Street Level
WALL3="$HOME/Pictures/Wallpaper/cyberpunk/city_3.jpg" # The Apartment
WALL4="$HOME/Pictures/Wallpaper/cyberpunk/city_4.jpg" # The Rooftop

# Transition config - This makes it look like you are "zooming" into the next scene
TRANSITION="--transition-type grow --transition-pos 0.5,0.5 --transition-fps 60 --transition-duration 2"

handle() {
  case $1 in
    1) swww img "$WALL1" $TRANSITION ;;
    2) swww img "$WALL2" $TRANSITION ;;
    3) swww img "$WALL3" $TRANSITION ;;
    4) swww img "$WALL4" $TRANSITION ;;
    *) swww img "$WALL1" $TRANSITION ;; # Default loop back to 1
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
  if [[ $line =~ ^workspace.*\>\>([0-9]+) ]]; then
    ws="${BASH_REMATCH[1]}"
    handle "$ws"
  fi
done

