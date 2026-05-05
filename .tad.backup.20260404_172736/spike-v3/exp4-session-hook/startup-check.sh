#!/bin/bash
# Quick health check for SessionStart hook test
HANDOFF_COUNT=$(ls .tad/active/handoffs/HANDOFF-*.md 2>/dev/null | wc -l | tr -d ' ')
EPIC_COUNT=$(ls .tad/active/epics/EPIC-*.md 2>/dev/null | wc -l | tr -d ' ')

cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "TAD Health: ${HANDOFF_COUNT} active handoffs, ${EPIC_COUNT} active epics"
  }
}
EOF
exit 0
