# =====================================================
# ZSH Configuration
# Modular dotfiles configuration
# =====================================================

# Initialize starship prompt
export STARSHIP_CONFIG="${HOME}/dotfiles/config/starship/starship.toml"
eval "$(starship init zsh)"

# Initialize zoxide (better z)
eval "$(zoxide init zsh)"

# =====================================================
# User preferences
# =====================================================

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="${HOME}/.zsh_history"

# History options
setopt SHARE_HISTORY              # Share history between sessions
setopt HIST_IGNORE_DUPS           # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS       # Delete old duplicate entries
setopt HIST_FIND_NO_DUPS          # Don't show duplicates in search
setopt HIST_SAVE_NO_DUPS          # Don't save duplicates
setopt HIST_REDUCE_BLANKS         # Remove blank lines
setopt HIST_VERIFY                # Show command before executing from history

# Navigation options
setopt AUTO_CD                    # cd by just typing directory name
setopt AUTO_PUSHD                 # Push dirs to stack automatically
setopt PUSHD_IGNORE_DUPS          # Don't push duplicates
setopt PUSHD_SILENT               # Don't print directory stack

# Other options
setopt CORRECT                    # Spelling correction for commands
setopt INTERACTIVE_COMMENTS       # Allow comments in interactive shell

# =====================================================
# Completion settings
# =====================================================

# Enable completion system with caching (faster startup)
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Enable menu selection with visual highlighting
zstyle ':completion:*' menu select

# Custom completion colors (directories in blue, selected in cyan)
zstyle ':completion:*:default' list-colors \
    'di=34' \
    'ln=36' \
    'ex=32'

# Highlight selected item in completion menu
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift-Tab to go backwards

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${HOME}/.zsh/cache"

# =====================================================
# Load dotfiles modules
# =====================================================

DOTFILES_SHELL="${HOME}/dotfiles/home/shell"

# Load modules in order (plugins last for syntax highlighting)
for module in path wayland conda aliases plugins; do
    if [[ -f "${DOTFILES_SHELL}/${module}.zsh" ]]; then
        source "${DOTFILES_SHELL}/${module}.zsh"
    fi
done

# Load dotfiles environment (optional, for scripts)
if [[ -f "${HOME}/dotfiles/lib/env.sh" ]]; then
    source "${HOME}/dotfiles/lib/env.sh"
fi

# =====================================================
# Welcome message (only for interactive shells)
# =====================================================

# Run neofetch only for interactive, non-SSH sessions
if [[ -o interactive ]] && [[ -z "${SSH_CONNECTION}" ]] && command -v neofetch >/dev/null 2>&1; then
    neofetch
fi

