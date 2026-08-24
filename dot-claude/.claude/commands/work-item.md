---
description: Work one scoped item end to end under a fixed protocol — restate context, smallest plan, stop at the phase boundary
argument-hint: "[path to the item/spec, an issue number, or a one-line description]"
---

Work this item: **$ARGUMENTS**

If nothing was named, ask which one — do not pick.

## Before touching anything

1. **Read the item in full** — the spec file, issue, or brief — plus whatever it links to for ordering and context. If it is a file, read the whole file, not the first screen.
   If it sits in `docs/backlog/`, the `backlog` skill owns that format — its conventions,
   its status line, its wrap-up. Follow them rather than inventing a parallel set, and
   expect to hand back to it when the turn ends.

   **Check the size first, and take the second route only if it is genuinely large.**
   `wc -c` the file. Under ~40 KB — which is almost every item — read it whole and move
   on; the rest of this step does not apply. A long-running feature item can reach ten or
   twenty times that, and re-reading a quarter of a megabyte to change one phase is worth
   avoiding. Above the threshold:

   - **Get the skeleton, not a sample.** Headings, the checkbox lines, and per-section
     sizes:
     `grep -n '^#\{1,4\} \|^- \[[ x]\]' FILE` and
     `awk '/^## /{if(s)printf "%-50s %6d B\n",s,b; s=substr($0,4); b=0} {b+=length($0)+1} END{printf "%-50s %6d B\n",s,b}' FILE`
   - **Always read these in full, whatever you are working on:** the title and status
     line, and any "where the work lives" / "read this first" block. That is where a big
     item records which branch holds what, and what is blocked on a person.
   - **Then read, in full, only the sections your work touches.** In full is the point —
     a half-read section is worse than an unread one, because you inherit its first claim
     without the correction three paragraphs later.
   - **Hunt the corrections before trusting anything.** A big item talks back to itself
     across sections, and the stale claim is rarely next to the thing it describes.
     `grep -in 'corrected\|superseded\|disproved\|was wrong\|no longer\|stale\|believe the code' FILE`
     and read every hit that touches your scope, wherever it sits.
   - **Say what you skipped** in the restate step below — "read X, Y, Z; did not read the
     legal frame or the data model". A wrong scoping is then something the reader can
     correct in one line, instead of a silent gap you act on.

   Two failures this exists to prevent, both observed. A checkbox tally counted from a
   partial read is confidently wrong, and it looks precise — recount from the file every
   time rather than trusting the number in the status line, including your own from
   earlier in the session. And a shared checkout moves: on a long turn, re-check
   `git status -sb` and `git log --oneline -3` before reporting where anything stands,
   because another session may have committed, switched branch, or grown the item under
   you.
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
- **Record where the work lives, not just what is done.** Checkboxes say a phase is
  finished; they do not say it is sitting on an unmerged branch. A later session reading
  only the ticks will start from the default branch and rebuild it. Keep a short block
  near the top of the item naming the branch, the PR, what is merged, and anything
  blocked on a person rather than on code — and update it whenever that changes.

## Stop conditions — any of these ends the turn

- **End of a phase.** Report and wait.
- **Two failed attempts** at the same fix. Report what you tried and what you learned; do not try a third approach.
- **The item is wrong** about something load-bearing.
- **The change outgrows the item's stated scope.** File the rest separately; don't absorb it.

## Close every turn with the progress table

**If the item lives in `docs/backlog/`, reconcile it with the `backlog` skill first.**
That skill owns the format and has a wrap-up mode whose second step exists for exactly
this moment: reading the file back and ticking anything that got done but never checked
off. Run that reconciliation *before* the table, because the table counts checkboxes —
if they are stale, the summary is confidently wrong, and a number that looks precise is
worse than no number.

Which parts of its wrap-up apply depends on where you stopped:

- **Phase boundary or blocked** — reconcile the checkboxes and refresh the status line.
  Nothing else: the item is not done, so it does not move.
- **The whole item is finished** — the full wrap-up. Status to `Done`, a
  `## Completion Notes` section covering anything that diverged from the spec, and
  `git mv` into the project's done folder, matching whatever convention already exists
  rather than inventing one.


Whenever the turn ends — phase finished, blocked, or the whole item done — print where
the item actually stands. Not a paraphrase: counted from the item's own checkboxes.

The reason is drift. A green test run and a merged PR both *feel* like completion, and
after a long session it is easy for "this phase is done" to slide into "this is done".
The table makes the remaining work impossible to round down, and it separates three
things that are constantly confused: the branch is green, the phase is finished, the
feature is usable.

Count `- [x]` against `- [ ]` under each `###` heading in the item:

```bash
python3 - "docs/backlog/THE-ITEM.md" <<'PY'
import io, re, sys

lines = io.open(sys.argv[1], encoding='utf-8').read().split('\n')
section, counts, order = None, {}, []

for line in lines:
    heading = re.match(r'^#{2,3} (.+)', line)
    if heading:
        section = re.sub(r'\s*[—(].*', '', heading.group(1)).strip()[:44]
        if section not in counts:
            counts[section] = [0, 0]
            order.append(section)
    if section and line.startswith('- [x]'):
        counts[section][0] += 1
    if section and line.startswith('- [ ]'):
        counts[section][1] += 1

done = total = 0
for section in order:
    d, o = counts[section]
    if d + o:
        print(f"{section:<44} {d:>2}/{d + o:<3} {'#' * d}{'·' * o}")
        done, total = done + d, total + d + o

print(f"{'TOTAL':<44} {done:>2}/{total}")
PY
```

Use `#` and `·` for the bar. Do not use `█` — full-block glyphs tile seamlessly and a
run of them renders as one white rectangle rather than a countable bar.

Add a short status against each line where it helps — `merged`, `in #<pr>`, `blocked on
<who/what>` — and follow the table with three sentences, no more:

- **What works now**, in user terms, not commits.
- **What that still isn't** — name the nearest thing a user would wrongly assume is
  finished.
- **What the next real milestone is**, and what is blocking it, including anything
  waiting on a person rather than on code.

If the item has no checkboxes, say so and summarise in prose instead of inventing a
denominator. A made-up percentage is worse than no number.

## Before claiming it's done

- Run the project's checks and **quote the actual output**. Paraphrase is not evidence.
- State which checks you ran, which you skipped, and which claims are inferred rather than observed.
- Update the item's status line, and the tracker it belongs to if there is one.
- One item, one PR, following the repo's commit convention.
- If something you learned applies more widely than this item, say where it belongs — a sibling item, a standards doc, or a shared rules file.
