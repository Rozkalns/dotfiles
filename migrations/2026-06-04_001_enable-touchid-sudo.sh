#!/bin/bash
# Migration: Enable Touch ID for sudo (macOS)
#
# Uses the Apple-sanctioned /etc/pam.d/sudo_local drop-in, which survives
# system updates. Requires macOS 14+ (the sudo_local.template ships with it).

up() {
    if [[ "$OSTYPE" != darwin* ]]; then
        info "Touch ID for sudo is macOS-only; skipping."
        return 0
    fi

    local target="/etc/pam.d/sudo_local"
    local template="/etc/pam.d/sudo_local.template"

    # Already enabled (e.g. set up by hand): active, uncommented pam_tid line.
    if [ -f "$target" ] && grep -Eq '^auth[[:space:]].*pam_tid\.so' "$target"; then
        info "Touch ID for sudo already enabled."
        return 0
    fi

    if [ ! -f "$template" ]; then
        warning "No $template found (needs macOS 14+); skipping Touch ID for sudo."
        return 0
    fi

    info "Enabling Touch ID for sudo (will prompt for your password)..."

    if [ ! -f "$target" ]; then
        sudo cp "$template" "$target"
    fi

    # Uncomment the pam_tid.so line.
    sudo sed -i '' 's/^#\(auth[[:space:]].*pam_tid\.so\)/\1/' "$target"

    if grep -Eq '^auth[[:space:]].*pam_tid\.so' "$target"; then
        success "Touch ID for sudo enabled."
    else
        error "Could not enable Touch ID for sudo; check $target manually."
        return 1
    fi
}
