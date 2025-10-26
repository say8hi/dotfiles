# Dotfiles

Personal configuration files for Arch Linux with Hyprland.

## Stack

- **WM**: [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/) - GPU-accelerated terminal
- **Shell**: ZSH + Starship
- **Editor**: [Neovim](https://neovim.io/) with [NvChad](https://nvchad.com/)
- **Bar**: [Waybar](https://github.com/Alexays/Waybar)
- **Launcher**: [Rofi](https://github.com/davatorium/rofi)
- **Notifications**: [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
- **Colors**: [Matugen](https://github.com/InioX/matugen) - Material You color generation from wallpaper
- **Display Manager**: SDDM with Silent theme
- **Wallpaper Engine**: Hyprpaper

## Structure

```
dotfiles/
├── config/          # Application configs (symlinked to ~/.config/)
│   ├── hypr/        # Hyprland WM
│   ├── kitty/       # Terminal
│   ├── nvim/        # Neovim + NvChad
│   ├── rofi/        # Launcher
│   ├── waybar/      # Status bar
│   ├── starship/    # Shell prompt
│   ├── matugen/     # Color scheme generator
│   ├── sddm/        # Login screen
│   └── ...
├── home/            # Home directory files
│   ├── .zshrc       # ZSH config
│   └── shell/       # Modular shell configs
├── scripts/         # Utility scripts
├── wallpaper/       # Wallpaper collection
└── lib/             # Shared libraries
```

## Features

### Dynamic Theming

Colors are automatically generated from wallpaper using Matugen and applied to:

- Terminal (Kitty)
- Editor (Neovim)
- Launcher (Rofi)
- Status bar (Waybar)
- Login screen (SDDM)

### Environment Variables

Consistent paths via dotfiles environment variables:

- `$DOTFILES_DIR` - Base directory
- `$DOTFILES_CONFIG` - Config directory
- `$DOTFILES_CACHE` - Cache directory
- `$DOTFILES_SCRIPTS` - Scripts directory

### SDDM Integration

Login screen automatically uses current wallpaper and theme colors.

## Setup

### Dependencies

**Core:**

```bash
hyprland waybar kitty rofi neovim matugen hyprpaper sddm
```

**Shell:**

```bash
zsh starship zsh-autosuggestions zsh-syntax-highlighting zoxide fzf
```

**Optional:**

```bash
wlogout swappy swaync
```

### Installation

#### Automated (Recommended)

```bash
# Clone repository
git clone https://github.com/say8hi/dotfiles.git ~/dotfiles

# Run installation script
cd ~/dotfiles
./install.sh
```

The script will:

- Check dependencies
- Backup existing configs
- Create symlinks
- Setup SDDM (optional)
- Install starship and zsh plugins (optional)
- Generate initial color scheme

#### Manual

```bash
# Clone repository
git clone <your-repo> ~/dotfiles

# Install dependencies (Arch Linux)
yay -S hyprland waybar kitty rofi neovim matugen-bin hyprpaper sddm zsh

# Create symlinks
ln -sf ~/dotfiles/config/hypr ~/.config/hypr
ln -sf ~/dotfiles/config/kitty ~/.config/kitty
ln -sf ~/dotfiles/config/nvim ~/.config/nvim
ln -sf ~/dotfiles/config/rofi ~/.config/rofi
ln -sf ~/dotfiles/config/waybar ~/.config/waybar
ln -sf ~/dotfiles/config/matugen ~/.config/matugen
ln -sf ~/dotfiles/home/.zshrc ~/.zshrc

# Generate colors from wallpaper
~/dotfiles/config/hypr/scripts/wallpaper.sh select
```

## Usage

### Wallpaper Management

```bash
# Random wallpaper
~/dotfiles/config/hypr/scripts/wallpaper.sh

# Select with rofi
~/dotfiles/config/hypr/scripts/wallpaper.sh select

# Init (load last wallpaper)
~/dotfiles/config/hypr/scripts/wallpaper.sh init
```

Changing wallpaper automatically:

1. Updates all color schemes via Matugen
2. Reloads Waybar
3. Sets SDDM background
4. Updates terminal colors
