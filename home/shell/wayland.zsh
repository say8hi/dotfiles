#!/bin/zsh
# =====================================================
# Wayland Environment Variables
# =====================================================

# Only set these if running on Wayland
if [[ "${XDG_SESSION_TYPE}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY}" ]]; then
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export MOZ_ENABLE_WAYLAND=1
    export GDK_BACKEND=wayland
fi
