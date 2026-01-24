#!/bin/bash

# Automated Dock Setup
# Uses dockutil to programmatically configure macOS Dock

# Get the absolute path of the directory where the script is located
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/../scripts/utils.sh"

setup_dock() {
    # Check if dockutil is installed
    if ! command -v dockutil &>/dev/null; then
        error "dockutil is not installed. Install it with: brew install dockutil"
        return 1
    fi

    info "Setting up Dock..."

    # Remove all default apps from Dock
    info "Removing default apps from Dock..."
    dockutil --no-restart --remove all

    # Add your preferred apps
    info "Adding preferred apps to Dock..."

    # Communication & Productivity (First - most used)
    [ -d "/System/Applications/Mail.app" ] && \
        dockutil --no-restart --add "/System/Applications/Mail.app"

    [ -d "/System/Applications/Messages.app" ] && \
        dockutil --no-restart --add "/System/Applications/Messages.app"

    [ -d "/System/Applications/Calendar.app" ] && \
        dockutil --no-restart --add "/System/Applications/Calendar.app"

    # Browser
    [ -d "/Applications/Safari.app" ] && \
        dockutil --no-restart --add "/Applications/Safari.app"

    # Development
    [ -d "/Applications/PhpStorm.app" ] && \
        dockutil --no-restart --add "/Applications/PhpStorm.app"

    [ -d "/Applications/WezTerm.app" ] && \
        dockutil --no-restart --add "/Applications/WezTerm.app"

    # Entertainment
    [ -d "/Applications/Spotify.app" ] && \
        dockutil --no-restart --add "/Applications/Spotify.app"

    # System
    [ -d "/System/Applications/System Settings.app" ] && \
        dockutil --no-restart --add "/System/Applications/System Settings.app"

    # Restart Dock to apply changes
    info "Restarting Dock..."
    killall Dock

    success "Dock setup complete!"
}

# Run if executed directly
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    setup_dock
fi
