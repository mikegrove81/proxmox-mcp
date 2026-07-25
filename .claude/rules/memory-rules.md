---
paths:
  - ".claude/memory/**"
---

# Memory File Rules

When accessing memory files, follow these rules.

## Session Start (if not already done)

If this is the first memory file access in this session, execute the full Session Start Sequence:
1. Identify the user — check `git config user.name`, map to team profile in CLAUDE.md
2. Read `.claude/memory/working-state.md` first
3. Scan frontmatter of `.claude/memory/` for files matching current task
4. Follow "related" links from loaded memory files (one hop)
5. Check `.claude/memory/open-threads.md` for relevant pending items

## Write Rules

- working-state.md is ephemeral: OVERWRITE each session, do not append
- open-threads.md is persistent: add, update, and move items between Active/Completed/Dropped tables
- Session digests go in `.claude/memory/digests/` with YYYY-MM-DD.md naming
- All memory files must have YAML frontmatter: a `title`/`name`, a `type` reflecting the file's role (`memory`, `user`, `feedback`, `reference`), a `description`/`summary`, and either `updated` or `originSessionId`
- Use the supersedes field when a memory file overrides a fact in a context file
- Do not create memory files speculatively — add when the need emerges

## Memory System Boundary

- Curated memory (.claude/memory/) is authoritative for operational facts
- Do not duplicate curated memory facts into Claude's native auto-memory
- If auto-memory contradicts a file here, this directory wins
