#!/bin/bash
# Create a temporary config file
config_file=$(mktemp)
# Write cava configuration to the temporary file
cat > "$config_file" << EOF
[general]
bars = 8
framerate = 60
sensitivity = 100
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
# Function to clean up temp file on exit
cleanup() {
    rm -f "$config_file"
}
trap cleanup EXIT
# Run cava with the config file and process its output
cava -p "$config_file" | while read -r line; do
    # Filter the line to get only the actual bar values (no spaces or other characters)
    filtered_line=$(echo "$line" | tr -cd '0-7')
    
    # Convert the ASCII values to a Unicode bar representation
    bar_chars=""
    for ((i=0; i<${#filtered_line}; i++)); do
        level=${filtered_line:$i:1}
        case $level in
            0) bar_chars+="▁";;
            1) bar_chars+="▂";;
            2) bar_chars+="▃";;
            3) bar_chars+="▄";;
            4) bar_chars+="▅";;
            5) bar_chars+="▆";;
            6) bar_chars+="▇";;
            7) bar_chars+="█";;
            *) bar_chars+="▁";;
        esac
    done
    
    # Check if audio is playing (sum of levels > threshold)
    is_playing="false"
    sum=0
    for ((i=0; i<${#filtered_line}; i++)); do
        val=${filtered_line:$i:1}
        if [[ "$val" =~ ^[0-9]+$ ]]; then
            sum=$((sum + val))
        fi
    done
    
    if [ $sum -gt 5 ]; then
        is_playing="true"
    fi
    
    # Create JSON output in the format that waybar expects
    echo "{\"text\": \"$bar_chars\", \"tooltip\": \"Audio Visualizer\", \"class\": \"custom-cava$([ $is_playing = true ] && echo ' playing')\"}"
done
