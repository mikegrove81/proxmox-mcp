---
name: notes
description: "Process a repo's notes/ folder (punchlist, todos, ideas). Use when the user says '/notes', 'process the notes', 'process the punchlist', 'process 1-4', 'process todos 1-3', 'work the punch list', 'create a plan for idea #2', or otherwise names punchlist/todos/ideas items to act on. Executes and prunes actionable punchlist/todo items, routes ideas to plan-for-subagent, and annotates blocked items."
categories:
  - workflow
tags:
  - notes
  - punchlist
  - todos
  - ideas
  - process-notes
summary: "Per-repo notes processor: parses a bucket (punchlist/todos/ideas) plus a range, executes and prunes punchlist/todo items with prune-on-success, routes ideas to plan-for-subagent, and annotates blocked items in place."
source: home-dev
---

# Notes

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/notes/SKILL.md` in the context of THIS repo.
