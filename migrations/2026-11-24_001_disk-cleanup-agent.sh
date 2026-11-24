#!/bin/bash
# Migration: daily disk-cleanup --scan LaunchAgent (size index + low-space alert)

up() {
    if [ "$(uname -s)" != "Darwin" ]; then
        info "Not macOS, nothing to do."
        return 0
    fi

    local dest="$HOME/Library/LaunchAgents/com.user.disk-cleanup.plist"
    mkdir -p "$HOME/Library/LaunchAgents" "$HOME/.local/share/disk-cleanup"
    sed -e "s|__BIN__|$DOTFILES_DIR/bin|g" -e "s|__HOME__|$HOME|g" \
        "$DOTFILES_DIR/macos/com.user.disk-cleanup.plist" > "$dest"

    launchctl unload "$dest" 2>/dev/null || true
    launchctl load "$dest"
    success "disk-cleanup LaunchAgent installed (daily 12:30, alert below MIN_FREE_GB=30 in ~/.config/disk-cleanup/config)."
}
