#!/bin/bash
# askuser-capture.sh — PostToolUse logger for AskUserQuestion (Phase 5 P5.2, 2026-04-25)
# Reads stdin envelope, derives slug from active handoff filename (NOT env var),
# appends one JSONL line to .tad/evidence/decisions/{date}.jsonl.
#
# Privacy boundary (NFR3): when selection NOT in original options.label list,
# JSONL line records is_other:true but does NOT include the user's free-text content.
#
# Anti-Epic-1 (NFR4): always exit 0. Never block tool round-trip.
#
# Slug single source of truth: .tad/active/handoffs/HANDOFF-*.md filename
# scanned via cwd from envelope (BA-P0-1, NOT TAD_HANDOFF_SLUG env var).

set -u   # NOT set -e — we tolerate missing fields, never block

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# ── Read stdin envelope ─────────────────────────────────────────────────
read_stdin_json

# Empty stdin → exit 0 silently (no JSONL write)
if [ -z "${STDIN_JSON:-}" ]; then
  exit 0
fi

# ── Verify jq present (graceful fallback if not) ───────────────────────
# Without jq, we can't reliably parse nested arrays — skip with stderr WARN.
# This matches the trace-step.sh fallback shape but is conservative for capture.
if [ "$HAS_JQ" != true ]; then
  echo "askuser-capture: jq not available; skipping capture (no JSONL write)" >&2
  exit 0
fi

# ── Single-pass jq extraction (perf: avoid 6+ jq spawns per architecture.md
#    "Hook Performance: Single-awk vs Per-item grep Loop - 2026-04-07")
# Extract all needed fields in ONE jq invocation, output as 7-line block
# separated by ASCII RS (\x1E — bash $() preserves; never appears in JSON).
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# This jq:
# - validates JSON (errors out via 2>/dev/null + empty PARSED below)
# - extracts session_id, cwd, question, multiSelect, options-as-json, selection
# - computes is_other inline (selection NOT in options labels)
# - emits 7 lines separated by \x1E (RS)
PARSED=$(printf '%s' "$STDIN_JSON" | jq -r '
  . as $env
  | (.tool_input.questions[0] // {}) as $q
  | (($q.options // []) | map(.label // "")) as $labels
  | ($q.question // "") as $qtext
  | ($q.multiSelect // false) as $msel
  | (
      if ($env.tool_response // null) != null and ($env.tool_response.answers // null) != null then
        ($env.tool_response.answers[$qtext] // null) as $direct
        | if $direct != null then $direct
          elif (($env.tool_response.answers) | type) == "object" then
            ($env.tool_response.answers | to_entries | (.[0].value // ""))
          else "" end
      else "" end
    ) as $raw_sel
  | (
      # is_other detection — elementwise for arrays, scalar for strings
      # (P1 fix from code-reviewer 2026-04-25: "P, Q" join was misclassifying
      # all multi-select selections as is_other:true)
      if ($raw_sel | type) == "array" then
        ([$raw_sel[] | tostring | select(. as $e | ($labels | index($e)) == null)] | length > 0)
      elif ($raw_sel | type) == "string" and $raw_sel != "" then
        ($labels | index($raw_sel)) == null
      else false end
    ) as $is_other
  | (
      # Display selection — joined string for arrays, scalar for strings.
      # Note: when $is_other=true, the shell layer below will replace this
      # with the literal "<other>" to enforce privacy boundary (NFR3).
      if ($raw_sel | type) == "array" then ($raw_sel | map(tostring) | join(", "))
      elif ($raw_sel | type) == "string" then $raw_sel
      else "" end
    ) as $sel
  | [
      ($env.session_id // ""),
      ($env.cwd // ""),
      $qtext,
      ($msel | tostring),
      ($labels | tojson),
      $sel,
      ($is_other | tostring)
    ]
  | join("")
' 2>/dev/null)

if [ -z "$PARSED" ]; then
  echo "askuser-capture: malformed JSON or missing tool_input; skipping" >&2
  exit 0
fi

# Split via IFS=\x1E (RS)
IFS=$'\x1e' read -r SESSION_ID ENV_CWD QUESTION MULTI_SELECT OPTIONS_JSON SELECTION IS_OTHER <<< "$PARSED"
OPTIONS_JSON="${OPTIONS_JSON:-[]}"

# Privacy boundary (NFR3): when is_other=true, REPLACE selection with the literal
# string "<other>" so the JSONL line carries the boolean signal but NOT the
# user's free-text content. Future *evolve sees "user picked Other" but never
# reads what they typed.
if [ "$IS_OTHER" = true ]; then
  SELECTION="<other>"
fi

# ── Derive slug from active handoff filename (BA-P0-1) ─────────────────
SLUG="null"  # JSON literal null when no active handoff
SCAN_DIR=""
if [ -n "$ENV_CWD" ] && [ -d "$ENV_CWD/.tad/active/handoffs" ]; then
  SCAN_DIR="$ENV_CWD/.tad/active/handoffs"
elif [ -d ".tad/active/handoffs" ]; then
  # Fallback to pwd-relative if envelope lacks cwd
  SCAN_DIR=".tad/active/handoffs"
fi

if [ -n "$SCAN_DIR" ]; then
  # Collect HANDOFF-*.md files (excludes COMPLETION-*.md, README, etc.)
  # shellcheck disable=SC2206
  matches=( "$SCAN_DIR"/HANDOFF-*.md )
  if [ -e "${matches[0]}" ] 2>/dev/null; then
    count=${#matches[@]}
    if [ "$count" -eq 1 ]; then
      candidate="${matches[0]}"
    else
      # Multiple active handoffs: pick newest mtime (BA-P0-1 contract)
      echo "askuser-capture: $count active handoffs in $SCAN_DIR; using newest mtime" >&2
      # macOS BSD stat -f%m + GNU stat -c%Y differ; try BSD first then GNU
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
    # Extract slug from HANDOFF-{date}-{slug}.md filename
    fname=$(basename "$candidate")
    raw_slug=$(printf '%s' "$fname" | sed -E 's/^HANDOFF-[0-9]{8}-(.+)\.md$/\1/')
    if [ "$raw_slug" != "$fname" ]; then
      # Whitelist (matches trace-step.sh + layer2-audit.sh — defense against path traversal)
      if [[ "$raw_slug" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$ ]]; then
        SLUG="\"$raw_slug\""
      else
        echo "askuser-capture: slug failed whitelist: $raw_slug" >&2
      fi
    fi
  fi
fi

# ── Write JSONL line ────────────────────────────────────────────────────
DECISIONS_DIR=".tad/evidence/decisions"
TODAY=$(date +%Y-%m-%d)
OUTFILE="$DECISIONS_DIR/$TODAY.jsonl"

mkdir -p "$DECISIONS_DIR" 2>/dev/null || {
  echo "askuser-capture: mkdir failed for $DECISIONS_DIR" >&2
  exit 0
}

# Atomic append via tmpfile + cat >> (avoids half-line on signal kill — EC5)
TMPFILE=$(mktemp -t askuser-capture.XXXXXX 2>/dev/null) || TMPFILE="/tmp/askuser-capture.$$.tmp"

jq -nc \
  --arg ts "$TS" \
  --arg session_id "$SESSION_ID" \
  --argjson slug "$SLUG" \
  --arg question "$QUESTION" \
  --argjson options "$OPTIONS_JSON" \
  --arg selection "$SELECTION" \
  --argjson is_other "$IS_OTHER" \
  --argjson multi_select "$MULTI_SELECT" \
  '{ts:$ts, session_id:$session_id, slug:$slug, question:$question, options:$options, selection:$selection, is_other:$is_other, multi_select:$multi_select}' \
  > "$TMPFILE" 2>/dev/null

if [ -s "$TMPFILE" ]; then
  cat "$TMPFILE" >> "$OUTFILE"
fi
rm -f "$TMPFILE"

exit 0
