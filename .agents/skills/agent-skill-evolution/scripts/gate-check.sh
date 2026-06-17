#!/usr/bin/env bash
# gate-check.sh — Verify a self-evolving agent design has the four safety mechanisms
#
# Usage: bash gate-check.sh <path-to-design-doc-or-skill.md>
#        bash gate-check.sh --help
#
# Exit codes:
#   0 = PASS  (all 4 mechanisms found)
#   1 = FAIL  (0 mechanisms found)
#   2 = PARTIAL (1-3 mechanisms found)
#
# The four safety mechanisms (from SkillOpt research):
#   1. Validation gate — held-out evaluation set + accept/reject
#   2. Edit budget / LR — bounded edits, learning rate schedule
#   3. Protected regions — write isolation for safety-critical sections
#   4. Staging + adopt — nothing live changes until human approval

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -eq 0 ]]; then
  cat <<'USAGE'
gate-check.sh — Verify self-evolving agent safety mechanisms

Usage: bash gate-check.sh <path-to-design-doc>

Checks for 4 safety mechanisms required for safe self-evolution:

  1. Validation gate   grep: validation.gate|held.out|gate.*accept|gate.*reject
  2. Edit budget / LR  grep: edit.budget|learning.rate|bounded.edit|max.edits
  3. Protected regions  grep: protected.region|SLOW_UPDATE|APPENDIX|write.isolation
  4. Staging + adopt    grep: staging|nothing.live|human.adopt|backup

Exit codes:
  0  PASS    All 4 mechanisms present
  1  FAIL    0 mechanisms found — design is unsafe for self-evolution
  2  PARTIAL 1-3 mechanisms found — gaps need attention

Example:
  bash gate-check.sh my-agent/SKILL.md
USAGE
  exit 0
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

found=0
total=4

# Mechanism 1: Validation gate
if grep -qiE 'validation.gate|held.out|gate.*accept|gate.*reject' "$FILE" 2>/dev/null; then
  echo "  ✅ [1/4] Validation gate: FOUND"
  found=$((found + 1))
else
  echo "  ❌ [1/4] Validation gate: MISSING"
fi

# Mechanism 2: Edit budget / learning rate
if grep -qiE 'edit.budget|learning.rate|bounded.edit|max.edits' "$FILE" 2>/dev/null; then
  echo "  ✅ [2/4] Edit budget / LR: FOUND"
  found=$((found + 1))
else
  echo "  ❌ [2/4] Edit budget / LR: MISSING"
fi

# Mechanism 3: Protected regions
if grep -qiE 'protected.region|SLOW_UPDATE|APPENDIX|write.isolation' "$FILE" 2>/dev/null; then
  echo "  ✅ [3/4] Protected regions: FOUND"
  found=$((found + 1))
else
  echo "  ❌ [3/4] Protected regions: MISSING"
fi

# Mechanism 4: Staging + adopt
if grep -qiE 'staging|nothing.live|human.adopt|backup' "$FILE" 2>/dev/null; then
  echo "  ✅ [4/4] Staging + adopt: FOUND"
  found=$((found + 1))
else
  echo "  ❌ [4/4] Staging + adopt: MISSING"
fi

echo ""
echo "Result: $found/$total mechanisms found"

if [[ $found -eq $total ]]; then
  echo "PASS — all safety mechanisms present"
  exit 0
elif [[ $found -eq 0 ]]; then
  echo "FAIL — no safety mechanisms found; design is unsafe for self-evolution"
  exit 1
else
  echo "PARTIAL — $((total - found)) mechanism(s) missing; review gaps before proceeding"
  exit 2
fi
