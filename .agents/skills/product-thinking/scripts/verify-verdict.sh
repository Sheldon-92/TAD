#!/usr/bin/env bash
# verify-verdict.sh — Structural rigor verifier for a /pressure-test output.
#
# Usage: bash scripts/verify-verdict.sh <pressure-test-output.md>
#
# Asserts the output is WELL-FORMED — i.e. it carries the rigor structure the
# /pressure-test protocol requires. It does NOT judge the conclusion: a rigorous
# KILL and a rigorous BUILD both PASS. This mirrors the rubric's conclusion-neutral
# firewall (references/pressure-test-rubric.md §C — score rigor, never the verdict).
#
# Checks (all must pass):
#   1. Exactly ONE terminal verdict token (BUILD | PIVOT | KILL) on a VERDICT line
#   2. A Confidence score in the form "N/10" (1-10)
#   3. A Fatal Flaws count line
#   4. A FACT / ASSUMPTION evidence tally
#   5. A 2-Week (validation) Plan section
#   6. An explicit Success signal inside that plan
#
# Requirements: bash, grep (BSD/GNU compatible). No npm, no jq.

set -euo pipefail

FILE="${1:-}"

if [ -z "$FILE" ]; then
  echo "Usage: bash scripts/verify-verdict.sh <pressure-test-output.md>" >&2
  exit 2
fi

if [ ! -f "$FILE" ]; then
  echo "✗ File not found: $FILE" >&2
  exit 2
fi

FAIL=0
pass() { printf '  ✓ %s\n' "$1"; }
fail() { printf '  ✗ %s\n' "$1" >&2; FAIL=1; }

echo "=== /pressure-test structural verifier: $FILE ==="

# 1. Exactly one terminal verdict token on a VERDICT line.
#    grep -E 'VERDICT' line, then count distinct BUILD/PIVOT/KILL tokens on it.
VERDICT_LINE="$(grep -E '^[^a-z]*VERDICT' "$FILE" | grep -Eo 'BUILD|PIVOT|KILL' | sort -u || true)"
VERDICT_COUNT="$(printf '%s\n' "$VERDICT_LINE" | grep -c '[A-Z]' || true)"
if [ "$VERDICT_COUNT" -eq 1 ]; then
  pass "Terminal verdict present and unambiguous ($VERDICT_LINE)"
else
  fail "Need exactly ONE of BUILD/PIVOT/KILL on a VERDICT line (found: ${VERDICT_COUNT:-0})"
fi

# 2. Confidence N/10 (1-10).
if grep -Eiq 'Confidence:?[[:space:]]*(10|[1-9])[[:space:]]*/[[:space:]]*10' "$FILE"; then
  pass "Confidence score in N/10 form present"
else
  fail "Missing 'Confidence: N/10' (N = 1-10)"
fi

# 3. Fatal Flaws count.
if grep -Eiq 'Fatal Flaws?:?[[:space:]]*[0-9]' "$FILE"; then
  pass "Fatal Flaws count present"
else
  fail "Missing 'Fatal Flaws: <count>' line"
fi

# 4. FACT / ASSUMPTION tally (both labels must appear).
if grep -Eq 'FACT' "$FILE" && grep -Eiq 'ASSUMPTION' "$FILE"; then
  pass "FACT / ASSUMPTION evidence tally present"
else
  fail "Missing FACT/ASSUMPTION evidence labeling"
fi

# 5. 2-week validation plan section.
if grep -Eiq '2.?week.*(validation|plan)|validation plan' "$FILE"; then
  pass "2-Week validation plan section present"
else
  fail "Missing 2-Week validation plan section"
fi

# 6. Explicit Success signal.
if grep -Eiq 'Success signal' "$FILE"; then
  pass "Explicit Success signal present"
else
  fail "Missing explicit 'Success signal' in the validation plan"
fi

echo "---"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS — output is structurally well-formed (rigor structure present)."
  echo "NOTE: this asserts STRUCTURE only; the BUILD/PIVOT/KILL conclusion is not judged here."
  exit 0
else
  echo "RESULT: FAIL — output is missing required rigor structure (see ✗ above)." >&2
  exit 1
fi
