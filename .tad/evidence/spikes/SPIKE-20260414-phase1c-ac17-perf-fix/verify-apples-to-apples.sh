#!/bin/bash
# AC12 + AC13: Verify hooks-v2/hardened-*.sh delta vs 1b hardened-*.sh is ONLY
# dep-guard source + require_dep call lines (plus the block-header/footer comments).
# Also enforce anti-pattern CI guard (AC13): no `require_dep "$...` variable calls.

set -euo pipefail
cd "$(dirname "$0")"

SRC_1B="../SPIKE-20260414-quality-enforcement-adversarial"
DST_1C="hooks-v2"
OUT="results/apples-to-apples.txt"

mkdir -p results
: > "$OUT"

hooks=(hardened-pretool-interceptor.sh hardened-bash-watcher.sh hardened-override-detector.sh hardened-evidence-validator.sh)

overall_ok=1

for h in "${hooks[@]}"; do
  echo "==== diff $h ====" >> "$OUT"
  # unified diff between 1b and 1c version
  diff -u "$SRC_1B/$h" "$DST_1C/$h" >> "$OUT" 2>&1 || true
  echo >> "$OUT"
done

# Validate: every "added" line (+) that is not "+++" or "---" must be either:
#  - a dep-guard comment/header/footer line
#  - `source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"`
#  - `require_dep jq` or `require_dep awk`
#  - an empty added line
echo "==== added-line validation ====" >> "$OUT"
added_unexpected=$(awk '
  /^\+\+\+/ { next }
  /^\+/ {
    line = substr($0, 2)
    # allowed patterns
    if (line == "") next
    if (line ~ /^# ── TAD Phase 1c AC17 fix: dep-guard/) next
    if (line ~ /^source "\$\{BASH_SOURCE\[0\]\}%\/\*\}\/lib\/dep-guard\.sh"$/) next
    if (line ~ /^source "\$\{BASH_SOURCE\[0\]%\/\*\}\/lib\/dep-guard\.sh"$/) next
    if (line ~ /^require_dep (jq|awk)$/) next
    if (line ~ /^# ── end dep-guard block ──$/) next
    print "UNEXPECTED_ADDED: " line
  }
' "$OUT")

if [ -n "$added_unexpected" ]; then
  echo "$added_unexpected" >> "$OUT"
  echo "AC12 FAIL: unexpected added lines"
  echo "AC12 FAIL" > results/apples-to-apples-verdict.txt
  overall_ok=0
else
  echo "AC12 PASS: only dep-guard lines added" >> "$OUT"
  echo "AC12 PASS" > results/apples-to-apples-verdict.txt
fi

# Strict byte-preservation check: the ONLY allowed delta is the 5-line dep-guard block
# appearing right after `set -euo pipefail`. We verify by counting added-line hunks
# and checking that the total line-count delta matches expected (5 lines per hook,
# 6 for evidence-validator which also has `require_dep awk`).
for h in "${hooks[@]}"; do
  actual_delta=$(( $(wc -l < "$DST_1C/$h") - $(wc -l < "$SRC_1B/$h") ))
  case "$h" in
    hardened-evidence-validator.sh) expected=6 ;;  # 4 block lines + require_dep jq + require_dep awk
    *) expected=5 ;;                                # 4 block lines + require_dep jq
  esac
  if [ "$actual_delta" -ne "$expected" ]; then
    echo "BYTE-PRESERVE FAIL: $h line-count delta=$actual_delta (expected $expected)" >> "$OUT"
    overall_ok=0
  else
    echo "BYTE-PRESERVE PASS: $h +$actual_delta lines (all dep-guard)" >> "$OUT"
  fi
done

# AC13: anti-pattern grep guard
echo "==== AC13 anti-pattern grep ====" >> "$OUT"
bad=$(grep -rn 'require_dep "\$' "$DST_1C/" 2>/dev/null || true)
if [ -n "$bad" ]; then
  echo "AC13 FAIL: variable-based require_dep call detected:" >> "$OUT"
  echo "$bad" >> "$OUT"
  echo "AC13 FAIL" >> results/apples-to-apples-verdict.txt
  overall_ok=0
else
  echo "AC13 PASS: no variable-based require_dep calls" >> "$OUT"
  echo "AC13 PASS" >> results/apples-to-apples-verdict.txt
fi

echo
cat results/apples-to-apples-verdict.txt
exit $((1 - overall_ok))
