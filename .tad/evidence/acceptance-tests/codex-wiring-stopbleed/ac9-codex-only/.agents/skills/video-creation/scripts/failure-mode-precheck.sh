#!/usr/bin/env bash
# failure-mode-precheck.sh — Deterministic linter for the 6 banned timeline
# anti-patterns in a HyperFrames/Remotion composition.
#
# Turns the prose "Failure Mode Pre-Check" in SKILL.md Output Format into an
# executable gate (per QUALITY-BAR A10: hand deterministic ops to code, do not
# punt to Claude). Greps the composition source for the 6 banned patterns and
# exits non-zero on the first hit so CI/agents block the render.
#
# Usage:   bash scripts/failure-mode-precheck.sh <file-or-dir> [<file-or-dir> ...]
#          bash scripts/failure-mode-precheck.sh src/Composition.tsx
#          bash scripts/failure-mode-precheck.sh ./composition/
#
# Exit codes:
#   0  — clean (no banned pattern found)
#   1  — at least one banned anti-pattern found (render must be blocked)
#   2  — usage / no input files
#
# Requirements: bash, grep (BSD or GNU). No npm, no Windows paths.

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: bash scripts/failure-mode-precheck.sh <file-or-dir> [...]" >&2
  echo "  Scans HyperFrames/Remotion composition source for 6 banned timeline anti-patterns." >&2
  exit 2
fi

# Collect candidate source files (composition + timeline code only).
FILES=()
for arg in "$@"; do
  if [ -d "$arg" ]; then
    while IFS= read -r f; do
      FILES+=("$f")
    done < <(find "$arg" -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.html' -o -name '*.css' \))
  elif [ -f "$arg" ]; then
    FILES+=("$arg")
  else
    echo "✗ Not found: $arg" >&2
    exit 2
  fi
done

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "✗ No source files (.js/.jsx/.ts/.tsx/.html/.css) found in input." >&2
  exit 2
fi

# Each rule: label | extended-regex | why it breaks deterministic render.
# Patterns are anchored to the banned constructs from SKILL.md Output Format
# + references/visual-design.md §Anti-Patterns.
declare -a RULE_LABEL RULE_REGEX RULE_WHY
RULE_LABEL+=("Date.now() / new Date()");      RULE_REGEX+=('Date\.now\(|new[[:space:]]+Date\(');                       RULE_WHY+=("Non-deterministic clock → frame timing differs per render → blank/jittered frames")
RULE_LABEL+=("Math.random()");                RULE_REGEX+=('Math\.random\(');                                          RULE_WHY+=("Non-deterministic value → frame N renders differently each pass → flicker")
RULE_LABEL+=("setInterval / setTimeout");     RULE_REGEX+=('setInterval\(|setTimeout\(');                              RULE_WHY+=("Wall-clock timer not tied to frame seek → desync under headless-Chrome frame stepping")
RULE_LABEL+=("repeat: -1 (infinite loop)");   RULE_REGEX+=('repeat:[[:space:]]*-1');                                   RULE_WHY+=("Infinite GSAP loop never resolves the timeline → render hangs / never finishes")
RULE_LABEL+=("async/await in timeline");      RULE_REGEX+=('(async[[:space:]]+function|async[[:space:]]*\()|await[[:space:]]'); RULE_WHY+=("Awaited work inside timeline construction races the frame seeker → missing tweens")
RULE_LABEL+=("visibility (use autoAlpha)");   RULE_REGEX+=('visibility[[:space:]]*[:=][[:space:]]*.?(hidden|visible)');  RULE_WHY+=("visibility toggles are not tweenable/seekable in GSAP → use autoAlpha for deterministic fade")
RULE_LABEL+=("inline opacity:0");             RULE_REGEX+=('opacity:[[:space:]]*0[^.0-9]');                            RULE_WHY+=("Inline opacity:0 hides element before GSAP set() runs → element never appears on render")

FOUND=0
echo "=== Timeline Failure-Mode Pre-Check (${#FILES[@]} file(s)) ==="
for i in "${!RULE_LABEL[@]}"; do
  label="${RULE_LABEL[$i]}"
  regex="${RULE_REGEX[$i]}"
  why="${RULE_WHY[$i]}"
  # grep -nE across all files; -H to print filename. Suppress "no match" exit.
  hits="$(grep -HnE "$regex" "${FILES[@]}" 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    FOUND=1
    echo ""
    echo "✗ BANNED: $label"
    echo "  why: $why"
    echo "$hits" | sed 's/^/    /'
  fi
done

echo ""
if [ "$FOUND" -eq 0 ]; then
  echo "✓ PASS — none of the 6 banned timeline anti-patterns found. Render is unblocked."
  exit 0
else
  echo "✗ FAIL — banned anti-pattern(s) found above. Fix before rendering (see SKILL.md Output Format / references/visual-design.md §Anti-Patterns)."
  exit 1
fi
