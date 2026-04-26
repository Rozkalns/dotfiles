#!/bin/bash
# Migration: Switch claude-code from brew cask to official installer

up() {
    # Remove brew cask version
    if brew list --cask claude-code &>/dev/null; then
        info "Removing brew cask claude-code..."
        brew uninstall --cask claude-code
    fi

    # Install via official installer
    info "Installing Claude Code via official installer..."
    curl -fsSL https://claude.ai/install.sh | bash

    if command -v claude &>/dev/null; then
        success "Claude Code installed via official installer."
    else
        warning "Claude Code binary not found in PATH. You may need to restart your shell."
    fi
}
