---
name: repo-selfcheck
description: >
  Audit the repo's own Claude harness configuration for drift, contradictions, and staleness.
  Use when the user says '/repo-selfcheck', 'check yourself', 'audit your config', 'something feels off',
  'are your skills up to date', 'check for drift', or 'validate your setup'. Spawns a subagent to
  scan CLAUDE.md, skills, references, rules, and memory for misalignment then reports findings.
categories:
  - workflow
  - maintenance
  - quality
tags:
  - audit
  - config
  - drift
  - repo-selfcheck
  - validation
summary: "On-demand audit of the repo's Claude harness — checks CLAUDE.md alignment, rules consistency, memory integrity, staleness, naming conventions, and orphan detection."
source: home-dev
---

# Self-Check Skill

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/repo-selfcheck/SKILL.md` in the context of THIS repo.
