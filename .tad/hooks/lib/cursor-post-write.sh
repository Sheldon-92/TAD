#!/bin/bash
# TAD Cursor adapter shim — postToolUse (thin dialect layer, no TAD logic).
#
# Passes the Cursor hook payload on stdin through to the shared behavior
# source (.tad/hooks/post-write-sync.sh), then transcodes its Codex-shaped
# stdout ({"hookSpecificOutput":{"additionalContext": ...}}) into the Cursor
# shape ({"additional_context": ...}).
#
# Field notes (measured 2026-10-06, Cursor Agent 2026.10.01-e373342, skeleton
# probe OC-2; see .tad/evidence/designs/2026-10-06-p3-phase0-probes.md):
#   - Cursor postToolUse payload: tool_name "Write", file path at
#     tool_input.file_path (absolute). Both sit inside the shared envelope
#     fallback chains (.tool_name, .tool_input.file_path), so stdin is passed
#     through unmodified — no field normalization is applied.
#
# SAFETY: fail-open smoke alarm. Always exit 0; on any failure (missing jq,
# unparsable shared-script output) emit {} so the session proceeds untouched.

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
TARGET="${SCRIPT_DIR}/../post-write-sync.sh"

INPUT="$(cat 2>/dev/null || true)"

OUT="$(printf '%s' "$INPUT" | bash "$TARGET" 2>/dev/null || true)"

CTX=""
if [ -n "$OUT" ] && command -v jq >/dev/null 2>&1; then
  CTX="$(printf '%s' "$OUT" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null || true)"
fi

if [ -n "$CTX" ] && command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$CTX" '{"additional_context": $ctx}' 2>/dev/null || printf '%s\n' '{}'
else
  printf '%s\n' '{}'
fi
exit 0
