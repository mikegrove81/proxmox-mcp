---
name: compound
description: >
  Promote learnings into the orchestration layer — skills, references, CLAUDE.md — so
  behavior actually changes. Memory is a fallback for user-specific facts that
  don't generalize. Use when the user says "compound this", "what did we learn", "that worked
  well", "save that pattern", "remember this for next time", "what patterns are we seeing",
  or after completing any significant code delivery, architecture decision, or multi-file change.
  Also triggers when the user notes an outcome — "that worked", "that broke in prod", "that
  approach was wrong".
categories:
  - memory-management
  - learning
  - orchestration
summary: "Disposition-first learning capture. Each learning is routed to a skill update, reference update, CLAUDE.md edit, or memory entry — defaulting to orchestration so behavior changes. Audit log in memory/learnings/_log.md."
---

# Compound Learning Skill

After completing a deliverable, identify what was learned — then **promote the learning into the orchestration layer** so the next session benefits automatically. Memory is a fallback, not the default.

This is semi-autonomous: Claude proposes the learning AND its target file with a concrete diff. The user approves, edits, or rejects. Only on approval does Claude make the file change. The propose-then-approve gate is preserved; the leverage point shifts from "what frontmatter to give the memory file" to "where in orchestration this learning lands."

## Why Disposition-First

Memory doesn't reliably get scanned mid-task — a learning there sits hoping Claude finds it. A learning in a SKILL.md changes behavior next session, automatically. That's the difference between accumulating and compounding.

## When to Use This

**Explicit triggers:** "compound this", "what did we learn", "save that pattern", "that worked well/didn't work", "that broke in prod", "what patterns are we seeing".

**Implicit triggers (offer, don't force):** after a significant code delivery, architecture decision, or multi-file change, after a significant outcome, after a deliverable goes through revision (the delta IS the learning).

**Do NOT self-trigger:** session digests and working-state updates (session-wrap handles those), quick factual exchanges under ~100 words, or when the user says "skip".

**Auto-call from `/wrap`:** session-wrap calls this skill as a step when session markers fire (orchestration edits, multi-file changes, explicit "save that" phrases) — see session-wrap SKILL.md step 3. The propose-approve gate preserves user control: each proposal shows its budget line and the user approves, edits, redirects, or skips. Compound's resulting file edits get bundled into the wrap commit.

## Stakes Classification (gate before disposition)

- **Low** — quick answers, minor file edits, single stored procedure fix → skip unless explicitly asked
- **Medium** (default) — single component build, routine ETL pattern, configuration change → run full workflow on one learning
- **High** — full project scaffolding, complex architecture decision, multi-component ETL pipeline, production incident resolution → run full workflow on each distinct learning; may produce multiple file edits

If a session produced no novel learning, say so and stop. Capturing nothing is a valid outcome.

## Workflow

### Phase 1 — Identify the Learning Moment

Sources: success pattern, failure/revision (the delta IS the lesson), preference discovery, template extraction.

### Phase 2 — Extract the Learning

For each: one-sentence takeaway, context, the insight, when to apply, confidence (High/Medium/Low). Push for specificity — "Code should handle errors" is useless. "Vendor X returns HTML error pages instead of JSON on 500s — always check Content-Type before deserializing" is useful.

### Phase 3 — Disposition Decision (the key step)

For each learning, classify the disposition. Walk through these in order — stop at the first one that fits:

| Disposition | Use when | Target |
|---|---|---|
| **Skill update** | Learning changes how a workflow runs | Edit relevant `skills/{skill}/SKILL.md` |
| **Reference update** | Learning changes a documented fact, framework, or convention | Edit relevant `references/{file}.md` |
| **New reference file** | Learning is reusable across many tasks but no existing reference fits | Create new `references/` file with frontmatter |
| **CLAUDE.md update** | Learning fundamentally affects all sessions in this vault (rare) | Edit `CLAUDE.md` |
| **Memory entry** | Learning is user-specific and doesn't generalize | Write to `memory/learnings/` as individual file |
| **Audit-only** | Interesting but not actionable in any file | Log only, no file change |

**Default to Skill update or Reference update.** Memory is the fallback. Before writing memory, ask explicitly: "Could this go in a skill or reference instead?"

**Check for existing learnings first.** Scan `memory/learnings/` for existing learnings in the same category. If a similar learning exists:
- **Reinforce it** — update the existing file's confidence level and add context
- **Refine it** — update the insight with new nuance
- **Contradict it** — flag both to the user. Don't silently overwrite.

### Phase 4 — Propose to User (with budget gate)

**Step 4a — Budget check.** Before showing the diff, compute target file post-edit word count. Apply ceilings: **SKILL.md = 1,500 words; reference = 2,000; CLAUDE.md = 1,500.** Memory and audit-only dispositions skip the gate.

If post-edit exceeds the ceiling, **redirect** instead of proposing:
- **Skill update over ceiling** → New reference file + one-line pointer in the skill.
- **Reference update over ceiling** → Split into sub-references, OR trim older sections, then add.
- **CLAUDE.md update over ceiling** → New reference file + pointer in CLAUDE.md.

**Step 4b — Present the proposal.** Show each learning with the budget line visible at decision time:

```
LEARNING: [takeaway]
CONFIDENCE: [High | Medium | Low]
DISPOSITION: [type]
TARGET FILE: [path]
BUDGET: [current] → [post-edit] / [ceiling] (under | OVER by N)
PROPOSED DIFF:
[exact text]
```

When redirected, show both: original target's budget overflow AND the redirected proposal (new file path + pointer text + content).

Show all learnings together for High-stakes sessions; inline for Medium. The user approves, edits, redirects, or rejects. This is the curation gate — do not skip the diff or the budget line.

### Phase 5 — Apply on Approval

For each approved learning:
1. Make the file edit using Edit tool (or Write for new files)
2. If the target file's frontmatter has `updated:`, bump the date
3. Confirm the change landed

### Phase 6 — Audit Log

Append a single line to `memory/learnings/_log.md` per applied learning:

```
2026-05-06 | Skill update | skills/database-ddl/SKILL.md | Added SCHEMABINDING QUOTED_IDENTIFIER check
2026-05-06 | Reference update | references/etl-patterns.md | Added retry wrapper pattern for paginated APIs
2026-05-06 | Memory | memory/learnings/etl-retry.md | Vendor X rate limit at 100/min
2026-05-06 | Audit-only | (no file change) | PowerShell test harness approach for WebForms
```

This is the only thing written to memory under the new model for orchestration dispositions. It's an append-only audit trail, not a substitute for the skill/reference edits.

### Phase 7 — Surface Prior Learnings (at task start, not session end)

When starting any deliverable, scan recent `_log.md` entries (last ~20 lines or last 30 days) for patterns relevant to the current task. Flag any that apply:

> "Recent learnings that apply here: [list]. The relevant skill/reference has already been updated — proceeding with current orchestration."

If a `_log.md` entry exists for a pattern but Claude is about to repeat the old behavior anyway, that's a flag — the orchestration update may not have actually taken effect. Surface this to the user.

## Synthesis Mode

When the user asks "what patterns are we seeing" or enough learnings accumulate (10+ in a category), run a synthesis pass:

1. Read all learnings in the requested category (or all categories if unspecified)
2. Cluster by theme — which learnings reinforce each other?
3. Identify contradictions — which learnings conflict?
4. Propose promotions — which learnings are High confidence and recurring enough to become:
   - A reference file update (e.g., new pattern in a reference file)
   - A skill update (e.g., new gotcha in a domain skill's Common Pitfalls)
   - A decision (e.g., "we always do X now" → `memory/decisions.md`)
5. Present the synthesis to the user. They decide what gets promoted.
6. Flag learnings older than 90 days during synthesis — the user can archive or update.

Synthesis promotions follow the same propose-approve gate as regular dispositions.

## Memory Entry Format (for memory-disposition learnings only)

```yaml
---
name: {category}-{brief-descriptor}-{YYYY-MM-DD}
type: memory
updated: {today}
categories:
  - {category}
tags:
  - {relevant tags}
scope: mikegrove81
summary: "{one-sentence takeaway}"
---
```

```markdown
## Context
[What task produced this learning]

## The Insight
[The actual insight. Specific enough to act on.]

## When to Apply
[Specific future situations where this learning is relevant]

## Confidence
[HIGH / MEDIUM / LOW]
```

**Filename convention:** `{category}-{brief-descriptor}-{YYYY-MM-DD}.md`

## Common Pitfalls

- **Memory-by-default.** Memory is the fallback. If a learning ends up there, the disposition step must justify why it doesn't fit a skill or reference.
- **Vague proposals.** "I'll update database-ddl" without showing the diff is a bypass. Show the exact text.
- **Compounding everything.** Stakes Classification gates this. If the session produced no novel learning, capture nothing.
- **Generic learnings.** "Code should handle errors" teaches nothing. Be specific.
- **Skipping the audit log.** Even "audit-only" dispositions get a line in `_log.md`. Entries without a corresponding file edit are still valid.
- **Stale patterns.** If `_log.md` shows three entries on the same pattern targeting the same file, the file edit isn't holding — investigate why.

## Interface

### Expects
- A completed deliverable or explicit user trigger
- Access to `skills/`, `references/`, `CLAUDE.md`, and `memory/learnings/`

### Produces
- One or more orchestration-layer file edits (skill, reference, CLAUDE.md, or memory)
- One or more lines appended to `memory/learnings/_log.md`
- Behavior change visible in the next session

> **Done.** Learning(s) promoted into orchestration. Run `/sync` to save progress, or `/wrap` if this was your last task.
