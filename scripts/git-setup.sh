#!/usr/bin/env bash

# Git Setup Script
# Creates ~/.gitconfig with user info and includes dotfiles git config

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/utils.sh"

GITCONFIG="$HOME/.gitconfig"
DOTFILES_GIT_CONFIG="$HOME/.config/git/config"

info "Setting up Git configuration..."
echo ""

# Check if dotfiles git config exists
if [ ! -f "$DOTFILES_GIT_CONFIG" ]; then
    error "Dotfiles git config not found at $DOTFILES_GIT_CONFIG"
    echo "Please run 'make link' first to create symlinks"
    exit 1
fi

# Prompt for user info
printf "%sEnter your Git user information:%s\n" "$blue" "$default_color"
read -p "Full name [Roberts Rožkalns]: " git_name
git_name=${git_name:-Roberts Rožkalns}

read -p "Email [roberts.rozkalns@me.com]: " git_email
git_email=${git_email:-roberts.rozkalns@me.com}

echo ""

# Check if ~/.gitconfig already exists
if [ -f "$GITCONFIG" ]; then
    warning "~/.gitconfig already exists"
    read -p "Overwrite? [y/N] " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "Skipping git setup"
        exit 0
    fi
fi

# Create ~/.gitconfig with user info and include
cat > "$GITCONFIG" << EOF
[user]
	name = $git_name
	email = $git_email

[include]
	path = ~/.config/git/config
EOF

info "✅ Git configuration complete!"
echo ""
echo "Configuration:"
echo "  • Name:  $git_name"
echo "  • Email: $git_email"
echo "  • Settings: ~/.config/git/config (from dotfiles)"
echo ""
echo "Test it:"
echo "  git config --get user.name"
echo "  git config --get user.email"
echo "  git config --list"
