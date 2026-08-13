---
name: session-wrap
description: "Close a work session: write digest, update memory, commit everything, push. Use when the user says '/wrap', 'wrap up', 'end of session', 'done for today', 'write a digest', 'session summary', 'log this session', 'save progress and close', 'sign off', or before ending a conversation. Generates session digest from conversation context, reconciles Roadmap/ROADMAP.md and open-threads, updates the changelog only if something shipped, stages all changes, commits, and pushes. Supersedes session-digest in this vault."
categories:
  - session-lifecycle
  - git-transport
  - memory-management
tags:
  - wrap
  - digest
  - session-end
  - commit
  - push
summary: "Session closer that generates digest, updates all memory files, then commits and pushes everything to remote. Runs with auto-execution and a single end-of-run summary block."
source: home-dev
---

# Session Wrap

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/session-wrap/SKILL.md` in the context of THIS repo.
