# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Load all modular config files safely
# Files are loaded in alphanumeric order (00-*, 05-*, etc.)
for f in ~/.zsh.d/*.zsh; do
  [ -f "$f" ] && source "$f"
done

# Local machine-specific config (gitignored - for Herd, work-specific stuff, etc.)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/roberts/Library/Application Support/Herd/config/php/84/"
