#!/usr/bin/env bash
# Serves the current git worktree on its own https .test site (Laravel Herd) with a fresh
# SQLite database and demo data, for manual QA. The shell version of kartites' `qa:up`, for
# apps without their own `composer qa:up`.
#
# Run it from the worktree root:  ~/.claude/skills/manual-qa/scripts/qa-up.sh
#
# Settings come from .claude/manual-qa.env (see SKILL.md for the lookup order):
#   QA_SITE_PREFIX  Herd site name prefix. Default: the main checkout's folder name.
#   QA_SEED         Artisan command that fills the demo. Default: "db:seed --force".
#   QA_PIN          Optional artisan command that prints "PIN: 123456".
#   QA_URL_PATH     Path added to the URL the tester opens, for example /demo.
#   QA_ENV_VARS     Extra .env values for QA only, space-separated KEY=value pairs.
# Lines the seed or PIN command prints that start with "QA:" are repeated at the end.
set -euo pipefail

fail() { echo "qa-up: $*" >&2; exit 1; }

root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "not inside a git checkout."
cd "$root"

git_dir=$(git rev-parse --path-format=absolute --git-dir)
common_dir=$(git rev-parse --path-format=absolute --git-common-dir)
main_checkout=$(dirname "$common_dir")

[ "$git_dir" != "$common_dir" ] || fail "run this in a git worktree, not in the main checkout."
command -v herd >/dev/null || fail "Laravel Herd is not on PATH."
[ -f artisan ] || fail "no artisan file here; this is not a Laravel app."

settings_file=""
for candidate in .claude/manual-qa.env "$main_checkout/.claude/manual-qa.env" .claude/manual-qa.env.example; do
    if [ -f "$candidate" ]; then settings_file=$candidate; break; fi
done

# Reads one KEY=value line as data (never sourced), without surrounding quotes.
setting() {
    local value=""
    if [ -n "$settings_file" ]; then
        value=$(grep -E "^$1=" "$settings_file" | tail -1 | cut -d= -f2- || true)
        value=${value#\"}; value=${value%\"}; value=${value#\'}; value=${value%\'}
    fi
    printf '%s' "${value:-${2:-}}"
}

env_value() { grep -E "^$1=" "$2" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '"' || true; }

# Sets KEY=value in .env, replacing the line if it exists.
set_env() {
    local key=$1 value=$2 escaped
    escaped=$(printf '%s' "$value" | sed -e 's/[\\|&]/\\&/g')
    if grep -qE "^$key=" .env; then
        sed -i '' -E "s|^$key=.*|$key=$escaped|" .env
    else
        printf '%s=%s\n' "$key" "$value" >> .env
    fi
}

[ -f .env ] || cp .env.example .env
[ "$(env_value APP_ENV .env)" = "local" ] || fail "APP_ENV is not local in .env."

prefix=$(setting QA_SITE_PREFIX "$(basename "$main_checkout")")
base=$(basename "$root")
case "$base" in "$prefix"-*) site=$base ;; *) site="$prefix-$base" ;; esac
site=$(printf '%s' "$site" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
url="https://$site.test"
database="$root/database/qa.sqlite"

# 1. Link the Herd site, then undo whatever Boost's update wrote into the checkout while linking.
if ! herd links 2>/dev/null | grep -qF "$root"; then
    before=$(git status --porcelain)
    edited_before=$(printf '%s\n' "$before" | grep -v '^??' | cut -c4- | while IFS= read -r path; do
        [ -f "$path" ] && printf '%s %s\n' "$(md5 -q "$path")" "$path"; done || true)

    herd link --secure --no-interaction "$site" >/dev/null

    comm -13 <(printf '%s\n' "$before" | sort) <(git status --porcelain | sort) | while IFS= read -r line; do
        [ -n "$line" ] || continue
        path=${line:3}
        case "$line" in
            '??'*) git clean -fdq -- "$path" ;;
            *) git checkout -- "$path" ;;
        esac
    done

    # A file that already had local edits cannot be reverted without losing them, so say so.
    printf '%s\n' "$edited_before" | while read -r hash path; do
        [ -n "$path" ] && [ -f "$path" ] && [ "$(md5 -q "$path")" != "$hash" ] \
            && echo "qa-up: herd link changed $path, which already had local edits. Check git diff $path." >&2
    done || true
fi

# 2. A fresh database and the QA site's own URL.
rm -f "$database" "$database-wal" "$database-shm"
touch "$database"
set_env APP_URL "$url"
set_env DB_CONNECTION sqlite
set_env DB_DATABASE "$database"
for pair in $(setting QA_ENV_VARS); do
    set_env "${pair%%=*}" "${pair#*=}"
done

[ -d vendor ] || composer install --no-interaction --quiet
[ -n "$(env_value APP_KEY .env)" ] || php artisan key:generate --force --no-interaction >/dev/null

# 3. Build assets in the background while the database fills; neither depends on the other.
rm -f public/hot
build_log=$(mktemp -t qa-build)
(
    [ -d node_modules ] || npm ci --silent
    npm run build
) >"$build_log" 2>&1 &
build_pid=$!

# 4. Schema, PIN and demo data.
php artisan config:clear --no-interaction >/dev/null
php -d memory_limit=-1 artisan migrate --force --no-interaction >/dev/null

notes=""
pin_line=""
pin_command=$(setting QA_PIN)
if [ -n "$pin_command" ]; then
    branch=$(git branch --show-current)
    # shellcheck disable=SC2086
    pin_output=$(php -d memory_limit=-1 artisan $pin_command "$branch")
    pin=$(printf '%s' "$pin_output" | grep -oE 'PIN:[[:space:]]+[0-9]{6}' | grep -oE '[0-9]{6}' | head -1)
    [ -n "$pin" ] || fail "$pin_command printed no PIN: $pin_output"
    pin_line="PIN: $pin"
    notes=$(printf '%s' "$pin_output" | grep '^QA:' || true)
fi

# shellcheck disable=SC2086
seed_output=$(php -d memory_limit=-1 artisan $(setting QA_SEED "db:seed --force") --no-interaction)
notes=$(printf '%s\n%s' "$notes" "$(printf '%s' "$seed_output" | grep '^QA:' || true)" | sed '/^$/d')

if ! wait "$build_pid"; then
    cat "$build_log" >&2
    fail "npm run build failed."
fi
rm -f "$build_log"

echo
echo "URL: $url$(setting QA_URL_PATH)"
[ -z "$pin_line" ] || echo "$pin_line"
[ -z "$notes" ] || printf '%s\n' "$notes" | sed 's/^QA: *//'
echo "Follow the manual-qa skill for the test steps."
