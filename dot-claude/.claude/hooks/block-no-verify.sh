#!/usr/bin/env bash
# Claude Code PreToolUse(Bash) guard: deny the assistant any git commit/push
# that skips hooks (--no-verify, or `commit -n`). `git push -n` = --dry-run, allowed.
# A human in their own terminal is unaffected (this only sees Claude's Bash calls).
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Only react to git commit / push invocations.
if printf '%s' "$cmd" | grep -qE '(^|[;&| ])git( |$)' \
   && printf '%s' "$cmd" | grep -qE '(commit|push)'; then

  if printf '%s' "$cmd" | grep -qE -- '--no-verify'; then
    echo "Blocked: --no-verify disables the git quality + secret hooks. Run 'composer lint' and push normally, or ask a human to bypass." >&2
    exit 2
  fi
  # `-n` means --no-verify only for commit (push -n is --dry-run, fine).
  if printf '%s' "$cmd" | grep -qE 'commit([^;&|]* )-n( |$)'; then
    echo "Blocked: 'git commit -n' (--no-verify) is disabled for the assistant. Run 'composer lint' and commit normally." >&2
    exit 2
  fi
fi
exit 0
