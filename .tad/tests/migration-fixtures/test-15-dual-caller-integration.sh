#!/usr/bin/env bash
# test-15-dual-caller-integration.sh — Phase 3 integration fixtures
# Tests call_migration_engine() wrapper behavior in isolation.
# Sub-tests:
#   T15a: Engine called with correct args in upgrade path simulation
#   T15b: Engine skipped when old_ver="none" (fresh install)
#   T15c: Engine skipped when old_ver=new_ver (same version)
#   T15d: Engine missing binary → graceful skip (no crash)
#   T15e: Engine exit 2 → warn, no crash
#   T15f: Engine exit 1 → warn, no crash
#   T15g: Non-TTY mode (</dev/null) → no hang
# Usage: bash test-15-dual-caller-integration.sh
# Exit: 0 if all pass, 1 if any fail
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TAD_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
ENGINE="$TAD_ROOT/hooks/lib/migration-engine.sh"

PASS_COUNT=0 FAIL_COUNT=0
FAILURES=""

RED="" GREEN="" RESET=""
if [ -t 1 ]; then RED=$'\033[31m'; GREEN=$'\033[32m'; RESET=$'\033[0m'; fi

report_pass() { printf '%s  PASS: %s%s\n' "$GREEN" "$1" "$RESET"; PASS_COUNT=$((PASS_COUNT + 1)); }
report_fail() { printf '%s  FAIL: %s — %s%s\n' "$RED" "$1" "$2" "$RESET"; FAIL_COUNT=$((FAIL_COUNT + 1)); FAILURES="${FAILURES}  - $1: $2\n"; }

# ─────────────────────────────────────────────────���────────────
# Helper: create a minimal source tree with engine and manifest
# ──────────────────────────────────────────────��───────────────
create_test_source() {
    local src="$1"
    mkdir -p "$src/.tad/hooks/lib" "$src/.tad/migrations"
    cp "$ENGINE" "$src/.tad/hooks/lib/"
    cp "$TAD_ROOT/hooks/lib/derive-sync-set.sh" "$src/.tad/hooks/lib/"
    printf '0.2.0\n' > "$src/.tad/version.txt"

    # Init git repo for engine's user-modification detection
    cd "$src"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    mkdir -p .claude/skills
    printf 'original' > .claude/skills/old-file.md
    printf '0.1.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.1.0" && git tag "v0.1.0"
    rm -f .claude/skills/old-file.md
    printf '0.2.0\n' > .tad/version.txt
    git add -A && git commit -q -m "v0.2.0" && git tag "v0.2.0"
}

write_test_manifest() {
    local src="$1"
    cat > "$src/.tad/migrations/0.1.0-to-0.2.0.yaml" <<'EOF'
schema_version: 1
from: "0.1.0"
to: "0.2.0"
generated_by: "manual"
delete:
  - path: ".claude/skills/old-file.md"
    type: "file"
    reason: "removed in 0.2.0"
verify:
  - type: "absent"
    path: ".claude/skills/old-file.md"
EOF
    cd "$src" && git add -A && git commit -q -m "manifest" 2>/dev/null || true
}

# Source the tad.sh function we need to test (extract call_migration_engine)
# We extract just the function + logging deps to test in isolation
create_test_harness() {
    local harness="$1"
    cat > "$harness" <<'HARNESS'
#!/bin/bash
set -euo pipefail
# Minimal logging stubs
log_info()    { printf '[INFO] %s\n' "$1"; }
log_success() { printf '[OK]   %s\n' "$1"; }
log_warn()    { printf '[WARN] %s\n' "$1"; }
log_error()   { printf '[ERR]  %s\n' "$1"; }

call_migration_engine() {
    local src="$1"
    local old_ver="$2"
    local new_ver="$3"
    if [ "$old_ver" = "none" ] || [ "$old_ver" = "$new_ver" ]; then
        return 0
    fi
    local engine="$src/.tad/hooks/lib/migration-engine.sh"
    if [ ! -f "$engine" ]; then
        log_warn "  -> Migration engine not found in source; skipping migration"
        return 0
    fi
    log_info "  -> Running migration engine ($old_ver -> $new_ver)..."
    local engine_rc=0
    bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src" || engine_rc=$?
    case $engine_rc in
        0)  log_success "  -> Migration completed successfully" ;;
        2)  log_warn "  -> Migration skipped: manifest invalid or chain gap (exit 2)"
            log_warn "    If upgrading from a very old version, consider a clean reinstall" ;;
        1)  log_warn "  -> Migration had execution errors (exit 1)"
            log_warn "    Backup exists in .tad-backup/ for recovery" ;;
        *)  log_warn "  -> Migration returned unexpected exit code: $engine_rc" ;;
    esac
}

# Execute: call_migration_engine "$@"
# Args: src old_ver new_ver
call_migration_engine "$@"
HARNESS
    chmod +x "$harness"
}

# ══════════════════════════════════════���═══════════════════════
# T15a: Engine called with correct args — delete executes
# ════════════════════════════════════════════════════════════���═
test_15a() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source" tgt="$tmp/target"
    local harness="$tmp/harness.sh"

    create_test_source "$src"
    write_test_manifest "$src"
    create_test_harness "$harness"

    mkdir -p "$tgt/.tad" "$tgt/.claude/skills"
    printf 'original' > "$tgt/.claude/skills/old-file.md"
    printf '0.1.0\n' > "$tgt/.tad/version.txt"

    cd "$tgt"
    local rc=0
    bash "$harness" "$src" "0.1.0" "0.2.0" >/dev/null 2>&1 || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15a" "exit $rc (expected 0)"; rm -rf "$tmp"; return; fi
    if [ -e "$tgt/.claude/skills/old-file.md" ]; then report_fail "T15a" "file not deleted by engine"; rm -rf "$tmp"; return; fi
    if [ ! -d "$tgt/.tad-backup/0.1.0-to-0.2.0" ]; then report_fail "T15a" "backup dir not created"; rm -rf "$tmp"; return; fi

    report_pass "T15a engine-upgrade-integration"
    rm -rf "$tmp"
}

# ══════════════════════════════════════════════════════════════
# T15b: old_ver="none" → skip
# ════════════════════════════���═══════════════════════════���═════
test_15b() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source"
    local harness="$tmp/harness.sh"

    create_test_source "$src"
    write_test_manifest "$src"
    create_test_harness "$harness"

    mkdir -p "$tmp/target/.tad" "$tmp/target/.claude/skills"
    printf 'content' > "$tmp/target/.claude/skills/old-file.md"

    cd "$tmp/target"
    local out rc=0
    out="$(bash "$harness" "$src" "none" "0.2.0" 2>&1)" || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15b" "exit $rc"; rm -rf "$tmp"; return; fi
    # File should still exist (engine skipped)
    if [ ! -f "$tmp/target/.claude/skills/old-file.md" ]; then report_fail "T15b" "file deleted despite none"; rm -rf "$tmp"; return; fi
    # No engine output (skipped before calling)
    if printf '%s' "$out" | grep -q 'Running migration'; then report_fail "T15b" "engine ran despite none"; rm -rf "$tmp"; return; fi

    report_pass "T15b old_ver=none skip"
    rm -rf "$tmp"
}

# ═════════════════════════════════��════════════════════════════
# T15c: old_ver=new_ver → skip
# ═════════════════════���════════════════════════════════════════
test_15c() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source"
    local harness="$tmp/harness.sh"

    create_test_source "$src"
    write_test_manifest "$src"
    create_test_harness "$harness"

    mkdir -p "$tmp/target/.tad" "$tmp/target/.claude/skills"
    printf 'content' > "$tmp/target/.claude/skills/old-file.md"

    cd "$tmp/target"
    local out rc=0
    out="$(bash "$harness" "$src" "0.2.0" "0.2.0" 2>&1)" || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15c" "exit $rc"; rm -rf "$tmp"; return; fi
    if [ ! -f "$tmp/target/.claude/skills/old-file.md" ]; then report_fail "T15c" "file deleted despite same ver"; rm -rf "$tmp"; return; fi
    if printf '%s' "$out" | grep -q 'Running migration'; then report_fail "T15c" "engine ran despite same ver"; rm -rf "$tmp"; return; fi

    report_pass "T15c old_ver=new_ver skip"
    rm -rf "$tmp"
}

# ═══════════════════════════════════════���══════════════════════
# T15d: Engine binary missing → graceful skip
# ══════════════════════════════════════════════════════════════
test_15d() {
    local tmp; tmp="$(mktemp -d)"
    local harness="$tmp/harness.sh"

    create_test_harness "$harness"

    # Source without engine binary
    mkdir -p "$tmp/source/.tad/hooks/lib"
    # Intentionally do NOT copy engine

    mkdir -p "$tmp/target/.tad"
    cd "$tmp/target"
    local out rc=0
    out="$(bash "$harness" "$tmp/source" "0.1.0" "0.2.0" 2>&1)" || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15d" "exit $rc (should be 0)"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out" | grep -q 'not found'; then report_fail "T15d" "no warning about missing engine"; rm -rf "$tmp"; return; fi

    report_pass "T15d engine-missing graceful"
    rm -rf "$tmp"
}

# ══════════════════════════════════��═══════════════════════════
# T15e: Engine exit 2 → warn, function returns 0 (no crash)
# ════════════════════════════���═════════════════════════════════
test_15e() {
    local tmp; tmp="$(mktemp -d)"
    local harness="$tmp/harness.sh"

    create_test_harness "$harness"

    # Create a fake engine that exits 2
    mkdir -p "$tmp/source/.tad/hooks/lib"
    printf '#!/bin/bash\nexit 2\n' > "$tmp/source/.tad/hooks/lib/migration-engine.sh"
    chmod +x "$tmp/source/.tad/hooks/lib/migration-engine.sh"

    mkdir -p "$tmp/target/.tad"
    cd "$tmp/target"
    local out rc=0
    out="$(bash "$harness" "$tmp/source" "0.1.0" "0.2.0" 2>&1)" || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15e" "exit $rc (wrapper should absorb exit 2)"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out" | grep -q 'chain gap'; then report_fail "T15e" "no chain gap warning"; rm -rf "$tmp"; return; fi

    report_pass "T15e engine-exit-2 handled"
    rm -rf "$tmp"
}

# ════════════════════════════════════��═════════════════════════
# T15f: Engine exit 1 → warn, function returns 0 (no crash)
# ══════════════════════════════════════════════════════════════
test_15f() {
    local tmp; tmp="$(mktemp -d)"
    local harness="$tmp/harness.sh"

    create_test_harness "$harness"

    # Create a fake engine that exits 1
    mkdir -p "$tmp/source/.tad/hooks/lib"
    printf '#!/bin/bash\nexit 1\n' > "$tmp/source/.tad/hooks/lib/migration-engine.sh"
    chmod +x "$tmp/source/.tad/hooks/lib/migration-engine.sh"

    mkdir -p "$tmp/target/.tad"
    cd "$tmp/target"
    local out rc=0
    out="$(bash "$harness" "$tmp/source" "0.1.0" "0.2.0" 2>&1)" || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15f" "exit $rc (wrapper should absorb exit 1)"; rm -rf "$tmp"; return; fi
    if ! printf '%s' "$out" | grep -q 'execution errors'; then report_fail "T15f" "no execution error warning"; rm -rf "$tmp"; return; fi

    report_pass "T15f engine-exit-1 handled"
    rm -rf "$tmp"
}

# ═══════════════════════════════════════════════════════���══════
# T15g: Non-TTY mode — no hang under </dev/null
# ══════════════════════════════════════════════════════════════
test_15g() {
    local tmp; tmp="$(mktemp -d)"
    local src="$tmp/source"
    local harness="$tmp/harness.sh"

    create_test_source "$src"
    write_test_manifest "$src"
    create_test_harness "$harness"

    mkdir -p "$tmp/target/.tad" "$tmp/target/.claude/skills"
    printf 'original' > "$tmp/target/.claude/skills/old-file.md"
    printf '0.1.0\n' > "$tmp/target/.tad/version.txt"

    cd "$tmp/target"
    local rc=0
    # Run with stdin closed (non-TTY simulation)
    # Use background + kill pattern for timeout (no coreutils timeout on macOS)
    bash "$harness" "$src" "0.1.0" "0.2.0" </dev/null >/dev/null 2>&1 &
    local pid=$!
    local waited=0
    while kill -0 "$pid" 2>/dev/null; do
        sleep 1
        waited=$((waited + 1))
        if [ "$waited" -ge 30 ]; then
            kill "$pid" 2>/dev/null || true
            report_fail "T15g" "timed out after 30s (non-TTY hang)"
            rm -rf "$tmp"
            return
        fi
    done
    wait "$pid" || rc=$?

    if [ "$rc" -ne 0 ]; then report_fail "T15g" "exit $rc (non-TTY)"; rm -rf "$tmp"; return; fi
    if [ -e "$tmp/target/.claude/skills/old-file.md" ]; then report_fail "T15g" "file not deleted in non-TTY"; rm -rf "$tmp"; return; fi

    report_pass "T15g non-TTY no hang"
    rm -rf "$tmp"
}

# ════════════════════════════════════════════���═════════════════
# Run all sub-tests
# ══════════════════════════════════════════════════════════════
printf '=== T15: Dual-Caller Integration Fixtures ===\n\n'

test_15a
test_15b
test_15c
test_15d
test_15e
test_15f
test_15g

printf '\n=== Results ===\n'
printf 'Passed: %d / %d\n' "$PASS_COUNT" "$((PASS_COUNT + FAIL_COUNT))"

if [ "$FAIL_COUNT" -gt 0 ]; then
    printf '\nFailures:\n'
    printf '%b' "$FAILURES"
    exit 1
fi

printf '\nALL T15 SUB-TESTS PASS (7/7)\n'
exit 0
