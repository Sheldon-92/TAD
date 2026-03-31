#!/bin/bash
# TAD Hook Shared Utilities
# Used by all TAD hook scripts for JSON I/O and file operations.

# Detect jq availability (cached for performance)
HAS_JQ=false
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=true
fi

# Read JSON from stdin into STDIN_JSON variable
# Usage: read_stdin_json
read_stdin_json() {
  STDIN_JSON=$(cat)
}

# Extract a field from JSON string
# Usage: get_json_field ".tool_input.file_path"
# Falls back to grep if jq unavailable
get_json_field() {
  local field="$1"
  local json="${2:-$STDIN_JSON}"

  if [ "$HAS_JQ" = true ]; then
    echo "$json" | jq -r "$field" 2>/dev/null
  else
    # Grep fallback: only works for simple top-level or one-level nested fields
    # Extract last segment of jq path for grep (e.g., .tool_input.file_path -> file_path)
    local key
    key=$(echo "$field" | sed 's/.*\.//')
    echo "$json" | grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*"'${key}'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
  fi
}

# Output hook response JSON with additionalContext
# Usage: output_response "SessionStart" "TAD v3.0 | 1 handoffs"
output_response() {
  local event_name="$1"
  local context="$2"

  if [ "$HAS_JQ" = true ]; then
    jq -n \
      --arg event "$event_name" \
      --arg ctx "$context" \
      '{"hookSpecificOutput":{"hookEventName":$event,"additionalContext":$ctx}}'
  else
    # Manual JSON construction — safe because we control the inputs
    # Escape backslashes and quotes in context string
    local escaped_ctx
    escaped_ctx=$(printf '%s' "$context" | sed 's/\\/\\\\/g; s/"/\\"/g')
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"${event_name}","additionalContext":"${escaped_ctx}"}}
EOF
  fi
}

# Output empty JSON (no-op response)
output_empty() {
  echo '{}'
}

# Safe file count: count matching files, return 0 if dir/pattern doesn't exist
# Usage: safe_count ".tad/active/handoffs/HANDOFF-*.md"
safe_count() {
  local pattern="$1"
  # shellcheck disable=SC2086
  local count
  count=$(ls $pattern 2>/dev/null | wc -l | tr -d ' ')
  echo "${count:-0}"
}
