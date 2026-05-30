---
name: session-digest
description: "*(Superseded by session-wrap in this vault. Kept as template for deployed personas without git lifecycle.)* Write a structured session digest. Do NOT trigger — use session-wrap instead for all end-of-session workflows."
categories:
  - memory-management
  - session-continuity
tags:
  - digest
  - session-end
  - memory-write
  - superseded
summary: "Superseded by session-wrap. Kept as reference template for personas without git lifecycle skills."
---

# Session Digest

> **Superseded by session-wrap in this vault.** Use `/wrap` for end-of-session workflows. This file is kept as a template reference for other deployed personas.

Write a structured session digest at the end of a work session. This prevents the "empty memory" problem — every session that produces meaningful work leaves a written record.

## When to Use This

- End of any session where decisions were made, context was gathered, or work was produced
- When the user says "wrap up", "let's stop here", "write a digest", or similar
- NOT for mid-session updates (update working-state.md directly)

## Workflow

1. **Review the session**: Scan the conversation for decisions, discoveries, open questions, and work produced
2. **Check working-state.md**: Read current state to understand what changed
3. **Write the digest** in `memory/digests/YYYY-MM-DD.md`. If multiple sessions same day, append suffix: `YYYY-MM-DD-2.md`
4. **Update working-state.md**: Overwrite with current state — what's in progress, where we left off, active decisions pending
5. **Update open-threads.md**: Add new threads, update existing ones, move completed items
6. **Update project-registry.md**: If project status changed, update the registry
7. **Update decisions.md**: If architecture decisions were made, record them with rationale
8. **Confirm with the user**: Show a brief summary of what was written and where

## Output Format

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
scope: gpg-development
related:
  - memory/working-state.md
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
- [Specific next steps]
```

## Common Pitfalls

- **Writing too much**: Under 500 words. If longer, you're writing a report.
- **Vague next steps**: "Continue ETL work" is useless. "Build the stored procedures for delta detection on the vendor staging table" is useful.
- **Skipping working-state update**: The digest is archival. Working-state is ephemeral. Both need updating.
- **Forgetting project-registry**: If a project was started or its status changed, update the registry.
