# Wrap: Compound-Learning Gate

During /wrap, step 3 is a required compound check. Run it (with visible output) before step 4 (digest) so any compound edits land in the digest and commit. There is no human-approval pause.

## Gate Resolution

Check the session for these compound markers:
- [ ] File edits under `skills/`, `references/`, or `CLAUDE.md` — **in home-dev, skip this marker.** home-dev is the admin repo; touching skills/rules is routine here, not a signal. Rely on the other three markers instead. In a child repo this marker still applies as-is.
- [ ] More than 5 files changed this session
- [ ] User phrases: "save that", "compound this", "what did we learn", "that worked well"
- [ ] Significant code delivery, architecture decision, or production incident resolution

### Path A: Markers fire
State which markers fired, then run `/compound` inline. It auto-applies within budgets with no approval pause; its edits join the wrap commit and appear in the wrap summary. No human wait.

### Path B: No markers
State: **"Compound: no markers detected - skipping."** Then proceed to step 4.

### Path C: User skip
If user said "skip compound", "no compound", or "just wrap", state: **"Compound: skipped per user request."** Then proceed to step 4.

## Why This Exists

Claude tends to skip step 3 silently. Every path through this gate requires visible output so the user can verify the check happened.

Under auto-execution there is no approval pause on any path; the visible marker/skip line plus the end-of-run summary block are how the user verifies the check happened and reviews what compound did.

> **Note:** This rule mirrors session-wrap step 3 by design. If session-wrap step 3 content or step numbers change, update this file to match.
