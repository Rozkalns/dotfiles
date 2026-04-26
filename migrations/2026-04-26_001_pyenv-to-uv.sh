#!/bin/bash
# Migration: Replace pyenv with uv for Python management

up() {
    # Remove pyenv
    if command -v pyenv &>/dev/null; then
        info "Removing pyenv..."
        brew uninstall pyenv 2>/dev/null || true
    fi

    if [ -d "$HOME/.pyenv" ]; then
        info "Removing ~/.pyenv directory..."
        rm -rf "$HOME/.pyenv"
    fi

    # Remove pipenv
    if command -v pipenv &>/dev/null; then
        info "Removing pipenv..."
        brew uninstall pipenv 2>/dev/null || true
        pip uninstall pipenv -y 2>/dev/null || true
    fi

    # Install uv
    if ! command -v uv &>/dev/null; then
        info "Installing uv..."
        brew install uv
    fi

    # Install Python via uv
    info "Installing Python 3.12 via uv..."
    uv python install 3.12

    success "Migrated from pyenv to uv."
}
