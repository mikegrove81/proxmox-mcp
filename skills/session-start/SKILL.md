---
name: session-start
description: "Open a work session by syncing git state and loading context. Use when the user says '/start', 'start session', 'open session', 'begin session', 'pick up where I left off', or at the start of any new conversation. Pulls remote changes, detects uncommitted local work, resolves trivial merge conflicts, then runs the full Session Start Sequence."
categories:
  - session-lifecycle
  - git-transport
tags:
  - start
  - pull
  - sync
  - session-open
summary: "Session opener that syncs local git state with remote, then runs the Session Start Sequence from CLAUDE.md."
source: home-dev
---

# Session Start

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/session-start/SKILL.md` in the context of THIS repo.
