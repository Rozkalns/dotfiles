---
name: error-report
description: "Debug a failed request from its request ID, in a Laravel app that stamps prefixed request IDs (AssignRequestId middleware, app.server_code). Use whenever a message holds an error-page block — 'Pieprasījuma ID:' / 'Request ID:' with 'Laiks', 'Adrese', 'Lietotājs', 'Loma' lines — even when no question comes with it, or an ID like SRVAPP-K7Q2M9X4TB, a screenshot of an error page, or 'I get a 500 / 403 / 419 on …'. The block means: find that request in the server log, the audit log and GlitchTip, explain what failed and fix it."
---

# Error report

A pasted error-page block is a bug report, even when it arrives with no words or only "again".
The path alone rarely shows the cause; the server recorded it under the ID. Find the request by
its ID, read what was recorded, then explain the cause and fix it.

Several blocks for the same path: search every ID. A repeat says the error still happens, which
rules out a one-off (and, minutes after a deploy, points at step 5); it is not a second bug.

## 0. Is this project set up for it?

Request IDs are a per-app feature, not a fleet default. Check the current project has both
`app/Http/Middleware/AssignRequestId.php` and an `app.server_code` key in `config/app.php`. If not,
say in one line that this app has no request-ID tracing, then debug the report the usual way (path,
time, daily log around that minute). Do not go looking on a server for an ID this app never wrote.

```
Pieprasījuma ID: SRVAPP-K7Q2M9X4TB      ← the key to everything below
Laiks: 29.10.2026 12:25:50             ← Europe/Riga; the log is in UTC
Adrese: /bookings/01m5…                ← path without query; link tokens show as …
Lietotājs: …   Loma: …                 ← who saw it (signed in only); "Īstais konts" = impersonation
```

## 1. Decode the ID

`SRVAPP-K7Q2M9X4TB` = server code `SRV` + project code `APP` + `-` + 10 random characters. The
codes are in `~/code/server/projects.yaml` (local only): `code:` on the server and on the site.
That entry also gives the values for `<ssh>`, `<path>` and `<database>` below, and the GlitchTip
URL. Use them as written there (absolute paths).

- **`XXX` server code** = a local or CI run, never a server. Look in this checkout's
  `storage/logs/`, not on a server.
- **No prefix (10 characters only)** = written before the prefix shipped (2026-10-29): this app on
  the server that was live then (see `projects.yaml`).
- An unknown code: ask, do not guess. A new server must be added to `projects.yaml` first.
- Keep real codes out of repo files, commits and PRs (examples use `SRVAPP`). The prefix is
  meant to tell us where an ID came from and tell an outsider nothing; that only holds while the
  mapping stays in `projects.yaml`.

The same ID is on every log line, every audit entry and the GlitchTip event of that web request.
Commands and jobs get IDs too, and a job queued by a request keeps the request's ID.

## 2. Server log

Daily files: `storage/logs/laravel-YYYY-MM-DD.log`, named by the **UTC** date (production runs
`LOG_STACK=daily`; its `laravel.log` is a stale leftover). Convert `Laiks` from Riga time first
(UTC+3 in summer, UTC+2 in winter); near midnight check both days.

The ID sits on the **last** line of an entry. An exception's message and file:line are on the
first line, above the stack trace, so read enough lines before the match:

```bash
ssh <ssh> 'grep -F -B 200 <ID> <path>/storage/logs/laravel-2026-10-29.log'
```

Production SSH goes through a guard hook that lets only listed read-only commands run unattended;
the two commands in this skill are on that list. If a command is blocked, ask Roberts in one sentence
or hand over a one-liner to paste. Do not reword a command to get past the hook: it is the only
guard between a session and production, so a workaround removes the protection, not the prompt.

What the lines mean:
- `production.ERROR` with an exception: the 500. The first line gives class, message, file:line.
- `Access denied` (notice): a 403, with `ability`, `model`, `model_key` when a policy refused, and
  `referrer_route`: the page the user came from (`external` = another site), so "how did they get
  here" is usually answered without the audit log. `impersonated_by` means an admin was acting as
  that user; a 403 then is often expected.
- `Validation failed` (info): rule names per field, never values.

## 3. Audit log

What happened around the request: the audit entries a few minutes before and after `Laiks`, with
`request_id` as a column so the request's own entries stand out. Only a request that changed
something writes audit entries. A 403 or a failed form writes none; then the entries just before
it show how the user got there.

The guard hook rejects quotes inside the SQL, so the query has no string literals: the window is in
Unix seconds (`created_at` is UTC). Get each bound from the UTC time with
`date -u -j -f '%Y-%m-%d %H:%M:%S' '2026-10-29 09:20:00' +%s`.

```bash
ssh <ssh> 'sqlite3 -readonly <database> "SELECT id, created_at, request_id, description, causer_id, subject_type, subject_id, school_id FROM activity_log WHERE (julianday(created_at) - 2440587.5) * 86400 BETWEEN <from> AND <to> ORDER BY id"'
```

Select IDs and metadata only. The database holds sensitive personal data, and anything printed
here leaves the server for an external API, so never select `properties` or any personal field.

## 4. GlitchTip

A 500 also has a GlitchTip event tagged `request_id`. Open the site's `glitchtip_url` from
`projects.yaml` and search the tag `request_id:<ID>`.

## 5. Was it a deploy?

Compare `Laiks` with the live commit and the merge time: `git -C <path>/current
rev-parse HEAD` (allowed unattended), then `git log` locally. An error in the first minutes after
a deploy is often a stale compiled view, not the code: see the stale-Livewire incidents in
`~/code/server/incidents/`.

## 6. Reproduce and fix

Reproduce locally from the file:line, on the demo seed (`composer qa:up` in a worktree), never on
the production copy. Write a failing test first, then fix. Report: the ID, what the log said, the
cause, the fix. If nothing matches the ID, say so plainly and say which files and dates you
searched.
