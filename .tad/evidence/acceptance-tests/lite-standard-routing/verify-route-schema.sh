#!/usr/bin/env bash
# verify-route-schema.sh — Route Contract SSOT schema/precedence/route-mapping assertions
# Exit 0 = all checks pass, Exit 1 = at least one check failed (fail-closed)
set -euo pipefail

CONTRACT=".tad/routing-contract.yaml"
FAIL=0

echo "=== Route Contract Schema Verification ==="
echo "Contract: $CONTRACT"

if [ ! -f "$CONTRACT" ]; then
  echo "FAIL: Contract file missing: $CONTRACT"
  exit 1
fi

# --- identity (AC1) ---
for pat in '^contract_id: TAD-ROUTING-2026-08$' '^schema_version: 1$' '^levels: \[lite, standard, full\]$'; do
  if rg -q "$pat" "$CONTRACT"; then
    echo "  OK: identity marker $pat"
  else
    echo "FAIL: identity marker missing: $pat"
    FAIL=1
  fi
done

# --- precedence fail-closed (AC2) ---
for marker in 'user_can_lower: false' 'missing_contract: fail_closed' 'F0_FATAL' 'F1_GOVERNANCE_CRITICAL' 'override_allowed: false'; do
  if rg -q "$marker" "$CONTRACT"; then
    echo "  OK: fail-closed marker $marker"
  else
    echo "FAIL: fail-closed marker missing: $marker"
    FAIL=1
  fi
done

# --- independent depth routing (AC5) ---
for marker in 'design_depth' 'execution_depth' 'Standard/Lite' 'Lite/Standard'; do
  if rg -q "$marker" "$CONTRACT"; then
    echo "  OK: depth-routing marker $marker"
  else
    echo "FAIL: depth-routing marker missing: $marker"
    FAIL=1
  fi
done

# --- F0/F1 mandatory full (AC2 route mapping) ---
F0_FULLS=$(awk '/^  F0_FATAL:/,/^  F1_GOVERNANCE_CRITICAL:/' "$CONTRACT" | grep -oE '\bfull\b' | wc -l | tr -d '[:space:]')
F1_FULLS=$(awk '/^  F1_GOVERNANCE_CRITICAL:/,/^  F2_UNCERTAIN:/' "$CONTRACT" | grep -oE '\bfull\b' | wc -l | tr -d '[:space:]')
if [ "$F0_FULLS" -ge 3 ] && [ "$F1_FULLS" -ge 3 ]; then
  echo "  OK: F0 ($F0_FULLS full refs) and F1 ($F1_FULLS full refs) map to full"
else
  echo "FAIL: F0/F1 must map both depths to full (got F0=$F0_FULLS, F1=$F1_FULLS)"
  FAIL=1
fi

# --- F2 affected-side-only (AC5 route mapping) ---
if awk '/^  F2_UNCERTAIN:/,/^  F3_ROUTINE:/' "$CONTRACT" | rg -q 'affected_side_only: true'; then
  echo "  OK: F2 is affected-side-only"
else
  echo "FAIL: F2 must be affected_side_only"
  FAIL=1
fi

# --- route_level derivation invariant (AC5) ---
if rg -q 'full_if_any_depth: full' "$CONTRACT" && rg -q 'standard_if_any_depth: standard' "$CONTRACT"; then
  echo "  OK: route_level monotonic derivation invariant present"
else
  echo "FAIL: route_level derivation invariant missing"
  FAIL=1
fi

# --- state machine present (AC7/AC16) ---
if rg -q 'state_machine:' "$CONTRACT" && rg -q 'blocked_missing_contract' "$CONTRACT" && rg -q 'blocked_stale_revision' "$CONTRACT"; then
  echo "  OK: state machine with blocking states present"
else
  echo "FAIL: state machine / blocking states missing"
  FAIL=1
fi

echo "---"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS (route-schema)"
else
  echo "RESULT: FAIL"
fi
exit $FAIL
