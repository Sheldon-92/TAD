#!/bin/bash
# p6a-layer2-reviewer-detect-test.sh — 5 cases for layer2-audit.sh reviewer-name detection
# (FR6, Phase 6-A.2, 2026-04-25)
#
# Uses LAYER2_AUDIT_REVIEW_ROOT env var (P1-5) to override the canonical
# reviews root with a fixture-controlled temp dir.
#
# Usage: bash .tad/evidence/fixtures/phase6/p6a-layer2-reviewer-detect-test.sh
# Exit:  0 on all 5 PASS; non-zero count on failures

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
AUDIT="$REPO_ROOT/.tad/hooks/lib/layer2-audit.sh"

PASS=0
FAIL=0
FAIL_DETAILS=""

emit_pass() {
  PASS=$((PASS + 1))
  printf "  PASS: %s\n" "$1"
}
emit_fail() {
  FAIL=$((FAIL + 1))
  FAIL_DETAILS="${FAIL_DETAILS}  FAIL: $1\n    detail: $2\n"
  printf "  FAIL: %s\n    detail: %s\n" "$1" "$2"
}

# Helper: create reviewer .md files (≥200 bytes to pass min-bytes filter)
make_reviewer_file() {
  local path="$1"
  local name="$2"
  cat > "$path" <<EOF
# $name review

Sample reviewer artifact for fixture testing. Padding to exceed the 200-byte
min-bytes filter in layer2-audit.sh. This is fixture-only content; does not
represent real review findings. Layer 2 audit's smoke-alarm size check
verifies the file is non-trivial; the new P6-A.2 reviewer-name detection
verifies the filename matches the canonical KNOWN_REVIEWERS list.
EOF
}

run_test() {
  local case_name="$1"
  local slug="$2"
  local expected_grep_pattern="$3"
  local expected_exit="$4"
  shift 4
  local files=("$@")

  local TMP_ROOT
  TMP_ROOT=$(mktemp -d)
  local DIR="$TMP_ROOT/$slug"
  mkdir -p "$DIR"

  for f in "${files[@]}"; do
    make_reviewer_file "$DIR/$f.md" "$f"
  done

  local out rc
  out=$(LAYER2_AUDIT_REVIEW_ROOT="$TMP_ROOT" bash "$AUDIT" "$slug" 2>&1)
  rc=$?

  rm -rf "$TMP_ROOT"

  local ok=true
  local why=""
  if [ "$rc" -ne "$expected_exit" ]; then
    ok=false
    why="exit=$rc expected=$expected_exit"
  fi
  if ! printf '%s' "$out" | grep -qE "$expected_grep_pattern"; then
    ok=false
    why="${why} no match for: $expected_grep_pattern"
  fi

  if $ok; then
    emit_pass "$case_name"
  else
    emit_fail "$case_name" "$why; output: $(printf '%s' "$out" | tr '\n' '|' | head -c 300)"
  fi
}

echo "═══ p6a-layer2-reviewer-detect-test — 5 cases ═══"

# Case 1: 2 distinct reviewers → DISTINCT_COUNT=2 (PASS exit 0)
run_test \
  "Case 1: code-reviewer + backend-architect (DISTINCT_COUNT=2)" \
  "phase6a-fixture-c1" \
  '^DISTINCT_COUNT=2' \
  0 \
  "code-reviewer" "backend-architect"

# Case 2: code-reviewer + self-review → DISTINCT_COUNT=1 + SUBSTITUTIONS contains self-review
TMP_ROOT2=$(mktemp -d)
DIR2="$TMP_ROOT2/phase6a-fixture-c2"
mkdir -p "$DIR2"
make_reviewer_file "$DIR2/code-reviewer.md" "code-reviewer"
make_reviewer_file "$DIR2/self-review.md" "self-review"
out2=$(LAYER2_AUDIT_REVIEW_ROOT="$TMP_ROOT2" bash "$AUDIT" "phase6a-fixture-c2" 2>&1)
rc2=$?
ok2=true; why2=""
if ! printf '%s' "$out2" | grep -qE '^DISTINCT_COUNT=1'; then ok2=false; why2="no DISTINCT_COUNT=1"; fi
if ! printf '%s' "$out2" | grep -qE '^SUBSTITUTIONS=.*self-review'; then ok2=false; why2="${why2}; no SUBSTITUTIONS=...self-review"; fi
if $ok2; then emit_pass "Case 2: code-reviewer + self-review (DISTINCT=1 + SUBSTITUTIONS)"; else emit_fail "Case 2" "$why2"; fi
rm -rf "$TMP_ROOT2"

# Case 3: code-reviewer only, slug = phase6a-fixture-c3 (NOT ending in -express)
# → WARN_REVIEWER_COUNT=1 (exit 0). NOTE: prior fixture used slug ending in
# "-non-express" which the case pattern correctly matched as *-express
# (spec is_express_slug treats anything ending in -express as express slug —
# a plain-word-suffix interpretation; "non-express" ends in "-express", just
# how the pattern is defined). Renamed slug to avoid the accidental match.
run_test \
  "Case 3: code-reviewer only, non-express slug → WARN_REVIEWER_COUNT=1" \
  "phase6a-fixture-c3-standard" \
  '^WARN_REVIEWER_COUNT=1$' \
  0 \
  "code-reviewer"

# Case 4: code-reviewer only, slug starts with express- → WARN_REVIEWER_COUNT=1_EXPRESS_OK (exit 0)
run_test \
  "Case 4: code-reviewer only, express-bugfix-styling slug → 1_EXPRESS_OK" \
  "express-bugfix-styling" \
  '^WARN_REVIEWER_COUNT=1_EXPRESS_OK$' \
  0 \
  "code-reviewer"

# Case 5: 3 distinct reviewers → DISTINCT_COUNT=3
run_test \
  "Case 5: code-reviewer + backend-architect + security-auditor (DISTINCT=3)" \
  "phase6a-fixture-c5" \
  '^DISTINCT_COUNT=3' \
  0 \
  "code-reviewer" "backend-architect" "security-auditor"

# ── Summary ──────────────────────────────────────────────────────────────
echo ""
echo "═══ Result: $PASS PASS, $FAIL FAIL ═══"
if [ "$FAIL" -gt 0 ]; then
  printf "%b" "$FAIL_DETAILS"
  exit 1
fi
exit 0
