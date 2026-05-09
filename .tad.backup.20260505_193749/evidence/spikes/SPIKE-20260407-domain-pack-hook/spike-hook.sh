#!/bin/bash
# Spike hook — UserPromptSubmit event handler.
# Purpose: prove the hook fires (sentinel) AND additionalContext reaches Alex.
# This is NOT a real classifier — Path A only verifies the integration channel.
# Path B (run-spike.sh canonical accuracy) measures Haiku quality out-of-band.

set -euo pipefail

SENTINEL="/tmp/tad-spike-userprompt-fired.log"

# Drain stdin (Claude Code passes hook input as JSON on stdin)
INPUT="$(cat 2>/dev/null || true)"

# Sentinel write — proves the hook actually executed
TS="$(date +%s)"
PROMPT_SNIPPET="$(printf '%s' "$INPUT" | tr '\n' ' ' | cut -c1-200)"
printf '%s | %s\n' "$TS" "$PROMPT_SNIPPET" >> "$SENTINEL"

# Emit hookSpecificOutput so Alex receives a system-reminder.
# Format mirrors .tad/hooks/lib/common.sh::output_response().
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"SPIKE-TEST-MARKER-A1B2C3: This is a UserPromptSubmit hook injection from SPIKE-20260407-domain-pack-hook. If you (Alex) see this string, the hook channel works. Pretend web-frontend.component_development pack is relevant (this is a fixed test injection, not a real classification)."}}
JSON

exit 0
