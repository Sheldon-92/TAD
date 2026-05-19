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
    echo "$json" | jq -r "$field" 2>/dev/null || echo ""
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
    escaped_ctx=$(printf '%s' "$context" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | tr '\n' ' ')
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"${event_name}","additionalContext":"${escaped_ctx}"}}
EOF
  fi
}

# Output empty JSON (no-op response)
output_empty() {
  echo '{}'
}

# Record a trace entry to .tad/evidence/traces/{date}.jsonl
# Usage: record_trace "type" "file_path" "domain"
# v2 extensions: set TRACE_* env vars before calling (see trace-writer.sh for helpers)
#   TRACE_CONTEXT  — context string (truncated per detail_level)
#   TRACE_OUTCOME  — pass|fail|error|skip|partial
#   TRACE_ACTOR    — human_confirmed|agent_inferred|agent_verified|human_overridden
#   TRACE_DETAIL   — full|summary (default: summary)
#   TRACE_SLUG     — handoff slug for cross-referencing
#   TRACE_AGENT    — alex|blake|conductor|sub-agent|tool-name
#   TRACE_DURATION — elapsed ms for timed events
record_trace() {
  local type="$1"
  local file_path="${2:-}"
  local domain="${3:-}"
  # --- v2 extensions via environment variables ---
  local context="${TRACE_CONTEXT:-}"
  local outcome="${TRACE_OUTCOME:-}"
  local actor_tag="${TRACE_ACTOR:-agent_inferred}"
  local detail_level="${TRACE_DETAIL:-summary}"
  local slug="${TRACE_SLUG:-}"
  local agent="${TRACE_AGENT:-}"
  local duration_ms="${TRACE_DURATION:-}"

  # Auto-escalation: failures force full detail regardless of caller
  case "$outcome" in
    fail|error|FAIL|ERROR) detail_level="full" ;;
  esac

  # Truncate context based on detail_level
  if [ -n "$context" ]; then
    if [ "$detail_level" = "summary" ]; then
      context=$(printf '%.200s' "$context")
    else
      context=$(printf '%.2048s' "$context")
    fi
  fi

  local trace_dir=".tad/evidence/traces"
  mkdir -p "$trace_dir"

  local today
  today=$(date +%Y-%m-%d)
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local project
  project=$(basename "$(pwd)")

  # Guard stat on empty file_path
  local size=0
  [ -n "$file_path" ] && size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")

  if [ "$HAS_JQ" = true ]; then
    local jq_args=(
      --arg ts "$ts"
      --arg type "$type"
      --arg project "$project"
      --arg schema_version "2.0"
      --arg actor_tag "$actor_tag"
      --arg detail_level "$detail_level"
    )
    local jq_obj='{ts:$ts,type:$type,project:$project,schema_version:$schema_version,actor_tag:$actor_tag,detail_level:$detail_level}'

    # Legacy fields (present when non-empty)
    if [ -n "$file_path" ]; then
      jq_args+=(--arg file "$file_path" --argjson size_bytes "$size")
      jq_obj="$jq_obj + {file:\$file,size_bytes:\$size_bytes}"
    fi
    if [ -n "$domain" ]; then
      jq_args+=(--arg domain "$domain")
      jq_obj="$jq_obj + {domain:\$domain}"
    fi

    # v2 fields (present when non-empty)
    if [ -n "$context" ]; then
      jq_args+=(--arg context "$context")
      jq_obj="$jq_obj + {context:\$context}"
    fi
    if [ -n "$outcome" ]; then
      jq_args+=(--arg outcome "$outcome")
      jq_obj="$jq_obj + {outcome:\$outcome}"
    fi
    if [ -n "$slug" ]; then
      jq_args+=(--arg slug "$slug")
      jq_obj="$jq_obj + {slug:\$slug}"
    fi
    if [ -n "$agent" ]; then
      jq_args+=(--arg agent "$agent")
      jq_obj="$jq_obj + {agent:\$agent}"
    fi
    if [ -n "$duration_ms" ]; then
      jq_args+=(--argjson duration_ms "$duration_ms")
      jq_obj="$jq_obj + {duration_ms:\$duration_ms}"
    fi

    jq -nc "${jq_args[@]}" "$jq_obj" >> "$trace_dir/$today.jsonl" 2>/dev/null || true
  else
    # Shell fallback — always include schema_version, actor_tag, detail_level
    local safe_path safe_domain safe_project safe_context safe_outcome safe_slug safe_agent
    safe_path=$(printf '%s' "$file_path" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_domain=$(printf '%s' "$domain" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_project=$(printf '%s' "$project" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_context=$(printf '%s' "$context" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_outcome=$(printf '%s' "$outcome" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_slug=$(printf '%s' "$slug" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_agent=$(printf '%s' "$agent" | sed 's/\\/\\\\/g; s/"/\\"/g')

    local json="{\"ts\":\"$ts\",\"type\":\"$type\",\"project\":\"$safe_project\",\"schema_version\":\"2.0\",\"actor_tag\":\"$actor_tag\",\"detail_level\":\"$detail_level\""
    # Numeric guard for size_bytes
    [[ "$size" =~ ^[0-9]+$ ]] || size=0
    [ -n "$file_path" ] && json="$json,\"file\":\"$safe_path\",\"size_bytes\":$size"
    [ -n "$domain" ] && json="$json,\"domain\":\"$safe_domain\""
    [ -n "$context" ] && json="$json,\"context\":\"$safe_context\""
    [ -n "$outcome" ] && json="$json,\"outcome\":\"$safe_outcome\""
    [ -n "$slug" ] && json="$json,\"slug\":\"$safe_slug\""
    [ -n "$agent" ] && json="$json,\"agent\":\"$safe_agent\""
    # Numeric guard for duration_ms
    if [ -n "$duration_ms" ] && [[ "$duration_ms" =~ ^[0-9]+$ ]]; then
      json="$json,\"duration_ms\":$duration_ms"
    fi
    json="$json}"
    echo "$json" >> "$trace_dir/$today.jsonl"
  fi

  # Clear TRACE_* env vars to prevent bleed between calls
  unset TRACE_CONTEXT TRACE_OUTCOME TRACE_ACTOR TRACE_DETAIL TRACE_SLUG TRACE_AGENT TRACE_DURATION
}

# Safe file count: count matching files, return 0 if dir/pattern doesn't exist
# Usage: safe_count ".tad/active/handoffs/HANDOFF-*.md"
safe_count() {
  local pattern="$1"
  # shellcheck disable=SC2206
  local matches=( $pattern )
  if [ -e "${matches[0]}" ] 2>/dev/null; then
    echo "${#matches[@]}"
  else
    echo "0"
  fi
}
