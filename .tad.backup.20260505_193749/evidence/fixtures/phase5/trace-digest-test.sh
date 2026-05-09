#!/bin/bash
# trace-digest-test.sh — 5 fixture tests for trace-digest.sh (Phase 5 P5.4)
#
# Usage: bash .tad/evidence/fixtures/phase5/trace-digest-test.sh
# Exit: 0 on all PASS

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
DIGEST="$REPO_ROOT/.tad/hooks/lib/trace-digest.sh"

PASS=0
FAIL=0
FAIL_DETAILS=""

# Helper: setup a temp slug dir + run digest + check
run_test() {
  local name="$1"
  local setup_func="$2"
  local expected_exit="$3"
  local expected_grep="${4:-}"

  TEST_CWD=$(mktemp -d)
  cd "$TEST_CWD"
  mkdir -p ".tad/evidence/traces/per-handoff"

  # Run setup function (creates slug dir + fixture JSONL)
  "$setup_func" "$TEST_CWD"

  # Determine slug from setup (function exports SLUG)
  SLUG="${TEST_SLUG:-fixture-slug}"

  out=$(bash "$DIGEST" "$SLUG" 2>&1)
  rc=$?

  cd "$REPO_ROOT"

  ok=true
  if [ "$rc" -ne "$expected_exit" ]; then
    ok=false
    reason="exit=$rc expected=$expected_exit"
  fi
  if [ -n "$expected_grep" ] && ! printf '%s' "$out" | grep -qE "$expected_grep"; then
    ok=false
    reason="${reason:-} no match for: $expected_grep"
  fi

  if $ok; then
    PASS=$((PASS + 1))
    printf "  PASS: %s\n" "$name"
  else
    FAIL=$((FAIL + 1))
    FAIL_DETAILS="${FAIL_DETAILS}  FAIL: $name ($reason)\n    output: $(printf '%s' "$out" | head -3)\n"
    printf "  FAIL: %s (%s)\n" "$name" "$reason"
  fi

  rm -rf "$TEST_CWD"
  unset TEST_SLUG
}

# ── Setup functions ────────────────────────────────────────────────────
setup_clean() {
  local cwd="$1"
  TEST_SLUG="clean-slug"
  local d="$cwd/.tad/evidence/traces/per-handoff/$TEST_SLUG"
  mkdir -p "$d"
  for i in 1 2 3 4 5; do
    cat >> "$d/2026-04-25.jsonl" <<EOF
{"ts":"2026-04-25T10:0$i:00Z","type":"step_start","project":"test","domain":"d","capability":"c","step":"s$i"}
{"ts":"2026-04-25T10:0$i:30Z","type":"step_end","project":"test","domain":"d","capability":"c","step":"s$i","status":"completed","tool":""}
EOF
  done
  export TEST_SLUG
}

setup_orphan() {
  local cwd="$1"
  TEST_SLUG="orphan-slug"
  local d="$cwd/.tad/evidence/traces/per-handoff/$TEST_SLUG"
  mkdir -p "$d"
  # 3 starts but only 2 ends matching 2 of them → 1 orphan
  cat >> "$d/2026-04-25.jsonl" <<EOF
{"ts":"2026-04-25T10:01:00Z","type":"step_start","project":"test","domain":"d","capability":"c","step":"s1"}
{"ts":"2026-04-25T10:02:00Z","type":"step_start","project":"test","domain":"d","capability":"c","step":"s2"}
{"ts":"2026-04-25T10:03:00Z","type":"step_start","project":"test","domain":"d","capability":"c","step":"s3"}
{"ts":"2026-04-25T10:04:00Z","type":"step_end","project":"test","domain":"d","capability":"c","step":"s1","status":"completed","tool":""}
{"ts":"2026-04-25T10:05:00Z","type":"step_end","project":"test","domain":"d","capability":"c","step":"s2","status":"completed","tool":""}
EOF
  export TEST_SLUG
}

setup_failed() {
  local cwd="$1"
  TEST_SLUG="failed-slug"
  local d="$cwd/.tad/evidence/traces/per-handoff/$TEST_SLUG"
  mkdir -p "$d"
  for i in 1 2 3 4 5; do
    status=$([ "$i" = "3" ] && echo "failed" || echo "completed")
    cat >> "$d/2026-04-25.jsonl" <<EOF
{"ts":"2026-04-25T10:0$i:00Z","type":"step_start","project":"test","domain":"d","capability":"c","step":"s$i"}
{"ts":"2026-04-25T10:0$i:30Z","type":"step_end","project":"test","domain":"d","capability":"c","step":"s$i","status":"$status","tool":""}
EOF
  done
  export TEST_SLUG
}

setup_missing() {
  TEST_SLUG="missing-slug-not-created"
  export TEST_SLUG
  # Don't create dir
}

setup_invalid() {
  TEST_SLUG="evil/../../../etc"
  export TEST_SLUG
}

# ── Run fixtures ───────────────────────────────────────────────────────
echo "═══ trace-digest-test.sh — 5 fixtures ═══"

run_test "fixture-clean-slug (5/5/0/0)" setup_clean 0 'step_start events: 5'
run_test "fixture-orphan-slug (3/2/0/1)" setup_orphan 1 'orphaned starts \(no end\): 1'
run_test "fixture-failed-slug (5/4/1/0)" setup_failed 1 'step_end failed: 1'
run_test "fixture-missing-slug" setup_missing 2 'per-handoff trace dir missing'
run_test "fixture-invalid-slug" setup_invalid 2 'invalid slug'

echo ""
echo "═══ Result: $PASS PASS, $FAIL FAIL ═══"
if [ "$FAIL" -gt 0 ]; then
  printf "%b" "$FAIL_DETAILS"
  exit 1
fi
exit 0
