#!/bin/bash
# trace-step.sh — Record capability step-level trace
# Layer 2 trace: called by Blake during Capability Pack execution
# Usage: bash trace-step.sh <start|end> <domain> <capability> <step> [status] [tool]
#
# Phase 5 P5.4 (2026-04-25): dual-write to date-keyed AND per-handoff trace dirs.
# Slug derived from active handoff filename (BA-P0-2: NOT env var).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ACTION="$1"
DOMAIN="$2"
CAPABILITY="$3"
STEP="$4"
STATUS="${5:-}"
TOOL="${6:-}"

# Validate required args
if [ -z "$ACTION" ] || [ -z "$DOMAIN" ] || [ -z "$CAPABILITY" ] || [ -z "$STEP" ]; then
  echo "Usage: trace-step.sh <start|end> <domain> <capability> <step> [status] [tool]" >&2
  exit 1
fi

TRACE_DIR=".tad/evidence/traces"
mkdir -p "$TRACE_DIR"

TODAY=$(date +%Y-%m-%d)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROJECT=$(basename "$(pwd)")

_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# ── P5.4 (BA-P0-2): derive slug from active handoff filename ───────────
# Single source of truth — same scan as askuser-capture.sh (BA-P0-1).
# Slug whitelist matches layer2-audit.sh (rejects path traversal).
SLUG=""
if [ -d ".tad/active/handoffs" ]; then
  # shellcheck disable=SC2206
  matches=( .tad/active/handoffs/HANDOFF-*.md )
  if [ -e "${matches[0]}" ] 2>/dev/null; then
    count=${#matches[@]}
    if [ "$count" -eq 1 ]; then
      candidate="${matches[0]}"
    else
      # Newest mtime wins (BSD stat then GNU stat fallback)
      newest=""
      newest_ts=0
      for f in "${matches[@]}"; do
        ts=$(stat -f%m -- "$f" 2>/dev/null || stat -c%Y -- "$f" 2>/dev/null || echo 0)
        if [ "$ts" -gt "$newest_ts" ]; then
          newest_ts="$ts"
          newest="$f"
        fi
      done
      candidate="$newest"
    fi
    fname=$(basename "$candidate")
    raw_slug=$(printf '%s' "$fname" | sed -E 's/^HANDOFF-[0-9]{8}-(.+)\.md$/\1/')
    if [ "$raw_slug" != "$fname" ]; then
      # Whitelist (P5.4 NFR7 — defense against path traversal)
      if [[ "$raw_slug" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$ ]]; then
        SLUG="$raw_slug"
      else
        echo "trace-step: slug failed whitelist (skipping per-handoff write): $raw_slug" >&2
      fi
    fi
  fi
fi

# ── Build JSONL line once, write to two sinks ──────────────────────────
if [ "$ACTION" = "start" ]; then
  if [ "$HAS_JQ" = true ]; then
    LINE=$(jq -nc \
      --arg ts "$TS" --arg type "step_start" --arg project "$PROJECT" \
      --arg domain "$DOMAIN" --arg capability "$CAPABILITY" --arg step "$STEP" \
      '{ts:$ts,type:$type,project:$project,domain:$domain,capability:$capability,step:$step}')
  else
    LINE="{\"ts\":\"$TS\",\"type\":\"step_start\",\"project\":\"$(_escape "$PROJECT")\",\"domain\":\"$(_escape "$DOMAIN")\",\"capability\":\"$(_escape "$CAPABILITY")\",\"step\":\"$(_escape "$STEP")\"}"
  fi
elif [ "$ACTION" = "end" ]; then
  if [ -z "$STATUS" ]; then
    echo "Error: 'end' action requires status (completed|failed|skipped)" >&2
    exit 1
  fi
  if [ "$HAS_JQ" = true ]; then
    LINE=$(jq -nc \
      --arg ts "$TS" --arg type "step_end" --arg project "$PROJECT" \
      --arg domain "$DOMAIN" --arg capability "$CAPABILITY" --arg step "$STEP" \
      --arg status "$STATUS" --arg tool "$TOOL" \
      '{ts:$ts,type:$type,project:$project,domain:$domain,capability:$capability,step:$step,status:$status,tool:$tool}')
  else
    LINE="{\"ts\":\"$TS\",\"type\":\"step_end\",\"project\":\"$(_escape "$PROJECT")\",\"domain\":\"$(_escape "$DOMAIN")\",\"capability\":\"$(_escape "$CAPABILITY")\",\"step\":\"$(_escape "$STEP")\",\"status\":\"$(_escape "$STATUS")\",\"tool\":\"$(_escape "$TOOL")\"}"
  fi
else
  echo "Usage: trace-step.sh <start|end> <domain> <capability> <step> [status] [tool]" >&2
  exit 1
fi

# Sink 1 (canonical): date-keyed file. Failure → exit 1 (existing behavior preserved).
if ! printf '%s\n' "$LINE" >> "$TRACE_DIR/$TODAY.jsonl"; then
  echo "trace-step: ERROR writing to $TRACE_DIR/$TODAY.jsonl" >&2
  exit 1
fi

# Sink 2 (best-effort): per-handoff path. Failure → WARN, continue.
# Only when slug derivation succeeded.
if [ -n "$SLUG" ]; then
  PER_DIR="$TRACE_DIR/per-handoff/$SLUG"
  if mkdir -p "$PER_DIR" 2>/dev/null; then
    printf '%s\n' "$LINE" >> "$PER_DIR/$TODAY.jsonl" 2>/dev/null \
      || echo "trace-step: WARN per-handoff append failed for $PER_DIR/$TODAY.jsonl (date-keyed write succeeded)" >&2
  else
    echo "trace-step: WARN mkdir failed for $PER_DIR (date-keyed write succeeded)" >&2
  fi
fi

exit 0
