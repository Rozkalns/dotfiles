#!/bin/bash
# Migration: Install sqlit TUI via uv

up() {
    info "Installing sqlit-tui..."
    uv tool install sqlit-tui
    success "sqlit-tui installed."
}
