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
