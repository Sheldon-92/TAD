#!/usr/bin/env bash
# run-all.sh — drive 5 negative + 2 dogfood fixtures against layer2-audit.sh
# Produces test-results.tsv with columns: fixture\texpected_exit\texpected_stderr_has\tactual_exit\tactual_stderr_has\tverdict
# Cleans up test review dirs it creates (preserves real layer2-audit/ reviews).
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname -- "$0")"/../../../..  # repo root

SCRIPT=.tad/hooks/lib/layer2-audit.sh
RESULTS=.tad/evidence/fixtures/layer2-audit/test-results.tsv
REV_ROOT=.tad/evidence/reviews/blake

# Test slugs (prefixed to avoid collision with real handoffs)
SLUGS=(
  "audittest_empty_dir"
  "audittest_tiny_md"
  "audittest_symlink_small"
  "audittest_dotfile_only"
  "dogfood-pass"
  "dogfood-fail"
)

# Cleanup helper (idempotent)
_cleanup() {
  for s in "${SLUGS[@]}"; do
    rm -rf -- "${REV_ROOT:?}/${s}"
  done
  # Also clean the symlink-target aux file
  rm -f -- "/tmp/.layer2-audit-symlink-target-$$.md"
}
trap _cleanup EXIT

# Fresh start
_cleanup

# ── Set up fixture state ──────────────────────────────────────────────

# (a) audittest_dir_missing — slug points to nonexistent dir (don't create)
# just use the slug; audit script sees missing dir.

# (b) audittest_empty_dir — dir exists, no files
mkdir -p -- "${REV_ROOT}/audittest_empty_dir"

# (c) audittest_tiny_md — dir has .md file but <200 bytes
mkdir -p -- "${REV_ROOT}/audittest_tiny_md"
printf 'tiny review\n' > "${REV_ROOT}/audittest_tiny_md/code-reviewer.md"   # ~12 bytes

# (d) audittest_symlink_small — dir has symlink pointing to small target
mkdir -p -- "${REV_ROOT}/audittest_symlink_small"
aux="/tmp/.layer2-audit-symlink-target-$$.md"
printf 'symlink target small\n' > "$aux"   # ~21 bytes
ln -sf -- "$aux" "${REV_ROOT}/audittest_symlink_small/review.md"

# (e) audittest_dotfile_only — dir has only dotfile .md
mkdir -p -- "${REV_ROOT}/audittest_dotfile_only"
# 300B dotfile that shouldn't count (dotfiles excluded by script)
perl -e 'print "." x 300' > "${REV_ROOT}/audittest_dotfile_only/.hidden.md"

# Dogfood-pass — dir with 1 real-sized review (>200B)
mkdir -p -- "${REV_ROOT}/dogfood-pass"
perl -e 'print "fake reviewer artifact — " x 20' > "${REV_ROOT}/dogfood-pass/code-reviewer.md"

# Dogfood-fail — empty dir → script should FAIL
mkdir -p -- "${REV_ROOT}/dogfood-fail"

# ── Run matrix ──────────────────────────────────────────────────────────
printf 'fixture\texpected_exit\texpected_stderr_has\tactual_exit\tactual_stderr_has\tverdict\n' > "$RESULTS"

_run_case() {
  local label="$1" slug="$2" exp_exit="$3" exp_stderr="$4" exp_stdout="${5:-}"
  local actual_exit actual_stderr actual_stdout verdict
  set +e
  actual_stdout=$(NO_COLOR=1 bash "$SCRIPT" "$slug" 2>/tmp/.l2a-err.$$)
  actual_exit=$?
  actual_stderr=$(cat /tmp/.l2a-err.$$ 2>/dev/null || printf '')
  rm -f /tmp/.l2a-err.$$
  set -e
  local stderr_snippet="(empty)"
  [ -n "$actual_stderr" ] && stderr_snippet=$(printf '%s' "$actual_stderr" | head -c 100 | tr '\n' ' ')

  # Verdict
  verdict="FAIL"
  if [ "$actual_exit" -eq "$exp_exit" ]; then
    if [ -z "$exp_stderr" ]; then
      # Expected empty stderr
      [ -z "$actual_stderr" ] && verdict="PASS"
    else
      if printf '%s' "$actual_stderr" | grep -qF "$exp_stderr"; then
        verdict="PASS"
      fi
    fi
    if [ -n "$exp_stdout" ]; then
      if ! printf '%s' "$actual_stdout" | grep -qF "$exp_stdout"; then
        verdict="FAIL"
      fi
    fi
  fi
  printf '%s\t%d\t%s\t%d\t%s\t%s\n' \
    "$label" "$exp_exit" "${exp_stderr:-EMPTY}" \
    "$actual_exit" "$stderr_snippet" "$verdict" >> "$RESULTS"
  # Echo for log
  printf '[%s] %s  exit=%d  verdict=%s\n' "$verdict" "$label" "$actual_exit" "$verdict"
}

# AC2 smoke/negative (slug validation) — 4 cases
_run_case "slug_empty"          ""                  2 "invalid slug"
_run_case "slug_traversal"      ".."                2 "invalid slug"
_run_case "slug_slash"          "a/b"               2 "invalid slug"
_run_case "slug_leading_dash"   "-rf"               2 "invalid slug"

# AC4 5 FAIL fixtures
_run_case "dir_missing"         "audittest_dir_missing"        1 "directory missing"
_run_case "empty_dir"           "audittest_empty_dir"          1 "no .md files"
_run_case "tiny_md"             "audittest_tiny_md"            1 "under 200B"
_run_case "symlink_small"       "audittest_symlink_small"      1 "symlinked target too small"
_run_case "dotfile_only"        "audittest_dotfile_only"       1 "only dotfiles"

# AC6 dogfood (2 independent)
_run_case "dogfood-pass"        "dogfood-pass"                 0 "" "Layer 2 audit PASS"
_run_case "dogfood-fail"        "dogfood-fail"                 1 "no .md files"

# Summary
total=$(tail -n +2 "$RESULTS" | wc -l | tr -d ' ')
passed=$(tail -n +2 "$RESULTS" | awk -F'\t' '$6=="PASS"' | wc -l | tr -d ' ')
printf '\n──── test summary ────\n%d/%d PASS\n' "$passed" "$total"
if [ "$passed" -eq "$total" ]; then
  printf 'OVERALL: PASS\n'
  exit 0
fi
printf 'OVERALL: FAIL\n'
printf '\nFailing cases:\n'
awk -F'\t' '$6=="FAIL"' "$RESULTS"
exit 1
