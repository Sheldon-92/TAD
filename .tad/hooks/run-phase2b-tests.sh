#!/bin/bash
# Phase 2b regression test runner — repeatable harness for the 30-case test set.
# Use after modifying keywords.yaml or userprompt-domain-router.sh to verify
# no accuracy regression. Addresses GAP-1 from the Gate 3 test-runner review.
#
# Usage:
#   ./run-phase2b-tests.sh            # run all 30 cases, print per-case + summary
#   ./run-phase2b-tests.sh --quiet    # print only summary + failures
#   ./run-phase2b-tests.sh --latency  # also run n=5 latency microbench
#
# Exit codes:
#   0 — all thresholds met (total ≥ 21/30, positive ≥ 17/24, negative all PASS)
#   1 — accuracy regression (thresholds failed)
#   2 — test data file missing
#   3 — hook missing or non-executable

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="${SCRIPT_DIR}/userprompt-domain-router.sh"
TESTSET="${SCRIPT_DIR}/.phase2b-testset.tsv"
RESULTS="${SCRIPT_DIR}/.phase2b-testresults.tsv"

QUIET=false
LATENCY=false
for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=true ;;
    --latency) LATENCY=true ;;
  esac
done

# ─── Pre-flight ──────────────────────────────────────────────────────────
if [ ! -x "$HOOK" ]; then
  echo "❌ hook missing or not executable: $HOOK" >&2
  exit 3
fi
if [ ! -f "$TESTSET" ]; then
  echo "❌ test set missing: $TESTSET" >&2
  exit 2
fi

# ─── Run cases via Python (yaml-free, simple TSV read + subprocess) ──────
# Python is already required by generate-keywords.sh. Keeps the runner
# BSD-portable without needing bats or similar.
python3 - "$HOOK" "$TESTSET" "$RESULTS" "$QUIET" <<'PY'
import json, subprocess, re, sys

hook, testset, results_path, quiet = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "true"

def run_case(msg: str):
    # Passive mode (TAD 2.8.4): hook does not emit stdout context.
    # Read .tad/hooks/.router.log last line instead. P1-A: derive log_path
    # from hook location to be cwd-independent.
    import os
    log_path = os.path.join(os.path.dirname(hook), ".router.log")

    # Capture pre-test log line count for delta detection.
    try:
        with open(log_path) as f:
            pre_lines = sum(1 for _ in f)
    except FileNotFoundError:
        pre_lines = 0

    out = subprocess.run(
        ["bash", hook],
        input=json.dumps({"prompt": msg}),
        capture_output=True, text=True, timeout=10,
    )
    if out.returncode != 0:
        return ("", f"EXIT{out.returncode}")

    # Read .router.log last line. Format (5-tuple, space-separated):
    #   <ISO-timestamp> <elapsed_ms> <pack_name|none> <matched/total|0> <msglen>
    # Example: 2026-04-27T09:30:59-0400 137 mobile-ui-design 1/13 4641
    try:
        with open(log_path) as f:
            lines = f.readlines()
        if len(lines) <= pre_lines:
            return ("", "NO_LOG_DELTA")  # hook didn't write — defensive
        last = lines[-1].strip().split()
        if len(last) < 5:
            return (None, f"LOG_PARSE_ERR:{last}")
        pack = last[2]
        ratio = last[3]
        # "none" = no keyword match. "whitelist_early_exit" = hook bailed on
        # whitelist-only short inputs like "yes" (line 95-98 of hook). Both
        # mean "no pack injection" — treat as empty for classify().
        if pack in ("none", "whitelist_early_exit") or ratio == "0":
            return ("", "")
        return (pack, ratio)
    except Exception as e:
        return (None, f"PARSE_ERR:{e}")

def classify(expected: str, actual: str) -> bool:
    if expected == "NONE":
        return not actual
    if expected.startswith("_any_"):
        fam = expected[5:]
        if fam == "web": return bool(actual) and actual.startswith("web-")
        if fam == "mobile": return bool(actual) and actual.startswith("mobile-")
        if fam == "ai": return bool(actual) and actual.startswith("ai-")
        if fam == "security": return actual in ("code-security", "supply-chain-security")
        if fam == "hw_fw_or_circuit": return actual in ("hw-firmware", "hw-circuit-design", "hw-testing")
        return False
    return actual == expected

cases = []
with open(testset) as f:
    for line in f:
        parts = line.rstrip("\n").split("\t")
        if len(parts) == 3:
            cases.append(parts)

pos_ids, neg_ids = set(), set()
results = []
correct = 0
for cid, expected, msg in cases:
    pack, ratio = run_case(msg)
    if expected == "NONE":
        neg_ids.add(cid)
    else:
        pos_ids.add(cid)
    ok = classify(expected, pack or "")
    if ok:
        correct += 1
    results.append((cid, expected, pack or "", ratio, ok))
    if not quiet:
        mark = "✅" if ok else "❌"
        print(f"  {mark} {cid}  expected={expected:28s}  actual={(pack or '-'):28s}  {ratio}")

total = len(cases)
pos_correct = sum(1 for c,e,p,r,ok in results if c in pos_ids and ok)
neg_correct = sum(1 for c,e,p,r,ok in results if c in neg_ids and ok)
pos_total = len(pos_ids)
neg_total = len(neg_ids)

print()
print(f"=== SUMMARY ===")
print(f"Total:    {correct}/{total} ({correct/total*100:.1f}%)")
print(f"Positive: {pos_correct}/{pos_total}")
print(f"Negative: {neg_correct}/{neg_total}")
print()
print(f"AC9 thresholds:")
total_pass = correct >= 21
pos_pass = pos_correct >= 17
neg_pass = neg_correct == neg_total
print(f"  total ≥ 21/30:       {'✅ PASS' if total_pass else '❌ FAIL'}")
print(f"  positive ≥ 17/24:    {'✅ PASS' if pos_pass else '❌ FAIL'}")
print(f"  negative all:        {'✅ PASS' if neg_pass else '❌ FAIL'}")

with open(results_path, "w") as f:
    for c, e, p, r, ok in results:
        f.write(f"{c}\t{e}\t{p}\t{r}\t{'PASS' if ok else 'FAIL'}\n")

if not (total_pass and pos_pass and neg_pass):
    if quiet:
        print("\nFailures:")
        for c,e,p,r,ok in results:
            if not ok:
                print(f"  {c}  expected={e}  actual={p or '-'}")
    sys.exit(1)
sys.exit(0)
PY
ACCURACY_EXIT=$?

# ─── Optional latency microbench ─────────────────────────────────────────
if [ "$LATENCY" = "true" ]; then
  echo
  echo "=== Latency (n=5, median target < 200ms) ==="
  SAMPLES=""
  for i in 1 2 3 4 5; do
    T=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000000' 2>/dev/null || echo 0)
    printf '%s' '{"prompt":"做一个 React button 组件用 typescript"}' | bash "$HOOK" > /dev/null
    T2=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000000' 2>/dev/null || echo 0)
    MS=$(( (T2 - T) / 1000 ))
    SAMPLES="$SAMPLES $MS"
    echo "  run $i: ${MS}ms"
  done
  MEDIAN=$(echo $SAMPLES | tr ' ' '\n' | grep -v '^$' | sort -n | awk '{a[NR]=$1} END {print a[int((NR+1)/2)]}')
  echo "  median: ${MEDIAN}ms"
  if [ "$MEDIAN" -lt 200 ] 2>/dev/null; then
    echo "  ✅ AC12 PASS"
  else
    echo "  ❌ AC12 FAIL (median ${MEDIAN}ms >= 200ms)"
    exit 1
  fi
fi

exit $ACCURACY_EXIT
