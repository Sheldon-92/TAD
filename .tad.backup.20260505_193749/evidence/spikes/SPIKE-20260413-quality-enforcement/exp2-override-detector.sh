#!/bin/bash
# Experiment 2 — UserPromptSubmit Override detector (Phase 1a mechanism existence)
# Reads stdin JSON envelope with .prompt field.
# If prompt matches ^TAD_OVERRIDE: <gate> <reason>=20 chars>$ → append log line.
# Otherwise → no log.
# Always outputs empty (allow) — override detection is informational, not a blocker.
#
# NOTE: Phase 1a does NOT cover injection vectors (read-induced, social-eng,
# clipboard, sub-agent context). That is Phase 1b.

set -euo pipefail

# Fail-closed for UserPromptSubmit = don't block prompt on hook error.
# (Blocking the user's message on hook crash would be user-hostile and is
# explicitly noted in handoff §4.2.)
trap 'exit 0' ERR

LOG_DIR=".tad/evidence/overrides"
LOG_FILE="$LOG_DIR/spike-test.log"

# Read stdin JSON
stdin_json=$(cat)

# Extract prompt via jq (-r = raw). If malformed JSON, jq exits non-zero → trap fires → exit 0.
prompt=$(printf '%s' "$stdin_json" | jq -r '.prompt // ""' 2>/dev/null || echo "")

# Strip trailing newline(s) — EC4 handling.
prompt="${prompt%$'\n'}"
prompt="${prompt%$'\n'}"

# Bash regex (NOT grep -P). Anchored: ^TAD_OVERRIDE: <gate-no-whitespace> <reason >=20 chars>$
# Note: {20,} requires at least 20 chars after the space.
if [[ "$prompt" =~ ^TAD_OVERRIDE:\ ([^[:space:]]+)\ (.{20,})$ ]]; then
  gate="${BASH_REMATCH[1]}"
  reason="${BASH_REMATCH[2]}"
  mkdir -p "$LOG_DIR"
  # ISO-8601 UTC timestamp
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '%s gate=%s reason=%s\n' "$ts" "$gate" "$reason" >> "$LOG_FILE"
fi

# Always allow — empty output
exit 0
