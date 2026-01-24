#!/usr/bin/env bash

# Topgrade LaunchAgent Setup
# Installs a LaunchAgent to run topgrade daily at 3am

# Source utils.sh
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/../scripts/utils.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_SOURCE="$SCRIPT_DIR/com.user.topgrade.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.user.topgrade.plist"

info "Setting up Topgrade LaunchAgent..."

# Check if topgrade is installed
if ! command -v topgrade &>/dev/null; then
    warning "topgrade not installed. Install it with: brew install topgrade"
    echo "Skipping LaunchAgent setup"
    exit 0
fi

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$HOME/Library/LaunchAgents"

# Check if old brew updater exists and remove it
OLD_BREW_PLIST="$HOME/Library/LaunchAgents/com.user.brewupdate.plist"
if [ -f "$OLD_BREW_PLIST" ]; then
    info "Found old brew updater LaunchAgent, removing..."
    launchctl unload "$OLD_BREW_PLIST" 2>/dev/null || true
    rm "$OLD_BREW_PLIST"
fi

# Copy plist to LaunchAgents
info "Installing LaunchAgent..."
cp "$PLIST_SOURCE" "$PLIST_DEST"

# Load the LaunchAgent
info "Loading LaunchAgent..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

info "✅ Topgrade LaunchAgent installed!"
echo ""
echo "Configuration:"
echo "  • Runs daily at 3:00 AM"
echo "  • Updates: Homebrew, npm, composer, git repos, and more"
echo "  • Logs: ~/topgrade_stdout.log and ~/topgrade_stderr.log"
echo "  • Notifications: macOS notifications on start/finish"
echo ""
echo "To manually run topgrade now:"
echo "  topgrade --yes"
echo ""
echo "To test the LaunchAgent:"
echo "  launchctl start com.user.topgrade"
