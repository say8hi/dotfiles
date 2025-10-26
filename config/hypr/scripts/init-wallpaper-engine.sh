#!/bin/bash
# =====================================================
# Wallpaper Engine Initialization
# =====================================================

# Source environment and utilities
source "${HOME}/dotfiles/lib/env.sh"
source "${HOME}/dotfiles/lib/utils.sh"

# Get wallpaper engine setting from env
wallpaper_engine="${WALLPAPER_ENGINE:-hyprpaper}"

print_info "Initializing wallpaper engine: ${wallpaper_engine}"

case "${wallpaper_engine}" in
    "swww")
        if command_exists swww; then
            print_info "Starting swww daemon..."
            swww init
            swww-daemon --format xrgb &
            sleep 0.5
        else
            print_error "swww not found, falling back to hyprpaper"
            wallpaper_engine="hyprpaper"
        fi
        ;;

    "hyprpaper")
        print_info "Using hyprpaper"
        ;;

    *)
        print_warning "Wallpaper engine disabled or unknown: ${wallpaper_engine}"
        ;;
esac

# Initialize wallpaper
if [[ -x "${HYPR_SCRIPTS}/wallpaper.sh" ]]; then
    "${HYPR_SCRIPTS}/wallpaper.sh" init
else
    print_warning "Wallpaper script not found or not executable"
fi

