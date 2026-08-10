---
name: backlog
description: "Create, refine, and manage development-ready backlog items in docs/backlog/. Use this skill whenever the user mentions backlog items, work items, feature specs, wants to add something to the backlog, asks to refine or improve a backlog document, needs to move items to done, or wants an overview of current backlog status. Also trigger when the user says things like 'spec this out', 'add this to the backlog', 'write up a feature doc', 'what needs doing', 'mark X as done', 'let's plan this feature', or references docs/backlog/ files. Even if the user doesn't say 'backlog' explicitly but describes a feature they want documented for later development, this skill applies. Critically, also trigger when the user asks what's next in the pipeline, what to work on, or wants to review the backlog — these are overview requests. When the user signals wrap-up ('looks like this is a wrap', 'done with this', 'that's it for this one'), finalize the backlog item."
---

# Backlog Item Management

Write and manage development-ready work items in `docs/backlog/`. Every backlog item should be detailed enough that a developer (or AI agent) can pick it up and start building without needing to ask clarifying questions.

## Detect Mode

This skill has three modes. Determine which one applies based on the user's intent:

1. **Overview** — the user asks about backlog status, what's next, what to work on, shows the pipeline, or wants to review items. This is the default when the intent is ambiguous.
2. **Create / Refine** — the user wants to add a new item, spec something out, or edit/improve an existing backlog document.
3. **Wrap-up** — the user signals they're done with a backlog item ("looks like this is a wrap", "done with this", "that's it for this one", "wrap up").

---

## Mode 1: Overview

Present a scannable overview grouped by priority, with clickable file paths.

### Output format

The user works in a terminal or IDE where file paths are cmd+clickable — but only when the path appears as plain text on its own line. Markdown tables, backtick-wrapped paths, and inline paths all break this. Use a bullet list grouped under priority headings, with the file path on its own line:

### High Priority

- **Student CRUD** — Not started
  docs/backlog/student-crud.md
- **Observation Edit & Delete** — Not started
  docs/backlog/observation-edit-delete.md

### Medium Priority

- **Kanban Board** — Not started
  docs/backlog/kanban-board.md

### Low Priority

- **Mago PHP Toolchain** — Not started
  docs/backlog/mago-php-toolchain.md

Each item: bold title, em-dash, status. Next line: file path as plain text (no backticks, no bold, not inside a table). No descriptions or summaries — just title, status, and path. This format is intentional; do not substitute a table.

### How to gather the data

1. List files in `docs/backlog/` (exclude subdirectories like `done/`).
2. For each file, read line 1 (the `# Title`) and line 2 (the `Priority: X | Status: Y` metadata line). If line 2 doesn't start with "Priority:", default to Medium priority, Not started.
3. Group items under `### High Priority`, `### Medium Priority`, `### Low Priority` headings. Omit any group that has no items.

### After showing the overview

Use `AskUserQuestion` to ask which item the user wants to work on and whether they want to **implement** it or **refine/edit** the spec.

- **Implement** → Read the backlog item fully, then invoke the `/feature-dev` skill. When passing context to feature-dev, include:
  1. The full backlog item content (so the developer understands what to build)
  2. **Explicit instruction to update checkboxes in the backlog file as each phase completes.** The instruction should say: "The backlog spec at `docs/backlog/<filename>.md` has implementation phases with checkboxes. As you complete each phase, update the corresponding `- [ ]` to `- [x]` in the backlog file. Do this after each phase, not in a batch at the end — the checkboxes are the source of truth for progress tracking."
  3. The backlog file path so feature-dev knows where to write updates
- **Refine / Edit** → Switch to the refine workflow (Mode 2 below). Interview the user about what needs to change.

---

## Mode 2: Create / Refine

### Discover Project Context

Every project is different. Before writing or refining any backlog item, orient yourself:

1. **Read CLAUDE.md** — understand the project's domain, terminology, tech stack, conventions, and stakeholders.
2. **Scan existing backlog items** — `ls docs/backlog/` to see what exists, then read 2-3 items to absorb the project's backlog conventions (section ordering, tone, level of detail). If no items exist yet, use the template in `references/template.md`.
3. **Check the database** — if the project has a database, use `database-schema` (or read migrations) to understand current table structures. Don't guess at column names.
4. **Search docs** — if the feature involves framework patterns, use `search-docs` or read relevant documentation.
5. **Read affected code** — if the feature touches existing code, read the relevant files to understand current implementation.

Adapt your writing to the project's domain. Use the project's own terminology, reference its real roles and workflows, and ground examples in realistic scenarios.

### Creating a New Item

**Filename:** Date-prefixed kebab-case, descriptive and scoped: `YYYY-MM-DD-feature-name.md` (e.g., `2026-05-22-survey-export.md` not `edit.md`). Save to `docs/backlog/`.

**Template:** Read `references/template.md` for the full template. The key sections are:

1. **Title + metadata** — `# Title` on line 1, `Priority: X | Status: Y` on line 2 (plain text, not a heading)
2. **Background** — the problem, grounded in project context and real scenarios
3. **Scope** — in scope (verifiable deliverables) + out of scope (explicit deferrals)
4. **User Story** — optional but encouraged, from a specific role's perspective
5. **Data Model** — concrete tables, enums, relationships (when applicable)
6. **Implementation** — phased with checkboxes, each phase independently deployable
7. **Files Affected** — specific paths to estimate effort and spot conflicts
8. **Technical Considerations** — edge cases, security, compliance
9. **Open Questions** — decisions needed, with options and trade-offs listed
10. **Dependencies** — only when they exist; omit the section entirely if none
11. **Related** — cross-references to other backlog items

Not every section is needed for every item — use judgment, but err toward more rather than less.

### Matching Existing Conventions

If the project already has backlog items, match their style. Consistency across the backlog matters more than strictly following the template.

### Refining an Existing Item

When asked to improve a backlog item:

1. Read the item thoroughly
2. Identify gaps against the template — which sections are missing or thin?
3. Check common weaknesses:
   - **No background** — add the "why"
   - **Vague scope** — replace "improve X" with concrete deliverables
   - **Missing data model** — check database schema and propose concrete tables/columns
   - **No implementation phases** — break it down into deployable steps
   - **No open questions** — surface unresolved decisions
   - **No files affected** — trace through the codebase to identify impacted files
   - **Missing out-of-scope** — add boundaries to prevent scope creep
4. Present the gaps to the user before making changes — they may have context you don't

---

## Mode 3: Wrap-up

When the user signals they're done working on a backlog item:

1. **Identify which item** — look at the conversation context to determine which backlog item was being worked on. If unclear, ask.
2. **Reconcile checkboxes** — read the backlog file and check if all implementation phase checkboxes reflect reality. If any `- [ ]` items were completed but not checked off, update them to `- [x]` now. If any phases were skipped or deferred, leave them unchecked and note them in completion notes. This step catches drift between the code and the spec — it's the safety net for when checkboxes weren't updated during implementation.
3. **Update the status** — change the metadata line to `Priority: X | Status: Done`
4. **Add a completion note** — if the implementation diverged from the spec or there are follow-up items worth noting, add a brief `## Completion Notes` section at the bottom.
5. **Move to done** — check if the project has an existing done folder (e.g., `done/`, `00_done/`). Match whatever exists. Default to `done/` for new projects.
   ```bash
   git mv docs/backlog/feature-name.md docs/backlog/done/feature-name.md
   ```
5. **Suggest next steps** — offer to show the backlog overview so the user can pick up the next item.
