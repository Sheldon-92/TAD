#!/usr/bin/env bash
# AC-P1.3 — layer2-audit.sh slug truncation fallback
# Covers: AC-P1.3-a (strict match), -b (truncated match), -c (no match), -d (warn stderr), -e (single-segment)
#
# Strategy: set up a throwaway fixture root with .tad/evidence/reviews/blake/<slug>/ dirs
# containing a dummy reviewer .md file ≥200B, cd into it, run the script.
# Cleanup via trap.

set -uo pipefail

SCRIPT=$(cd "$(dirname "$0")" && pwd)/../../../hooks/lib/layer2-audit.sh
SCRIPT=$(cd "$(dirname "$SCRIPT")" && pwd)/$(basename "$SCRIPT")
# Resolve absolute path — script is at .tad/hooks/lib/layer2-audit.sh relative to repo root
REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
SCRIPT="${REPO_ROOT}/.tad/hooks/lib/layer2-audit.sh"

if [ ! -x "$SCRIPT" ]; then
  echo "FAIL: script not executable: $SCRIPT"
  exit 1
fi

FIXTURE_ROOT=$(mktemp -d -t layer2-audit-fixture.XXXXXX)
trap 'rm -rf "$FIXTURE_ROOT"' EXIT

mkdir -p "${FIXTURE_ROOT}/.tad/evidence/reviews/blake"

# Create a dummy reviewer artifact (≥200B so size gate passes)
_make_review() {
  local dir="$1"
  mkdir -p "$dir"
  # 300+ byte content
  printf 'code-reviewer review for %s\n\n## Findings\n\nP0: 0\nP1: 0\n\n%s\n' \
    "$dir" "$(printf 'padding %.0s' {1..20})" > "${dir}/code-reviewer.md"
}

PASS=0
FAIL=0

_assert() {
  local name="$1" expected="$2" actual="$3" stderr_file="${4:-}"
  if [ "$expected" = "$actual" ]; then
    printf '[PASS] %s (exit=%s)\n' "$name" "$actual"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (expected exit=%s, got exit=%s)\n' "$name" "$expected" "$actual"
    [ -n "$stderr_file" ] && [ -s "$stderr_file" ] && printf '      stderr: %s\n' "$(cat "$stderr_file")"
    FAIL=$((FAIL + 1))
  fi
}

_assert_stderr_contains() {
  local name="$1" needle="$2" stderr_file="$3"
  if grep -q -F "$needle" "$stderr_file" 2>/dev/null; then
    printf '[PASS] %s (stderr contains %s)\n' "$name" "'$needle'"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (stderr missing %s)\n      stderr: %s\n' \
      "$name" "'$needle'" "$(cat "$stderr_file" 2>/dev/null)"
    FAIL=$((FAIL + 1))
  fi
}

# ── AC-P1.3-a: strict-match (no regression) ──
_make_review "${FIXTURE_ROOT}/.tad/evidence/reviews/blake/exact-slug"
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" exact-slug 2>"$stderr"); rc=$?
_assert "AC-P1.3-a strict-match PASS" 0 "$rc" "$stderr"
# no warn on stderr for strict match
if [ ! -s "$stderr" ]; then
  printf '[PASS] AC-P1.3-a no WARN on stderr for strict match\n'
  PASS=$((PASS + 1))
else
  printf '[FAIL] AC-P1.3-a unexpected stderr: %s\n' "$(cat "$stderr")"
  FAIL=$((FAIL + 1))
fi
rm -f "$stderr"

# ── AC-P1.3-b: truncated match (1-level) ──
_make_review "${FIXTURE_ROOT}/.tad/evidence/reviews/blake/loop-mpr121-da7280"
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" loop-mpr121-da7280-integration 2>"$stderr"); rc=$?
_assert "AC-P1.3-b truncated match PASS (exit 0, not 1)" 0 "$rc" "$stderr"
_assert_stderr_contains "AC-P1.3-d truncated match emits WARN" "WARN" "$stderr"
_assert_stderr_contains "AC-P1.3-d warn mentions truncated slug" "loop-mpr121-da7280" "$stderr"
rm -f "$stderr"

# ── AC-P1.3-c: completely missing slug (truncation also fails) → exit 1 ──
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" nonexistent-slug-xyz 2>"$stderr"); rc=$?
_assert "AC-P1.3-c completely missing → exit 1" 1 "$rc" "$stderr"
_assert_stderr_contains "AC-P1.3-c FAIL message" "FAIL" "$stderr"
rm -f "$stderr"

# ── AC-P1.3-e: single-segment slug (no '-'), dir missing, no infinite loop ──
# macOS has no stock `timeout`; use `gtimeout` if available, else `perl alarm`.
# Rationale: single-segment slug must fall through to original FAIL with no loop.
# Bounded logic verified by reading the code (at most 2 truncations, all guarded).
if command -v gtimeout >/dev/null 2>&1; then
  stderr=$(mktemp); (cd "$FIXTURE_ROOT" && gtimeout 10 bash "$SCRIPT" foo 2>"$stderr"); rc=$?
elif command -v perl >/dev/null 2>&1; then
  stderr=$(mktemp); (cd "$FIXTURE_ROOT" && perl -e 'alarm 10; exec @ARGV' -- bash "$SCRIPT" foo 2>"$stderr"); rc=$?
else
  stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" foo 2>"$stderr"); rc=$?
fi
_assert "AC-P1.3-e single-segment → exit 1 (no loop)" 1 "$rc" "$stderr"
rm -f "$stderr"

# ── Bonus: 2-level truncation ──
_make_review "${FIXTURE_ROOT}/.tad/evidence/reviews/blake/alpha"
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" alpha-beta-gamma 2>"$stderr"); rc=$?
_assert "Bonus 2-level truncation PASS" 0 "$rc" "$stderr"
_assert_stderr_contains "Bonus 2-level truncation WARN" "doubly-truncated" "$stderr"
rm -f "$stderr"

# ── Bonus: 3-level slug where only full match should work at 1-level (not 2) ──
# alpha-beta-gamma-delta with review dir only at alpha-beta-gamma
# Expected: 1-level truncation catches it
_make_review "${FIXTURE_ROOT}/.tad/evidence/reviews/blake/delta-echo-foxtrot"
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" delta-echo-foxtrot-golf 2>"$stderr"); rc=$?
_assert "Bonus 1-level truncation for 4-segment slug" 0 "$rc" "$stderr"
rm -f "$stderr"

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
