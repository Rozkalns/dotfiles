---
name: manual-qa
description: "Set up manual QA for a finished change and write the test steps, in a Laravel app served by Herd (with its own `composer qa:up`, or this skill's `scripts/qa-up.sh`). Use as soon as an implementation is done — before the user asks — and whenever they say 'QA', 'let me test it', 'test steps', 'how do I check this', or report a QA finding. Covers `composer qa:up`/`qa:down` and the shell fallback, the demo seed, and where the steps go: a GitHub QA issue or a `QA.md` file. Not for the automated browser suite (`composer test:browser`)."
---

# Manual QA

The goal: when the user comes back, the URL, the PIN and the test steps are ready. They may be away
for hours, so a setup that waits for them wastes that time.

## Project settings

Read the settings before anything else. They hold what differs per project. Read the file as data;
do not `source` it. Use the first of these that exists:

1. `.claude/manual-qa.env` in the current checkout.
2. `.claude/manual-qa.env` in the main checkout. It is git-ignored, so a new worktree does not have
   it. Find the main checkout with `git rev-parse --path-format=absolute --git-common-dir`, then go
   up one level.
3. `.claude/manual-qa.env.example`, the committed template.

Then read `~/.claude/manual-qa.env` if it exists: personal settings for every repo (for example
`QA_FILE_DIR`). It fills only settings that the project file leaves out or blank.

| Setting | Meaning |
| --- | --- |
| `QA_TARGET` | `issue` for a GitHub QA issue, `file` for a QA file (see `QA_FILE_DIR`) |
| `QA_FILE_DIR` | Only for `file`: the folder for the QA file, for example a notes vault. `~` is allowed. Blank: `QA.md` in the worktree root |
| `QA_PROJECT_OWNER`, `QA_PROJECT_NUMBER` | The GitHub project board for the QA issue. Blank: a plain issue, no board |
| `QA_PROJECT_STATUS` | The board status that means "waiting for the tester" |
| `QA_LOGIN` | How the first step logs in |
| `QA_SWITCH_PERSON`, `QA_PERSON_GROUPS` | How later steps change person, and the groups in that menu |
| `QA_PEOPLE_SOURCE` | Where people, roles and other demo data come from |
| `QA_LABELS_SOURCE` | Where menu labels and button texts come from |
| `QA_SEED`, `QA_PIN`, `QA_URL_PATH`, `QA_ENV_VARS`, `QA_SITE_PREFIX` | Only for `scripts/qa-up.sh` (Setup, below). The comment at the top of the script explains each |

If no file exists: `QA_TARGET` is `issue` when `~/code/server/projects.yaml` lists the repo (these
apps are in active development), otherwise `file`. Read the other values from the code. If the
setting you need stays unclear, ask.

## When

- **Do not wait for the user.** Start as soon as the implementation is done. Write the steps while
  `/simplify` and the gate run (for example in a background agent).
- **Run `composer qa:up` after the gate, not during it.** Its `npm run build` empties
  `public/build/` while it builds, so a test that renders `@vite` at that moment fails with a
  missing Vite manifest, and it looks like a flaky test.
- If `/simplify`, the gate or a fix changes code after the steps exist: run `composer qa:up`
  (or `scripts/qa-up.sh`) again (it rebuilds everything) and update the steps the change touches.
- **A running `npm run dev` in the worktree breaks the gate the same way.** It writes `public/hot`,
  so `Vite::manifestHash()` is null and asset-version tests fail. Do not stop the user's dev server:
  move `public/hot` aside, rerun those tests, and put it back.

## Setup

1. In the worktree, run `composer qa:up`. It needs `vendor/` (run `composer install` first in a
   fresh worktree). It runs only with `APP_ENV=local`, with Herd installed, and in a git worktree,
   never in the main checkout.
   - **No `composer qa:up` in the app?** Run this skill's `scripts/qa-up.sh` from the worktree root
     instead. It does the same: the same refusals, `herd link --secure`, undoing what Boost writes
     while linking, a fresh `database/qa.sqlite`, the asset build, `migrate`, then the app's
     `QA_SEED` (and `QA_PIN`, if set). It needs a demo seeder for `QA_SEED`. If the app has none,
     write one in the same PR (it is demo data, see below) before running the script.
   - Do not improvise any other site or copy a database.
2. Put its URL and PIN at the top of the steps (below) and give the user the link or the path.
   Nothing else about the setup.

Do not talk about databases. QA always runs on the demo seed; a copy of production data spreads
real personal data, and the question is settled.

If a check needs data that the demo does not have, add it to the demo seeders in the same PR and
run `composer test:demo` (or, without that script, a test that runs the seeder). Hand-made data is lost on the next `qa:up`, and the user should test, not
prepare.

If a check needs queued jobs, start `php artisan queue:listen --tries=1` in the background.

After the merge, local cleanup runs `composer qa:down` (or `scripts/qa-down.sh`) before the worktree is
removed.

## Where the steps go

Never in the chat: steps there get lost in a long conversation. In the chat, give only the issue
link or the file path and one line about what changed. No Artifact pages (they pile up) and no PR
comments.

### `QA_TARGET=issue`

Create a GitHub issue titled `QA <n> · <feature> (#<PR>)`, where `<n>` is the next number after the
highest existing QA issue. Leave out the PR number until the PR exists.

If `QA_PROJECT_NUMBER` is set, add the issue to that board with `QA_PROJECT_STATUS`, placed in merge
order. Board automation may set a new item to another status: set the status again after
`gh project item-add`, then check. Order the items with the GraphQL `updateProjectV2ItemPosition`
(`afterId`).

The issue body holds, in this order: merge prerequisites, the worktree path, how to renew the PIN
(`composer qa:up`), the URL and the PIN with its expiry, the design references to compare with (if
the project has them), then the steps as `- [ ]` checkboxes. Once the PR exists, put
`Closes #<issue>` in its body, so the issue links to it and closes on merge. When `qa:up` issues a
new PIN or the steps change, update the issue body.

**Edit the live body, never overwrite it.** Fetch it (`gh issue view <n> --json body -q .body`),
change only the lines meant to change, and write that back. Pushing a stale copy wipes the steps
the user has already ticked.

**A PR stack gets one QA issue**, `QA <n> · <feature> (#A, #B)`, tested on the top branch's `qa:up`
site. Mark which steps belong to which PR, so the base PR can merge first.

### `QA_TARGET=file`

Where the file goes:

- `QA_FILE_DIR` blank: `QA.md` in the worktree root. Check that the repo git-ignores it.
- `QA_FILE_DIR` set: `<QA_FILE_DIR>/<YYYY-MM-DD> <name>.md`, where the date is the day the first
  QA round starts and `<name>` is the ticket key, else `<app>-<change>` (for example
  `2026-11-23 kartites-editor-heading-toggles.md`). The date puts the folder in test order, oldest
  first. Create the folder if it is missing. The file is outside the repo, so it needs no
  git-ignore. Give the user the full path.
- **If the folder is in an Obsidian vault, also give an Obsidian link.** The folder is in a vault
  when it, or a folder above it, has a `.obsidian/` folder. Resolve symlinks first (`readlink -f`),
  because `~/vault` can be a link. The vault name is that folder's own name. The file is its path
  inside the vault, without `.md`, URL-encoded (`/` → `%2F`, space → `%20`). Write it as a markdown
  link, never as a bare URL: Ghostty and similar terminals do not make a bare `obsidian://` URL
  clickable, but a markdown link becomes a real hyperlink. Example:
  `[Open the QA file in Obsidian](obsidian://open?vault=PersonalVault&file=QA%2F2026-11-23%20kartites-editor-heading-toggles)`.
- Before creating one, look for `* <name>.md` in the folder (and the old undated `<name>.md`). If
  it exists, it is an earlier round of the same change: update it, keep its date, do not overwrite
  it.
- After the merge, delete the file as part of the local cleanup, so the folder lists only what is
  still to test.

Start with
`# QA — <branch>`, then the `URL:` and `PIN:` lines from the `qa:up` output, then the steps as
`- [ ]` checkboxes, which the user ticks in their editor. When `qa:up` issues a new PIN, change only
those two lines.

## Writing the steps

Two sections:

- **Scripted steps** — real demo names: who logs in, what to open, what to click, what to choose.
- **Exploratory checks** — 3–5 "try to break it" ideas: empty input, a very long name, a second
  tab, the wrong role, going back mid-flow.

Only step 1 logs in, as `QA_LOGIN` describes. If a login needs a one-time (TOTP) code, give a
copy-paste command that prints the current code from the worktree's config, for example
`php artisan tinker --execute 'echo (new PragmaRX\Google2FA\Google2FA)->getCurrentOtp(config("app.some_totp_secret")), PHP_EOL;'`.
Do not ask the tester to add a secret to an authenticator app. Every later change of person follows
`QA_SWITCH_PERSON`. Take people and roles from `QA_PEOPLE_SOURCE`, and labels from
`QA_LABELS_SOURCE`. Read them; do not write names from memory.

Write in simplified technical English (ASD-STE100 principles): one action per step, short
sentences, the expected result after "→". Less text, not more: a long step is harder to test.

- **Number a step as `- [ ] **1.** …`.** `- [ ] 1. …` makes every item a nested list (PhpStorm
  shows i, ii, iii), and `1. [ ] …` hides the numbers in PhpStorm.
- **Every step goes through the UI.** No hand-built URLs or IDs copied from the address bar. If the
  UI has no way to a page the check needs, that is a finding: report it, do not script around it.
- **State the demo fact a result depends on.** When the expected result depends on what the seed
  already holds, say it before the "→": "(In the demo, this group already has one member.)". A
  fictional roster is hard to follow.
- **Say when a refusal is the expected result.** A step that sends a role somewhere it may not go
  ends with "→ 403" (or the message it shows), so a refusal is not reported as a bug.
- **No bare `<placeholder>` in the steps.** Obsidian and other markdown renderers read
  `<date and time>` as an HTML tag, and every step after it shows as raw text. Put a placeholder in
  backticks (`` `konstrukts-<today>.xlsx` ``) or write it in words ("the date and time"). The
  `<…>` in the template below are for you to replace, never to copy.

```markdown
## Scripted steps

- [ ] **1.** Log in as <demo person> (<role>).
- [ ] **2.** Open <menu> → <button>.
- [ ] **3.** Set the date to 6 November. → "Until" shows 06.11. 00:00.

## Exploratory checks

- [ ] Save with "From" later than "Until".
```

## After a fix round

Update the steps in place. Add a short list at the top, under the PIN:

```markdown
## Changed — re-check

- Step 4: the time line now rounds to 5 minutes.
```

Untick the steps it lists. Remove the list when the user confirms them.
