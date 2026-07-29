---
name: github-code-reviewer
description: "Review a GitHub PR with surgical precision - flag only high-severity issues (bugs, security, performance, breaking changes) as succinct inline comments on specific lines, submitted via the GitHub API as COMMENT-only (never approve/reject). Skips style, nits, and minor improvements. Use when the user says '/gh-review', 'review PR <url or number>', or asks for a high-signal/low-noise pass on a pull request - distinct from the built-in review skill in that it actually posts inline comments to GitHub rather than just reporting findings in chat."
categories:
  - workflow
  - code-review
tags:
  - github
  - pull-request
  - code-review
  - gh-cli
summary: "Surgical GitHub PR review: fetches PR info/diff via gh CLI, reads surrounding code for context, flags only bugs/security/performance/breaking-change issues as 1-2 line inline comments, and submits them as a COMMENT-only review via the GitHub API. Never approves or requests changes - humans make that call."
source: home-dev
---

# GitHub Code Reviewer

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/github-code-reviewer/SKILL.md` in the context of THIS repo.
