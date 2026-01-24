#!/usr/bin/env bash

# MOTD Setup Script
# Installs custom update reminder to /etc/update-motd.d/

# Source utils.sh
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/../scripts/utils.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOTD_SOURCE="$SCRIPT_DIR/99-custom-update-reminder"
MOTD_DEST="/etc/update-motd.d/99-custom-update-reminder"

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    warning "MOTD setup is only for Linux systems"
    exit 0
fi

# Check if /etc/update-motd.d exists (Ubuntu/Debian)
if [ ! -d "/etc/update-motd.d" ]; then
    warning "/etc/update-motd.d does not exist on this system"
    echo "MOTD setup skipped (not Ubuntu/Debian)"
    exit 0
fi

info "Installing custom MOTD..."

# Copy MOTD script (requires sudo)
if sudo cp "$MOTD_SOURCE" "$MOTD_DEST"; then
    sudo chmod +x "$MOTD_DEST"
    info "✅ MOTD installed to $MOTD_DEST"
    echo ""
    echo "The MOTD will now show:"
    echo "  • Number of available updates"
    echo "  • Suggestion to run 'topgrade' (if installed)"
    echo "  • Reboot required warnings"
    echo "  • System uptime"
    echo ""
    echo "To test it now:"
    echo "  run-parts /etc/update-motd.d/"
else
    error "Failed to install MOTD (sudo required)"
    exit 1
fi
