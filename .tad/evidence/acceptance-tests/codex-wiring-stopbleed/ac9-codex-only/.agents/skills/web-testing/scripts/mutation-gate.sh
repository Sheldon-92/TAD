#!/usr/bin/env bash
# mutation-gate.sh — Parse a Stryker mutation report and assert mutation score >= floor.
#
# Why (Rule U4 / S6): line coverage can be gamed by AI-generated tests that exercise trivial
# paths. Mutation score = detected/(detected+undetected)*100 where detected = killed+timeout.
# Stryker's documented config thresholds: break 50, low 60, high 80 (stryker-mutator.io).
# This gate defaults the FLOOR to 60 (existing projects); pass 80 for new/business-critical code.
# Chasing 100% has diminishing returns and is impractical.
#
# Usage: bash scripts/mutation-gate.sh <stryker-report.json> [floor]
#        Default report path candidates: reports/mutation/mutation.json
#        Default floor: 60
#
# Exit 0: mutationScore >= floor
# Exit 1: mutationScore < floor
# Exit 2: bad usage / file missing / unparseable

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: bash scripts/mutation-gate.sh <stryker-report.json> [floor=60]"
  echo "  Asserts mutation score >= floor. detected = killed + timeout."
  echo "  Stryker thresholds: break 50 / low 60 / high 80. Use 80 for business-critical code."
  echo "  Generate input: npx stryker run  (jsonReporter -> reports/mutation/mutation.json)"
  exit 0
fi

REPORT="${1:-}"
if [[ -z "$REPORT" ]]; then
  for f in reports/mutation/mutation.json reports/mutation.json stryker.json; do
    if [[ -f "$f" ]]; then REPORT="$f"; break; fi
  done
fi
FLOOR="${2:-60}"

if [[ -z "$REPORT" || ! -f "$REPORT" ]]; then
  echo "✗ Stryker JSON report not found." >&2
  echo "  Enable the JSON reporter and run: npx stryker run" >&2
  echo "  Then pass: bash scripts/mutation-gate.sh reports/mutation/mutation.json [floor]" >&2
  exit 2
fi

# Stryker mutation-report-schema: files[].mutants[].status with values
# Killed | Survived | Timeout | NoCoverage | RuntimeError | CompileError | Ignored.
# detected = Killed + Timeout ; undetected = Survived + NoCoverage (per Stryker metrics docs).
# mutation score          = detected / (detected + undetected) * 100
# mutation score on covered code = detected / (detected + Survived) * 100  (excludes NoCoverage)
COMPUTE='
  const rep = JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));
  const c = { Killed:0, Survived:0, Timeout:0, NoCoverage:0, RuntimeError:0, CompileError:0, Ignored:0 };
  // Support both schema versions: top-level .files map, or already-aggregated mutants.
  const files = rep.files || {};
  for (const k of Object.keys(files)) {
    for (const m of (files[k].mutants || [])) { if (c[m.status] !== undefined) c[m.status]++; }
  }
  const detected   = c.Killed + c.Timeout;
  const undetected = c.Survived + c.NoCoverage;
  const total      = detected + undetected;
  const score        = total ? (detected / total) * 100 : 0;
  const coveredTotal = detected + c.Survived;
  const coveredScore = coveredTotal ? (detected / coveredTotal) * 100 : 0;
  console.log([score.toFixed(2), coveredScore.toFixed(2), c.Killed, c.Survived, c.Timeout, c.NoCoverage].join(" "));
'

if command -v node >/dev/null 2>&1; then
  read -r SCORE COVERED KILLED SURVIVED TIMEOUT NOCOV < <(node -e "$COMPUTE" "$REPORT")
else
  echo "✗ node not available to parse the Stryker report." >&2
  exit 2
fi

echo "=== Mutation Gate (Rule U4 / S6) ==="
echo "  Killed: $KILLED  Survived: $SURVIVED  Timeout: $TIMEOUT  NoCoverage: $NOCOV"
echo "  Mutation score (all):          ${SCORE}%   detected/(detected+undetected)"
echo "  Mutation score (covered code): ${COVERED}%  detected/(detected+survived) — isolates weak assertions"
echo "  Floor: ${FLOOR}%"
echo ""

PASS=$(awk -v s="$SCORE" -v f="$FLOOR" 'BEGIN{print (s>=f)?1:0}')
if [[ "$PASS" == "1" ]]; then
  echo "RESULT: PASS — mutation score ${SCORE}% >= floor ${FLOOR}%."
  exit 0
else
  echo "RESULT: FAIL — mutation score ${SCORE}% < floor ${FLOOR}%."
  echo "  Surviving mutants reveal weak assertions. A high NoCoverage count means missing tests;"
  echo "  a high Survived count means tests run the code but do not assert on its behavior (Rule U6)."
  exit 1
fi
