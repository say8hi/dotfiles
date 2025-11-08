#!/usr/bin/env bash
#==============================================================================
# GTK Bookmarks Generator
# Generates GTK file manager bookmarks with user-specific paths
#==============================================================================

set -euo pipefail

BOOKMARKS_FILE="${HOME}/.config/gtk-3.0/bookmarks"

# Create directory if it doesn't exist
mkdir -p "$(dirname "${BOOKMARKS_FILE}")"

# Generate bookmarks
cat > "${BOOKMARKS_FILE}" << EOF
file://${HOME}/Downloads Downloads
file://${HOME}/Desktop Desktop
file://${HOME}/Documents Documents
file://${HOME}/Pictures Pictures
file://${HOME}/Videos Videos
EOF

echo "GTK bookmarks generated at ${BOOKMARKS_FILE}"