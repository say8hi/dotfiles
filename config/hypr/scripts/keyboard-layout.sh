#!/bin/bash
# Keyboard layout indicator for hyprlock

# Get current active keyboard layout
layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Extract layout code (usually first word before space) and convert to uppercase
echo "$layout" | awk '{print $1}' | tr '[:lower:]' '[:upper:]'