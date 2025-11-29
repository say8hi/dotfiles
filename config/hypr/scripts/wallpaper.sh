#!/bin/bash

# Load environment variables
source "$HOME/dotfiles/lib/env.sh"

# Cache file for holding the current wallpaper
cache_file="$HOME/.cache/current_wallpaper"
blurred="$HOME/.cache/blurred_wallpaper.png"
square="$HOME/.cache/square_wallpaper.png"
rasi_file="$HOME/.cache/current_wallpaper.rasi"

# Use blur settings from env
blur="$BLUR"

# Create cache file if not exists
if [ ! -f $cache_file ] ;then
    touch $cache_file
    echo "$HOME/wallpaper/default.jpg" > "$cache_file"
fi

# Create rasi file if not exists
if [ ! -f $rasi_file ] ;then
    touch $rasi_file
    echo "* { current-image: url(\"$HOME/wallpaper/default.jpg\", height); }" > "$rasi_file"
fi

current_wallpaper=$(cat "$cache_file")

case $1 in

    # Load wallpaper from .cache of last session
    "init")
        sleep 1
        if [ -f $cache_file ]; then
            wallpaper=$current_wallpaper
        else
            wallpaper=$(find ~/wallpaper/ -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)
        fi
    ;;

    # Select wallpaper with rofi
    "select")
        sleep 0.2
        selected=$( find "$HOME/wallpaper" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | sort -V | while read rfile
        do
            echo -en "$rfile\x00icon\x1f$HOME/wallpaper/${rfile}\n"
        done | rofi -dmenu -i -replace -config ~/dotfiles/config/rofi/config-wallpaper.rasi)
        if [ ! "$selected" ]; then
            echo "No wallpaper selected"
            exit
        fi
        wallpaper="$HOME/wallpaper/$selected"
    ;;

    # Randomly select wallpaper
    *)
        wallpaper=$(find ~/wallpaper/ -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)
    ;;

esac

# -----------------------------------------------------
# Save wallpaper path and generate colors with matugen
# -----------------------------------------------------
echo "$wallpaper" > "$cache_file"
echo ":: Wallpaper: $wallpaper"
matugen image "$wallpaper" --type scheme-content

# ----------------------------------------------------- 
# get wallpaper image name
# ----------------------------------------------------- 
newwall=$(echo $wallpaper | sed "s|$HOME/wallpaper/||g")

# ----------------------------------------------------- 
# Reload waybar with new colors
# -----------------------------------------------------
~/dotfiles/config/waybar/launch.sh

# -----------------------------------------------------
# Set the new wallpaper
# -----------------------------------------------------
# Random transition type for swww
transition_types=("simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "outer")
transition_type="${transition_types[$RANDOM % ${#transition_types[@]}]}"

if [ "$WALLPAPER_ENGINE" == "swww" ] ;then
    # swww
    echo ":: Using swww with transition: $transition_type"
    # Get all connected monitors
    monitors=$(hyprctl monitors -j | jq -r '.[].name' | tr '\n' ',' | sed 's/,$//')
    swww img $wallpaper \
        --outputs "$monitors" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-fps=60 \
        --transition-type=$transition_type \
        --transition-duration=0.7 \
        --transition-pos "$( hyprctl cursorpos )"
elif [ "$WALLPAPER_ENGINE" == "hyprpaper" ] ;then
    # hyprpaper
    echo ":: Using hyprpaper"
    killall hyprpaper
    cat > "$HOME/dotfiles/config/hypr/hyprpaper.conf" <<EOF
# Preload Wallpapers
preload = $wallpaper

# Set Wallpapers
wallpaper = ,$wallpaper

# Disable Splash
splash = false
EOF
    hyprpaper &
else
    echo ":: Wallpaper Engine disabled"
fi

if [ "$1" == "init" ] ;then
    echo ":: Init"
else
    sleep 1
    notify-send "Wallpaper" "Applying $newwall..." -h int:value:10 -h string:x-canonical-private-synchronous:wallpaper

    # -----------------------------------------------------
    # Reload Hyprctl.sh
    # -----------------------------------------------------
    $HOME/.config/ml4w-hyprland-settings/hyprctl.sh &
fi

# -----------------------------------------------------
# Create blurred and square wallpapers (optimized with caching)
# -----------------------------------------------------
if [ "$1" != "init" ] ;then
    notify-send "Wallpaper" "Processing..." -h int:value:40 -h string:x-canonical-private-synchronous:wallpaper
fi

# Generate hash for caching
wallpaper_hash=$(md5sum "$wallpaper" | cut -d' ' -f1)
cached_blur="$HOME/.cache/wallpaper_blur_${wallpaper_hash}.png"
cached_square="$HOME/.cache/wallpaper_square_${wallpaper_hash}.png"

# Check if cached versions exist
if [[ -f "$cached_blur" && -f "$cached_square" ]]; then
    echo ":: Using cached versions"
    cp "$cached_blur" "$blurred"
    cp "$cached_square" "$square"
else
    echo ":: Generating new versions"

    # Run imagemagick operations in parallel with optimized settings
    {
        if [ ! "$blur" == "0x0" ] ;then
            magick "$wallpaper" -filter box -quality 85 -resize 75% -blur $blur "$blurred"
            echo ":: Created blurred version"
        else
            magick "$wallpaper" -filter box -quality 85 -resize 75% "$blurred"
            echo ":: Created resized version"
        fi
        # Cache the result
        cp "$blurred" "$cached_blur"
    } &

    {
        magick "$wallpaper" -filter box -quality 85 -gravity Center -extent 1:1 "$square"
        echo ":: Created square version"
        # Cache the result
        cp "$square" "$cached_square"
    } &

    # Wait for both operations to complete
    wait
    echo ":: Image processing complete"
fi

if [ "$1" != "init" ] ;then
    notify-send "Wallpaper" "Finalizing..." -h int:value:75 -h string:x-canonical-private-synchronous:wallpaper
fi

# -----------------------------------------------------
# Write selected wallpaper into .cache files
# -----------------------------------------------------
echo "$wallpaper" > "$cache_file"
echo "* { current-image: url(\"$blurred\", height); }" > "$rasi_file"

# -----------------------------------------------------
# Send notification
# -----------------------------------------------------

if [ "$1" == "init" ] ;then
    echo ":: Init"
else
    notify-send "Wallpaper" "Applied $newwall" -h int:value:100 -h string:x-canonical-private-synchronous:wallpaper
fi

# -----------------------------------------------------
# Set SDDM wallpaper (async - runs in background)
# -----------------------------------------------------
if [ "$1" == "init" ] ;then
    echo ":: Skipping SDDM wallpaper update on init"
else
    {
        echo ":: Setting SDDM wallpaper (background)"

        # Create SDDM config directory if it doesn't exist
        if [ ! -d /etc/sddm.conf.d/ ]; then
            sudo mkdir -p /etc/sddm.conf.d 2>/dev/null
        fi

        # Copy SDDM config
        sudo cp "$HOME/dotfiles/config/sddm/sddm.conf" /etc/sddm.conf.d/ 2>/dev/null

        # Get file extension
        extension="${wallpaper##*.}"

        # Copy current wallpaper to SDDM theme
        sudo cp "$wallpaper" /usr/share/sddm/themes/silent/Backgrounds/current_wallpaper.$extension 2>/dev/null

        # Update theme.conf
        sudo cp "$HOME/dotfiles/config/sddm/theme.conf" /usr/share/sddm/themes/silent/ 2>/dev/null
        sudo sed -i 's/CURRENTWALLPAPER/'"current_wallpaper.$extension"'/' /usr/share/sddm/themes/silent/theme.conf 2>/dev/null

        echo ":: SDDM wallpaper updated"
    } &
    disown
fi

echo "DONE!"
