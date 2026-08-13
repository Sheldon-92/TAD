#!/usr/bin/env bash
# graph-arch-lint.sh — Deterministic structural linter for the knowledge-graph pack.
#
# Usage: bash scripts/graph-arch-lint.sh [pack-root]
#   pack-root defaults to the parent dir of this script (the knowledge-graph/ pack).
#
# Checks (all deterministic — no LLM, no network):
#   1. Fixture discriminative_pattern is a grep -oE-parseable alternation,
#      and min_discriminative is a positive integer.
#   2. references/ is exactly one level deep (no nested subdirs) — Anthropic
#      best-practice "references one level deep".
#   3. Every reference file carries a determinismLevel annotation for each rule.
#   4. SKILL.md / references do NOT recommend a deprecated graph DB
#      (RedisGraph EOL 2025-01; Kuzu embedded archived after the 2025-10 Apple
#      acquisition) outside an explicit old-patterns / deprecated isolation block.
#
# Exit codes:
#   0 = all checks pass
#   1 = at least one check failed
#   2 = usage / environment error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="${1:-$(cd "$SCRIPT_DIR/.." && pwd)}"

if [ ! -d "$PACK_ROOT" ]; then
  echo "✗ Pack root not found: $PACK_ROOT" >&2
  exit 2
fi

SKILL="$PACK_ROOT/SKILL.md"
REF_DIR="$PACK_ROOT/references"
EX_DIR="$PACK_ROOT/examples"

if [ ! -f "$SKILL" ]; then
  echo "✗ SKILL.md not found under $PACK_ROOT" >&2
  exit 2
fi

ERRORS=0
fail() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
ok()   { echo "  ✓ $1"; }

echo "=== knowledge-graph pack lint: $PACK_ROOT ==="
echo ""

# ── Check 1: fixture discriminative_pattern is grep -oE-parseable ────────────
echo "[ 1/4 ] Fixture discriminative gate is parseable..."
FIXTURE="$(find "$EX_DIR" -name '*.md' 2>/dev/null | head -1)"
if [ -z "$FIXTURE" ]; then
  fail "no fixture found under examples/"
else
  PATTERN="$(grep -E '^discriminative_pattern:' "$FIXTURE" | head -1 | sed 's/^discriminative_pattern: *//; s/^"//; s/"$//')"
  MIN_D="$(grep -E '^min_discriminative:' "$FIXTURE" | head -1 | sed 's/^min_discriminative: *//')"
  if [ -z "$PATTERN" ]; then
    fail "$FIXTURE missing discriminative_pattern (A9)"
  elif ! printf 'LazyGraphRAG 700x test\n' | grep -oE "$PATTERN" >/dev/null 2>&1; then
    fail "discriminative_pattern is not a valid grep -oE alternation: $PATTERN"
  else
    ok "discriminative_pattern compiles under grep -oE"
  fi
  if ! printf '%s' "$MIN_D" | grep -qE '^[1-9][0-9]*$'; then
    fail "min_discriminative is not a positive integer: '$MIN_D'"
  else
    ok "min_discriminative = $MIN_D"
  fi
fi
echo ""

# ── Check 2: references/ is exactly one level deep ───────────────────────────
echo "[ 2/4 ] references/ is one level deep (no nesting)..."
if [ -d "$REF_DIR" ]; then
  NESTED="$(find "$REF_DIR" -mindepth 1 -type d 2>/dev/null)"
  if [ -n "$NESTED" ]; then
    fail "references/ contains nested subdirectories: $NESTED"
  else
    ok "references/ has no nested subdirectories"
  fi
else
  fail "references/ directory missing"
fi
echo ""

# ── Check 3: every reference rule carries a determinismLevel annotation ──────
echo "[ 3/4 ] Each reference annotates determinismLevel..."
if [ -d "$REF_DIR" ]; then
  for ref in "$REF_DIR"/*.md; do
    [ -e "$ref" ] || continue
    name="$(basename "$ref")"
    # Count rule headings (### XYZn:) vs determinismLevel annotations.
    RULES="$(grep -cE '^### [A-Z]+[0-9]+:' "$ref" || true)"
    DLEVELS="$(grep -cE 'determinismLevel\*?\*?:' "$ref" || true)"
    if [ "$RULES" -eq 0 ]; then
      fail "$name has no '### RULEn:' headings — cannot verify annotation coverage"
    elif [ "$DLEVELS" -lt "$RULES" ]; then
      fail "$name: $DLEVELS determinismLevel annotations < $RULES rules"
    else
      ok "$name: $DLEVELS determinismLevel ≥ $RULES rules"
    fi
  done
else
  fail "references/ directory missing"
fi
echo ""

# ── Check 4: no deprecated graph DB recommended outside an isolation block ───
echo "[ 4/4 ] No deprecated DB (RedisGraph/Kuzu) recommended outside old-patterns..."
# Deprecated engines that an agent must NOT recommend for new long-term builds.
DEPRECATED='RedisGraph|Kuzu|Kùzu'
for f in "$SKILL" "$REF_DIR"/*.md; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  HITS="$(grep -nE "$DEPRECATED" "$f" 2>/dev/null || true)"
  [ -z "$HITS" ] && continue
  # A file that mentions a deprecated engine MUST also carry an isolation marker.
  if grep -qiE 'deprecated|old.?pattern|EOL|archived|do not.{0,30}recommend|migration' "$f"; then
    ok "$name: deprecated-DB mention is inside an old-patterns/deprecated isolation block"
  else
    fail "$name mentions a deprecated DB with no old-patterns/deprecated isolation marker:"
    echo "$HITS" | sed 's/^/        /'
  fi
done
echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
if [ "$ERRORS" -eq 0 ]; then
  echo "=== PASS: 4/4 checks clean ==="
  exit 0
else
  echo "=== FAIL: $ERRORS check(s) failed ==="
  exit 1
fi
