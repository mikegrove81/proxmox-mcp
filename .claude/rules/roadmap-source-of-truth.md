---
paths:
  - "Roadmap/**"
  - "notes/**"
---

# Roadmap Is the Single Source of Truth for "What's Next"

Three layers answer "what's raw," "what's planned," and "what shipped," per repo.
This file is the canonical definition; `repo-notes`, `plan-for-subagent`,
`/start`, `/sync`, and `/wrap` all defer to it. It replaces the retired
`working-state.md` as the answer to "what's next."

## Layers

| Layer | Lives in | Horizon | Role |
|-------|----------|---------|------|
| Notes | `notes/{ideas,punchlist,questions}.md` | raw / unprocessed | capture-as-you-go scratchpad |
| Roadmap | `Roadmap/ROADMAP.md` | future | the one consolidated list of planned work |
| Changelog | `Roadmap/CHANGELOG.md` | past | durable, plain-English record of what shipped |

Supporting folders under `Roadmap/`: `Specs/` (design briefs) and `Plans/`
(execution plans), each with an `Archive/` for shipped items.

**Scope is per-repo and covers THIS repo only** - the same boundary as
`memory-scoping-rules.md`. Child-project work belongs in that child's own
`Roadmap/`, never in a parent or admin repo's roadmap. home-dev's own
`Roadmap/` tracks harness/tooling work only.

## Invariants

- `notes/` holds ONLY unprocessed items. Once an item is processed it is
  DELETED from `notes/` - never annotated-and-kept (a genuinely-blocked item is
  the one exception; it stays with a `>> ` note).
- `Roadmap/ROADMAP.md` holds ONLY unshipped future work.
- `Roadmap/CHANGELOG.md` holds ONLY shipped past work.
- Nothing lives in two layers at once.
- A fully-cleared notes file is genuinely empty (0 bytes) - no header, no
  "(empty)" placeholder. This matches the existing notes convention.

## Flows

### Idea

1. Capture raw in `notes/ideas.md`.
2. **Process = graduate it:**
   - **Spec it.** Non-trivial -> write
     `Roadmap/Specs/<YYYY-MM-DD>-<slug>-design.md` (what / why / roughly how /
     dependencies / open decisions); brainstorm as needed. Trivial -> no spec
     file; a one-line scope on the roadmap is enough.
   - **Place it on `Roadmap/ROADMAP.md`** under the right bucket, with a
     `-> pointer` to the spec if one was written.
   - **DELETE the raw idea from `notes/ideas.md`.** The roadmap entry, not the
     raw line, is now the unit of planned work.
3. **Build it** (later, separate action): run `plan-for-subagent` against the
   spec -> writes `Roadmap/Plans/<YYYY-MM-DD>-<slug>.md` (roadmap-aware: checks
   dependencies / contradictions against Now / Next / Parked). Execute the plan.
4. **Ship it:** archive the spec + plan into `Roadmap/Specs/Archive/` and
   `Roadmap/Plans/Archive/`; move the roadmap item to Recently shipped (drop
   older ones); add a `Roadmap/CHANGELOG.md` entry.

### Punchlist

1. Capture the defect in `notes/punchlist.md`.
2. Fix it, verify it.
3. **DELETE it from `notes/punchlist.md`.**
4. Add a `Roadmap/CHANGELOG.md` entry. No roadmap round-trip.

If a "bug" turns out to be real work, promote it like an idea (spec + roadmap)
and prune the punchlist line.

### Questions

`notes/questions.md` is free-form and is NOT processed by any workflow. It stays
until you clear it yourself.

## ROADMAP.md structure

Buckets, top to bottom: **Now / Next / Parked-Blocked / Ideas-Someday /
Recently shipped / Won't do.**

- **Now** stays short - one or a few items actively being worked or immediately
  next. If everything is Now, nothing is.
- Item format: `**Title** - one line. [status/gate]. -> pointer`
- **Parked** items each name their trigger (what unblocks them).
- **Won't do** is a decision record, not a deletion - it preserves why something
  was dropped.
- Items flow Ideas -> Next -> Now as priorities firm, and out to the changelog
  on ship.

## CHANGELOG.md structure

- Reverse-chronological, newest date at the top.
- One `## YYYY-MM-DD` heading per day. Append bullets under today's heading if it
  already exists; create the heading (and the file) if not.
- Plain outcome-language, jargon-light - it reads for anyone, not just the
  author, and is safe to relay to non-technical stakeholders. Describe what is
  true now, not the mechanics of how it was built.
- **No ship, no entry.** An entry lands only when a roadmap item ships or a
  punchlist item is fixed - not on every wrap.

## Relationship to session memory

- `Roadmap/ROADMAP.md` replaces `working-state.md` as the answer to "what's
  next" - its **Now** bucket is loaded at session start and reconciled at
  `/wrap`. `working-state.md` is retired.
- Per-session digests remain the private, granular trail (SQL run, files
  touched, errors hit) in `.claude/memory/digests/`.
- `Roadmap/CHANGELOG.md` is the public distillation - one plain-English entry
  per shipped thing.
