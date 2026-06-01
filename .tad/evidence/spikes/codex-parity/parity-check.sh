#!/usr/bin/env bash
# parity-check.sh — Codex-edition semantic-coverage parity check (P1 prototype)
# Exit: 0=parity, 1=drift, 2=usage error. Parse errors → WARN + continue (P1 fail-open).
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

echo "========================================="
echo "PARITY CHECK: $(basename "$CODEX_EDITION")"
echo "SOURCE:       $(basename "$CLAUDE_SKILL")"
echo "========================================="
echo ""

# ═══════════════════════════════════════
# LAYER 1: Section Coverage
# ═══════════════════════════════════════
echo "--- LAYER 1: Section Coverage ---"

source_protocols=$(grep -oE '[a-z_]+_protocol:' "$CLAUDE_SKILL" | sed 's/:$//' | LC_ALL=C sort -u)

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
# LAYER 2: Constraint Coverage
# ═══════════════════════════════════════
echo "--- LAYER 2: Constraint Coverage ---"

ask_count=$(grep -c 'AskUserQuestion' "$CODEX_EDITION" 2>/dev/null) || true
ask_count=${ask_count:-0}
echo "  AskUserQuestion count: $ask_count (must be 0)"
if [ "$ask_count" -ne 0 ]; then
  echo "  FAIL: AskUserQuestion references remain"
  DRIFT=1
fi

source_constraint_count=$(grep -coE 'MUST|MANDATORY|VIOLATION' "$CLAUDE_SKILL" 2>/dev/null) || true
source_constraint_count=${source_constraint_count:-0}
codex_constraint_count=$(grep -coE 'MUST|MANDATORY|VIOLATION' "$CODEX_EDITION" 2>/dev/null) || true
codex_constraint_count=${codex_constraint_count:-0}
floor=$((source_constraint_count / 10))
if [ "$floor" -lt 10 ]; then
  floor=10
fi
echo "  Constraint keywords: codex=$codex_constraint_count, source=$source_constraint_count, floor=$floor"
if [ "$codex_constraint_count" -lt "$floor" ]; then
  echo "  FAIL: constraint count $codex_constraint_count < floor $floor"
  DRIFT=1
fi

has_ar=$(grep -c 'anti_rationalization_registry' "$CODEX_EDITION" 2>/dev/null) || true
has_ar=${has_ar:-0}
echo "  anti_rationalization_registry: $has_ar (must be >0)"
if [ "$has_ar" -eq 0 ]; then
  echo "  FAIL: anti_rationalization_registry absent"
  DRIFT=1
fi

has_fi=$(grep -c 'forbidden_implementations' "$CODEX_EDITION" 2>/dev/null) || true
has_fi=${has_fi:-0}
echo "  forbidden_implementations: $has_fi (must be >0)"
if [ "$has_fi" -eq 0 ]; then
  echo "  FAIL: forbidden_implementations absent"
  DRIFT=1
fi

if [ "$ask_count" -eq 0 ] && [ "$codex_constraint_count" -ge "$floor" ] && \
   [ "$has_ar" -gt 0 ] && [ "$has_fi" -gt 0 ]; then
  echo "  LAYER 2: PASS"
else
  echo "  LAYER 2: FAIL"
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
  # Fallback: scan for task_type: <value> assignments
  task_types=$(grep -oE 'task_type:[[:space:]]*(code|yaml|research|e2e|mixed|deliverable)' "$CLAUDE_SKILL" 2>/dev/null | \
    grep -oE 'code|yaml|research|e2e|mixed|deliverable' | LC_ALL=C sort -u || true)
fi

if [ -z "$task_types" ]; then
  echo "  WARN: could not extract task_type values from source (parse error — P1 fail-open)"
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
