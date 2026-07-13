---
name: session-wrap
description: "Close a work session: write digest, update memory, commit everything, push. Use when the user says '/wrap', 'wrap up', 'end of session', 'done for today', 'write a digest', 'session summary', 'log this session', 'save progress and close', 'sign off', or before ending a conversation. Generates session digest from conversation context, updates working-state and open-threads, stages all changes, commits, and pushes. Supersedes session-digest in this vault."
categories:
  - session-lifecycle
  - git-transport
  - memory-management
tags:
  - wrap
  - digest
  - session-end
  - commit
  - push
summary: "Session closer that generates digest, updates all memory files, then commits and pushes everything to remote."
---

# Session Wrap

Close a work session by writing a structured digest, updating all memory files, then committing and pushing everything. This is the team-friendly replacement for the manual end-of-session workflow — digest, git add, commit, push all happen in one shot.

**This skill supersedes session-digest in this vault.** It does everything session-digest does plus git commit and push.

## When to Use This

- End of any session where decisions were made, context was gathered, or work was produced
- When the user says `/wrap`, "wrap up", "done for today", "write a digest", or similar
- Before switching to a different persona or ending a conversation
- NOT for "wrap up the project plan" (project-plan output) or mid-session summaries
- NOT for mid-session checkpoints (use `/sync`)

## Child Project Behavior

Detect by checking the repo name (`basename` of repo root). If NOT `home-dev`:
- Create `.claude/memory/` and `.claude/memory/digests/` if they don't exist
- Write working-state.md and digests as normal, scoped to this project's work only
- Write open-threads.md, scoped to this project's threads only

## Workflow

### No-Op Check (before anything else)

0. **Check for a no-op session** — run `git status --short`. If it's empty AND the conversation produced no decisions, discoveries, file edits, or work worth recording (e.g. this is an immediate `/wrap` right after `/start`, or a pure Q&A session with nothing done), ask via `AskUserQuestion` using this exact wording:
   - Header: `Wrap`
   - Question: `Nothing changed this session — write a digest anyway, or skip?`
   - Option 1 — Label: `Skip (recommended)` — Description: `No commit, no digest — nothing happened worth recording.`
   - Option 2 — Label: `Write anyway` — Description: `Write a digest and update memory even though nothing changed.`

   If the user picks Skip: state "Nothing to wrap — no changes this session." and stop here. Do not write a digest, do not touch working-state.md or open-threads.md, do not commit or push.

   If the user picks "Write anyway," or if `git status --short` is non-empty, or the session clearly did produce discoveries/decisions/edits even without a git diff (e.g. pure planning or research) — proceed to the Memory Phase below as normal.

### Memory Phase

1. **Review the session** — scan the conversation for decisions, discoveries, open questions, and work produced.

2. **Read working-state.md** — understand what changed relative to the start of the session.

3. **Run compound-learning if session markers fire** — auto-invoke the compound-learning skill when ANY of these markers are present in the session:
   - File edits or new files under `skills/`, `references/`, or `CLAUDE.md` (orchestration changes)
   - More than 5 files changed total this session (multi-file deliverable signal)
   - Explicit user phrases mid-session: "save that", "compound this", "what did we learn", "that worked well", "that landed well"
   - Significant code delivery, architecture decision, or production incident resolution

   Skip the auto-call when ALL markers are absent — the session was conversation, planning, or a quick single-file fix only. Also skip when the user says "skip compound", "no compound", or "just wrap" at the start of the wrap flow.

   Compound's propose-approve gate runs as normal: user sees each proposal with budget line, approves/edits/redirects/skips. Resulting file edits become part of the wrap commit. Audit log entries land in `.claude/memory/learnings/_log.md` before the digest is written.

4. **Write the digest** — create `.claude/memory/digests/YYYY-MM-DD.md`. If compound ran in step 3, mention dispositions in "Decisions Made" or "What Happened". If a digest already exists for today, use suffix: `YYYY-MM-DD-2.md`, `YYYY-MM-DD-3.md`, etc.

5. **Overwrite working-state.md** — replace entirely with current state: what's in progress, where we left off, active decisions pending, temporary context. This is ephemeral — do not append.

6. **Update open-threads.md** — add new threads discovered mid-session, update existing threads with progress, move completed items to the Completed table, move abandoned items to the Dropped table with a reason.

7. **Update domain memory files** — **skip this step in child projects** (see Child Project Behavior above). In home-dev, if the session produced a durable fact (user background, feedback, project pointer, reference) that belongs in permanent memory and isn't already covered by open-threads.md, create or update the relevant memory file (see MEMORY.md for existing files). Do not create files speculatively — only when the need has actually emerged.

8. **Confirm memory writes with the user** — show a brief summary of what was written (including compound dispositions if step 3 ran) and where. Let the user correct anything before committing. This is the review gate.

### Git Phase

9. **Detect recent sync** — if the last commit is a `sync:` commit from this session, note that only wrap-specific changes (digest, thread closure, state update, plus any compound edits from step 3) are in this commit.

10. **Stage everything** — `git add -A`

11. **Generate commit message** — `wrap: {username} session end — {digest summary sentence}`. If compound ran, fold a brief mention into the summary (e.g. "...; compound: 2 dispositions to etl-patterns.md").

12. **Commit** — `git commit -m "{message}"`

13. **Push** — `git push`

14. **Final confirmation** — "Session wrapped. Digest written, memory updated, {N} files committed and pushed." Append `(compound: {N} dispositions)` if step 3 ran.

15. **Auto-clear (rules-driven)** — Check `.claude/rules/wrap-auto-clear.md`. If present and the current user matches, suggest prompt `/clear` so the user can reset the conversation.

## Digest Output Format

```yaml
---
title: "Session Digest — [Date]"
type: memory
updated: [today's date]
categories:
  - session-digest
tags:
  - [session-specific tags]
status: active
scope: [username]
related:
  - .claude/memory/working-state.md
  - [other files referenced or updated this session]
summary: "[One sentence: what was accomplished this session.]"
---
```

```markdown
# Session Digest — [Date]

## What Happened
[2-4 sentences: focus, accomplishments]

## Decisions Made
- [Decision]: [rationale]

## Code Produced
- [Component]: [what was built, where it lives]

## Open Questions
- [Question]: [why it matters]

## Next Session
- [Specific next steps — not vague "continue work"]
```

## What NOT to Include in the Digest

- Conversation transcripts (this is a summary, not a log)
- Speculative analysis not grounded in session work
- Duplicate information already captured in working-state.md
- Over-linked wikilinks (2-5 max, only files you'd need alongside this digest)

## Common Pitfalls

- **Writing too much in the digest**: under 500 words. If longer, you're writing a report, not a digest.
- **Vague next steps**: "Continue ETL work" is useless. "Build the stored procedures for delta detection on the vendor staging table" is useful.
- **Skipping working-state update**: the digest is archival, working-state is ephemeral. Both need updating — digest alone doesn't help next session's startup sequence.
- **Forgetting open-threads**: new threads discovered mid-session get lost if not written to open-threads.md.
- **Forgetting project-registry**: if a project was started or its status changed, update the registry.
- **Not confirming with user before committing**: memory writes should be reviewed. The git commit is the point of no return for the push.
- **If push fails**: the commit is still local. Tell the user. The memory files are already written, so the session is captured regardless.

## Interface

### Expects
- Active session with identified user (from `/start` or Session Start Sequence)
- Conversation context with decisions, discoveries, or work produced

### Produces
- Session digest in `.claude/memory/digests/YYYY-MM-DD.md`
- Overwritten `.claude/memory/working-state.md`
- Updated `.claude/memory/open-threads.md`
- Updated domain memory files (if applicable)
- All changes committed and pushed to remote
- Final confirmation message
