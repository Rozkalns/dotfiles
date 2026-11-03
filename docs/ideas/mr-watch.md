# mr-watch – spoken MR and PR updates

## Why

While waiting for reviews, I keep opening GitLab to check whether my merge requests got approved. A temporary `say` loop in a Claude session showed that hearing "New approval on 101. 4 of 5 approved." is both useful and fun. But it lived only as long as the Claude session was open, and it watched a hard-coded list of MRs.

At work I use GitLab. On my own projects I use GitHub. The watcher must work with both.

## What

A standalone watcher that polls GitLab with `glab` and GitHub with `gh`, and speaks short updates with plain `say` (uses the macOS System voice – a Siri voice sounds natural; `say -v` cannot name Siri voices).

"MR" below means a GitLab merge request or a GitHub pull request.

### Events

| Event | Example |
|---|---|
| New approval | "New approval on 101 from Anna. 4 of 5 approved." |
| Several approvals in one tick | "Alex and Kristaps approved 101." |
| Ready to merge | "102 is ready to merge." |
| Merged | "101 is merged. Next in the chain is 102." |
| Failed pipeline | "Pipeline failed on 103." |
| New comment from someone else | "Ben commented on 104." |
| Review request for me (I'm a reviewer, not approved yet) | "Anna asked you to review 105. Worth a look." |
| After silent time or mute | One catch-up sentence: "While you were away: 2 approvals, 1 comment." |

On GitHub there is no "N of M approved" count, so it says "2 approvals" instead.

### What it watches

- My own open, non-draft MRs, found through the API (`author = me`), across all repos, on each forge where the CLI is logged in.
- MRs where I'm a reviewer and haven't approved yet.
- Extra MRs added by hand (anyone's).
- Chains: a merge order I define by hand (see below).

### Chains

A chain is my own merge order, as in a Slack message like "Merge order: !7360 → !7327 → !7380 → !7393. !7406 can merge on its own." It is not a merge train, and it is not stacked branches. All MRs can target the same branch. The order exists only because I say so, so the tool cannot find it from the API.

- `mr-watch chain <ref> <ref> …` stores the order. The MRs in it are watched like extra MRs.
- When an MR in a chain is merged: "7360 is merged. Next in the chain is 7327."
- When the next MR is also ready to merge, it says so in the same sentence: "7360 is merged. 7327 is next and ready to merge."
- When the last one is merged: "7393 is merged. The chain is done." The chain is then removed.
- An MR outside every chain (like !7406) never gets a "next" part.

### References

The separator tells which forge an MR is on, so one list can hold both:

- GitLab: `group/project!123`
- GitHub: `owner/repo#123`
- A bare `!123` or `#123` uses the repo of the current directory (resolved once, when added).

## How

One CLI; the Claude skill and the terminal call the same commands:

```
mr-watch on | off            # launchctl enable+bootstrap / bootout+disable (off survives reboot)
mr-watch quiet [60m|2h|off]  # mute on top of the speaking hours
mr-watch status              # speak + print what's up now
mr-watch add <ref>…
mr-watch remove <ref>…
mr-watch chain <ref> <ref> … # set a merge order
mr-watch chain clear [<ref>] # remove one chain (the one holding <ref>) or all
mr-watch voice [test]        # how to change the voice; test speaks a sample
mr-watch tick [--now]        # one poll – what launchd runs; --now skips the on/off and interval checks
```

- **Config:** `~/.config/mr-watch/config.json`, written only by the CLI. JSON, because `jq` is installed and `yq` isn't.

  ```json
  {
    "enabled": true,
    "muted_until": null,
    "speak_hours": {"days": "1-5", "from": "08:00", "to": "19:00"},
    "interval_minutes": 3,
    "forges": ["gitlab", "github"],
    "gitlab_host": "gitlab.example.com",
    "watch": {
      "own_open_mrs": true,
      "review_requests": true,
      "mrs": [],
      "chains": [["acme/app!7360", "acme/app!7327", "acme/app!7380", "acme/app!7393"]],
      "ignore": []
    }
  }
  ```

  `speak_hours` are the hours it **may speak**. Outside them it stays silent and keeps recording.
  `ignore` holds MRs removed with `remove`, so the API search does not bring them back.
- **Forges:** one small adapter per forge with the same output shape (state, approvers, approvals left or null, ready, pipeline, notes). The rest of the script doesn't know which forge an MR came from.

  | | GitLab (`glab api`) | GitHub (`gh`) |
  |---|---|---|
  | My MRs | `merge_requests?author_username=me&state=opened&scope=all` | `gh search prs --author=@me --state=open`, drafts dropped with `jq` |
  | Review requests | `merge_requests?reviewer_username=me&state=opened` | `gh search prs --review-requested=@me --state=open` |
  | Approvals | `…/approvals` (`approved_by`, `approvals_left`) | reviews with state `APPROVED`, latest per user |
  | Ready to merge | `detailed_merge_status == "mergeable"` | `mergeStateStatus == "CLEAN"` |
  | Pipeline | `head_pipeline.status` | `statusCheckRollup` |
  | Comments | notes with `system: false` | issue comments + review comments |

  A forge is skipped when its CLI isn't logged in. Each CLI reads its own token, so the script has no hosts, names or tokens. The one exception: launchd doesn't pass on the shell's `GITLAB_HOST`, so `gitlab_host` is copied from it into the config when the config is created, and `tick` exports it again.
- **State:** `~/.local/state/mr-watch/state.json` (last seen approvals, pipelines, note ids, queued events, last poll time). It is kept apart from the config, so a config change never replays old events.
- **launchd:** a LaunchAgent in `~/Library/LaunchAgents` runs `mr-watch tick` every 60 s, only while I'm logged in (needed for `say`). `tick` returns at once if less than `interval_minutes` has passed since the last poll, so the plist is written once and never changes. The plist sets `PATH` to include `/opt/homebrew/bin` for `glab` and `gh`. On/off only loads and unloads it.
- **Voice:** `say` uses the System voice, so mr-watch has no voice setting. `mr-watch voice` prints how to change it (System Settings → Accessibility → Spoken Content → System voice), and `mr-watch on` prints the same steps the first time.
- **Skill:** `dot-claude/.claude/skills/mr-watch/` with the script in `scripts/`; `/mr-watch …` just runs the CLI and shows its output.

### Rules for a correct tick

- **First sight is silent.** When an MR enters the watch list (first run, `add`, a new MR found by the API), record its state and say nothing. Only changes after that are events.
- **Comments:** skip system notes ("added 1 commit", "approved"), my own notes and bot users.
- **Ready to merge:** use the forge's own merge status field. It already checks approvals, resolved threads and the pipeline.
- **Silent time:** events outside speaking hours or during a mute go into a queue in state. The first tick that may speak says one catch-up sentence and empties the queue.
- **Lock:** a `mkdir` lock in the state dir, so a slow tick and the next one can't both speak the same event.
- **Auth failure:** if a CLI call fails, say it once ("mr-watch can't reach GitLab") and stay quiet until it works again, then say "GitLab is back".

## Lessons from the prototype

- Sort approver names before comparing. The API returned the same two approvers in a different order, and the prototype announced a "new approval" that wasn't new.
- Announce only the newly added approver, not the whole list.

## Scope

No work sources (Jira epics, GitHub Projects, backlog items, OpenSpec changes). My own MRs are found by the API, and those already cover an epic I work on. A chain gives the merge order, and `add` covers the odd MR from someone else. A source would add a Jira login under launchd and loose branch matching, for little gain.
