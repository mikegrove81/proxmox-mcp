# Notes Files Are Always User-Authored

Mike adds items to `notes/` files (`punchlist.md`, `todos.md`, `ideas.md`, and
anything else under `notes/`) ad hoc, between sessions and mid-session, so he
doesn't forget them. **Any uncommitted change to a file under `notes/` is always
his own edit.** Treat it as valid, expected, and already-authorized to commit.

## The Rule

Never do "the dance" over a `notes/` change:

- **Never flag it as foreign / unexpected / "this changed and I didn't do it."**
  A modified `notes/` file in `git status` is not a mystery to investigate or a
  change to attribute — it's Mike jotting something down. Assume that, always.
- **Never ask permission to include it in a commit or push.** Notes changes are
  pre-authorized. Sweep them into whatever commit is being made (`/start`
  checkpoint, `/sync`, `/wrap`) with no confirmation prompt.
- This applies in **every repo** (home-dev and all children), which is exactly
  where the "hey, this changed and I didn't do it" back-and-forth kept happening.

## How It Applies Per Skill

- **`/start` (session-start step 2):** if the *only* uncommitted changes are
  under `notes/`, skip the "You have uncommitted changes — sync these first?"
  offer entirely: auto-commit and push (remote-backed) as the pre-start
  checkpoint. If notes changes are *mixed* with other uncommitted work, the
  notes portion still needs no separate confirmation — fold it into whatever the
  user chooses for the rest.
- **`/sync` and `/wrap`:** these already `git add -A`, so notes are already
  swept. This rule affirms that behavior is correct — never carve notes out of a
  sync/wrap commit or pause over them.

## Boundaries

- This covers **committing/pushing** notes changes without friction. It does not
  change how notes *content* is processed: acting on a note (executing a
  punchlist item, routing an idea) still follows `/repo-notes` and
  `notes-completion-pruning.md`.
- A genuine merge conflict inside a `notes/` file is still resolved normally
  (notes files are effectively append-only, so prefer keeping both sides) — this
  rule removes the confirmation dance, not conflict handling.

## Why

The trust boundary here is settled: notes files are Mike's scratchpad, not a
surface Claude edits or needs to police. Every session that opened with a
modified `notes/` file and asked "did you mean to change this?" was spending a
round-trip on a question with a permanent, known answer. Encoding the answer
once removes the friction fleet-wide.
