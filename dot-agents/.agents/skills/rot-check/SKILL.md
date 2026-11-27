---
name: rot-check
description: List my rotting work – idle or old MRs/PRs, branches with no open MR/PR, idle tickets and issues, stale backlog items and OpenSpec changes – each with one suggested action. Works with GitLab, GitHub, Jira, docs/backlog and OpenSpec, using whichever are available on this machine. Use when the user says "rot check", "what is rotting", "stale MRs", "stale PRs", "what needs attention", "clean up my branches", "why is my cycle time high", "DevMetrics", or before merging an MR/PR that is months old. `/rot-check all` gives an overview of every repo under ~/code. The reflections standup calls it for its `_Rotting:_` footer.
---

# Rot check

Find work that is quietly going stale and say what to do with each item. Read-only: never close, delete, merge or edit anything without asking first.

## Why this exists

This check is for finding real neglect, not for gaming the metrics. See "Outcomes over output" and "Small and often" under Values in `~/.agents/AGENTS.md`: never split, merge, close or time work just to move a number.

At work, the team leads review per-developer metrics (open MRs, open and stale branches, WIP tickets, cycle time). There is no published rubric, so the thresholds below are working guesses. What we observed (not confirmed):

- **Cycle time** behaves like *first commit → merge*, averaged over the MRs merged in a month. One old MR merged late can turn a 4-day month into a 4-week month.
- **WIP tickets** seems to count tickets where the user is the assignee **or in the Developer field**.
- **Open MRs** counts every repo, not only the main one.

If the user learns the real rules, update the thresholds.

## Scope

| Mode | Forge MRs/PRs, issues, Jira, branches | Backlog and OpenSpec |
|---|---|---|
| `/rot-check` inside a git repo | global | current repo only |
| `/rot-check all`, outside a repo, or from the standup | global | current repo + every repo under `~/code/*` + registered OpenSpec stores |

## Sources – use what is available

Check each source first and skip it quietly if it is not there. Say which ones ran in the last line of the output.

| Source | Available when |
|---|---|
| GitLab | `glab auth status` succeeds |
| GitHub | `gh auth status` succeeds |
| Jira | `JIRA_SITE` is set and the Atlassian MCP is connected |
| Backlog | a repo in scope has `docs/backlog/` |
| OpenSpec | `openspec` is installed and a repo in scope has `openspec/`, or `openspec store list --json` lists a store |

Hosts and the Jira site come from env vars (`GITLAB_HOST`, `JIRA_SITE`) – never hard-code them.

## Thresholds

| Signal | Threshold | Suggested action |
|---|---|---|
| Open MR/PR, no update | > 7 d: nudge. > 14 d: rotting | Ping reviewers, merge, or close |
| Draft MR/PR | > 14 d | Undraft or close |
| Open MR/PR whose first commit is old | > 30 d | Warn: merging it spikes that month's cycle time. Merge anyway if it is right, but know it |
| My branch with no open MR/PR | last commit > 30 d | Delete (check for a closed MR/PR first) |
| Jira: mine, In Progress status, no update | > 14 d | Move forward, or On Hold with a reason |
| Jira: I am Developer, someone else is assignee, not Done | any | Ask to clear the Developer field |
| GitHub issue assigned to me, no update | > 30 d | Close, or comment with the next step |
| Backlog item `Status: In progress`, no commit to the file | > 14 d | Finish it or set it back to Not started |
| Backlog item `Not started` | file older than 90 d | Still wanted? Drop or reprioritise |
| Backlog item with all boxes ticked, not in `done/` | any | Finalise: Status Done, move to `done/` |
| OpenSpec active change, no commit under its folder | > 14 d | Apply, or drop it |
| OpenSpec change with all `tasks.md` boxes ticked, not archived | any | Archive (`/opsx:archive`) |

## Gather (run the sources in parallel)

### GitLab

Open MRs, all projects:

```bash
glab api "merge_requests?scope=created_by_me&state=opened&per_page=100" \
  | jq -r '.[] | [.references.full, (if .draft then "draft" else "-" end), .created_at[:10], .updated_at[:10], .project_id, .iid, .source_branch] | @tsv'
```

Oldest commit of an MR (newest is listed first, so take the last): `glab api "projects/<project_id>/merge_requests/<iid>/commits?per_page=100" | jq -r '.[-1].authored_date[:10]'`

Branches – every project I pushed to in the last 6 months:

```bash
# latest push per project + branch
glab api "users/$(glab api user | jq .id)/events?action=pushed&after=$(date -v-6m +%F)&per_page=100" --paginate \
  | jq -rs 'add | map(select(.push_data.ref_type == "branch")) | group_by([.project_id, .push_data.ref])
            | map(max_by(.created_at)) | .[] | [.project_id, .push_data.ref, .created_at[:10]] | @tsv'
# my MRs of the same period, any state
glab api "merge_requests?scope=created_by_me&state=all&updated_after=$(date -v-7m +%F)&per_page=100" --paginate \
  | jq -rs 'add | .[] | [.project_id, .source_branch, .state] | @tsv'
```

Join the two on project + branch. Keep pushes older than 30 days, skip `main`/`master`, and drop branches whose MR is `merged` (usually deleted on merge) or `opened` (already covered above). Only the rest – no MR, or a closed MR – need a call each to check the branch still exists: `glab api "projects/<id>/repository/branches/<url-encoded ref>"` (404 = already gone, drop it). Measured 2026-11-27: 143 old pushes → 20 calls.

### GitHub

```bash
gh search prs --author=@me --state=open --limit 100 \
  --json repository,number,title,isDraft,createdAt,updatedAt \
  --jq '.[] | [.repository.nameWithOwner, .number, .isDraft, .createdAt[:10], .updatedAt[:10], .title] | @tsv'
gh search issues --assignee=@me --state=open --limit 100 \
  --json repository,number,title,updatedAt \
  --jq '.[] | [.repository.nameWithOwner, .number, .updatedAt[:10], .title] | @tsv'
```

Oldest commit of a PR: `gh pr view <n> -R <owner/repo> --json commits --jq '.commits[0].authoredDate[:10]'`

Branches – repos I pushed to (GitHub keeps only about 90 days of events):

```bash
gh api "users/$(gh api user --jq .login)/events?per_page=100" --paginate \
  --jq '.[] | select(.type == "PushEvent") | [.repo.name, (.payload.ref | sub("refs/heads/"; "")), .created_at[:10]] | @tsv' \
  | sort -u -k1,2
```

For each repo in that list, list branches with their last commit and keep only those where the last commit author is me (this drops bot branches such as `dependabot/*`):

```bash
gh api "repos/<owner/repo>/branches?per_page=100" --paginate --jq '.[].name' \
  | while read -r b; do gh api "repos/<owner/repo>/commits/$b" --jq "[\"$b\", .commit.author.date[:10], .author.login] | @tsv"; done
```

Skip the default branch and branches that are the head of an open PR.

### Current repo (fallback for branches)

If no forge CLI is logged in, read the current repo's remote branches:

```bash
git fetch origin --prune -q
git for-each-ref --format='%(committerdate:short) %(refname:lstrip=3) %(authoremail)' refs/remotes/origin \
  | grep -F "<$(git config user.email)>" | sort
```

### Jira

Atlassian MCP, `cloudId` = `$JIRA_SITE` (read it with `echo "$JIRA_SITE"`). Fields: `summary, status, assignee, updated`.

- Idle: `assignee = currentUser() AND statusCategory = "In Progress" AND updated <= -14d ORDER BY updated ASC`
- Developer leftovers: `Developer = currentUser() AND (assignee != currentUser() OR assignee is EMPTY) AND statusCategory != Done ORDER BY created ASC`
- On Hold, for info only: `assignee = currentUser() AND status = "On Hold"`

### Repos in scope (for backlog and OpenSpec)

```bash
{ git rev-parse --show-toplevel 2>/dev/null
  for d in "$HOME"/code/*/; do [ -d "$d/docs/backlog" ] || [ -d "$d/openspec" ] && echo "${d%/}"; done
} | sort -u
```

(The `~/code/*` loop only in `all` mode.)

### Backlog

For each `docs/backlog/*.md` (not subfolders such as `done/`): line 1 is `# Title`, line 2 is `Priority: X | Status: Y` (missing → Not started). Count `- [ ]` and `- [x]`. Age = last commit to the file: `git -C <repo> log -1 --format=%cs -- <file>` (uncommitted → file mtime).

### OpenSpec

Per repo: `openspec list --json` (run in the repo); per store: `openspec list --json --store <id>`. A `"root": null` answer means no OpenSpec there – skip it. For each active change, count the boxes in `openspec/changes/<name>/tasks.md` and take the age from `git -C <repo> log -1 --format=%cs -- openspec/changes/<name>`.

## Output

Group items by action, worst first. One line per item: where, what, age. Leave out empty groups. In `all` mode, put the repo name in front of backlog and OpenSpec items. End with one line of counts and the sources that ran.

```
Rotting work – 2026-11-27

Merge or close (idle > 14 d)
- group/repo!101 docs: test schema design – idle 85 d
- owner/app#42 fix: export timeout – idle 21 d
Spikes cycle time if merged
- group/repo!102 – first commit 2026-08-28 (91 d)
Delete branch (no open MR/PR)
- group/repo feature-old-export – last commit 2026-06-09, no MR
Clear Developer field
- PROJ-123 (A. Person, In Progress) – created 2023-03
Idle tickets and issues
- PROJ-456 In Progress – no update 91 d
Backlog and OpenSpec
- app: backlog "CSV import" In progress 3/7 – untouched 40 d
- app: openspec add-dark-mode 9/9 tasks – archive it

6 open MRs/PRs · 3 stale branches · 4 idle tickets · 2 backlog/spec items
Sources: GitLab, GitHub, Jira, backlog (3 repos), OpenSpec (1 repo)
```

When called from the standup, return only the top 3 items as a single `_Rotting:_` footer line (they are not for the posted text), for example:
`_Rotting:_ !101 idle 85 d · !102 merge spikes cycle time · 8 tickets list me as Developer`

## After the list

Offer the cleanup the user can approve in one go: delete the listed dead branches, remove the user from the Developer field on the listed tickets, or archive OpenSpec changes whose tasks are all done. Show the exact list first and act only on a yes. Ask before closing an MR, PR or issue, or posting a comment.
