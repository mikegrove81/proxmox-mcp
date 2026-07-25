# Guard Hook Self-Modification Requires Explicit Confirmation

Editing `.claude/hooks/*.sh` (guard-destructive.sh, guard-protected-paths.sh,
guard-sql-destructive.sh) triggers the Claude Code auto-mode classifier's
self-modification check — it blocks the edit unless the user has explicitly
confirmed the *specific* diff, not just a general "fix it" or "yes go ahead."

A vague re-authorization like "Fix the guard hook" is not sufficient, even
after already explaining the bug and proposed fix in a prior message.

**How to apply:** before attempting the `Edit` call, restate the exact change
(what pattern is added/changed, what it does and doesn't affect) and get
explicit confirmation via `AskUserQuestion`.
