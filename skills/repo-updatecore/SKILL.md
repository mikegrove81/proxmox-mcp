---
name: repo-updatecore
description: "Pull core skill and config updates from home-dev into THIS child repo. Use when the user says '/repo-updatecore', 'update core skills', 'sync from upstream', or 'pull upstream changes'. Runs only in child repos - pulls wrapper stubs, rules, and repo-root files from home-dev and commits with a core: prefix. To push config from home-dev to ALL children, use /fleet-push; to pull home-dev's own upstream (gpg-development), use /sync-from-gpg."
categories:
  - workflow
  - maintenance
tags:
  - update
  - upstream
  - core-skills
summary: "Pulls core session/workflow wrapper stubs and rules from home-dev into the current child repo. home-dev is the top of the child update chain; fleet-push distributes to all children, repo-updatecore pulls into one."
source: home-dev
---

# Update Core Skill

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/repo-updatecore/SKILL.md` in the context of THIS repo.
