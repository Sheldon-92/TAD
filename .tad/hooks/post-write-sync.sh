#!/bin/bash
# TAD PostToolUse Hook — Key File Write Detection
# Detects writes to TAD-managed files and injects workflow reminders.
# Triggered by: Write | Edit tools (via matcher in settings.json)
# Output: JSON with hookSpecificOutput wrapper, or empty JSON for non-TAD files.
# Exit code: always 0 (async, never blocks).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Record a trace entry to .tad/evidence/traces/{date}.jsonl
# Usage: record_trace "type" "file_path" "domain"
record_trace() {
  local type="$1"
  local file_path="$2"
  local domain="${3:-}"

  local trace_dir=".tad/evidence/traces"
  mkdir -p "$trace_dir"

  local today
  today=$(date +%Y-%m-%d)
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local project
  project=$(basename "$(pwd)")
  local size
  size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")

  if [ "$HAS_JQ" = true ]; then
    jq -nc \
      --arg ts "$ts" \
      --arg type "$type" \
      --arg project "$project" \
      --arg file "$file_path" \
      --arg domain "$domain" \
      --argjson size "$size" \
      '{ts:$ts,type:$type,project:$project,file:$file,domain:$domain,size_bytes:$size}' \
      >> "$trace_dir/$today.jsonl"
  else
    local safe_path safe_domain safe_project
    safe_path=$(printf '%s' "$file_path" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_domain=$(printf '%s' "$domain" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_project=$(printf '%s' "$project" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"ts\":\"$ts\",\"type\":\"$type\",\"project\":\"$safe_project\",\"file\":\"$safe_path\",\"domain\":\"$safe_domain\",\"size_bytes\":$size}" >> "$trace_dir/$today.jsonl"
  fi
}

# Read stdin JSON from Claude Code
read_stdin_json

# Extract file_path from tool_input
FILE_PATH=$(get_json_field ".tool_input.file_path" || echo "")

# If file_path extraction failed, exit silently
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  output_empty
  exit 0
fi

# Pattern matching against TAD-managed files
# Patterns use *.tad/* to match both absolute (/path/.tad/) and relative (.tad/) paths
case "$FILE_PATH" in
  *.tad/active/handoffs/HANDOFF-*.md)
    record_trace "handoff_created" "$FILE_PATH" ""
    output_response "PostToolUse" "Handoff created. BEFORE sending to Blake: 1. Call 2+ expert sub-agents (code-reviewer REQUIRED + 1 domain expert) 2. Fix ALL P0 issues from expert review 3. Run /gate 2 4. Generate Blake message (Step 7). Skipping expert review = VIOLATION."
    ;;
  *.tad/active/handoffs/COMPLETION-*.md)
    record_trace "task_completed" "$FILE_PATH" ""
    output_response "PostToolUse" "COMPLETION report detected. You MUST run /gate 3 before sending results to Alex. Gate 3 is MANDATORY, not optional. The pre-gate hook will BLOCK /gate 3 if evidence is missing."
    ;;
  */NEXT.md|NEXT.md)
    output_response "PostToolUse" "NEXT.md updated. Linear sync may be needed if items changed."
    ;;
  *.tad/active/epics/EPIC-*.md)
    output_response "PostToolUse" "Epic updated. Check if phase status changed."
    ;;
  *.tad/project-knowledge/*.md)
    output_response "PostToolUse" "Knowledge file updated."
    ;;
  *.tad/evidence/ralph-loops/*_state.yaml)
    output_response "PostToolUse" "Ralph Loop state detected. MANDATORY workflow reminder: 1. Layer 1: build + test + lint + tsc (ALL must pass) 2. Layer 2: code-reviewer + test-runner sub-agents (P0=0 required) 3. *complete to write COMPLETION report 4. /gate 3 formal quality check (Hook will BLOCK if evidence missing) 5. Message to Alex. SKIPPING ANY STEP = VIOLATION."
    ;;
  *.tad/active/research/*)
    record_trace "domain_pack_step" "$FILE_PATH" ""
    output_empty
    ;;
  *.tad/evidence/traces/*)
    # CRITICAL: This branch MUST appear before *.tad/evidence/* to prevent infinite recursion
    output_empty
    ;;
  *.tad/evidence/*)
    record_trace "evidence_created" "$FILE_PATH" ""
    output_empty
    ;;
  *)
    output_empty
    ;;
esac

exit 0
