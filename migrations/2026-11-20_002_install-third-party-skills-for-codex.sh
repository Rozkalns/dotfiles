#!/bin/bash
# Migration: install third-party skills for Claude Code and Codex
#
# Replaces the old `make skills` target. That target installed with only
# --agent claude-code, as a real copy in ~/.claude/skills, so Codex did not see
# it. With --agent claude-code --agent codex, the Skills CLI (skills.sh) puts the
# one real copy in ~/.agents/skills (Codex reads it there) and a relative link
# in ~/.claude/skills: the same layout as the dotfiles skills.
#
# A new machine gets these from `make macos` / `make linux`, which run
# migrations last; an existing one on `git pull`. It runs after
# 2026-11-20_001, which has already moved an old real ~/.claude/skills/<skill>
# into ~/.agents/skills and linked it back, so the CLI only refreshes that copy.
#
# To update later: npx skills update -g. To add another third-party skill:
# write a new migration like this one.
#
# Needs npx (Node comes from Herd, not Homebrew). Without it the migration
# skips and retries on the next run.

up() {
    if ! command -v npx >/dev/null 2>&1; then
        warning "npx not found; install Node (Herd). Third-party skills install on the next run."
        return "$SKIP_EXIT"
    fi

    npx -y skills add https://github.com/cloudflare/security-audit-skill \
        --skill security-audit --global --agent claude-code --agent codex --yes

    if [ ! -f "$HOME/.agents/skills/security-audit/SKILL.md" ]; then
        error "security-audit is not in ~/.agents/skills after the install."
        return 1
    fi
    if [ ! -f "$HOME/.claude/skills/security-audit/SKILL.md" ]; then
        error "Claude cannot reach security-audit through ~/.claude/skills."
        return 1
    fi
}
