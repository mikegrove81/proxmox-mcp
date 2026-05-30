---
name: sync
description: "Mid-session checkpoint that saves all progress to git. Use when the user says '/sync', 'save progress', 'checkpoint', 'push my changes', 'commit everything', or after completing a meaningful unit of work. Flushes memory updates, stages all changes, commits with auto-generated message, and pushes."
categories:
  - session-lifecycle
  - git-transport
tags:
  - sync
  - commit
  - push
  - checkpoint
summary: "Mid-session git checkpoint: flush memory, stage all, commit, push in one shot."
---

# Session Sync

Mid-session checkpoint that commits and pushes all changes to remote. The user never needs to run git commands.

## When to Use This

- Mid-session when the user wants to save progress
- After completing a meaningful phase or deliverable
- Before stepping away temporarily
- When another skill's completion flow suggests it
- NOT at end of session (use `/wrap` — it does everything `/sync` does plus digest and thread closure)
- NOT at start of session (use `/start`)

## Workflow

1. **Check for changes** — `git status`. If nothing to commit, say "No changes to sync." and stop.

2. **Compound-marker check (offer, don't force)** — if the work since session start includes any of:
   - File edits or new files under `skills/`, `references/`, or `CLAUDE.md`
   - Explicit phrases this session: "save that", "compound this", "what did we learn", "that worked well"
   - A completed deliverable (code delivery, architecture decision, multi-file change)

   ...ask once: "This session has compound markers ({brief — what fired}). Run `/compound` first, or just sync?" If user says compound, defer sync and hand off. If user says sync / skip / continue, proceed without further prompting.

   Skip the offer entirely when no markers fire. Sync stays a fast checkpoint by default.

3. **Detect recent sync** — `git log --oneline -1`. If the last commit is a `sync:` or `wrap:` commit from within the last 5 minutes, ask: "You just synced {N} minutes ago. Sync again?" Prevents accidental double-commits.

4. **Quick-update working-state** — check if `memory/working-state.md` reflects current work. If the "Currently Working On" section is stale (doesn't match what was actually done this session), update it before committing. This ensures the checkpoint captures meaningful state, not just file changes.

5. **Stage everything** — `git add -A`

6. **Generate commit message** — `sync: {username} checkpoint — {first 60 chars of "Currently Working On" from working-state.md}`
   - If no working-state context is available: `sync: {username} checkpoint`

7. **Commit** — `git commit -m "{message}"`

8. **Push** — `git push`

9. **Confirm** — "Synced. {N} files committed and pushed."

## Common Pitfalls

- **Do not skip the working-state check.** A sync without updated memory is just a git commit — it misses the point of capturing session state.
- **Do not prompt for a detailed commit message.** The auto-generated message is intentional — this is a checkpoint, not a curated commit. Keep it fast.
- **If push fails**, the commit is still local. Tell the user and suggest retrying. The work is not lost.
- **Do not run `git add -A` without `git status` first.** If there's nothing to commit, say so instead of creating an empty commit.

## Interface

### Expects
- Active session with identified user (from `/start` or Session Start Sequence)
- Changes in the working tree

### Produces
- All changes committed and pushed to remote
- Updated working-state.md (if it was stale)
- Confirmation message with file count
