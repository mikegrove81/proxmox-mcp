#!/bin/bash
# guard-sql-destructive.sh - PreToolUse hook for SQL MCP tools
# Evaluation order:
#   1. Global deny (guards.conf)
#   2. Repo access scope (db-access.conf)
#   3. Read-only enforcement (tool name check)
#   4. Destructive pattern guards (DROP, TRUNCATE, etc.)
# Exit 0 + JSON = deny or ask. Exit 0 + no output = allow.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"

INPUT=$(cat)

# Extract fields from tool_input using python
eval "$(echo "$INPUT" | python -c "
import sys, json
d = json.load(sys.stdin)
tn = d.get('tool_name', '')
ti = d.get('tool_input', {})
instance = ti.get('instance', '')
database = ti.get('database', '')
sql = ''
for field in ['sql', 'query', 'command', 'statement', 'ddl']:
    v = ti.get(field, '')
    if v:
        sql = v
        break
procedure = ti.get('procedure', '')
print(f'TOOL_NAME=\"{tn}\"')
print(f'INSTANCE=\"{instance}\"')
print(f'DATABASE=\"{database}\"')
print(f'PROCEDURE=\"{procedure}\"')
# SQL may have quotes/newlines - base64 encode it
import base64
print(f'SQL_B64=\"{base64.b64encode(sql.encode()).decode()}\"')
" 2>/dev/null)"

# Tools that don't take a database param - allow through
case "$TOOL_NAME" in
  *sql_list_databases|*sql_server_info|*sql_active_sessions|*sql_backup_info)
    # These are instance-level tools, no database scope to check
    # Fall through to destructive pattern check only if they have SQL
    [ -z "$SQL_B64" ] && exit 0
    ;;
esac

# Decode SQL
SQL=""
[ -n "$SQL_B64" ] && SQL=$(echo "$SQL_B64" | python -c "import sys,base64; print(base64.b64decode(sys.stdin.read().strip()).decode())" 2>/dev/null)

# If no database specified, nothing to scope-check
[ -z "$DATABASE" ] && exit 0

DB_LC=$(echo "$DATABASE" | tr '[:upper:]' '[:lower:]')

# === LAYER 1: Global deny (guards.conf) ===
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
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $DATABASE is a system database. Output a script and run it in SSMS.\"}}"
        exit 0
      fi
    fi
  done < "$GUARDS_FILE"
fi

# === LAYER 2: Repo access scope (db-access.conf) ===
# Resolve instance alias to canonical server name
SERVER="$INSTANCE"
ALIASES_FILE="$CLAUDE_DIR/db-aliases.conf"
if [ -n "$INSTANCE" ] && [ -f "$ALIASES_FILE" ]; then
  INST_LC=$(echo "$INSTANCE" | tr '[:upper:]' '[:lower:]')
  while IFS='=' read -r alias server; do
    [[ "$alias" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${alias// }" ]] && continue
    ALIAS_LC=$(echo "$alias" | tr '[:upper:]' '[:lower:]' | xargs)
    if [ "$INST_LC" = "$ALIAS_LC" ]; then
      SERVER=$(echo "$server" | xargs)
      break
    fi
  done < "$ALIASES_FILE"
fi

[ -z "$SERVER" ] && SERVER="$INSTANCE"
SERVER_LC=$(echo "$SERVER" | tr '[:upper:]' '[:lower:]')

ACCESS_FILE="$CLAUDE_DIR/db-access.conf"
if [ ! -f "$ACCESS_FILE" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: No db-access.conf found. Create .claude/db-access.conf with: sql: $SERVER/$DATABASE = read|write\"}}"
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
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $SERVER/$DATABASE is not in this repo's access scope. Add to .claude/db-access.conf: sql: $SERVER/$DATABASE = read|write\"}}"
  exit 0
fi

# === LAYER 3: Read-only enforcement ===
if [ "$ACCESS_LEVEL" = "read" ]; then
  case "$TOOL_NAME" in
    *sql_execute|*sql_execute_ddl|*sql_execute_proc)
      echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $SERVER/$DATABASE is read-only in this repo. Only SELECT queries allowed.\"}}"
      exit 0
      ;;
  esac
  exit 0
fi

# === LAYER 4: Destructive pattern guards (write-allowed databases only) ===
[ -z "$SQL" ] && exit 0

LC=$(echo "$SQL" | tr '[:upper:]' '[:lower:]')

# SAFE: DROP + CREATE in same batch = deploy pattern
HAS_DROP=$(echo "$LC" | grep -ciE '\bdrop\b')
HAS_CREATE=$(echo "$LC" | grep -ciE '\bcreate\b')
SKIP_DROP=0
if [ "$HAS_DROP" -gt 0 ] && [ "$HAS_CREATE" -gt 0 ]; then
  SKIP_DROP=1
fi

REASON=""

if [ "$SKIP_DROP" -eq 0 ]; then
  echo "$LC" | grep -qiE '\bdrop\s+(table|database|schema|view|procedure|function|index|trigger)\b' && REASON="DROP statement without CREATE context - this permanently removes the object"
fi

[ -z "$REASON" ] && echo "$LC" | grep -qiE 'alter\s+table\s+.*\bdrop\s+column\b' && REASON="ALTER TABLE DROP COLUMN permanently removes column data"
[ -z "$REASON" ] && echo "$LC" | grep -qiE '\btruncate\s+table\b' && REASON="TRUNCATE TABLE removes all rows without logging individual deletes"

if [ -z "$REASON" ] && echo "$LC" | grep -qiE '\bdelete\s+(from\s+)?\w'; then
  echo "$LC" | grep -qiE '\bwhere\b' || REASON="DELETE without WHERE clause - this removes ALL rows from the table"
fi

if [ -n "$REASON" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"BLOCKED: $REASON\"}}"
  exit 0
fi

ASK_REASON=""
echo "$LC" | grep -qiE '\bsp_rename\b' && ASK_REASON="sp_rename can break object dependencies"
[ -z "$ASK_REASON" ] && echo "$LC" | grep -qiE 'alter\s+schema\s+.*transfer' && ASK_REASON="ALTER SCHEMA TRANSFER moves objects between schemas"
[ -z "$ASK_REASON" ] && echo "$LC" | grep -qiE '\bdbcc\b' && ASK_REASON="DBCC command detected - these can affect database performance and storage"

if [ -n "$ASK_REASON" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"CONFIRM: $ASK_REASON\"}}"
  exit 0
fi

# All clear
exit 0
