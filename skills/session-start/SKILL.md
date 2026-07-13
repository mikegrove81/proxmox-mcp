---
name: session-start
description: "Open a work session by syncing git state and loading context. Use when the user says '/start', 'start session', 'open session', 'begin session', 'pick up where I left off', or at the start of any new conversation. Pulls remote changes, detects uncommitted local work, resolves trivial merge conflicts, then runs the full Session Start Sequence."
categories:
  - session-lifecycle
  - git-transport
tags:
  - start
  - pull
  - sync
  - session-open
summary: "Session opener that syncs local git state with remote, then runs the Session Start Sequence from CLAUDE.md."
---

# Session Start

Open a work session by syncing the local repo with remote and loading session context. The user never needs to touch git directly.

## When to Use This

- Beginning of any work session, especially when others may have pushed changes
- When the user says `/start`, "start session", "pick up where I left off"
- When CLAUDE.md Step 0 detects unsynced state and the user agrees to run `/start`
- NOT for "start building the console app" (development trigger)
- NOT mid-session (use `/sync`) or end-of-session (use `/wrap`)

## Workflow

> **Pre-injected state at session open** (resolved before Claude reads this skill):
> - Uncommitted changes: `!`git status --short``
> - Unpushed commits: `!`git log --oneline origin/master..HEAD 2>/dev/null || echo "none"``
> - Working state snapshot: `!`head -20 .claude/memory/working-state.md 2>/dev/null || echo "no working state found"``

1. **Identify the user** — resolve username from pre-injected `git config user.name` output above, map to team profile in CLAUDE.md. Ask if ambiguous.

2. **Check for uncommitted local changes** — use the pre-injected `git status` output above. If dirty:
   - Show the user what's uncommitted (`git diff --stat`)
   - Offer: "You have uncommitted changes from a previous session. Sync these first?"
   - If yes: `git add -A`, commit with message `sync: {username} pre-start checkpoint`, push
   - If no: proceed (changes stay uncommitted, user is aware)

3. **Check for unpushed commits** — use the pre-injected `git log` output above. If any:
   - Show the unpushed commits
   - Push them (`git push`)

4. **Pull remote changes** — `git pull`. Handle merge outcomes:
   - **Clean pull**: proceed
   - **Trivial conflicts** (non-overlapping edits, append-only files like changelog.md): auto-resolve. Use `git checkout --theirs` for changelog.md specifically (append-only, last-write-wins by design).
   - **Ambiguous conflicts**: stop, show the conflict markers, ask the user which version to keep.

5. **Report what changed** — show `git log --oneline` of new commits pulled and `git diff --stat` of what changed. Summarize in plain language.

   **Core update detection:** After pull, check if any incoming commits have a `core:` prefix in the message:
   ```
   git log --oneline @{1}..HEAD --grep="^core:"
   ```
   If matches found, display a prominent notice:
   ```
   ┌─────────────────────────────────────────────┐
   │  Core skills updated since your last session │
   │  {one-line summary from commit message}      │
   └─────────────────────────────────────────────┘
   ```
   This is informational only — no action needed from the user. The updated skills are already active.

6. **Detect stale working-state** — if `.claude/memory/working-state.md` has an `updated` date older than today, ask: "Your last session was on {date}. Continue that work or start fresh?" Either way, working-state gets overwritten during this session's work.

7. **Lazy context load** — the pre-injected snapshot is enough to orient; load more on demand:
   - Working-state is already pre-injected above — extract the current topic from it
   - **Ask:** "Git synced. Last working on: [topic]. What are we working on today?"
   - Load additional context **only after the user responds**: open-threads, related files — on demand based on their stated task, not upfront.

8. **Set permission mode** — Use the `AskUserQuestion` tool (not plain text) to ask: "Want hands-free mode? Run `/permissions bypassPermissions` now to skip all prompts." Claude cannot invoke slash commands itself, so if the user opts in, tell them to type `/permissions bypassPermissions` when convenient. Wait for the user's answer before proceeding.

9. **Report ready state** — brief status after context is loaded.

10. **Auto-clear (rules-driven)** — Check `.claude/rules/start-auto-clear.md`. If present and the current user matches, ensure working-state.md is current on disk, then suggest prompt `/clear` so the user can reset the conversation.

## Output Format

```
Session ready for {username}.
- Git: {pulled N commits / up to date / synced local first}
- Last: {topic} ({date})
What are we working on today?
```

## Common Pitfalls

- **Do not `git pull --rebase`** — standard merge preserves history better.
- **Do not silently discard uncommitted changes.** Always show what exists and ask before committing.
- **Load context on demand.** Working-state is pre-injected; pull open-threads and related files only after the user states their task.
- **If `git push` fails** (permissions, network), tell the user plainly and suggest retrying. Never attempt force-push.
- **Do not auto-resolve conflicts in skill files or CLAUDE.md** — these are structural files where a bad merge can break the persona. Always ask.
- **Do not `git pull` home-dev from a child repo.** home-dev is always current on disk. Pulling it adds network dependency and slows startup.

## Interface

### Expects
- Git repository with remote configured (`origin/master`)
- User identity in `git config user.name` mapping to team profile in CLAUDE.md

### Produces
- Clean, synced working tree (local matches remote)
- Loaded session context per Session Start Sequence
- Status report to user
