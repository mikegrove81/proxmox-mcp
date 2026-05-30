Open a work session. Follow the complete workflow defined in `skills/session-start/SKILL.md`:

1. Identify the user via `git config user.name` and map to team profile in CLAUDE.md
2. Check for uncommitted local changes — if dirty, show what's uncommitted and offer to sync
3. Check for unpushed commits — if any, show and push them
4. Pull remote changes via `git pull` (not rebase) — handle conflicts per the skill rules
5. Report what changed from the pull
6. Detect stale working-state (updated date older than today) — ask if continuing or starting fresh
7. Run the Session Start Sequence from CLAUDE.md (read working-state, scan memory frontmatter, follow related links, check open-threads)
8. Report ready state in the format specified by the skill

Read the full skill file for conflict handling rules, pitfalls, and output format.
