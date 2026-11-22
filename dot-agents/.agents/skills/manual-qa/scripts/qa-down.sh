#!/usr/bin/env bash
# Stops serving the QA site of the current worktree and deletes its database. The shell version
# of kartites' `qa:down`, for apps without their own `composer qa:down`.
#
# Run it from the worktree root:  ~/.claude/skills/manual-qa/scripts/qa-down.sh
set -euo pipefail

fail() { echo "qa-down: $*" >&2; exit 1; }

root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "not inside a git checkout."
cd "$root"

git_dir=$(git rev-parse --path-format=absolute --git-dir)
common_dir=$(git rev-parse --path-format=absolute --git-common-dir)
main_checkout=$(dirname "$common_dir")

[ "$git_dir" != "$common_dir" ] || fail "run this in a git worktree, not in the main checkout."
command -v herd >/dev/null || fail "Laravel Herd is not on PATH."

settings_file=""
for candidate in .claude/manual-qa.env "$main_checkout/.claude/manual-qa.env" .claude/manual-qa.env.example; do
    if [ -f "$candidate" ]; then settings_file=$candidate; break; fi
done

prefix=""
if [ -n "$settings_file" ]; then
    prefix=$(grep -E '^QA_SITE_PREFIX=' "$settings_file" | tail -1 | cut -d= -f2- | tr -d "\"'" || true)
fi
prefix=${prefix:-$(basename "$main_checkout")}
base=$(basename "$root")
case "$base" in "$prefix"-*) site=$base ;; *) site="$prefix-$base" ;; esac
site=$(printf '%s' "$site" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
database="$root/database/qa.sqlite"

herd unlink "$site" >/dev/null 2>&1 || true
rm -f "$database" "$database-wal" "$database-shm"

echo "Unlinked https://$site.test and deleted $database."
