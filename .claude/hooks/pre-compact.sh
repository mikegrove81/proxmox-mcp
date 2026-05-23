#!/bin/bash
# pre-compact.sh — PreCompact hook
# Captures working state before conversation compaction so critical context
# survives the compression. Output from this script is preserved in the
# compacted conversation.

echo "=== PRE-COMPACT: ACTIVE WORKING STATE ==="
echo ""

if [ -f ".claude/memory/working-state.md" ]; then
  echo "--- WORKING STATE ---"
  awk '/^---$/{n++; next} n>=2' ".claude/memory/working-state.md"
  echo ""
fi

echo "=== PRE-COMPACT: OPEN THREADS (ACTIVE ONLY) ==="
echo ""

if [ -f ".claude/memory/open-threads.md" ]; then
  awk '/^## Active/{found=1; next} /^## /{if(found) exit} found' ".claude/memory/open-threads.md"
fi

echo ""
echo "=== PRE-COMPACT: REMINDERS ==="
echo "- Curated memory (.claude/memory/) is authoritative. Do not rely on pre-compaction conversation for facts."
echo "- Run Session Start Sequence if memory context feels incomplete."
