#!/bin/bash
# TAD Dream Scanner — extract knowledge patterns from trace JSONL
# Usage: bash .tad/hooks/lib/dream-scanner.sh
# Reads traces from BOTH evidence/traces/ and archive/traces/ (rotation-safe)
# Outputs CAND-*.md candidates to .tad/active/dream-candidates/
# Exit 0 always (advisory, never blocks)
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

STATE_FILE=".tad/active/dream-state.yaml"
CANDIDATE_DIR=".tad/active/dream-candidates"
TRACE_DIRS=(".tad/evidence/traces" ".tad/archive/traces")

mkdir -p "$CANDIDATE_DIR"

# ── Phase 1: Load & Filter ──────────────────────────────────────

LAST_SCAN_TS=""
if [ ! -f "$STATE_FILE" ]; then
  cat > "$STATE_FILE" << 'YAML_EOF'
last_scan_ts: null
last_scan_candidates: 0
total_accepted: 0
total_rejected: 0
YAML_EOF
fi
LAST_SCAN_TS=$(grep '^last_scan_ts:' "$STATE_FILE" | sed 's/^last_scan_ts:[[:space:]]*//' | tr -d '"')
[ "$LAST_SCAN_TS" = "null" ] && LAST_SCAN_TS=""

MERGED_TRACES=$(mktemp)
trap 'rm -f "$MERGED_TRACES" 2>/dev/null' EXIT

for dir in "${TRACE_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  for f in "$dir"/*.jsonl; do
    [ -f "$f" ] || continue
    cat "$f" >> "$MERGED_TRACES"
  done
done

if [ ! -s "$MERGED_TRACES" ]; then
  echo "Dream scan complete: 0 new candidates (no trace data)"
  # Update state even with 0 entries
  NOW_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  if [ -f "$STATE_FILE" ]; then
    sed -i.bak "s/^last_scan_ts:.*/last_scan_ts: \"$NOW_TS\"/" "$STATE_FILE"; rm -f "${STATE_FILE}.bak"
    sed -i.bak "s/^last_scan_candidates:.*/last_scan_candidates: 0/" "$STATE_FILE"; rm -f "${STATE_FILE}.bak"
  fi
  exit 0
fi

# Filter to entries newer than last scan
FILTERED_TRACES=$(mktemp)
trap 'rm -f "$MERGED_TRACES" "$FILTERED_TRACES" 2>/dev/null' EXIT

if [ -n "$LAST_SCAN_TS" ] && [ "$HAS_JQ" = true ]; then
  jq -c --arg cutoff "$LAST_SCAN_TS" 'select(.ts > $cutoff)' "$MERGED_TRACES" > "$FILTERED_TRACES" 2>/dev/null || cp "$MERGED_TRACES" "$FILTERED_TRACES"
else
  cp "$MERGED_TRACES" "$FILTERED_TRACES"
fi

NEW_COUNT=$(wc -l < "$FILTERED_TRACES" | tr -d ' ')
if [ "$NEW_COUNT" -eq 0 ]; then
  echo "Dream scan complete: 0 new candidates (no new entries since last scan)"
  NOW_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  if [ -f "$STATE_FILE" ]; then
    sed -i.bak "s/^last_scan_ts:.*/last_scan_ts: \"$NOW_TS\"/" "$STATE_FILE"; rm -f "${STATE_FILE}.bak"
    sed -i.bak "s/^last_scan_candidates:.*/last_scan_candidates: 0/" "$STATE_FILE"; rm -f "${STATE_FILE}.bak"
  fi
  exit 0
fi

# ── Phase 2: Pattern Detection (4 passes) ───────────────────────

CANDIDATE_COUNT=0
NOW_DATE=$(date +%Y-%m-%d)

generate_candidate() {
  local signal_type="$1" title="$2" discovery="$3" action="$4" evidence="$5" scope_tag="$6" confidence="$7"
  local ts_suffix
  ts_suffix=$(date +%H%M%S)
  # Add sub-second uniqueness via counter
  CANDIDATE_COUNT=$((CANDIDATE_COUNT + 1))
  local padded
  padded=$(printf '%02d' "$CANDIDATE_COUNT")
  local fname="CAND-${NOW_DATE}-${ts_suffix}${padded}.md"

  cat > "$CANDIDATE_DIR/$fname" <<CAND_EOF
---
type: dream_candidate
created: ${NOW_DATE}
source_events: ["${evidence}"]
signal_type: ${signal_type}
scope_tag: ${scope_tag}
confidence: ${confidence}
status: pending
---

### ${title} — ${NOW_DATE}
- **Context**: Detected by dream-scanner from trace analysis
- **Discovery**: ${discovery}
- **Action**: ${action}
- **Evidence**: ${evidence}
CAND_EOF
}

classify_scope() {
  local file_field="$1" slug_field="$2" decision_text="${3:-}"
  if [ -n "$file_field" ]; then
    case "$file_field" in
      *.claude/skills/*|*.tad/hooks/*) echo "framework"; return ;;
    esac
  fi
  if [ -n "$slug_field" ]; then
    case "$slug_field" in
      *capability-pack*|*skill*|*hook*|*trace*|*evolve*|*dream*|*registry*) echo "framework"; return ;;
    esac
  fi
  if [ -n "$decision_text" ]; then
    # TAD-specific framework signals ONLY — generic words (sync/schema) over-classify
    # to framework, which fans out cross-project in *evolve (backend-architect P1-2).
    case "$decision_text" in
      *"trace schema"*|*emission*|*观测式*|*发射机制*) echo "framework"; return ;;
    esac
  fi
  echo "project"
}

if [ "$HAS_JQ" = true ]; then

  # ── Pass A: Recurring failures ──
  # Group reflexion_diagnosis by what_failed (double-parse in single jq), find ≥2
  PASS_A_RESULT=$(jq -r '
    select(.type == "reflexion_diagnosis" and .slug != null and .slug != "")
    | (.context | fromjson | .what_failed) // empty' "$FILTERED_TRACES" 2>/dev/null \
    | sort | uniq -c | sort -rn \
    | awk '$1 >= 2 {$1=""; sub(/^ +/,""); print}') || true

  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    # Get slug and file from first matching event for scope classification
    match_info=$(jq -r --arg p "$pattern" '
      select(.type == "reflexion_diagnosis" and .slug != null and .slug != "")
      | select((.context | fromjson | .what_failed) == $p)
      | "\(.file // "")\t\(.slug // "")"' "$FILTERED_TRACES" 2>/dev/null | head -1)
    match_file=$(echo "$match_info" | cut -f1)
    match_slug=$(echo "$match_info" | cut -f2)
    scope=$(classify_scope "$match_file" "$match_slug")

    generate_candidate \
      "recurring_failure" \
      "Recurring failure: $pattern" \
      "Pattern '$pattern' appeared in ≥2 reflexion_diagnosis events" \
      "Investigate root cause — may indicate a systemic issue worth documenting" \
      "reflexion_diagnosis events matching '$pattern'" \
      "$scope" \
      "medium"
  done <<< "$PASS_A_RESULT"

  # ── Pass B: Unresolved escalations ──
  # gate_result fail without matching pass for same slug
  FAIL_SLUGS=$(jq -r 'select(.type == "gate_result" and .outcome == "fail" and .slug != null and .slug != "") | .slug' "$FILTERED_TRACES" 2>/dev/null | sort -u)
  PASS_SLUGS=$(jq -r 'select(.type == "gate_result" and .outcome == "pass" and .slug != null and .slug != "") | .slug' "$FILTERED_TRACES" 2>/dev/null | sort -u)

  while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    if ! echo "$PASS_SLUGS" | grep -qxF "$slug"; then
      match_file=$(jq -r --arg s "$slug" 'select(.type == "gate_result" and .slug == $s) | .file // ""' "$FILTERED_TRACES" 2>/dev/null | head -1)
      scope=$(classify_scope "$match_file" "$slug")
      generate_candidate \
        "unresolved_escalation" \
        "Unresolved gate failure: $slug" \
        "Gate failed for slug '$slug' with no subsequent pass recorded" \
        "Check if this task was abandoned, redesigned, or needs attention" \
        "gate_result fail for slug '$slug'" \
        "$scope" \
        "low"
    fi
  done <<< "$FAIL_SLUGS"

  # ── Pass C: Human overrides ──
  # Process each event as compact JSON to avoid tab-collapse in read
  jq -c 'select(.type == "decision_point" and .actor_tag == "human_overridden")' "$FILTERED_TRACES" 2>/dev/null > "${FILTERED_TRACES}.passC" || true
  while IFS= read -r event_json; do
    [ -z "$event_json" ] && continue
    slug=$(echo "$event_json" | jq -r '.slug // ""')
    file=$(echo "$event_json" | jq -r '.file // ""')
    decision=$(echo "$event_json" | jq -r '(.context | (try fromjson catch null) | .decision?) // "unknown"' 2>/dev/null)
    [ "$decision" = "unknown" ] || [ -z "$decision" ] && continue
    chosen=$(echo "$event_json" | jq -r '((.context | (try fromjson catch null) | .chosen?) // "") | gsub("\n";" ")' 2>/dev/null)
    rationale=$(echo "$event_json" | jq -r '((.context | (try fromjson catch null) | .rationale?) // "") | gsub("\n";" ")' 2>/dev/null)
    scope=$(classify_scope "$file" "$slug" "$decision")

    if [ -n "$chosen" ]; then
      disc="On '$decision', human chose: $chosen"
      [ -n "$rationale" ] && disc="$disc. Rationale: $rationale"
    else
      disc="Human explicitly overrode agent suggestion for '$decision'"
    fi
    if [ -n "$rationale" ]; then
      act="Captured rationale present — verify it is reflected in project-knowledge; reject if already documented"
    else
      act="Document the override rationale for future reference"
    fi

    generate_candidate \
      "human_override" \
      "Human override: $decision → ${chosen:-?}" \
      "$disc" \
      "$act" \
      "decision_point human_overridden slug=$slug" \
      "$scope" \
      "high"
  done < "${FILTERED_TRACES}.passC"
  rm -f "${FILTERED_TRACES}.passC"

  # ── Pass D: Reflexion insights ──
  # High-confidence reflexion_diagnosis where same slug later has gate_result pass
  # File-based intermediary to avoid tab-collapse in read
  GATE_PASS_SLUGS=$(jq -r 'select(.type == "gate_result" and .outcome == "pass" and .slug != null and .slug != "") | .slug' "$FILTERED_TRACES" 2>/dev/null | sort -u)

  jq -c 'select(.type == "reflexion_diagnosis" and .slug != null and .slug != "")' "$FILTERED_TRACES" 2>/dev/null > "${FILTERED_TRACES}.passD" || true
  while IFS= read -r event_json; do
    [ -z "$event_json" ] && continue
    slug=$(echo "$event_json" | jq -r '.slug // ""')
    [ -z "$slug" ] && continue
    confidence=$(echo "$event_json" | jq -r '(.context | (try fromjson catch null) | .confidence?) // "low"' 2>/dev/null)
    [ "$confidence" != "high" ] && continue
    if echo "$GATE_PASS_SLUGS" | grep -qxF "$slug"; then
      approach=$(echo "$event_json" | jq -r '(.context | (try fromjson catch null) | .revised_approach?) // "unknown"' 2>/dev/null)
      match_file=$(echo "$event_json" | jq -r '.file // ""')
      scope=$(classify_scope "$match_file" "$slug")
      generate_candidate \
        "reflexion_insight" \
        "Validated insight: $approach" \
        "High-confidence reflexion approach '$approach' led to successful gate pass for slug '$slug'" \
        "Document this pattern as a reusable fix strategy" \
        "reflexion_diagnosis + gate_result pass for slug=$slug" \
        "$scope" \
        "high"
    fi
  done < "${FILTERED_TRACES}.passD"
  rm -f "${FILTERED_TRACES}.passD"

else
  # No jq — skip pattern detection (grep-only mode would be unreliable for double-parse)
  echo "Warning: jq not available. Dream scanner requires jq for double-parse. Skipping pattern detection."
fi

# ── Phase 3: Staleness guard (AC17) ────────────────────────────
# Expire candidates older than 30 days
CUTOFF_30D=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d "30 days ago" +%Y-%m-%d 2>/dev/null || echo "")
if [ -n "$CUTOFF_30D" ]; then
  for cand in "$CANDIDATE_DIR"/CAND-*.md; do
    [ -f "$cand" ] || continue
    cand_date=$(basename "$cand" | sed 's/^CAND-\([0-9-]*\)-.*/\1/')
    [[ "$cand_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue
    cand_status=$(grep '^status:' "$cand" | sed 's/^status:[[:space:]]*//')
    if [ "$cand_status" = "pending" ] && [[ "$cand_date" < "$CUTOFF_30D" ]]; then
      sed -i.bak "s/^status: pending/status: expired/" "$cand"; rm -f "${cand}.bak"
    fi
  done
fi

# ── Phase 4: State Update ──────────────────────────────────────

NOW_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
if [ -f "$STATE_FILE" ]; then
  sed -i.bak "s/^last_scan_ts:.*/last_scan_ts: \"$NOW_TS\"/" "$STATE_FILE"; rm -f "${STATE_FILE}.bak"
  sed -i.bak "s/^last_scan_candidates:.*/last_scan_candidates: $CANDIDATE_COUNT/" "$STATE_FILE"; rm -f "${STATE_FILE}.bak"
fi

echo "Dream scan complete: $CANDIDATE_COUNT new candidates"
exit 0
