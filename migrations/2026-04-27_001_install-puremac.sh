#!/bin/bash
# Migration: Install PureMac cask

up() {
    if brew list --cask puremac &>/dev/null; then
        info "puremac already installed."
        return 0
    fi

    info "Installing puremac..."
    brew install --cask puremac
    success "puremac installed."
}
