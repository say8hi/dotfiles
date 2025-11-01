#!/bin/bash

# Check if waybar-disabled file exists
if [ -f $HOME/.cache/waybar-disabled ]; then
    killall waybar
    pkill waybar
    pkill cava
    exit 1
fi

# Quit all running waybar instances and related processes
killall waybar
pkill waybar
pkill cava
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
    # Desktop: remove laptop modules, keep desktop modules
    sed -e 's/"battery",//g' \
        -e 's/"backlight",//g' \
        "$CONFIG_FILE" > /tmp/waybar-config-temp.json
    waybar -c /tmp/waybar-config-temp.json -s ~/dotfiles/config/waybar/style.css &
else
    # Laptop: remove desktop modules, keep laptop modules
    sed -e 's/"cpu",//g' \
        -e 's/"memory",//g' \
        "$CONFIG_FILE" > /tmp/waybar-config-temp.json
    waybar -c /tmp/waybar-config-temp.json -s ~/dotfiles/config/waybar/style.css &
fi