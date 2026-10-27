#!/usr/bin/env bash

# Git Setup Script
# Writes this machine's git identity to ~/.config/git-private/user. The dotfiles
# git config includes that file, so the identity stays out of this public repo.

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/utils.sh"

DOTFILES_GIT_CONFIG="$HOME/.config/git/config"
USER_FILE="$HOME/.config/git-private/user"

info "Setting up Git configuration..."
echo ""

# Check if dotfiles git config exists
if [ ! -f "$DOTFILES_GIT_CONFIG" ]; then
    error "Dotfiles git config not found at $DOTFILES_GIT_CONFIG"
    echo "Please run 'make link' first to create symlinks"
    exit 1
fi

# Git reads ~/.gitconfig after the dotfiles config, so an old one overrides it
if [ -e "$HOME/.gitconfig" ] || [ -L "$HOME/.gitconfig" ]; then
    backup="$HOME/.gitconfig.bak-$(date +%Y%m%d-%H%M%S)"
    mv "$HOME/.gitconfig" "$backup"
    warning "Moved ~/.gitconfig to $backup (it overrode the dotfiles config)"
    echo ""
fi

if [ -f "$USER_FILE" ]; then
    warning "$USER_FILE already exists:"
    sed 's/^/    /' "$USER_FILE"
    read -r -p "Overwrite? [y/N] " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "Skipping git setup"
        exit 0
    fi
fi

# Prompt for user info. No default email: work and personal machines differ.
printf "%sEnter your Git user information:%s\n" "$blue" "$default_color"
read -r -p "Full name [Roberts Rožkalns]: " git_name
git_name=${git_name:-Roberts Rožkalns}

git_email=""
while [[ "$git_email" != *@* ]]; do
    read -r -p "Email (work or personal, for this machine): " git_email
done

echo ""

mkdir -p "$(dirname "$USER_FILE")"
cat > "$USER_FILE" << EOF
# Git identity for this machine. Written by \`make git-setup\` in ~/.dotfiles.

[user]
	name = $git_name
	email = $git_email
EOF

info "✅ Git configuration complete!"
echo ""
echo "Configuration:"
echo "  • Name:  $git_name"
echo "  • Email: $git_email"
echo "  • Identity: $USER_FILE (private, not in dotfiles)"
echo "  • Settings: ~/.config/git/config (from dotfiles)"
echo ""
echo "Test it:"
echo "  git config --show-origin --get user.email"
