if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec dbus-run-session Hyprland
fi
