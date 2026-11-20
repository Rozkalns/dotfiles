# Backlog Item Template

Not every section is required for every item — a small UI tweak doesn't need a data model section, and a database migration doesn't need a user story. Use judgment, but err toward including more rather than less.

```markdown
# Feature Title
Priority: High | Status: Not started

## Background

[2-3 paragraphs explaining the problem. Start with the pain point — what's
broken, missing, or frustrating? Then explain why it matters in the project's
context. Include a concrete scenario with realistic details.

Ground it in the domain: use the project's own terminology, reference real
user roles, and describe actual workflows. Generic specs produce generic
implementations — specificity is what makes a backlog item actionable.]

## Scope

### In scope
- [Specific, concrete deliverables — things you can demo or test]
- [Each bullet should be verifiable: "done" or "not done"]

### Out of scope (for now)
- [Explicit deferrals — things someone might expect but that aren't included]
- [This prevents scope creep and sets expectations]

## User Story

> As a [specific role], I want to [concrete action]
> so that [measurable benefit].

## Data Model

[Only when the feature changes the database. Be concrete:]

### New Table: `table_name`
| Column | Type | Notes |
|--------|------|-------|
| id | bigint | auto-increment |
| foreign_id | bigint | → related_table.id |
| ... | | |

### New Enum: `App\Enums\EnumName` (or project-appropriate location)
- `CaseName` — description

### Relationship Changes
- `ModelA` hasMany `ModelB`
- `ModelB` belongsTo `ModelC`

## Implementation

### Phase 1 — [name, e.g., "Data model + migration"]
- [ ] Concrete step
- [ ] Another step

### Phase 2 — [name] (if needed)
- [ ] Steps for phase 2

[Break complex features into phases. Each phase should be independently
deployable and testable. Phase 1 is the minimum viable version.]

## Files Affected

- `path/to/model.ext` — add relationship method
- `path/to/migration.ext` — new migration
- `path/to/view.ext` — add UI section

[List specific files. This helps estimate effort and spot conflicts with
other in-progress work.]

## Technical Considerations

[Edge cases, performance implications, security concerns, compliance
requirements (GDPR, etc.), browser compatibility. Focus on things that
might bite during implementation.]

## Open Questions

1. [Specific decision needed — list known options if possible]
   - Option A: [description + trade-off]
   - Option B: [description + trade-off]
   - Decision owner: [who needs to weigh in]

[Open questions are decision points for stakeholders. Include options
with trade-offs so the conversation is productive, not open-ended.]

## Dependencies

- `other-item.md` — [why this is needed first]
- [Only include this section when dependencies exist. Omit entirely if none.]

## Related

- `other-item.md` — [how they relate: shares UI with, overlaps scope, etc.]
```

## Metadata Format

The metadata line goes directly after the `# Title` heading — no blank line between them. It is plain text, not a heading:

```markdown
# Observation Tombstones
Priority: Medium | Status: Not started
```

**Priority values:** High, Medium, Low
**Status values:** Not started, In progress, Done

Do not use `##` headers for priority, status, or dependencies. Priority and status are compact inline metadata. Dependencies get their own section only when they exist — if there are no dependencies, omit the section entirely.

## What Makes a Great Backlog Item

The difference between a useful spec and a vague wish:

**Vague:** "Add data import functionality"

**Development-ready:** Specifies the file format (CSV/XLSX), required columns, duplicate detection strategy, error handling (skip row vs. abort), who can access it, and how it interacts with existing records.

## Key Qualities

- **Problem before solution** — the reader understands WHY before HOW
- **Concrete examples** — real names, actual data, specific role workflows from the project's domain
- **Boundaries drawn** — what's in, what's out, what's deferred
- **Trade-offs surfaced** — when there are multiple approaches, list them with pros/cons
- **Dependencies mapped** — which other backlog items block or are blocked by this one
- **Phases defined** — complex items broken into deployable increments
- **Grounded in context** — uses the project's terminology, not generic language
