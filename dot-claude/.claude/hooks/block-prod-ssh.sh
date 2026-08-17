#!/usr/bin/env bash
# Claude Code PreToolUse(Bash) guard: remote access needs explicit approval.
#
# Deliberately contains no hostnames, IPs or command names. Everything
# environment-specific lives in a private config file outside this repository:
#
#     $HOME/.claude/prod-hosts.conf
#
#     deny:  <regex>     destination is production - approval required
#     allow: <regex>     destination is known-safe - no approval needed
#     cmd:   <regex>     remote command permitted unattended on a deny: host
#
# Design notes, in case this looks over-built:
#
# 1. Fail closed, not "does it look read-only". The command that prompted this guard
#    was a synthetic test workload run on a production host - it read nothing and
#    wrote nothing, so any read/write heuristic waves it through. The question is not
#    "is this safe" but "is this the one thing that was authorised".
#
# 2. Resolve, don't name-match. An ssh alias is one person's ~/.ssh/config entry, so
#    matching the name is defeated by renaming the alias or using the address
#    directly. Every destination is expanded with `ssh -G`, which reads ~/.ssh/config
#    and does NOT connect, and the RESOLVED value is classified. Renaming an alias
#    changes nothing.
#
# 3. Unclassified is blocked. "Not on the deny list" is not the same as "safe" - only
#    allow: is an allowlist. A destination matching neither list needs a human.
#
# 4. Missing config blocks everything. A guard that silently disables itself when its
#    config is absent is worse than no guard.
#
# Every attempt is appended to $ATTEMPT_LOG with the destination and what it resolved
# to, so targets are auditable after the fact:  tail ~/.claude/prod-ssh-attempts.log
set -uo pipefail

CONFIG="${PROD_HOSTS_CONF:-$HOME/.claude/prod-hosts.conf}"
ATTEMPT_LOG="${ATTEMPT_LOG:-$HOME/.claude/prod-ssh-attempts.log}"

REMOTE_TOOLS='ssh|scp|sftp|rsync|ssh-copy-id|ssh-keyscan'

# Flags that consume the next token as a value, so it is not mistaken for a destination.
VALUE_FLAGS='i|p|o|l|F|b|c|D|L|R|W|e|m|O|Q|S|B|E|I|J'

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Cheap bail-out: no remote-access tool anywhere in the command.
printf '%s' "$cmd" | grep -qE "(^|[;&|(]|[[:space:]]|/)(${REMOTE_TOOLS})([[:space:]]|$)" || exit 0

log_attempt() {
    printf '%s\t%s\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$1" "$cmd" >> "$ATTEMPT_LOG" 2>/dev/null || true
}

# ------------------------------------------------------------------- load config
if [ ! -r "$CONFIG" ]; then
    log_attempt "blocked no-config"
    cat >&2 <<MSG
Blocked: remote access guard has no configuration.

Expected: ${CONFIG}

Without it there is no way to tell a production host from a safe one, so everything
is refused rather than silently allowed. Create it with one regex per line:

    deny:  ^10\\.0\\.0\\.[0-9]{1,3}\$
    allow: ^github\\.com\$
    cmd:   ^some-readonly-tool\$

Or set PROD_HOSTS_CONF to point elsewhere.
MSG
    exit 2
fi

join_patterns() {
    grep -E "^[[:space:]]*$1:" "$CONFIG" 2>/dev/null \
        | sed -E "s/^[[:space:]]*$1:[[:space:]]*//" \
        | sed -E 's/[[:space:]]+$//' \
        | grep -v '^$' \
        | paste -sd '|' -
}

PROD_PATTERNS="$(join_patterns deny)"
SAFE_PATTERNS="$(join_patterns allow)"
ALLOWED_CMDS="$(join_patterns cmd)"

if [ -z "$PROD_PATTERNS" ]; then
    log_attempt "blocked empty-deny-list"
    echo "Blocked: ${CONFIG} defines no deny: patterns, so nothing can be classified." >&2
    exit 2
fi

# ------------------------------------------------------- remote payload extraction
# The first single- or double-quoted string is the remote command. Anything after its
# closing quote is a local pipeline (| jq, > file) on this machine and is not inspected.
payload="$(printf '%s' "$cmd" | sed -n "s/^[^']*'\([^']*\)'.*/\1/p")"
if [ -z "$payload" ]; then
    payload="$(printf '%s' "$cmd" | sed -n 's/^[^"]*"\([^"]*\)".*/\1/p')"
fi

# Strip the payload before hunting for destinations, so its contents cannot be
# mistaken for a hostname.
invocation="$cmd"
[ -n "$payload" ] && invocation="${cmd%%"$payload"*}"

# ------------------------------------------------------------ destination discovery
destinations=""
skip_next=0
prev_flag=""
seen_tool=0
for tok in $invocation; do
    if [ "$skip_next" = 1 ]; then
        if [ "$prev_flag" = "-J" ]; then   # ProxyJump target is a destination too
            j="${tok##*@}"
            destinations="$destinations ${j%%:*}"
        fi
        skip_next=0
        continue
    fi

    if printf '%s' "$tok" | grep -qE "(^|/)(${REMOTE_TOOLS})$"; then
        seen_tool=1
        continue
    fi
    [ "$seen_tool" = 1 ] || continue

    case "$tok" in
        -*)
            printf '%s' "$tok" | grep -qE "^-(${VALUE_FLAGS})$" && { prev_flag="$tok"; skip_next=1; }
            continue
            ;;
    esac

    host="${tok##*@}"   # drop user@
    host="${host%%:*}"  # drop :path for scp/rsync
    printf '%s' "$host" | grep -qE '^[a-zA-Z0-9_.-]+$' || continue
    destinations="$destinations $host"
done

destinations="$(printf '%s' "$destinations" | tr ' ' '\n' | grep -v '^$' | sort -u)"
if [ -z "$destinations" ]; then
    log_attempt "no-destination"   # e.g. `ssh -V`
    exit 0
fi

# ------------------------------------------------------------------ classification
prod_hits=""
unknown_hits=""
while IFS= read -r dest; do
    [ -z "$dest" ] && continue
    resolved="$(ssh -G "$dest" 2>/dev/null | awk '$1=="hostname"{print $2; exit}')"
    [ -z "$resolved" ] && resolved="$dest"

    if printf '%s\n%s' "$resolved" "$dest" | grep -qE "$PROD_PATTERNS"; then
        prod_hits="$prod_hits ${dest}[${resolved}]"
    elif [ -n "$SAFE_PATTERNS" ] && printf '%s\n%s' "$resolved" "$dest" | grep -qE "$SAFE_PATTERNS"; then
        :
    else
        unknown_hits="$unknown_hits ${dest}[${resolved}]"
    fi
done <<< "$destinations"

if [ -z "$prod_hits" ] && [ -z "$unknown_hits" ]; then
    log_attempt "allowed-safe-host"
    exit 0
fi

# A deny: host is reachable only by a permitted cmd:, with no shell chaining.
if [ -z "$unknown_hits" ] && [ -n "$payload" ] && [ -n "$ALLOWED_CMDS" ] \
    && printf '%s' "$payload" | grep -qE "$ALLOWED_CMDS" \
    && ! printf '%s' "$payload" | grep -qE '[;&`|<>]|\$\(' ; then
    log_attempt "allowed-permitted-cmd${prod_hits}"
    exit 0
fi

log_attempt "blocked${prod_hits}${unknown_hits}"

{
    echo "Blocked: remote access needs approval."
    echo
    [ -n "$prod_hits" ] && echo "  production target(s):   ${prod_hits# }"
    [ -n "$unknown_hits" ] && echo "  unclassified target(s): ${unknown_hits# }"
    echo "  shown as destination[resolved] - expanded via ssh -G, without connecting"
    cat <<MSG

Production hosts are not a scratchpad. Only a specifically permitted read-only command
may run there unattended, and only with no shell chaining in it. Everything else needs
approval first, including commands that look harmless.

An unclassified target is blocked on purpose: "not on the deny list" is not the same
as "safe". Renaming an ssh alias does not help - destinations are resolved, not
name-matched.

What to do instead:
  - Need data from a remote host? Write the script locally and ask for it to be run.
  - Need to observe a process?    Hand over a short one-liner to paste.
  - Genuinely need this command?  Ask, in one sentence, and wait.

Classification lists: ${CONFIG}
Attempt log:          ${ATTEMPT_LOG}
MSG
} >&2
exit 2
