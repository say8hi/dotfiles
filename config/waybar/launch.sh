#!/bin/bash

# Check if waybar-disabled file exists
if [ -f $HOME/.cache/waybar-disabled ]; then
    killall waybar
    pkill waybar
    exit 1
fi

# Quit all running waybar instances
killall waybar
pkill waybar
sleep 0.2

# Check if battery exists (laptop detection)
CHASSIS_TYPE=$(cat /sys/class/dmi/id/chassis_type)
if [ "$CHASSIS_TYPE" == "10" ]; then
    HAS_BATTERY=true
else
    HAS_BATTERY=false
fi

# Generate config based on battery presence
CONFIG_FILE="$HOME/dotfiles/config/waybar/config"

if [ "$HAS_BATTERY" = false ]; then
    # Remove battery from modules-right for desktop
    sed 's/"battery",//g' "$CONFIG_FILE" > /tmp/waybar-config-temp.json
    waybar -c /tmp/waybar-config-temp.json -s ~/dotfiles/config/waybar/style.css &
else
    # Use config as-is for laptop
    waybar -c "$CONFIG_FILE" -s ~/dotfiles/config/waybar/style.css &
fi