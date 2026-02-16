# zsh Options
setopt HIST_IGNORE_ALL_DUPS

# Load all modular config files safely
# Files are loaded in alphanumeric order (00-*, 05-*, etc.)
for f in ~/.zsh.d/*.zsh; do
  [ -f "$f" ] && source "$f"
done

# Local machine-specific config (gitignored - for Herd, work-specific stuff, etc.)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
