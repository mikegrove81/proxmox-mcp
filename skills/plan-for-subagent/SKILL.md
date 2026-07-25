---
name: plan-for-subagent
description: "Use when you need a detailed, hands-off execution plan broken into small, independently-testable deliverables. Identifies natural breakpoints (features, components, or dependency groups) and emits one small plan per deliverable, allowing iterative testing without token burn. Auto-escalates to Opus mid-planning if complexity exceeds current reasoning. Executor agents follow plans literally with zero improvisation."
categories:
  - workflow
  - planning
tags:
  - plan-for-subagent
  - planner-executor
  - hand-off
  - runbook
  - multi-agent
  - adaptive-escalation
summary: "Any Claude model acts as Planner: interactive discovery, explicit approval gate, self-audit, then emits a zero-assumption Execution Plan(s). If mid-planning complexity requires a stronger model, escalates hands-free to Opus. Spawns one or more executor agents (Haiku → Sonnet as appropriate), executes in parallel/series, hands-free."
source: home-dev
---

# Plan for Subagent — Adaptive Multi-Model Planner → Multi-Agent Executor

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/plan-for-subagent/SKILL.md` in the context of THIS repo.
