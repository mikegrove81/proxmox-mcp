Mid-session checkpoint. Follow the complete workflow defined in `skills/session-sync/SKILL.md`:

1. Check for changes via `git status` — if nothing to commit, say so and stop
2. Detect recent sync — if last commit is a sync/wrap from within 5 minutes, confirm before proceeding
3. Quick-update `memory/working-state.md` if stale
4. Stage everything with `git add -A`
5. Generate commit message: `sync: {username} checkpoint — {first 60 chars of "Currently Working On"}`
6. Commit and push
7. Confirm with file count

Read the full skill file for pitfalls and edge cases.
