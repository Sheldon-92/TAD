#!/usr/bin/env bash
# AC-P1.1 — Blake Gate 3 git_tracked_dirs assertion
# Covers: a (tracked dir PASS), b (untracked FAIL), c (field absent SKIP),
#         d (not in git repo), e (empty array SKIP), f (dir missing WARN),
#         g (.gitignore WARN), h (wrong YAML type)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
SCRIPT="${REPO_ROOT}/.tad/hooks/lib/gate3-git-tracked-check.sh"

if [ ! -x "$SCRIPT" ]; then
  echo "FAIL: script missing: $SCRIPT"; exit 1
fi

PASS=0
FAIL=0

# ── Helper: make a handoff fixture with given frontmatter ──
# $1 = fixture name, $2 = frontmatter body (between ---)
_make_handoff() {
  local name="$1" fm_body="$2"
  local path="${FIXTURE_ROOT}/handoffs/${name}.md"
  mkdir -p "$(dirname "$path")"
  {
    printf -- '---\n'
    printf '%s' "$fm_body"
    # ensure trailing newline before closing ---
    case "$fm_body" in
      *$'\n') ;;
      *) printf '\n' ;;
    esac
    printf -- '---\n\n# Test handoff %s\n\nContent.\n' "$name"
  } > "$path"
  printf '%s' "$path"
}

_assert_exit() {
  local name="$1" expected_rc="$2" actual_rc="$3" stderr_file="${4:-}"
  if [ "$expected_rc" = "$actual_rc" ]; then
    printf '[PASS] %s (exit=%s)\n' "$name" "$actual_rc"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (expected exit=%s, got exit=%s)\n' "$name" "$expected_rc" "$actual_rc"
    [ -n "$stderr_file" ] && [ -s "$stderr_file" ] && printf '      stderr: %s\n' "$(cat "$stderr_file")"
    FAIL=$((FAIL + 1))
  fi
}

_assert_stderr_has() {
  local name="$1" needle="$2" stderr_file="$3"
  if grep -q -F "$needle" "$stderr_file" 2>/dev/null; then
    printf '[PASS] %s (stderr contains %s)\n' "$name" "'$needle'"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (stderr missing %s)\n      stderr: %s\n' \
      "$name" "'$needle'" "$(cat "$stderr_file" 2>/dev/null || echo '(empty)')"
    FAIL=$((FAIL + 1))
  fi
}

# ── Build throwaway git fixture root ──
FIXTURE_ROOT=$(mktemp -d -t gate3-git-fixture.XXXXXX)
trap 'rm -rf "$FIXTURE_ROOT"' EXIT

(
  cd "$FIXTURE_ROOT"
  git init -q
  git config user.email test@tad.local
  git config user.name TestBot
  mkdir -p src/pages untracked-dir ignored-dir
  echo 'console.log("tracked");' > src/pages/index.ts
  echo '# ignored' > ignored-dir/note.md
  echo 'ignored-dir/' > .gitignore
  git add .gitignore src/pages/index.ts
  git commit -q -m "init"
  # untracked-dir intentionally not committed
  echo 'hello' > untracked-dir/hello.txt
)

# ── AC-P1.1-a: tracked dir → PASS ──
handoff=$(_make_handoff "a-tracked" 'task_type: code
git_tracked_dirs:
  - src/pages
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-a tracked dir → exit 0" 0 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-a OK message" "has git-tracked files" "$stderr"
rm -f "$stderr"

# ── AC-P1.1-b: declared dir has no tracked files → FAIL ──
handoff=$(_make_handoff "b-untracked" 'task_type: code
git_tracked_dirs:
  - untracked-dir
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-b untracked dir → exit 1" 1 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-b FAIL message mentions untracked-dir" "untracked-dir" "$stderr"
rm -f "$stderr"

# ── AC-P1.1-c: field absent → SKIP (exit 0, no FAIL) ──
handoff=$(_make_handoff "c-no-field" 'task_type: code
e2e_required: no
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-c no field → exit 0 (skip)" 0 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-c skip INFO" "not declared" "$stderr"
rm -f "$stderr"

# ── AC-P1.1-d: not in git repo ──
NONGIT_ROOT=$(mktemp -d -t nongit.XXXXXX)
handoff=$(_make_handoff "d-nongit" 'git_tracked_dirs:
  - src/pages
')
stderr=$(mktemp); (cd "$NONGIT_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-d non-git-repo → exit 1 (clear error, not crash)" 1 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-d clear error message" "not inside a git repo" "$stderr"
rm -rf "$NONGIT_ROOT"
rm -f "$stderr"

# ── AC-P1.1-e: empty array → SKIP with warn ──
handoff=$(_make_handoff "e-empty" 'task_type: code
git_tracked_dirs: []
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-e empty array → exit 0 (skip, not FAIL)" 0 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-e WARN on empty" "empty" "$stderr"
rm -f "$stderr"

# ── AC-P1.1-f: dir not on disk → WARN, not FAIL ──
handoff=$(_make_handoff "f-missing-dir" 'git_tracked_dirs:
  - does-not-exist-on-disk
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-f missing dir → exit 0 (WARN, not FAIL)" 0 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-f WARN message" "not found on disk" "$stderr"
rm -f "$stderr"

# ── AC-P1.1-g: dir covered by .gitignore → WARN, distinguish ──
handoff=$(_make_handoff "g-ignored" 'git_tracked_dirs:
  - ignored-dir
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-g ignored dir → exit 0 (WARN, distinct from untracked)" 0 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-g WARN mentions .gitignore" ".gitignore" "$stderr"
rm -f "$stderr"

# ── AC-P1.1-h: field is a string (wrong type) → clear error ──
handoff=$(_make_handoff "h-wrong-type" 'git_tracked_dirs: "src/pages"
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "AC-P1.1-h wrong YAML type → exit 1 (clear error, no crash)" 1 "$rc" "$stderr"
_assert_stderr_has "AC-P1.1-h error explains expected type" "must be a list" "$stderr"
rm -f "$stderr"

# ── Bonus: multiple dirs, one FAIL + one PASS → FAIL with COMPLETE list (no short-circuit) ──
handoff=$(_make_handoff "bonus-collect" 'git_tracked_dirs:
  - src/pages
  - untracked-dir
')
stderr=$(mktemp); (cd "$FIXTURE_ROOT" && bash "$SCRIPT" "$handoff" 2>"$stderr"); rc=$?
_assert_exit "Bonus mixed dirs → exit 1 (aggregate FAIL)" 1 "$rc" "$stderr"
_assert_stderr_has "Bonus reports untracked in fail list" "untracked-dir" "$stderr"
_assert_stderr_has "Bonus still reports tracked as OK" "src/pages" "$stderr"
rm -f "$stderr"

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
