- never add "Co-Authored-By" lines to git commits
- for git commit messages, follow the project's CONTRIBUTING.md if present, otherwise default to Conventional Commits
- use `jq` for JSON parsing in bash, not `python3 -c "import json..."`
- **local dev:** use `rg` (ripgrep) instead of grep or find
- **server (production/staging):** use standard POSIX tools only (`grep`, `find`, `awk`, `sed`) — do not assume `rg` or other non-default tools are installed
- **server inventory:** `~/code/server/projects.yaml` (local only, outside this repo) is the source of truth for the personal server and its sites — per site: domains, repo, branch, deploy path, zero-downtime mode, CI, alerts, plus the deploy CLI and workflow. Read it before any server/site work instead of rediscovering layout.
- **memory search:** when recalling something from memory, always search BOTH `~/.claude/memory/` (global) AND `~/.claude/projects/<project>/memory/` (project-specific)

## Working agreement

- **Name the deliverable in one sentence before starting** — the PR title, the file to be changed, or the command output expected. If you can't state it, you don't have the task yet: ask.
- **Research before you edit.** Reading a file before editing it is already enforced by the tooling; grepping is not. Before changing a function's signature or behaviour, grep every caller — including Blade, string-based container resolution, `<livewire:>` tags, route action strings and config keys, all of which a PHP-only search misses.
- **Smallest viable plan first**, stated before touching anything. Keep context narrow; prefer a targeted grep over a broad sweep.
- **Stop and check in** instead of pressing on: after **two failed attempts** at the same fix, at the **end of a phase** of a multi-phase task, or when the planned approach turns out to be wrong. Report what was learned; don't quietly try a third thing.
- **Measure before optimising, and re-measure after.** State the number being improved and the number achieved. A prediction is not a result — and the first thing worth checking is whether the thing you were asked to optimise is actually the bottleneck.
- **Verify before claiming.** Run the command and quote its output. Say explicitly when a check was skipped, or when a claim is inferred rather than observed.
- **Correct your own earlier statements** as soon as a later measurement contradicts them, and say plainly what was wrong. A spec or report left carrying a false claim costs more than the original error did.
