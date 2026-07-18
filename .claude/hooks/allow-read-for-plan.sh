#!/bin/bash
# Allow Read tool operations for subagents executing plans.
# Reads are non-destructive, so subagents need full folder access to explore
# and understand the project structure during plan execution.

# Always auto-allow reads - they're read-only and necessary for plan execution
# to discover what's in the working directory.
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Read operations auto-allowed for subagent plan execution (read-only, non-destructive)"
  }
}'

