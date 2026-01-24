#!/bin/bash

# Dotfiles Installation Script
# This is a wrapper around the Makefile for backward compatibility

set -e

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add bin to PATH for utility scripts
export PATH="$SCRIPT_DIR/bin:$PATH"

# Source utils for colored output
. "$SCRIPT_DIR/scripts/utils.sh"

echo ""
info "========================================"
info "   Dotfiles Installation (v2.0)"
info "========================================"
echo ""
info "This installation uses GNU stow + Makefile"
info "See 'make help' for all available commands"
echo ""

# Check if stow is installed
if ! command -v stow >/dev/null 2>&1; then
    warning "GNU stow is not installed yet"
    info "It will be installed via Homebrew during setup"
    echo ""
fi

# Interactive prompts
read -p "Install/update apps via Homebrew? [y/n] " install_apps
read -p "Create/update symlinks? [y/n] " create_symlinks

echo ""

# Build make command based on user choices
if [[ "$install_apps" == "y" ]]; then
    info "Running full installation..."
    make all
elif [[ "$create_symlinks" == "y" ]]; then
    info "Creating symlinks only..."
    make core link

    # Optionally run macOS defaults
    if is-macos; then
        read -p "Apply macOS system defaults? [y/n] " apply_defaults
        if [[ "$apply_defaults" == "y" ]]; then
            make defaults
        fi
    fi
else
    warning "No actions selected. Exiting."
    echo ""
    info "Run 'make help' to see all available commands"
    exit 0
fi

echo ""
success "Installation complete!"
echo ""
info "Next steps:"
info "  1. Reload shell: source ~/.zshrc"
info "  2. Or open a new terminal window"
echo ""
info "Useful commands:"
info "  make update    - Update all packages"
info "  make unlink    - Remove all symlinks"
info "  make test      - Test installation"
info "  make help      - Show all commands"
echo ""
