#!/bin/bash
# =====================================================
# Dotfiles Environment Configuration
# Path variables for bash scripts
# =====================================================
#
# Note: Wayland environment variables are set in:
# ~/dotfiles/config/hypr/conf/environment.conf
#

# Base directories
export DOTFILES_DIR="${HOME}/dotfiles"
export DOTFILES_CONFIG="${DOTFILES_DIR}/config"
export DOTFILES_SCRIPTS="${DOTFILES_DIR}/scripts"

# Hyprland
export HYPR_DIR="${DOTFILES_CONFIG}/hypr"
export HYPR_CONF="${HYPR_DIR}/conf"
export HYPR_SCRIPTS="${HYPR_DIR}/scripts"

# Application configs
export WAYBAR_DIR="${DOTFILES_CONFIG}/waybar"
export ROFI_DIR="${DOTFILES_CONFIG}/rofi"
export NVIM_DIR="${DOTFILES_CONFIG}/nvim"
export SWAYNC_DIR="${DOTFILES_CONFIG}/swaync"

# Cache directories
export WALLPAPER_CACHE="${HOME}/.cache/wallpaper"
export DOTFILES_CACHE="${HOME}/.cache/dotfiles"

# Settings
export DOTFILES_SETTINGS="${DOTFILES_DIR}/.settings"

# User wallpapers
export USER_WALLPAPERS="${HOME}/wallpaper"
export DEFAULT_WALLPAPER="${USER_WALLPAPERS}/default.jpg"

# Ensure cache directories exist
mkdir -p "${WALLPAPER_CACHE}" "${DOTFILES_CACHE}"