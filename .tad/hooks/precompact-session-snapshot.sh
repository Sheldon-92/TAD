#!/bin/bash
# TAD PreCompact Hook — mechanical session-state snapshot (Layer 0)
#
# Fires before every context compaction (manual /compact and auto-compact).
# Writes an INDEPENDENT snapshot file per compaction:
#   .tad/active/precompact/snapshot-{YYYYMMDD-HHMMSS}-{sid8}.md
# Reader rule: newest-wins (filename timestamp prefix = time order). Keeps newest 5.
#
# CONTRACT (consumed by CLAUDE.md §4.5 recovery flow — field renames are breaking):
#   When / Trigger / Session / Git HEAD / Git / Active handoffs / Active epics
#
# SAFETY (2026-04-15 principle): fail-open smoke alarm, NOT a fire suppressor.
#   - ALWAYS exit 0 — any internal error must never block compaction.
#   - MUST NOT deny/block anything. MUST NOT write session-state.md or any
#     agent-maintained file. Only write targets: own snapshot files + prune
#     inside .tad/active/precompact/ + .hook-debug.log breadcrumb + T1 probe tee.
#   - Discriminable failure: derivation failures render as "(unavailable: reason)"
#     fields; if even the snapshot file cannot be written, append one line to
#     .tad/active/precompact/.hook-debug.log ("{ts} snapshot-skipped: {reason}").
#
# FR7 write discipline: NO `set -e`; every $() has a fallback; the real snapshot
# file is only ever touched by one final atomic `mv` (temp assembled first).

SNAP_DIR=".tad/active/precompact"
DEBUG_LOG="${SNAP_DIR}/.hook-debug.log"
EVIDENCE_DIR=".tad/evidence/hooks/precompact-snapshot"

# Breadcrumb helper (best-effort; never fails the hook)
log_skip() {
  local reason="$1"
  local ts
  ts=$(date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || echo "unknown-time")
  mkdir -p "$SNAP_DIR" 2>/dev/null || return 0
  echo "${ts} snapshot-skipped: ${reason}" >> "$DEBUG_LOG" 2>/dev/null || true
}

# --- Read stdin JSON (may be empty) ---
STDIN_JSON=$(cat 2>/dev/null || echo "")

# --- T1 probe (built-in): tee raw stdin so the first REAL compact auto-produces
#     the T1 evidence (overwrite, best-effort). ---
if mkdir -p "$EVIDENCE_DIR" 2>/dev/null; then
  printf '%s' "$STDIN_JSON" > "${EVIDENCE_DIR}/last-stdin.json" 2>/dev/null || true
fi

# --- Field extraction (jq preferred, grep fallback; every path has a fallback) ---
HAS_JQ=false
command -v jq >/dev/null 2>&1 && HAS_JQ=true

json_field() {
  # $1 = top-level field name; prints "" when missing
  local key="$1"
  if [ "$HAS_JQ" = true ]; then
    printf '%s' "$STDIN_JSON" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null || echo ""
  else
    printf '%s' "$STDIN_JSON" | grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" 2>/dev/null \
      | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' || echo ""
  fi
}

TRIGGER=$(json_field "trigger" || echo "")
[ -n "$TRIGGER" ] || TRIGGER="(unavailable: no-trigger-field)"

SESSION_ID=$(json_field "session_id" || echo "")
if [ -n "$SESSION_ID" ]; then
  SID8=$(printf '%s' "$SESSION_ID" | cut -c1-8 2>/dev/null || echo "unknown")
else
  SID8="unknown"
fi
[ -n "$SID8" ] || SID8="unknown"

# --- Timestamps ---
TS=$(date '+%Y%m%d-%H%M%S' 2>/dev/null || echo "")
if [ -z "$TS" ]; then
  log_skip "date-unavailable"
  exit 0
fi
WHEN=$(date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || echo "(unavailable: date)")

# --- Git facts (read-only; each derivation has a fallback; multi-line output is
#     ALWAYS flattened to a single line per FR1) ---
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "")
if [ -n "$GIT_SHA" ]; then
  GIT_SUBJECT=$(git log -1 --pretty=%s 2>/dev/null | head -1 | cut -c1-60 || echo "")
  GIT_HEAD_LINE="${GIT_SHA} ${GIT_SUBJECT}"
else
  GIT_HEAD_LINE="(unavailable: git-rev-parse-failed)"
fi

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -n "$GIT_BRANCH" ] || GIT_BRANCH="(unavailable: git-branch)"

# ahead/behind vs upstream (upstream may not exist — that is a normal state)
AB_RAW=$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null | tr '\t' ' ' || echo "")
if [ -n "$AB_RAW" ]; then
  BEHIND=$(printf '%s' "$AB_RAW" | awk '{print $1}' 2>/dev/null || echo "?")
  AHEAD=$(printf '%s' "$AB_RAW" | awk '{print $2}' 2>/dev/null || echo "?")
else
  AHEAD="?"
  BEHIND="?"
fi

STATUS_RAW=$(git status --porcelain 2>/dev/null || echo "__GIT_STATUS_FAILED__")
if [ "$STATUS_RAW" = "__GIT_STATUS_FAILED__" ]; then
  N_MODIFIED="(unavailable: git-status)"
  N_UNTRACKED="(unavailable: git-status)"
else
  # NOTE: grep -c prints "0" AND exits 1 on zero matches — fallback must be
  # output-neutral (|| true), then normalize empty to "?".
  N_MODIFIED=$(printf '%s\n' "$STATUS_RAW" | grep -c '^[^?[:space:]]\|^.[^?[:space:]]' 2>/dev/null || true)
  [ -n "$N_MODIFIED" ] || N_MODIFIED="?"
  N_UNTRACKED=$(printf '%s\n' "$STATUS_RAW" | grep -c '^??' 2>/dev/null || true)
  [ -n "$N_UNTRACKED" ] || N_UNTRACKED="?"
fi

# --- Active handoffs / epics (count + single-line space-joined names per FR1) ---
list_dir() {
  # $1 = glob; prints "count<US>joined-names" using \x1F separator (never newline)
  local names count
  names=$(ls -1 $1 2>/dev/null | while read -r f; do basename "$f" 2>/dev/null; done | tr '\n' ' ' | sed 's/ $//' || echo "")
  if [ -n "$names" ]; then
    count=$(printf '%s ' "$names" | tr ' ' '\n' | grep -c . 2>/dev/null || echo "?")
  else
    count=0
  fi
  printf '%s\x1f%s' "$count" "$names"
}

HANDOFF_RAW=$(list_dir ".tad/active/handoffs/HANDOFF-*.md" || printf '?\x1f(unavailable: ls)')
HANDOFF_COUNT=${HANDOFF_RAW%%$'\x1f'*}
HANDOFF_NAMES=${HANDOFF_RAW#*$'\x1f'}

EPIC_RAW=$(list_dir ".tad/active/epics/EPIC-*.md" || printf '?\x1f(unavailable: ls)')
EPIC_COUNT=${EPIC_RAW%%$'\x1f'*}
EPIC_NAMES=${EPIC_RAW#*$'\x1f'}

# --- Assemble in temp, then single atomic mv (FR7) ---
if ! mkdir -p "$SNAP_DIR" 2>/dev/null; then
  log_skip "mkdir-failed: ${SNAP_DIR}"
  exit 0
fi

TMP=$(mktemp "${SNAP_DIR}/.snapshot-tmp.XXXXXX" 2>/dev/null || echo "")
if [ -z "$TMP" ]; then
  log_skip "mktemp-failed"
  exit 0
fi
trap 'rm -f "$TMP" 2>/dev/null' EXIT

# 8-line template (header + 7 contract fields) — line count is asserted by AC5.
{
  echo "# PreCompact Snapshot (mechanical — auto-written, do not edit)"
  echo "- When: ${WHEN}"
  echo "- Trigger: ${TRIGGER}"
  echo "- Session: ${SID8} (diagnostic only; not a match key across compaction boundary — readers use newest-wins)"
  echo "- Git HEAD: ${GIT_HEAD_LINE}"
  echo "- Git: ${GIT_BRANCH} | ahead ${AHEAD} / behind ${BEHIND} origin | ${N_MODIFIED} modified, ${N_UNTRACKED} untracked"
  echo "- Active handoffs (${HANDOFF_COUNT}): ${HANDOFF_NAMES}"
  echo "- Active epics (${EPIC_COUNT}): ${EPIC_NAMES}"
} > "$TMP" 2>/dev/null

if [ ! -s "$TMP" ]; then
  log_skip "temp-assembly-failed"
  exit 0
fi

FINAL="${SNAP_DIR}/snapshot-${TS}-${SID8}.md"
chmod 644 "$TMP" 2>/dev/null || true  # mktemp defaults to 600; snapshots are plain readable notes
if ! mv "$TMP" "$FINAL" 2>/dev/null; then
  log_skip "mv-failed: ${FINAL}"
  exit 0
fi

# --- Prune: keep newest 5 snapshot-*.md by name order (timestamp prefix = time
#     order). Deletion failure must not affect exit 0 (FR6). ---
SNAP_LIST=$(ls -1 "${SNAP_DIR}"/snapshot-*.md 2>/dev/null | LC_ALL=C sort || echo "")
if [ -n "$SNAP_LIST" ]; then
  TOTAL=$(printf '%s\n' "$SNAP_LIST" | grep -c . 2>/dev/null || true)
  [ -n "$TOTAL" ] || TOTAL="0"
  if [ "$TOTAL" -gt 5 ] 2>/dev/null; then
    EXCESS=$((TOTAL - 5))
    printf '%s\n' "$SNAP_LIST" | head -n "$EXCESS" | while read -r old; do
      [ -n "$old" ] && rm -f "$old" 2>/dev/null || true
    done
  fi
fi

exit 0
