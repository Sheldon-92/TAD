#!/bin/bash

# TAD updater helper — the SINGLE update orchestration point for the current
# project (Codex skills and the OpenCode command all delegate here).
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
#   - Interpreter: the helper runs the downloaded installer with /bin/bash (else
#     the running interpreter), never a PATH `bash` found first; the installer then
#     pins every nested bash level itself. Call this helper as
#     `/bin/bash .tad/scripts/tad-update.sh` (a Homebrew bash 5.3 can exit 139).
#   - One run updates every platform in the confirmed list: `--platform a,b`.
#   - Held backups (Phase 3): the check lists what the update would clear (the project's own
#     .tad/scripts/tad-backups.sh `clearable`, local code like this helper) and puts `--clear-held <token>` on the
#     To-apply line. With that flag the helper re-checks the token before the installer; only after the installer
#     exits 0 does it run `tad-backups.sh clear --ids-file`. A mismatch or a failed install clears nothing.

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
CLEAR_HELD_ARG=""

usage() {
    cat <<'EOF'
Usage: tad-update.sh [--check] [--yes] [--platform <list>] [--clear-held <token>] [--help]

  --check                read-only check: print current/remote versions and
                         whether an update is available. Never mutates.
  --yes                  apply the update. ONLY after explicit human approval;
                         the helper itself never infers consent.
  --platform <list>      explicit platform(s), comma separated, no spaces, from
                         codex, claude-code, opencode, cursor. The check prints the
                         exact line to run ("To apply:").
  --clear-held <token>   only with --yes: after a successful update, also clear the held
                         backups the check listed ("Will clear:"). The check prints the token.
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
        --clear-held)
            [ -z "${2:-}" ] && echo "tad-update: --clear-held requires a value" >&2 && exit 2
            case "$2" in *[!0-9]*) echo "tad-update: --clear-held takes the numeric token the check printed" >&2; exit 2 ;; esac
            CLEAR_HELD_ARG="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "tad-update: unknown option '$1' (use --help)" >&2; exit 2 ;;
    esac
done

if [ "$MODE_CHECK" = "1" ] && [ "$MODE_YES" = "1" ]; then
    echo "tad-update: --check and --yes are mutually exclusive" >&2
    exit 2
fi

# --platform takes a comma list (no spaces) from the four names; each element is checked
# exactly as one value always was (`both` and every other *claude* spelling are refused),
# duplicates are dropped and the list is kept in canonical order (codex, claude-code,
# opencode, cursor). A single value behaves as before.
PLATFORM_NAMES="codex, claude-code, opencode, cursor"
if [ -n "$PLATFORM_ARG" ]; then
    _bad=0
    case "$PLATFORM_ARG" in ,*|*,|*,,*) _bad=1 ;; esac
    _canon=""
    if [ "$_bad" = "0" ]; then
        _rest="$PLATFORM_ARG,"
        while [ -n "$_rest" ]; do
            _el="${_rest%%,*}"
            _rest="${_rest#*,}"
            case "$_el" in
                codex|claude-code|opencode|cursor) ;;
                *) _bad=1; break ;;
            esac
        done
    fi
    if [ "$_bad" = "1" ]; then
        echo "tad-update: --platform '$PLATFORM_ARG' is not a valid target. Valid for this updater: $PLATFORM_NAMES" >&2
        exit 2
    fi
    for _c in codex claude-code opencode cursor; do
        case ",$PLATFORM_ARG," in
            *",$_c,"*) _canon="${_canon:+$_canon,}$_c" ;;
        esac
    done
    PLATFORM_ARG="$_canon"
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
# All four harnesses (Codex, Claude Code, Cursor, OpenCode) share the .agents/skills tree, so the
# presence of .agents/skills/alex says nothing about which one a project was installed for. This
# function therefore reports only "codex" for it, and nothing else.
# A leftover downstream .claude tree is NEVER auto-deleted and never
# re-detected as an install target (see tad.sh tombstone).
# else → ambiguous/absent (check may report; apply REQUIRES --platform)
# This updater's --platform accepts the four names tad.sh accepts (codex, claude-code, opencode,
# cursor), as a comma list.
# Platform stickiness: for a project installed with --platform claude-code and updated without
# --platform, tad.sh keeps the Claude Code skill links that already exist up to date, but does not
# redo the rest of the Claude Code projection. The check may display claude-code when the
# installer's own claude_projection_present conditions hold; a fact found in the project never
# applies it: only an explicit --platform token on the confirmed To-apply line does.
detect_platform() {
    if [ -d "$PROJECT_ROOT/.agents/skills/alex" ]; then
        echo "codex"
    else
        echo "ambiguous"
    fi
}

# claude_shown — display-only mirror of tad.sh claude_projection_present (the installer's own
# predicate decides what an install does; this only decides whether the check SHOWS claude-code):
# .tad/version.txt and .agents/skills/alex/SKILL.md regular files, .claude and .claude/skills real
# directories (no symlinked parent), .claude/skills/alex the standard link ../../.agents/skills/alex
# or a TAD pointer directory, and either the exact managed BEGIN line in a regular CLAUDE.md or at
# least 3 other TAD-made entries. It never writes and never decides an apply.
claude_entry_tad_made() {
    local _n="$1" _e="$PROJECT_ROOT/.claude/skills/$1"
    if [ -L "$_e" ]; then
        [ "$(readlink "$_e" 2>/dev/null || true)" = "../../.agents/skills/$_n" ]
        return $?
    fi
    if [ -d "$_e" ] && [ ! -L "$_e/SKILL.md" ] && [ -f "$_e/SKILL.md" ]; then
        head -n 40 "$_e/SKILL.md" 2>/dev/null | grep -Fxq -e 'tad_pointer: true'
        return $?
    fi
    return 1
}
claude_shown() {
    local _e _n _c=0
    [ ! -L "$PROJECT_ROOT/.tad" ] && [ ! -L "$PROJECT_ROOT/.tad/version.txt" ] && [ -f "$PROJECT_ROOT/.tad/version.txt" ] || return 1
    [ ! -L "$PROJECT_ROOT/.agents" ] && [ ! -L "$PROJECT_ROOT/.agents/skills" ] && [ ! -L "$PROJECT_ROOT/.agents/skills/alex" ] \
        && [ ! -L "$PROJECT_ROOT/.agents/skills/alex/SKILL.md" ] && [ -f "$PROJECT_ROOT/.agents/skills/alex/SKILL.md" ] || return 1
    [ ! -L "$PROJECT_ROOT/.claude" ] && [ -d "$PROJECT_ROOT/.claude" ] && [ ! -L "$PROJECT_ROOT/.claude/skills" ] && [ -d "$PROJECT_ROOT/.claude/skills" ] || return 1
    claude_entry_tad_made "alex" || return 1
    if [ ! -L "$PROJECT_ROOT/CLAUDE.md" ] && [ -f "$PROJECT_ROOT/CLAUDE.md" ] \
       && grep -Fxq -e '<!-- TAD:AGENTS-REF:BEGIN (managed by tad.sh) -->' "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null; then
        return 0
    fi
    for _e in "$PROJECT_ROOT"/.claude/skills/*; do
        _n="${_e##*/}"
        [ "$_n" != "alex" ] || continue
        if claude_entry_tad_made "$_n"; then
            _c=$((_c + 1))
            if [ "$_c" -ge 3 ]; then return 0; fi
        fi
    done
    return 1
}

# shown_platforms — the list the check displays and the To-apply line carries: the detect_platform
# result plus claude-code iff claude_shown. Empty when nothing is detected.
shown_platforms() {
    local _p
    _p="$(detect_platform)"
    if [ "$_p" = "ambiguous" ]; then return 0; fi
    if claude_shown; then echo "codex,claude-code"; else echo "codex"; fi
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

# clear_info — what a yes would clear: the project's own tad-backups.sh (local code, never the download).
# Absent script or any problem: nothing is offered (CLEAR_N=0).
CLEAR_N=0; CLEAR_KB=0; REVIEW_N=0; CLEAR_TOKEN=""
clear_info() {
    local _tb="$PROJECT_ROOT/.tad/scripts/tad-backups.sh" _out _k _v _bytes=0
    CLEAR_N=0; CLEAR_KB=0; REVIEW_N=0; CLEAR_TOKEN=""
    [ -f "$_tb" ] && [ ! -L "$_tb" ] || return 0
    _out="$(cd "$PROJECT_ROOT" && /bin/bash "$_tb" clearable 2>/dev/null)" || return 0
    while IFS="$(printf '\t')" read -r _k _v; do
        case "$_k" in
            clear_n) case "$_v" in ''|*[!0-9]*) ;; *) CLEAR_N="$_v" ;; esac ;;
            clear_bytes) case "$_v" in ''|*[!0-9]*) ;; *) _bytes="$_v" ;; esac ;;
            review_n) case "$_v" in ''|*[!0-9]*) ;; *) REVIEW_N="$_v" ;; esac ;;
            token) CLEAR_TOKEN="$_v" ;;
        esac
    done <<< "$_out"
    CLEAR_KB=$(( (_bytes + 1023) / 1024 ))
    case "$CLEAR_TOKEN" in ''|*[!0-9]*) CLEAR_N=0 ;; esac
    return 0
}

print_check() {
    echo "TAD update check"
    echo "Current: $CURRENT_VERSION"
    echo "Remote:  $REMOTE_VERSION"
    case "$UPDATE_STATE" in
        newer)
            local _shown _human _settings _flag
            _shown="$(shown_platforms)"
            if [ -z "$_shown" ]; then
                echo "Platforms: not determined (.agents/skills/alex not found)"
            else
                _human="$(printf '%s' "$_shown" | sed 's/,/, /g')"
                echo "Platforms: $_human (OpenCode and Cursor wiring is always refreshed)"
                case ",$_shown," in
                    *",claude-code,"*)
                        if [ -f "$PROJECT_ROOT/.claude/settings.json" ] && [ ! -L "$PROJECT_ROOT/.claude/settings.json" ]; then
                            _settings="present, kept"
                        else
                            _settings="absent, will be created"
                        fi
                        echo "Claude Code: full refresh; .claude/settings.json $_settings; CLAUDE.md @AGENTS.md block appended only to an existing CLAUDE.md"
                        ;;
                esac
            fi
            echo "Changes: only TAD-owned files (AGENTS.md \"File Ownership\"); every existing project file except .git/ and node_modules/ is checked before and after; TAD's areas are listed and their changed files backed up"
            echo "AGENTS.md: replaced by the release copy; a copy that matches no TAD release is first kept as AGENTS.md.pre-tad.<time>"
            echo "Backup: ~/.tad-backups/<project>/<time> (only the files this update changes or removes); older backups move to a holding area and are deleted only with your yes"
            clear_info
            if [ "$CLEAR_N" -gt 0 ]; then
                echo "Will clear: $CLEAR_N held backups ($CLEAR_KB KB): TAD's own files, its reports, files still in your project, or copies already absorbed — deleted after the update succeeds"
            fi
            if [ "$REVIEW_N" -gt 0 ]; then
                echo "Held for review: $REVIEW_N (say \"看备份\")"
            fi
            echo "Update available."
            _flag=""
            if [ "$CLEAR_N" -gt 0 ]; then _flag=" --clear-held $CLEAR_TOKEN"; fi
            if [ -z "$_shown" ]; then
                echo "To apply: /bin/bash .tad/scripts/tad-update.sh --yes --platform <codex,claude-code,opencode,cursor: choose>$_flag"
            else
                echo "To apply: /bin/bash .tad/scripts/tad-update.sh --yes --platform $_shown$_flag"
            fi
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
# The whole flow is one function: the installer this helper runs overwrites .tad/scripts/tad-update.sh
# in place while bash is still reading it, and bash must not read a new file at an old offset after
# the install. A function body and the call line below are parsed before anything runs.
main_flow() {
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
        echo "Error: cannot determine the installed platform (.agents/skills/alex was not found)." >&2
        echo "Re-run with --platform codex. No update was applied." >&2
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
clear_ids=""
cleanup_tmp() { rm -f "$tmp_file"; [ -z "$clear_ids" ] || rm -f "$clear_ids"; }
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

# Interpreter (D1 b): /bin/bash, else the running interpreter; never a PATH `bash`.
installer_bash="/bin/bash"
[ -x "$installer_bash" ] || installer_bash="$BASH"
# Held backups the check listed: re-test the token now (before the installer); clear only after it succeeds.
tadb="$PROJECT_ROOT/.tad/scripts/tad-backups.sh"
if [ -n "$CLEAR_HELD_ARG" ]; then
    if [ -f "$tadb" ] && [ ! -L "$tadb" ]; then
        clear_ids="$(mktemp "${TMPDIR:-/tmp}/tad-clear-ids.XXXXXX")" || clear_ids=""
        if [ -z "$clear_ids" ] || ! (cd "$PROJECT_ROOT" && "$installer_bash" "$tadb" clearable --token "$CLEAR_HELD_ARG" --ids-out "$clear_ids" >/dev/null 2>&1); then
            echo "Held backups changed since the check: nothing will be cleared"
            [ -z "$clear_ids" ] || rm -f "$clear_ids"
            clear_ids=""
        fi
    else
        echo "Held backups cannot be checked here (.tad/scripts/tad-backups.sh is not installed): nothing will be cleared"
    fi
fi
echo "Applying TAD update to v${REMOTE_VERSION} (platform: ${platform})..."
rc=0
"$installer_bash" "$tmp_file" --release-ref "$ref" --expected-version "$REMOTE_VERSION" --platform "$platform" --yes || rc=$?
if [ "$rc" = "0" ] && [ -n "$clear_ids" ]; then
    (cd "$PROJECT_ROOT" && "$installer_bash" "$tadb" clear --ids-file "$clear_ids" --how upgrade --yes) || echo "Held backups: the clear step reported a problem (the update itself is done); run /bin/bash .tad/scripts/tad-backups.sh list"
fi
exit "$rc"
}
main_flow "$@"; exit $?
