#!/bin/bash
# TAD PreToolUse Hook — Gate 3/4 Prerequisite Check
# Gate 3: Requires COMPLETION report (BLOCK if missing)
# Gate 4: Warns if no COMPLETION (does not BLOCK)
# Cold start safe: missing evidence dir = ALLOW with warning
# Exit 0 = ALLOW, Exit 2 = BLOCK
# Must complete in <500ms (no network calls).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Read stdin JSON from Claude Code
read_stdin_json

# Extract tool name and skill details
TOOL_NAME=$(get_json_field ".tool_name" || echo "")
SKILL_NAME=$(get_json_field ".tool_input.skill" || echo "")
SKILL_ARGS=$(get_json_field ".tool_input.args" || echo "")

# Only check when invoking Skill tool with "gate" in skill name
if [ "$TOOL_NAME" != "Skill" ] || [[ "$SKILL_NAME" != *"gate"* ]]; then
  output_empty
  exit 0
fi

# Check if TAD is initialized
if [ ! -d ".tad" ]; then
  output_empty
  exit 0
fi

# Extract gate number from args (first digit found)
GATE_NUM=$(echo "$SKILL_ARGS" | grep -oE '^[0-9]+' | head -1)

if [ "$GATE_NUM" = "3" ]; then
  # Gate 3 prerequisite: COMPLETION report must exist

  # Cold start safety: if handoffs dir doesn't exist, ALLOW (first-time project)
  if [ ! -d ".tad/active/handoffs" ]; then
    output_response "PreToolUse" "First-time project: no handoffs directory. Gate 3 will proceed but completion evidence is recommended."
    exit 0
  fi

  # Check for COMPLETION report
  COMPLETION=$(safe_count ".tad/active/handoffs/COMPLETION-*.md")

  if [ "$COMPLETION" = "0" ]; then
    echo "Cannot run Gate 3: no COMPLETION report found in .tad/active/handoffs/. Run *complete first to generate the completion report." >&2
    exit 2  # BLOCK
  fi

  output_response "PreToolUse" "Gate 3 prerequisites met. Completion report found. Proceeding with quality gate check."
  exit 0

elif [ "$GATE_NUM" = "4" ]; then
  # Gate 4: warn if no COMPLETION, but don't BLOCK (Alex-side responsibility)
  COMPLETION=$(safe_count ".tad/active/handoffs/COMPLETION-*.md")

  if [ "$COMPLETION" = "0" ]; then
    output_response "PreToolUse" "Warning: no completion report found. Gate 4 typically requires Gate 3 to pass first."
  else
    output_response "PreToolUse" "Gate 4 prerequisites met. Completion report found."
  fi
  exit 0

else
  # Gate 1, 2, or other → allow without checks
  output_empty
  exit 0
fi
