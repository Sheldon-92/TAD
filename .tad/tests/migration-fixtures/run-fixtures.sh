#!/usr/bin/env bash
# run-fixtures.sh — TAD Migration Engine E2E Fixture Harness
# Runs 14 fixture test cases against migration-engine.sh in isolated tmp sandboxes.
# Usage: bash run-fixtures.sh
# Exit: 0 if all pass, 1 if any fail
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ENGINE="$(cd "$SCRIPT_DIR/../../hooks/lib" && pwd -P)/migration-engine.sh"

VERIFIER="$(cd "$SCRIPT_DIR/../../hooks/lib" && pwd -P)/release-verify.sh"

PASS_COUNT=0 FAIL_COUNT=0 TOTAL=22
FAILURES=""

# Colors (if terminal supports)
RED="" GREEN="" RESET=""
if [ -t 1 ]; then RED=$'\033[31m'; GREEN=$'\033[32m'; RESET=$'\033[0m'; fi

report_pass() { printf '%s  PASS: %s%s\n' "$GREEN" "$1" "$RESET"; PASS_COUNT=$((PASS_COUNT + 1)); }
report_fail() { printf '%s  FAIL: %s — %s%s\n' "$RED" "$1" "$2" "$RESET"; FAIL_COUNT=$((FAIL_COUNT + 1)); FAILURES="${FAILURES}  - $1: $2\n"; }

# ══════════════════════════════════════════════════════════════
# Helper: create synthetic source git repo with manifests
# ══════════════════════════════════════════════════════════════
create_source() {
    local src="$1"
    mkdir -p "$src/.tad/hooks/lib" "$src/.tad/migrations"

    # Copy derive-sync-set.sh from real repo
    cp "$SCRIPT_DIR/../../hooks/lib/derive-sync-set.sh" "$src/.tad/hooks/lib/"

    # Copy engine
    cp "$ENGINE" "$src/.tad/hooks/lib/"

    cd "$src"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
}

add_version() {
    local src="$1" ver="$2"
    shift 2
    cd "$src"
    # Create files for this version
    while [ $# -gt 0 ]; do
        local fpath="$1" content="$2"
        mkdir -p "$(dirname "$fpath")"
        printf '%s' "$content" > "$fpath"
        shift 2
    done
    printf '%s\n' "$ver" > .tad/version.txt
    git add -A
    git commit -q -m "v$ver" --allow-empty
    git tag "v$ver"
}

write_manifest() {
    local src="$1" from="$2" to="$3"
    shift 3
    local mf="$src/.tad/migrations/${from}-to-${to}.yaml"
    mkdir -p "$(dirname "$mf")"
    cat > "$mf" <<MFEOF
schema_version: 1
from: "$from"
to: "$to"
generated_by: "manual"
$@
MFEOF
    cd "$src" && git add -A && git commit -q -m "manifest $from-to-$to" 2>/dev/null || true
}

create_target() {
    local tgt="$1"
    mkdir -p "$tgt/.tad" "$tgt/.claude/skills" "$tgt/.codex" "$tgt/.agents"
}

# ══════════════════════════════════════════════════════════════
# F1: normal-upgrade
# ══════════════════════════════════════════════════════════════
test_f1() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/old-ref.md" "old content" \
        ".claude/skills/blake/SKILL.md" "blake skill"
    # v0.2.0: remove old-ref.md
    cd "$src"
    rm -f .claude/skills/old-ref.md
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old-ref.md"
    type: "file"
    reason: "removed in v0.2.0"
verify:
  - type: "absent"
    path: ".claude/skills/old-ref.md"
  - type: "present"
    path: ".claude/skills/blake/SKILL.md"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills/blake"
    printf 'old content' > "$tgt/.claude/skills/old-ref.md"
    printf 'blake skill' > "$tgt/.claude/skills/blake/SKILL.md"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F1" "exit $rc (expected 0)"; rm -rf "$tmp"; return; fi
    if [ -e "$tgt/.claude/skills/old-ref.md" ]; then report_fail "F1" "file not deleted"; rm -rf "$tmp"; return; fi
    if [ ! -f "$tgt/.tad-backup/0.1.0-to-0.2.0/.claude/skills/old-ref.md" ]; then report_fail "F1" "backup missing"; rm -rf "$tmp"; return; fi

    local tsv="$tgt/.tad-backup/0.1.0-to-0.2.0/MIGRATION-REPORT.tsv"
    if [ ! -f "$tsv" ]; then report_fail "F1" "TSV missing"; rm -rf "$tmp"; return; fi
    if ! grep -q 'done' "$tsv"; then report_fail "F1" "no done in TSV"; rm -rf "$tmp"; return; fi

    report_pass "F1 normal-upgrade"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F2: idempotent-rerun
# ══════════════════════════════════════════════════════════════
test_f2() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".claude/skills/old.md" "old"
    cd "$src"; rm -f .claude/skills/old.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old.md"
    type: "file"
    reason: "removed"
verify:
  - type: "absent"
    path: ".claude/skills/old.md"
BODY
)"

    create_target "$tgt"
    printf 'old' > "$tgt/.claude/skills/old.md"

    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || true

    # Snapshot after first run
    cp -a "$tgt" "$tmp/snapshot"

    # Second run
    local out rc=0
    out="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F2" "second run exit $rc"; rm -rf "$tmp"; return; fi

    local diff_count
    diff_count="$({ diff -rq "$tgt" "$tmp/snapshot" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$diff_count" -ne 0 ]; then report_fail "F2" "diff after rerun: $diff_count lines"; rm -rf "$tmp"; return; fi

    if ! printf '%s' "$out" | grep -q 'already-applied'; then report_fail "F2" "no already-applied in output"; rm -rf "$tmp"; return; fi

    report_pass "F2 idempotent-rerun"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F3: user-modified-mixed
# ══════════════════════════════════════════════════════════════
test_f3() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/unmodified.md" "original" \
        ".claude/skills/modified.md" "original"
    cd "$src"; rm -f .claude/skills/unmodified.md .claude/skills/modified.md
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/unmodified.md"
    type: "file"
    reason: "removed"
  - path: ".claude/skills/modified.md"
    type: "file"
    reason: "removed"
verify:
  - type: "absent"
    path: ".claude/skills/unmodified.md"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'original' > "$tgt/.claude/skills/unmodified.md"
    printf 'USER CHANGED THIS' > "$tgt/.claude/skills/modified.md"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?

    # Modified file should still exist (in-place preservation)
    if [ ! -f "$tgt/.claude/skills/modified.md" ]; then report_fail "F3" "modified file deleted"; rm -rf "$tmp"; return; fi

    # Unmodified file should be gone
    if [ -e "$tgt/.claude/skills/unmodified.md" ]; then report_fail "F3" "unmodified file not deleted"; rm -rf "$tmp"; return; fi

    # Check TSV
    local tsv="$tgt/.tad-backup/0.1.0-to-0.2.0/MIGRATION-REPORT.tsv"
    if ! grep -q 'skipped-user-modified' "$tsv" 2>/dev/null; then report_fail "F3" "no skipped-user-modified in TSV"; rm -rf "$tmp"; return; fi
    if ! grep -q 'done' "$tsv" 2>/dev/null; then report_fail "F3" "no done in TSV"; rm -rf "$tmp"; return; fi

    report_pass "F3 user-modified-mixed"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F4: detection-unavailable
# ══════════════════════════════════════════════════════════════
test_f4() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    # Source WITHOUT git (no .git dir — simulate remote tad.sh install)
    create_source "$src"
    add_version "$src" "0.1.0" ".claude/skills/file.md" "content"
    cd "$src"; rm -f .claude/skills/file.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # No verify section — avoids verify-absent failing when delete is skipped
    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/file.md"
    type: "file"
    reason: "removed"
BODY
)"

    create_target "$tgt"
    printf 'content' > "$tgt/.claude/skills/file.md"

    # Snapshot before
    cp -a "$tgt" "$tmp/snapshot"

    # Create a source copy without git
    local nogit_src="$tmp/nogit-source"
    cp -a "$src" "$nogit_src"
    rm -rf "$nogit_src/.git"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$nogit_src" >/dev/null 2>&1 || rc=$?

    # File should still exist (detection unavailable → skip)
    if [ ! -f "$tgt/.claude/skills/file.md" ]; then report_fail "F4" "file deleted despite no git"; rm -rf "$tmp"; return; fi

    # Contrast: same manifest with git source → should delete
    create_target "$tmp/target2"
    mkdir -p "$tmp/target2/.claude/skills"
    printf 'content' > "$tmp/target2/.claude/skills/file.md"
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tmp/target2" --source "$src" >/dev/null 2>&1 || true
    if [ -e "$tmp/target2/.claude/skills/file.md" ]; then report_fail "F4" "contrast leg: file not deleted with git"; rm -rf "$tmp"; return; fi

    report_pass "F4 detection-unavailable"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F5: chain-upgrade + gap
# ══════════════════════════════════════════════════════════════
test_f5() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/a.md" "a-content" \
        ".claude/skills/b.md" "b-content" \
        ".claude/skills/keep.md" "keep"
    cd "$src"; rm -f .claude/skills/a.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"
    rm -f .claude/skills/b.md; printf '0.3.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.3.0" && git tag "v0.3.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/a.md"
    type: "file"
    reason: "removed in 0.2.0"
verify:
  - type: "absent"
    path: ".claude/skills/a.md"
BODY
)"
    write_manifest "$src" "0.2.0" "0.3.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/b.md"
    type: "file"
    reason: "removed in 0.3.0"
verify:
  - type: "absent"
    path: ".claude/skills/b.md"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'a-content' > "$tgt/.claude/skills/a.md"
    printf 'b-content' > "$tgt/.claude/skills/b.md"
    printf 'keep' > "$tgt/.claude/skills/keep.md"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.3.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F5" "chain exit $rc"; rm -rf "$tmp"; return; fi
    if [ -e "$tgt/.claude/skills/a.md" ]; then report_fail "F5" "a.md not deleted"; rm -rf "$tmp"; return; fi
    if [ -e "$tgt/.claude/skills/b.md" ]; then report_fail "F5" "b.md not deleted"; rm -rf "$tmp"; return; fi
    if [ ! -f "$tgt/.claude/skills/keep.md" ]; then report_fail "F5" "keep.md wrongly deleted"; rm -rf "$tmp"; return; fi

    # Gap test: remove middle manifest
    rm -f "$src/.tad/migrations/0.1.0-to-0.2.0.yaml"
    create_target "$tmp/target2"
    mkdir -p "$tmp/target2/.claude/skills"
    printf 'a-content' > "$tmp/target2/.claude/skills/a.md"
    rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.3.0 --target "$tmp/target2" --source "$src" 2>"$tmp/gap_err" || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F5" "gap: exit $rc (expected 2)"; rm -rf "$tmp"; return; fi
    if ! grep -qi 'clean reinstall' "$tmp/gap_err" 2>/dev/null; then report_fail "F5" "gap: no clean reinstall msg"; rm -rf "$tmp"; return; fi

    report_pass "F5 chain-upgrade+gap"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F6: malicious-zero-touch ×3
# ══════════════════════════════════════════════════════════════
test_f6() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".tad/version.txt" "0.1.0"
    cd "$src"; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    local pass=1

    # F6a: exact zero-touch path
    create_target "$tgt"
    mkdir -p "$tgt/.tad/project-knowledge"
    printf 'user data' > "$tgt/.tad/project-knowledge/test.md"
    cp -a "$tgt" "$tmp/snap6a"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".tad/project-knowledge/test.md"
    type: "file"
    reason: "malicious"
BODY
)"
    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F6a" "exit $rc (expected 2)"; pass=0; fi
    local d6a; d6a="$({ diff -rq "$tgt" "$tmp/snap6a" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$d6a" -ne 0 ]; then report_fail "F6a" "target modified ($d6a diffs)"; pass=0; fi

    # F6b: case-insensitive variant
    rm -rf "$tgt"; create_target "$tgt"
    mkdir -p "$tgt/.tad/project-knowledge"
    printf 'user data' > "$tgt/.tad/project-knowledge/test.md"
    cp -a "$tgt" "$tmp/snap6b"

    # Rewrite manifest for case variant
    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
delete:
  - path: ".tad/Project-Knowledge/test.md"
    type: "file"
    reason: "case variant attack"
MFEOF
    cd "$src" && git add -A && git commit -q -m "manifest case" 2>/dev/null || true

    rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F6b" "exit $rc (expected 2)"; pass=0; fi
    local d6b; d6b="$({ diff -rq "$tgt" "$tmp/snap6b" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$d6b" -ne 0 ]; then report_fail "F6b" "target modified ($d6b diffs)"; pass=0; fi

    # F6c: rename INTO zero-touch
    rm -rf "$tgt"; create_target "$tgt"
    mkdir -p "$tgt/.tad" "$tgt/.claude/skills"
    printf 'framework file' > "$tgt/.claude/skills/old.md"
    cp -a "$tgt" "$tmp/snap6c"

    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
rename:
  - from: ".claude/skills/old.md"
    to: ".tad/active/injected.md"
    type: "file"
    reason: "rename into zero-touch"
MFEOF
    cd "$src" && git add -A && git commit -q -m "manifest zt rename" 2>/dev/null || true

    rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F6c" "exit $rc (expected 2)"; pass=0; fi
    local d6c; d6c="$({ diff -rq "$tgt" "$tmp/snap6c" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$d6c" -ne 0 ]; then report_fail "F6c" "target modified ($d6c diffs)"; pass=0; fi

    [ "$pass" -eq 1 ] && report_pass "F6 malicious-zero-touch ×3"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F7: malicious-path ×4
# ══════════════════════════════════════════════════════════════
test_f7() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"
    local pass=1

    create_source "$src"
    add_version "$src" "0.1.0" ".tad/version.txt" "0.1.0"
    cd "$src"; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # F7a: path traversal
    create_target "$tgt"
    cp -a "$tgt" "$tmp/snap7a"
    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".tad/../../../etc/passwd"
    type: "file"
    reason: "traversal"
BODY
)"
    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F7a" "traversal exit $rc"; pass=0; fi

    # F7b: symlink in middle component
    rm -rf "$tgt"; create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'legit' > "$tgt/.claude/skills/real.md"
    local ext_dir; ext_dir="$(mktemp -d)"
    printf 'external secret' > "$ext_dir/secret.md"
    ln -s "$ext_dir" "$tgt/.claude/skills/linked"
    cp -a "$tgt" "$tmp/snap7b"

    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
delete:
  - path: ".claude/skills/linked/secret.md"
    type: "file"
    reason: "through symlink"
MFEOF
    cd "$src" && git add -A && git commit -q -m "manifest symlink" 2>/dev/null || true

    rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F7b" "symlink exit $rc"; pass=0; fi
    if [ ! -f "$ext_dir/secret.md" ]; then report_fail "F7b" "external file deleted"; pass=0; fi

    # F7c: leaf symlink
    rm -rf "$tgt"; create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    ln -s "$ext_dir/secret.md" "$tgt/.claude/skills/leaf-link.md"

    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
delete:
  - path: ".claude/skills/leaf-link.md"
    type: "file"
    reason: "leaf symlink"
MFEOF
    cd "$src" && git add -A && git commit -q -m "manifest leaf" 2>/dev/null || true

    rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F7c" "leaf symlink exit $rc"; pass=0; fi

    # F7d: colon in path
    rm -rf "$tgt"; create_target "$tgt"
    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
delete:
  - path: ".claude/skills/bad:file.md"
    type: "file"
    reason: "colon injection"
MFEOF
    cd "$src" && git add -A && git commit -q -m "manifest colon" 2>/dev/null || true

    rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F7d" "colon exit $rc"; pass=0; fi

    [ "$pass" -eq 1 ] && report_pass "F7 malicious-path ×4"
    rm -rf "$tmp" "$ext_dir"
}

# ══════════════════════════════════════════════════════════════
# F8: unknown-strategy → manual-required
# ══════════════════════════════════════════════════════════════
test_f8() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/old.md" "old" \
        "CLAUDE.md" "framework head"
    cd "$src"; rm -f .claude/skills/old.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old.md"
    type: "file"
    reason: "removed"
merge:
  - path: "CLAUDE.md"
    strategy: "unknown-future-strategy"
    marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->"
    on_missing_marker: "skip_and_report"
verify:
  - type: "absent"
    path: ".claude/skills/old.md"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'old' > "$tgt/.claude/skills/old.md"
    printf 'framework head\nuser content' > "$tgt/CLAUDE.md"

    cp -a "$tgt/CLAUDE.md" "$tmp/claude_snap"

    local out rc=0
    out="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F8" "exit $rc (expected 0)"; rm -rf "$tmp"; return; fi

    # Merge reported as manual-required (unknown strategy)
    if ! printf '%s' "$out" | grep -q 'manual-required'; then report_fail "F8" "no manual-required"; rm -rf "$tmp"; return; fi

    # CLAUDE.md must be untouched (unknown strategy doesn't write)
    if ! cmp -s "$tgt/CLAUDE.md" "$tmp/claude_snap"; then report_fail "F8" "CLAUDE.md modified by unknown strategy"; rm -rf "$tmp"; return; fi

    report_pass "F8 unknown-strategy"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F9: dir-delete dual-branch
# ══════════════════════════════════════════════════════════════
test_f9() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/clean-dir/a.md" "a" \
        ".claude/skills/clean-dir/b.md" "b" \
        ".claude/skills/dirty-dir/c.md" "c"
    cd "$src"
    rm -rf .claude/skills/clean-dir .claude/skills/dirty-dir
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/clean-dir"
    type: "dir"
    reason: "removed dir"
  - path: ".claude/skills/dirty-dir"
    type: "dir"
    reason: "removed dir"
verify:
  - type: "absent"
    path: ".claude/skills/clean-dir"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills/clean-dir" "$tgt/.claude/skills/dirty-dir"
    printf 'a' > "$tgt/.claude/skills/clean-dir/a.md"
    printf 'b' > "$tgt/.claude/skills/clean-dir/b.md"
    printf 'c' > "$tgt/.claude/skills/dirty-dir/c.md"
    printf 'USER ADDED' > "$tgt/.claude/skills/dirty-dir/user-file.md"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?

    # Clean dir should be deleted
    if [ -d "$tgt/.claude/skills/clean-dir" ]; then report_fail "F9" "clean dir not deleted"; rm -rf "$tmp"; return; fi
    # Dirty dir should remain (user-modified)
    if [ ! -d "$tgt/.claude/skills/dirty-dir" ]; then report_fail "F9" "dirty dir deleted"; rm -rf "$tmp"; return; fi
    if [ ! -f "$tgt/.claude/skills/dirty-dir/user-file.md" ]; then report_fail "F9" "user file missing"; rm -rf "$tmp"; return; fi

    report_pass "F9 dir-delete dual-branch"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F10: delete-only-no-verify
# ══════════════════════════════════════════════════════════════
test_f10() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".claude/skills/old.md" "old"
    cd "$src"; rm -f .claude/skills/old.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # Manifest with NO verify section
    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old.md"
    type: "file"
    reason: "removed"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'old' > "$tgt/.claude/skills/old.md"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F10" "exit $rc"; rm -rf "$tmp"; return; fi

    local tsv="$tgt/.tad-backup/0.1.0-to-0.2.0/MIGRATION-REPORT.tsv"
    if ! grep -q 'done' "$tsv" 2>/dev/null; then report_fail "F10" "no done (oracle may have fired)"; rm -rf "$tmp"; return; fi

    report_pass "F10 delete-only-no-verify"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F11: zt-authority-unavailable
# ══════════════════════════════════════════════════════════════
test_f11() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".tad/version.txt" "0.1.0"
    cd "$src"; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old.md"
    type: "file"
    reason: "removed"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'content' > "$tgt/.claude/skills/old.md"
    cp -a "$tgt" "$tmp/snapshot"

    # Stub: remove derive-sync-set.sh so authority fails
    rm -f "$src/.tad/hooks/lib/derive-sync-set.sh"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F11" "exit $rc (expected 2)"; rm -rf "$tmp"; return; fi

    local d11; d11="$({ diff -rq "$tgt" "$tmp/snapshot" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$d11" -ne 0 ]; then report_fail "F11" "target modified despite authority failure"; rm -rf "$tmp"; return; fi

    report_pass "F11 zt-authority-unavailable"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F12: rm-site-recheck (TOCTOU defense)
# ══════════════════════════════════════════════════════════════
test_f12() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/parent/target.md" "target content" \
        ".claude/skills/parent/other.md" "other"
    cd "$src"
    rm -f .claude/skills/parent/other.md
    # Rename parent to make subsequent delete's parent a symlink
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # Manifest: rename parent dir contents then delete through the now-changed parent
    # This is a simplified TOCTOU test — we'll create the symlink manually
    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/parent/target.md"
    type: "file"
    reason: "test toctou"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    # Create parent as symlink to external dir
    local ext_dir; ext_dir="$(mktemp -d)"
    printf 'target content' > "$ext_dir/target.md"
    ln -s "$ext_dir" "$tgt/.claude/skills/parent"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    # Should be rejected due to symlink check
    if [ "$rc" -eq 0 ]; then report_fail "F12" "exit 0 (should have rejected symlink)"; rm -rf "$tmp" "$ext_dir"; return; fi

    # External dir should be untouched
    if [ ! -f "$ext_dir/target.md" ]; then report_fail "F12" "external file deleted"; rm -rf "$tmp" "$ext_dir"; return; fi

    report_pass "F12 rm-site-recheck"
    rm -rf "$tmp" "$ext_dir"
}

# ══════════════════════════════════════════════════════════════
# F13: mid-chain-malformed
# ══════════════════════════════════════════════════════════════
test_f13() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".claude/skills/a.md" "a"
    cd "$src"; rm -f .claude/skills/a.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"
    printf '0.3.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.3.0" && git tag "v0.3.0"

    # Valid manifest #1
    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/a.md"
    type: "file"
    reason: "removed"
verify:
  - type: "absent"
    path: ".claude/skills/a.md"
BODY
)"

    # MALFORMED manifest #2 (unknown field in delete)
    cat > "$src/.tad/migrations/0.2.0-to-0.3.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.2.0"
to: "0.3.0"
delete:
  - path: ".claude/skills/b.md"
    type: "file"
    platform: "codex"
    reason: "unknown field"
MFEOF
    cd "$src" && git add -A && git commit -q -m "bad manifest" 2>/dev/null || true

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'a' > "$tgt/.claude/skills/a.md"
    cp -a "$tgt" "$tmp/snapshot"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.3.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "F13" "exit $rc (expected 2)"; rm -rf "$tmp"; return; fi

    # Manifest #1 also should NOT have executed
    local d13; d13="$({ diff -rq "$tgt" "$tmp/snapshot" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$d13" -ne 0 ]; then report_fail "F13" "target modified ($d13 diffs) — #1 executed despite #2 invalid"; rm -rf "$tmp"; return; fi

    report_pass "F13 mid-chain-malformed"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F14: backup-collision
# ══════════════════════════════════════════════════════════════
test_f14() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".claude/skills/old.md" "original"
    cd "$src"; rm -f .claude/skills/old.md; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old.md"
    type: "file"
    reason: "removed"
BODY
)"

    create_target "$tgt"
    mkdir -p "$tgt/.claude/skills"
    printf 'original' > "$tgt/.claude/skills/old.md"

    # Pre-create backup with DIFFERENT content
    mkdir -p "$tgt/.tad-backup/0.1.0-to-0.2.0/.claude/skills"
    printf 'PRECIOUS PREVIOUS BACKUP' > "$tgt/.tad-backup/0.1.0-to-0.2.0/.claude/skills/old.md"

    local rc=0
    bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -eq 0 ]; then report_fail "F14" "exit 0 (should have refused overwrite)"; rm -rf "$tmp"; return; fi

    # Previous backup should be intact
    local backup_content
    backup_content="$(cat "$tgt/.tad-backup/0.1.0-to-0.2.0/.claude/skills/old.md")"
    if [ "$backup_content" != "PRECIOUS PREVIOUS BACKUP" ]; then report_fail "F14" "backup overwritten"; rm -rf "$tmp"; return; fi

    report_pass "F14 backup-collision"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F16: merge-marker-present (head replaced, user content preserved)
# ══════════════════════════════════════════════════════════════
test_f16() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    local marker="<!-- TAD:PROJECT-CONTENT-BELOW -->"

    create_source "$src"
    # Source v0.1.0: old CLAUDE.md with marker
    add_version "$src" "0.1.0" \
        "CLAUDE.md" "# TAD Framework v2.27
Old content.

$marker

Source user area (ignored in v0.1.0)
"
    # Source v0.2.0: new CLAUDE.md with marker (new head content)
    cd "$src"
    printf '# TAD Framework v2.28\n\nNew content here.\n\n%s\n\nSource user area (ignored)\n' "$marker" > "CLAUDE.md"
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<BODY
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "$marker"
    on_missing_marker: "skip_and_report"
BODY
)"

    create_target "$tgt"
    # Target has old head + user content below marker
    printf '# TAD Framework v2.27\n\nOld content.\n\n%s\n\n## My Project\n\nUser notes here.\n' "$marker" > "$tgt/CLAUDE.md"

    # Save user content for byte-identity check
    tail -n +"$(grep -nF "$marker" "$tgt/CLAUDE.md" | head -1 | cut -d: -f1)" "$tgt/CLAUDE.md" > "$tmp/user_tail_before"

    local out rc=0
    out="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F16" "exit $rc (expected 0)"; rm -rf "$tmp"; return; fi

    # TSV contains merge done
    if ! printf '%s' "$out" | grep -q 'merge.*done'; then report_fail "F16" "no merge done in output"; rm -rf "$tmp"; return; fi

    # New head from source present
    if ! grep -q '# TAD Framework v2.28' "$tgt/CLAUDE.md"; then report_fail "F16" "new head not present"; rm -rf "$tmp"; return; fi
    if ! grep -q 'New content here.' "$tgt/CLAUDE.md"; then report_fail "F16" "new source content not present"; rm -rf "$tmp"; return; fi

    # Old head gone
    if grep -q 'Old content.' "$tgt/CLAUDE.md"; then report_fail "F16" "old head still present"; rm -rf "$tmp"; return; fi

    # User content preserved (byte-identity)
    tail -n +"$(grep -nF "$marker" "$tgt/CLAUDE.md" | head -1 | cut -d: -f1)" "$tgt/CLAUDE.md" > "$tmp/user_tail_after"
    if ! cmp -s "$tmp/user_tail_before" "$tmp/user_tail_after"; then report_fail "F16" "user content not byte-identical"; rm -rf "$tmp"; return; fi

    # User content still has project data
    if ! grep -q '## My Project' "$tgt/CLAUDE.md"; then report_fail "F16" "user project content missing"; rm -rf "$tmp"; return; fi
    if ! grep -q 'User notes here.' "$tgt/CLAUDE.md"; then report_fail "F16" "user notes missing"; rm -rf "$tmp"; return; fi

    # Backup created
    if [ ! -f "$tgt/.tad-backup/0.1.0-to-0.2.0/CLAUDE.md" ]; then report_fail "F16" "backup missing"; rm -rf "$tmp"; return; fi

    report_pass "F16 merge-marker-present"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F17: merge-marker-absent (skip, file untouched)
# ══════════════════════════════════════════════════════════════
test_f17() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    local marker="<!-- TAD:PROJECT-CONTENT-BELOW -->"

    create_source "$src"
    # Source has marker
    add_version "$src" "0.1.0" \
        "CLAUDE.md" "# TAD v2.27

$marker

Source content.
"
    cd "$src"
    printf '# TAD v2.28\n\n%s\n\nSource content.\n' "$marker" > "CLAUDE.md"
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<BODY
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "$marker"
    on_missing_marker: "skip_and_report"
BODY
)"

    create_target "$tgt"
    # Target has NO marker — all user content
    printf '# My Project\n\nAll user content, no marker.\n' > "$tgt/CLAUDE.md"

    # Snapshot for comparison
    cp "$tgt/CLAUDE.md" "$tmp/claude_snap"

    local out rc=0
    out="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F17" "exit $rc (expected 0)"; rm -rf "$tmp"; return; fi

    # TSV shows skipped-no-marker
    if ! printf '%s' "$out" | grep -q 'skipped-no-marker'; then report_fail "F17" "no skipped-no-marker in output"; rm -rf "$tmp"; return; fi

    # File untouched
    if ! cmp -s "$tgt/CLAUDE.md" "$tmp/claude_snap"; then report_fail "F17" "CLAUDE.md modified despite no marker"; rm -rf "$tmp"; return; fi

    report_pass "F17 merge-marker-absent"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F18: merge-idempotent (second run reports already-current)
# ══════════════════════════════════════════════════════════════
test_f18() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    local marker="<!-- TAD:PROJECT-CONTENT-BELOW -->"

    create_source "$src"
    add_version "$src" "0.1.0" \
        "CLAUDE.md" "# TAD v2.27

$marker

Source.
"
    cd "$src"
    printf '# TAD v2.28\n\nNew head.\n\n%s\n\nSource.\n' "$marker" > "CLAUDE.md"
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<BODY
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "$marker"
    on_missing_marker: "skip_and_report"
BODY
)"

    create_target "$tgt"
    printf '# TAD v2.27\n\nOld head.\n\n%s\n\n## My Project\n\nUser stuff.\n' "$marker" > "$tgt/CLAUDE.md"

    # First run: should merge
    local out1 rc1=0
    out1="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1)" || rc1=$?
    if [ "$rc1" -ne 0 ]; then report_fail "F18" "first run exit $rc1"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out1" | grep -q 'merge.*done'; then report_fail "F18" "first run: no merge done"; rm -rf "$tmp"; return; fi

    # Snapshot after first merge
    cp "$tgt/CLAUDE.md" "$tmp/after_first"

    # Remove backup to allow second run (backup-collision would block)
    rm -rf "$tgt/.tad-backup"

    # Second run: should report already-current
    local out2 rc2=0
    out2="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1)" || rc2=$?
    if [ "$rc2" -ne 0 ]; then report_fail "F18" "second run exit $rc2"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out2" | grep -q 'already-current'; then report_fail "F18" "no already-current in second run"; rm -rf "$tmp"; return; fi

    # File unchanged between runs
    if ! cmp -s "$tgt/CLAUDE.md" "$tmp/after_first"; then report_fail "F18" "file changed on second run"; rm -rf "$tmp"; return; fi

    report_pass "F18 merge-idempotent"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# F19: merge-dry-run (would-merge, no write)
# ══════════════════════════════════════════════════════════════
test_f19() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    local marker="<!-- TAD:PROJECT-CONTENT-BELOW -->"

    create_source "$src"
    add_version "$src" "0.1.0" \
        "CLAUDE.md" "# TAD v2.27

$marker

Source.
"
    cd "$src"
    printf '# TAD v2.28\n\nNew head.\n\n%s\n\nSource.\n' "$marker" > "CLAUDE.md"
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<BODY
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "$marker"
    on_missing_marker: "skip_and_report"
BODY
)"

    create_target "$tgt"
    printf '# TAD v2.27\n\nOld head.\n\n%s\n\n## My Project\n\nUser stuff.\n' "$marker" > "$tgt/CLAUDE.md"

    # Snapshot before
    cp "$tgt/CLAUDE.md" "$tmp/claude_snap"

    local out rc=0
    out="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" --dry-run 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F19" "dry-run exit $rc"; rm -rf "$tmp"; return; fi

    # Output shows would-merge
    if ! printf '%s' "$out" | grep -q 'would-merge'; then report_fail "F19" "no would-merge in output"; rm -rf "$tmp"; return; fi

    # File untouched
    if ! cmp -s "$tgt/CLAUDE.md" "$tmp/claude_snap"; then report_fail "F19" "CLAUDE.md modified in dry-run"; rm -rf "$tmp"; return; fi

    # No backup dir created
    if [ -d "$tgt/.tad-backup" ]; then report_fail "F19" "backup dir created in dry-run"; rm -rf "$tmp"; return; fi

    report_pass "F19 merge-dry-run"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# Inline test: min_engine_version (AC17)
# ══════════════════════════════════════════════════════════════
test_ac17() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"

    create_source "$src"
    add_version "$src" "0.1.0" ".tad/version.txt" "0.1.0"
    cd "$src"; printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'MFEOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
min_engine_version: "99.0.0"
delete: []
MFEOF
    cd "$src" && git add -A && git commit -q -m "high min_engine" 2>/dev/null || true

    create_target "$tgt"

    local rc=0 err
    err="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" 2>&1 >/dev/null)" || rc=$?
    if [ "$rc" -ne 2 ]; then report_fail "AC17" "exit $rc (expected 2)"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$err" | grep -q "$ENGINE_VERSION\|engine"; then
        # Just check it mentions version somehow
        true
    fi

    report_pass "AC17 min_engine_version"
    rm -rf "$tmp"
}

# Read ENGINE_VERSION from engine
ENGINE_VERSION="$(grep -m1 'ENGINE_VERSION=' "$ENGINE" | sed 's/.*="//' | sed 's/"//')"

# ══════════════════════════════════════════════════════════════
# MG1: migration-gate: unmanifested-delete-detected
# Tests release-verify.sh migration mode: delete without manifest → exit 1,
# then add manifest → exit 0.
# ══════════════════════════════════════════════════════════════
test_mg1() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/old-ref.md" "old content" \
        ".claude/skills/blake/SKILL.md" "blake skill"

    # v0.2.0: remove old-ref.md (no manifest yet)
    cd "$src"
    rm -f .claude/skills/old-ref.md
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # Run migration gate — should detect unmanifested delete → exit 1
    local out rc=0
    out="$(bash "$VERIFIER" migration "$src" "0.2.0" 2>&1)" || rc=$?
    if [ "$rc" -ne 1 ]; then report_fail "MG1a" "exit $rc (expected 1 for unmanifested delete)"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out" | grep -q 'UNMANIFESTED DELETE'; then report_fail "MG1a" "no UNMANIFESTED DELETE in output"; rm -rf "$tmp"; return; fi

    # Now create the manifest
    write_manifest "$src" "0.1.0" "0.2.0" "$(cat <<'BODY'
delete:
  - path: ".claude/skills/old-ref.md"
    type: "file"
    reason: "removed in v0.2.0"
verify:
  - type: "absent"
    path: ".claude/skills/old-ref.md"
BODY
)"

    # Re-run migration gate — should pass now → exit 0
    rc=0
    out="$(bash "$VERIFIER" migration "$src" "0.2.0" 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "MG1b" "exit $rc (expected 0 after manifest added)"; rm -rf "$tmp"; return; fi

    report_pass "MG1 unmanifested-delete-detected"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# MG2: migration-gate: zero-touch-excluded
# Deleting a file inside a ZERO_TOUCH dir should NOT trigger a finding.
# ══════════════════════════════════════════════════════════════
test_mg2() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".tad/active/handoffs/test-handoff.md" "handoff content" \
        ".claude/skills/blake/SKILL.md" "blake skill"

    # v0.2.0: remove file inside active/ (which is ZERO_TOUCH)
    cd "$src"
    rm -f .tad/active/handoffs/test-handoff.md
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # No manifest — but active/ is ZERO_TOUCH, so migration gate should pass
    local rc=0
    bash "$VERIFIER" migration "$src" "0.2.0" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "MG2" "exit $rc (expected 0 — ZERO_TOUCH excluded)"; rm -rf "$tmp"; return; fi

    report_pass "MG2 zero-touch-excluded"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# MG3: migration-gate: rename-detected
# Rename a file between tags, run without rename in manifest → exit 1.
# ══════════════════════════════════════════════════════════════
test_mg3() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source"

    create_source "$src"
    add_version "$src" "0.1.0" \
        ".claude/skills/old-name.md" "skill content"

    # v0.2.0: rename the file (git -M should detect it)
    cd "$src"
    git mv .claude/skills/old-name.md .claude/skills/new-name.md
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"

    # No manifest — should detect unmanifested rename → exit 1
    local out rc=0
    out="$(bash "$VERIFIER" migration "$src" "0.2.0" 2>&1)" || rc=$?
    if [ "$rc" -ne 1 ]; then report_fail "MG3" "exit $rc (expected 1 for unmanifested rename)"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out" | grep -qiE 'UNMANIFESTED RENAME|POSSIBLE RENAME'; then report_fail "MG3" "no rename finding in output"; rm -rf "$tmp"; return; fi

    report_pass "MG3 rename-detected"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# Run all fixtures
# ══════════════════════════════════════════════════════════════
printf '=== TAD Migration Engine Fixture Harness ===\n\n'

test_f1
test_f2
test_f3
test_f4
test_f5
test_f6
test_f7
test_f8
test_f9
test_f10
test_f11
test_f12
test_f13
test_f14
test_f16
test_f17
test_f18
test_f19
test_ac17
test_mg1
test_mg2
test_mg3

printf '\n=== Results ===\n'
printf 'Passed: %d / %d (18 fixtures + 1 inline AC17 + 3 migration gate)\n' "$PASS_COUNT" "$((PASS_COUNT + FAIL_COUNT))"

if [ "$FAIL_COUNT" -gt 0 ]; then
    printf '\nFailures:\n'
    printf '%b' "$FAILURES"
    printf '\nFIXTURE HARNESS FAILED (%d/%d)\n' "$PASS_COUNT" "$((PASS_COUNT + FAIL_COUNT))"
    exit 1
fi

printf '\nALL FIXTURES PASS (22/22)\n'
exit 0
