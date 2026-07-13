#!/bin/bash
# TAD PostToolUse Hook — Key File Write Detection
# Detects writes to TAD-managed files and injects workflow reminders.
# Triggered by: Write | Edit tools (via matcher in settings.json)
# Output: JSON with hookSpecificOutput wrapper, or empty JSON for non-TAD files.
# Exit code: always 0 (async, never blocks).
#
# ⚠️ SAFETY (NFR1): this hook MUST NEVER fail-closed. No `set -e`. Every v2
#    observational parse path tolerates malformed input and returns 0; callers
#    append `|| true`. BSD-safe regex only (no grep -P / .*? / \d). Trace JSON is
#    compact no-space (`"type":"x"`) — all membership greps use that format (NFR3).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/trace-writer.sh
source "${SCRIPT_DIR}/lib/trace-writer.sh"

# Update session-state.md metadata (compact recovery support)
# Only runs if session-state.md already exists (agent creates it; hook only updates)
update_session_state_metadata() {
  local written_file="$1"
  local state_file=".tad/active/session-state.md"

  [ -f "$state_file" ] || return 0   # agent creates; hook only updates existing

  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Escape sed metacharacters (& \ #) for # delimiter — avoids | delimiter collision
  local escaped_file
  escaped_file=$(printf '%s' "$written_file" | sed 's/[\\&#]/\\&/g')

  # Update Hook Last Touched — BSD-portable sed -i with .bak; always rm (use ; not &&)
  # Use # as delimiter to avoid | collision; $ts is always ISO format with no special chars
  if grep -q "^Hook Last Touched:" "$state_file"; then
    sed -i.bak "s#^Hook Last Touched:.*#Hook Last Touched: $ts#" "$state_file"; rm -f "${state_file}.bak"
  else
    echo "Hook Last Touched: $ts" >> "$state_file"
  fi

  # Update Last File Written — append if line missing (fallback for partial files)
  if grep -q "^Last File Written:" "$state_file"; then
    sed -i.bak "s#^Last File Written:.*#Last File Written: $escaped_file#" "$state_file"; rm -f "${state_file}.bak"
  else
    echo "Last File Written: $escaped_file" >> "$state_file"
  fi
}

# record_trace() moved to lib/common.sh (v2.0 — sourced via line 14)

# ──────────────────────────────────────────────────────────────────────────
# v2 observational trace helpers (trace-instrumentation-fix, 2026-05-30)
# Decision-level events are emitted by PARSING agent-written artifacts, not by
# agents remembering to call helpers (imperative emission proved unreliable —
# fired once in 328 events). Every helper is SAFETY-bound (NFR1): tolerant of
# malformed input, returns 0, never blocks. Dedup is per (slug, type, day).
# ──────────────────────────────────────────────────────────────────────────

_trace_file_today() { printf '%s/%s.jsonl' ".tad/evidence/traces" "$(date +%Y-%m-%d)"; }

# Extract handoff/completion slug from a file path (group 2 of the filename).
# Returns "" if the filename doesn't match the HANDOFF/COMPLETION contract (NFR4 validation).
extract_slug() {
  local base; base=$(basename "$1" 2>/dev/null) || { printf ''; return 0; }
  case "$base" in
    HANDOFF-*.md|COMPLETION-*.md) : ;;
    *) printf ''; return 0 ;;
  esac
  local s
  s=$(printf '%s' "$base" | sed -E 's/^(HANDOFF|COMPLETION)-[0-9]{8}-(.+)\.md$/\2/')
  case "$s" in
    "$base"|"") printf ''; return 0 ;;   # sed didn't match → reject
  esac
  printf '%s' "$s" | tr -d '\r\n' | tr -cd 'A-Za-z0-9._-' | cut -c1-100
}

# True (0) if today's trace already has an event of <type> carrying <slug>.
trace_already_emitted() {
  local etype="$1" eslug="$2" tf; tf=$(_trace_file_today)
  [ -n "$eslug" ] || return 1
  [ -f "$tf" ] || return 1
  grep -F "\"type\":\"${etype}\"" "$tf" 2>/dev/null | grep -qF "\"slug\":\"${eslug}\"" && return 0
  return 1
}

# Gate_result emit policy (FR2b): no prior gate_result for slug → emit;
# prior with same outcome → skip; prior with different outcome → emit (override).
gate_result_should_emit() {
  local eslug="$1" verdict="$2" tf; tf=$(_trace_file_today)
  [ -f "$tf" ] || return 0
  local existing
  existing=$(grep -F '"type":"gate_result"' "$tf" 2>/dev/null | grep -F "\"slug\":\"${eslug}\"" | tail -1)
  [ -n "$existing" ] || return 0
  local prev
  if [ "$HAS_JQ" = true ]; then
    prev=$(printf '%s' "$existing" | jq -r '.outcome // ""' 2>/dev/null)
  else
    prev=$(printf '%s' "$existing" | sed -E 's/.*"outcome":"([^"]*)".*/\1/')
  fi
  [ "$prev" = "$verdict" ] && return 1
  return 0
}

# True (0) if today's trace already has a reflexion_diagnosis for (slug, what_failed).
reflexion_already_emitted() {
  local eslug="$1" ewf="$2" tf; tf=$(_trace_file_today)
  [ -f "$tf" ] || return 1
  if [ "$HAS_JQ" = true ]; then
    jq -r --arg s "$eslug" 'select(.type=="reflexion_diagnosis" and .slug==$s)
      | (.context|fromjson|.what_failed) // empty' "$tf" 2>/dev/null \
      | grep -Fxq "$ewf" && return 0
    return 1
  fi
  grep -F '"type":"reflexion_diagnosis"' "$tf" 2>/dev/null \
    | grep -F "\"slug\":\"${eslug}\"" | grep -qF "$ewf" && return 0
  return 1
}

# FR2: parse COMPLETION frontmatter `gate3_verdict:` marker → gate_result.
# Stable machine-readable marker (Blake writes it as a Gate 3 post-step) — NOT prose.
emit_gate_result() {
  local file="$1" slug="$2"
  [ -n "$slug" ] || return 0
  [ -f "$file" ] || return 0
  local raw verdict
  raw=$(grep -E '^gate3_verdict:' "$file" 2>/dev/null | head -1)
  [ -n "$raw" ] || return 0
  verdict=$(printf '%s' "$raw" | sed -E 's/^gate3_verdict:[[:space:]]*//' \
    | tr -d '\r\n' | tr 'A-Z' 'a-z' | cut -c1-20)
  case "$verdict" in
    pass|fail|partial) ;;
    *) return 0 ;;   # empty / placeholder / invalid → skip (back-compat + FR2b timing)
  esac
  gate_result_should_emit "$slug" "$verdict" || return 0
  trace_gate_result 3 "$verdict" "Gate 3" "$slug" blake || true
}

# FR3: parse reviews/blake/<slug>/<reviewer>.md → expert_review_finding per priority.
# One event per non-zero priority; count goes in context, outcome=P<n> (top-level).
emit_expert_findings() {
  local file="$1"
  [ -f "$file" ] || return 0
  local slug; slug=$(basename "$(dirname "$file")" 2>/dev/null)
  slug=$(printf '%s' "$slug" | tr -cd 'A-Za-z0-9._-' | cut -c1-100)
  [ -n "$slug" ] || return 0
  local base; base=$(basename "$file")
  [ "$base" = "gate3-verdict.md" ] && return 0   # Blake's own verdict, not external review
  local reviewer
  case "$base" in
    code-reviewer.md)     reviewer=code-reviewer ;;
    backend-architect.md) reviewer=backend-architect ;;
    *-review.md)          reviewer=$(printf '%s' "$base" | sed -E 's/-review\.md$//') ;;
    *)                    reviewer=$(printf '%s' "$base" | sed -E 's/\.md$//') ;;
  esac
  reviewer=$(printf '%s' "$reviewer" | tr -d '\r\n' | tr -cd 'A-Za-z0-9._-' | cut -c1-60)
  [ -n "$reviewer" ] || return 0
  local n count re
  for n in 0 1 2; do
    # Count numbered-heading findings only (a heading like P-zero-dash-one with a
    # finding-id suffix), NOT table cells or prose mentions — prose/verdict-cells
    # self-trigger the parser and inflate priority counts. grep -cE counts LINES. BSD-safe.
    re="^#+[[:space:]]*P${n}-[0-9]"
    count=$(grep -cE "$re" "$file" 2>/dev/null)
    [[ "$count" =~ ^[0-9]+$ ]] || count=0
    if [ "$count" -gt 0 ]; then
      trace_expert_finding "$reviewer" "P${n}" "${count} P${n} findings" "$slug" || true
    fi
  done
}

# FR4: parse §11 Decision Summary table → decision_point per row (override-aware).
# Column-NAME-aware since 2026-05-31: the header row is scanned for the Decision/Chosen/
# Rationale column names and awk indices di/ci/ri are bound by name (was hardcoded
# a[3]/a[5]/a[6] — those positions are correct only for the 5-col layout; 4-col tables
# written before this date are column-shifted in the historical trace, NOT repaired,
# append-only).
# Multi-table-aware since 2026-07-12: a table BOUNDARY is any non-pipe line inside the
# section; the FIRST pipe row of each new table is treated as its header. A header whose
# cells include Decision+Chosen (case-insensitive) re-binds di/ci/ri and enables emission
# for that table; any other header DISABLES emission for the whole table (fixes the
# trailing non-decision table over-emitting rows via stale indices, e.g. a disposition
# table). Because headers are only recognized at table start, a mid-table data row that
# literally reads "| Decision | Chosen |" can never spuriously re-bind. Limitation
# (documented, invalid markdown edge): two tables NOT separated by any non-pipe line are
# treated as one table. Append-only trace behavior unchanged.
emit_decision_points() {
  local file="$1" slug="$2"
  [ -n "$slug" ] || return 0
  [ -f "$file" ] || return 0
  local rows
  rows=$(awk -v SEP=$'\x1e' '
    { if (incomment) { if ($0 ~ /-->/) incomment=0; next }
      if ($0 !~ /^##/ && $0 ~ /<!--/ && $0 ~ /-->/) next
      if ($0 !~ /^##/ && $0 ~ /<!--/) { incomment=1; next } }
    /^##[[:space:]]/ { insec = ($0 ~ /Decision Summary/) ? 1 : 0;
                       intable=0; emitting=0; di=0; ci=0; ri=0; next }  # reset per section
    !insec { next }
    !/^\|/ { intable=0; next }                     # non-pipe line = table boundary
    /^\|[-: |]+\|[[:space:]]*$/ { next }           # separator row
    intable==0 {                                   # FIRST pipe row of a new table = header
      intable=1; emitting=0; di=0; ci=0; ri=0      # re-bind indices per table
      n=split($0, a, "|")
      for (i=1; i<=n; i++) {
        t=a[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); lt=tolower(t)
        if (lt=="decision")  di=i
        if (lt=="chosen")    ci=i
        if (lt=="rationale") ri=i
      }
      if (di>0 && ci>0) emitting=1                 # non-decision header → table suppressed
      next                                         # header rows emit nothing
    }
    emitting==0 { next }                           # rows of a non-decision table: no emit
    {
      n=split($0, a, "|")                          # data row: read by bound indices
      d=a[di]; c=a[ci]; r=(ri>0 ? a[ri] : "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", d)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", c)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", r)
      # KEEP guard: catches blank/separator residue plus a literal header-lookalike data
      # row ("| Decision | Chosen |") inside a decision table — skipped WITHOUT re-binding.
      # Removing it emits junk + triggers parser self-trigger.
      if (d=="" || c=="" || (tolower(d)=="decision" && tolower(c)=="chosen")) next
      printf "%s%s%s%s%s\n", d, SEP, c, SEP, r
    }
  ' "$file" 2>/dev/null)
  [ -n "$rows" ] || return 0
  printf '%s\n' "$rows" | while IFS=$'\x1e' read -r d c r; do
    [ -n "$d" ] && [ -n "$c" ] || continue
    d=$(printf '%s' "$d" | tr -d '\r\n' | cut -c1-200)
    c=$(printf '%s' "$c" | tr -d '\r\n' | cut -c1-200)
    r=$(printf '%s' "$r" | tr -d '\r\n' | cut -c1-200)
    actor=agent_inferred
    # Scan BOTH Chosen and Rationale columns for override markers (a marker can land in
    # either, e.g. "用户选 passport" in the Chosen cell).
    case "$c $r" in
      *用户选*|*"user chose"*|*"human override"*|*人类决策*) actor=human_overridden ;;
    esac
    trace_decision_point "$d" "$c" "$r" "$slug" "$actor" || true
  done
}

# FR5: parse COMPLETION `## Reflexion History` blocks → reflexion_diagnosis (deduped).
emit_reflexions() {
  local file="$1" slug="$2"
  [ -n "$slug" ] || return 0
  [ -f "$file" ] || return 0
  local blocks
  blocks=$(awk -v SEP=$'\x1e' '
    function val(line){ sub(/^[^:]*:[[:space:]]*/, "", line); return line }
    { if (incomment) { if ($0 ~ /-->/) incomment=0; next }
      if ($0 !~ /^##/ && $0 ~ /<!--/ && $0 ~ /-->/) next
      if ($0 !~ /^##/ && $0 ~ /<!--/) { incomment=1; next } }
    /^##[[:space:]]/ { insec = ($0 ~ /Reflexion History/) ? 1 : 0; next }
    !insec { next }
    /what_failed:/           { wf=val($0) }
    /root_cause_hypothesis:/ { hyp=val($0) }
    /revised_approach:/      { app=val($0) }
    /confidence:/            { conf=val($0);
      if (wf != "") { printf "%s%s%s%s%s%s%s\n", wf, SEP, hyp, SEP, app, SEP, conf;
                      wf=""; hyp=""; app=""; conf="" } }
  ' "$file" 2>/dev/null)
  [ -n "$blocks" ] || return 0
  printf '%s\n' "$blocks" | while IFS=$'\x1e' read -r wf hyp app conf; do
    [ -n "$wf" ] || continue
    wf=$(printf '%s' "$wf" | tr -d '\r\n' | cut -c1-200)
    hyp=$(printf '%s' "$hyp" | tr -d '\r\n' | cut -c1-200)
    app=$(printf '%s' "$app" | tr -d '\r\n' | cut -c1-200)
    conf=$(printf '%s' "$conf" | tr -d '\r\n' | cut -c1-20)
    case "$conf" in low|medium|high) ;; *) conf=medium ;; esac
    reflexion_already_emitted "$slug" "$wf" && continue
    trace_reflexion_diagnosis "$wf" "$hyp" "$app" "$conf" "$slug" || true
  done
}

# Read stdin JSON from Claude Code
read_stdin_json

# Extract file_path from tool_input
FILE_PATH=$(get_json_field ".tool_input.file_path" || echo "")

# If file_path extraction failed, exit silently
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  output_empty
  exit 0
fi

# Pattern matching against TAD-managed files
# Patterns use *.tad/* to match both absolute (/path/.tad/) and relative (.tad/) paths
case "$FILE_PATH" in
  *.tad/active/handoffs/HANDOFF-*.md)
    update_session_state_metadata "$FILE_PATH"
    _slug=$(extract_slug "$FILE_PATH")
    if [ -n "$_slug" ]; then
      # FR1: dedup handoff_created per (slug, day) — kills the 6x over-fire.
      if ! trace_already_emitted "handoff_created" "$_slug"; then
        TRACE_SLUG="$_slug" record_trace "handoff_created" "$FILE_PATH" "" || true
      fi
      # FR4: emit §11 decisions once per (slug, day) — independent decision_point dedup.
      # Captures the case where §11 was ABSENT on the first write and added in a later
      # same-day edit (no prior decision_point yet). Limitation (Decision 7 per-(slug,day)
      # granularity, accepted): rows ADDED after decisions were already emitted today are
      # NOT re-captured.
      if ! trace_already_emitted "decision_point" "$_slug"; then
        emit_decision_points "$FILE_PATH" "$_slug" || true
      fi
    else
      record_trace "handoff_created" "$FILE_PATH" "" || true   # malformed slug → legacy emit
    fi
    output_response "PostToolUse" "Handoff created. BEFORE sending to Blake: 1. Call 2+ expert sub-agents (code-reviewer REQUIRED + 1 domain expert) 2. Fix ALL P0 issues from expert review 3. Run /gate 2 4. Generate Blake message (Step 7). Skipping expert review = VIOLATION."
    ;;
  *.tad/active/handoffs/COMPLETION-*.md)
    update_session_state_metadata "$FILE_PATH"
    _slug=$(extract_slug "$FILE_PATH")
    # FR2b: dedup task_completed per (slug, day) — COMPLETION is written then re-edited
    # (to add gate3_verdict), each write must not re-emit task_completed.
    if [ -n "$_slug" ]; then
      if ! trace_already_emitted "task_completed" "$_slug"; then
        TRACE_SLUG="$_slug" record_trace "task_completed" "$FILE_PATH" "" || true
      fi
    else
      record_trace "task_completed" "$FILE_PATH" "" || true
    fi
    # FR2: gate_result from frontmatter marker (only after Blake fills it post-Gate-3).
    emit_gate_result "$FILE_PATH" "$_slug" || true
    # FR5: reflexion_diagnosis from ## Reflexion History blocks (deduped).
    emit_reflexions "$FILE_PATH" "$_slug" || true
    output_response "PostToolUse" "COMPLETION report detected. You MUST run /gate 3 before sending results to Alex. Gate 3 is MANDATORY, not optional. The pre-gate hook will BLOCK /gate 3 if evidence is missing. Gate 3 includes Knowledge Assessment — if you learned anything project-specific, record it to .tad/project-knowledge/ BEFORE running Gate 3."
    ;;
  */NEXT.md|NEXT.md)
    output_response "PostToolUse" "NEXT.md updated."
    ;;
  *.tad/active/epics/EPIC-*.md)
    output_response "PostToolUse" "Epic updated. Check if phase status changed."
    ;;
  *.tad/project-knowledge/*.md)
    output_response "PostToolUse" "Knowledge file updated."
    ;;
  *.tad/evidence/ralph-loops/*_state.yaml)
    output_response "PostToolUse" "Ralph Loop state detected. MANDATORY workflow reminder: 1. Layer 1: build + test + lint + tsc (ALL must pass) 2. Layer 2: code-reviewer + test-runner sub-agents (P0=0 required) 3. *complete to write COMPLETION report 4. /gate 3 formal quality check (Hook will BLOCK if evidence missing) 5. Message to Alex. SKIPPING ANY STEP = VIOLATION."
    ;;
  *.tad/active/research/*)
    output_empty
    ;;
  *.tad/evidence/traces/*)
    # CRITICAL: This branch MUST appear before *.tad/evidence/* to prevent infinite recursion
    output_empty
    ;;
  *.tad/evidence/reviews/blake/*/*.md)
    # FR3: parse expert review evidence → expert_review_finding events.
    # MUST stay between the traces guard (above) and evidence/* (below) — first-match-wins.
    # Still emits evidence_created afterwards to preserve existing behavior.
    emit_expert_findings "$FILE_PATH" || true
    record_trace "evidence_created" "$FILE_PATH" "" || true
    output_empty
    ;;
  *.tad/evidence/*)
    record_trace "evidence_created" "$FILE_PATH" ""
    output_empty
    ;;
  *)
    output_empty
    ;;
esac

exit 0
