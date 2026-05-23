#!/bin/bash
# guard-destructive.sh - PreToolUse hook for Bash commands
# Checks: sqlcmd access control, git destructive ops, filesystem destructive ops, SQL patterns.
# Exit 0 + JSON = deny or ask. Exit 0 + no output = allow.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"

INPUT=$(cat)
CMD=$(echo "$INPUT" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

# Nothing to check
[ -z "$CMD" ] && exit 0

# Normalize: strip path prefixes like /usr/bin/git -> git
NORM=$(echo "$CMD" | sed 's|/[^ ]*/||g')

# Convert to lowercase for matching
LC=$(echo "$NORM" | tr '[:upper:]' '[:lower:]')

# === SQLCMD ACCESS CONTROL ===
# If the command involves sqlcmd or Invoke-Sqlcmd, check access scope
if echo "$LC" | grep -qiE '\b(sqlcmd|invoke-sqlcmd|osql)\b'; then

  # Extract -S server and -d database flags
  SQLCMD_SERVER=$(echo "$CMD" | grep -oiE '(-S|--server|-ServerInstance)\s+[^ ]+' | head -1 | sed 's/^[^ ]* *//')
  SQLCMD_DB=$(echo "$CMD" | grep -oiE '(-d|--database|-Database)\s+[^ ]+' | head -1 | sed 's/^[^ ]* *//')

  # Resolve alias if server matches an alias
  if [ -n "$SQLCMD_SERVER" ]; then
    ALIASES_FILE="$CLAUDE_DIR/db-aliases.conf"
    if [ -f "$ALIASES_FILE" ]; then
      SRV_LC=$(echo "$SQLCMD_SERVER" | tr '[:upper:]' '[:lower:]')
      while IFS='=' read -r alias server; do
        [[ "$alias" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${alias// }" ]] && continue
        ALIAS_LC=$(echo "$alias" | tr '[:upper:]' '[:lower:]' | xargs)
        if [ "$SRV_LC" = "$ALIAS_LC" ]; then
          SQLCMD_SERVER=$(echo "$server" | xargs)
          break
        fi
      done < "$ALIASES_FILE"
    fi
  else
    # No -S flag: default to the SQL alias
    ALIASES_FILE="$CLAUDE_DIR/db-aliases.conf"
    if [ -f "$ALIASES_FILE" ]; then
      SQLCMD_SERVER=$(grep -iE '^[[:space:]]*SQL[[:space:]]*=' "$ALIASES_FILE" | head -1 | sed 's/^[^=]*=//' | xargs)
    fi
    [ -z "$SQLCMD_SERVER" ] && SQLCMD_SERVER="localhost"
  fi

  if [ -n "$SQLCMD_DB" ]; then
    DB_LC=$(echo "$SQLCMD_DB" | tr '[:upper:]' '[:lower:]')
    SERVER_LC=$(echo "$SQLCMD_SERVER" | tr '[:upper:]' '[:lower:]')

    # Check guards.conf deny
    GUARDS_FILE="$CLAUDE_DIR/guards.conf"
    if [ -f "$GUARDS_FILE" ]; then
      IN_DENY=0
      while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        [[ "$line" == "[database-deny]" ]] && IN_DENY=1 && continue
        [[ "$line" == "["* ]] && IN_DENY=0 && continue
        if [ "$IN_DENY" -eq 1 ]; then
          LINE_LC=$(echo "$line" | tr '[:upper:]' '[:lower:]' | xargs)
          if [ "$DB_LC" = "$LINE_LC" ]; then
            echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $SQLCMD_DB is a system database. Output a script and run it in SSMS.\"}}"
            exit 0
          fi
        fi
      done < "$GUARDS_FILE"
    fi

    # Check db-access.conf
    ACCESS_FILE="$CLAUDE_DIR/db-access.conf"
    if [ ! -f "$ACCESS_FILE" ]; then
      echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: No db-access.conf found. Create .claude/db-access.conf with: sql: $SQLCMD_SERVER/$SQLCMD_DB = read|write\"}}"
      exit 0
    fi

    ACCESS_LEVEL=""
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${line// }" ]] && continue
      if [[ "$line" =~ ^[[:space:]]*sql:[[:space:]]*(.+)/(.+)[[:space:]]*=[[:space:]]*(read|write)[[:space:]]*$ ]]; then
        CONF_SERVER=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]' | xargs)
        CONF_DB=$(echo "${BASH_REMATCH[2]}" | tr '[:upper:]' '[:lower:]' | xargs)
        CONF_LEVEL=$(echo "${BASH_REMATCH[3]}" | tr '[:upper:]' '[:lower:]' | xargs)
        if [ "$SERVER_LC" = "$CONF_SERVER" ] && [ "$DB_LC" = "$CONF_DB" ]; then
          ACCESS_LEVEL="$CONF_LEVEL"
          break
        fi
      fi
    done < "$ACCESS_FILE"

    if [ -z "$ACCESS_LEVEL" ]; then
      echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $SQLCMD_SERVER/$SQLCMD_DB is not in this repo's access scope. Add to .claude/db-access.conf: sql: $SQLCMD_SERVER/$SQLCMD_DB = read|write\"}}"
      exit 0
    fi

    # Read-only check: if access is read, check if the SQL is SELECT-only
    if [ "$ACCESS_LEVEL" = "read" ]; then
      # Extract -Q inline query or assume write if using -i (input file)
      if echo "$LC" | grep -qiE '\s-q\s'; then
        # Has inline query - check if it's SELECT-only
        if ! echo "$LC" | grep -qiE '\b(select|with)\b' || echo "$LC" | grep -qiE '\b(insert|update|delete|create|alter|drop|truncate|exec|execute)\b'; then
          echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $SQLCMD_SERVER/$SQLCMD_DB is read-only in this repo. Only SELECT queries allowed.\"}}"
          exit 0
        fi
      elif echo "$LC" | grep -qiE '\s-i\s'; then
        # Input file - can't inspect, block writes on read-only DBs
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"CONFIRM: $SQLCMD_SERVER/$SQLCMD_DB is read-only. sqlcmd -i runs a script file - verify it's SELECT-only.\"}}"
        exit 0
      fi
    fi
  fi
  # sqlcmd access checks done - fall through to destructive pattern checks
fi

# === SAFE PATTERNS (allowlist - check first) ===
# git checkout -b (branch creation)
echo "$LC" | grep -qiE 'git\s+checkout\s+-b\b' && exit 0
# git checkout --orphan
echo "$LC" | grep -qiE 'git\s+checkout\s+--orphan' && exit 0
# git clean dry run
echo "$LC" | grep -qiE 'git\s+clean\s+.*(-n|--dry-run)' && exit 0
# rm -rf on temp/build dirs only
echo "$LC" | grep -qiE 'rm\s+-(rf|fr)\s+(bin|obj|temp|\.vs|node_modules|/tmp|/var/tmp)' && exit 0

# === BLOCK PATTERNS ===
REASON=""

# git reset --hard or --merge
echo "$LC" | grep -qiE 'git\s+reset\s+--(hard|merge)' && REASON="git reset --hard/--merge discards commits and working changes"

# git push --force or -f (but not --force-with-lease)
if [ -z "$REASON" ]; then
  if echo "$LC" | grep -qiE 'git\s+push\s+.*(-f\b|--force)'; then
    echo "$LC" | grep -qiE 'force-with-lease' || REASON="git push --force can overwrite remote history"
  fi
fi

# git branch -D (force delete)
[ -z "$REASON" ] && echo "$LC" | grep -qiE 'git\s+branch\s+.*-D' && REASON="git branch -D force-deletes without merge check"

# git clean -f (without -n)
[ -z "$REASON" ] && echo "$LC" | grep -qiE 'git\s+clean\s+.*-f' && ! echo "$LC" | grep -qiE '(-n|--dry-run)' && REASON="git clean -f permanently removes untracked files"

# git checkout -- (discard working tree changes)
[ -z "$REASON" ] && echo "$LC" | grep -qiE 'git\s+checkout\s+--\s' && REASON="git checkout -- discards uncommitted changes"

# git stash drop/clear
[ -z "$REASON" ] && echo "$LC" | grep -qiE 'git\s+stash\s+(drop|clear)' && REASON="git stash drop/clear permanently removes stashed changes"

# rm -rf or rm -r (not caught by safe patterns above)
[ -z "$REASON" ] && echo "$LC" | grep -qiE 'rm\s+-(rf|fr|r)\b' && REASON="rm -r recursively deletes files"

# SQL via CLI - destructive patterns
if [ -z "$REASON" ] && echo "$LC" | grep -qiE '\bdrop\s+(table|database|schema|view|procedure|function|index|trigger)\b'; then
  echo "$LC" | grep -qiE '\bcreate\b' || REASON="DROP statement via CLI without CREATE context"
fi
[ -z "$REASON" ] && echo "$LC" | grep -qiE 'alter\s+table\s+.*\bdrop\s+column\b' && REASON="ALTER TABLE DROP COLUMN permanently removes column data"
[ -z "$REASON" ] && echo "$LC" | grep -qiE '\btruncate\s+table\b' && REASON="TRUNCATE TABLE removes all rows without logging individual deletes"
if [ -z "$REASON" ] && echo "$LC" | grep -qiE '\bdelete\s+(from\s+)?\w'; then
  echo "$LC" | grep -qiE '\bwhere\b' || REASON="DELETE without WHERE clause via CLI"
fi

if [ -n "$REASON" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $REASON\"}}"
  exit 0
fi

# === ASK PATTERNS ===
ASK_REASON=""
echo "$LC" | grep -qiE '\bdbcc\b' && ASK_REASON="DBCC command detected - these can affect database performance and storage"
[ -z "$ASK_REASON" ] && echo "$LC" | grep -qiE '\bsp_rename\b' && ASK_REASON="sp_rename can break object dependencies"
[ -z "$ASK_REASON" ] && echo "$LC" | grep -qiE 'alter\s+schema\s+.*transfer' && ASK_REASON="ALTER SCHEMA TRANSFER moves objects between schemas"

if [ -n "$ASK_REASON" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"CONFIRM: $ASK_REASON\"}}"
  exit 0
fi

# All clear
exit 0
