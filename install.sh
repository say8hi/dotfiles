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
if [[ ! -f "${DOTFILES_DIR}/lib/packages.conf" ]]; then
    echo -e "${RED}✗${NC} lib/packages.conf not found in ${DOTFILES_DIR}"
    exit 1
fi
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

check_yay() {
    print_header "Checking package manager"

    if command_exists yay; then
        print_success "yay is installed"
        return 0
    fi

    print_warning "yay AUR helper not found"

    if ! ask_confirmation "Install yay? (required for AUR packages)"; then
        print_warning "Continuing without yay - some packages may not be available"
        return 0
    fi

    # Check if required dependencies are installed
    if ! command_exists git; then
        print_error "git is required to install yay"
        if ask_confirmation "Install git with pacman?"; then
            sudo pacman -S --needed --noconfirm git || {
                print_error "Failed to install git"
                return 1
            }
        else
            return 1
        fi
    fi

    if ! command_exists makepkg; then
        if ask_confirmation "Install base-devel? (required for building AUR packages)"; then
            sudo pacman -S --needed --noconfirm base-devel || {
                print_error "Failed to install base-devel"
                return 1
            }
        fi
    fi

    # Install yay
    print_header "Installing yay"
    local tmp_dir
    tmp_dir=$(mktemp -d) || {
        print_error "Failed to create temporary directory"
        return 1
    }
    local original_dir="${PWD}"

    if git clone https://aur.archlinux.org/yay.git "${tmp_dir}"; then
        cd "${tmp_dir}" || {
            rm -rf "${tmp_dir}"
            return 1
        }
        if makepkg -si --noconfirm; then
            print_success "yay installed successfully"
            cd "${original_dir}" || true
            rm -rf "${tmp_dir}"
            return 0
        else
            print_error "Failed to build yay"
            cd "${original_dir}" || true
            rm -rf "${tmp_dir}"
            return 1
        fi
    else
        print_error "Failed to clone yay repository"
        rm -rf "${tmp_dir}"
        return 1
    fi
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

        if command_exists yay; then
            if ask_confirmation "Install missing dependencies automatically?"; then
                print_header "Installing dependencies"
                if yay -S --needed --noconfirm "${missing[@]}"; then
                    print_success "All dependencies installed successfully"
                else
                    print_error "Failed to install some dependencies"
                    if ! ask_confirmation "Continue anyway?"; then
                        exit 1
                    fi
                fi
            else
                echo "Install manually with:"
                echo "  yay -S ${missing[*]}"
                echo ""
                if ! ask_confirmation "Continue without installing dependencies?"; then
                    exit 1
                fi
            fi
        else
            print_warning "yay not found. Please install dependencies manually:"
            for pkg in "${missing[@]}"; do
                echo "  yay -S ${pkg}"
            done
            echo ""
            if ! ask_confirmation "Continue without installing dependencies?"; then
                exit 1
            fi
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
        if [[ -e "${config_path}" ]] || [[ -L "${config_path}" ]]; then
            # Backup real files/directories, remove old symlinks
            if [[ ! -L "${config_path}" ]]; then
                mkdir -p "${BACKUP_DIR}"
                if mv "${config_path}" "${BACKUP_DIR}/"; then
                    print_success "Backed up ${config}"
                    backed_up=1
                else
                    print_warning "Failed to backup ${config}"
                fi
            else
                # Remove old symlink
                rm -f "${config_path}"
                print_success "Removed old symlink ${config}"
            fi
        fi
    done

    # Backup or remove home directory files
    for file in "${HOME_FILES[@]}"; do
        local file_path="${HOME}/${file}"
        if [[ -e "${file_path}" ]] || [[ -L "${file_path}" ]]; then
            if [[ ! -L "${file_path}" ]]; then
                mkdir -p "${BACKUP_DIR}"
                if mv "${file_path}" "${BACKUP_DIR}/"; then
                    print_success "Backed up ${file}"
                    backed_up=1
                else
                    print_warning "Failed to backup ${file}"
                fi
            else
                # Remove old symlink
                rm -f "${file_path}"
                print_success "Removed old symlink ${file}"
            fi
        fi
    done

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

        if [[ -e "${source}" ]]; then
            # Use -n flag to prevent creating symlink inside existing directory symlink
            ln -sfn "${source}" "${target}"
            print_success "Linked ${config}"
        else
            print_warning "Skipped ${config} (source not found)"
        fi
    done

    # Home directory symlinks
    for file in "${HOME_FILES[@]}"; do
        local source="${DOTFILES_DIR}/home/${file}"
        local target="${HOME}/${file}"

        if [[ -e "${source}" ]]; then
            ln -sfn "${source}" "${target}"
            print_success "Linked ${file}"
        else
            print_warning "Skipped ${file} (source not found)"
        fi
    done

    print_success "All symlinks created"
}

setup_local_config() {
    print_header "Setting up device-specific configuration"

    local local_conf="${CONFIG_DIR}/hypr/conf/local.conf"
    local example_conf="${CONFIG_DIR}/hypr/conf/local.conf.example"

    if [[ ! -f "${local_conf}" ]]; then
        if [[ -f "${example_conf}" ]]; then
            mv "${example_conf}" "${local_conf}"
            print_success "Created local.conf from example"
            print_warning "Edit ~/.config/hypr/conf/local.conf to customize:"
            echo "  • Add COINMARKETCAP_API_KEY for waybar-crypto"
            echo "  • Uncomment hyprsplit config for desktop setup"
        else
            print_warning "local.conf.example not found, skipping"
        fi
    else
        print_success "local.conf already exists"
    fi
}

setup_wallpaper_dir() {
    print_header "Setting up wallpaper directory"

    local wallpaper_dir="${HOME}/wallpaper"

    # Create wallpaper directory if it doesn't exist
    if [[ ! -d "${wallpaper_dir}" ]]; then
        mkdir -p "${wallpaper_dir}"
        print_success "Created ~/wallpaper directory"

        # Copy default Hyprland wallpapers if available
        if [[ -d "/usr/share/hyprland" ]]; then
            local copied=0
            # Try common wallpaper locations
            shopt -s nullglob
            for wallpaper in /usr/share/hyprland/*.png /usr/share/hyprland/*.jpg /usr/share/hyprland/wall*; do
                if [[ -f "${wallpaper}" ]]; then
                    cp "${wallpaper}" "${wallpaper_dir}/"
                    print_success "Copied $(basename "${wallpaper}")"
                    copied=1
                fi
            done
            shopt -u nullglob

            if [[ ${copied} -eq 0 ]]; then
                print_warning "No default Hyprland wallpapers found"
                echo "You can add your own wallpapers to ~/wallpaper"
            fi
        else
            print_warning "Hyprland wallpapers not found in /usr/share/hyprland"
            echo "You can add your own wallpapers to ~/wallpaper"
        fi
    else
        print_success "~/wallpaper directory already exists"
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

install_optional_components() {
    print_header "Optional components installation"

    echo ""
    echo "The following components are optional and can enhance your workflow:"
    echo ""

    # Miniconda
    if [[ ! -d "/opt/miniconda3" ]] && [[ ! -f "${HOME}/miniconda3/bin/conda" ]]; then
        if ask_confirmation "Install Miniconda? (Python package manager)"; then
            print_header "Installing Miniconda"
            local tmp_dir
            tmp_dir=$(mktemp -d) || {
                print_error "Failed to create temporary directory"
                return 1
            }

            # Download Miniconda installer
            if curl -L -o "${tmp_dir}/miniconda.sh" https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; then
                chmod +x "${tmp_dir}/miniconda.sh"

                # Ask for installation location
                echo ""
                echo "Choose installation location:"
                echo "  1) /opt/miniconda3 (system-wide, requires sudo)"
                echo "  2) ~/miniconda3 (user-local)"
                read -rp "$(echo -e "${YELLOW}?${NC}") Select location (1/2): " conda_location

                if [[ "${conda_location}" == "1" ]]; then
                    if sudo bash "${tmp_dir}/miniconda.sh" -b -p /opt/miniconda3; then
                        sudo chown -R "${USER}:${USER}" /opt/miniconda3
                        print_success "Miniconda installed to /opt/miniconda3"
                    else
                        print_error "Miniconda installation failed"
                    fi
                elif [[ "${conda_location}" == "2" ]]; then
                    if bash "${tmp_dir}/miniconda.sh" -b -p "${HOME}/miniconda3"; then
                        print_success "Miniconda installed to ~/miniconda3"
                        print_warning "Note: conda.zsh expects /opt/miniconda3, you may need to edit it"
                    else
                        print_error "Miniconda installation failed"
                    fi
                else
                    print_warning "Invalid selection, skipping Miniconda installation"
                fi

                rm -rf "${tmp_dir}"
            else
                print_error "Failed to download Miniconda installer"
                rm -rf "${tmp_dir}"
            fi
        fi
    else
        print_success "Miniconda already installed"
    fi

    # Rust/Cargo
    if ! command_exists cargo; then
        if ask_confirmation "Install Rust? (rustup toolchain)"; then
            print_header "Installing Rust"
            if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
                print_success "Rust installed successfully"
                print_warning "Restart your shell or source ~/.cargo/env to use cargo"
            else
                print_error "Rust installation failed"
            fi
        fi
    else
        print_success "Rust already installed"
    fi

    # Go
    if ! command_exists go; then
        if ask_confirmation "Install Go? (yay -S go)"; then
            if command_exists yay; then
                yay -S --noconfirm go && {
                    print_success "Go installed successfully"
                } || {
                    print_error "Go installation failed"
                }
            else
                print_warning "yay not found, please install Go manually: yay -S go"
            fi
        fi
    else
        print_success "Go already installed"
    fi

    # Docker
    if ! command_exists docker; then
        if ask_confirmation "Install Docker? (yay -S docker docker-compose)"; then
            if command_exists yay; then
                yay -S --noconfirm docker docker-compose && {
                    print_success "Docker installed successfully"
                    if ask_confirmation "Add current user to docker group?"; then
                        sudo usermod -aG docker "${USER}" && {
                            print_success "User added to docker group"
                            print_warning "Logout and login again for group changes to take effect"
                        } || {
                            print_error "Failed to add user to docker group"
                        }
                    fi
                    if ask_confirmation "Enable Docker service?"; then
                        sudo systemctl enable docker && {
                            print_success "Docker service enabled"
                        } || {
                            print_error "Failed to enable Docker service"
                        }
                    fi
                } || {
                    print_error "Docker installation failed"
                }
            else
                print_warning "yay not found, please install Docker manually: yay -S docker docker-compose"
            fi
        fi
    else
        print_success "Docker already installed"
    fi

    # Node.js/npm
    if ! command_exists node; then
        if ask_confirmation "Install Node.js? (yay -S nodejs npm)"; then
            if command_exists yay; then
                yay -S --noconfirm nodejs npm && {
                    print_success "Node.js installed successfully"
                } || {
                    print_error "Node.js installation failed"
                }
            else
                print_warning "yay not found, please install Node.js manually: yay -S nodejs npm"
            fi
        fi
    else
        print_success "Node.js already installed"
    fi

    echo ""
    print_success "Optional components setup complete"
}

generate_initial_colors() {
    print_header "Generating initial color scheme"

    if ! command_exists matugen; then
        print_warning "Matugen not installed, skipping"
        return 0
    fi

    # Find a wallpaper in ~/wallpaper
    local wallpaper
    wallpaper=$(find "${HOME}/wallpaper" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -1)

    if [[ -n "${wallpaper}" ]]; then
        mkdir -p "${HOME}/.cache"
        echo "${wallpaper}" > "${HOME}/.cache/current_wallpaper"
        matugen image "${wallpaper}" --type scheme-content || print_warning "Matugen color generation failed"
        print_success "Generated colors from wallpaper"
    else
        print_warning "No wallpapers found in ~/wallpaper, skipping color generation"
    fi
}

generate_gtk_bookmarks() {
    print_header "Generating GTK bookmarks"

    if [[ -f "${DOTFILES_DIR}/scripts/generate-bookmarks.sh" ]]; then
        bash "${DOTFILES_DIR}/scripts/generate-bookmarks.sh" || print_warning "Failed to generate bookmarks"
        print_success "GTK bookmarks generated"
    else
        print_warning "generate-bookmarks.sh not found, skipping"
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
    echo "  • Install shell plugins (optional)"
    echo "  • Install optional components: Miniconda, Rust, Go, Docker, Node.js (optional)"
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
    check_yay
    check_dependencies
    backup_existing_configs
    create_symlinks
    setup_local_config
    setup_wallpaper_dir
    setup_sddm
    install_shell_plugins
    install_optional_components
    generate_initial_colors
    generate_gtk_bookmarks
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