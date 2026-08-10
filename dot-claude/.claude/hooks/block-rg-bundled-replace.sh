#!/usr/bin/env bash
# Claude Code PreToolUse(Bash) guard: deny `rg` invocations that bundle -r with
# trailing letters (-rl, -rn, -rln, -ril, -nrl ...).
#
# In ripgrep, -r is --replace, NOT --recursive (rg is recursive by default). A
# bundled -r consumes the following characters as the replacement string, so
# `rg -rln 'tia'` means --replace=ln and rewrites every match:
#     "Initialise the tiara"  ->  "Inilnlise the lnra"
# It exits 0 and looks like a normal result, so the caller silently reads
# corrupted content. That is why this is a hard block rather than a warning.
#
# The check is scoped to the rg SEGMENT of a compound command, not the whole
# command line — otherwise `rg foo | xargs rm -rf` false-positives on rm's -rf.
#
# Allowed, because these are real --replace usage or fail loudly:
#   rg -r 'X' pat        standalone -r, value is the next arg
#   rg -or 'X' pat       -r last in the bundle, value is the next arg
#   rg --replace=X pat   long form
#   rg -lr pat           -r last; consumes pat, leaving no pattern -> rg errors
#   grep -rl pat         not rg — in grep, -r really is recursive
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Cheap bail-out: no rg anywhere, nothing to do.
printf '%s' "$cmd" | grep -qE '(^|[;&|( ]|/)rg( |$)' || exit 0

# Split the command line into segments on ; && || | and newline, so each
# segment is a single invocation. Order matters: && and || before a bare |.
segments="$(printf '%s' "$cmd" \
  | tr '\n' ';' \
  | sed 's/&&/;/g; s/||/;/g; s/|/;/g' \
  | tr ';' '\n')"

while IFS= read -r seg; do
  # Only inspect segments that actually invoke rg.
  printf '%s' "$seg" | grep -qE '(^|[[:space:]]|/)rg([[:space:]]|$)' || continue

  # A short-flag bundle where r is followed by at least one more letter.
  # Leading `--` cannot match: the char after the first `-` must be [a-zA-Z].
  if printf '%s' "$seg" | grep -qE '(^|[[:space:]])-[a-zA-Z]*r[a-zA-Z]+'; then
    cat >&2 <<'MSG'
Blocked: in ripgrep, -r is --replace, not --recursive.

rg searches recursively by default, so -r is never needed for recursion.
Bundling it (-rl, -rn, -rln, -ril) consumes the following letters as the
REPLACEMENT STRING and silently rewrites every match, exiting 0:

    rg -rln 'tia' file   ->  --replace=ln
    "Initialise the tiara" prints as "Inilnlise the lnra"

You get corrupted output that looks like a successful search.

Fix: drop the r.
    rg -ln 'pat'      list files + line numbers
    rg -l 'pat'       list matching files
    rg -n 'pat'       show line numbers

If you genuinely want --replace, keep -r unbundled:
    rg -r 'replacement' 'pat'      or      rg --replace='replacement' 'pat'
MSG
    exit 2
  fi
done <<< "$segments"

exit 0
