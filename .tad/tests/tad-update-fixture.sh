#!/usr/bin/env bash
# tad-update-fixture.sh — deterministic regression fixture suite for
# TAD v2.43.1: macOS dangling-symlink backup repair + the shared updater helper
# + updater-only OpenCode projection (HANDOFF-20260902-tad-update-v2431).
#
# Usage: bash .tad/tests/tad-update-fixture.sh --case <name> [options]
#   --case backup                 AC2  symlink-preserving backups + unique destinations
#   --case states                 AC3  update state matrix + platform matrix
#   --case consent                AC4  explicit-confirmation boundary
#   --case download-safety        AC5  fail-closed download/extraction/binding
#   --case opencode-preservation  AC8  exact-file projection + preservation + rollback
#   --case full-upgrade           AC9  real old-version upgrade + existing suites
#   --case release-gates          AC10 release preflight order
#   --case remote-release         AC14 publication verification (post-Gate-4)
#
# Deterministic by construction: NO real network. A temporary mock curl in PATH
# intercepts the fixed official URLs and serves fixture payloads built from a
# tar of THIS repo tree (zero-touch dirs excluded). Exit: 0 = all pass.
#
# Bash enforcement guard: zsh does not word-split and would break the harness.
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
TAD_SH="$REPO_ROOT/tad.sh"
UPDATER="$REPO_ROOT/.tad/scripts/tad-update.sh"
UPGRADE_ACCEPTANCE="$REPO_ROOT/.tad/tests/upgrade-acceptance.sh"
DETECT_STATE_FIXTURE="$REPO_ROOT/.tad/tests/detect-state-fixture.sh"
MIGRATION_RUNNER="$REPO_ROOT/.tad/tests/migration-fixtures/run-fixtures.sh"

FIXTURE_VERSION="$(head -1 "$REPO_ROOT/.tad/version.txt" | tr -d '[:space:]')"
# Gate-4 finding 2026-09-03: version gate fails toward false-positive by design,
# so derive OLD_VERSION from .tad/migrations/*-to-<current>.yaml to avoid a second literal source of truth.
_derive_old_version() {
    local _match_count=0
    local _match_file=""
    local _f
    for _f in "$REPO_ROOT"/.tad/migrations/*-to-"$FIXTURE_VERSION".yaml; do
        [ -e "$_f" ] || continue
        _match_count=$((_match_count + 1))
        _match_file="$_f"
    done
    if [ "$_match_count" -ne 1 ]; then
        echo "tad-update-fixture: expected exactly one migration *-to-$FIXTURE_VERSION.yaml (found $_match_count)" >&2
        exit 2
    fi
    basename "$_match_file" | cut -d- -f1
}
OLD_VERSION="${OLD_VERSION:-$(_derive_old_version)}"
[ -n "${OLD_VERSION:-}" ] || { echo "tad-update-fixture: could not derive OLD_VERSION from .tad/migrations/*-to-$FIXTURE_VERSION.yaml" >&2; exit 2; }

CASE="" EXPECTED_COMMIT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --case) CASE="$2"; shift 2 ;;
        --expected-version) FIXTURE_VERSION="$2"; shift 2 ;;
        --expected-commit) EXPECTED_COMMIT="$2"; shift 2 ;;
        --old-version) OLD_VERSION="$2"; shift 2 ;;
        --help|-h)
            sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "tad-update-fixture: unknown option '$1'" >&2; exit 2 ;;
    esac
done

if [ -z "$CASE" ]; then
    echo "tad-update-fixture: --case is required" >&2
    exit 2
fi

PASS=0 FAIL=0
ok()   { PASS=$((PASS + 1)); echo "  PASS: $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

# ══════════════════════════════════════════════════════════════════
# Fixture source tarball — a tar of THIS repo tree with zero-touch
# dirs and ephemeral trees excluded. Top-level dir named after the
# repo basename, then re-rooted to TAD-main so tad.sh finds it.
# ══════════════════════════════════════════════════════════════════
make_src_tarball() {
    local out="$1"
    # Build dir lives under SANDBOX so the global EXIT trap cleans it. NO
    # RETURN trap here: bash RETURN traps are global, not function-scoped —
    # one would also fire when the CALLER returns, with this function's
    # locals already destroyed (set -u → unbound variable).
    local tmp="$SANDBOX/srcbuild.$$"
    rm -rf "$tmp"
    mkdir -p "$tmp"
    ( cd "$REPO_ROOT" && tar -czf "$tmp/all.tar.gz" \
        --exclude='./.git' --exclude='./.worktrees' \
        --exclude='./.tad/active' --exclude='./.tad/archive' \
        --exclude='./.tad/decisions' --exclude='./.tad/dependencies' \
        --exclude='./.tad/evidence' --exclude='./.tad/github-registry' \
        --exclude='./.tad/memory' --exclude='./.tad/pair-testing' \
        --exclude='./.tad/project-knowledge' \
        --exclude='./.tad/research-notebooks' --exclude='./.tad/skill-library' \
        --exclude='./.tad/skillify-candidates' \
        --exclude='./.claude/skills/local' --exclude='./.agents/skills/local' \
        --exclude='./*.backup.*' --exclude='./.tad-migrate-backup*' \
        --exclude='./TAD-main' \
        --exclude='./assets' --exclude='./bin' --exclude='./codex-tad-bundle' \
        --exclude='./tad-work' --exclude='./supabase' --exclude='./research' \
        --exclude='./tad-intro.html' --exclude='./tad-intro-feedback.html' \
        --exclude='./OBJECTIVES.md' \
        . )
    # Re-root into TAD-main (the name the installer hardcodes after download).
    mkdir -p "$tmp/TAD-main"
    ( cd "$tmp" && tar -xzf all.tar.gz -C TAD-main )
    ( cd "$tmp" && tar -czf "$out" TAD-main )
}

# ══════════════════════════════════════════════════════════════════
# Mock curl — intercepts the fixed official URLs. Behavior toggles:
#   MOCK_MODE=empty|html|garbage|fail|ok
#   MOCK_REMOTE_VERSION=<semver>   (raw version.txt payload)
#   MOCK_SRC_TARBALL=<path>        (main + tag archive payload)
#   MOCK_INSTALLER=<path>          (tagged tad.sh payload)
#   MOCK_TAG_TARBALL=<path>        (optional tag-only override)
# Counts calls per URL class for "invoked exactly once" assertions:
#   MOCK_COUNT_FILE=<path>  (append one line per request)
# ══════════════════════════════════════════════════════════════════
make_mock_curl() {
    local dir="$1"
    cat > "$dir/curl" <<'MOCKEOF'
#!/bin/bash
# deterministic mock curl — see tad-update-fixture.sh header
out=""
url=""
prev=""
for a in "$@"; do
    if [ "$prev" = "-o" ]; then out="$a"; prev=""; continue; fi
    case "$a" in
        -o) prev="-o" ;;
        -*) ;;
        *) url="$a" ;;
    esac
done
if [ -n "${MOCK_COUNT_FILE:-}" ]; then
    printf '%s\n' "$url" >> "$MOCK_COUNT_FILE"
fi
case "${MOCK_MODE:-ok}" in
    empty)   [ -n "$out" ] && : > "$out"; exit 0 ;;
    html)    [ -n "$out" ] && printf '<html>404: Not Found</html>\n' > "$out"; exit 0 ;;
    garbage) [ -n "$out" ] && printf 'this is not a tar archive at all\n' > "$out"; exit 0 ;;
    fail)    exit 22 ;;
esac
case "$url" in
    *"/Sheldon-92/TAD/main/.tad/version.txt")
        payload="${MOCK_REMOTE_VERSION:-9.9.9}"
        if [ -n "$out" ]; then printf '%s\n' "$payload" > "$out"; else printf '%s\n' "$payload"; fi
        exit 0 ;;
    *"/Sheldon-92/TAD/archive/refs/tags/"*.tar.gz)
        if [ -n "${MOCK_TAG_TARBALL:-}" ]; then src="$MOCK_TAG_TARBALL"; else src="${MOCK_SRC_TARBALL:-}"; fi
        if [ -z "$src" ]; then exit 22; fi
        if [ -n "$out" ]; then cat "$src" > "$out"; else cat "$src"; fi
        exit 0 ;;
    *"/Sheldon-92/TAD/archive/refs/heads/main.tar.gz")
        if [ -z "${MOCK_SRC_TARBALL:-}" ]; then exit 22; fi
        if [ -n "$out" ]; then cat "$MOCK_SRC_TARBALL" > "$out"; else cat "$MOCK_SRC_TARBALL"; fi
        exit 0 ;;
    */tad.sh)
        if [ -z "${MOCK_INSTALLER:-}" ]; then exit 22; fi
        if [ -n "$out" ]; then cat "$MOCK_INSTALLER" > "$out"; else cat "$MOCK_INSTALLER"; fi
        exit 0 ;;
esac
echo "mock-curl: unhandled URL: $url" >&2
exit 22
MOCKEOF
    chmod +x "$dir/curl"
}

# ══════════════════════════════════════════════════════════════════
# Tree digest — md5 over sorted path+content; excludes ephemeral
# backup/migration/TAD-main trees that legitimately appear during runs.
# ══════════════════════════════════════════════════════════════════
digest_tree() {
    local dir="$1"
    ( cd "$dir" && find . -type f \
        -not -path './.tad.backup.*' -not -path './.tad-migrate-backup*' \
        -not -path './TAD-main/*' \
        -print | LC_ALL=C sort | xargs md5 -q | md5 )
}

# digest of a subtree (paths included via sort order; file set changes alter it)
digest_subtree() {
    local dir="$1"
    ( cd "$dir" && find . -type f -print | LC_ALL=C sort | xargs md5 -q | md5 )
}

# digest of USER-owned OpenCode content only (excludes the TAD-projected command)
digest_opencode_user() {
    local dir="$1"
    ( cd "$dir" && find . -type f -not -path './commands/tad-update.md' -print         | LC_ALL=C sort | xargs md5 -q | md5 )
}

# ══════════════════════════════════════════════════════════════════
# Shared sandbox: project dir + mock bin + counters
# ══════════════════════════════════════════════════════════════════
SANDBOX=""
SRC_TARBALL=""
setup_sandbox() {
    SANDBOX="$(mktemp -d)"
    mkdir -p "$SANDBOX/bin" "$SANDBOX/proj"
    make_mock_curl "$SANDBOX/bin"
    # Standard fixture source tarball (usable by every case; cases that need a
    # corrupted variant build their own with make_src_tarball).
    SRC_TARBALL="$SANDBOX/src.tar.gz"
    make_src_tarball "$SRC_TARBALL"
}
teardown_sandbox() {
    [ -n "$SANDBOX" ] && rm -rf "$SANDBOX"
}
trap teardown_sandbox EXIT

run_installer() {
    # run_installer <workdir> [extra args...]
    local wd="$1"; shift
    ( cd "$wd" \
        && PATH="$SANDBOX/bin:$PATH" \
             MOCK_SRC_TARBALL="$SRC_TARBALL" \
             MOCK_INSTALLER="$TAD_SH" \
             MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
             bash "$TAD_SH" "$@" )
}

run_updater() {
    # run_updater <workdir> [extra args...]
    local wd="$1"; shift
    ( cd "$wd" \
        && PATH="$SANDBOX/bin:$PATH" \
             MOCK_SRC_TARBALL="$SRC_TARBALL" \
             MOCK_INSTALLER="$TAD_SH" \
             MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
             bash "$UPDATER" "$@" )
}

make_old_project() {
    # make_old_project <proj> <version> — a realistic old install with
    # user evidence, a dangling symlink, and user OpenCode content.
    local proj="$1" ver="$2"
    mkdir -p "$proj/.tad/evidence/helpers"
    ln -s missing "$proj/.tad/evidence/helpers/node_modules"
    mkdir -p "$proj/.tad/active/handoffs"
    printf 'user handoff\n' > "$proj/.tad/active/handoffs/user.md"
    printf '%s\n' "$ver" > "$proj/.tad/version.txt"
    # Full zero-touch skeleton so snapshot-based acceptance verifiers see a
    # complete pre-upgrade tree (every dir the installer keeps in place, plus
    # the dirs the installer itself (re)creates on every run — a real old
    # install would already have them, and the snapshot must too, otherwise
    # the post-upgrade zero-touch diff flags installer-created empties).
    local zt
    for zt in active archive decisions dependencies evidence github-registry \
              memory pair-testing project-knowledge research-notebooks \
              skill-library skillify-candidates; do
        mkdir -p "$proj/.tad/$zt"
    done
    mkdir -p "$proj/.tad/active/designs" "$proj/.tad/active/epics" \
             "$proj/.tad/active/playground" \
             "$proj/.tad/archive/handoffs" "$proj/.tad/archive/epics" \
             "$proj/.tad/archive/playground" \
             "$proj/.tad/evidence/reviews" "$proj/.tad/evidence/completions" \
             "$proj/.tad/evidence/ralph-loops" "$proj/.tad/evidence/pair-tests" \
             "$proj/.tad/evidence/acceptance-tests" \
             "$proj/.tad/evidence/reviews/_iterations" \
             "$proj/.tad/reports"
    # project-knowledge/README.md is overwritten by the installer with the
    # source copy — seed the old install with the real source file so the
    # snapshot stays byte-identical after upgrade.
    if [ -f "$REPO_ROOT/.tad/project-knowledge/README.md" ]; then
        cp "$REPO_ROOT/.tad/project-knowledge/README.md" "$proj/.tad/project-knowledge/README.md"
    fi
    mkdir -p "$proj/.claude/skills/alex"
    printf 'skill stub\n' > "$proj/.claude/skills/alex/stub.md"
    mkdir -p "$proj/.agents/skills/alex"
    printf 'skill stub\n' > "$proj/.agents/skills/alex/stub.md"
    mkdir -p "$proj/.opencode/commands/custom"
    printf 'custom command\n' > "$proj/.opencode/commands/custom/custom.md"
    printf 'custom file\n' > "$proj/.opencode/commands/custom-extra.md"
}

# ══════════════════════════════════════════════════════════════════
# Case: backup (AC2)
# ══════════════════════════════════════════════════════════════════
case_backup() {
    echo "== backup: symlink-preserving snapshots + unique destinations =="

    # (a) dangling symlink survives; backup succeeds; link target preserved.
    setup_sandbox
    local proj="$SANDBOX/proj"
    mkdir -p "$proj/.tad/evidence/helpers"
    ln -s missing "$proj/.tad/evidence/helpers/node_modules"
    ( cd "$proj" && cp -R .tad "$SANDBOX/backup1" )
    if [ -L "$SANDBOX/backup1/evidence/helpers/node_modules" ] \
       && [ "$(readlink "$SANDBOX/backup1/evidence/helpers/node_modules")" = "missing" ]; then
        ok "dangling link preserved as a link with target text intact (cp -R)"
    else
        bad "dangling link not preserved by cp -R"
    fi

    # (b) two same-second normal backups cannot overwrite/nest: independent
    # snapshots of the same tree must produce identical digests and separate
    # destinations.
    local src_tar="$SRC_TARBALL"
    local b1 b2
    ( cd "$proj" && cp -R .tad "$SANDBOX/b1" )
    ( cd "$proj" && cp -R .tad "$SANDBOX/b2" )
    if [ "$(digest_tree "$SANDBOX/b1")" = "$(digest_tree "$SANDBOX/b2")" ]; then
        ok "independent snapshots are identical trees"
    else
        bad "independent snapshots differ"
    fi

    # (b2) integration-level negative control: run the REAL backup_existing
    # extracted from tad.sh against a symlink-bearing project — a cp -R → cp -r
    # regression inside the installer must turn this red.
    local bext="$SANDBOX/backup-extract.sh"
    {
        echo 'set -euo pipefail'
        echo "RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' CYAN='\033[0;36m' NC='\033[0m'"
        sed -n '/^log_info() {/,/^}/p;/^log_success() {/,/^}/p;/^log_warn() {/,/^}/p;/^log_error() {/,/^}/p' "$TAD_SH"
        sed -n '/^backup_existing() {/,/^}/p' "$TAD_SH"
        echo 'backup_existing'
    } > "$bext"
    local bp="$SANDBOX/bp"
    mkdir -p "$bp/.tad/evidence/helpers"
    ln -s missing "$bp/.tad/evidence/helpers/node_modules"
    if ( cd "$bp" && bash "$bext" >/dev/null 2>&1 ); then
        # pipefail-safe glob: an unmatched pattern must not abort the harness.
        local bl=""
        for d in "$bp"/.tad.backup.*; do
            [ -e "$d" ] || continue
            bl="$d"
            break
        done
        if [ -n "$bl" ] && [ -L "$bl/evidence/helpers/node_modules" ] \
           && [ "$(readlink "$bl/evidence/helpers/node_modules")" = "missing" ]; then
            ok "real backup_existing: succeeds and preserves the dangling link"
        else
            bad "real backup_existing: backup missing or link not preserved"
        fi
    else
        bad "real backup_existing failed on symlink-bearing project"
    fi

    # (c) migration fixture begins with a pre-existing .tad-migrate-backup*
    # and proves it survives while the new unique migration snapshot is used.
    local proj2="$SANDBOX/proj2"
    mkdir -p "$proj2/.tad/active/handoffs"
    printf '1.4.0\n' > "$proj2/.tad/version.txt"
    mkdir -p "$proj2/.tad-migrate-backup.20250101_000000"
    printf 'preexisting recovery\n' > "$proj2/.tad-migrate-backup.20250101_000000/recovery.txt"
    if [ ! -d "$proj2/.tad/evidence" ]; then
        mkdir -p "$proj2/.tad/evidence"
    fi
    # Run a real migrate install against the fixture source.
    if ( cd "$proj2" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_INSTALLER="$TAD_SH" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$TAD_SH" --yes >/dev/null 2>&1 ); then
        # detect_state: 1.4.0 vs fixture → migrate path
        if [ -f "$proj2/.tad-migrate-backup.20250101_000000/recovery.txt" ]; then
            ok "pre-existing migration recovery copy survived"
        else
            bad "pre-existing migration recovery copy was destroyed"
        fi
        if ls "$proj2"/.tad-migrate-backup.* >/dev/null 2>&1 \
           && [ "$(ls -d "$proj2"/.tad-migrate-backup.* | wc -l | tr -d ' ')" -ge 2 ]; then
            ok "new unique migration snapshot created alongside pre-existing one"
        else
            bad "no unique new migration snapshot found"
        fi
        if [ -f "$proj2/.tad/active/handoffs/user.md" ] \
           || [ -f "$proj2/.tad/version.txt" ]; then
            ok "migrated project end-state present"
        else
            bad "migrated project end-state missing"
        fi
    else
        bad "migrate install failed"
    fi
}

# ══════════════════════════════════════════════════════════════════
# Case: states (AC3) — update classification + platform matrix
# ══════════════════════════════════════════════════════════════════
case_states() {
    echo "== states: deterministic update + platform classification =="
    setup_sandbox
    local proj="$SANDBOX/proj"
    mkdir -p "$proj/.tad"
    printf '%s\n' "$FIXTURE_VERSION" > "$proj/.tad/version.txt"

    # equal → exit 0, "Already up to date", no mutation
    local out
    out="$(run_updater "$proj" --check)" || true
    printf '%s\n' "$out" | grep -q "Already up to date" && ok "equal → up to date" \
        || bad "equal → not detected as up to date"

    # older (local newer than remote) → refuse downgrade, exit 1
    printf '9.9.9\n' > "$proj/.tad/version.txt"
    out="$(run_updater "$proj" --check 2>&1)" || true
    printf '%s\n' "$out" | grep -q "downgrade refused" && ok "older remote → downgrade refused" \
        || bad "older remote → downgrade not refused"
    [ "$(cat "$proj/.tad/version.txt")" = "9.9.9" ] && ok "no mutation on downgrade refusal" \
        || bad "downgrade refusal mutated the project"

    # newer (local older than remote) → update available
    printf '1.0.0\n' > "$proj/.tad/version.txt"
    out="$(run_updater "$proj" --check 2>&1)" || true
    printf '%s\n' "$out" | grep -q "Update available" && ok "newer remote → update available" \
        || bad "newer remote → not detected"

    # malformed local → error, no mutation
    printf 'garbage\n' > "$proj/.tad/version.txt"
    out="$(run_updater "$proj" --check 2>&1)" || true
    printf '%s\n' "$out" | grep -qi "not a strict" && ok "malformed local → clear error" \
        || bad "malformed local → no error"
    [ "$(cat "$proj/.tad/version.txt")" = "garbage" ] && ok "no mutation on malformed local" \
        || bad "malformed local mutated the project"

    # remote unavailable → error, no mutation
    printf '%s\n' "$FIXTURE_VERSION" > "$proj/.tad/version.txt"
    out="$(PATH="$SANDBOX/bin:$PATH" MOCK_MODE=fail bash "$UPDATER" --check 2>&1)" || true
    printf '%s\n' "$out" | grep -qi "could not retrieve" && ok "remote unavailable → clear error" \
        || bad "remote unavailable → no clear error"

    # malformed remote → error
    out="$(PATH="$SANDBOX/bin:$PATH" MOCK_REMOTE_VERSION="<html>nope</html>" bash "$UPDATER" --check 2>&1)" || true
    printf '%s\n' "$out" | grep -qi "malformed" && ok "malformed remote → clear error" \
        || bad "malformed remote → no clear error"

    # platform matrix: claude-code / codex / both / explicit / ambiguous.
    # Apply needs a real update available, so pin the local version below remote
    # and use a fast no-op installer for the delegation assertion.
    printf '1.0.0\n' > "$proj/.tad/version.txt"
    local fast_installer="$SANDBOX/fast-installer.sh"
    printf '#!/bin/bash\n# TAD Framework installer stub\nexit 0\n' > "$fast_installer"
    chmod +x "$fast_installer"
    run_updater_platform() {
        # run_updater_platform <workdir> <installer> [extra args...]
        local wd="$1" inst="$2"; shift 2
        ( cd "$wd" \
            && PATH="$SANDBOX/bin:$PATH" \
                 MOCK_SRC_TARBALL="$SRC_TARBALL" \
                 MOCK_INSTALLER="$inst" \
                 MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
                 bash "$UPDATER" "$@" 2>&1 ) || true
    }

    rm -rf "$proj/.claude" "$proj/.agents"
    mkdir -p "$proj/.claude/skills/alex"
    out="$(run_updater_platform "$proj" "$fast_installer" --yes)"
    printf '%s\n' "$out" | grep -q "platform: claude-code" \
        && ok "claude-only → platform claude-code forwarded" \
        || bad "claude-only → platform not claude-code"

    rm -rf "$proj/.claude"
    mkdir -p "$proj/.agents/skills/alex"
    out="$(run_updater_platform "$proj" "$fast_installer" --yes)"
    printf '%s\n' "$out" | grep -q "platform: codex" && ok "codex-only → platform codex forwarded" \
        || bad "codex-only → platform not codex"

    rm -rf "$proj/.agents"
    mkdir -p "$proj/.claude/skills/alex" "$proj/.agents/skills/alex"
    out="$(run_updater_platform "$proj" "$fast_installer" --yes)"
    printf '%s\n' "$out" | grep -q "platform: both" && ok "both present → platform both forwarded" \
        || bad "both present → platform not both"

    out="$(run_updater_platform "$proj" "$fast_installer" --yes --platform codex)"
    printf '%s\n' "$out" | grep -q "platform: codex" && ok "explicit --platform overrides detection" \
        || bad "explicit --platform not honored"

    rm -rf "$proj/.claude" "$proj/.agents"
    out="$(run_updater_platform "$proj" "$fast_installer" --yes)"
    printf '%s\n' "$out" | grep -q "cannot determine the installed platform" \
        && ok "ambiguous layout → apply refuses with guidance" \
        || bad "ambiguous layout → apply did not refuse"
}

# ══════════════════════════════════════════════════════════════════
# Case: consent (AC4) — explicit confirmation boundary
# ══════════════════════════════════════════════════════════════════
case_consent() {
    echo "== consent: explicit confirmation required; apply delegates exactly once =="
    setup_sandbox
    local proj="$SANDBOX/proj"
    mkdir -p "$proj/.tad" "$proj/.claude/skills/alex" "$proj/.agents/skills/alex"
    # Pin local BELOW remote so every branch reaches the confirmation gate
    # (an equal local version would exit before any consent logic runs).
    printf '1.0.0\n' > "$proj/.tad/version.txt"
    local counts="$SANDBOX/calls.txt"
    : > "$counts"
    export MOCK_COUNT_FILE="$counts"

    # no-TTY default: check output, "confirmation required", nonzero, no installer call
    local rc=0 out
    out="$(cd "$proj" && PATH="$SANDBOX/bin:$PATH" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$UPDATER" < /dev/null 2>&1)" || rc=$?
    [ "$rc" -eq 3 ] && ok "no-TTY → exit 3" || bad "no-TTY → exit $rc (expected 3)"
    printf '%s\n' "$out" | grep -q "confirmation required" \
        && ok "no-TTY → prints 'confirmation required'" \
        || bad "no-TTY → missing 'confirmation required'"
    if ! grep -q "/tad.sh" "$counts"; then
        ok "no-TTY → installer never invoked"
    else
        bad "no-TTY → installer invoked"
    fi

    # decline via explicit --check: read-only, zero calls
    : > "$counts"
    run_updater "$proj" --check >/dev/null 2>&1
    if ! grep -q "/tad.sh" "$counts"; then
        ok "--check → zero installer calls"
    else
        bad "--check → installer invoked"
    fi
    [ "$(cat "$proj/.tad/version.txt")" = "1.0.0" ] && ok "--check → no mutation" \
        || bad "--check → mutated project"

    # approved --yes: installer called exactly once, project updated
    : > "$counts"
    if run_updater "$proj" --yes >/dev/null 2>&1; then
        ok "--yes → apply succeeded"
    else
        bad "--yes → apply failed"
    fi
    local calls
    calls="$(grep -c "/tad.sh" "$counts" || true)"
    [ "$calls" = "1" ] && ok "--yes → installer invoked exactly once" \
        || bad "--yes → installer invoked $calls times (expected 1)"
    [ "$(cat "$proj/.tad/version.txt")" = "$FIXTURE_VERSION" ] \
        && ok "--yes → project updated to $FIXTURE_VERSION" \
        || bad "--yes → project not updated"

    # updater must never pass --force to the installer
    if grep -q -- '--force' "$UPDATER"; then
        bad "updater references --force"
    else
        ok "updater never passes --force"
    fi
}

# ══════════════════════════════════════════════════════════════════
# Case: download-safety (AC5) — fail-closed download/extraction/binding
# ══════════════════════════════════════════════════════════════════
case_download_safety() {
    echo "== download-safety: fail-closed download, extraction, immutable binding =="
    setup_sandbox
    local src_tar="$SRC_TARBALL"
    local proj="$SANDBOX/proj"
    make_old_project "$proj" "$OLD_VERSION"
    mkdir -p "$proj/.claude/skills/alex" "$proj/.agents/skills/alex"
    local digest_before
    digest_before="$(digest_tree "$proj")"

    # empty installer payload → refused, no mutation
    if PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" MOCK_INSTALLER="$TAD_SH" \
        MOCK_MODE=empty bash "$UPDATER" --yes >/dev/null 2>&1; then
        bad "empty installer payload was accepted"
    else
        ok "empty installer payload rejected"
    fi
    [ "$(digest_tree "$proj")" = "$digest_before" ] && ok "empty payload → zero project mutation" \
        || bad "empty payload → project mutated"

    # HTML payload → refused
    if PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" MOCK_INSTALLER="$TAD_SH" \
        MOCK_MODE=html bash "$UPDATER" --yes >/dev/null 2>&1; then
        bad "HTML installer payload was accepted"
    else
        ok "HTML installer payload rejected"
    fi
    [ "$(digest_tree "$proj")" = "$digest_before" ] && ok "HTML payload → zero project mutation" \
        || bad "HTML payload → project mutated"

    # non-installer (garbage) payload → refused
    if PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" MOCK_INSTALLER="$TAD_SH" \
        MOCK_MODE=garbage bash "$UPDATER" --yes >/dev/null 2>&1; then
        bad "garbage installer payload was accepted"
    else
        ok "garbage installer payload rejected"
    fi

    # unsafe archive root (two roots) → pinned installer refuses, no residue
    local badtar="$SANDBOX/bad.tar.gz"
    local bd="$SANDBOX/bad"
    mkdir -p "$bd/TAD-main/.tad" "$bd/TAD-other/.tad"
    printf '%s\n' "$FIXTURE_VERSION" > "$bd/TAD-main/.tad/version.txt"
    ( cd "$bd" && tar -czf "$badtar" TAD-main TAD-other )
    local proj5="$SANDBOX/proj5"
    make_old_project "$proj5" "$OLD_VERSION"
    mkdir -p "$proj5/.claude/skills/alex" "$proj5/.agents/skills/alex"
    printf '1.0.0\n' > "$proj5/.tad/version.txt"
    local d5
    d5="$(digest_tree "$proj5")"
    local rc5=0
    ( cd "$proj5" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_TAG_TARBALL="$badtar" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$TAD_SH" --release-ref "v$FIXTURE_VERSION" --expected-version "$FIXTURE_VERSION" --yes ) >/dev/null 2>&1 || rc5=$?
    [ "$rc5" -ne 0 ] && ok "multi-root archive refused (rc=$rc5)" || bad "multi-root archive accepted"
    [ "$(digest_tree "$proj5")" = "$d5" ] && ok "multi-root → zero project mutation" \
        || bad "multi-root → project mutated"
    if ls "$proj5"/TAD-* >/dev/null 2>&1; then
        bad "TAD-* residue in project after unsafe archive"
    else
        ok "no TAD-* residue in project"
    fi

    # pinned mode ignores mutable-main probe: main version.txt says 9.9.9,
    # tag archive carries fixture version → installs fixture version only.
    local proj2="$SANDBOX/proj2"
    make_old_project "$proj2" "$OLD_VERSION"
    mkdir -p "$proj2/.claude/skills/alex" "$proj2/.agents/skills/alex"
    if ( cd "$proj2" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_INSTALLER="$TAD_SH" MOCK_REMOTE_VERSION="9.9.9" \
        bash "$TAD_SH" --release-ref "v$FIXTURE_VERSION" --expected-version "$FIXTURE_VERSION" --yes ) >/dev/null 2>&1; then
        if [ "$(cat "$proj2/.tad/version.txt")" = "$FIXTURE_VERSION" ]; then
            ok "pinned mode installs the pinned version, not the mutable-main probe"
        else
            bad "pinned mode installed the wrong version: $(cat "$proj2/.tad/version.txt")"
        fi
    else
        bad "pinned install failed"
    fi

    # version/ref mismatch → refused with zero mutation
    local proj3="$SANDBOX/proj3"
    make_old_project "$proj3" "$OLD_VERSION"
    mkdir -p "$proj3/.claude/skills/alex" "$proj3/.agents/skills/alex"
    local d3
    d3="$(digest_tree "$proj3")"
    local rc3=0
    ( cd "$proj3" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$TAD_SH" --release-ref "v$FIXTURE_VERSION" --expected-version "1.0.0" --yes ) >/dev/null 2>&1 || rc3=$?
    [ "$rc3" -ne 0 ] && ok "version mismatch refused" || bad "version mismatch accepted"
    [ "$(digest_tree "$proj3")" = "$d3" ] && ok "version mismatch → zero mutation" \
        || bad "version mismatch → project mutated"

    # pinned archive with NO .tad/version.txt → fail CLOSED (the literal
    # fallback must never stand in for an unverifiable archive version)
    local novtar="$SANDBOX/noversion.tar.gz"
    local nd="$SANDBOX/noversion"
    mkdir -p "$nd/TAD-main/.tad"
    ( cd "$nd" && tar -czf "$novtar" TAD-main )
    local proj7="$SANDBOX/proj7"
    make_old_project "$proj7" "$OLD_VERSION"
    mkdir -p "$proj7/.claude/skills/alex" "$proj7/.agents/skills/alex"
    printf '1.0.0\n' > "$proj7/.tad/version.txt"
    local d7
    d7="$(digest_tree "$proj7")"
    local rc7=0
    ( cd "$proj7" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_TAG_TARBALL="$novtar" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$TAD_SH" --release-ref "v$FIXTURE_VERSION" --expected-version "$FIXTURE_VERSION" --yes ) >/dev/null 2>&1 || rc7=$?
    [ "$rc7" -ne 0 ] && ok "archive without version.txt refused (fail-closed)" \
        || bad "archive without version.txt accepted"
    [ "$(digest_tree "$proj7")" = "$d7" ] && ok "no-version archive → zero mutation" \
        || bad "no-version archive → project mutated"

    # non-zero installer exit propagates
    local proj6="$SANDBOX/proj6"
    make_old_project "$proj6" "$OLD_VERSION"
    mkdir -p "$proj6/.claude/skills/alex" "$proj6/.agents/skills/alex"
    printf '1.0.0\n' > "$proj6/.tad/version.txt"
    local fake_installer="$SANDBOX/fake-installer.sh"
    printf '#!/bin/bash\n# TAD Framework installer stub\nexit 42\n' > "$fake_installer"
    chmod +x "$fake_installer"
    local rc4=0
    ( cd "$proj6" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_INSTALLER="$fake_installer" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$UPDATER" --yes ) >/dev/null 2>&1 || rc4=$?
    [ "$rc4" -eq 42 ] && ok "installer exit code propagated (42)" \
        || bad "installer exit code not propagated (got $rc4)"

    # temp cleanup: no tad-installer.* residue
    if ls "${TMPDIR:-/tmp}"/tad-installer.* >/dev/null 2>&1; then
        bad "tad-installer.* residue in TMPDIR"
    else
        ok "installer temp file cleaned"
    fi

    # environment URL override is ignored/rejected: the mock only answers the
    # fixed URLs, so an evil DOWNLOAD_URL/RAW_GITHUB_URL env var must not change
    # where the helper fetches from.
    local counts="$SANDBOX/calls.txt"
    : > "$counts"
    if ( cd "$proj3" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$src_tar" \
        MOCK_COUNT_FILE="$counts" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        DOWNLOAD_URL="https://evil.example/tad.sh" RAW_GITHUB_URL="https://evil.example/raw" \
        bash "$UPDATER" --check ) >/dev/null 2>&1; then
        if grep -q "evil.example" "$counts"; then
            bad "environment URL override reached the network layer"
        else
            ok "environment URL override ignored (fixed endpoints used)"
        fi
    else
        bad "check failed under env-var override attempt"
    fi
}

# ══════════════════════════════════════════════════════════════════
# Case: opencode-preservation (AC8)
# ══════════════════════════════════════════════════════════════════
case_opencode_preservation() {
    echo "== opencode-preservation: exact projection + preservation + rollback =="
    setup_sandbox
    local src_tar="$SRC_TARBALL"

    # fresh install with user OpenCode content → custom tree byte-identical,
    # TAD command present and source-identical.
    local proj="$SANDBOX/proj"
    mkdir -p "$proj/.opencode/commands/custom" "$proj/.claude/skills/alex" "$proj/.agents/skills/alex"
    printf 'custom command\n' > "$proj/.opencode/commands/custom/custom.md"
    printf 'custom file\n' > "$proj/.opencode/commands/custom-extra.md"
    local custom_digest
    custom_digest="$(digest_opencode_user "$proj/.opencode")"
    if run_installer "$proj" --yes >/dev/null 2>&1; then
        [ "$(digest_opencode_user "$proj/.opencode")" = "$custom_digest" ] \
            && ok "fresh install → user OpenCode content byte-identical" \
            || bad "fresh install → user OpenCode content altered"
        cmp -s "$proj/.opencode/commands/tad-update.md" "$REPO_ROOT/.opencode/commands/tad-update.md" \
            && ok "fresh install → TAD command present and source-identical" \
            || bad "fresh install → TAD command missing/mismatched"
    else
        bad "fresh install failed"
    fi

    # upgrade from old project → same preservation guarantees
    local proj2="$SANDBOX/proj2"
    make_old_project "$proj2" "$OLD_VERSION"
    printf '1.0.0\n' > "$proj2/.tad/version.txt"
    local custom_digest2
    custom_digest2="$(digest_opencode_user "$proj2/.opencode")"
    if run_installer "$proj2" --yes >/dev/null 2>&1; then
        [ "$(digest_opencode_user "$proj2/.opencode")" = "$custom_digest2" ] \
            && ok "upgrade → user OpenCode content byte-identical" \
            || bad "upgrade → user OpenCode content altered"
        cmp -s "$proj2/.opencode/commands/tad-update.md" "$REPO_ROOT/.opencode/commands/tad-update.md" \
            && ok "upgrade → TAD command present and source-identical" \
            || bad "upgrade → TAD command missing/mismatched"
    else
        bad "upgrade failed"
    fi

    # divergent existing TAD command → preflight fails BEFORE any mutation
    # across .tad/.claude/.agents/root-files/.opencode.
    local proj3="$SANDBOX/proj3"
    make_old_project "$proj3" "$OLD_VERSION"
    printf '1.0.0\n' > "$proj3/.tad/version.txt"
    mkdir -p "$proj3/.opencode/commands"
    printf 'divergent content\n' > "$proj3/.opencode/commands/tad-update.md"
    local all_before
    all_before="$(digest_tree "$proj3")"
    local rc3=0
    run_installer "$proj3" --yes >/dev/null 2>&1 || rc3=$?
    [ "$rc3" -ne 0 ] && ok "divergent target → install refused" \
        || bad "divergent target → install did not refuse"
    [ "$(digest_tree "$proj3")" = "$all_before" ] \
        && ok "divergent target → zero changes across all managed surfaces" \
        || bad "divergent target → managed surfaces changed"
    if [ ! -d "$proj3/TAD-main" ]; then
        ok "divergent target → no TAD-* residue (downloaded source cleaned)"
    else
        bad "divergent target → TAD-main residue left in project"
    fi
    if run_installer "$proj3" --yes > "$SANDBOX/proj3.log" 2>&1; then
        bad "divergent target → second run unexpectedly succeeded"
    fi
    if grep -q "rename or remove" "$SANDBOX/proj3.log"; then
        ok "divergent target → deterministic recovery instruction printed"
    else
        bad "divergent target → recovery instruction missing"
        [ -n "${TAD_DEBUG:-}" ] && cat "$SANDBOX/proj3.log"
    fi

    # injected post-projection failure → rollback restores exact pre-run tree.
    local proj4="$SANDBOX/proj4"
    make_old_project "$proj4" "$OLD_VERSION"
    printf '1.0.0\n' > "$proj4/.tad/version.txt"
    local op_before
    op_before="$(digest_subtree "$proj4/.opencode")"
    # Corrupt the source tarball: remove CLAUDE.md so merge_claude_md fails
    # AFTER projection (the completeness self-check is one-directional and
    # cannot be tripped by deletion) → rollback must restore .opencode.
    local bad_src="$SANDBOX/badsrc.tar.gz"
    local bd="$SANDBOX/badsrc"
    mkdir -p "$bd"
    ( cd "$bd" && tar -xzf "$src_tar" )
    rm -f "$bd/TAD-main/CLAUDE.md"
    ( cd "$bd" && tar -czf "$bad_src" TAD-main )
    local rc4=0
    ( cd "$proj4" && PATH="$SANDBOX/bin:$PATH" MOCK_SRC_TARBALL="$bad_src" \
        MOCK_INSTALLER="$TAD_SH" MOCK_REMOTE_VERSION="$FIXTURE_VERSION" \
        bash "$TAD_SH" --yes > "$SANDBOX/proj4.log" 2>&1 ) || rc4=$?
    if [ -n "${TAD_DEBUG:-}" ]; then cat "$SANDBOX/proj4.log"; fi
    [ "$rc4" -ne 0 ] && ok "post-projection failure → install failed (as injected)" \
        || bad "post-projection failure did not fail the install"
    [ "$(digest_subtree "$proj4/.opencode")" = "$op_before" ] \
        && ok "post-projection failure → .opencode restored to exact pre-run tree" \
        || bad "post-projection failure → .opencode not restored"
}

# ══════════════════════════════════════════════════════════════════
# Case: full-upgrade (AC9) — real old install → fixture version
# ══════════════════════════════════════════════════════════════════
case_full_upgrade() {
    echo "== full-upgrade: disposable $OLD_VERSION project → $FIXTURE_VERSION =="
    setup_sandbox
    local src_tar="$SRC_TARBALL"

    local proj="$SANDBOX/proj"
    make_old_project "$proj" "$OLD_VERSION"
    local snapshot="$SANDBOX/snapshot"
    mkdir -p "$snapshot/.tad"
    cp -R "$proj/.tad/." "$snapshot/.tad/"

    if ! run_installer "$proj" --yes >/dev/null 2>&1; then
        bad "upgrade install failed"
        return 1
    fi

    # version updated
    [ "$(cat "$proj/.tad/version.txt")" = "$FIXTURE_VERSION" ] \
        && ok "upgrade → version.txt is $FIXTURE_VERSION" \
        || bad "upgrade → version.txt is $(cat "$proj/.tad/version.txt")"

    # user evidence + dangling symlink survive in the announced backup
    local backup_dir
    backup_dir="$(ls -d "$proj"/.tad.backup.* 2>/dev/null | head -1 || true)"
    if [ -n "$backup_dir" ]; then
        [ -L "$backup_dir/evidence/helpers/node_modules" ] \
            && ok "backup → dangling symlink preserved in backup" \
            || bad "backup → dangling symlink missing from backup"
        [ -f "$backup_dir/active/handoffs/user.md" ] \
            && ok "backup → user evidence preserved" \
            || bad "backup → user evidence missing"
    else
        bad "upgrade → no backup directory created"
    fi

    # project retains its evidence
    [ -f "$proj/.tad/active/handoffs/user.md" ] \
        && ok "upgrade → project evidence retained in place" \
        || bad "upgrade → project evidence lost"

    # OpenCode command projected
    cmp -s "$proj/.opencode/commands/tad-update.md" "$REPO_ROOT/.opencode/commands/tad-update.md" \
        && ok "upgrade → OpenCode command projected" \
        || bad "upgrade → OpenCode command missing"

    # acceptance verifier with snapshot + migration expectation
    if bash "$UPGRADE_ACCEPTANCE" --target "$proj" --expected-version "$FIXTURE_VERSION" \
        --snapshot "$snapshot" --expect-migration-from "$OLD_VERSION" > "$SANDBOX/ua.log" 2>&1; then
        ok "upgrade-acceptance.sh PASS"
    else
        bad "upgrade-acceptance.sh FAIL"
        [ -n "${TAD_DEBUG:-}" ] && cat "$SANDBOX/ua.log"
    fi

    # existing suites remain green
    if bash "$DETECT_STATE_FIXTURE" >/dev/null 2>&1; then
        ok "detect-state-fixture.sh PASS"
    else
        bad "detect-state-fixture.sh FAIL"
    fi
    if bash "$MIGRATION_RUNNER" >/dev/null 2>&1; then
        ok "migration-fixtures/run-fixtures.sh PASS"
    else
        bad "migration-fixtures/run-fixtures.sh FAIL"
    fi
}

# ══════════════════════════════════════════════════════════════════
# Case: release-gates (AC10) — authoritative preflight order
# ══════════════════════════════════════════════════════════════════
case_release_gates() {
    echo "== release-gates: canonical order, recorded, all exit 0 =="
    setup_sandbox
    local log="$SANDBOX/release-gates.log"
    : > "$log"

    # 1. parity
    if bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" parity "$REPO_ROOT" >> "$log" 2>&1; then
        printf '1 parity\n' >> "$log"
        ok "gate 1: parity PASS"
    else
        bad "gate 1: parity FAIL"
    fi

    # 2. derive-sync-set report + version zero-stale
    if bash "$REPO_ROOT/.tad/hooks/lib/derive-sync-set.sh" --report "$REPO_ROOT" >> "$log" 2>&1 \
       && bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" version "$REPO_ROOT" "$FIXTURE_VERSION" "$OLD_VERSION" >> "$log" 2>&1; then
        printf '2 derive-sync-set + version %s/%s\n' "$FIXTURE_VERSION" "$OLD_VERSION" >> "$log"
        ok "gate 2: derive-sync-set report + version PASS"
    else
        bad "gate 2: derive-sync-set/version FAIL"
    fi

    # 3. version-sweep
    if bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" version-sweep "$REPO_ROOT" "$FIXTURE_VERSION" >> "$log" 2>&1; then
        printf '3 version-sweep\n' >> "$log"
        ok "gate 3: version-sweep PASS"
    else
        bad "gate 3: version-sweep FAIL"
    fi

    # 4. migration
    if bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" migration "$REPO_ROOT" >> "$log" 2>&1; then
        printf '4 migration\n' >> "$log"
        ok "gate 4: migration PASS"
    else
        bad "gate 4: migration FAIL"
    fi

    # 5. pack-registry driftcheck (advisory — recorded, not blocking)
    if bash "$REPO_ROOT/.tad/hooks/lib/pack-registry-driftcheck.sh" >> "$log" 2>&1; then
        printf '5 pack-registry driftcheck (advisory)\n' >> "$log"
        ok "gate 5: pack-registry driftcheck PASS (advisory recorded)"
    else
        printf '5 pack-registry driftcheck ADVISORY-FAIL (recorded)\n' >> "$log"
        ok "gate 5: pack-registry driftcheck advisory recorded (non-blocking)"
    fi

    # 6. tad.sh denylist drift
    if bash "$TAD_SH" --verify-denylist >> "$log" 2>&1; then
        printf '6 tad.sh denylist\n' >> "$log"
        ok "gate 6: tad.sh --verify-denylist PASS"
    else
        bad "gate 6: tad.sh --verify-denylist FAIL"
    fi

    # order assertion: 1..6 each present in sequence
    local seq
    seq="$(grep -oE '^[1-6]' "$log" | tr -d '\n')"
    [ "$seq" = "123456" ] && ok "gates ran in canonical order" \
        || bad "gate order wrong: '$seq'"
}

# ══════════════════════════════════════════════════════════════════
# Case: remote-release (AC14) — post-Gate-4 publication verification
# ══════════════════════════════════════════════════════════════════
case_remote_release() {
    echo "== remote-release: annotated tag + remote refs resolve to the accepted commit =="
    if [ -z "$EXPECTED_COMMIT" ]; then
        echo "  SKIP: --expected-commit not provided (post-Gate-4 publication only)"
        return 0
    fi
    local tag="v${FIXTURE_VERSION}"

    # local tag object type
    local ttype
    ttype="$(git -C "$REPO_ROOT" cat-file -t "$tag" 2>/dev/null || true)"
    if [ "$ttype" = "tag" ]; then
        ok "local tag $tag exists and is annotated (object type: tag)"
    else
        bad "local tag $tag missing or not annotated (type: ${ttype:-<absent>})"
    fi

    # origin/main resolves to the accepted commit
    local remote_main
    remote_main="$(git -C "$REPO_ROOT" ls-remote origin refs/heads/main 2>/dev/null | cut -f1 || true)"
    if [ "$remote_main" = "$EXPECTED_COMMIT" ]; then
        ok "origin/main == $EXPECTED_COMMIT"
    else
        bad "origin/main is ${remote_main:-<unreachable>} (expected $EXPECTED_COMMIT)"
    fi

    # remote tag peeled SHA
    local peeled
    peeled="$(git -C "$REPO_ROOT" ls-remote origin "refs/tags/${tag}^{}" 2>/dev/null | cut -f1 || true)"
    if [ "$peeled" = "$EXPECTED_COMMIT" ]; then
        ok "remote tag $tag peels to $EXPECTED_COMMIT"
    else
        bad "remote tag $tag peels to ${peeled:-<unreachable>} (expected $EXPECTED_COMMIT)"
    fi

    # GitHub Release target (read-only via gh; SKIP if gh unavailable)
    if command -v gh >/dev/null 2>&1; then
        local release_json
        release_json="$(gh release view "$tag" --repo Sheldon-92/TAD --json isDraft,isPrerelease,targetCommitish,url 2>/dev/null || true)"
        if [ -n "$release_json" ]; then
            local target is_draft is_pre
            target="$(printf '%s' "$release_json" | sed -n 's/.*"targetCommitish": *"\([^"]*\)".*/\1/p')"
            is_draft="$(printf '%s' "$release_json" | sed -n 's/.*"isDraft": *\([a-z]*\).*/\1/p')"
            is_pre="$(printf '%s' "$release_json" | sed -n 's/.*"isPrerelease": *\([a-z]*\).*/\1/p')"
            [ "$target" = "$EXPECTED_COMMIT" ] && ok "GitHub Release target == $EXPECTED_COMMIT" \
                || bad "GitHub Release target is $target"
            [ "$is_draft" = "false" ] && [ "$is_pre" = "false" ] \
                && ok "GitHub Release is non-draft and non-prerelease" \
                || bad "GitHub Release draft=$is_draft prerelease=$is_pre"
            printf '%s' "$release_json" | grep -q '"url"' \
                && ok "GitHub Release URL present" \
                || bad "GitHub Release URL missing"
        else
            echo "  SKIP: release $tag not found via gh (not published yet)"
        fi
    else
        echo "  SKIP: gh CLI unavailable"
    fi
}

# ══════════════════════════════════════════════════════════════════
# Dispatch
# ══════════════════════════════════════════════════════════════════
case "$CASE" in
    backup) case_backup ;;
    states) case_states ;;
    consent) case_consent ;;
    download-safety) case_download_safety ;;
    opencode-preservation) case_opencode_preservation ;;
    full-upgrade) case_full_upgrade ;;
    release-gates) case_release_gates ;;
    remote-release) case_remote_release ;;
    *) echo "tad-update-fixture: unknown --case '$CASE'" >&2; exit 2 ;;
esac

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS  FAIL: $FAIL"
if [ "$FAIL" -gt 0 ]; then
    echo "VERDICT: FAIL"
    exit 1
fi
echo "VERDICT: PASS"
exit 0