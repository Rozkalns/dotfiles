---
name: rot-check
description: List my rotting work – idle or old MRs, branches with no open MR, idle in-progress tickets, and tickets where I am still in the Developer field but someone else owns them – each with one suggested action. Use when the user says "rot check", "what is rotting", "stale MRs", "what needs attention", "clean up my branches", "why is my cycle time high", "DevMetrics", or before merging an MR that is months old. The reflections standup calls it for its `_Rotting:_` footer.
---

# Rot check

Find work that is quietly going stale and say what to do with each item. Read-only: never close, delete, merge or edit anything without asking first.

## Why this exists

This check is for finding real neglect, not for gaming the metrics. See "Outcomes over output" under Values in `~/.agents/AGENTS.md`: never split, merge, close or time work just to move a number.

The team leads review per-developer metrics (open MRs, open and stale branches, WIP tickets, cycle time). There is no published rubric, so the thresholds below are working guesses. What we observed (not confirmed):

- **Cycle time** behaves like *first commit → merge*, averaged over the MRs merged in a month. One old MR merged late can turn a 4-day month into a 4-week month.
- **WIP tickets** seems to count tickets where the user is the assignee **or in the Developer field**.
- **Open MRs** counts every repo, not only the main one.

If the user learns the real rules, update this table.

## Thresholds

| Signal | Threshold | Suggested action |
|---|---|---|
| Open MR, no update | > 7 days: nudge. > 14 days: rotting | Ping reviewers, merge, or close |
| Draft MR | > 14 days | Undraft or close |
| Open MR whose first commit is old | > 30 days | Warn: merging it spikes that month's cycle time. Merge anyway if it is right, but know it |
| My remote branch with no open MR | last commit > 30 days | Delete (check for a closed MR first) |
| My ticket in an In Progress status, no update | > 14 days | Move forward, or On Hold with a reason |
| I am Developer, someone else is assignee, not Done | any | Ask to clear the Developer field |

## Gather (run in parallel)

Hosts and the Jira site come from env vars (`GITLAB_HOST`, `JIRA_SITE`) – never hard-code them.

**1. Open MRs, all repos:**

```bash
glab api "merge_requests?scope=created_by_me&state=opened&per_page=100" \
  | jq -r '.[] | [.references.full, (if .draft then "draft" else "-" end), .created_at[:10], .updated_at[:10], .project_id, .iid, .source_branch] | @tsv'
```

For each MR, the oldest commit (the API lists newest first, so take the last):

```bash
glab api "projects/<project_id>/merge_requests/<iid>/commits?per_page=100" | jq -r '.[-1].authored_date[:10]'
```

**2. My remote branches in the current repo** (skip if not in a git repo):

```bash
git fetch origin --prune -q
git for-each-ref --format='%(committerdate:short) %(refname:lstrip=3) %(authoremail)' refs/remotes/origin \
  | grep -F "<$(git config user.email)>" | sort
```

Drop branches that are the source of an open MR from step 1. For each one left that is older than 30 days, check for a closed or merged MR: `glab mr list --source-branch <branch> --all`.

**3. Jira** (Atlassian MCP, `cloudId` = `$JIRA_SITE`; read the value with `echo "$JIRA_SITE"`):

- Idle: `assignee = currentUser() AND statusCategory = "In Progress" AND updated <= -14d ORDER BY updated ASC`
- Developer leftovers: `Developer = currentUser() AND (assignee != currentUser() OR assignee is EMPTY) AND statusCategory != Done ORDER BY created ASC`
- On Hold, for info only: `assignee = currentUser() AND status = "On Hold"`

Fields: `summary, status, assignee, updated`.

## Output

Group items by action, worst first. One line per item: reference, age, action. Leave out the empty groups. End with one line of counts.

```
Rotting work – 2026-11-27

Merge or close (idle > 14 d)
- group/repo!101 docs: test schema design – idle 85 d
Spikes cycle time if merged
- group/repo!102 – first commit 2026-08-28 (91 d)
Delete branch (no open MR)
- feature-old-export – last commit 2026-06-09, no MR
Clear Developer field
- PROJ-123 (A. Person, In Progress) – created 2023-03
Idle tickets
- PROJ-456 In Progress – no update 91 d

6 open MRs · 3 stale branches · 4 idle tickets · 8 Developer leftovers
```

When called from the standup, return only the top 3 items as a single `_Rotting:_` footer line (they are not for the posted text), for example:
`_Rotting:_ !101 idle 85 d · !102 merge spikes cycle time · 8 tickets list me as Developer`

## After the list

Offer the cleanup the user can approve in one go: delete the listed dead branches, or remove the user from the Developer field on the listed tickets. Show the exact list first and act only on a yes. Ask before closing an MR or posting a comment.
