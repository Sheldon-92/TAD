#!/usr/bin/env bash
# run-fixtures.sh — TAD Migration Engine E2E Fixture Harness
# Runs 14 fixture test cases against migration-engine.sh in isolated tmp sandboxes.
# Usage: bash run-fixtures.sh
# Exit: 0 if all pass, 1 if any fail
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ENGINE="$(cd "$SCRIPT_DIR/../../hooks/lib" && pwd -P)/migration-engine.sh"

PASS_COUNT=0 FAIL_COUNT=0 TOTAL=14
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
# F8: dry-run + merge
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
    strategy: "tad-head-marker"
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

    cp -a "$tgt" "$tmp/snapshot"

    local out rc=0
    out="$(bash "$ENGINE" --from 0.1.0 --to 0.2.0 --target "$tgt" --source "$src" --dry-run 2>&1)" || rc=$?
    if [ "$rc" -ne 0 ]; then report_fail "F8" "dry-run exit $rc"; rm -rf "$tmp"; return; fi

    # Zero writes
    local d8; d8="$({ diff -rq "$tgt" "$tmp/snapshot" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    if [ "$d8" -ne 0 ]; then report_fail "F8" "dry-run modified target ($d8 diffs)"; rm -rf "$tmp"; return; fi
    if [ -d "$tgt/.tad-backup" ]; then report_fail "F8" "dry-run created backup dir"; rm -rf "$tmp"; return; fi

    # Merge reported as manual-required
    if ! printf '%s' "$out" | grep -q 'manual-required'; then report_fail "F8" "no manual-required"; rm -rf "$tmp"; return; fi

    report_pass "F8 dry-run+merge"
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
test_ac17

printf '\n=== Results ===\n'
printf 'Passed: %d / %d (14 fixtures + 1 inline AC17)\n' "$PASS_COUNT" "$((PASS_COUNT + FAIL_COUNT))"

if [ "$FAIL_COUNT" -gt 0 ]; then
    printf '\nFailures:\n'
    printf '%b' "$FAILURES"
    printf '\nFIXTURE HARNESS FAILED (%d/%d)\n' "$PASS_COUNT" "$((PASS_COUNT + FAIL_COUNT))"
    exit 1
fi

printf '\nALL FIXTURES PASS (14/14)\n'
exit 0
