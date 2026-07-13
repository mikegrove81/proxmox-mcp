---
name: repo-updatecore
description: "Pull core skill and config updates from gpg-development into home-dev, or push config updates from home-dev to child repos. Use when the user says '/repo-updatecore', 'update core skills', 'sync from upstream', 'pull upstream changes', or 'push config to child repos'."
categories:
  - workflow
  - maintenance
tags:
  - update
  - upstream
  - core-skills
summary: "Syncs core session/workflow skills from gpg-development into home-dev, or pushes home-dev config to child repos."
---

# Update Core Skill

## Purpose

home-dev is the admin repo for personal projects. This skill handles two directions:

- **Pull from gpg-development** — adopt improvements to session skills or hooks from the work environment (when gpg-development is on disk at `C:\Repo\_RepoWork\gpg-development`)
- **Push to child repos** — propagate home-dev's hooks, rules, or config to NovaBeat, MediaCleanup, etc.

## Usage

```
/repo-updatecore           # pull from gpg-development into home-dev
/repo-updatecore push      # push home-dev config to child repos
```

## Pull Direction (default)

### Source

`C:\Repo\_RepoWork\gpg-development` — if absent, ask the user where it is or skip.

### What to Consider Pulling (review manually, don't auto-copy everything)

Unlike child repos which get full wrappers, home-dev reviews gpg-development's skills and selectively adopts improvements. Work-specific content (ouvvi, fabric, monday, IIS, TSC server names, D:\Repo paths) is never brought over.

**Hook files** — highest priority. These are the security and access control foundation:
- `.claude/hooks/guard-destructive.sh`
- `.claude/hooks/guard-sql-destructive.sh`
- `.claude/hooks/guard-protected-paths.sh`
- `.claude/hooks/pre-compact.sh`
- `.claude/hooks/update-frontmatter-date.sh`

After copying hooks, adapt: replace "gpg-development not found" with "home-dev not found" in warning messages.

**Session skills** — compare gpg-development's full skill files against home-dev's:
- `skills/session-start/SKILL.md`
- `skills/session-sync/SKILL.md`
- `skills/session-wrap/SKILL.md`
- `skills/compound/SKILL.md`
- `skills/repo-selfcheck/SKILL.md`

After copying skills, adapt memory paths: `memory/users/{username}/` becomes `.claude/memory/`, remove multi-user sections.

**Rules** — compare and selectively adopt:
- `.claude/rules/formatting-rules.md`
- `.claude/rules/memory-rules.md`
- `.claude/rules/references-rules.md`
- `.claude/rules/access-control-immutable.md`

**NOT pulled** (home-dev specific, never overwrite from gpg-development):
- `guards.conf` — home-dev has its own with `C:\Repo` fence and `admin = home-dev`
- `server-aliases.conf` — home-dev uses `SQL = localhost`, not work servers
- `db-access.conf` — per-repo
- `folder-access.conf` — per-repo
- Work-specific skills (ouvvi, fabric, IIS, console-app templates with D:\Repo paths)

### Pull Workflow

1. **Detect source** — confirm `C:\Repo\_RepoWork\gpg-development` exists. Prompt if absent.

2. **Pull latest in source** — `git -C C:\Repo\_RepoWork\gpg-development pull`

3. **Dry run** — diff each manifest file. Show summary table:
   ```
   | File | Status |
   |------|--------|
   | .claude/hooks/guard-destructive.sh | Changed (8 lines differ) |
   | skills/session-wrap/SKILL.md | No changes |
   ```
   For changed files, show the diff.

4. **Ask for confirmation** — "Apply these updates? (yes / pick which / skip)"

5. **Copy approved files** — adapt work-specific content (D:\Repo becomes C:\Repo, TSC servers become localhost, "gpg-development" becomes "home-dev" in warning strings).

6. **Commit with `core:` prefix:**
   ```
   core: updated hooks and session skills from gpg-development
   ```

7. **Push** — `git push`

## Push Direction (`/repo-updatecore push`)

Propagates home-dev's current rules, settings template, and core session skills to child repos under `C:\Repo`.

### Key Architecture Point

Child repos reference home-dev's hooks via relative paths — they do NOT have local hook copies. The push operation verifies their `settings.json` is pointing correctly and propagates updated rule files and core session skills.

**Drift check (every push run):** flag any child repo with a local `.claude/hooks/` directory, or a local `guards.conf`/`server-aliases.conf` — these must be global-only in home-dev. If found, this is drift: the local copies go stale (missing `[protected-paths]`/`[repo-fence]` sections added later, for example) since nothing keeps them in sync. Migrate by deleting the local copies and repointing `settings.json` hook commands from `bash .claude/hooks/X.sh` to `bash ../home-dev/.claude/hooks/X.sh` (2026-07-13: discovered 7 of 8 affected repos had a `guards.conf` missing `[protected-paths]` entirely, meaning the access-control-immutable protection wasn't actually enforced there).

**Session skills are pushed now (2026-07-11+).** Earlier this only propagated rules/settings, never `skills/*.md` — when home-dev's `session-start/SKILL.md` was fixed to stop auto-diffing core files on every `/start` (token cost), every child repo kept the old, still-firing copy because nothing ever pushed skill files to them. That required an ad hoc 14-repo file-copy sweep instead of a normal `/repo-updatecore push` run. The Session Skills list below closes that gap.

### What to Push to Child Repos

**Verify `settings.json` hook paths** — each child's `settings.json` should reference `../home-dev/.claude/hooks/`. If a child has a local `.claude/hooks/` directory, that is drift — flag it.

**Verify `statusLine`** — each child's `settings.json` should have a top-level `statusLine` block referencing `../home-dev/.claude/hooks/statusline.sh` (same relative-path pattern as the hooks above, since statusline.sh is generic and repo-agnostic):
```json
"statusLine": {
  "type": "command",
  "command": "bash ../home-dev/.claude/hooks/statusline.sh"
}
```
If missing, add it as a merge into the existing `settings.json` (don't touch the `hooks` block). If a child has no `settings.json` at all, or no `.claude/` directory at all, flag it and ask before creating anything — don't silently scaffold a repo that was never fully set up via `/project-new`.

**Verify `.gitignore` has `temp/`** — `temp/` is transient session/build-drop scratch space, never meant to be tracked. If missing from a child's `.gitignore`, add it as its own line (don't reorganize the rest of the file). A missing entry here isn't cosmetic — it's how StreamVault ended up with two >90MB binaries in an unpushed commit history that blocked pushing entirely (2026-07-11 incident).

**Rules to propagate** (copy to any child repo that has the file):
- `.claude/rules/formatting-rules.md`
- `.claude/rules/memory-scoping-rules.md`
- `.claude/rules/memory-rules.md`
- `.claude/rules/references-rules.md`
- `.claude/rules/access-control-immutable.md`

**Conditional rules** (only if file exists in child — never recreate deleted files):
- `.claude/rules/start-auto-clear.md`
- `.claude/rules/wrap-auto-clear.md`

**Session skills to propagate** (same list as Pull Direction's Session skills; copy only to child repos that already have the file — never create a skill a repo never had, e.g. AdHoc has no `session-start`):
- `skills/session-start/SKILL.md`
- `skills/session-sync/SKILL.md`
- `skills/session-wrap/SKILL.md`
- `skills/compound/SKILL.md`
- `skills/repo-selfcheck/SKILL.md`
- `skills/memory-archive/SKILL.md` (2026-07-13+ — push to any child repo whose memory/digest volume has grown enough to need it; unlike the others, don't force this onto every repo automatically, ask first since not all children need it yet)

Push these as-is — no adaptation needed. Unlike the pull direction (home-dev selectively adopts from gpg-development and adapts memory paths), home-dev's own session skills are already child-repo-generic; they were written to run correctly in any repo, home-dev included, keyed off runtime checks like "if the current repo is NOT home-dev" rather than build-time differences.

**NOT pushed** (per-repo, global-only, or child-specific):
- `db-access.conf`, `folder-access.conf` — per-repo
- `guards.conf`, `server-aliases.conf` — global, live only in home-dev
- Hook scripts — child repos don't have local copies
- Domain skills (`console-app`, `web-app`, `database-ddl`, `database-admin`, etc.) — child-specific, not part of the core session-lifecycle set

### Push Workflow

1. **List child repos** — find all repos at the top level of `C:\Repo` (not inside `_RepoWork`, `_RepoDeprecated`, or `_RepoTemp` — see CLAUDE.md Repo Folder Taxonomy) that have `.claude/` but are NOT `home-dev` or `open-design`. Work-family repos (gpg-development, persona-creator, DataDictionary, WarehouseMerge, etc.) live under `_RepoWork\` and are out of scan scope entirely.

2. **Dry run** — diff rule files AND session skill files (where present in the child) between home-dev and each child. Show summary per child.

3. **Ask for confirmation** per child repo or globally.

4. **Copy approved files** — create target directories if needed.

5. **Commit in each child** with `core: updated rules and skills from home-dev` (or `core: updated rules from home-dev` if no skill files changed) and push.

## Rules

- ALWAYS show diffs before copying — never blindly overwrite
- ALWAYS commit with `core:` prefix so `/start` can detect it
- NEVER copy work-specific content (ouvvi, fabric, IIS, TSC server names, D:\Repo paths)
- NEVER copy `db-access.conf`, `folder-access.conf`, `guards.conf`, or `server-aliases.conf`
- NEVER run automatically — admin-initiated only
- If a file exists in the manifest but NOT in the target, ask before creating it
- If adapting copied content, show the adapted version to the user before committing
- After editing any Session skill file in home-dev (session-start, session-sync, session-wrap, compound, repo-selfcheck), proactively ask the user whether to run `/repo-updatecore push` in the same session — don't let home-dev and child repos silently diverge. (2026-07-11: exactly this gap caused a same-day 14-repo phone-home incident.)
