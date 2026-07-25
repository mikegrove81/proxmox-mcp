# Access Control Files Are Immutable

Claude must NEVER edit, write, or overwrite the **content** of these files in any repo:

- `.claude/db-access.conf` (database access scope)
- `.claude/folder-access.conf` (folder access overrides)
- `.claude/guards.conf` (global guards - system db deny, protected paths, repo fence)
- `.claude/server-aliases.conf` (server alias-to-name mapping)

(Guard hook scripts under `.claude/hooks/*.sh` are governed separately by
`guard-hook-self-modification.md` — edit-with-explicit-confirmation, not immutable.)

## Git Versioning Is Allowed

This rule prohibits **content modification** (Edit/Write), not version control. Once the
user has manually edited one of these files, Claude MAY stage, commit, and push it like
any other file: `git add`, `git commit`, and `git push` are all permitted and expected.

These paths are `readonly` (not `block`) in guards.conf, so `git add` does not trip the
write check, `git commit` is allowlisted, and non-force `git push` falls through. Do not
refuse a commit/push of these files; the user authored the change, and versioning it does
not widen Claude's own permission boundary.

## Why

These files define Claude's own permission boundaries. Allowing Claude to modify them defeats the purpose of having guardrails. A hook enforces this as a hard block, but Claude should not attempt the write in the first place.

## What To Do Instead

If a task requires access Claude doesn't have:

1. Tell the user which file needs the change
2. Provide the exact line to add (e.g., `sql: localhost/MyDatabase = read`)
3. Wait for the user to paste it manually

If the user can't reliably copy content from the chat itself (e.g. mid-diagnosis of a
terminal rendering issue), write the drafted content to a sibling staging file next to
the protected one (e.g. `db-access.conf.NEW`) instead of only pasting it in chat — the
user can open that file in an editor and copy/rename from there without retyping.

## Exception

The admin repo (home-dev) bypasses the hook for repo-updatecore maintenance of guards.conf and server-aliases.conf. This does NOT mean Claude should freely edit access files in the admin repo - the policy still applies. The bypass exists only for infrastructure propagation to child repos.
