#!/usr/bin/env bash
# detect-state-test.sh — isolated-tempdir fixture harness for tad.sh detect_state()
# routing. Covers HANDOFF-20260614-fix-detect-state-semver §9.1 AC rows.
#
# CRITICAL: each AC row runs in its OWN `mktemp -d` dir with a fixture
# `.tad/version.txt` and a pinned TARGET_VERSION — it never reads the repo's
# real version.txt. The routing logic (_tad_ver_cmp + detect_state + the
# STATE->ACTION case mapping) is EXTRACTED from tad.sh, not reimplemented.
set -u

# --- locate tad.sh (repo root = two dirs up from .tad/hooks/lib/) ------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAD_SH="$SCRIPT_DIR/../../../tad.sh"
if [ ! -f "$TAD_SH" ]; then
    echo "FATAL: cannot find tad.sh at $TAD_SH" >&2
    exit 1
fi

# --- extract routing logic from tad.sh into a sourceable shim ---------------
SHIM="$(mktemp)"
trap 'rm -f "$SHIM"' EXIT

# 1. _tad_ver_cmp() : from its definition line to the closing brace.
sed -n '/^_tad_ver_cmp() {/,/^}/p' "$TAD_SH" >> "$SHIM"
echo "" >> "$SHIM"

# 2. detect_state() : from its definition line to the closing brace.
sed -n '/^detect_state() {/,/^}/p' "$TAD_SH" >> "$SHIM"
echo "" >> "$SHIM"

# 3. STATE->ACTION mapping: wrap tad.sh's `case $STATE in ... esac` block in a
#    function. Extract the block verbatim (the 4-space-indented case..esac in
#    main()), then expose it as derive_action() operating on $STATE -> $ACTION.
{
    echo "derive_action() {"
    echo "    local STATE=\"\$1\""
    echo "    local ACTION=\"\""
    echo "    # color/echo vars are undefined in the harness; define them empty so"
    echo "    # the case arms' echo lines don't abort under set -u. Their output is"
    echo "    # discarded — only the ACTION= assignments are load-bearing."
    echo "    local GREEN=\"\" YELLOW=\"\" BLUE=\"\" CYAN=\"\" NC=\"\" CURRENT_VERSION=\"\" TARGET_VERSION=\"\${TARGET_VERSION:-}\" TARGET_SKILL_DIR=\"\""
    echo "    {"
    sed -n '/^    case \$STATE in/,/^    esac/p' "$TAD_SH"
    echo "    } >/dev/null 2>&1"
    echo "    echo \"\$ACTION\""
    echo "}"
} >> "$SHIM"

# sanity: the shim must define all three.
for fn in _tad_ver_cmp detect_state derive_action; do
    grep -q "^${fn}\(\)\? *(\?" "$SHIM" || { echo "FATAL: shim missing $fn (extraction failed)" >&2; exit 1; }
done

# --- AC table: AC|TARGET_VERSION|version.txt-bytes|expect_state|expect_action
# version.txt content uses printf-style escapes (so AC13 can embed \r\n).
# A literal sentinel __EMPTY__ means "write an empty file".
run_case() {
    local label="$1" target="$2" vbytes="$3" exp_state="$4" exp_action="$5"
    local dir; dir="$(mktemp -d)"
    mkdir -p "$dir/.tad"
    if [ "$vbytes" = "__EMPTY__" ]; then
        : > "$dir/.tad/version.txt"
    else
        printf '%b' "$vbytes" > "$dir/.tad/version.txt"
    fi

    # Run in a clean subshell, cd'd into the isolated fixture dir, with the
    # routing logic sourced and TARGET_VERSION pinned for this row only.
    local out got_state got_action
    out="$(
        cd "$dir" || exit 99
        # shellcheck disable=SC1090
        source "$SHIM"
        TARGET_VERSION="$target"
        st="$(detect_state)"
        ac="$(derive_action "$st")"
        printf '%s|%s\n' "$st" "$ac"
    )"
    got_state="${out%%|*}"
    got_action="${out#*|}"
    # normalize empty action to "none" for the no-op rows (ACTION stays "" only
    # if a state had no arm; current's arm sets ACTION=none explicitly).
    [ -z "$got_action" ] && got_action="none"

    rm -rf "$dir"

    if [ "$got_state" = "$exp_state" ] && [ "$got_action" = "$exp_action" ]; then
        printf 'PASS %-5s target=%-7s ver=%-12s -> state=%-8s action=%s\n' \
            "$label" "$target" "$(printf '%q' "$vbytes")" "$got_state" "$got_action"
        return 0
    else
        printf 'FAIL %-5s target=%-7s ver=%-12s -> state=%-8s action=%-8s (expected state=%s action=%s)\n' \
            "$label" "$target" "$(printf '%q' "$vbytes")" "$got_state" "$got_action" "$exp_state" "$exp_action"
        return 1
    fi
}

PASS=0; FAIL=0
check() {
    if run_case "$@"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
}

# AC | TARGET | version.txt | expect_state | expect_action
check AC1  2.29.1 "2.29.1"   current  none
check AC2  2.29.1 "2.29.0"   upgrade  upgrade
check AC3  2.29.1 "2.20.0"   upgrade  upgrade
check AC4  2.29.1 "2.0.0"    upgrade  upgrade
check AC5  2.29.1 "1.8.0"    v1.8     upgrade
check AC6  2.29.1 "1.4.0"    v1.4     migrate
check AC7  3.0.0  "2.29.1"   old      migrate
check AC8  2.29.1 "__EMPTY__" old     migrate
check AC9  2.29.1 "garbage"  old      migrate
check AC10 2.29.1 "2.30.0"   current  none
check AC11 2.29.1 "2.9.0"    upgrade  upgrade
check AC13 2.29.1 "2.29.1\r\n" current none

echo ""
echo "TALLY: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
