#!/bin/bash
# update-frontmatter-date.sh — PostToolUse hook for Edit/Write
# Auto-updates the `updated:` frontmatter field on memory/ and context/ files.
# Prevents staleness by ensuring the date stays current when content changes.

INPUT=$(cat)

# Extract file_path from JSON input (works with or without jq)
FILE_PATH=$(echo "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

# Normalize backslashes to forward slashes for pattern matching
NORM_PATH=$(echo "$FILE_PATH" | tr '\\' '/')

# Exit silently if no file path
[ -z "$NORM_PATH" ] && exit 0

# Only process memory/ and context/ files
case "$NORM_PATH" in
  */memory/*|*/context/*) ;;
  *) exit 0 ;;
esac

# Skip templates, indexes, and digest files
case "$NORM_PATH" in
  */_templates/*|*/_indexes/*|*/digests/*) exit 0 ;;
esac

# Update the frontmatter date if the file has one
if [ -f "$FILE_PATH" ] && head -20 "$FILE_PATH" | grep -q "^updated:"; then
  TODAY=$(date +%Y-%m-%d)
  sed -i "s/^updated: .*/updated: $TODAY/" "$FILE_PATH"
  echo "Frontmatter date auto-updated to $TODAY on $(basename "$FILE_PATH")"
fi
