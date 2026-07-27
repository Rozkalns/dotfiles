#!/bin/bash
# Migration: Install the vault-brain Claude Code plugin
#
# Adds the private claude-vault-brain marketplace and installs the plugin, which
# provides the `note`, `who` and `vault-setup` skills plus hooks that keep the
# Obsidian vault index and validation current.
#
# The marketplace repo is private, so this needs working SSH access to GitHub.
# Without it the migration skips rather than failing — a machine that cannot
# reach the repo should still finish `make install`.
#
# This does not create the vault itself. Run `/vault-setup` in Claude Code
# afterwards; it locates the Obsidian vault, creates the ~/vault symlink and
# seeds the config files.

MARKETPLACE="Rozkalns/claude-vault-brain"
MARKETPLACE_NAME="claude-vault-brain"
PLUGIN="vault-brain"

up() {
    if ! command -v claude >/dev/null 2>&1; then
        warning "claude CLI not found; skipping vault-brain plugin install."
        return "$SKIP_EXIT"
    fi

    if claude plugin list 2>/dev/null | grep -q "$PLUGIN@$MARKETPLACE_NAME"; then
        info "vault-brain plugin already installed."
        return 0
    fi

    # The marketplace is a private repo. Check reachability before trying, so a
    # machine without the key gives a clear message instead of a git error.
    #
    # `ssh -T git@github.com` exits 1 even when auth succeeds ("does not provide
    # shell access"), so this must not be a pipeline — migrate.sh runs under
    # `set -o pipefail`, which would propagate that 1 and make the check always fail.
    probe="$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
                 -o ConnectTimeout=5 -T git@github.com 2>&1 || true)"
    if [[ "$probe" != *"successfully authenticated"* ]]; then
        warning "No SSH access to GitHub; skipping vault-brain (private repo)."
        info "Once your key is set up:  claude plugin marketplace add $MARKETPLACE"
        return "$SKIP_EXIT"
    fi

    if ! claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE_NAME"; then
        info "Adding $MARKETPLACE_NAME marketplace..."
        if ! claude plugin marketplace add "$MARKETPLACE" >/dev/null 2>&1; then
            warning "Could not add $MARKETPLACE_NAME marketplace; skipping."
            return "$SKIP_EXIT"
        fi
    fi

    info "Installing $PLUGIN plugin..."
    if claude plugin install "$PLUGIN@$MARKETPLACE_NAME" >/dev/null 2>&1; then
        success "vault-brain plugin installed."
        info "Next: run /vault-setup in Claude Code to wire up the vault."
        info "Hooks load at session start, so restart Claude Code to activate them."
    else
        warning "Could not install $PLUGIN; add it by hand with:"
        info "  claude plugin install $PLUGIN@$MARKETPLACE_NAME"
        return "$SKIP_EXIT"
    fi
}
