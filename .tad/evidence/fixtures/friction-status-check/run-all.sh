#!/usr/bin/env bash
# run-all.sh — Fixture harness for friction-status-check.sh.
# Runs each fixture, verifies expected exit code and output text.
# Exit 0 if all pass, exit 1 if any fail.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CHECKER="$SCRIPT_DIR/../../../hooks/lib/friction-status-check.sh"
FIXTURE_DIR="$SCRIPT_DIR"

PASS_COUNT=0
FAIL_COUNT=0

check() {
  local name="$1"
  local fixture="$2"
  local expected_exit="$3"
  local required_text="$4"

  printf '%s\n' "--- $name ---"
  out=$(bash "$CHECKER" "$fixture" 2>&1)
  actual_exit=$?

  if [ "$actual_exit" -ne "$expected_exit" ]; then
    printf "  FAIL: expected exit %d, got %d\n" "$expected_exit" "$actual_exit"
    printf "  Output:\n%s\n" "$out"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  if [ -n "$required_text" ]; then
    if ! printf '%s\n' "$out" | grep -q "$required_text"; then
      printf "  FAIL: expected output to contain '%s'\n" "$required_text"
      printf "  Output:\n%s\n" "$out"
      FAIL_COUNT=$((FAIL_COUNT + 1))
      return
    fi
  fi

  printf "  PASS (exit=%d, text matched)\n" "$actual_exit"
  PASS_COUNT=$((PASS_COUNT + 1))
}

# --- Fixtures ---
check "pass (clean report)" \
  "$FIXTURE_DIR/pass.md" \
  0 \
  "RESULT: clean"

check "blocked-as-pass (BLOCKED row under PASS)" \
  "$FIXTURE_DIR/blocked-as-pass.md" \
  1 \
  "WARN"

check "missing-friction-status (no section under PASS)" \
  "$FIXTURE_DIR/missing-friction-status.md" \
  1 \
  "WARN"

check "pending-text-mismatch (verdict pass but prose pending)" \
  "$FIXTURE_DIR/pending-text-mismatch.md" \
  1 \
  "WARN"

# --- Summary ---
printf "\n=== Fixture Results: %d passed, %d failed ===\n" "$PASS_COUNT" "$FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
