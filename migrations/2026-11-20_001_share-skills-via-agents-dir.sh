#!/bin/bash
# Migration: share personal skills with Codex through ~/.agents/skills
#
# Claude Code reads skills from ~/.claude/skills. Codex reads ~/.agents/skills.
# One copy of each skill now lives in ~/.agents/skills, and ~/.claude/skills
# holds a relative link to it.
#
# - Skills from the dotfiles (package dot-agents) are linked by `make link`.
#   This migration does not touch them.
# - Skills that are real folders in ~/.claude/skills (made on this machine, not
#   in the dotfiles) are moved to ~/.agents/skills and linked back.
#   Not moved: links (stow or other), hidden folders, folders without a SKILL.md,
#   and `synced` (claude.ai manages it).
# - Global rules are one file, ~/.agents/AGENTS.md (package dot-agents).
#   ~/.claude/CLAUDE.md links to it through dot-claude, and `make link` links
#   ~/.codex/AGENTS.md to it. A real ~/.codex/AGENTS.md would block that link,
#   so it is moved to ~/.codex/AGENTS.md.bak-<timestamp>. Merge anything you
#   still need into dot-agents/.agents/AGENTS.md.
#
# Safe to run again: a skill that is already moved is a link, so it is skipped.
# A name that exists in both places is left alone and the migration skips, so
# it retries after you sort it out by hand.

up() {
    local claude_dir="$HOME/.claude/skills"
    local agents_dir="$HOME/.agents/skills"
    local conflicts=0 dir name

    mkdir -p "$agents_dir"

    # A folded stow link means every entry belongs to the dotfiles repo, so
    # there is nothing local to move.
    if [ -d "$claude_dir" ] && [ ! -L "$claude_dir" ]; then
        for dir in "$claude_dir"/*/; do
            dir="${dir%/}"
            name="$(basename "$dir")"

            [ -L "$dir" ] && continue
            [ -f "$dir/SKILL.md" ] || continue
            [ "$name" = "synced" ] && continue

            if [ -e "$agents_dir/$name" ] || [ -L "$agents_dir/$name" ]; then
                warning "Skill '$name' exists in both $claude_dir and $agents_dir; left as is. Merge them by hand."
                conflicts=$((conflicts + 1))
                continue
            fi

            mv "$dir" "$agents_dir/$name"
            ln -s "../../.agents/skills/$name" "$claude_dir/$name"
            info "Moved skill '$name' to $agents_dir and linked it back for Claude."
        done
    fi

    local codex_rules="$HOME/.codex/AGENTS.md"
    if [ -f "$codex_rules" ] && [ ! -L "$codex_rules" ]; then
        local backup
        backup="$codex_rules.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$codex_rules" "$backup"
        warning "Moved the old ~/.codex/AGENTS.md to $backup. Merge what you need into dot-agents/.agents/AGENTS.md."
    fi

    if [ "$conflicts" -gt 0 ]; then
        return "$SKIP_EXIT"
    fi
}
