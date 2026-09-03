#!/bin/bash

# TAD updater helper — the SINGLE update orchestration point for the current
# project (Claude Code / Codex skills and the OpenCode command all delegate here).
#
# Design contract (TAD v2.43.1, HANDOFF-20260902-tad-update-v2431 FR-2):
#   - One engine: this helper only checks, compares, and delegates. Installation,
#     backup, migration, and rollback live in the canonical remote tad.sh — never
#     reimplemented here.
#   - Explicit human confirmation: --yes is the SOLE apply mechanism and is only
#     legal after an external human approval. With a controlling TTY the default
#     mode prompts once. Without a TTY, only the check runs: it prints
#     "confirmation required" and exits nonzero without consuming piped input
#     and without invoking any installer.
#   - Fail-closed: any malformed local/remote version, refused downgrade,
#     platform ambiguity at apply time, or network failure makes NO mutation.
#   - Pinned binding: the version shown to the human is bound to the immutable
#     GitHub tag ref vX.Y.Z; the tagged tad.sh is downloaded to a private temp
#     file, sanity-checked, and invoked with --release-ref/--expected-version so
#     the installer itself re-validates before any project mutation.
#   - Fixed endpoints: compiled-in official HTTPS URLs only. No environment
#     variable can override them (code-execution injection surface is closed).

set -euo pipefail

VERSION_URL_BASE="https://raw.githubusercontent.com/Sheldon-92/TAD"
TAG_INSTALLER_URL_BASE="https://raw.githubusercontent.com/Sheldon-92/TAD"

# Project root = the caller's working directory. The skill/command contract
# invokes this helper from the project root (`bash .tad/scripts/tad-update.sh`),
# so $PWD is the deterministic anchor — not the script's own location, which
# differs when the helper is exercised from outside the project (e.g. tests).
PROJECT_ROOT="$(pwd -P)"

MODE_CHECK=0
MODE_YES=0
PLATFORM_ARG=""

usage() {
    cat <<'EOF'
Usage: tad-update.sh [--check] [--yes] [--platform <claude-code|codex|both>] [--help]

  --check                read-only check: print current/remote versions and
                         whether an update is available. Never mutates.
  --yes                  apply the update. ONLY after explicit human approval;
                         the helper itself never infers consent.
  --platform <name>      explicit platform when automatic detection is
                         ambiguous (claude-code | codex | both).
  --help                 this help.

Default (no flag): with a controlling TTY, check then prompt once for
confirmation. Without a TTY, only the check runs and the script exits
with status 3 ("confirmation required").

Exit codes: 0 = up to date / declined / applied; 1 = error (no mutation);
3 = confirmation required (no TTY); 2 = usage error.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --check) MODE_CHECK=1; shift ;;
        --yes) MODE_YES=1; shift ;;
        --platform)
            [ -z "${2:-}" ] && echo "tad-update: --platform requires a value" >&2 && exit 2
            PLATFORM_ARG="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "tad-update: unknown option '$1' (use --help)" >&2; exit 2 ;;
    esac
done

if [ "$MODE_CHECK" = "1" ] && [ "$MODE_YES" = "1" ]; then
    echo "tad-update: --check and --yes are mutually exclusive" >&2
    exit 2
fi

if [ -n "$PLATFORM_ARG" ]; then
    case "$PLATFORM_ARG" in
        claude-code|codex|both) ;;
        *) echo "tad-update: --platform must be claude-code, codex, or both (got: $PLATFORM_ARG)" >&2; exit 2 ;;
    esac
fi

# ============================================
# Version parsing (strict MAJOR.MINOR.PATCH)
# ============================================
is_semver() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# compare: echo -1 if a<b, 0 if a==b, 1 if a>b (numeric, BSD-safe)
ver_cmp() {
    local a="$1" b="$2"
    [ "$a" = "$b" ] && { echo 0; return; }
    local IFS=.
    # bash 3.2 compatible: no -a arrays; split via positional params. Save the
    # inputs FIRST — `set -- $a` overwrites $1/$2, so $b must be captured before.
    local a1 a2 a3 b1 b2 b3
    set -- $a
    a1="${1:-0}"; a2="${2:-0}"; a3="${3:-0}"
    set -- $b
    b1="${1:-0}"; b2="${2:-0}"; b3="${3:-0}"
    if [ "$a1" -gt "$b1" ]; then echo 1; return; fi
    if [ "$a1" -lt "$b1" ]; then echo -1; return; fi
    if [ "$a2" -gt "$b2" ]; then echo 1; return; fi
    if [ "$a2" -lt "$b2" ]; then echo -1; return; fi
    if [ "$a3" -gt "$b3" ]; then echo 1; return; fi
    if [ "$a3" -lt "$b3" ]; then echo -1; return; fi
    echo 0
}

# ============================================
# Platform detection (deterministic precedence)
# ============================================
# both → both canonical Alex skill roots present
# claude-code → only .claude/skills/alex
# codex → only .agents/skills/alex
# else → ambiguous/absent (check may report; apply REQUIRES --platform)
detect_platform() {
    local has_claude=0 has_codex=0
    [ -d "$PROJECT_ROOT/.claude/skills/alex" ] && has_claude=1
    [ -d "$PROJECT_ROOT/.agents/skills/alex" ] && has_codex=1
    if [ "$has_claude" = "1" ] && [ "$has_codex" = "1" ]; then
        echo "both"
    elif [ "$has_claude" = "1" ]; then
        echo "claude-code"
    elif [ "$has_codex" = "1" ]; then
        echo "codex"
    else
        echo "ambiguous"
    fi
}

# ============================================
# Check phase (always read-only)
# ============================================
CURRENT_VERSION=""
REMOTE_VERSION=""
UPDATE_STATE="error"   # newer | equal | older | error

run_check() {
    # Local version — strict semver required.
    if [ ! -f "$PROJECT_ROOT/.tad/version.txt" ]; then
        echo "TAD update check" >&2
        echo "Error: no .tad/version.txt — this project is not TAD-initialized." >&2
        echo "No update was applied." >&2
        exit 1
    fi
    CURRENT_VERSION="$(head -1 "$PROJECT_ROOT/.tad/version.txt" | tr -d '[:space:]')"
    if ! is_semver "$CURRENT_VERSION"; then
        echo "TAD update check" >&2
        echo "Error: local .tad/version.txt is not a strict MAJOR.MINOR.PATCH version (got: '$CURRENT_VERSION')." >&2
        echo "No update was applied." >&2
        exit 1
    fi

    # Remote version — bounded timeout, strict semver, first line only.
    local raw
    raw="$(curl -fsSL --max-time 15 "${VERSION_URL_BASE}/main/.tad/version.txt" 2>/dev/null | head -1 | tr -d '[:space:]')" || true
    if [ -z "$raw" ]; then
        echo "TAD update check" >&2
        echo "Error: could not retrieve the remote version (network failure or timeout)." >&2
        echo "No update was applied." >&2
        exit 1
    fi
    if ! is_semver "$raw"; then
        echo "TAD update check" >&2
        echo "Error: remote version payload is malformed (not strict MAJOR.MINOR.PATCH: '$raw')." >&2
        echo "No update was applied." >&2
        exit 1
    fi
    REMOTE_VERSION="$raw"

    local cmp
    cmp="$(ver_cmp "$REMOTE_VERSION" "$CURRENT_VERSION")"
    if [ "$cmp" = "1" ]; then
        UPDATE_STATE="newer"
    elif [ "$cmp" = "0" ]; then
        UPDATE_STATE="equal"
    else
        UPDATE_STATE="older"
    fi
}

print_check() {
    echo "TAD update check"
    echo "Current: $CURRENT_VERSION"
    echo "Remote:  $REMOTE_VERSION"
    case "$UPDATE_STATE" in
        newer)
            echo "Backup:  .tad.backup.<timestamp-or-unique-suffix>"
            echo "Update available."
            ;;
        equal)
            echo "Already up to date."
            ;;
        older)
            echo "Remote is older than the installed version — downgrade refused."
            ;;
    esac
}

# ============================================
# Main flow
# ============================================
run_check
print_check

case "$UPDATE_STATE" in
    equal)
        exit 0
        ;;
    older)
        exit 1
        ;;
esac

# Update available (state == newer). Determine the apply path.
if [ "$MODE_YES" = "1" ]; then
    # Sole apply mechanism — the caller (skill/command/human) already approved.
    :
elif [ "$MODE_CHECK" = "1" ]; then
    # Explicit read-only check: report and exit without mutating.
    exit 0
elif [ -t 0 ]; then
    # Interactive: prompt once. Default is No.
    echo "Update available. Continue? [y/N]"
    local_reply=""
    read -r -n 1 local_reply || local_reply=""
    echo ""
    case "$local_reply" in
        y|Y) ;;
        *) echo "Declined. No update was applied."; exit 0 ;;
    esac
else
    # No controlling TTY and no explicit --yes: check only, consume nothing.
    echo "confirmation required"
    exit 3
fi

# ── Apply path (external human approval obtained) ──────────────────────
# Platform resolution: explicit wins; otherwise deterministic detection;
# ambiguity at apply time is a hard error (never guess).
platform="$PLATFORM_ARG"
if [ -z "$platform" ]; then
    platform="$(detect_platform)"
    if [ "$platform" = "ambiguous" ]; then
        echo "Error: cannot determine the installed platform (neither .claude/skills/alex nor .agents/skills/alex was found)." >&2
        echo "Re-run with --platform claude-code|codex|both. No update was applied." >&2
        exit 1
    fi
fi

# Private temp installer — download the TAGGED tad.sh matching the version the
# human saw, sanity-check it, then delegate with the pinned contract.
ref="v${REMOTE_VERSION}"
tmp_file=""
# BSD/macOS mktemp substitutes ONLY a trailing XXXXXX — a .sh suffix would make
# it a literal fixed filename (concurrent runs collide; a killed run blocks all
# later runs). Template must END in XXXXXX; bash does not need the extension.
tmp_file="$(mktemp "${TMPDIR:-/tmp}/tad-installer.XXXXXX")"
chmod 700 "$tmp_file"
cleanup_tmp() { rm -f "$tmp_file"; }
trap cleanup_tmp EXIT

if ! curl -fsSL --max-time 60 "${TAG_INSTALLER_URL_BASE}/${ref}/tad.sh" -o "$tmp_file" 2>/dev/null; then
    echo "Error: could not download the tagged installer ${ref}/tad.sh. No update was applied." >&2
    exit 1
fi
if [ ! -s "$tmp_file" ]; then
    echo "Error: downloaded installer is empty. No update was applied." >&2
    exit 1
fi
if ! grep -q "TAD Framework" "$tmp_file" 2>/dev/null; then
    echo "Error: downloaded payload is not recognizable as TAD's Bash installer. No update was applied." >&2
    exit 1
fi

echo "Applying TAD update to v${REMOTE_VERSION} (platform: ${platform})..."
bash "$tmp_file" --release-ref "$ref" --expected-version "$REMOTE_VERSION" --platform "$platform" --yes
rc=$?
exit "$rc"