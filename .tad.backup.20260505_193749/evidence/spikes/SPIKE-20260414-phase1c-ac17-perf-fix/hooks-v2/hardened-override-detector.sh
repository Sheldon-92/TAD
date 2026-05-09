#!/bin/bash
# Hardened UserPromptSubmit Override detector (Phase 1b).
#
# Extends Phase 1a exp2 with:
#   - Line-start strict (anchored ^ + reject if any leading whitespace/newline)
#   - Reject if sub-agent (Agent tool) context detected via stdin envelope
#   - HMAC-chain log entries (each includes prev entry's HMAC)
#   - Single-use nonce: consumed from .tad/evidence/overrides/nonce-registry.txt
#   - Ticket reference required: TAD-\d+
#   - Expiry: 5 minutes from now
#   - Tool-result injection resistance: override from tool-result envelope rejected
#
# Fail-closed: on any error → exit 0 with no log written (user msg not blocked;
# failure-to-log is safer than failure-to-deliver for UserPromptSubmit).

set -euo pipefail

# ── TAD Phase 1c AC17 fix: dep-guard (hard-deny if jq/awk missing) ──
source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"
require_dep jq
# ── end dep-guard block ──

LOG_DIR=".tad/evidence/overrides"
LOG_FILE="$LOG_DIR/spike-1b.log"
NONCE_REGISTRY="$LOG_DIR/nonce-registry.txt"
CONSUMED_REGISTRY="$LOG_DIR/nonce-consumed.txt"

trap 'exit 0' ERR  # fail-closed = don't block user, don't write log

# Trigger: missing deps → silently pass (can't log without openssl; don't block user)
for dep in jq openssl perl; do
  if ! command -v "$dep" >/dev/null 2>&1; then exit 0; fi
done

stdin_json=$(cat)
[ -n "$stdin_json" ] || exit 0  # stdin EOF → pass-through

# ────────────────────────────────────────────────────────────────
# Reject if invocation context is a sub-agent (Agent tool spawn)
# Claude Code's UserPromptSubmit envelope has `session_id` and `cwd`;
# sub-agent sessions have distinct session_id prefixed/suffixed; look for
# explicit markers in transcript_path or a known sub-agent indicator.
# Conservative: if transcript_path contains "/agent-" or cwd differs from
# expected project root markers, treat as sub-agent context → pass-through.
# ────────────────────────────────────────────────────────────────
transcript_path=$(printf '%s' "$stdin_json" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")
source_marker=$(printf '%s' "$stdin_json" | jq -r '.source // ""' 2>/dev/null || echo "")
if printf '%s' "$transcript_path" | grep -qiE '/(sub-agent|agent-task|spawned)/'; then
  exit 0
fi
if [ "$source_marker" = "tool_result" ] || [ "$source_marker" = "sub-agent" ]; then
  exit 0
fi

prompt=$(printf '%s' "$stdin_json" | jq -r '.prompt // ""' 2>/dev/null || exit 0)

# ────────────────────────────────────────────────────────────────
# Reject if NOT at line start — strict anchor check.
# bash regex =~ ^ matches start of string. If user pastes with leading
# whitespace/newlines, they must re-enter clean.
# ────────────────────────────────────────────────────────────────
# Strip trailing newline(s) only; leading chars are significant.
prompt="${prompt%$'\n'}"
prompt="${prompt%$'\n'}"

# Strict line-start: first char must be 'T' of TAD_OVERRIDE
if [ "${prompt:0:13}" != "TAD_OVERRIDE:" ]; then
  exit 0
fi

# ────────────────────────────────────────────────────────────────
# Parse: TAD_OVERRIDE: <gate> ticket=<TAD-N> nonce=<hex> <reason ≥20>
# ────────────────────────────────────────────────────────────────
if [[ "$prompt" =~ ^TAD_OVERRIDE:\ ([^[:space:]]+)\ ticket=(TAD-[0-9]+)\ nonce=([a-f0-9]{8,64})\ (.{20,})$ ]]; then
  gate="${BASH_REMATCH[1]}"
  ticket="${BASH_REMATCH[2]}"
  nonce="${BASH_REMATCH[3]}"
  reason="${BASH_REMATCH[4]}"
else
  exit 0
fi

# ────────────────────────────────────────────────────────────────
# Reason-content hardening (Cat 4 log-integrity attacks):
# Reject reason containing injection tokens that try to forge log fields
# or corrupt the chain (prev_hmac=, hmac=, ts=, source=, FAKE_ROW, tab/newline).
# ────────────────────────────────────────────────────────────────
if printf '%s' "$reason" | grep -qE '(^|[[:space:]])(prev_hmac|hmac|ts|source)='; then
  exit 0  # reject as log-integrity attack
fi
if printf '%s' "$reason" | grep -qiF 'FAKE_ROW'; then
  exit 0
fi
# Reject if reason contains literal tab or newline (format injection)
if printf '%s' "$reason" | grep -qP '[\t\n]' 2>/dev/null; then
  exit 0
fi
# BSD-portable alternative (no -P): use tr + grep
if [ "$(printf '%s' "$reason" | tr -d '\t\n' | wc -c | tr -d ' ')" != "$(printf '%s' "$reason" | wc -c | tr -d ' ')" ]; then
  exit 0
fi

mkdir -p "$LOG_DIR"
touch "$NONCE_REGISTRY" "$CONSUMED_REGISTRY" "$LOG_FILE"

# ────────────────────────────────────────────────────────────────
# Nonce single-use check
# ────────────────────────────────────────────────────────────────
if ! grep -qxF "$nonce" "$NONCE_REGISTRY"; then
  exit 0  # unknown nonce — not in registry
fi
if grep -qxF "$nonce" "$CONSUMED_REGISTRY"; then
  exit 0  # already used
fi

# Mark consumed atomically (append is atomic for small writes on local FS)
printf '%s\n' "$nonce" >> "$CONSUMED_REGISTRY"

# ────────────────────────────────────────────────────────────────
# HMAC-chain log entry
# ────────────────────────────────────────────────────────────────
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
expires_at=$(perl -MTime::Piece -e 'print((localtime->gmtime + 300)->strftime("%Y-%m-%dT%H:%M:%SZ"))' 2>/dev/null || echo "$ts")

# Previous entry's HMAC (empty for first entry)
prev_hmac=""
if [ -s "$LOG_FILE" ]; then
  prev_hmac=$(tail -1 "$LOG_FILE" | awk -F '\t' '{print $NF}')
fi

KEY="TAD_SPIKE_1B_SECRET"
row="$ts	gate=$gate	ticket=$ticket	nonce=$nonce	expires_at=$expires_at	reason=$reason	prev_hmac=$prev_hmac"
row_hmac=$(printf '%s' "$row" | openssl dgst -sha256 -hmac "$KEY" -r | awk '{print $1}')

printf '%s\thmac=%s\n' "$row" "$row_hmac" >> "$LOG_FILE"

exit 0
