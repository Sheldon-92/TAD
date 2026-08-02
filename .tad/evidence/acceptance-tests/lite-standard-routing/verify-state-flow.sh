#!/usr/bin/env bash
# verify-state-flow.sh — approval gate, stale-write rejection, append-only ownership,
# resume, and F2 escalated-review mapping assertions (AC7/AC16)
# Exit 0 = all checks pass, Exit 1 = at least one check failed (fail-closed)
set -euo pipefail

CONTRACT=".tad/routing-contract.yaml"
SKILLS=(".claude/skills/alex-lite/SKILL.md" ".claude/skills/blake-lite/SKILL.md")
FAIL=0

echo "=== State Flow Verification ==="

# --- approval gate: approval_pending blocks execution until approve (AC16) ---
if rg -q 'from: approval_pending, event: approve, to: execution_ready' "$CONTRACT" \
   && rg -q 'approval_record' "$CONTRACT"; then
  echo "  OK: approval_pending -> approve -> execution_ready transition present"
else
  echo "FAIL: approval gate transition or approval_record missing"
  FAIL=1
fi

# --- approval_record five-field schema (G4-2): status/actor/timestamp/route_revision/evidence ---
approval_fields=("status: approved" "actor" "timestamp" "route_revision" "evidence")
approval_ok=1
for af in "${approval_fields[@]}"; do
  if rg -q "$af" .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md "$CONTRACT"; then
    echo "  OK: approval_record field '$af' present"
  else
    echo "FAIL: approval_record missing field '$af'"
    approval_ok=0
  fi
done
if [ "$approval_ok" -ne 1 ]; then FAIL=1; fi

# --- decision_record required-field completeness (G4-2) ---
# The required list spans two YAML lines; match each field independently within
# the decision_record block (not requiring same-line as 'required:').
required_fields="route_id revision base_revision contract_id route_level design_depth execution_depth risk_class affected_side escalated_review reason authority writer override_allowed evidence state"
dr_ok=1
DR_BLOCK=$(awk '/^decision_record:/,/^revision_rules:/' "$CONTRACT")
for rf in $required_fields; do
  if printf '%s\n' "$DR_BLOCK" | rg -q "\b$rf\b"; then
    echo "  OK: decision_record field '$rf' required"
  else
    echo "FAIL: decision_record missing required field '$rf'"
    dr_ok=0
  fi
done
if [ "$dr_ok" -ne 1 ]; then FAIL=1; fi

# --- reject -> revise retry loop (AC16) ---
if rg -q 'from: approval_pending, event: reject, to: approval_rejected' "$CONTRACT" \
   && rg -q 'from: approval_rejected, event: revise, to: design_ready' "$CONTRACT"; then
  echo "  OK: reject -> approval_rejected -> revise -> design_ready present"
else
  echo "FAIL: rejection/revise transitions missing"
  FAIL=1
fi

# --- stale/lower write rejection (AC16) ---
if rg -q 'stale_or_lower_write: reject_to_blocked_stale_revision' "$CONTRACT" \
   && rg -q 'from: .*event: stale_revision, to: blocked_stale_revision' "$CONTRACT"; then
  echo "  OK: stale/lower write rejects to blocked_stale_revision"
else
  echo "FAIL: stale-write rejection missing"
  FAIL=1
fi

# --- append-only ownership (AC16): Alex may not write execution_depth, Blake may not write design_depth ---
if rg -q 'alex_may_write: \[design_depth, risk_class, affected_side, escalated_review, reason, evidence\]' "$CONTRACT" \
   && rg -q 'blake_may_write: \[execution_depth, risk_class, affected_side, escalated_review, reason, evidence\]' "$CONTRACT" \
   && rg -q 'neither_role_may_write: \[policy_contract, other_role_depth, approval_record\]' "$CONTRACT"; then
  echo "  OK: append-only field ownership enforced"
else
  echo "FAIL: field ownership rules missing/inconsistent"
  FAIL=1
fi

# --- resume from latest valid revision (AC16) ---
if rg -q 'resume_from_latest_valid_revision' "$CONTRACT"; then
  echo "  OK: resume_from_latest_valid_revision present"
else
  echo "FAIL: resume event missing"
  FAIL=1
fi

# --- F2 escalated_review maps to standard, cannot lower F0/F1 (AC16) ---
if rg -q 'escalated_review' "$CONTRACT" \
   && rg -q 'escalated_review 是 F2 非致命兼容标记' "${SKILLS[0]}" "${SKILLS[1]}" \
   && rg -q '不能覆盖 F0/F1' "${SKILLS[0]}" "${SKILLS[1]}"; then
  echo "  OK: F2 escalated_review mapped to standard, cannot lower F0/F1"
else
  echo "FAIL: escalated-review mapping missing"
  FAIL=1
fi

# --- F0/F1 cannot be lowered in both skills (AC6) ---
for f in "${SKILLS[@]}"; do
  if rg -q 'F0/F1 cannot be lowered' "$f"; then
    echo "  OK: $f contains no-lower anchor"
  else
    echo "FAIL: $f missing F0/F1 cannot be lowered"
    FAIL=1
  fi
done

# --- honest partial four elements in both skills (AC14) ---
for f in "${SKILLS[@]}"; do
  for m in '已完成' '阻塞原因' '下一步'; do
    if rg -q "$m" "$f"; then
      echo "  OK: $f contains honest-partial element $m"
    else
      echo "FAIL: $f missing $m"
      FAIL=1
    fi
  done
done

echo "---"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS (state-flow)"
else
  echo "RESULT: FAIL"
fi
exit $FAIL
