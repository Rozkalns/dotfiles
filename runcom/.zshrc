# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# ZLE plugins (autosuggestions, syntax highlighting) - MUST be loaded last
[ -f "$HOME/.config/zsh/plugins.zsh" ] && source "$HOME/.config/zsh/plugins.zsh"

# Local machine-specific config (gitignored - for Herd, work-specific stuff, etc.)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
