---
name: update-core
description: "Pull core skill updates into this repo from an upstream source repo. Use when the user says '/update-core', 'update core skills', 'sync from upstream', 'pull upstream changes'. Copies core session skill files and guard hooks, shows diffs, and commits with a core: prefix."
categories:
  - workflow
  - maintenance
tags:
  - update
  - upstream
  - core-skills
summary: "Syncs core session/workflow skills and guard hooks from an upstream repo into this repo. Shows diffs, asks confirmation, commits with core: prefix."
---

# Update Core Skill

## Purpose

Pulls core skill and template updates into this repo from an upstream source repo.

home-dev is the upstream source for personal child repos. Running this skill in a child repo pulls updates from home-dev. Running it in home-dev itself requires the user to specify an upstream source path.

## Usage

```
/update-core
/update-core C:\path\to\upstream
```

## Source Resolution

1. If an argument is provided, use that path as the source.
2. Detect current repo: run `git rev-parse --show-toplevel`.
3. If current repo is home-dev (`C:\Repo\home-dev`):
   - Default source: `C:\Repo\gpg-development`
   - If gpg-development doesn't exist there, prompt for source path.
4. For all other repos (home-dev children):
   - Default source: `C:\Repo\home-dev`
   - Confirm home-dev exists; if not, prompt for source path.

## Core File Manifest

These are the files that flow downstream. **Only these files are copied.** Everything else in this repo is instance-specific and untouched.

### Skills (copy SKILL.md only)

| Source path | Target path |
|-------------|-------------|
| `skills/session-start/SKILL.md` | `skills/session-start/SKILL.md` |
| `skills/session-sync/SKILL.md` | `skills/session-sync/SKILL.md` |
| `skills/session-wrap/SKILL.md` | `skills/session-wrap/SKILL.md` |
| `skills/session-digest/SKILL.md` | `skills/session-digest/SKILL.md` |
| `skills/compound/SKILL.md` | `skills/compound/SKILL.md` |
| `skills/update-core/SKILL.md` | `skills/update-core/SKILL.md` |

### Commands (always copy)

| Source path | Target path |
|-------------|-------------|
| `.claude/commands/start.md` | `.claude/commands/start.md` |
| `.claude/commands/sync.md` | `.claude/commands/sync.md` |
| `.claude/commands/wrap.md` | `.claude/commands/wrap.md` |
| `.claude/commands/compound.md` | `.claude/commands/compound.md` |
| `.claude/commands/update-core.md` | `.claude/commands/update-core.md` |
| `.claude/commands/new-project.md` | `.claude/commands/new-project.md` |
| `.claude/commands/graduate-project.md` | `.claude/commands/graduate-project.md` |

### Templates (copy if they exist in target)

| Source path | Target path |
|-------------|-------------|
| `_templates/template-memory.md` | `_templates/template-memory.md` |
| `_templates/template-working-state.md` | `_templates/template-working-state.md` |
| `_templates/template-session-digest.md` | `_templates/template-session-digest.md` |
| `_templates/template-skill.md` | `_templates/template-skill.md` |

### Rules (always copy)

| Source path | Target path |
|-------------|-------------|
| `.claude/rules/formatting-rules.md` | `.claude/rules/formatting-rules.md` |
| `.claude/rules/memory-scoping-rules.md` | `.claude/rules/memory-scoping-rules.md` |

### Rules (conditional copy -- do NOT recreate if deleted in target)

Child repos may delete these files to opt out. Once deleted, update-core will not recreate them.

| Source path | Target path |
|-------------|-------------|
| `.claude/rules/start-auto-clear.md` | `.claude/rules/start-auto-clear.md` |
| `.claude/rules/wrap-auto-clear.md` | `.claude/rules/wrap-auto-clear.md` |

### Guard Hooks (always copy)

These enforce destructive-operation protection. Copy verbatim -- `db-aliases.conf` in this repo provides the correct server defaults, so no patching is needed.

| Source path | Target path |
|-------------|-------------|
| `.claude/hooks/guard-destructive.sh` | `.claude/hooks/guard-destructive.sh` |
| `.claude/hooks/guard-sql-destructive.sh` | `.claude/hooks/guard-sql-destructive.sh` |
| `.claude/guards.conf` | `.claude/guards.conf` |

**Do NOT copy:** `db-aliases.conf`, `db-access.conf`, `folder-access.conf` -- these are per-instance and managed locally.

### Rules (copy if they exist in both source and target)

Check for other `.claude/rules/` files in the source that also exist in the target. Copy matches only.

## Workflow

1. **Detect source** -- confirm source path exists. Display: "Updating from [source path]."

2. **Pull latest in source** -- run `git -C [source] pull` to ensure we're copying the latest.

3. **Dry run -- show what would change:**
   - For each file in the manifest, diff the source against the target
   - Show a summary table:
     ```
     | File | Status |
     |------|--------|
     | skills/session-start/SKILL.md | Changed (14 lines differ) |
     | skills/session-wrap/SKILL.md | No changes |
     | .claude/hooks/guard-destructive.sh | Changed (2 lines differ) |
     ```
   - For files that changed, show the diff
   - For conditional-copy files: skip if deleted in target (do not show as "missing")

4. **Ask for confirmation** -- "Apply these updates? (yes/no)"

5. **Copy the changed files** -- only files the user approved. Create target directories if needed.

6. **Mirror to user-level skills** -- for each skill file copied in step 5, also copy it to `C:\Users\mikeg\.claude\skills\{skill-name}\SKILL.md`. Create the directory if it doesn't exist. This keeps the global skills (available in all repos) in sync. Only mirror skill files -- not templates, rules, or hooks.

7. **Commit with `core:` prefix:**
   ```
   core: updated session skills from [source]

   Updated: session-start, compound, guard-destructive.sh
   ```

8. **Push** -- `git push` (only if repo is remote-backed)

9. **Report:**
   - Files updated in this repo
   - Files mirrored to `~/.claude/skills/`
   - Source used

## Rules

- ALWAYS show diffs before copying -- never blindly overwrite
- ALWAYS commit with `core:` prefix so `/start` can detect it
- NEVER copy non-manifest files -- domain skills, references, and memory are repo-specific
- NEVER run this automatically -- it's admin-initiated only
- NEVER copy `db-aliases.conf`, `db-access.conf`, or `folder-access.conf` -- these are per-instance
- NEVER recreate conditional-copy files that have been deleted in the target
- If a file exists in the manifest but NOT in the target repo, ask before creating it (it may have been intentionally removed)

## Patch Rules (applied after copy, before commit)

### session-start/SKILL.md
After copying from upstream, check if the source contains a step that auto-updates from a hardcoded upstream path. If found, remove it -- child repos use `/update-core` for this instead. Identify it as any step containing:
- A hardcoded source path reference
- `git -C [path] pull` with a hardcoded path
- auto-apply language referencing the upstream

Strip that entire step and renumber subsequent steps down by one.
