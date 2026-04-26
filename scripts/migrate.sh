#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATIONS_DIR="$DOTFILES_DIR/migrations"
STATE_FILE="$HOME/.dotfiles-migrations"

source "$DOTFILES_DIR/scripts/utils.sh"

touch "$STATE_FILE"

if [ ! -d "$MIGRATIONS_DIR" ] || [ -z "$(ls -A "$MIGRATIONS_DIR"/*.sh 2>/dev/null)" ]; then
    info "No migrations found."
    exit 0
fi

pending=0

for migration in "$MIGRATIONS_DIR"/*.sh; do
    name="$(basename "$migration")"

    if grep -qFx "$name" "$STATE_FILE"; then
        continue
    fi

    pending=$((pending + 1))

    info "Running migration: $name"
    (
        source "$migration"
        up
    )

    echo "$name" >> "$STATE_FILE"
    success "Completed: $name"
done

if [ "$pending" -eq 0 ]; then
    info "No pending migrations."
else
    success "Ran $pending migration(s)."
fi
