---
name: repo-memory-archive
description: >
  Consolidate old session digests into condensed monthly archive summaries so
  .claude/memory/digests/ doesn't grow unbounded. Use when the user says
  '/repo-memory-archive', 'archive old digests', 'clean up memory', 'digests are piling
  up', or when repo-selfcheck flags the digests folder has grown past its threshold.
  Never touches digests less than 30 days old.
categories:
  - workflow
  - maintenance
  - memory-management
tags:
  - memory
  - archive
  - digest
  - consolidation
summary: "Rolls up session digests older than 30 days into one condensed archive file per month, deleting the originals (recoverable via git history)."
source: home-dev
---

# Memory Archive Skill

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/repo-memory-archive/SKILL.md` in the context of THIS repo.
