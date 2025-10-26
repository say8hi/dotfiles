#!/bin/bash
# Screenshot script for Hyprland
# Usage:
#   screenshot.sh        - fullscreen to clipboard
#   screenshot.sh area   - area selection to clipboard + editor

DIR="$HOME/Pictures/screenshots/"
NAME="screenshot_$(date +%d%m%Y_%H%M%S).png"

# Create directory if it doesn't exist
mkdir -p "$DIR"

# Get screenshot editor from env (swappy/satty)
EDITOR="${SCREENSHOT_EDITOR:-swappy}"

case "$1" in
    "area")
        # Area selection
        grim -g "$(slurp)" "$DIR$NAME"
        if [ $? -eq 0 ]; then
            wl-copy < "$DIR$NAME"
            notify-send "Screenshot captured" "Area selection saved and copied to clipboard"
            $EDITOR -f "$DIR$NAME"
        fi
        ;;
    *)
        # Fullscreen active monitor
        active_monitor=$(hyprctl -j activeworkspace | jq -r '.monitor')
        grim -o "$active_monitor" "$DIR$NAME"
        if [ $? -eq 0 ]; then
            wl-copy < "$DIR$NAME"
            notify-send "Screenshot captured" "Active monitor saved and copied to clipboard"
        fi
        ;;
esac