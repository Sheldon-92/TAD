#!/bin/bash
# TAD SessionStart Hook — Project Health Summary
# Injects TAD status into every new session via additionalContext.
# Output: JSON with hookSpecificOutput wrapper.
# Exit code: always 0 (never block session startup).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Read stdin JSON from Claude Code
read_stdin_json

# Check source field — only run on "startup" (or if field missing, run anyway)
SOURCE=$(get_json_field ".source" || echo "")
if [ -n "$SOURCE" ] && [ "$SOURCE" != "null" ] && [ "$SOURCE" != "startup" ]; then
  output_empty
  exit 0
fi

# Check if TAD is initialized
if [ ! -d ".tad" ]; then
  output_response "SessionStart" "TAD not initialized in this project."
  exit 0
fi

# Gather health metrics
HANDOFF_COUNT=$(safe_count ".tad/active/handoffs/HANDOFF-*.md")
EPIC_COUNT=$(safe_count ".tad/active/epics/EPIC-*.md")
IDEA_COUNT=$(safe_count ".tad/active/ideas/IDEA-*.md")

# Check for blocked items in NEXT.md
HAS_BLOCKED=""
if [ -f "NEXT.md" ] && grep -q "## Blocked" NEXT.md 2>/dev/null; then
  HAS_BLOCKED=" | has blocked items"
fi

# Read TAD version
VERSION="unknown"
if [ -f ".tad/config.yaml" ]; then
  # Extract version from config.yaml
  if [ "$HAS_JQ" = true ] && command -v yq >/dev/null 2>&1; then
    VERSION=$(yq -r '.version' .tad/config.yaml 2>/dev/null || echo "unknown")
  else
    VERSION=$(grep -m1 '^version:' .tad/config.yaml 2>/dev/null | sed 's/version:[[:space:]]*//' | tr -d '"' || echo "unknown")
  fi
fi

# Build summary
SUMMARY="TAD v${VERSION} | ${HANDOFF_COUNT} handoffs | ${EPIC_COUNT} epics | ${IDEA_COUNT} ideas${HAS_BLOCKED} | Hooks: active"

output_response "SessionStart" "$SUMMARY"
exit 0
