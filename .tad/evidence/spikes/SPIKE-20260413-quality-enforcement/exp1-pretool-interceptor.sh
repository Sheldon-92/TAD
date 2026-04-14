#!/bin/bash
# Experiment 1 — PreToolUse Write interceptor (Phase 1a mechanism existence)
#
# Logic:
#   1. Read stdin JSON envelope (PreToolUse).
#   2. If tool_name != "Write" → allow.
#   3. If tool_input.content does NOT contain sentinel "message from blake"
#      (case-insensitive) → allow.
#   4. Otherwise extract {slug} from tool_input.file_path (regex HANDOFF-YYYYMMDD-slug),
#      default "spike-default" if no match.
#   5. Count .md files in .tad/evidence/reviews/blake/{slug}/. If < 2 → deny with
#      reason listing missing evidence path. If >= 2 → allow.
#
# Fail-closed: on ANY error (malformed JSON, missing jq, etc.) → emit deny JSON.
# PreToolUse semantics: deny = tool blocked BEFORE execution (file never written).
#
# Phase 1a ONLY: sentinel bypass attacks (case variants, zero-width chars, Edit tool,
# split writes, Bash redirect) are out of scope — Phase 1b will cover.
#
# Env:
#   TAD_SPIKE_LATENCY_LOG — optional path. When set, per-step ns timestamps written as
#     "step\tepoch_ns" lines (used by test-runner.sh for per-step latency breakdown).

set -euo pipefail

# ────────────────────────────────────────
# Fail-closed trap: ANY unhandled error → deny
# ────────────────────────────────────────
emit_deny_crash() {
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"hook crashed - fail closed"}}'
  exit 0
}
trap 'emit_deny_crash' ERR

emit_allow() {
  # Empty JSON is also treated as allow; use explicit form for clarity and for tests.
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
}

emit_deny() {
  local reason="$1"
  # JSON-escape reason via jq (-n for null input, -c for compact)
  jq -nc --arg r "$reason" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# ────────────────────────────────────────
# Per-step latency checkpoint (optional)
# ────────────────────────────────────────
CHECKPOINT() {
  local label="$1"
  if [ -n "${TAD_SPIKE_LATENCY_LOG:-}" ]; then
    # macOS date doesn't support %N. python3 startup (~130ms) was dominating the
    # measurement. Perl is ~7ms startup — acceptable overhead for per-step breakdown.
    # For production (no instrumentation), this function is a no-op.
    local ns
    ns=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1e9')
    printf '%s\t%s\n' "$label" "$ns" >> "$TAD_SPIKE_LATENCY_LOG"
  fi
}

CHECKPOINT start

# ────────────────────────────────────────
# 1. Read + parse stdin
# ────────────────────────────────────────
STDIN_JSON=$(cat)

# Single jq invocation extracts 3 fields as TSV. If stdin is malformed,
# jq fails → pipefail → ERR trap → deny "hook crashed".
PARSED=$(printf '%s' "$STDIN_JSON" | jq -r '[.tool_name // "", .tool_input.file_path // "", .tool_input.content // ""] | @tsv')
CHECKPOINT jq_done

# Split TSV (handle multiline content via IFS+read -d '')
tool_name=$(printf '%s' "$PARSED" | awk -F '\t' '{print $1}')
file_path=$(printf '%s' "$PARSED" | awk -F '\t' '{print $2}')
# Content may contain tabs/newlines; take fields 3+ back
content=$(printf '%s' "$PARSED" | awk -F '\t' '{for(i=3;i<=NF;i++){if(i>3)printf "\t"; printf "%s",$i}}')

# ────────────────────────────────────────
# 2. tool_name filter
# ────────────────────────────────────────
if [ "$tool_name" != "Write" ]; then
  CHECKPOINT end_allow_tool
  emit_allow
fi

# ────────────────────────────────────────
# 3. Sentinel match (case-insensitive substring).
#    ENVIRON["CONTENT"] pattern (not -v) — -v would interpret \n escapes.
#    Env-var assignment placed on the awk command (not a preceding pipeline stage).
# ────────────────────────────────────────
if ! CONTENT="$content" awk 'BEGIN { if (index(tolower(ENVIRON["CONTENT"]), "message from blake") > 0) exit 0; exit 1 }'; then
  CHECKPOINT end_allow_nomatch
  emit_allow
fi
CHECKPOINT awk_match

# ────────────────────────────────────────
# 4. Extract slug from file_path
# ────────────────────────────────────────
slug="spike-default"
if [[ "$file_path" =~ HANDOFF-[0-9]{8}-([a-z0-9-]+) ]]; then
  slug="${BASH_REMATCH[1]}"
fi
CHECKPOINT slug_done

# ────────────────────────────────────────
# 5. Count evidence files
# ────────────────────────────────────────
evidence_dir=".tad/evidence/reviews/blake/$slug"
count=0
if [ -d "$evidence_dir" ]; then
  count=$(find "$evidence_dir" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
fi
CHECKPOINT find_done

if [ "$count" -lt 2 ]; then
  reason="Missing evidence: $evidence_dir/*.md has $count files, need >=2. Please run Layer 2 expert review before generating Message to Alex."
  CHECKPOINT end_deny
  emit_deny "$reason"
fi

CHECKPOINT end_allow_ok
emit_allow
