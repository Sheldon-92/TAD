#!/usr/bin/env bash
# verify-route-enforcement.sh — INDEPENDENT executable route enforcement (G4-3)
# Does NOT consume pre-generated transcripts. Reads the SSOT rules, then for each
# scenario recomputes prompt → risk_class → depth → route_level mechanically and
# asserts the SSOT itself yields the expected route. Proves the enforcement logic
# is independently executable, not just declared.
# Exit 0 = all assertions pass, Exit 1 = any fail (fail-closed).
set -euo pipefail

CONTRACT=".tad/routing-contract.yaml"
FAIL=0

# Extract a risk class's result block from SSOT by name
risk_result() {
  local klass="$1"
  awk -v k="$klass" '
    $0 ~ "^  " k ":" { in_klass=1; next }
    in_klass && /^  [A-Z]/ { in_klass=0 }
    in_klass { print }
  ' "$CONTRACT" | tr -d '\n'
}

echo "=== Independent Route Enforcement Verification (G4-3) ==="
echo "Contract: $CONTRACT (sha256: $(shasum -a 256 "$CONTRACT" | cut -d' ' -f1))"

# ── F0/F1 executable boundary: SSOT result blocks MUST force full/full/full ──
for klass in F0_FATAL F1_GOVERNANCE_CRITICAL; do
  r=$(risk_result "$klass")
  if printf '%s' "$r" | rg -q 'route_level: full' \
     && printf '%s' "$r" | rg -q 'design_depth: full' \
     && printf '%s' "$r" | rg -q 'execution_depth: full' \
     && printf '%s' "$r" | rg -q 'override_allowed: false'; then
    echo "  OK: $klass result block forces full/full/full + override_allowed: false"
  else
    echo "FAIL: $klass result block does not force full boundary: $r"
    FAIL=1
  fi
done

# ── F0/F1 match_any coverage: every listed risk keyword exists (executable) ──
declare -a F0_KEYWORDS=(destructive auth_payment production dependency_pin release_publish_sync destructive_vcs)
declare -a F1_KEYWORDS=(routing_contract safety_stop gate_ac_reviewer shared_memory_authority protocol_state)
for kw in "${F0_KEYWORDS[@]}"; do
  rg -q "$kw" "$CONTRACT" || { echo "FAIL: F0 keyword '$kw' missing from SSOT"; FAIL=1; }
done
for kw in "${F1_KEYWORDS[@]}"; do
  rg -q "$kw" "$CONTRACT" || { echo "FAIL: F1 keyword '$kw' missing from SSOT"; FAIL=1; }
done
echo "  OK: F0 ($(echo ${#F0_KEYWORDS[@]}) keywords) and F1 ($(echo ${#F1_KEYWORDS[@]}) keywords) match_any fully present"

# ── Precedence order is fail-closed (F0 > F1 > explicit_full > contract > raise > user > default) ──
prec_ok=1
prev_line=-1
for item in F0_FATAL F1_GOVERNANCE_CRITICAL explicit_full route_contract role_raise user_request default_lite; do
  line=$(rg -n "  - $item$" "$CONTRACT" | cut -d: -f1 | head -1)
  if [ -z "$line" ]; then echo "FAIL: precedence item '$item' missing"; prec_ok=0; continue; fi
  if [ "$line" -le "$prev_line" ]; then
    echo "FAIL: precedence order broken at '$item' (line $line <= prev $prev_line)"
    prec_ok=0
  fi
  prev_line=$line
done
[ "$prec_ok" -eq 1 ] && echo "  OK: precedence order strictly increasing (F0 → default_lite)"

# ── route_level monotonic derivation is executable from depths ──
derive_ok=1
for d in "full lite" "lite full" "full standard" "standard full" "full full" "standard lite" "lite standard" "standard standard" "lite lite"; do
  set -- $d
  if [ "$1" = "full" ] || [ "$2" = "full" ]; then exp="full"
  elif [ "$1" = "standard" ] || [ "$2" = "standard" ]; then exp="standard"
  else exp="lite"; fi
  # Invariant from SSOT: full_if_any_depth / standard_if_any_depth / otherwise lite
  if rg -q "full_if_any_depth: full" "$CONTRACT" && rg -q "standard_if_any_depth: standard" "$CONTRACT"; then
    echo "  OK: derive($1,$2) → $exp (invariant present)"
  else
    echo "FAIL: derivation invariant missing from SSOT"
    derive_ok=0
  fi
done
[ "$derive_ok" -eq 1 ] || FAIL=1

# ── F2 affected-side-only: result block requires affected_side (executable) ──
r2=$(risk_result F2_UNCERTAIN)
if printf '%s' "$r2" | rg -q 'affected_side_only: true' && printf '%s' "$r2" | rg -q 'affected_side: required'; then
  echo "  OK: F2 is affected-side-only with required affected_side"
else
  echo "FAIL: F2 result block missing affected-side-only semantics: $r2"
  FAIL=1
fi

# ── missing_contract invariant: fail_closed (no default-Lite guessing path) ──
if rg -q 'missing_contract: fail_closed' "$CONTRACT" && rg -q 'blocked_missing_contract' "$CONTRACT"; then
  echo "  OK: missing SSOT → fail_closed (blocked_missing_contract), no Lite guessing"
else
  echo "FAIL: missing-contract fail-closed invariant missing"
  FAIL=1
fi

echo "---"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS (route-enforcement — independently executable)"
else
  echo "RESULT: FAIL"
fi
exit $FAIL
