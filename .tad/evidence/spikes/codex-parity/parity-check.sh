#!/usr/bin/env bash
# parity-check.sh — Codex-edition semantic-coverage parity check (P2)
# Exit: 0=parity, 1=drift, 2=usage error.
# P2: fail-CLOSED on parse error (exit 1) — this gates a LIVE replace.
# BSD/macOS safe: no grep -P. LC_ALL=C on sort/comm.
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: parity-check.sh <claude_skill> <codex_edition>" >&2
  exit 2
fi

CLAUDE_SKILL="$1"
CODEX_EDITION="$2"

if [ ! -f "$CLAUDE_SKILL" ]; then
  echo "ERROR: Claude SKILL not found: $CLAUDE_SKILL" >&2
  exit 2
fi
if [ ! -f "$CODEX_EDITION" ]; then
  echo "ERROR: Codex edition not found: $CODEX_EDITION" >&2
  exit 2
fi

DRIFT=0

# --- Expected-absent allowlist (from portable-rules.md) ---
EXPECTED_ABSENT="yolo_execution_protocol
optimize_protocol
evolve_protocol
dream_protocol
publish_protocol
sync_protocol
sync_add_protocol
sync_list_protocol
lsp_provision_protocol"

NESTED_IGNORE="per_phase_protocol
blocking_in_alex_protocol
fallback_protocol
honest_partial_protocol
archive_protocol"

SAFETY_CATEGORIES="forbidden_implementations anti_rationalization_registry NOT_via_alex_auto honest_partial"

# Temp files for section-level parsing
SOURCE_COUNTS_FILE=$(mktemp)
CODEX_COUNTS_FILE=$(mktemp)
trap 'rm -f "$SOURCE_COUNTS_FILE" "$CODEX_COUNTS_FILE"' EXIT

# Determine source identity for pin table validation
case "$CLAUDE_SKILL" in
  */alex/*) SOURCE_ID="alex" ;;
  */blake/*) SOURCE_ID="blake" ;;
  *)
    echo "ERROR: Cannot determine source identity from path (need /alex/ or /blake/): $CLAUDE_SKILL" >&2
    exit 1
    ;;
esac

echo "========================================="
echo "PARITY CHECK: $(basename "$CODEX_EDITION")"
echo "SOURCE:       $(basename "$CLAUDE_SKILL") ($SOURCE_ID)"
echo "========================================="
echo ""

# ═══════════════════════════════════════
# LAYER 1: Section Coverage
# ═══════════════════════════════════════
echo "--- LAYER 1: Section Coverage ---"

source_protocols=$(grep -oE '^[a-z_]+_protocol:' "$CLAUDE_SKILL" | sed 's/:$//' | LC_ALL=C sort -u)

covered=0
expected_absent=0
missing=0
missing_list=""

for proto in $source_protocols; do
  if echo "$NESTED_IGNORE" | grep -qFx "$proto"; then
    continue
  fi

  if grep -q "$proto" "$CODEX_EDITION" 2>/dev/null; then
    covered=$((covered + 1))
  elif echo "$EXPECTED_ABSENT" | grep -qFx "$proto"; then
    expected_absent=$((expected_absent + 1))
  else
    missing=$((missing + 1))
    missing_list="${missing_list}  MISSING: ${proto}\n"
  fi
done

echo "  COVERED:         $covered"
echo "  EXPECTED-ABSENT: $expected_absent"
echo "  MISSING:         $missing"

if [ "$missing" -gt 0 ]; then
  printf '%b' "$missing_list"
  DRIFT=1
  echo "  LAYER 1: FAIL (off-allowlist missing sections)"
else
  echo "  LAYER 1: PASS"
fi
echo ""

# ═══════════════════════════════════════
# LAYER 2: Per-Owner SAFETY Presence (P2 — position-aware)
# Bodies delimited by next col-0 key of ANY kind (not just _protocol:).
# ═══════════════════════════════════════
echo "--- LAYER 2: Per-Owner SAFETY Presence ---"

# Guard: AskUserQuestion must be 0
ask_count=$(grep -c 'AskUserQuestion' "$CODEX_EDITION" 2>/dev/null) || true
ask_count=${ask_count:-0}
echo "  AskUserQuestion: $ask_count (must be 0)"
if [ "$ask_count" -ne 0 ]; then
  echo "  FAIL: AskUserQuestion references remain"
  DRIFT=1
fi

# Parse file into col-0 sections, count SAFETY tokens per section body.
# Col-0 key = line matching ^[a-z_]+: (any YAML-style key at column 0).
# Output: section_key<TAB>category<TAB>count
parse_safety_counts() {
  awk '
    /^[a-z_]+:/ {
      if (section != "") {
        for (cat in counts) {
          print section "\t" cat "\t" counts[cat]
        }
      }
      section = $0
      sub(/:.*/, "", section)
      delete counts
    }
    /forbidden_implementations/ { counts["forbidden_implementations"]++ }
    /anti_rationalization_registry/ { counts["anti_rationalization_registry"]++ }
    /NOT_via_alex_auto/ { counts["NOT_via_alex_auto"]++ }
    /honest_partial/ { counts["honest_partial"]++ }
    END {
      if (section != "") {
        for (cat in counts) {
          print section "\t" cat "\t" counts[cat]
        }
      }
    }
  ' "$1"
}

parse_safety_counts "$CLAUDE_SKILL" > "$SOURCE_COUNTS_FILE"
parse_safety_counts "$CODEX_EDITION" > "$CODEX_COUNTS_FILE"

# Fail-CLOSED: source must produce >0 SAFETY entries
source_entry_count=$(wc -l < "$SOURCE_COUNTS_FILE" | tr -d ' ')
if [ "$source_entry_count" -eq 0 ]; then
  echo "  ERROR: source SAFETY parse returned 0 entries (parse failure)" >&2
  exit 1
fi

layer2_fail=0

for category in $SAFETY_CATEGORIES; do
  must_cover_total=0
  owner_details=""
  category_fail=0

  while IFS=$'\t' read -r owner cat count; do
    [ "$cat" = "$category" ] || continue

    # Skip allowlisted owners
    if echo "$EXPECTED_ABSENT" | grep -qFx "$owner"; then
      continue
    fi

    must_cover_total=$((must_cover_total + count))

    # Find codex count for this (owner, category)
    codex_count=$(awk -F'\t' -v o="$owner" -v c="$category" \
      '$1 == o && $2 == c { print $3 }' "$CODEX_COUNTS_FILE")
    codex_count=${codex_count:-0}

    if [ "$codex_count" -ge "$count" ]; then
      owner_details="${owner_details}    + ${owner}: codex=${codex_count} >= source=${count}\n"
    else
      category_fail=$((category_fail + 1))
      owner_details="${owner_details}    X ${owner}: codex=${codex_count} < source=${count}\n"
    fi
  done < "$SOURCE_COUNTS_FILE"

  if [ "$must_cover_total" -eq 0 ]; then
    echo "  $category: SKIP (0 must-cover after allowlist)"
    continue
  fi

  echo "  $category: must-cover=${must_cover_total}"
  printf '%b' "$owner_details"

  if [ "$category_fail" -gt 0 ]; then
    echo "  -> FAIL: $category_fail owner(s) below source count"
    layer2_fail=$((layer2_fail + category_fail))
  fi
done

# --- Pin Table Validation (ARCH P0-2) ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIN_FILE="$SCRIPT_DIR/parity-criterion.md"
echo ""
if [ -f "$PIN_FILE" ]; then
  echo "  --- Pin Table Validation ---"
  pin_mismatch=0

  for category in $SAFETY_CATEGORIES; do
    derived_total=0
    while IFS=$'\t' read -r owner cat count; do
      [ "$cat" = "$category" ] || continue
      if echo "$EXPECTED_ABSENT" | grep -qFx "$owner"; then
        continue
      fi
      derived_total=$((derived_total + count))
    done < "$SOURCE_COUNTS_FILE"

    # Read pinned total: <!-- PIN:source_id|category|number -->
    pinned=$(awk -v id="$SOURCE_ID" -v cat="$category" '
      /<!-- PIN:/ {
        s = $0
        sub(/.*<!-- PIN:/, "", s)
        sub(/ -->.*/, "", s)
        n = split(s, parts, "[|]")
        if (n >= 3 && parts[1] == id && parts[2] == cat) {
          print parts[3]
        }
      }
    ' "$PIN_FILE")

    if [ -z "$pinned" ]; then
      echo "    WARN: no pin for ${SOURCE_ID}|${category} (skip validation)"
      continue
    fi

    if [ "$derived_total" -eq "$pinned" ]; then
      echo "    + ${category}: derived=${derived_total} == pin=${pinned}"
    else
      echo "    X ${category}: derived=${derived_total} != pin=${pinned} -- PARSER BROKEN"
      pin_mismatch=$((pin_mismatch + 1))
    fi
  done

  if [ "$pin_mismatch" -gt 0 ]; then
    echo "  ERROR: ${pin_mismatch} pin mismatch(es) -- parser derivation broken" >&2
    exit 1
  fi
else
  echo "  ERROR: pin file not found at $PIN_FILE (required for LIVE gate)" >&2
  exit 1
fi

# Secondary signal: global constraint floor (WARN only, not FAIL)
source_constraint_count=$(grep -coE 'MUST|MANDATORY|VIOLATION' "$CLAUDE_SKILL" 2>/dev/null) || true
source_constraint_count=${source_constraint_count:-0}
codex_constraint_count=$(grep -coE 'MUST|MANDATORY|VIOLATION' "$CODEX_EDITION" 2>/dev/null) || true
codex_constraint_count=${codex_constraint_count:-0}
floor=$((source_constraint_count / 10))
if [ "$floor" -lt 10 ]; then floor=10; fi
echo ""
echo "  [secondary] Constraints: codex=$codex_constraint_count source=$source_constraint_count floor=$floor"
if [ "$codex_constraint_count" -lt "$floor" ]; then
  echo "  [secondary] WARN: below floor (per-owner check is primary)"
fi

if [ "$ask_count" -eq 0 ] && [ "$layer2_fail" -eq 0 ]; then
  echo "  LAYER 2: PASS"
else
  echo "  LAYER 2: FAIL"
  DRIFT=1
fi
echo ""

# ═══════════════════════════════════════
# LAYER 3: Capability-Marker Coverage
# ═══════════════════════════════════════
echo "--- LAYER 3: Capability-Marker Coverage ---"

marker_missing=0
marker_list=""

# Extract task_type enum values from source validation lines
task_types=$(grep -E 'task_type.*must be one of|task_type.*code.*yaml' "$CLAUDE_SKILL" 2>/dev/null | \
  grep -oE 'code|yaml|research|e2e|mixed|deliverable' | LC_ALL=C sort -u || true)
if [ -z "$task_types" ]; then
  task_types=$(grep -oE 'task_type:[[:space:]]*(code|yaml|research|e2e|mixed|deliverable)' "$CLAUDE_SKILL" 2>/dev/null | \
    grep -oE 'code|yaml|research|e2e|mixed|deliverable' | LC_ALL=C sort -u || true)
fi

if [ -z "$task_types" ]; then
  echo "  WARN: could not extract task_type values from source (parse failure -- fail-CLOSED)"
  DRIFT=1
else
  for tt in $task_types; do
    if grep -qi "$tt" "$CODEX_EDITION" 2>/dev/null; then
      echo "  COVERED: task_type '$tt'"
    else
      echo "  MISSING: task_type '$tt'"
      marker_missing=$((marker_missing + 1))
    fi
  done
fi

feature_markers="deliverable research_complexity step4_5"
for marker in $feature_markers; do
  # Only check markers present in the source (source-conditioned)
  source_has=$(grep -ci "$marker" "$CLAUDE_SKILL" 2>/dev/null) || true
  source_has=${source_has:-0}
  if [ "$source_has" -eq 0 ]; then
    echo "  SKIP: feature marker '$marker' (not in source)"
    continue
  fi
  if grep -qi "$marker" "$CODEX_EDITION" 2>/dev/null; then
    echo "  COVERED: feature marker '$marker'"
  else
    echo "  MISSING: feature marker '$marker'"
    marker_missing=$((marker_missing + 1))
    marker_list="${marker_list}  MISSING: ${marker}\n"
  fi
done

if [ "$marker_missing" -gt 0 ]; then
  DRIFT=1
  echo "  LAYER 3: FAIL ($marker_missing markers absent)"
else
  echo "  LAYER 3: PASS"
fi
echo ""

# ═══════════════════════════════════════
# VERDICT
# ═══════════════════════════════════════
echo "========================================="
if [ "$DRIFT" -eq 0 ]; then
  echo "VERDICT: PARITY (exit 0)"
  echo "========================================="
  exit 0
else
  echo "VERDICT: DRIFT DETECTED (exit 1)"
  echo "========================================="
  exit 1
fi
