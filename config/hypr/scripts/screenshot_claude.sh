#!/bin/bash
# Send area screenshot directly to Claude Code TUI via kitty remote control
# Requires: grim, slurp, kitty with allow_remote_control yes
# Launch claude with: kitty --listen-on unix:/tmp/kitty-claude -e claude

SOCKET="unix:/tmp/kitty-claude"
FILE="/tmp/claude_shot_$(date +%s).png"

# Clean up screenshots older than 10 minutes — claude has long read them.
find /tmp -maxdepth 1 -name 'claude_shot_*.png' -mmin +10 -delete 2>/dev/null || true

if ! kitty @ --to "$SOCKET" ls > /dev/null 2>&1; then
    exit 1
fi

GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
grim -g "$GEOM" "$FILE" || exit 1

kitty @ --to "$SOCKET" send-text --match "cmdline:claude" "@${FILE}"

KITTY_PID=$(lsof /tmp/kitty-claude 2>/dev/null | awk 'NR>1 {print $2; exit}')
CLAUDE_ADDR=$(hyprctl clients -j | jq -r --argjson pid "$KITTY_PID" '.[] | select(.pid == $pid) | .address')
PREV=$(hyprctl activewindow -j | jq -r '.address')

hyprctl dispatch focuswindow "address:$CLAUDE_ADDR"
# sleep 0.1
wtype -k Return
sleep 0.1
wtype -k Return

hyprctl dispatch focuswindow "address:$PREV"

