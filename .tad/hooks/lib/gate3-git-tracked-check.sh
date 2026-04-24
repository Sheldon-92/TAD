#!/usr/bin/env bash
# gate3-git-tracked-check.sh — Phase 1 P1.1 (2026-04-24)
# Smoke-alarm assertion: production dirs declared in handoff frontmatter must
# have ≥1 git-tracked file at Gate 3 time.
#
# Precedent: toy 2026-04-22 — 38 production files accumulated for weeks
# untracked; Blake's Gate 3 didn't catch it because git tracking was never
# a Gate 3 item.
#
# Usage:   bash .tad/hooks/lib/gate3-git-tracked-check.sh <handoff-path>
# Exit:    0 PASS or skip | 1 FAIL | 2 usage / invalid frontmatter
# Output:  human-readable messages on stderr; one summary line on stdout.
#
# Design contracts:
#   (a) Opt-in: absent / null / [] → skip, not FAIL.
#   (b) Fail-collect: iterate all dirs, report all failures together.
#   (c) Warn-not-fail on recoverable edges (dir not on disk, .gitignore).
#   (d) Clear error on type mismatches; never crash.
#   (e) Pure read-only.
#
# Macros-free; BSD-portable: grep -E, no grep -P, no gdate, no awk gensub.

set -uo pipefail

# ── ANSI selection (NO_COLOR honored) ───────────────────────────────────
_red=""; _yellow=""; _green=""; _reset=""
if [ -z "${NO_COLOR:-}" ] && [ -t 2 ]; then
  _red=$'\033[31m'; _yellow=$'\033[33m'; _green=$'\033[32m'; _reset=$'\033[0m'
fi

_info() { printf '[INFO] %s\n' "$*" >&2; }
_warn() { printf '%s[WARN]%s %s\n' "$_yellow" "$_reset" "$*" >&2; }
_err()  { printf '%s[FAIL]%s %s\n' "$_red"    "$_reset" "$*" >&2; }
_ok()   { printf '%s[ OK ]%s %s\n' "$_green"  "$_reset" "$*" >&2; }

# ── Arg parse ───────────────────────────────────────────────────────────
if [ $# -ne 1 ]; then
  printf 'usage: %s <handoff-path>\n' "$(basename -- "$0")" >&2
  exit 2
fi
HANDOFF="$1"

if [ ! -r "$HANDOFF" ]; then
  _err "handoff file not readable: $HANDOFF"
  exit 2
fi

# ── Extract frontmatter (top of file between two '---' lines) ───────────
# BSD-portable awk; no gawk-isms.
FM=$(awk '
  BEGIN { in_fm = 0; started = 0 }
  NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; started = 1; next }
  started && /^---[[:space:]]*$/ { in_fm = 0; exit }
  in_fm { print }
' "$HANDOFF")

if [ -z "$FM" ]; then
  # No frontmatter at all → treat as pre-Phase-1 handoff, skip check
  _info "no YAML frontmatter detected — skip git_tracked_dirs check (backward compat)"
  printf 'SKIP (no frontmatter)\n'
  exit 0
fi

# ── Dependency check: need yq for YAML parsing ──────────────────────────
if ! command -v yq >/dev/null 2>&1; then
  _err "yq not installed — cannot parse frontmatter (install via: brew install yq)"
  exit 2
fi

# ── Parse git_tracked_dirs field via yq ─────────────────────────────────
# Use `.git_tracked_dirs | type` to classify the field into one of:
# !!null (absent/null) / !!seq (list) / !!str / !!int / !!bool / !!map
FIELD_TYPE=$(printf '%s\n' "$FM" | yq '.git_tracked_dirs | type' 2>/dev/null || echo '!!null')

# Classify the field into: absent, empty_list, list, wrong_type
case "$FIELD_TYPE" in
  '!!null')
    # Field absent or explicitly null → skip
    _info "git_tracked_dirs not declared — skip (backward compat)"
    printf 'SKIP (field absent)\n'
    exit 0
    ;;
  '!!seq')
    # It's a list — check emptiness
    LEN=$(printf '%s\n' "$FM" | yq '.git_tracked_dirs | length' 2>/dev/null || echo 0)
    if [ "$LEN" -eq 0 ]; then
      _warn "git_tracked_dirs is empty [] — skip (no dirs to verify)"
      printf 'SKIP (empty list)\n'
      exit 0
    fi
    ;;
  *)
    # Wrong type (!!str, !!int, !!bool, !!map, etc.)
    _err "git_tracked_dirs must be a list (got type: $FIELD_TYPE). Ask Alex to fix handoff frontmatter."
    printf 'FAIL (invalid type: %s)\n' "$FIELD_TYPE"
    exit 1
    ;;
esac

# ── Verify we're in a git repo ──────────────────────────────────────────
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  _err "not inside a git repo — git_tracked_dirs check cannot run"
  printf 'FAIL (not a git repo)\n'
  exit 1
fi

# ── Iterate dirs, collect outcomes (NO short-circuit) ───────────────────
# yq emits one dir per line (stripping quotes)
DIRS=$(printf '%s\n' "$FM" | yq '.git_tracked_dirs[]' 2>/dev/null)

declare -a FAIL_DIRS=()
declare -a WARN_NOT_FOUND=()
declare -a WARN_IGNORED=()
declare -a OK_DIRS=()

while IFS= read -r dir; do
  [ -z "$dir" ] && continue

  # Edge (a): dir does not exist on disk
  if [ ! -e "$dir" ]; then
    WARN_NOT_FOUND+=("$dir")
    _warn "dir '$dir' not found on disk; skipping (non-blocking)"
    continue
  fi

  # Edge (b): dir covered by .gitignore
  # check-ignore exits 0 = IS ignored, 1 = NOT ignored, 128 = error
  if git check-ignore -q -- "$dir" 2>/dev/null; then
    WARN_IGNORED+=("$dir")
    _warn "dir '$dir' is covered by .gitignore; skipping (legitimate ignore, not untracked)"
    continue
  fi

  # Real check: does dir have ANY git-tracked file?
  # ls-files exits 0 regardless; we check output is non-empty.
  if git ls-files -- "$dir" 2>/dev/null | grep -q .; then
    OK_DIRS+=("$dir")
    _ok "dir '$dir' has git-tracked files"
  else
    FAIL_DIRS+=("$dir")
    # Do NOT emit FAIL here — collect, report at end
  fi
done <<< "$DIRS"

# ── Verdict ─────────────────────────────────────────────────────────────
n_ok=${#OK_DIRS[@]}
n_warn=$((${#WARN_NOT_FOUND[@]} + ${#WARN_IGNORED[@]}))
n_fail=${#FAIL_DIRS[@]}

if [ "$n_fail" -eq 0 ]; then
  printf 'PASS: %d dirs verified (%d warned, %d tracked)\n' \
    "$((n_ok + n_warn))" "$n_warn" "$n_ok"
  exit 0
fi

# FAIL — report ALL failing dirs together
_err "git_tracked_dirs check FAIL: the following declared dirs have no git-tracked files:"
for d in "${FAIL_DIRS[@]}"; do
  _err "  - $d"
done
_err "Run 'git add <dir>' for each, then re-run Gate 3."
printf 'FAIL: %d of %d dirs untracked\n' "$n_fail" "$((n_ok + n_warn + n_fail))"
exit 1
