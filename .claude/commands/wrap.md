Close the work session. Follow the complete workflow defined in `skills/session-wrap/SKILL.md`:

**Memory Phase:**
1. Review the session for decisions, discoveries, open questions, and work produced
2. Read `memory/working-state.md` to understand what changed
3. Write digest to `memory/digests/YYYY-MM-DD.md` (use suffix if today's already exists)
4. Overwrite `memory/working-state.md` entirely with current state
5. Update `memory/open-threads.md` — add new threads, update existing, move completed/dropped
6. Update domain memory files if applicable (project-registry, decisions)
7. Confirm memory writes with the user before committing

**Git Phase:**
8. Stage everything with `git add -A`
9. Generate commit message: `wrap: {username} session end — {digest summary}`
10. Commit and push
11. Final confirmation
12. Compound nudge if session had deliverables

Read the full skill file for digest format, output rules, and pitfalls.
