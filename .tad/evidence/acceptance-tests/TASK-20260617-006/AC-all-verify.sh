#!/bin/bash
# Acceptance verification for TASK-20260617-006 (Pack Content Protection P1)
set -euo pipefail

SRC="/Users/sheldonzhao/01-on progress programs/TAD"
PASS=0
FAIL=0

report() {
    local ac="$1" status="$2" msg="$3"
    if [ "$status" = "PASS" ]; then
        PASS=$((PASS + 1))
        echo "✅ $ac: $msg"
    else
        FAIL=$((FAIL + 1))
        echo "❌ $ac: $msg"
    fi
}

# Setup: create clean test directory
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
mkdir -p .claude .tad

# Run tad.sh install
bash "$SRC/tad.sh" --yes >/dev/null 2>&1

# AC1: pack meta exists
if [ -f ".claude/skills/web-testing/.tad-pack-meta.yaml" ]; then
    report "AC1" "PASS" "pack meta exists"
else
    report "AC1" "FAIL" "pack meta missing"
fi

# AC2: sha256 matches
actual=$(shasum -a 256 ".claude/skills/web-testing/SKILL.md" | cut -d' ' -f1)
meta=$(grep -A1 'path: "SKILL.md"' ".claude/skills/web-testing/.tad-pack-meta.yaml" | grep sha256 | sed 's/.*sha256: "//;s/"//')
if [ "$actual" = "$meta" ]; then
    report "AC2" "PASS" "sha256 match"
else
    report "AC2" "FAIL" "sha256 mismatch: actual=$actual meta=$meta"
fi

# AC3: non-pack skill no meta
if [ ! -f ".claude/skills/alex/.tad-pack-meta.yaml" ] && [ ! -f ".claude/skills/blake/.tad-pack-meta.yaml" ]; then
    report "AC3" "PASS" "non-pack skills have no meta"
else
    report "AC3" "FAIL" "non-pack skills have meta"
fi

# AC4: sync-protocol.md no install.sh execution refs
count=$(grep -c 'install\.sh --force\|cd.*&&.*install\.sh\|b2.*install\.sh' "$SRC/.claude/skills/alex/references/sync-protocol.md" 2>/dev/null) || count=0
positive=$(grep -c 'mirror is authoritative\|no longer invoked\|cp -R.*merge' "$SRC/.claude/skills/alex/references/sync-protocol.md" 2>/dev/null) || positive=0
if [ "$count" -eq 0 ] && [ "$positive" -gt 0 ]; then
    report "AC4" "PASS" "old refs removed, new descriptions present"
else
    report "AC4" "FAIL" "old_refs=$count positive=$positive"
fi

# AC5: local/ excluded
mkdir -p ".claude/skills/web-testing/local"
echo "test" > ".claude/skills/web-testing/local/test.md"
bash "$SRC/tad.sh" --yes --force >/dev/null 2>&1
if grep -q 'local/' ".claude/skills/web-testing/.tad-pack-meta.yaml" 2>/dev/null; then
    report "AC5" "FAIL" "local/ found in meta"
else
    report "AC5" "PASS" "local/ excluded from meta"
fi

# AC6: sync_policy preserved
sed -i '' 's/sync_policy: upstream/sync_policy: forked/' ".claude/skills/web-testing/.tad-pack-meta.yaml"
bash "$SRC/tad.sh" --yes --force >/dev/null 2>&1
if grep -q 'sync_policy: forked' ".claude/skills/web-testing/.tad-pack-meta.yaml"; then
    report "AC6" "PASS" "sync_policy preserved"
else
    report "AC6" "FAIL" "sync_policy not preserved"
fi

# AC7: change scope
changed=$(cd "$SRC" && git diff --name-only -- tad.sh .tad/templates/capability-pack-template/install.sh .claude/skills/alex/references/sync-protocol.md .tad/hooks/lib/release-verify.sh | wc -l | tr -d ' ')
if [ "$changed" -eq 4 ]; then
    report "AC7" "PASS" "4 modified files match §6"
else
    report "AC7" "FAIL" "expected 4 modified, got $changed"
fi

# AC8: migration baseline
TMPDIR2=$(mktemp -d)
cd "$TMPDIR2"
mkdir -p .claude .tad
bash "$SRC/tad.sh" --yes >/dev/null 2>&1
if grep -q 'baseline_source: migrated' ".claude/skills/web-testing/.tad-pack-meta.yaml"; then
    report "AC8" "PASS" "baseline_source: migrated for first-time"
else
    report "AC8" "FAIL" "wrong baseline_source"
fi
rm -rf "$TMPDIR2"

# AC9: release-verify.sh no meta noise
cd "$TMPDIR"
out=$(bash "$SRC/.tad/hooks/lib/release-verify.sh" structural "$SRC" "$TMPDIR" 2>&1 || true)
if echo "$out" | grep -q '\.tad-pack-meta\.yaml'; then
    report "AC9" "FAIL" ".tad-pack-meta.yaml in output"
else
    report "AC9" "PASS" "no .tad-pack-meta.yaml noise"
fi

# Cleanup
rm -rf "$TMPDIR"

echo ""
echo "=== Results: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
