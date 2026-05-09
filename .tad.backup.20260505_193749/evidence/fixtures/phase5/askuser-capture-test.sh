#!/bin/bash
# askuser-capture-test.sh — 10 fixture tests for askuser-capture.sh (Phase 5 P5.2)
# Tests: 5 basic + 5 slug-derivation
#
# Usage: bash .tad/evidence/fixtures/phase5/askuser-capture-test.sh
# Exit:  0 on all PASS; non-zero count on failures
#
# Privacy boundary fixture (#2): contains literal "SECRET_OTHER_CONTENT_xyz123"
# in user "Other" free-text. JSONL output MUST NOT contain this string.

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
HOOK="$REPO_ROOT/.tad/hooks/lib/askuser-capture.sh"

# Use a separate decisions dir for tests (no pollution of real evidence)
TEST_DECISIONS_DIR="$REPO_ROOT/.tad/evidence/fixtures/phase5/test-decisions-$$"
mkdir -p "$TEST_DECISIONS_DIR"

PASS=0
FAIL=0
FAIL_DETAILS=""

# Helper: run hook with given JSON envelope and check JSONL output
run_test() {
  local name="$1"
  local envelope="$2"
  local check_func="$3"
  local check_arg="${4:-}"

  # Clear test JSONL
  TODAY=$(date +%Y-%m-%d)
  TEST_JSONL="$TEST_DECISIONS_DIR/$TODAY.jsonl"
  rm -f "$TEST_JSONL"

  # Run hook with custom decisions dir via env? No — script hardcodes path.
  # Instead: run from temp cwd that has its own .tad/evidence/decisions/
  TEST_CWD=$(mktemp -d)
  mkdir -p "$TEST_CWD/.tad/evidence/decisions"
  mkdir -p "$TEST_CWD/.tad/active/handoffs"

  # If check_arg specifies fixture handoffs to create, do so
  if [ -n "${check_arg}" ] && [[ "$check_arg" == handoff:* ]]; then
    # Format: handoff:filename1,filename2,...
    # Stagger mtimes deterministically (older first, newer last) using touch -t
    # macOS BSD stat -f%m returns integer seconds — need ≥1s difference.
    files="${check_arg#handoff:}"
    IFS=',' read -ra HANDOFFS <<< "$files"
    i=0
    for h in "${HANDOFFS[@]}"; do
      touch "$TEST_CWD/.tad/active/handoffs/$h"
      # Set explicit mtime: 2026-04-25 12:00:00 + i seconds
      mtime_str=$(printf '202604251200.%02d' "$i")
      touch -t "$mtime_str" "$TEST_CWD/.tad/active/handoffs/$h"
      i=$((i + 1))
    done
  fi

  # Substitute test cwd into envelope (for slug derivation tests)
  ENVELOPE_FINAL=$(printf '%s' "$envelope" | sed "s|REPLACE_CWD|$TEST_CWD|g")

  # Run hook from test cwd
  cd "$TEST_CWD" && printf '%s' "$ENVELOPE_FINAL" | bash "$HOOK"
  RC=$?
  cd "$REPO_ROOT"

  TEST_JSONL="$TEST_CWD/.tad/evidence/decisions/$TODAY.jsonl"

  # Run check function
  if "$check_func" "$TEST_JSONL" "$RC" "$envelope"; then
    PASS=$((PASS + 1))
    printf "  PASS: %s\n" "$name"
  else
    FAIL=$((FAIL + 1))
    FAIL_DETAILS="${FAIL_DETAILS}  FAIL: $name (RC=$RC, jsonl=$([ -f "$TEST_JSONL" ] && echo present || echo absent))\n"
    printf "  FAIL: %s (RC=%s)\n" "$name" "$RC"
  fi

  rm -rf "$TEST_CWD"
}

# ── Check functions ───────────────────────────────────────────────────
check_basic_pass() {
  local jsonl="$1"
  [ -s "$jsonl" ] && /usr/bin/jq -e '.is_other == false' "$jsonl" >/dev/null 2>&1
}

check_other_no_secret() {
  local jsonl="$1"
  [ -s "$jsonl" ] || return 1
  /usr/bin/jq -e '.is_other == true' "$jsonl" >/dev/null 2>&1 || return 1
  # CRITICAL: SECRET_OTHER_CONTENT_xyz123 must NOT appear anywhere in JSONL
  if /usr/bin/grep -q 'SECRET_OTHER_CONTENT_xyz123' "$jsonl"; then
    echo "    LEAK DETECTED: secret string in JSONL!" >&2
    return 1
  fi
  return 0
}

check_multiselect() {
  # P1 fix from code-reviewer 2026-04-25: also assert is_other=false AND
  # selection contains both labels (previously this only checked multi_select).
  local jsonl="$1"
  [ -s "$jsonl" ] || return 1
  /usr/bin/jq -e '.multi_select == true and .is_other == false and (.selection | contains("P")) and (.selection | contains("Q"))' "$jsonl" >/dev/null 2>&1
}

check_no_jsonl_exit_zero() {
  local jsonl="$1"
  local rc="$2"
  [ "$rc" -eq 0 ] && [ ! -s "$jsonl" ]
}

check_slug_eq() {
  local jsonl="$1"
  local rc="$2"
  local envelope="$3"
  [ -s "$jsonl" ] || return 1
  expected=$(printf '%s' "$envelope" | grep -oE '__SLUG_EXPECT_[a-zA-Z0-9_-]+' | head -1 | sed 's/__SLUG_EXPECT_//')
  actual=$(/usr/bin/jq -r '.slug // "null"' "$jsonl")
  if [ "$expected" = "null_literal" ]; then
    [ "$actual" = "null" ]
  else
    [ "$actual" = "$expected" ]
  fi
}

check_slug_null() {
  local jsonl="$1"
  [ -s "$jsonl" ] || return 1
  /usr/bin/jq -e '.slug == null' "$jsonl" >/dev/null 2>&1
}

# ── Fixtures ───────────────────────────────────────────────────────────

echo "═══ askuser-capture-test.sh — 10 fixtures ═══"

# Basic 1: single question, single selection in options
echo "─── Basic Group ───"
run_test "fixture-basic" '{
  "session_id":"s1","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q1?","options":[{"label":"A"},{"label":"B"},{"label":"C"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q1?":"A"}}
}' check_basic_pass

# Basic 2: Other free-text — privacy test (AC-P5.2-e)
run_test "fixture-other-no-secret" '{
  "session_id":"s2","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q2?","options":[{"label":"X"},{"label":"Y"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q2?":"SECRET_OTHER_CONTENT_xyz123"}}
}' check_other_no_secret

# Basic 3: multiSelect
run_test "fixture-multiselect" '{
  "session_id":"s3","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q3?","options":[{"label":"P"},{"label":"Q"}],"multiSelect":true}]},
  "tool_response":{"answers":{"q3?":["P","Q"]}}
}' check_multiselect

# Basic 4: malformed JSON
run_test "fixture-malformed" '{this is not json' check_no_jsonl_exit_zero

# Basic 5: empty stdin
run_test "fixture-empty-stdin" '' check_no_jsonl_exit_zero

# Slug 1: 0 active handoffs → slug=null
echo "─── Slug Group ───"
run_test "fixture-slug-zero-handoffs" '{
  "session_id":"s6","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q6?","options":[{"label":"A"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q6?":"A"}}
}' check_slug_null

# Slug 2: 1 active handoff → slug derived (need __SLUG_EXPECT_test-slug in env)
run_test "fixture-slug-one-handoff" '{
  "session_id":"s7-__SLUG_EXPECT_test-slug","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q7?","options":[{"label":"A"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q7?":"A"}}
}' check_slug_eq "handoff:HANDOFF-20260425-test-slug.md"

# Slug 3: 2 active handoffs → newest mtime wins
run_test "fixture-slug-multi-handoffs" '{
  "session_id":"s8-__SLUG_EXPECT_newer-slug","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q8?","options":[{"label":"A"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q8?":"A"}}
}' check_slug_eq "handoff:HANDOFF-20260424-older-slug.md,HANDOFF-20260425-newer-slug.md"

# Slug 4: handoff with path-traversal-like name (filename "evil/../" but bash filename can't contain /, so test invalid chars)
run_test "fixture-slug-traversal-rejected" '{
  "session_id":"s9-__SLUG_EXPECT_null_literal","cwd":"REPLACE_CWD","tool_input":{"questions":[{"question":"q9?","options":[{"label":"A"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q9?":"A"}}
}' check_slug_eq "handoff:HANDOFF-20260425---bad-leading-dash.md"

# Slug 5: envelope missing cwd → slug=null (degraded gracefully)
run_test "fixture-slug-no-cwd" '{
  "session_id":"s10","tool_input":{"questions":[{"question":"q10?","options":[{"label":"A"}],"multiSelect":false}]},
  "tool_response":{"answers":{"q10?":"A"}}
}' check_slug_null

# ── Cleanup + summary ─────────────────────────────────────────────────
rm -rf "$TEST_DECISIONS_DIR"

echo ""
echo "═══ Result: $PASS PASS, $FAIL FAIL ═══"
if [ "$FAIL" -gt 0 ]; then
  printf "%b" "$FAIL_DETAILS"
  exit 1
fi
exit 0
