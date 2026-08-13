#!/bin/bash
# statusline.sh - renders the Claude Code status line footer.
# Reads the status JSON Claude Code passes on stdin.

INPUT=$(cat)

# context_window: this conversation's token usage (context fill %).
# rate_limits.five_hour: subscription "session" usage window - the closest
#   analog to a daily figure Claude Code exposes (resets every 5h, not once/day).
# rate_limits.seven_day: subscription weekly usage window.
# rate_limits.* is only present on Claude.ai subscription plans, not API billing.
IFS='|' read -r MODEL CTX_PCT FIVE_PCT FIVE_RESET WEEK_PCT WEEK_RESET < <(echo "$INPUT" | python -c "
import sys, json
from datetime import datetime

d = json.load(sys.stdin)
model = d.get('model', {}).get('display_name', 'unknown')

ctx = d.get('context_window') or {}
ctx_pct = ctx.get('used_percentage', '')
ctx_s = f'{ctx_pct:.0f}' if isinstance(ctx_pct, (int, float)) else ''

rl = d.get('rate_limits') or {}
five = rl.get('five_hour') or {}
week = rl.get('seven_day') or {}

five_pct = five.get('used_percentage', '')
five_s = f'{five_pct:.0f}' if isinstance(five_pct, (int, float)) else ''

def fmt_reset(val, with_day=False):
    if not val:
        return ''
    try:
        if isinstance(val, (int, float)):
            dt = datetime.fromtimestamp(val).astimezone()
        else:
            dt = datetime.fromisoformat(str(val).replace('Z', '+00:00')).astimezone()
        time_s = dt.strftime('%I:%M%p').lstrip('0').lower()
        if with_day and dt.date() != datetime.now().astimezone().date():
            return f\"{dt.strftime('%a')} {time_s}\"
        return time_s
    except Exception:
        return ''

reset_s = fmt_reset(five.get('resets_at', ''))

week_pct = week.get('used_percentage', '')
week_s = f'{week_pct:.0f}' if isinstance(week_pct, (int, float)) else ''
week_reset_s = fmt_reset(week.get('resets_at', ''), with_day=True)

print(f'{model}|{ctx_s}|{five_s}|{reset_s}|{week_s}|{week_reset_s}')
" 2>/dev/null | tr -d '\r')

[ -z "$MODEL" ] && MODEL="unknown"

USAGE=""
[ -n "$CTX_PCT" ] && USAGE="ctx:${CTX_PCT}%"

if [ -n "$FIVE_PCT" ]; then
  SEG="5h:${FIVE_PCT}%"
  [ -n "$FIVE_RESET" ] && SEG="$SEG (resets ${FIVE_RESET})"
  if [ -n "$USAGE" ]; then USAGE="$USAGE | $SEG"; else USAGE="$SEG"; fi
fi

if [ -n "$WEEK_PCT" ]; then
  SEG="7d:${WEEK_PCT}%"
  [ -n "$WEEK_RESET" ] && SEG="$SEG (resets ${WEEK_RESET})"
  if [ -n "$USAGE" ]; then USAGE="$USAGE | $SEG"; else USAGE="$SEG"; fi
fi

REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
[ -z "$REPO_NAME" ] && REPO_NAME=$(basename "$PWD")

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  BRANCH="${BRANCH}*"
fi

LINE="[$REPO_NAME] $MODEL"
[ -n "$USAGE" ] && LINE="$LINE | $USAGE"
[ -n "$BRANCH" ] && LINE="$LINE | $BRANCH"

echo "$LINE"
