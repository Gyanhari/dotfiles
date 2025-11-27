#!/bin/bash

# A simple script to control volume using 'wpctl' (for PipeWire/WirePlumber)
# and send a notification using 'notify-send' (picked up by swaync).

# Exit on error
set -e

# --- CONFIGURATION ---
VOLUME_STEP="5%"
MAX_VOLUME_LIMIT="1.5" # 1.5 = 150%.
NOTIFICATION_ID=9910 # Reuses the same ID for updating the progress bar
SINK_ID="@DEFAULT_AUDIO_SINK@" 
# --- END CONFIGURATION ---

# Check if required commands exist
if ! command -v wpctl &> /dev/null; then
    echo "Error: wpctl command not found. Please ensure pipewire-utils is installed." >&2
    exit 1
fi
if ! command -v notify-send &> /dev/null; then
    echo "Error: notify-send command not found. Please ensure libnotify-bin is installed." >&2
    exit 1
fi


# Function to get the current volume and mute status robustly
get_volume_status() {
    local info
    
    # Use the simplest, most stable command: wpctl get-volume SINK_ID
    # This command always returns a string like: "Volume: 0.55" or "Volume: 0.55 [MUTED]"
    info=$(wpctl get-volume $SINK_ID 2>/dev/null)
    
    # Fallback/Error check
    if [ -z "$info" ]; then
        echo "Error: wpctl failed to get volume information." >&2
        VOLUME_PERC=0
        MUTE_STATUS="no"
        return
    fi
    
    # 1. Extract the volume as a float (e.g., "0.55")
    local volume_float
    volume_float=$(echo "$info" | awk '{print $2}')
    
    # 2. Convert float volume to percentage integer (e.g., 0.55 -> 55)
    # Uses bash's built-in arithmetic to handle the conversion
    VOLUME_PERC=$(printf "%.0f\n" $(echo "$volume_float * 100" | bc))

    # 3. Check for the MUTED tag
    if echo "$info" | grep -q '\[MUTED\]'; then
        MUTE_STATUS="yes"
    else
        MUTE_STATUS="no"
    fi
    
    # Ensure VOLUME_PERC is a clean integer
    if ! [[ "$VOLUME_PERC" =~ ^[0-9]+$ ]]; then
        VOLUME_PERC=0
    fi
}

# Function to send a notification using notify-send
send_notification() {
    get_volume_status
    
    local icon_name
    local message

    # VOLUME_PERC is already an integer
    local volume_int=$((VOLUME_PERC))

    if [[ "$MUTE_STATUS" == "yes" ]]; then
        icon_name="audio-volume-muted"
        message="Muted"
    elif (( volume_int == 0 )); then
        icon_name="audio-volume-off"
        message="Volume: ${volume_int}%"
    elif (( volume_int < 33 )); then
        icon_name="audio-volume-low"
        message="Volume: ${volume_int}%"
    elif (( volume_int < 66 )); then
        icon_name="audio-volume-medium"
        message="Volume: ${volume_int}%"
    else
        icon_name="audio-volume-high"
        message="Volume: ${volume_int}%"
    fi

    # Send the notification, using the same ID to update the previous one.
    notify-send \
        -i "$icon_name" \
        -r "$NOTIFICATION_ID" \
        -u low \
        -h int:value:"$volume_int" \
        "Volume" \
        "$message"
}

case "$1" in
    up)
        # Increase volume, respecting the 150% limit
        wpctl set-volume $SINK_ID "$VOLUME_STEP+" -- $MAX_VOLUME_LIMIT
        send_notification
        ;;
    down)
        # Decrease volume
        wpctl set-volume $SINK_ID "$VOLUME_STEP-"
        send_notification
        ;;
    mute)
        # Toggle mute status
        wpctl set-mute $SINK_ID toggle
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac

exit 0
