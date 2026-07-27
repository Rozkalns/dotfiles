#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATIONS_DIR="$DOTFILES_DIR/migrations"
STATE_FILE="$HOME/.dotfiles-migrations"

# A migration's up() returns SKIP_EXIT to say "not applicable on this machine
# yet" (no network, missing tool, private repo unreachable). Skips and outright
# failures are both left unrecorded so they retry on the next run — recording a
# skip as done is how a broken migration stays invisible.
SKIP_EXIT=42

source "$DOTFILES_DIR/scripts/utils.sh"

touch "$STATE_FILE"

if [ ! -d "$MIGRATIONS_DIR" ] || [ -z "$(ls -A "$MIGRATIONS_DIR"/*.sh 2>/dev/null)" ]; then
    info "No migrations found."
    exit 0
fi

pending=0
ran=0
skipped=0
failed=0

for migration in "$MIGRATIONS_DIR"/*.sh; do
    name="$(basename "$migration")"

    if grep -qFx "$name" "$STATE_FILE"; then
        continue
    fi

    pending=$((pending + 1))

    info "Running migration: $name"

    # `|| status=$?` keeps set -e from aborting the whole run on a failed
    # migration — the remaining ones still get their turn.
    status=0
    (
        source "$migration"
        up
    ) || status=$?

    case "$status" in
        0)
            echo "$name" >> "$STATE_FILE"
            ran=$((ran + 1))
            success "Completed: $name"
            ;;
        "$SKIP_EXIT")
            skipped=$((skipped + 1))
            warning "Skipped: $name — left pending, will retry next run."
            ;;
        *)
            failed=$((failed + 1))
            error "Failed: $name (exit $status) — left pending, will retry next run."
            ;;
    esac
done

if [ "$pending" -eq 0 ]; then
    info "No pending migrations."
else
    if [ "$ran" -gt 0 ]; then
        success "Ran $ran migration(s)."
    fi
    if [ "$skipped" -gt 0 ]; then
        warning "Skipped $skipped migration(s)."
    fi
    if [ "$failed" -gt 0 ]; then
        error "Failed $failed migration(s)."
        exit 1
    fi
fi

exit 0
