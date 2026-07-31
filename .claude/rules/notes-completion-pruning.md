# Notes Completion Pruning Applies Outside `/repo-notes` Too

`notes/punchlist.md`, `notes/todos.md`, and `notes/ideas.md` items get
executed two ways: through the `repo-notes` skill (`/repo-notes`, "process
1-4"), or ad hoc — the user just asks for the thing directly in
conversation, without invoking the skill. Only the first path pruned the
note. The second left it sitting in the file, done or not, which is what
produced the "did we do this?" pattern: the work happened, but nothing ever
removed the paper trail saying it hadn't.

## The Rule

Whenever work you complete in a session **matches or clearly overlaps** an
item in `notes/punchlist.md` or `notes/todos.md` — regardless of whether the
user invoked `/repo-notes` — prune that item the same way `repo-notes` would:

- **Done:** remove the item, renumber the remaining items in that file.
- **Blocked / needs a decision:** keep it, append a `>> ` annotation line
  explaining why and what's needed (same convention as `repo-notes` step 2).

`notes/ideas.md` items follow `repo-notes`' plan-path convention: once an
idea has been substantially acted on (not just planned), it's fine to remove
it directly rather than only annotating — ideas are the one bucket without a
"leave it, the user deletes it" rule baked in for the ad-hoc path, since
there's no `plans/` pointer to preserve when the ad-hoc work already *is*
the deliverable.

Do this in the same session as the work, not deferred to the next
`/repo-notes` or `/wrap` run — a stale note is exactly the failure mode this
closes.

## Why

Treating pruning as something only `/repo-notes` does made note hygiene
depend on which door the user walked through to get the work done, which is
not a distinction the user should have to track. The note files exist to
answer "did we do this?" at a glance — that only holds if completion prunes
the note regardless of invocation path.

## What This Does Not Change

- The `/repo-notes` confirmation gate (list items, wait for confirmation
  before executing) still applies when the user explicitly invokes
  `/repo-notes` on a range — this rule only covers ad-hoc completions where
  no such gate was requested.
- Items with no clear match to notes content are left alone — do not go
  hunting through notes files speculatively for something to prune.
