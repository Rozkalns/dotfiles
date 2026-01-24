# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1

# Bat (better cat) configuration
export BAT_PAGER="less -RFX"
# -R: show colors
# -F: quit if one screen
# -X: don't clear screen on exit
# Note: Removed --mouse flag as it causes escape sequences to leak

# Herd
export HERD_PHP_84_INI_SCAN_DIR="/Users/roberts/Library/Application Support/Herd/config/php/84/"

# Herd injected NVM configuration
export NVM_DIR="/Users/roberts/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# Herd injected PHP binary.
export PATH="/Users/roberts/Library/Application Support/Herd/bin/":$PATH

# Pipenv
export PIPENV_VENV_IN_PROJECT=1

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" # Initialize pyenv when a new shell spawns

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
# starship config palette $STARSHIP_THEME

# Neovim as MANPAGER
export MANPAGER='nvim +Man!'

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files

bindkey "ç" fzf-cd-widget # Fix for ALT+C on Mac

# fcd - fuzzy cd to selected directory
fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# zoxide - a better cd command
eval "$(zoxide init zsh)"

# thefuck - corrects your previous console command
eval $(thefuck --alias)

# Activate syntax highlighting
# Load Catppuccin Mocha theme BEFORE loading the plugin (if available)
if [ -f ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh ]; then
    source ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
fi

# Now load the syntax highlighting plugin
if [ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Change colors
# export ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue

# Activate autosuggestions
if [ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

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
export KEYTIMEOUT=1 # Makes switching modes quicker
export VI_MODE_SET_CURSOR=true # trigger cursor shape changes when switching modes
