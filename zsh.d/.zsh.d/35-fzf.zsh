# FZF - Fuzzy finder

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files

# Fix for ALT+C on Mac
bindkey "ç" fzf-cd-widget
