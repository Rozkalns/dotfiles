# Dotfiles bin utilities
# Auto-detect dotfiles location by following the .zshrc symlink
if [ -z "$DOTFILES_DIR" ]; then
    # Get the target of the .zshrc symlink
    _zshrc_link="$(readlink ~/.zshrc)"
    # If relative, prepend HOME to make it absolute
    [[ "$_zshrc_link" != /* ]] && _zshrc_link="$HOME/$_zshrc_link"
    # Get dotfiles dir (two levels up from .zshrc: runcom/.zshrc -> runcom -> dotfiles)
    DOTFILES_DIR="$(cd "$(dirname "$(dirname "$_zshrc_link")")" 2>/dev/null && pwd)"
    unset _zshrc_link
fi
export DOTFILES_DIR
export PATH="$DOTFILES_DIR/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1

# Bat (better cat) configuration
export BAT_PAGER="less -RFX"
# -R: show colors
# -F: quit if one screen
# -X: don't clear screen on exit
# Note: Removed --mouse flag as it causes escape sequences to leak

# Pipenv
export PIPENV_VENV_IN_PROJECT=1

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" # Initialize pyenv when a new shell spawns

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
starship config palette $STARSHIP_THEME

# Neovim as MANPAGER
export MANPAGER='nvim +Man!'

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files

bindkey "ç" fzf-cd-widget # Fix for ALT+C on Mac

# zoxide - a better cd command
eval "$(zoxide init zsh)"

# thefuck - corrects your previous console command
eval $(thefuck --alias)

# Vi mode
# ANSI cursor escape codes:
# \e[0 q: Reset to the default cursor style.
# \e[1 q: Blinking block cursor.
# \e[2 q: Steady block cursor (non-blinking).
# \e[3 q: Blinking underline cursor.
# \e[4 q: Steady underline cursor (non-blinking).
# \e[5 q: Blinking bar cursor.
# \e[6 q: Steady bar cursor (non-blinking).
bindkey -e # Enable emacs keybindings
