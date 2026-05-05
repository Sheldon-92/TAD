#!/bin/bash
# TAD PreToolUse Hook — *accept Gate 4 Prerequisite Check
# Ensures COMPLETION report exists before acceptance.
# Triggered by: Skill tool when skill contains "accept"
# Exit 0 = ALLOW, Exit 2 = BLOCK
# Must complete in <500ms (no network calls).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Read stdin JSON from Claude Code
read_stdin_json

# Extract tool name and skill name
TOOL_NAME=$(get_json_field ".tool_name" || echo "")
SKILL_NAME=$(get_json_field ".tool_input.skill" || echo "")

# Only check when invoking Skill tool with "accept" in skill name
if [ "$TOOL_NAME" != "Skill" ] || [[ "$SKILL_NAME" != *"accept"* ]]; then
  output_empty
  exit 0
fi

# Check if TAD is initialized
if [ ! -d ".tad/active/handoffs" ]; then
  output_empty
  exit 0
fi

# Check for COMPLETION report
COMPLETION=$(safe_count ".tad/active/handoffs/COMPLETION-*.md")

if [ "$COMPLETION" = "0" ]; then
  echo "Cannot accept: no completion report found in .tad/active/handoffs/. Blake must run *complete + /gate 3 first." >&2
  exit 2  # BLOCK
fi

# COMPLETION exists → ALLOW
output_response "PreToolUse" "Completion report found (${COMPLETION} file(s)). Proceed with Gate 4 acceptance."
exit 0
