# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/roberts/Library/Application Support/Herd/config/php/84/"
