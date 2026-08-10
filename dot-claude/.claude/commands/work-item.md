---
description: Work one scoped item end to end under a fixed protocol — restate context, smallest plan, stop at the phase boundary
argument-hint: "[path to the item/spec, an issue number, or a one-line description]"
---

Work this item: **$ARGUMENTS**

If nothing was named, ask which one — do not pick.

## Before touching anything

1. **Read the item in full** — the spec file, issue, or brief — plus whatever it links to for ordering and context. If it is a file, read the whole file, not the first screen.
2. **Restate the working context in under 10 bullets**: the goal, what's in scope, what proves it's done, the constraints, and anything the item records as already decided. Nothing else — no repo tour, no summary of things you haven't been asked about.
3. **Name the deliverable in one sentence** — the PR title, the document produced, or the output expected.
4. **State the smallest viable plan for the first phase only.**

Then stop and wait for a reaction before making changes.

## Establish how this project verifies itself

Before writing anything, find out what "done" is checked by — don't assume a stack. Look, in order, at: the project's `CLAUDE.md` or `AGENTS.md`, then its manifest scripts (`composer.json`, `package.json`, `Makefile`, `justfile`, `pyproject.toml`, `Cargo.toml`), then its CI workflow. Use the project's own commands.

If it has no automated checks — a document, a contract, a config change — say so, and state instead how you will verify the work: the thing you will read back, diff, or run by hand.

## While working

- **Grep every caller before changing something's signature or behaviour.** Reading a file before editing it is already enforced; this is not. Include the call sites a language-only search misses — templates, string-based lookups, config keys, route or job names, generated code.
- Keep searches targeted. No broad sweeps to get oriented.
- **Treat the item's own claims as evidence, not fact.** Specs go stale and are often written without running anything. If one is disproved, say so, fix the item in the same change, and flag anywhere else that inherits the same claim.
- **Record progress in the item, not the conversation** — tick its checkboxes or update its status as you go, so the work survives the session ending.

## Stop conditions — any of these ends the turn

- **End of a phase.** Report and wait.
- **Two failed attempts** at the same fix. Report what you tried and what you learned; do not try a third approach.
- **The item is wrong** about something load-bearing.
- **The change outgrows the item's stated scope.** File the rest separately; don't absorb it.

## Before claiming it's done

- Run the project's checks and **quote the actual output**. Paraphrase is not evidence.
- State which checks you ran, which you skipped, and which claims are inferred rather than observed.
- Update the item's status line, and the tracker it belongs to if there is one.
- One item, one PR, following the repo's commit convention.
- If something you learned applies more widely than this item, say where it belongs — a sibling item, a standards doc, or a shared rules file.
