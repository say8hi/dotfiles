#!/bin/zsh
# =====================================================
# PATH Configuration
# =====================================================

# Rust/Cargo
[[ -d "${HOME}/.cargo/bin" ]] && export PATH="${HOME}/.cargo/bin:${PATH}"

# Go
if command -v go >/dev/null 2>&1; then
    export PATH="${PATH}:$(go env GOPATH)/bin"
fi

# Spicetify
[[ -d "${HOME}/.spicetify" ]] && export PATH="${PATH}:${HOME}/.spicetify"

# Local bin
[[ -d "${HOME}/.local/bin" ]] && export PATH="${HOME}/.local/bin:${PATH}"

# Dotfiles scripts
[[ -d "${HOME}/dotfiles/scripts" ]] && export PATH="${HOME}/dotfiles/scripts:${PATH}"
