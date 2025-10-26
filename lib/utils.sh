#!/bin/bash
# =====================================================
# Dotfiles Utility Functions
# Common functions used across scripts
# =====================================================

# Source environment if not already loaded
if [[ -z "${DOTFILES_DIR}" ]]; then
    source "${HOME}/dotfiles/config/env.sh"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if file exists and is readable
file_readable() {
    [[ -f "$1" && -r "$1" ]]
}

# Check if script exists and is executable
script_exists() {
    [[ -f "$1" && -x "$1" ]]
}

# Safe source a file
safe_source() {
    if file_readable "$1"; then
        # shellcheck disable=SC1090
        source "$1"
        return 0
    else
        print_warning "Cannot source $1 (file not found or not readable)"
        return 1
    fi
}

# Execute script if exists
safe_exec() {
    if script_exists "$1"; then
        "$@"
        return $?
    else
        print_warning "Script $1 not found or not executable"
        return 1
    fi
}

# Read setting file
read_setting() {
    local setting_file="$1"
    local default_value="${2:-}"

    if file_readable "${setting_file}"; then
        cat "${setting_file}"
    else
        echo "${default_value}"
    fi
}

# Write setting file
write_setting() {
    local setting_file="$1"
    local value="$2"

    mkdir -p "$(dirname "${setting_file}")"
    echo "${value}" > "${setting_file}"
}

# Check if running on Wayland
is_wayland() {
    [[ "${XDG_SESSION_TYPE}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY}" ]]
}

# Get wallpaper engine setting
get_wallpaper_engine() {
    read_setting "${DOTFILES_SETTINGS}/wallpaper-engine.sh" "hyprpaper"
}

# Notify user (using notify-send or swaync)
notify_user() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"

    if command_exists notify-send; then
        notify-send -u "${urgency}" "${title}" "${message}"
    fi
}
