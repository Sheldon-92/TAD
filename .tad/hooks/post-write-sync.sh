#!/bin/bash
# TAD PostToolUse Hook — Key File Write Detection
# Detects writes to TAD-managed files and injects workflow reminders.
# Triggered by: Write | Edit tools (via matcher in settings.json)
# Output: JSON with hookSpecificOutput wrapper, or empty JSON for non-TAD files.
# Exit code: always 0 (async, never blocks).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Read stdin JSON from Claude Code
read_stdin_json

# Extract file_path from tool_input
FILE_PATH=$(get_json_field ".tool_input.file_path")

# If file_path extraction failed, exit silently
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  output_empty
  exit 0
fi

# Pattern matching against TAD-managed files
case "$FILE_PATH" in
  */.tad/active/handoffs/HANDOFF-*.md)
    output_response "PostToolUse" "Handoff detected. Remember: Expert review (2+ experts) is MANDATORY before sending to Blake."
    ;;
  */.tad/active/handoffs/COMPLETION-*.md)
    output_response "PostToolUse" "Completion report detected. Gate 4 (business acceptance) should be executed."
    ;;
  */NEXT.md)
    output_response "PostToolUse" "NEXT.md updated. Linear sync may be needed if items changed."
    ;;
  */.tad/active/epics/EPIC-*.md)
    output_response "PostToolUse" "Epic updated. Check if phase status changed."
    ;;
  */.tad/project-knowledge/*.md)
    output_response "PostToolUse" "Knowledge file updated."
    ;;
  *)
    output_empty
    ;;
esac

exit 0
