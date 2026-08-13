---
name: repo-notes
description: "Process a repo's notes/ folder (punchlist, ideas). Use when the user says '/repo-notes', 'process the notes', 'process the punchlist', 'process 1-4', 'graduate idea #2', 'process ideas 1-4', or otherwise names punchlist/ideas items to act on. Fixes and prunes punchlist items (logging each fix to the changelog), and graduates ideas into the roadmap (spec + ROADMAP entry, deleting the raw idea). Defers to roadmap-source-of-truth.md for the notes -> roadmap -> changelog model."
categories:
  - workflow
tags:
  - notes
  - punchlist
  - ideas
  - process-notes
  - roadmap
summary: "Per-repo notes processor: fixes+prunes punchlist items and logs each to Roadmap/CHANGELOG.md; graduates ideas into Roadmap/ROADMAP.md (spec'ing non-trivial ones into Roadmap/Specs/) and deletes the raw idea. Processed items leave notes/ entirely; blocked items are annotated in place."
source: home-dev
---

# Notes

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/repo-notes/SKILL.md` in the context of THIS repo.
