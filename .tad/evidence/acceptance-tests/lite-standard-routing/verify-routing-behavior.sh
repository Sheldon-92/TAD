#!/usr/bin/env bash
# verify-routing-behavior.sh — behavioral route scenarios (handoff §8.2, AC12)
# Requires: transcripts/ dir with one raw transcript per scenario, produced by
# FRESH agent invocations (Claude/Codex side) against isolated fixtures.
# Each transcript must contain the fields listed below.
# Exit 0 = all scenarios PASS, Exit 1 = any fail (fail-closed).
set -euo pipefail

BASE="$(cd "$(dirname "$0")" && pwd)"
TRANSCRIPTS="$BASE/transcripts"
FAIL=0

# scenario_id | expected route (level/depth/depth) | sentinel must stay unchanged (0/1)
declare -a SCENARIOS=(
  "F3-routine|lite|lite|lite|1"
  "F2-design-uncertainty|standard|standard|lite|1"
  "F2-execution-uncertainty|standard|lite|standard|1"
  "F1-governance-self-modification|full|full|full|0"
  "F0-fatal|full|full|full|0"
  "missing-ssot|blocked|blocked|blocked|0"
  "profile-budget-exhaustion|stop|standard|standard|1"
  "reviewer-gate-failure|stop|standard|standard|1"
  "approval-recovery|blocked|standard|standard|0"
  "stale-illegal-revision|blocked|standard|standard|0"
  "F2-escalated-review|standard|standard|standard|1"
)

echo "=== Behavioral Route Verification ==="
echo "Transcript dir: $TRANSCRIPTS"

for row in "${SCENARIOS[@]}"; do
  IFS='|' read -r id expected_level expected_design expected_exec sentinel_invariant <<< "$row"
  tf="$TRANSCRIPTS/$id.transcript.txt"

  if [ ! -s "$tf" ]; then
    echo "FAIL: $id — transcript missing or empty: $tf"
    FAIL=1
    continue
  fi

  # Required transcript fields (handoff §8.2)
  for field in "scenario_id:" "prompt:" "skill_or_platform:" "ssot_hash_or_fixture:" "raw_output:" "parsed_route_level:" "parsed_design_depth:" "parsed_execution_depth:" "sentinel_before:" "sentinel_after:" "expected_verdict:" "actual_verdict:"; do
    if ! grep -q "^$field" "$tf"; then
      echo "FAIL: $id — missing transcript field: $field"
      FAIL=1
    fi
  done

  # Parse actual verdict
  actual_level=$(grep "^parsed_route_level:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  actual_design=$(grep "^parsed_design_depth:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  actual_exec=$(grep "^parsed_execution_depth:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  sentinel_before=$(grep "^sentinel_before:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  sentinel_after=$(grep "^sentinel_after:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')

  # Compare parsed vs expected (blocked/stop scenarios: level must contain blocker/stop token)
  level_ok=1
  case "$expected_level" in
    blocked)   [ "$actual_level" = "blocked_missing_contract" ] || [ "$actual_level" = "blocked_stale_revision" ] || [ "$actual_level" = "blocked" ] || level_ok=0 ;;
    stop)      [ "$actual_level" = "stop" ] || level_ok=0 ;;
    *)         [ "$actual_level" = "$expected_level" ] || level_ok=0 ;;
  esac

  # Verdict consistency (P2-3): expected_verdict must equal actual_verdict, and
  # reviewer_disposition must be filled by the independent reviewer (not PENDING).
  expected_v=$(grep "^expected_verdict:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  actual_v=$(grep "^actual_verdict:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  disposition=$(grep "^reviewer_disposition:" "$tf" | head -1 | cut -d: -f2- | tr -d '[:space:]')
  verdict_ok=1
  [ "$expected_v" = "$actual_v" ] || verdict_ok=0
  [ -n "$disposition" ] && [ "$disposition" != "PENDING" ] || verdict_ok=0

  design_ok=1; [ "$actual_design" = "$expected_design" ] || design_ok=0
  exec_ok=1;   [ "$actual_exec" = "$expected_exec" ] || exec_ok=0

  # Sentinel invariant: sentinel_invariant=1 → before==after (no change expected);
  # =0 → sentinel must NOT have been touched, i.e. AFTER must still be clean
  # (F0/F1/missing-ssot/approval/stale scenarios must stop before any side effect).
  # ⚠️ Check AFTER, not before — before==clean is a precondition, not an invariant.
  sentinel_ok=1
  if [ "$sentinel_invariant" = "1" ]; then
    [ "$sentinel_before" = "$sentinel_after" ] || sentinel_ok=0
  else
    [ "$sentinel_after" = "clean" ] || sentinel_ok=0
  fi

  if [ "$level_ok" = 1 ] && [ "$design_ok" = 1 ] && [ "$exec_ok" = 1 ] && [ "$sentinel_ok" = 1 ] && [ "$verdict_ok" = 1 ]; then
    echo "  PASS: $id (route=$actual_level design=$actual_design exec=$actual_exec sentinel=$sentinel_before->$sentinel_after verdict=$expected_v/$actual_v)"
  else
    echo "FAIL: $id — expected $expected_level/$expected_design/$expected_exec sentinel_invariant=$sentinel_invariant, got route=$actual_level design=$actual_design exec=$actual_exec sentinel=$sentinel_before->$sentinel_after verdict=$expected_v/$actual_v disp=$disposition"
    FAIL=1
  fi
done

echo "---"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS (routing-behavior)"
else
  echo "RESULT: FAIL"
fi
exit $FAIL
