#!/bin/bash
# Caps Lock indicator for hyprlock

# Get Caps Lock state using hyprctl
caps_state=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .capsLock')

if [ "$caps_state" = "true" ]; then
    echo " CAPS LOCK"
else
    echo ""
fi