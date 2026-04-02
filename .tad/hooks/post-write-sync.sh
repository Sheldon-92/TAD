#!/bin/bash
# TAD PostToolUse Hook — Key File Write Detection
# Detects writes to TAD-managed files and injects workflow reminders.
# Triggered by: Write | Edit tools (via matcher in settings.json)
# Output: JSON with hookSpecificOutput wrapper, or empty JSON for non-TAD files.
# Exit code: always 0 (async, never blocks).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

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
    output_response "PostToolUse" "Handoff created. BEFORE sending to Blake: 1. Call 2+ expert sub-agents (code-reviewer REQUIRED + 1 domain expert) 2. Fix ALL P0 issues from expert review 3. Run /gate 2 4. Generate Blake message (Step 7). Skipping expert review = VIOLATION."
    ;;
  *.tad/active/handoffs/COMPLETION-*.md)
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
  *)
    output_empty
    ;;
esac

exit 0
