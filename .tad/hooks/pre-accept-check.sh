#!/bin/bash
# TAD PreToolUse Hook — *accept Gate 4 Prerequisite Check
# Ensures COMPLETION report exists before acceptance.
# Triggered by: Skill tool when skill contains "accept"
# Exit 0 = ALLOW, Exit 2 = BLOCK
# Must complete in <500ms (no network calls).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/hook-envelope.sh
source "${SCRIPT_DIR}/lib/hook-envelope.sh"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Hook calls carry JSON; manual calls use gate 4 as an explicit argument.
MANUAL_MODE=0
if [ "$HOOK_ENVELOPE_HAS_INPUT" -eq 0 ]; then
  MANUAL_MODE=1
  if [ -z "${1:-}" ]; then
    echo "Usage: bash $0 4 (or provide a hook JSON envelope on stdin)" >&2
    exit 1
  fi
  if [ "$1" != "4" ]; then
    echo "Invalid gate number: $1" >&2
    echo "Usage: bash $0 4 (or provide a hook JSON envelope on stdin)" >&2
    exit 1
  fi
  TOOL_NAME=""
  SKILL_NAME=""
else
  TOOL_NAME="${HOOK_TOOL_NAME:-}"
  SKILL_NAME="${HOOK_SKILL:-}"
fi

# Only check when invoking Skill tool with "accept" in skill name
if [ "$MANUAL_MODE" -eq 0 ] && { [ "$TOOL_NAME" != "Skill" ] || [[ "$SKILL_NAME" != *"accept"* ]]; }; then
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
