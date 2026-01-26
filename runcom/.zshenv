# Secrets
[ -f "$HOME/.env" ] && source "$HOME/.env"

# XDG Base directory specification
export XDG_CONFIG_HOME="$HOME/.config"         # Config files
export XDG_CACHE_HOME="$HOME/.cache"           # Cache files
export XDG_DATA_HOME="$HOME/.local/share"      # Application data
export XDG_STATE_HOME="$HOME/.local/state"     # Logs and state files

# Themes (onedark or nord)
export NVIM_THEME="catppuccin" # catppuccin_mocha
export STARSHIP_THEME="catppuccin_mocha"
export WEZTERM_THEME="Catppuccin Mocha"
export EZA_CONFIG_DIR="$HOME/.config/eza"

# Use Neovim as default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Add /usr/local/bin to the beginning of the PATH environment variable.
# This ensures that executables in /usr/local/bin are found before other directories in the PATH.
export PATH="/usr/local/bin:$PATH"

# Hide computer name in terminal
export DEFAULT_USER="$(whoami)"