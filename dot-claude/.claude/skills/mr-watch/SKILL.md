---
name: mr-watch
description: "Spoken updates on GitLab merge requests and GitHub pull requests: approvals, ready to merge, merged (with the next MR in a hand-set merge order), failed pipelines, new comments and review requests, said aloud with macOS `say` by a LaunchAgent. Use when the user types /mr-watch, asks to turn the MR watcher on or off, mute it ('quiet for an hour'), watch or stop watching an MR or PR, set a merge order or chain ('merge order: !7360 → !7327'), asks what's up with their MRs, or wants to change the voice."
---

# mr-watch

All work goes through one CLI. Run it and show its output. Don't edit the config or state files by hand.

```
mr-watch on | off            # start / stop the LaunchAgent (off survives reboot)
mr-watch quiet [60m|2h|off]  # mute on top of the speaking hours
mr-watch status              # poll now, print and speak what's up
mr-watch add <ref>…          # watch an MR
mr-watch remove <ref>…       # stop watching; also hides it from the API search
mr-watch chain <ref> <ref>…  # set a merge order; `chain clear [<ref>]` removes it
mr-watch voice [test]        # how to change the voice; `test` speaks a sample
mr-watch tick [--now]        # one poll (what launchd runs); --now skips the on/off and interval checks
```

The script is `scripts/mr-watch`, also on PATH as `mr-watch` through `~/.dotfiles/bin`.

## References

- GitLab: `group/project!123`. GitHub: `owner/repo#123`.
- `!123` or `#123` takes the repo from the current directory's `origin`.
- A GitLab MR or GitHub PR URL also works.

When the user pastes a merge order (for example "Merge order: !7360 → !7327 → !7380. !7406 can merge on its own."), run `mr-watch chain` with the ordered refs only. An MR that "can merge on its own" doesn't go in the chain.

## What it watches by itself

Every forge in `forges` whose CLI (`glab`, `gh`) is logged in. The forges are detected when the config is first created. It watches:

- the user's own open, non-draft MRs;
- MRs where the user is a reviewer;
- extra MRs and chains added with the CLI.

A merged extra MR leaves the list. A chain leaves the list when all of its MRs are merged.

Settings the CLI doesn't change (`speak_hours`, `interval_minutes`, `forges`, `own_open_mrs`, `review_requests`) live in `~/.config/mr-watch/config.json`. Edit them with `jq` when the user asks. They take effect on the next tick.

## Voice

`say` uses the macOS System voice, so there is no voice setting in mr-watch. When the user wants another voice, run `mr-watch voice` and show the steps: System Settings → Accessibility → Spoken Content → System voice.

## When something looks wrong

- Log: `~/.local/state/mr-watch/tick.log`.
- `launchctl print gui/$(id -u)/com.user.mr-watch` shows whether the agent is loaded.
- Nothing is said for an MR the first time it is seen. That is how it avoids replaying old events.
