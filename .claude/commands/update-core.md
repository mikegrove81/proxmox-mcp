Pull core skill updates from gpg-development into this repo. Follow the complete workflow defined in `skills/update-core/SKILL.md`.

1. Confirm source exists at `C:\Repo\gpg-development` — ask if not found
2. Pull latest in the source repo
3. Dry-run: diff each manifest file and show a summary table with line counts
4. Show diffs for changed files and ask for confirmation before applying
5. Copy approved files, apply patch rules (strip auto-update block from session-start)
6. Commit with `core:` prefix and push

Read the full skill file for the manifest, patch rules, and multi-user path adaptation notes.
