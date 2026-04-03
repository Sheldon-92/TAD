#!/bin/bash
# trace-step.sh — Record Domain Pack step-level trace
# Layer 2 trace: called by Blake during Domain Pack execution
# Usage:
#   trace-step.sh start <domain> <capability> <step>
#   trace-step.sh end <domain> <capability> <step> <status> [tool]

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
  echo "Usage: trace-step.sh start|end <domain> <capability> <step> [status] [tool]" >&2
  exit 1
fi

TRACE_DIR=".tad/evidence/traces"
mkdir -p "$TRACE_DIR"

TODAY=$(date +%Y-%m-%d)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROJECT=$(basename "$(pwd)")

_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

if [ "$ACTION" = "start" ]; then
  # step_start: no status/tool fields (not yet known)
  if [ "$HAS_JQ" = true ]; then
    jq -nc \
      --arg ts "$TS" --arg type "step_start" --arg project "$PROJECT" \
      --arg domain "$DOMAIN" --arg capability "$CAPABILITY" --arg step "$STEP" \
      '{ts:$ts,type:$type,project:$project,domain:$domain,capability:$capability,step:$step}' \
      >> "$TRACE_DIR/$TODAY.jsonl"
  else
    echo "{\"ts\":\"$TS\",\"type\":\"step_start\",\"project\":\"$(_escape "$PROJECT")\",\"domain\":\"$(_escape "$DOMAIN")\",\"capability\":\"$(_escape "$CAPABILITY")\",\"step\":\"$(_escape "$STEP")\"}" >> "$TRACE_DIR/$TODAY.jsonl"
  fi
elif [ "$ACTION" = "end" ]; then
  # step_end: status is required
  if [ -z "$STATUS" ]; then
    echo "Error: 'end' action requires status (completed|failed|skipped)" >&2
    exit 1
  fi
  if [ "$HAS_JQ" = true ]; then
    jq -nc \
      --arg ts "$TS" --arg type "step_end" --arg project "$PROJECT" \
      --arg domain "$DOMAIN" --arg capability "$CAPABILITY" --arg step "$STEP" \
      --arg status "$STATUS" --arg tool "$TOOL" \
      '{ts:$ts,type:$type,project:$project,domain:$domain,capability:$capability,step:$step,status:$status,tool:$tool}' \
      >> "$TRACE_DIR/$TODAY.jsonl"
  else
    echo "{\"ts\":\"$TS\",\"type\":\"step_end\",\"project\":\"$(_escape "$PROJECT")\",\"domain\":\"$(_escape "$DOMAIN")\",\"capability\":\"$(_escape "$CAPABILITY")\",\"step\":\"$(_escape "$STEP")\",\"status\":\"$(_escape "$STATUS")\",\"tool\":\"$(_escape "$TOOL")\"}" >> "$TRACE_DIR/$TODAY.jsonl"
  fi
else
  echo "Usage: trace-step.sh start|end <domain> <capability> <step> [status] [tool]" >&2
  exit 1
fi

exit 0
