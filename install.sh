#!/usr/bin/env bash

#==============================================================================
# Dotfiles Installation Script
# Automated setup for Hyprland environment
#==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="${SCRIPT_DIR}"
readonly BACKUP_DIR="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
readonly CONFIG_DIR="${HOME}/.config"
readonly LOG_FILE="${DOTFILES_DIR}/install.log"

# Load package lists
source "${DOTFILES_DIR}/lib/packages.conf"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

#==============================================================================
# Helper Functions
#==============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

print_header() {
    echo -e "\n${BLUE}==>${NC} ${1}" | tee -a "${LOG_FILE}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}" | tee -a "${LOG_FILE}"
}

print_warning() {
    echo -e "${YELLOW}!${NC} ${1}" | tee -a "${LOG_FILE}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}" | tee -a "${LOG_FILE}"
}

ask_confirmation() {
    read -rp "$(echo -e "${YELLOW}?${NC}") ${1} (y/N): " response
    [[ "${response}" =~ ^[Yy]$ ]]
}

cleanup() {
    if [[ -n "${BACKUP_DIR:-}" ]] && [[ -d "${BACKUP_DIR}" ]]; then
        if [[ ! "$(ls -A "${BACKUP_DIR}")" ]]; then
            rm -rf "${BACKUP_DIR}"
            log "Removed empty backup directory"
        fi
    fi
}

error_exit() {
    print_error "$1"
    cleanup
    exit 1
}

command_exists() {
    command -v "$1" &> /dev/null
}

#==============================================================================
# Installation Steps
#==============================================================================

check_requirements() {
    print_header "Checking requirements"

    # Check if running from correct directory
    if [[ ! -f "${DOTFILES_DIR}/install.sh" ]]; then
        error_exit "Please run this script from the dotfiles directory"
    fi

    # Check if directories exist
    if [[ ! -d "${DOTFILES_DIR}/config" ]]; then
        error_exit "config/ directory not found in ${DOTFILES_DIR}"
    fi

    print_success "Requirements check passed"
}

check_arch() {
    print_header "Checking system compatibility"

    if [[ ! -f /etc/arch-release ]]; then
        print_warning "This script is designed for Arch Linux"
        if ! ask_confirmation "Continue anyway?"; then
            exit 1
        fi
    fi

    print_success "System check passed"
}

check_dependencies() {
    print_header "Checking dependencies"

    local -a missing=()

    # Check core packages (binary names, not package names)
    for pkg in "${CORE_PACKAGES[@]}"; do
        # Convert package name to command name (matugen-bin -> matugen)
        local cmd="${pkg%%-bin}"
        cmd="${cmd%%-git}"

        if ! command_exists "${cmd}"; then
            missing+=("${pkg}")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        print_warning "Missing core dependencies: ${missing[*]}"
        echo ""
        echo "Install all core packages with:"
        echo "  yay -S ${CORE_PACKAGES[*]}"
        echo ""
        echo "Or individually:"
        for pkg in "${missing[@]}"; do
            echo "  yay -S ${pkg}"
        done
        echo ""

        if ! ask_confirmation "Continue without installing dependencies?"; then
            exit 1
        fi
    else
        print_success "All core dependencies installed"
    fi
}

backup_existing_configs() {
    print_header "Backing up existing configurations"

    local backed_up=0

    for config in "${CONFIGS[@]}"; do
        local config_path="${CONFIG_DIR}/${config}"
        if [[ -e "${config_path}" ]] && [[ ! -L "${config_path}" ]]; then
            mkdir -p "${BACKUP_DIR}"
            if mv "${config_path}" "${BACKUP_DIR}/"; then
                print_success "Backed up ${config}"
                backed_up=1
            else
                print_warning "Failed to backup ${config}"
            fi
        fi
    done

    # Backup .zshrc
    if [[ -f "${HOME}/.zshrc" ]] && [[ ! -L "${HOME}/.zshrc" ]]; then
        mkdir -p "${BACKUP_DIR}"
        if mv "${HOME}/.zshrc" "${BACKUP_DIR}/"; then
            print_success "Backed up .zshrc"
            backed_up=1
        else
            print_warning "Failed to backup .zshrc"
        fi
    fi

    if [[ ${backed_up} -eq 1 ]]; then
        print_success "Backups saved to: ${BACKUP_DIR}"
    else
        print_success "No existing configs to backup"
    fi
}

create_symlinks() {
    print_header "Creating symlinks"

    # Ensure config directory exists
    mkdir -p "${CONFIG_DIR}"

    # Config symlinks
    for config in "${CONFIGS[@]}"; do
        local source="${DOTFILES_DIR}/config/${config}"
        local target="${CONFIG_DIR}/${config}"

        if [[ -d "${source}" ]]; then
            ln -sf "${source}" "${target}"
            print_success "Linked ${config}"
        else
            print_warning "Skipped ${config} (source not found)"
        fi
    done

    # Home directory symlinks
    if [[ -f "${DOTFILES_DIR}/home/.zshrc" ]]; then
        ln -sf "${DOTFILES_DIR}/home/.zshrc" "${HOME}/.zshrc"
        print_success "Linked .zshrc"
    else
        print_warning "Skipped .zshrc (source not found)"
    fi

    print_success "All symlinks created"
}

setup_wallpaper_dir() {
    print_header "Setting up wallpaper directory"

    local wallpaper_dir="${HOME}/wallpaper"
    local dotfiles_wallpaper="${DOTFILES_DIR}/wallpaper"

    if [[ -d "${wallpaper_dir}" ]] && [[ ! -L "${wallpaper_dir}" ]]; then
        print_warning "~/wallpaper already exists"
        if ask_confirmation "Merge with dotfiles/wallpaper?"; then
            if command_exists rsync; then
                rsync -av "${wallpaper_dir}/" "${dotfiles_wallpaper}/" || print_warning "rsync failed"
                rm -rf "${wallpaper_dir}"
                ln -sf "${dotfiles_wallpaper}" "${wallpaper_dir}"
                print_success "Merged and linked wallpaper directory"
            else
                print_warning "rsync not found, skipping merge"
            fi
        fi
    else
        ln -sf "${dotfiles_wallpaper}" "${wallpaper_dir}"
        print_success "Linked wallpaper directory"
    fi
}

setup_sddm() {
    print_header "Setting up SDDM"

    if ! command_exists sddm; then
        print_warning "SDDM not installed, skipping"
        return 0
    fi

    if ask_confirmation "Configure SDDM with Silent theme?"; then
        # Check sudo access
        if ! sudo -v; then
            print_error "Failed to get sudo access"
            return 1
        fi

        # Copy SDDM config
        sudo mkdir -p /etc/sddm.conf.d || error_exit "Failed to create /etc/sddm.conf.d"
        sudo cp "${DOTFILES_DIR}/config/sddm/sddm.conf" /etc/sddm.conf.d/ || print_warning "Failed to copy SDDM config"
        print_success "SDDM config installed"

        # Check if Silent theme exists
        if [[ -d "/usr/share/sddm/themes/silent" ]]; then
            print_success "Silent theme found"
        else
            print_warning "Silent theme not found at /usr/share/sddm/themes/silent"
            echo "Install with: yay -S sddm-theme-silent"
        fi

        # Enable SDDM
        if ask_confirmation "Enable SDDM service?"; then
            sudo systemctl enable sddm || print_warning "Failed to enable SDDM"
            print_success "SDDM enabled"
        fi
    fi
}

install_shell_plugins() {
    print_header "Setting up shell environment"

    # Check for starship
    if ! command_exists starship; then
        print_warning "starship not found"
        if ask_confirmation "Install starship? (yay -S starship)"; then
            if command_exists yay; then
                yay -S --noconfirm starship || {
                    print_warning "starship installation failed"
                }
            else
                print_warning "yay not found, please install starship manually: yay -S starship"
            fi
        fi
    else
        print_success "starship already installed"
    fi

    # Check for zsh-autosuggestions
    local autosuggestions_path="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    if [[ ! -f "${autosuggestions_path}" ]]; then
        print_warning "zsh-autosuggestions not found"
        if ask_confirmation "Install zsh-autosuggestions? (yay -S zsh-autosuggestions)"; then
            if command_exists yay; then
                yay -S --noconfirm zsh-autosuggestions || {
                    print_warning "zsh-autosuggestions installation failed"
                }
            else
                print_warning "yay not found, please install manually: yay -S zsh-autosuggestions"
            fi
        fi
    else
        print_success "zsh-autosuggestions already installed"
    fi

    # Check for zsh-syntax-highlighting
    local highlighting_path="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [[ ! -f "${highlighting_path}" ]]; then
        print_warning "zsh-syntax-highlighting not found"
        if ask_confirmation "Install zsh-syntax-highlighting? (yay -S zsh-syntax-highlighting)"; then
            if command_exists yay; then
                yay -S --noconfirm zsh-syntax-highlighting || {
                    print_warning "zsh-syntax-highlighting installation failed"
                }
            else
                print_warning "yay not found, please install manually: yay -S zsh-syntax-highlighting"
            fi
        fi
    else
        print_success "zsh-syntax-highlighting already installed"
    fi

    # Check for zsh-history-substring-search
    local substring_path="/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
    if [[ ! -f "${substring_path}" ]]; then
        print_warning "zsh-history-substring-search not found"
        if ask_confirmation "Install zsh-history-substring-search? (yay -S zsh-history-substring-search)"; then
            if command_exists yay; then
                yay -S --noconfirm zsh-history-substring-search || {
                    print_warning "zsh-history-substring-search installation failed"
                }
            else
                print_warning "yay not found, please install manually: yay -S zsh-history-substring-search"
            fi
        fi
    else
        print_success "zsh-history-substring-search already installed"
    fi
}

generate_initial_colors() {
    print_header "Generating initial color scheme"

    if ! command_exists matugen; then
        print_warning "Matugen not installed, skipping"
        return 0
    fi

    # Find a wallpaper
    local wallpaper
    wallpaper=$(find "${DOTFILES_DIR}/wallpaper" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -1)

    if [[ -n "${wallpaper}" ]]; then
        mkdir -p "${HOME}/.cache"
        echo "${wallpaper}" > "${HOME}/.cache/current_wallpaper"
        matugen image "${wallpaper}" --type scheme-content || print_warning "Matugen color generation failed"
        print_success "Generated colors from wallpaper"
    else
        print_warning "No wallpapers found, skipping color generation"
    fi
}

set_default_shell() {
    print_header "Setting default shell"

    local zsh_path
    zsh_path=$(command -v zsh) || {
        print_warning "zsh not found"
        return 0
    }

    if [[ "${SHELL}" != "${zsh_path}" ]]; then
        if ask_confirmation "Set zsh as default shell?"; then
            chsh -s "${zsh_path}" || print_warning "Failed to change shell"
            print_success "Default shell changed to zsh"
            print_warning "Logout and login again for changes to take effect"
        fi
    else
        print_success "Zsh already set as default shell"
    fi
}

#==============================================================================
# Main Installation
#==============================================================================

main() {
    # Set up error handling
    trap cleanup EXIT
    trap 'error_exit "Script interrupted"' INT TERM

    # Start logging
    log "Installation started"

    clear
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║   Dotfiles Installation Script        ║"
    echo "║   Hyprland + Waybar + Rofi + More     ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    # Confirmation
    echo "This script will:"
    echo "  • Backup existing configs to ${BACKUP_DIR}"
    echo "  • Create symlinks from ${DOTFILES_DIR} to ~/.config/"
    echo "  • Set up SDDM (optional)"
    echo "  • Install starship and zsh plugins (optional)"
    echo "  • Generate initial color scheme"
    echo ""
    echo "Installation log: ${LOG_FILE}"
    echo ""

    if ! ask_confirmation "Continue with installation?"; then
        echo "Installation cancelled"
        exit 0
    fi

    # Run installation steps
    check_requirements
    check_arch
    check_dependencies
    backup_existing_configs
    create_symlinks
    setup_wallpaper_dir
    setup_sddm
    install_shell_plugins
    generate_initial_colors
    set_default_shell

    # Done
    print_header "Installation Complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Logout and login again"
    echo "  2. Select 'Hyprland' session"
    echo "  3. Change wallpaper: Super + Shift + W"
    echo ""
    echo "Installation log saved to: ${LOG_FILE}"
    echo ""
    print_success "Enjoy your new setup!"

    log "Installation completed successfully"
}

# Run main function
main "$@"