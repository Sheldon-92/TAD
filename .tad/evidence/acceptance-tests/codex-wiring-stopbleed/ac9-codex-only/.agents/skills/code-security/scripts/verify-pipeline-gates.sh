#!/usr/bin/env bash
# verify-pipeline-gates.sh — Assert a CI config honors the Four-Gate fastest-fail-first
# ordering + the tool exit-code contract.
#
# This is the deterministic half of the cross-cutting "Four-Gate Pipeline" rule and the
# exit-code semantics in SKILL.md Step 1 — both are fixed contracts, NOT model judgment.
#
# Usage:
#   bash scripts/verify-pipeline-gates.sh <ci-config-file>   # e.g. .github/workflows/security.yml
#
# Checks:
#   1. ORDER: fast scanners (gitleaks, pre-commit, trivy fs) appear BEFORE slow scanners
#      (codeql, snyk, full nuclei). Fastest-fail-first = a slow full scan must not precede
#      the fast secret/IaC checks.
#   2. EXIT-CODE CONTRACT: any scanner invocation that swallows the failing exit code is
#      flagged. Failing exit codes by contract:
#        Semgrep   = 1
#        TruffleHog = 183  (verified leaked credentials)
#        Checkov   = 1
#        Gitleaks  = 1
#      A `|| true` / `continue-on-error: true` / `set +e` next to these defeats the gate.
#
# Requirements: grep, awk (POSIX). No network, no jq.
# Exit: 0 = all gate assertions pass; 1 = a gate assertion failed; 2 = usage/IO error.

set -euo pipefail

CFG="${1:-}"

if [ -z "$CFG" ] || [ ! -f "$CFG" ]; then
  echo "Usage: bash scripts/verify-pipeline-gates.sh <ci-config-file>" >&2
  exit 2
fi

FAIL=0
pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; FAIL=1; }

echo "Pipeline gate audit: $CFG"
echo ""

# ── Check 1: fastest-fail-first ordering ─────────────────────────────────────
echo "[1] Four-Gate fastest-fail-first ordering"

# Line number of first occurrence (0 if absent) for a regex.
firstline() { grep -niE "$1" "$CFG" 2>/dev/null | head -1 | cut -d: -f1; }

FAST=$(firstline 'gitleaks|pre-commit|trivy[[:space:]]+fs|tflint')
SLOW=$(firstline 'codeql|snyk[[:space:]]+test|zap-full-scan|nuclei[^-]*-as')
FAST="${FAST:-0}"; SLOW="${SLOW:-0}"

if [ "$FAST" -eq 0 ]; then
  fail "no fast pre-commit/secret/IaC scanner found (gitleaks/pre-commit/trivy fs/tflint) — fast gate missing"
elif [ "$SLOW" -ne 0 ] && [ "$FAST" -gt "$SLOW" ]; then
  fail "slow scanner (line $SLOW) runs BEFORE fast scanner (line $FAST) — violates fastest-fail-first"
else
  pass "fast scanners precede slow scanners (fast@${FAST}, slow@${SLOW:-none})"
fi

# ── Check 2: exit-code contract ──────────────────────────────────────────────
echo ""
echo "[2] Exit-code contract (Semgrep 1, TruffleHog 183, Checkov 1, Gitleaks 1)"

# Flag lines that invoke a gating scanner AND swallow its exit code on the same line.
SWALLOW='(\|\|[[:space:]]*true|continue-on-error:[[:space:]]*true|set[[:space:]]+\+e)'
for tool in semgrep trufflehog checkov gitleaks; do
  if grep -niE "$tool" "$CFG" | grep -iE "$SWALLOW" >/dev/null 2>&1; then
    LN=$(grep -niE "$tool" "$CFG" | grep -iE "$SWALLOW" | head -1 | cut -d: -f1)
    fail "$tool exit code is swallowed (|| true / continue-on-error) at line $LN — gate cannot fail the build"
  elif grep -qiE "$tool" "$CFG"; then
    pass "$tool present and not exit-code-swallowed"
  fi
done

# TruffleHog 183 explicit-handling hint (verified-only mode relies on the 183 code).
if grep -qiE 'trufflehog' "$CFG" && ! grep -qE '183' "$CFG"; then
  echo "  · note: TruffleHog present but exit code 183 (verified leaked credential) not referenced — confirm the gate keys off 183, not a generic non-zero."
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo ">>> PASS: pipeline honors fastest-fail-first ordering + exit-code contract."
  exit 0
else
  echo ">>> FAIL: pipeline gate assertions failed (see ✗ above)."
  exit 1
fi
