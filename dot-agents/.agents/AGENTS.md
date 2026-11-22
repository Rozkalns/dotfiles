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
- **Steal ideas, not layouts.** When I show another product (screenshots, a link, an app), mine it for ideas: list what it does well, then adapt the good ones to our design system, domain and security rules, and record them (backlog item, spec). Never copy its look. My motto, after Steve Jobs (1996): "Good artists copy; great artists steal."
- **Correct your own earlier statements** as soon as a later measurement contradicts them, and say plainly what was wrong. A spec or report left carrying a false claim costs more than the original error did.

## Writing style

- **Default to clear, simple international English.** Borrow ASD-STE100 Simplified Technical English *principles* where they aid clarity: short direct sentences, one idea per sentence, common words, active voice, consistent terminology, and no filler or inflated vocabulary ("use" not "utilise", "so" not "thereby", "enough" not "sufficient").
- **Do not apply STE strictly.** STE is a controlled language for technical instructions, not general writing, so skip its formal vocabulary and grammar rules. Adapt tone to the audience and purpose.
- **Scope:** this governs chat replies and general prose. It does not override a skill that defines its own register or voice (the reflections journal in my voice, the Latvian Slack voice, audience-specific JIRA and MR templates); those win where they apply.

## One rules file for every agent

This file is `~/.agents/AGENTS.md`. Claude Code reads it as `~/.claude/CLAUDE.md`, and Codex reads it as `~/.codex/AGENTS.md`. Both are links to this file, so edit it only here (in the dotfiles: `dot-agents/.agents/AGENTS.md`). Skills live in `~/.agents/skills/` and are shared the same way.

### Claude Code names in other agents

Skills and docs are written with Claude Code names. Claude Code: skip this section. In another agent, such as Codex, read them like this. Do not assume a Claude-only tool exists. (Tool rows based on [this mapping](https://gist.github.com/jylkim/ab9cb20e834532ea567d767fef14d268).)

| Claude Code says | Do this |
|---|---|
| `/skill-name`, or the `Skill` tool | Open that skill's `SKILL.md` and follow it. If it is not installed, say so and stop. Do not hand-roll its work. |
| A skill from a Claude Code plugin | Read its `SKILL.md` under `~/.claude/plugins/cache/` and follow it. If it is not there, use the skill's documented fallback. |
| `AskUserQuestion` | `request_user_input`. If it is not available, list the options as numbers in chat and wait for the reply. |
| `TodoWrite`, `TaskCreate` / `TaskUpdate` / `TaskList` | `update_plan` |
| `Read` | `read_file` when available, otherwise `cat` or `sed -n` in the shell |
| `Edit`, `Write` | `apply_patch` |
| `Glob`, `Grep` | `rg --files`, `rg` in the shell |
| `Bash` | Your shell tool (`exec_command`, `shell_command` or `shell`) |
| `WebSearch` / `WebFetch` | `web_search` / `curl`, or a matching MCP tool |
| `ToolSearch` | `tool_search` |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | `list_mcp_resources` / `read_mcp_resource` |
| `Agent` with `general-purpose` | `spawn_agent` (default type; `worker` for implementation with a clear owner) |
| `Agent` with `Explore` | `spawn_agent` with `agent_type: "explorer"` |
| `Agent` with `Plan` | Plan in the main agent, or `spawn_agent` with a planning-only prompt |
| `Agent` with a custom type (for example `review-security`) | Read that agent's `.md` file (under `.claude/agents/` or the plugin's `agents/`), then `spawn_agent` with its text as the prompt |
| `SendMessage` | `send_input` to the spawned agent; `close_agent` when it is done |
| `EnterPlanMode` / `ExitPlanMode` | No equivalent. Show the plan in chat and wait for approval. |
| `allowed-tools` in frontmatter | Ignore it. |
| `CLAUDE.md` or another file under `.claude/` | Read the file at that path. A project `CLAUDE.md` holds project rules, the same as `AGENTS.md`. |

Never post to GitLab, Jira or Slack without showing the user the exact text first and getting a yes.
