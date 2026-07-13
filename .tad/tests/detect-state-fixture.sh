#!/usr/bin/env bash
# detect-state-fixture.sh — regression fixture for tad.sh detect_state()
#
# Pins the _tad_ver_cmp-based version routing so future edits cannot silently
# reintroduce the order-sensitive glob-arm misclassification hazard:
#   (a) 2.x hazard: 2.19.x misrouted as v1.x/v2.0-era once TARGET_VERSION moved
#       past the glob (original bug class).
#   (b) 1.x prefix-glob hazard: `1.8*)` matches ACROSS minor boundaries
#       (1.80.0 → v1.8), so the case block MUST use dot-bounded arms
#       (`1.8|1.8.*)`). This fixture exercises the cross-major case block
#       directly (installed major < target major) AND asserts the dot-bounded
#       arms are literally present in the extracted detect_state source.
#
# Usage: bash .tad/tests/detect-state-fixture.sh
#        TAD_SH=/path/to/tad.sh bash .tad/tests/detect-state-fixture.sh
# Exit:  0 if all cases pass, 1 if any fail
#
# Design (HANDOFF-surplus-detect-state-glob-arm-hazard §4 + impl-review P0 fix):
# - Extracts _tad_ver_cmp + detect_state from tad.sh via sed (single source of
#   truth; NEVER source tad.sh whole — unguarded main call at EOF runs installer)
# - Derives TARGET_VERSION live from tad.sh so the fixture survives version bumps
# - Runs each case in an isolated mktemp -d sandbox with a controlled version.txt
# - P0 fix (impl review): the original 6-case matrix never REACHED the
#   cross-major glob block (all inputs resolved on the exact/newer/same-major
#   paths first). Added 1.x cross-major cases that hit each glob arm, plus
#   prefix-glob hazard inputs (1.80.0/1.60.2/1.40.0/1.9.0) that discriminate
#   dot-bounded arms from prefix globs, plus a source-level glob-guard grep.

# Bash enforcement guard: zsh does not word-split `local -a A=($1)`, which makes
# _tad_ver_cmp return 0 for everything (9.9.9 would falsely report "old").
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
TAD_SH="${TAD_SH:-$REPO_ROOT/tad.sh}"

if [ ! -f "$TAD_SH" ]; then
    echo "FAIL: tad.sh not found at $TAD_SH" >&2
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# ── Extract functions under test (NOT source tad.sh — unguarded main at EOF) ──
FUNCS="$WORK/funcs.sh"
sed -n '/^_tad_ver_cmp() {/,/^}/p' "$TAD_SH" > "$FUNCS"
sed -n '/^detect_state() {/,/^}/p' "$TAD_SH" >> "$FUNCS"

# ── Extraction-integrity preflight: FAIL loudly, never silently green ──
preflight_fail() { echo "FAIL: extraction preflight — $1" >&2; exit 1; }

grep -q '^_tad_ver_cmp() {' "$FUNCS" || preflight_fail "_tad_ver_cmp not extracted from $TAD_SH (renamed/moved?)"
grep -q '^detect_state() {' "$FUNCS" || preflight_fail "detect_state not extracted from $TAD_SH (renamed/moved?)"
[ "$(grep -c '^}' "$FUNCS" || true)" = "2" ] || preflight_fail "expected exactly 2 column-0 closing braces (got $(grep -c '^}' "$FUNCS" || true))"
[ "$(wc -l < "$FUNCS")" -ge 20 ] || preflight_fail "extraction suspiciously short ($(wc -l < "$FUNCS") lines)"
bash -n "$FUNCS" || preflight_fail "extracted functions fail bash -n syntax check"

# ── Derive TARGET_VERSION live from tad.sh (no drifting copy) ──
TARGET_LINE="$(grep -m1 '^TARGET_VERSION=' "$TAD_SH" || true)"
[ -n "$TARGET_LINE" ] || preflight_fail "TARGET_VERSION= not found in $TAD_SH"
eval "$TARGET_LINE"
tmaj="${TARGET_VERSION%%.*}"

# shellcheck disable=SC1090
. "$FUNCS"
type _tad_ver_cmp >/dev/null 2>&1 || preflight_fail "_tad_ver_cmp not defined after sourcing extraction"
type detect_state >/dev/null 2>&1 || preflight_fail "detect_state not defined after sourcing extraction"

# ── Reporting (house style: migration-fixtures/run-fixtures.sh) ──
PASS_COUNT=0 FAIL_COUNT=0
RED="" GREEN="" RESET=""
if [ -t 1 ]; then RED=$'\033[31m'; GREEN=$'\033[32m'; RESET=$'\033[0m'; fi
report_pass() { printf '%s  PASS: %s%s\n' "$GREEN" "$1" "$RESET"; PASS_COUNT=$((PASS_COUNT + 1)); }
report_fail() { printf '%s  FAIL: %s — %s%s\n' "$RED" "$1" "$2" "$RESET"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

# ── Glob-block integrity guard (impl-review P0/AC1 hardening) ──
# The cross-major case block MUST use dot-bounded arms. If a future edit
# reverts any arm to a prefix glob (e.g. `1.8*)`), the fixed-string grep below
# drops to 0 and the fixture FAILS loudly — a reported failure, not an early
# exit, so the behavioral hazard cases below also get a chance to fire.
glob_guard() {
    local arm="$1"
    local count
    # P2 fix (review round 2): strip comments before grepping — tad.sh's GLOB
    # SAFETY comment quotes the arm literal, so an unstripped grep would be
    # comment-satisfied even after the CODE arm reverts to a prefix glob.
    count="$(sed 's/#.*//' "$FUNCS" | grep -cF "$arm" || true)"
    if [ "$count" -ge 1 ]; then
        report_pass "glob-guard: dot-bounded arm '$arm' present in detect_state"
    else
        report_fail "glob-guard: '$arm'" "dot-bounded arm missing from extracted detect_state (reverted to prefix glob like '1.8*)'?)"
    fi
}

# ── Case runner ──
# run_case "<version-string|FRESH|PARTIAL>" "<expected-state>"
# FRESH   sentinel: sandbox with neither .tad nor .claude/commands
# PARTIAL sentinel: sandbox with .claude/commands but no .tad
# FR4: every 2.x version input additionally asserts the output is NOT any of
# the original misclassification class v1.8/v1.6/v1.4 (hazard-check).
run_case() {
    local ver="$1" expected="$2"
    local sandbox actual
    sandbox="$(mktemp -d "$WORK/case.XXXXXX")"
    case "$ver" in
        FRESH)   : ;;  # empty dir baseline
        PARTIAL) mkdir -p "$sandbox/.claude/commands" ;;
        *)
            mkdir -p "$sandbox/.tad"
            printf '%s\n' "$ver" > "$sandbox/.tad/version.txt"
            ;;
    esac
    actual="$(cd "$sandbox" && detect_state)"
    if [ "$actual" = "$expected" ]; then
        report_pass "$ver -> $actual"
    else
        report_fail "$ver -> $actual" "expected '$expected'"
    fi
    # FR4 hazard-class negative assertion for every 2.x input
    case "$ver" in
        2.*)
            case "$actual" in
                v1.8|v1.6|v1.4)
                    report_fail "$ver hazard-check" "2.x input fell into v1.x label '$actual' (glob-arm misclassification class)" ;;
                *)
                    report_pass "$ver hazard-check: not v1.8/v1.6/v1.4" ;;
            esac
            ;;
    esac
}

echo "detect-state-fixture: TAD_SH=$TAD_SH TARGET_VERSION=$TARGET_VERSION"

# ── Source-level glob-arm guard ──
glob_guard '1.8|1.8.*)'
glob_guard '1.6|1.6.*|1.5|1.5.*)'
glob_guard '1.4|1.4.*)'

# ── Case matrix (FR3) ──
# Evergreen (FR6): the two hardcoded 2.x-older cases expect "upgrade" while
# target major == 2; after a future 3.x bump they become cross-major → "old".
if [ "$tmaj" = "2" ]; then hazard_expected="upgrade"; else hazard_expected="old"; fi

run_case "2.19.1" "$hazard_expected"          # original hazard input (was misrouted by 2.1* glob)
run_case "2.20.0" "$hazard_expected"          # original hazard input (was misrouted by 2.2* glob)
run_case "$TARGET_VERSION" "current"          # exact match, version-relative (survives bumps)
run_case "9.9.9" "current"                    # newer than target → never downgrade
run_case "abc" "old"                          # unparseable → fail-safe migrate path (undecidable input)
run_case "FRESH" "fresh"                      # empty-dir baseline
run_case "PARTIAL" "partial"                  # .claude/commands without .tad (allowed 7th case, §10.2)

# ── Cross-major glob-arm cases (impl-review P0 fix) ──
# All 1.x inputs have installed major (1) < target major (≥2 forever), so they
# ALWAYS reach the cross-major case block — evergreen across future bumps.
run_case "1.8.5"  "v1.8"                      # 1.8.* arm, patch level
run_case "1.8"    "v1.8"                      # bare 1.8 arm (dot-bounded exact)
run_case "1.80.0" "old"                       # HAZARD: prefix glob 1.8* would say v1.8
run_case "1.9.0"  "old"                       # unrouted 1.x minor → fall-through arm
run_case "1.6"    "v1.6"                      # bare 1.6 arm
run_case "1.60.2" "old"                       # HAZARD: prefix glob 1.6* would say v1.6
run_case "1.5.3"  "v1.6"                      # 1.5.* routed to v1.6 migration path
run_case "1.4.1"  "v1.4"                      # 1.4.* arm
run_case "1.40.0" "old"                       # HAZARD: prefix glob 1.4* would say v1.4

# ── Summary ──
echo ""
echo "Summary: $PASS_COUNT passed, $FAIL_COUNT failed"
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
