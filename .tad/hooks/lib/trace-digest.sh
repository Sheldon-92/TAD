#!/usr/bin/env bash
# trace-digest.sh — Per-slug trace summary CLI (Phase 5 P5.4, 2026-04-25)
# Reads .tad/evidence/traces/per-handoff/{slug}/*.jsonl, outputs digest.
# Mirrors layer2-audit.sh interface: positional slug arg, exit 0/1/2.
#
# Exit codes:
#   0 PASS   — slug dir found, digest emitted, no anomalies (orphans=0 AND failed=0)
#   1 FAIL   — slug dir found, but orphans>0 OR failed>0 (red字 warning to stderr)
#   2 N/A    — slug dir missing OR slug invalid (advisory not failure)
#
# Anti-Epic-1 (NFR4): never registered as hook; CLI tool only. Used by Alex
# acceptance_protocol.step4d as advisory smoke alarm.

set -uo pipefail
IFS=$'\n\t'

# ── ANSI color (matches layer2-audit.sh) ───────────────────────────────
_red=""; _reset=""
if [ -z "${NO_COLOR:-}" ] && [ -t 2 ]; then
  _red=$'\033[31m'; _reset=$'\033[0m'
fi

_err() { printf '%s%s%s\n' "$_red" "$*" "$_reset" >&2; }

# ── Arg parse + slug whitelist (matches layer2-audit.sh + askuser-capture.sh) ──
if [ $# -ne 1 ]; then
  _err "usage: $(basename -- "$0") <slug>"
  exit 2
fi
slug_raw="$1"
slug_disp="${slug_raw:0:64}"  # truncate for stderr (anti-DoS)

# Strict whitelist: ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$
# Anchored both ends; first/last char [a-zA-Z0-9_] (no leading/trailing dash).
if ! [[ "$slug_raw" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$ ]]; then
  _err "trace-digest N/A: invalid slug '${slug_disp}' (rejects path traversal)"
  exit 2
fi
slug="$slug_raw"

# ── Target dir check ───────────────────────────────────────────────────
dir=".tad/evidence/traces/per-handoff/${slug}"
if [ ! -d "$dir" ]; then
  _err "trace-digest N/A: per-handoff trace dir missing: ${dir}"
  exit 2
fi

# Find all .jsonl files (any date)
jsonl_files=( "$dir"/*.jsonl )
if [ ! -e "${jsonl_files[0]}" ]; then
  _err "trace-digest N/A: no .jsonl files in ${dir}"
  exit 2
fi

# ── Aggregate counts via single jq pass ────────────────────────────────
# Read all .jsonl files line-by-line, count by type + status.
# Use jq slurp mode (-s) won't work since each line is its own JSON.
# Instead: cat all → jq -c per-line counts.
HAS_JQ=false
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=true
fi

if [ "$HAS_JQ" = true ]; then
  # jq -s combines all input objects into array; we then aggregate.
  # Each line is one event; .jsonl files concatenate cleanly via cat.
  STATS=$(cat "$dir"/*.jsonl 2>/dev/null | jq -s '
    . as $all
    | (
        {
          step_start: ([$all[] | select(.type == "step_start")] | length),
          step_end_completed: ([$all[] | select(.type == "step_end" and .status == "completed")] | length),
          step_end_failed: ([$all[] | select(.type == "step_end" and .status == "failed")] | length),
          step_end_skipped: ([$all[] | select(.type == "step_end" and .status == "skipped")] | length),
          most_recent_ts: ([$all[].ts] | max // ""),
          starts_keys: ([$all[] | select(.type == "step_start") | "\(.domain)/\(.capability)/\(.step)"] | unique),
          ends_keys:   ([$all[] | select(.type == "step_end")   | "\(.domain)/\(.capability)/\(.step)"] | unique)
        }
      )
    | . + {orphans: ((.starts_keys + .ends_keys | unique | length) - (.ends_keys | length))}
  ' 2>/dev/null)

  if [ -z "$STATS" ]; then
    _err "trace-digest N/A: failed to parse JSONL events from ${dir}"
    exit 2
  fi

  STEP_START=$(printf '%s' "$STATS" | jq -r '.step_start')
  STEP_COMPLETED=$(printf '%s' "$STATS" | jq -r '.step_end_completed')
  STEP_FAILED=$(printf '%s' "$STATS" | jq -r '.step_end_failed')
  STEP_SKIPPED=$(printf '%s' "$STATS" | jq -r '.step_end_skipped')
  ORPHANS=$(printf '%s' "$STATS" | jq -r '.orphans')
  MOST_RECENT=$(printf '%s' "$STATS" | jq -r '.most_recent_ts')
else
  # Fallback: grep-based counts (less precise but sufficient for advisory)
  STEP_START=$(grep -hc '"type":"step_start"' "$dir"/*.jsonl 2>/dev/null | awk '{s+=$1}END{print s+0}')
  STEP_COMPLETED=$(grep -hcE '"type":"step_end".*"status":"completed"' "$dir"/*.jsonl 2>/dev/null | awk '{s+=$1}END{print s+0}')
  STEP_FAILED=$(grep -hcE '"type":"step_end".*"status":"failed"' "$dir"/*.jsonl 2>/dev/null | awk '{s+=$1}END{print s+0}')
  STEP_SKIPPED=$(grep -hcE '"type":"step_end".*"status":"skipped"' "$dir"/*.jsonl 2>/dev/null | awk '{s+=$1}END{print s+0}')
  STEP_END=$((STEP_COMPLETED + STEP_FAILED + STEP_SKIPPED))
  ORPHANS=$((STEP_START - STEP_END))
  MOST_RECENT="(unknown — jq required for precise timestamp aggregation)"
fi

# ── Print digest ───────────────────────────────────────────────────────
printf "Trace digest for: %s\n" "$slug"
printf "  step_start events: %s\n" "$STEP_START"
printf "  step_end completed: %s\n" "$STEP_COMPLETED"
printf "  step_end failed: %s\n" "$STEP_FAILED"
printf "  step_end skipped: %s\n" "$STEP_SKIPPED"
printf "  orphaned starts (no end): %s" "$ORPHANS"
if [ "${ORPHANS:-0}" -gt 0 ] 2>/dev/null; then
  printf "   ⚠️  may indicate skipped step\n"
else
  printf "\n"
fi
printf "  Most recent: %s\n" "$MOST_RECENT"

# ── Verdict ────────────────────────────────────────────────────────────
# PASS only when no anomalies (orphans=0 AND failed=0).
# step_end_skipped is acceptable (legitimate skip declaration).
if [ "${ORPHANS:-0}" -eq 0 ] 2>/dev/null && [ "${STEP_FAILED:-0}" -eq 0 ] 2>/dev/null; then
  exit 0
fi

# Anomaly: orphans>0 OR failed>0 → exit 1 (smoke alarm to step4d)
_err "trace-digest WARN: anomalies detected (orphans=${ORPHANS}, failed=${STEP_FAILED}) — review whether Domain Pack steps were skipped or failed silently"
exit 1
