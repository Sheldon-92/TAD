#!/bin/bash

# TAD Framework - Unified Install & Upgrade Script v2.3
# Claude Code Support
# One command for all scenarios: fresh install, upgrade, or migration

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Version — fallback only. The AUTHORITATIVE value is derived from the source
# repo's .tad/version.txt at download time (see derive_target_version). This
# literal is a banner/fallback value: the state gate MUST NOT rely on it, because
# the gate runs BEFORE the source is fetched — a stale literal here silently
# freezes downstream upgrades (the 2.19.1-class hand-edit straggler, twice).
# The gate's "already latest" decision is made by probe_remote_version (success)
# or the ROOT FIX block in main() (failure), never from this literal.
# It is used ONLY before the source is fetched (banner) and as a last-resort
# fallback if the source version.txt is unreadable.
TARGET_VERSION="2.43.1"
REPO_URL="https://github.com/Sheldon-92/TAD"
DOWNLOAD_URL="https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz"
VERSION_URL="https://raw.githubusercontent.com/Sheldon-92/TAD/main/.tad/version.txt"

# derive_target_version <src> — set TARGET_VERSION from the source tree's
# .tad/version.txt (authoritative). Keeps the hardcoded literal as fallback.
derive_target_version() {
    local src="$1"
    if [ -f "$src/.tad/version.txt" ]; then
        local v
        v=$(head -1 "$src/.tad/version.txt" | tr -d '[:space:]')
        if [ -n "$v" ]; then
            TARGET_VERSION="$v"
        fi
    fi
}

PROBE_OK=0
# probe_remote_version — 在状态闸之前取得权威版本。成功 → 覆盖 TARGET_VERSION 并置
# PROBE_OK=1；任何失败（网络/超时/非法载荷）→ 两者均不动，PROBE_OK 保持 0。
# 这是 OPTIMIZATION 而非正确性来源：它只为保住「已是最新」的快速退出。正确性由
# main() 里 derive_target_version 之后的权威复判保证（见 M7）。
probe_remote_version() {
    local v
    v=$(curl -sSL --max-time 10 "$VERSION_URL" 2>/dev/null | head -1 | tr -d '[:space:]') || true
    # 载荷必须先验证再采信：404 会返回一整页 HTML，不加这道正则就会把 HTML 当版本号。
    if [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TARGET_VERSION="$v"
        PROBE_OK=1
    fi
}

# Global variables
BACKUP_PATH=""
DETECTED_PLATFORMS=""
RELEASE_REF=""
EXPECTED_VERSION=""
PINNED_MODE=0
# FR-1 --source offline mode (Phase 2 remainder).
# SOURCE_ARG = flag value (--source <dir>); TAD_SOURCE_DIR env fills ONLY when
# flag absent (flag wins, never silent env override — env use is logged).
# SOURCE_MODE=1 iff validated --source effective; TAD_SOURCE_RESOLVED = physical
# resolved source dir (cd && pwd -P); TAD_SRC/DOWNLOADED/TMP_ROOT runtime state.
SOURCE_ARG=""
SOURCE_MODE=0
TAD_SOURCE_RESOLVED=""
TAD_SRC=""
TAD_SRC_DOWNLOADED=0
TAD_TMP_ROOT=""
# F-06 rollback state (absolutized at snapshot time; see take_rollback_snapshot).
TARGET_ROOT=""
BACKUP_PATH_ABS=""
ROLLBACK_SNAP=""
MERGE_CREATED_BACKUP=""
ROLLBACK_CREATED_TOP=""
ROLLBACK_PRE_TOP=""
# Migration snapshot captured once as a UNIQUE path; every later migration read
# and the final report use this same variable (FR-1: never reuse a fixed name
# that a pre-existing recovery copy may already own).
MIGRATE_BACKUP_DIR=""

# ============================================
# FR-1 --source offline mode (Phase 2 remainder)
# ============================================
# --source <dir> = fully-TRUSTED local tree. The installer runs (bash/sources)
# engine scripts from it — never point it at an unreviewed checkout.
# Validation runs at arg-parse time, BEFORE probe/download/trap-arm/backup and
# the first bash/source of anything under the tree. On violation: usage error
# (exit 1) with ZERO mutations (nothing has run yet by construction).
resolve_tmpdir() {
    # Fail-closed to /tmp unless TMPDIR is absolute + existing + writable.
    # Trailing slashes are stripped (this host exports a trailing-slash TMPDIR).
    case "${TMPDIR:-}" in
        /*) if [ -d "$TMPDIR" ] && [ -w "$TMPDIR" ]; then
                local _t="${TMPDIR%/}"
                [ -n "$_t" ] || _t="/tmp"
                printf '%s' "$_t"
                return 0
            fi ;;
    esac
    printf '/tmp'
}

# cleanup_source_tree — the SINGLE chokepoint allowed to remove $TAD_SRC.
# User-supplied --source dirs (TAD_SRC_DOWNLOADED=0) are NEVER removed here:
# the EXIT trap and rollback stay inert for them (FR-1b regression-pinned).
cleanup_source_tree() {
    if [ "${TAD_SRC_DOWNLOADED:-0}" = "1" ] && [ -n "${TAD_SRC:-}" ] && [ -d "${TAD_SRC:-}" ]; then
        rm -rf "$TAD_SRC" # RM-OK:source-chokepoint-downloaded-only
    fi
}

# discard_tmp_root <dir> — guarded removal for mktemp-created pinned/unpinned
# download roots (basename must carry the tad-update. mktemp template).
discard_tmp_root() {
    local _d="${1:-}"
    if [ -n "$_d" ] && [ -d "$_d" ]; then
        case "$(basename "$_d")" in
            tad-update.*) rm -rf "$_d" ;; # RM-OK:pinned-tmp-discard
        esac
    fi
}

# cleanup_installer_temp — EXIT-trap removal of the verified download root's
# parent temp dir (set ONLY by the download paths from mktemp; never user input).
cleanup_installer_temp() {
    local _t="${TAD_TMP_ROOT:-}"
    if [ -n "$_t" ] && [ -d "$_t" ]; then
        case "$(basename "$_t")" in
            tad-update.*) rm -rf "$_t" ;; # RM-OK:installer-tmp-root
        esac
    fi
}

# validate_tar_members <archive> — tar-slip gate for BOTH extract paths.
# Rejects pre-extraction (zero outside writes): absolute members, dot-dot
# members, and symlink/hardlink members whose `->` target escapes
# (absolute or dot-dot). See N5 adjudication (evidence appendix) for the
# `->` predicate rationale + residual.
validate_tar_members() {
    local archive="$1"
    local listing
    listing="$(tar -tzf "$archive" 2>/dev/null)" || { log_error "Downloaded payload is not a valid tar archive — refusing to extract"; return 1; }
    if [ -z "$listing" ]; then
        log_error "Archive member listing is empty — refusing to extract"
        return 1
    fi
    local member
    while IFS= read -r member; do
        [ -n "$member" ] || continue
        case "$member" in
            /*) log_error "tar-slip rejected: absolute member: $member"; return 1 ;;
        esac
        case "$member" in
            ..|../*|*/../*|*/..) log_error "tar-slip rejected: dot-dot member: $member"; return 1 ;;
        esac
    done <<< "$listing"
    local vline linktarget
    # NOTE: the verbose listing is captured ONCE with fail-closed error check
    # (a failed/empty second listing must refuse, never skip the loop into
    # a vacuous PASS). BSD + GNU tar both render symlinks as `-> target` and
    # hardlinks as `link to target` — BOTH forms are checked with identical
    # escaping rules. Filenames containing ` -> ` cannot smuggle an outside
    # write: the worst parse yields a relative target (passes) while the
    # member-name loop above still rejects absolute/dot-dot members, and any
    # absolute/dot-dot fragment from a newline-split name rejects fail-closed.
    local vlisting
    vlisting="$(tar -tvzf "$archive" 2>/dev/null)" || { log_error "Downloaded payload verbose listing failed — refusing to extract"; return 1; }
    if [ -z "$vlisting" ]; then
        log_error "Downloaded payload verbose listing is empty — refusing to extract"
        return 1
    fi
    while IFS= read -r vline; do
        case "$vline" in
            *" -> "*)
                linktarget="${vline##* -> }"
                case "$linktarget" in
                    /*) log_error "tar-slip rejected: escaping link target: $vline"; return 1 ;;
                esac
                case "$linktarget" in
                    ..|../*|*/../*|*/..) log_error "tar-slip rejected: escaping link target: $vline"; return 1 ;;
                esac
                ;;
            *"link to "*)
                linktarget="${vline##*link to }"
                case "$linktarget" in
                    /*) log_error "tar-slip rejected: escaping hardlink target: $vline"; return 1 ;;
                esac
                case "$linktarget" in
                    ..|../*|*/../*|*/..) log_error "tar-slip rejected: escaping hardlink target: $vline"; return 1 ;;
                esac
                ;;
        esac
    done <<< "$vlisting"
    return 0
}

# resolve_source_mode — flag/env resolution + full validation. Called once,
# after the pinned-contract block (mutual exclusion needs PINNED verdicts)
# and before probe/download/trap-arm/backup/first-exec.
resolve_source_mode() {
    # TAD_SOURCE_DIR env fills ONLY when the flag is absent (flag wins);
    # env use is logged, never silent.
    if [ -z "$SOURCE_ARG" ] && [ -n "${TAD_SOURCE_DIR:-}" ]; then
        SOURCE_ARG="$TAD_SOURCE_DIR"
        echo "tad.sh: using source tree from TAD_SOURCE_DIR=$TAD_SOURCE_DIR (flag --source absent; flag wins when both are given)" >&2
    fi
    if [ -z "$SOURCE_ARG" ]; then
        return 0
    fi
    if [ -n "${RELEASE_REF:-}" ] || [ -n "${EXPECTED_VERSION:-}" ]; then
        echo "tad.sh: --source is mutually exclusive with --release-ref/--expected-version" >&2
        exit 1
    fi
    if [ -L "$SOURCE_ARG" ]; then
        echo "tad.sh: --source must not be a symlink: $SOURCE_ARG" >&2
        exit 1
    fi
    if [ ! -d "$SOURCE_ARG" ]; then
        echo "tad.sh: --source is not a directory: $SOURCE_ARG" >&2
        exit 1
    fi
    TAD_SOURCE_RESOLVED="$(cd "$SOURCE_ARG" && pwd -P)" || { echo "tad.sh: --source cannot be physically resolved: $SOURCE_ARG" >&2; exit 1; }
    local _s
    for _s in tad.sh .tad .claude .agents; do
        if [ ! -e "$TAD_SOURCE_RESOLVED/$_s" ]; then
            echo "tad.sh: --source tree is missing sentinel '$_s': $TAD_SOURCE_RESOLVED" >&2
            exit 1
        fi
    done
    local _target_phys _lsrc _ltgt
    _target_phys="$(pwd -P)" || { echo "tad.sh: cannot resolve target directory" >&2; exit 1; }
    # Case-normalised compare (APFS case-aliases); residual: exotic
    # Unicode-normalisation aliases are NOT folded — documented, not silent.
    _lsrc="$(printf '%s' "$TAD_SOURCE_RESOLVED" | tr '[:upper:]' '[:lower:]')"
    _ltgt="$(printf '%s' "$_target_phys" | tr '[:upper:]' '[:lower:]')"
    if [ "$_lsrc" = "$_ltgt" ]; then
        echo "tad.sh: --source == target (post-resolution): $TAD_SOURCE_RESOLVED" >&2
        exit 1
    fi
    case "$_lsrc/" in
        "$_ltgt"/*)
            echo "tad.sh: target is inside --source (self-nesting refused): target=$_target_phys source=$TAD_SOURCE_RESOLVED" >&2
            exit 1
            ;;
    esac
    case "$_ltgt/" in
        "$_lsrc"/*)
            echo "tad.sh: --source is inside target (self-nesting refused): target=$_target_phys source=$TAD_SOURCE_RESOLVED" >&2
            exit 1
            ;;
    esac
    SOURCE_MODE=1
    TAD_SRC="$TAD_SOURCE_RESOLVED"
    TAD_SRC_DOWNLOADED=0
    derive_target_version "$TAD_SRC"
}

# Argument parsing — while-loop + shift (supports --key value two-token args).
# --yes/-y skips the interactive confirmation prompt (non-TTY: Claude Code Bash,
# CI, curl|bash). "$@" is set -u-safe even with zero args.
AUTO_YES=0
VERIFY_DENYLIST=0
FORCE=0
PLATFORM=""
PACKS=""
RESOLVE_STRATEGY=""
FORK_PACK=""
UNFORK_PACK=""
LIST_PACKS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y)  AUTO_YES=1; shift ;;
    --force)   FORCE=1; shift ;;
    --verify-denylist) VERIFY_DENYLIST=1; shift ;;
    --platform)
      [ -z "${2:-}" ] && echo "tad.sh: --platform requires a value" >&2 && exit 1
      PLATFORM="$2"; shift 2 ;;
    --packs)
      [ -z "${2:-}" ] && echo "tad.sh: --packs requires a value" >&2 && exit 1
      PACKS="$2"; shift 2 ;;
    --resolve=*) RESOLVE_STRATEGY="${1#--resolve=}"; shift ;;
    --fork-pack)
      [ -z "${2:-}" ] && echo "tad.sh: --fork-pack requires a pack name" >&2 && exit 1
      FORK_PACK="$2"; shift 2 ;;
    --unfork-pack)
      [ -z "${2:-}" ] && echo "tad.sh: --unfork-pack requires a pack name" >&2 && exit 1
      UNFORK_PACK="$2"; shift 2 ;;
    --list-packs) LIST_PACKS=1; shift ;;
    --release-ref)
      [ -z "${2:-}" ] && echo "tad.sh: --release-ref requires a value" >&2 && exit 1
      RELEASE_REF="$2"; shift 2 ;;
    --source)
      [ -z "${2:-}" ] && echo "tad.sh: --source requires a value" >&2 && exit 1
      SOURCE_ARG="$2"; shift 2 ;;
    --source=*)
      [ -z "${1#--source=}" ] && echo "tad.sh: --source requires a value" >&2 && exit 1
      SOURCE_ARG="${1#--source=}"; shift ;;
    --expected-version)
      [ -z "${2:-}" ] && echo "tad.sh: --expected-version requires a value" >&2 && exit 1
      EXPECTED_VERSION="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: tad.sh [--yes|-y] [--force] [--platform <name>] [--packs <list>] [--resolve=MODE] [--verify-denylist]"
      echo "       tad.sh --fork-pack <name> | --unfork-pack <name> | --list-packs"
      echo "       tad.sh --release-ref vX.Y.Z --expected-version X.Y.Z [--yes]  (pinned update)"
      echo "       tad.sh --source <dir> [--platform <name>] --yes  (offline install from local tree)"
      echo "  --yes              skip the interactive confirmation prompt"
      echo "  --force            reinstall even if already on the same version"
      echo "  --platform <name>  target platform (claude-code, codex, both). Default: both"
      echo "  --packs <list>     comma-separated pack names to install (default: all)"
      echo "  --resolve=MODE     conflict strategy: local (keep yours), upstream (take new), ask (interactive)"
      echo "                     default: ask, or local with --yes"
      echo "  --fork-pack <name> mark a pack as forked (skipped on future installs)"
      echo "  --unfork-pack <name> unmark a forked pack (follows upstream again)"
      echo "  --list-packs       show all installed packs with sync status"
      echo "  --verify-denylist  (TAD repo only) assert tad.sh's inlined DENY_LIST == derive-sync-set.sh"
      echo "  --release-ref/--expected-version  pinned immutable-tag update (must be a matching pair)"
      echo "  --source <dir>     offline source tree (fully-TRUSTED: the installer runs engine scripts"
      echo "                     from it — never point at unreviewed checkouts). Bypasses the network"
      echo "                     download + version probe; TAD_SOURCE_DIR env fills ONLY when the flag is"
      echo "                     absent (flag wins). Mutually exclusive with --release-ref."
      exit 0 ;;
    *) echo "tad.sh: unknown option '$1' (use --help)" >&2; exit 1 ;;
  esac
done

# ============================================
# Pinned release contract validation (FR-2)
# ============================================
# --release-ref and --expected-version must be a matching pair: the ref is the
# immutable GitHub tag archive selector, the expected version is the strict
# SemVer that the downloaded source's .tad/version.txt MUST equal. Neither may
# appear alone. Strict syntax only — no version-prefix or ref-prefix guessing.
# Pinned mode never calls probe_remote_version; the mutable-main target is
# deliberately not consumed (a main that advertises a different version must
# not leak into the decision).
PINNED_MODE=0
if [ -n "${RELEASE_REF:-}" ] || [ -n "${EXPECTED_VERSION:-}" ]; then
    if [ -z "${RELEASE_REF:-}" ] || [ -z "${EXPECTED_VERSION:-}" ]; then
        echo "tad.sh: --release-ref and --expected-version must be provided as a matching pair" >&2
        exit 1
    fi
    case "$RELEASE_REF" in
        v[0-9]*.[0-9]*.[0-9]*)
            if [[ ! "$RELEASE_REF" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "tad.sh: --release-ref must be strict vMAJOR.MINOR.PATCH (got: $RELEASE_REF)" >&2
                exit 1
            fi ;;
        *) echo "tad.sh: --release-ref must be strict vMAJOR.MINOR.PATCH (got: $RELEASE_REF)" >&2; exit 1 ;;
    esac
    case "$EXPECTED_VERSION" in
        [0-9]*.[0-9]*.[0-9]*)
            if [[ ! "$EXPECTED_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "tad.sh: --expected-version must be strict MAJOR.MINOR.PATCH (got: $EXPECTED_VERSION)" >&2
                exit 1
            fi ;;
        *) echo "tad.sh: --expected-version must be strict MAJOR.MINOR.PATCH (got: $EXPECTED_VERSION)" >&2; exit 1 ;;
    esac
    if [ "v${EXPECTED_VERSION}" != "$RELEASE_REF" ]; then
        echo "tad.sh: --release-ref and --expected-version mismatch (v${EXPECTED_VERSION} != $RELEASE_REF)" >&2
        exit 1
    fi
    PINNED_MODE=1
fi

# Validate --resolve parameter
if [ -n "$RESOLVE_STRATEGY" ]; then
    case "$RESOLVE_STRATEGY" in
        local|upstream|ask) ;;
        *) echo "tad.sh: --resolve must be local, upstream, or ask" >&2; exit 1 ;;
    esac
fi

# FR-1 --source resolution: flag/env + full trust validation, at arg-parse
# time — BEFORE probe, download, trap-arm side effects, backup, and the first
# bash/source of anything under the tree. Usage-error exits here leave ZERO
# mutations (nothing has run yet by construction).
resolve_source_mode

# ============================================
# Logging Functions
# ============================================
log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

log_warn() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

log_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# ============================================
# Phase 1: Environment Validation
# ============================================
validate_environment() {
    log_info "Validating environment..."

    # Check bash version
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        log_warn "Bash 4+ recommended, current: $BASH_VERSION"
    fi

    # Check required tools
    for cmd in grep sed curl tar; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    log_success "Environment validated"
}

# ============================================
# Phase 2: Backup Existing Config
# ============================================
backup_existing() {
    # Unique destination: same-second reruns must never overwrite or nest into
    # an existing backup (FR-1). Suffix increments until a free name is found.
    local base=".tad.backup.$(date +%Y%m%d_%H%M%S)"
    local backup_dir="$base"
    local n=1
    while [ -e "$backup_dir" ]; do
        backup_dir="${base}.$n"
        n=$((n + 1))
    done

    if [ -d ".tad" ]; then
        log_info "Backing up existing .tad/ to $backup_dir"
        # Uppercase -R: on BSD/macOS, lowercase -r dereferences a dangling
        # symlink and fails under set -e (the reported helpers/node_modules
        # case). -R preserves the link and succeeds. The backup is user-owned
        # project data; a failed backup MUST abort before any mutation.
        cp -R .tad "$backup_dir"
        BACKUP_PATH="$backup_dir"
    fi
}

# ============================================
# Phase 3: Platform Detection & Validation
# ============================================
# Valid platforms are read from platform-codes.yaml AFTER download. At parse time
# (before source exists), we validate only against a static known set. This avoids
# the ordering problem (detect runs before download on a fresh machine).
# ⚠️ DRIFT: must match platforms: keys in .tad/platform-codes.yaml. Adding a new
# platform requires updating BOTH this list AND platform-codes.yaml.
# Future: release-verify.sh could add a --verify-platforms check.
KNOWN_PLATFORMS="claude-code codex both"

validate_platform() {
    local p="$1"
    local found=0
    for known in $KNOWN_PLATFORMS; do
        [ "$known" = "$p" ] && found=1 && break
    done
    if [ "$found" = "0" ]; then
        log_error "Unknown platform: '$p'. Valid platforms: $KNOWN_PLATFORMS"
        exit 1
    fi
}

resolve_platform() {
    if [ -n "$PLATFORM" ]; then
        validate_platform "$PLATFORM"
        log_info "Platform (explicit): $PLATFORM"
    else
        PLATFORM="both"
        log_info "No platform specified. Using default platform: both (Claude Code + Codex)"
    fi
}

# ============================================
# Deny-list derivation — INLINED copy of derive-sync-set.sh
# ============================================
# tad.sh runs via `curl | bash` on a FRESH machine where .tad/hooks/lib/ does
# NOT yet exist, so it CANNOT `source` derive-sync-set.sh. The derivation is
# therefore EMBEDDED here verbatim (per the lib's "P2 embeddability" note).
#
# ⚠️ MUST stay == derive-sync-set.sh DENY_LIST — drift-checked at release
#    (P2 AC: `bash tad.sh --verify-denylist`, run from the TAD repo, NOT at
#    install time). If you edit DENY_LIST in either file, edit BOTH or the
#    drift-check FAILS the release.
#
# SYNC_DIRS = { ls -d .tad/*/ } - DENY_LIST  → a new framework dir auto-copies.
# ─────────────────────────────────────────────────────────────────────────────
# Category A — zero-touch (preserve each target's own copy; NEVER sync):
TAD_ZERO_TOUCH="project-knowledge
active
archive
evidence
pair-testing
decisions
dependencies
github-registry
research-notebooks
skill-library
skillify-candidates
memory"
# Category C — transient / main-only (do NOT sync; not part of framework surface):
TAD_TRANSIENT="working
spike-v3
reports
checklists
domains"
# DENY_LIST = A ∪ C (the full set excluded from SYNC).
TAD_DENY_LIST="$TAD_ZERO_TOUCH
$TAD_TRANSIENT"
# Top-level deny (a FILE, not a dir):
TAD_TOP_DENY="sync-registry.yaml"
# The ONE dir with a sub-path rule: sync ONLY its registry index, never the tree.
TAD_REGISTRY_ONLY="capability-packs"
TAD_REGISTRY_FILE="pack-registry.yaml"

# derive_framework_dirs <src> — emit one SYNC dir basename per line
# (live .tad/ dirs MINUS the deny-list), LC_ALL=C sorted. Mirrors
# derive-sync-set.sh emit_dirs() exactly.
# (`|| true` keeps the pipeline rc=0 even when the grep -vxE filter matches
#  nothing — a source with only deny-listed dirs would otherwise return 1
#  under pipefail; harmless in the here-string loops but unsafe in if/pipe.)
derive_framework_dirs() {
    local src="$1"
    local deny_re
    deny_re="$(printf '%s' "$TAD_DENY_LIST" | LC_ALL=C sort -u | paste -sd '|' -)"
    ls -d "$src"/.tad/*/ 2>/dev/null \
        | sed 's|.*/\.tad/||;s|/$||' \
        | { grep -vxE "$deny_re" || true; } \
        | LC_ALL=C sort
}

# derive_framework_top_files <src> — emit one top-level .tad/ FILE basename per
# line (every regular file directly under $src/.tad/ MINUS the top-level deny-set),
# LC_ALL=C sorted. DENY-LIST derived, NOT an extension allow-list — a new top-level
# framework file of ANY extension (.sh/.json/.yaml/.md/…) is auto-copied. This
# kills the 2nd surviving hardcoded list (the old `*.yaml *.md *.txt` glob that
# silently dropped .tad/portable-extract.sh). TAD_TOP_DENY = the only excluded file.
derive_framework_top_files() {
    local src="$1"
    local f bn
    for f in "$src"/.tad/*; do
        [ -f "$f" ] || continue
        bn="$(basename "$f")"
        [ "$bn" = "$TAD_TOP_DENY" ] && continue
        printf '%s\n' "$bn"
    done | LC_ALL=C sort
}

# ============================================
# Platform-aware helpers (simple YAML parsing — no yq dependency)
# ============================================

# parse_platform_extra_deny <yaml_file> <platform> — emit extra_deny paths, one per line
parse_platform_extra_deny() {
    local yaml="$1" plat="$2"
    local in_platform=0 in_deny=0
    while IFS= read -r line; do
        if printf '%s' "$line" | grep -qE "^  ${plat}:"; then
            in_platform=1; in_deny=0; continue
        fi
        if [ "$in_platform" = "1" ] && printf '%s' "$line" | grep -qE '^  [a-z]'; then
            in_platform=0; in_deny=0; continue
        fi
        if [ "$in_platform" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+extra_deny:'; then
            if printf '%s' "$line" | grep -qE '\[\]'; then
                in_deny=0; continue
            fi
            in_deny=1; continue
        fi
        if [ "$in_platform" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+extra_root_files:'; then
            in_deny=0; continue
        fi
        if [ "$in_platform" = "1" ] && [ "$in_deny" = "1" ]; then
            if printf '%s' "$line" | grep -qE '^[[:space:]]+-[[:space:]]+'; then
                printf '%s\n' "$line" | sed -E 's/^[[:space:]]+-[[:space:]]+"?//;s/"?[[:space:]]*$//'
            fi
        fi
    done < "$yaml"
}

# parse_platform_root_files <yaml_file> <platform> — emit extra_root_files, one per line
parse_platform_root_files() {
    local yaml="$1" plat="$2"
    local in_platform=0 in_root=0
    while IFS= read -r line; do
        if printf '%s' "$line" | grep -qE "^  ${plat}:"; then
            in_platform=1; in_root=0; continue
        fi
        if [ "$in_platform" = "1" ] && printf '%s' "$line" | grep -qE '^  [a-z]'; then
            in_platform=0; in_root=0; continue
        fi
        if [ "$in_platform" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+extra_root_files:'; then
            if printf '%s' "$line" | grep -qE '\[\]'; then
                in_root=0; continue
            fi
            in_root=1; continue
        fi
        if [ "$in_platform" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+extra_deny:'; then
            in_root=0; continue
        fi
        if [ "$in_platform" = "1" ] && [ "$in_root" = "1" ]; then
            if printf '%s' "$line" | grep -qE '^[[:space:]]+-[[:space:]]+'; then
                printf '%s\n' "$line" | sed -E 's/^[[:space:]]+-[[:space:]]+"?//;s/"?[[:space:]]*$//'
            fi
        fi
    done < "$yaml"
}

# is_denied <path> <deny_list_newline_separated> — return 0 if path matches any deny entry
is_denied() {
    local path="$1" deny_list="$2"
    [ -z "$deny_list" ] && return 1
    local entry
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        # Exact match or directory-boundary prefix match (prevents .../alex matching .../alex-utils)
        if [ "$path" = "$entry" ] || [ "${path#"${entry}/"}" != "$path" ]; then
            return 0
        fi
    done <<< "$deny_list"
    return 1
}

# is_pack_skill <skill_name> <src> — return 0 if this skill comes from a capability pack
is_pack_skill() {
    local name="$1" src="$2"
    # A skill is a "pack skill" if it has a matching entry in pack-registry.yaml
    # Uses grep -F (fixed string) to avoid regex injection from directory names
    if [ -f "$src/.tad/capability-packs/pack-registry.yaml" ]; then
        grep -qF "name: \"${name}\"" "$src/.tad/capability-packs/pack-registry.yaml" 2>/dev/null
        return $?
    fi
    return 1
}

# generate_pack_meta <tgt_dir> [<src_dir>] — write .tad-pack-meta.yaml with SHA-256 hashes
# When src_dir is provided, list and hash files from src_dir (upstream) instead of tgt_dir.
# This ensures the meta records upstream content hashes, so customized target files are
# correctly detected as modified on subsequent installs.
generate_pack_meta() {
    local skill_dir="$1"
    local hash_dir="${2:-$skill_dir}"
    skill_dir="${skill_dir%/}"
    hash_dir="${hash_dir%/}"
    local meta_file="$skill_dir/.tad-pack-meta.yaml"
    local version="$TARGET_VERSION"
    local today
    today="$(date +%Y-%m-%d)"

    local sha_cmd
    if command -v shasum >/dev/null 2>&1; then
        sha_cmd="shasum -a 256"
    else
        sha_cmd="sha256sum"
    fi

    local existing_policy="upstream"
    local existing_baseline="fresh_install"
    if [ -f "$meta_file" ]; then
        local ep
        ep="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
        [ -n "$ep" ] && existing_policy="$ep"
    else
        existing_baseline="migrated"
    fi

    {
        printf '# Auto-generated by tad.sh — do not edit manually\n'
        printf 'installed_version: "%s"\n' "$version"
        printf 'installed_date: "%s"\n' "$today"
        printf 'sync_policy: %s\n' "$existing_policy"
        printf 'baseline_source: %s\n' "$existing_baseline"
        printf 'files:\n'
        find "$hash_dir" -type f -not -name '.tad-pack-meta.yaml' -not -path '*/local/*' | sort | while read -r f; do
            local rel
            rel="${f#"$hash_dir"/}"
            local hash
            hash="$($sha_cmd "$f" 2>/dev/null | cut -d' ' -f1)" || continue
            printf '  - path: "%s"\n' "$rel"
            printf '    sha256: "%s"\n' "$hash"
        done
    } > "$meta_file"
}

# resolve_conflict <skill_name> <rel> <tgt_file> <src_file> — handle three-way conflict
# Modifies caller's local: modified, updated. Requires PACK_STATS_CONFLICTS in outer scope.
resolve_conflict() {
    local skill_name="$1" rel="$2" tgt_file="$3" src_file="$4"
    PACK_STATS_CONFLICTS=$((PACK_STATS_CONFLICTS + 1))

    local strategy="$RESOLVE_STRATEGY"
    if [ -z "$strategy" ] && [ "$AUTO_YES" = "1" ]; then
        strategy="local"
    fi

    case "$strategy" in
        local)
            log_warn "    $skill_name/$rel: CONFLICT (both changed, local preserved)"
            modified=$((modified + 1))
            ;;
        upstream)
            cp "$tgt_file" "$tgt_file.tad-conflict-backup" 2>/dev/null || true
            log_warn "    $skill_name/$rel: CONFLICT (both changed, upstream applied; backup: ${rel}.tad-conflict-backup)"
            cp "$src_file" "$tgt_file"
            updated=$((updated + 1))
            ;;
        *)
            log_warn "    $skill_name/$rel: CONFLICT — both local and upstream changed"
            echo "    --- diff (first 30 lines) ---"
            diff -u --label "LOCAL: $skill_name/$rel" --label "UPSTREAM: $skill_name/$rel" \
                "$tgt_file" "$src_file" 2>/dev/null | head -30 || true
            echo "    ---"
            local choice=""
            read -p "    Keep YOUR version (l) / Use NEW upstream (u) / Full diff (d)? [l]: " choice </dev/tty 2>/dev/null || { choice="l"; log_warn "    (non-TTY: defaulting to local)"; }
            case "$choice" in
                u|U)
                    cp "$tgt_file" "$tgt_file.tad-conflict-backup" 2>/dev/null || true
                    cp "$src_file" "$tgt_file"
                    updated=$((updated + 1))
                    log_info "    (backup saved: ${rel}.tad-conflict-backup)"
                    ;;
                d|D)
                    diff -u --label "LOCAL: $skill_name/$rel" --label "UPSTREAM: $skill_name/$rel" \
                        "$tgt_file" "$src_file" 2>/dev/null || true
                    echo "    File: $skill_name/$rel"
                    local choice2=""
                    read -p "    Keep YOUR version (l) / Use NEW upstream (u)? [l]: " choice2 </dev/tty 2>/dev/null || { choice2="l"; log_warn "    (non-TTY: defaulting to local)"; }
                    if [ "$choice2" = "u" ] || [ "$choice2" = "U" ]; then
                        cp "$tgt_file" "$tgt_file.tad-conflict-backup" 2>/dev/null || true
                        cp "$src_file" "$tgt_file"
                        updated=$((updated + 1))
                        log_info "    (backup saved: ${rel}.tad-conflict-backup)"
                    else
                        modified=$((modified + 1))
                    fi
                    ;;
                *)
                    modified=$((modified + 1))
                    ;;
            esac
            ;;
    esac
}

# resolve_pack_dir <name> — find the skill dir across both platforms
resolve_pack_dir() {
    local name="$1"
    if [ -d ".claude/skills/$name" ]; then echo ".claude/skills/$name"
    elif [ -d ".agents/skills/$name" ]; then echo ".agents/skills/$name"
    else return 1
    fi
}

# fork_pack <name> — mark a pack as forked (skipped on future installs)
fork_pack() {
    local name="$1"
    case "$name" in */*|..|.) echo "tad.sh: invalid pack name '$name'" >&2; exit 1 ;; esac

    local skill_dir
    skill_dir="$(resolve_pack_dir "$name")" || {
        echo "tad.sh: pack '$name' not found in .claude/skills/ or .agents/skills/" >&2; exit 1
    }
    local meta_file="$skill_dir/.tad-pack-meta.yaml"

    if [ ! -f "$meta_file" ]; then
        echo "tad.sh: no meta file for '$name'. Run 'tad.sh --yes' first to generate baseline." >&2; exit 1
    fi

    local current
    current="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
    if [ "$current" = "forked" ]; then
        echo "'$name' is already forked"; exit 0
    fi

    sed -i.bak "s/^sync_policy:.*/sync_policy: forked/" "$meta_file" && rm -f "$meta_file.bak" # RM-OK:fork-sed-bak
    echo "✓ '$name' forked — will be skipped on future installs"
}

# unfork_pack <name> — restore a forked pack to upstream
unfork_pack() {
    local name="$1"
    case "$name" in */*|..|.) echo "tad.sh: invalid pack name '$name'" >&2; exit 1 ;; esac

    local skill_dir
    skill_dir="$(resolve_pack_dir "$name")" || {
        echo "tad.sh: pack '$name' not found in .claude/skills/ or .agents/skills/" >&2; exit 1
    }
    local meta_file="$skill_dir/.tad-pack-meta.yaml"

    if [ ! -f "$meta_file" ]; then
        echo "tad.sh: no meta file for '$name'." >&2; exit 1
    fi

    local current
    current="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
    if [ "$current" != "forked" ]; then
        echo "'$name' is not forked (current: ${current:-upstream})"; exit 0
    fi

    sed -i.bak "s/^sync_policy:.*/sync_policy: upstream/" "$meta_file" && rm -f "$meta_file.bak" # RM-OK:unfork-sed-bak
    echo "✓ '$name' unforked — will follow upstream on next install"
}

# list_packs — show all installed packs with sync status
list_packs() {
    local skill_base=".claude/skills"
    [ ! -d "$skill_base" ] && skill_base=".agents/skills"
    [ ! -d "$skill_base" ] && echo "No .claude/skills/ or .agents/skills/ directory found" >&2 && exit 1

    printf '%-24s %-11s %-15s %s\n' "Pack" "Policy" "Baseline" "Files"
    printf '%.0s─' {1..60}; echo

    local total=0 forked_count=0
    local sd
    for sd in "$skill_base"/*/; do
        [ -d "$sd" ] || continue
        local name
        name="$(basename "$sd")"
        local meta="$sd/.tad-pack-meta.yaml"
        [ ! -f "$meta" ] && [ ! -f ".tad/capability-packs/pack-registry.yaml" ] && continue
        if [ -f ".tad/capability-packs/pack-registry.yaml" ]; then
            grep -qF "name: \"${name}\"" ".tad/capability-packs/pack-registry.yaml" 2>/dev/null || continue
        elif [ ! -f "$meta" ]; then
            continue
        fi

        total=$((total + 1))
        local policy="—" baseline="—" file_count="—"
        if [ -f "$meta" ]; then
            policy="$(grep '^sync_policy:' "$meta" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
            [ -z "$policy" ] && policy="upstream"
            baseline="$(grep '^baseline_source:' "$meta" 2>/dev/null | sed 's/baseline_source:[[:space:]]*//' | tr -d '[:space:]"')"
            [ -z "$baseline" ] && baseline="—"
            file_count="$(grep -c '^  - path:' "$meta" 2>/dev/null)" || file_count=0
            [ "$policy" = "forked" ] && forked_count=$((forked_count + 1))
        else
            policy="no meta"
        fi
        printf '%-24s %-11s %-15s %s\n' "$name" "$policy" "$baseline" "$file_count"
    done

    printf '%.0s─' {1..60}; echo
    local upstream_count=$((total - forked_count))
    echo "$total packs ($upstream_count upstream, $forked_count forked)"
}

# copy_pack_skill_smart <src_dir> <tgt_dir> — smart copy: compare hashes, skip customized files
# Requires PACK_STATS_* counters declared as local in the caller (bash dynamic scoping).
copy_pack_skill_smart() {
    local src_dir="$1" tgt_dir="$2"
    src_dir="${src_dir%/}"
    local skill_name
    skill_name="$(basename "$src_dir")"
    local meta_file="$tgt_dir/.tad-pack-meta.yaml"

    # Case 1a: No target dir → first install
    if [ ! -d "$tgt_dir" ]; then
        cp -r "$src_dir" "$tgt_dir"
        PACK_STATS_NEW=$((PACK_STATS_NEW + 1))
        return 0
    fi
    # Case 1b: Target exists but no meta → pre-Phase-1 install, content copy
    if [ ! -f "$meta_file" ]; then
        cp -R "$src_dir/." "$tgt_dir/"
        PACK_STATS_NEW=$((PACK_STATS_NEW + 1))
        return 0
    fi

    local policy baseline
    policy="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
    baseline="$(grep '^baseline_source:' "$meta_file" 2>/dev/null | sed 's/baseline_source:[[:space:]]*//' | tr -d '[:space:]"')"

    # Case 2: Forked → skip entirely
    if [ "$policy" = "forked" ]; then
        PACK_STATS_FORKED=$((PACK_STATS_FORKED + 1))
        log_info "    $skill_name: forked (skipped)"
        return 0
    fi

    # Case 3: Migrated → only add new files, never overwrite
    if [ "$baseline" = "migrated" ]; then
        local src_file
        while IFS= read -r src_file; do
            [ -n "$src_file" ] || continue
            local rel
            rel="${src_file#"$src_dir"/}"
            if [ ! -f "$tgt_dir/$rel" ]; then
                mkdir -p "$(dirname "$tgt_dir/$rel")"
                cp "$src_file" "$tgt_dir/$rel"
            fi
        done <<< "$(find "$src_dir" -type f -not -name '.tad-pack-meta.yaml' -not -path '*/local/*')"
        PACK_STATS_MIGRATED=$((PACK_STATS_MIGRATED + 1))
        return 0
    fi

    # Case 4: fresh_install → per-file hash comparison
    local sha_cmd
    if command -v shasum >/dev/null 2>&1; then
        sha_cmd="shasum -a 256"
    else
        sha_cmd="sha256sum"
    fi

    local modified=0 updated=0
    local src_file
    while IFS= read -r src_file; do
        [ -n "$src_file" ] || continue
        local rel
        rel="${src_file#"$src_dir"/}"

        # New upstream file (not in target) → install
        if [ ! -f "$tgt_dir/$rel" ]; then
            mkdir -p "$(dirname "$tgt_dir/$rel")"
            cp "$src_file" "$tgt_dir/$rel"
            updated=$((updated + 1))
            continue
        fi

        # Look up installed hash from meta
        local installed_hash
        installed_hash="$(awk -v p="$rel" '
            index($0, "path: \""p"\"") > 0 {found=1; next}
            found && /sha256:/ {gsub(/.*sha256:[[:space:]]*"|"/, ""); print; exit}
        ' "$meta_file")"

        # No hash in meta → treat as customized (unknown state)
        if [ -z "$installed_hash" ]; then
            modified=$((modified + 1))
            continue
        fi

        # Compare current target hash with meta's recorded hash
        local current_hash
        current_hash="$($sha_cmd "$tgt_dir/$rel" 2>/dev/null | cut -d' ' -f1)" || continue

        if [ "$current_hash" = "$installed_hash" ]; then
            # Pristine → safe to overwrite
            cp "$src_file" "$tgt_dir/$rel"
            updated=$((updated + 1))
        else
            # Local was modified. Check if upstream also changed.
            local source_hash
            source_hash="$($sha_cmd "$src_file" 2>/dev/null | cut -d' ' -f1)" || { log_warn "    $skill_name/$rel: hash failed, preserving local"; modified=$((modified + 1)); continue; }

            if [ "$source_hash" = "$installed_hash" ]; then
                # Only local changed → preserve (Phase 2 behavior)
                modified=$((modified + 1))
                log_warn "    $skill_name/$rel: customized (preserved)"
            else
                # CONFLICT: both local AND upstream changed
                resolve_conflict "$skill_name" "$rel" "$tgt_dir/$rel" "$src_file"
            fi
        fi
    done <<< "$(find "$src_dir" -type f -not -name '.tad-pack-meta.yaml' -not -path '*/local/*')"

    if [ "$modified" -gt 0 ]; then
        PACK_STATS_CUSTOMIZED=$((PACK_STATS_CUSTOMIZED + 1))
    else
        PACK_STATS_UPDATED=$((PACK_STATS_UPDATED + 1))
    fi
}

# is_selected_pack <name> — return 0 if name is in the comma-separated PACKS list
is_selected_pack() {
    local name="$1"
    local IFS=','
    local p
    for p in $PACKS; do
        [ "$p" = "$name" ] && return 0
    done
    return 1
}

# verify_denylist_drift — release-time drift check (run from the TAD repo via
# `bash tad.sh --verify-denylist`). Asserts tad.sh's INLINED DENY_LIST is
# byte-identical (as a sorted set) to derive-sync-set.sh's authoritative one.
# Prevents the two copies from silently diverging (the stale-list disease at the
# installer). Exit 0 == in sync; exit 1 == DRIFT (fail the release). This is NOT
# run on a fresh install — only when the lib is present (TAD repo / dev tree).
verify_denylist_drift() {
    local lib=".tad/hooks/lib/derive-sync-set.sh"
    if [ ! -f "$lib" ]; then
        # Try alongside this script (when run from a checkout root).
        local self_dir
        self_dir="$(cd "$(dirname "$0")" && pwd)"
        lib="$self_dir/.tad/hooks/lib/derive-sync-set.sh"
    fi
    if [ ! -f "$lib" ]; then
        log_error "--verify-denylist: derive-sync-set.sh not found (run from the TAD repo root)"
        return 2
    fi

    # tad.sh's inlined DENY_LIST as a sorted set.
    local here_set lib_set
    here_set="$(printf '%s' "$TAD_DENY_LIST" | LC_ALL=C sort -u)"
    # The lib's DENY_LIST = --zero-touch ∪ --transient. Reconstruct it off the lib's
    # PUBLIC FLAG INTERFACE (cr-P1-1) rather than awk-scraping internal variable
    # names — a benign lib refactor (rename ZERO_TOUCH/TRANSIENT, fold lists, switch
    # quoting) no longer silently breaks the drift-check. The lib runs from its own
    # checkout dir; pass that as the root so its `.tad` existence guard is satisfied.
    local lib_root
    lib_root="$(cd "$(dirname "$lib")/../../.." && pwd)"
    lib_set="$(
        { bash "$lib" --zero-touch "$lib_root"
          bash "$lib" --transient "$lib_root"
        } | LC_ALL=C sort -u
    )"

    if [ "$here_set" = "$lib_set" ]; then
        log_success "--verify-denylist: tad.sh inlined DENY_LIST == derive-sync-set.sh ($(printf '%s\n' "$here_set" | grep -c . ) entries)"
        return 0
    else
        log_error "--verify-denylist: DRIFT detected between tad.sh and derive-sync-set.sh"
        echo "  --- only in tad.sh ---"  >&2
        LC_ALL=C comm -23 <(printf '%s\n' "$here_set") <(printf '%s\n' "$lib_set") | sed 's/^/    /' >&2
        echo "  --- only in derive-sync-set.sh ---" >&2
        LC_ALL=C comm -13 <(printf '%s\n' "$here_set") <(printf '%s\n' "$lib_set") | sed 's/^/    /' >&2
        return 1
    fi
}

# ============================================
# Phase 4: Copy ALL Framework Files
# ============================================
# Replaces manual file-by-file copy with comprehensive sync.
# Project-specific data (active/, archive/, evidence/, project-knowledge/,
# pair-testing/, …) — the deny-list — is never overwritten.
copy_framework_files() {
    local src="$1"
    log_info "  → Syncing framework files from source..."

    # Pack smart-copy counters (visible to copy_pack_skill_smart via bash dynamic scoping
    # — do NOT call that function from a subshell/pipeline)
    local PACK_STATS_UPDATED=0 PACK_STATS_CUSTOMIZED=0 PACK_STATS_NEW=0
    local PACK_STATS_FORKED=0 PACK_STATS_MIGRATED=0 PACK_STATS_CONFLICTS=0

    # --- .tad/ framework files (copy everything except project data) ---

    # Top-level config & metadata files — DENY-LIST derived (every regular file
    # under $src/.tad/ EXCEPT TAD_TOP_DENY), NOT a fixed extension allow-list.
    # A new top-level framework file (.sh/.json/…) auto-copies — this is what
    # makes .tad/portable-extract.sh land on a fresh machine.
    #
    # AC2.6 version-floor: capture the PRE-SYNC target version BEFORE this
    # loop overwrites .tad/version.txt with the source version.
    # apply_deprecations compares deprecation entries against the OLD
    # (pre-install) version — entries newer than what the target ran are
    # inert for this run (pinned: old=2.2.0 → 2.3.0 inert; old=2.3.1 → applies).
    local pre_sync_version=""
    if [ -f ".tad/version.txt" ]; then
        pre_sync_version="$(head -1 .tad/version.txt | tr -d '[:space:]')"
    fi
    local tf
    while IFS= read -r tf; do
        [ -n "$tf" ] || continue
        cp "$src/.tad/$tf" .tad/ 2>/dev/null || true
    done <<< "$(derive_framework_top_files "$src")"

    # Framework subdirectories — DERIVED (deny-list), not hardcoded.
    # A new framework dir (e.g. codex, capability-packs, cross-model) is
    # auto-included with ZERO edits here — fixes the omission disease that
    # the old 14-dir allow-list caused.
    local dir
    while IFS= read -r dir; do
        [ -n "$dir" ] || continue
        # registry-only special case: copy ONLY the registry index file, not the tree.
        if [ "$dir" = "$TAD_REGISTRY_ONLY" ]; then
            mkdir -p ".tad/$dir"
            cp "$src/.tad/$dir/$TAD_REGISTRY_FILE" ".tad/$dir/" 2>/dev/null || true
            continue
        fi
        if [ -d "$src/.tad/$dir" ]; then
            mkdir -p ".tad/$dir"
            # Trailing "/." copies the dir CONTENTS including dotfiles (.gitkeep),
            # which a bare "/*" glob misses (BSD/macOS-safe, no shopt dotglob).
            cp -R "$src/.tad/$dir/." ".tad/$dir/" 2>/dev/null || true
        fi
    done <<< "$(derive_framework_dirs "$src")"

    # --- .claude/ framework files (platform-scoped) ---
    # Read extra_deny from platform-codes.yaml (file exists in $src at this point).
    local platform_deny=""
    if [ -f "$src/.tad/platform-codes.yaml" ]; then
        platform_deny="$(parse_platform_extra_deny "$src/.tad/platform-codes.yaml" "$PLATFORM")"
    fi

    # Platform switch detection — warn about remnants from the other platform
    if [ "$PLATFORM" = "codex" ] && [ -d ".claude/skills/alex" ]; then
        log_warn "Detected Claude Code skills from previous install. Codex skills will be installed to .agents/skills/. Old .claude/skills/ left intact — remove manually if no longer needed."
    elif [ "$PLATFORM" = "claude-code" ] && [ -d ".agents/skills/alex" ]; then
        log_warn "Detected Codex skills from previous install. Claude Code skills will be installed to .claude/skills/. Old .agents/skills/ left intact — remove manually if no longer needed."
    fi

    mkdir -p "$TARGET_SKILL_DIR"
    # Copy skill directories — respecting platform deny + pack selection
    if [ -d "$src/.claude/skills" ]; then
        local skill_dir
        for skill_dir in "$src"/.claude/skills/*/; do
            [ -d "$skill_dir" ] || continue
            local skill_name
            skill_name="$(basename "$skill_dir")"
            # Platform deny check — uses SOURCE path (.claude/skills/) to match deny-list entries
            if is_denied ".claude/skills/$skill_name" "$platform_deny"; then
                continue
            fi
            # Pack selection check (if --packs specified, only copy selected packs + non-pack skills)
            if [ -n "$PACKS" ] && is_pack_skill "$skill_name" "$src"; then
                if ! is_selected_pack "$skill_name"; then
                    continue
                fi
            fi
            # F-06: record run-created skill dirs for rollback removal (the
            # atomic snap-restore covers pre-existing trees; these notes cover
            # surfaces that did not exist pre-run).
            local _skill_new=0
            if [ ! -e "$TARGET_SKILL_DIR/$skill_name" ]; then _skill_new=1; fi
            if is_pack_skill "$skill_name" "$src"; then
                copy_pack_skill_smart "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"
            else
                cp -r "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"
            fi
            if [ "$_skill_new" = "1" ] && [ -e "$TARGET_SKILL_DIR/$skill_name" ]; then
                note_created_top "$TARGET_SKILL_DIR/$skill_name"
            fi
        done
    fi
    # settings.json — platform deny check
    if ! is_denied ".claude/settings.json" "$platform_deny"; then
        local _settings_new=0
        if [ ! -e ".claude/settings.json" ]; then _settings_new=1; fi
        cp "$src"/.claude/settings.json .claude/ 2>/dev/null || true
        if [ "$_settings_new" = "1" ] && [ -e ".claude/settings.json" ]; then
            note_created_top ".claude/settings.json"
        fi
    fi
    # Workflow scripts — platform deny check
    if ! is_denied ".claude/workflows" "$platform_deny"; then
        if [ -d "$src/.claude/workflows" ]; then
            local _wf_new=0
            if [ ! -e ".claude/workflows" ]; then _wf_new=1; fi
            mkdir -p .claude/workflows
            cp -r "$src"/.claude/workflows/* .claude/workflows/ 2>/dev/null || true
            if [ "$_wf_new" = "1" ]; then
                note_created_top ".claude/workflows"
            fi
        fi
    fi

    # --- Deprecation cleanup (v2.8.2) ---
    # Read .tad/deprecation.yaml and delete files listed for deprecation
    # versions ≤ current TARGET_VERSION. Previously no deprecation processing,
    # which caused 2.8.1 command file cleanup to never execute on downstream projects.
    apply_deprecations "$src" "$pre_sync_version"

    # --- Root files from platform extra_root_files ---
    # 2026-08-16 (EPIC-20260816 Phase 2): deprecation.yaml v2.3.0 曾列 AGENTS.md，
    # 那会删除【用户拥有】的文件（agents.md 是跨厂商标准）。该条目已移除——
    # 现在 v2.3.0 只列 TAD 自己写入的文件。本段仍负责按平台安装 TAD 版根文件，
    # 但已改为「内容不同则先备份」而非无声覆盖（见下方 FR-4b 注释）。
    local root_files=""
    if [ -f "$src/.tad/platform-codes.yaml" ]; then
        root_files="$(parse_platform_root_files "$src/.tad/platform-codes.yaml" "$PLATFORM")"
    fi
    if [ -n "$root_files" ]; then
        local rf
        local _rf_backup=""
        local _rf_ts=""
        local _rf_n=1
        local _rf_new=0
        while IFS= read -r rf; do
            [ -n "$rf" ] || continue
            if [ -f "$src/$rf" ]; then
                # FR-4b (EPIC-20260816 Phase 2 / 审计 F-01 衍生): 这些是【用户可能已有】的
                # 根文件（如 AGENTS.md —— 跨厂商 agents.md 标准，Codex/Cursor/Aider/Zed 都读）。
                # 原实现用裸 cp 直接覆盖，用户版本无声丢失。改为：已存在且内容不同时先备份。
                _rf_new=0
                if [ ! -e "./$rf" ]; then _rf_new=1; fi
                if [ -f "./$rf" ] && ! cmp -s "$src/$rf" "./$rf"; then
                    _rf_ts="$(date +%Y%m%d-%H%M%S)"
                    _rf_backup="./${rf}.pre-tad.${_rf_ts}"
                    _rf_n=1
                    while [ -e "$_rf_backup" ]; do _rf_backup="./${rf}.pre-tad.${_rf_ts}.$_rf_n"; _rf_n=$((_rf_n + 1)); done
                    cp "./$rf" "$_rf_backup" 2>/dev/null \
                        && { log_info "  → Backed up existing $rf → $(basename "$_rf_backup")"; note_created_top "${_rf_backup#./}"; }
                fi
                cp "$src/$rf" ./ 2>/dev/null || true
                # F-06: a root file this run created (no pre-existing bytes)
                # is rollback-removed (snapshot restore covers the rest).
                if [ "$_rf_new" = "1" ] && [ -e "./$rf" ]; then
                    note_created_top "$rf"
                fi
            fi
        done <<< "$root_files"
    fi

    # --- "both" platform: secondary Codex copy ---
    if [ "$PLATFORM" = "both" ]; then
        mkdir -p .agents/skills
        if [ -d "$src/.claude/skills" ]; then
            local skill_dir_b
            for skill_dir_b in "$src"/.claude/skills/*/; do
                [ -d "$skill_dir_b" ] || continue
                local skill_name_b
                skill_name_b="$(basename "$skill_dir_b")"
                if [ -n "$PACKS" ] && is_pack_skill "$skill_name_b" "$src"; then
                    if ! is_selected_pack "$skill_name_b"; then
                        continue
                    fi
                fi
                local _skill_new_b=0
                if [ ! -e ".agents/skills/$skill_name_b" ]; then _skill_new_b=1; fi
                if is_pack_skill "$skill_name_b" "$src"; then
                    copy_pack_skill_smart "$skill_dir_b" ".agents/skills/$skill_name_b"
                else
                    cp -r "$skill_dir_b" ".agents/skills/$skill_name_b"
                fi
                if [ "$_skill_new_b" = "1" ] && [ -e ".agents/skills/$skill_name_b" ]; then
                    note_created_top ".agents/skills/$skill_name_b"
                fi
            done
        fi
        log_info "  → Copied skills to .agents/skills/ (Codex secondary path)"
    fi

    # --- Pack meta generation (Phase 1: hash manifest) ---
    # Runs AFTER both primary and secondary copy loops so smart copy reads OLD meta.
    if [ -f "$src/.tad/capability-packs/pack-registry.yaml" ]; then
        local meta_targets="$TARGET_SKILL_DIR"
        [ "$PLATFORM" = "both" ] && meta_targets="$TARGET_SKILL_DIR .agents/skills"
        local mt
        for mt in $meta_targets; do
            [ -d "$mt" ] || continue
            local skill_dir_m
            for skill_dir_m in "$mt"/*/; do
                [ -d "$skill_dir_m" ] || continue
                local sn
                sn="$(basename "$skill_dir_m")"
                is_pack_skill "$sn" "$src" || continue
                generate_pack_meta "$skill_dir_m" "$src/.claude/skills/$sn" || log_warn "Meta generation failed for $sn, skipping"
            done
        done
    fi

    # --- Pack status summary ---
    local pack_total=$((PACK_STATS_UPDATED + PACK_STATS_CUSTOMIZED + PACK_STATS_NEW + PACK_STATS_FORKED + PACK_STATS_MIGRATED))
    if [ "$pack_total" -gt 0 ]; then
        log_info "  → Pack status: $PACK_STATS_UPDATED updated, $PACK_STATS_CUSTOMIZED customized (preserved), $PACK_STATS_NEW new, $PACK_STATS_FORKED forked, $PACK_STATS_MIGRATED migrated"
    fi
    if [ "$PACK_STATS_CONFLICTS" -gt 0 ]; then
        local effective_strategy="${RESOLVE_STRATEGY:-local}"
        if [ "$AUTO_YES" = "1" ] && [ "$effective_strategy" = "local" ]; then
            log_warn "  ⚠ $PACK_STATS_CONFLICTS file-level conflict(s) auto-preserved (local kept). Run 'tad.sh --resolve=ask' to review."
        elif [ "$effective_strategy" = "upstream" ]; then
            log_warn "  ⚠ $PACK_STATS_CONFLICTS file-level conflict(s) resolved to upstream. Backups saved as .tad-conflict-backup."
        else
            log_warn "  ⚠ $PACK_STATS_CONFLICTS file-level conflict(s) detected."
        fi
    fi

    # --- Codex hooks.json generation ---
    if [ "$PLATFORM" = "codex" ] || [ "$PLATFORM" = "both" ]; then
        mkdir -p .codex
        # F-06: a generated hooks.json with no pre-existing bytes is
        # rollback-removed (snapshot restore covers the pre-existing case).
        local _hooks_new=0
        if [ ! -e ".codex/hooks.json" ]; then _hooks_new=1; fi
        if [ "$_hooks_new" = "1" ]; then note_created_top ".codex/hooks.json"; fi
        cat > .codex/hooks.json << 'HOOKS_EOF'
{
  "description": "TAD lifecycle hooks",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|compact",
        "hooks": [
          { "type": "command", "command": "bash .tad/hooks/startup-health.sh", "timeout": 30 },
          { "type": "command", "command": "bash .tad/hooks/notebook-dormant-sync.sh", "timeout": 30 }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "^apply_patch$",
        "hooks": [
          { "type": "command", "command": "bash .tad/hooks/post-write-sync.sh", "timeout": 10 }
        ]
      },
      {
        "matcher": "^ask_user_question$",
        "hooks": [
          { "type": "command", "command": "bash .tad/hooks/lib/askuser-capture.sh", "timeout": 10 }
        ]
      }
    ]
  }
}
HOOKS_EOF
        log_info "  → Generated .codex/hooks.json (Codex lifecycle hooks)"
    fi

    # Count installed files for verification (exclude the zero-touch deny-list dirs).
    local count
    count=$(find .tad -type f \
        -not -path ".tad/active/*" -not -path ".tad/archive/*" \
        -not -path ".tad/evidence/*" -not -path ".tad/project-knowledge/*" \
        -not -path ".tad/pair-testing/*" | wc -l | tr -d ' ')
    log_success "  → Synced $count framework files to .tad/"

    # --- OpenCode updater-only projection (exact single-file copy + compare) ---
    project_opencode_command "$src"

    # --- AC3: post-install completeness self-check ---
    verify_install_complete "$src"
}

# ============================================
# Phase 4c: Post-install completeness self-check (P2 AC3)
# ============================================
# For each DERIVED framework dir AND each DERIVED top-level file, assert it landed
# in the target. Reuses the SAME deny-list derivations so it checks exactly what was
# meant to be copied — a new framework dir/file is auto-verified, an omission is caught.
#
# Dirs are verified by `diff -rq "$src/.tad/$dir" ".tad/$dir"` (the source tree is
# LOCAL at install time): this catches PARTIAL copies (1-of-50 files), not just an
# empty dir. The presence + non-empty check is kept as a fallback when diff is
# unavailable or the dir is missing entirely.
#
# Top-level files (P1: portable-extract.sh class) are verified by `cmp -s` against
# the source — so a future top-level framework file omission is now CAUGHT here,
# closing the gap where the dir-only self-check (and P1 release-verify.sh structural)
# were blind to top-level files.
#
# FATAL under main: `return 1` propagates to set -e + the ERR trap → rollback_on_failure.
# This is the desired behavior — a broken/partial source must fail the install rather
# than leave a silently-incomplete tree.
verify_install_complete() {
    local src="$1"
    log_info "  → Post-install self-check (derived completeness + content diff)..."

    # Platform deny for .claude/ verification scope
    local platform_deny=""
    if [ -f "$src/.tad/platform-codes.yaml" ]; then
        platform_deny="$(parse_platform_extra_deny "$src/.tad/platform-codes.yaml" "$PLATFORM")"
    fi

    local missing=0 checked=0 dir
    while IFS= read -r dir; do
        [ -n "$dir" ] || continue
        checked=$((checked + 1))
        if [ "$dir" = "$TAD_REGISTRY_ONLY" ]; then
            # registry-only: only the index file must exist + match source.
            if [ ! -f ".tad/$dir/$TAD_REGISTRY_FILE" ]; then
                log_warn "    ✗ MISSING: .tad/$dir/$TAD_REGISTRY_FILE (registry index)"
                missing=$((missing + 1))
            elif [ -f "$src/.tad/$dir/$TAD_REGISTRY_FILE" ] \
                 && ! cmp -s "$src/.tad/$dir/$TAD_REGISTRY_FILE" ".tad/$dir/$TAD_REGISTRY_FILE"; then
                log_warn "    ✗ MISMATCH: .tad/$dir/$TAD_REGISTRY_FILE differs from source"
                missing=$((missing + 1))
            fi
            continue
        fi
        # The source must have had the dir for us to expect it in the target.
        [ -d "$src/.tad/$dir" ] || continue
        if [ ! -d ".tad/$dir" ] || [ -z "$(ls -A ".tad/$dir" 2>/dev/null)" ]; then
            log_warn "    ✗ MISSING or EMPTY: .tad/$dir/"
            missing=$((missing + 1))
        elif command -v diff >/dev/null 2>&1 \
             && diff -rq "$src/.tad/$dir" ".tad/$dir" 2>/dev/null | grep -q "^Only in $src"; then
            # One-directional: only flag files MISSING from target (source has but target doesn't).
            # Target-only files (project-local additions) are expected on upgrades — not an error.
            log_warn "    ✗ PARTIAL: .tad/$dir/ missing source files (one-directional diff)"
            missing=$((missing + 1))
        fi
    done <<< "$(derive_framework_dirs "$src")"

    # Top-level framework files (DENY-LIST derived, any extension) — closes the
    # portable-extract.sh gap. A source top-level file missing from the target FAILS.
    local tf top_checked=0
    while IFS= read -r tf; do
        [ -n "$tf" ] || continue
        top_checked=$((top_checked + 1))
        if [ ! -f ".tad/$tf" ]; then
            log_warn "    ✗ MISSING top-level file: .tad/$tf"
            missing=$((missing + 1))
        elif ! cmp -s "$src/.tad/$tf" ".tad/$tf"; then
            log_warn "    ✗ MISMATCH top-level file: .tad/$tf differs from source"
            missing=$((missing + 1))
        fi
    done <<< "$(derive_framework_top_files "$src")"

    # Verify skills — check TARGET path (platform-aware), deny with SOURCE path
    if [ -d "$src/.claude/skills" ]; then
        local skill_dir skill_name
        for skill_dir in "$src"/.claude/skills/*/; do
            [ -d "$skill_dir" ] || continue
            skill_name="$(basename "$skill_dir")"
            # Skip if denied by platform — uses SOURCE path for deny-list matching
            if is_denied ".claude/skills/$skill_name" "$platform_deny"; then
                continue
            fi
            # Skip if not a selected pack (when --packs is specified)
            if [ -n "$PACKS" ] && is_pack_skill "$skill_name" "$src"; then
                if ! is_selected_pack "$skill_name"; then
                    continue
                fi
            fi
            checked=$((checked + 1))
            if [ ! -d "$TARGET_SKILL_DIR/$skill_name" ]; then
                log_warn "    ✗ MISSING skill: $TARGET_SKILL_DIR/$skill_name/"
                missing=$((missing + 1))
            fi
            # "both" platform: also verify .agents/skills/ secondary path
            if [ "$PLATFORM" = "both" ] && [ ! -d ".agents/skills/$skill_name" ]; then
                log_warn "    ✗ MISSING skill (codex secondary): .agents/skills/$skill_name/"
                missing=$((missing + 1))
            fi
        done
    fi

    # OpenCode updater-only command — the source owns it, so the target MUST
    # carry it byte-identically (FR-4 completeness).
    local src_op_f="$src/.opencode/commands/tad-update.md"
    if [ -f "$src_op_f" ]; then
        checked=$((checked + 1))
        if [ ! -f ".opencode/commands/tad-update.md" ]; then
            log_warn "    ✗ MISSING OpenCode command: .opencode/commands/tad-update.md"
            missing=$((missing + 1))
        elif ! cmp -s "$src_op_f" ".opencode/commands/tad-update.md"; then
            log_warn "    ✗ MISMATCH OpenCode command: .opencode/commands/tad-update.md differs from source"
            missing=$((missing + 1))
        fi
    fi

    if [ "$missing" -eq 0 ]; then
        log_success "    ✓ Self-check passed: $checked derived paths (diff-clean) + $top_checked top-level files present (platform: $PLATFORM)"
    else
        log_error "    ✗ Self-check FAILED: $missing missing/partial/mismatched derived path(s)"
        log_error "      The install is INCOMPLETE — re-run the installer or report this."
        return 1
    fi
}

# ============================================
# Phase 4a: Migration Engine
# ============================================
# Calls migration-engine.sh to apply version-specific migrations (delete/rename).
# Engine is the SOLE executor of migration logic — no inline delete/rename here.
# Exit codes: 0=success, 1=execution error (warn), 2=manifest invalid (warn).
# Uses || to suppress ERR trap (bash 3.2: set +e does NOT suppress armed trap).
call_migration_engine() {
    local src="$1"
    local old_ver="$2"
    local new_ver="$3"

    # Skip if no old version (fresh install) or same version
    if [ "$old_ver" = "none" ] || [ "$old_ver" = "$new_ver" ]; then
        return 0
    fi

    local engine="$src/.tad/hooks/lib/migration-engine.sh"
    if [ ! -f "$engine" ]; then
        log_warn "  → Migration engine not found in source; skipping migration"
        return 0
    fi

    log_info "  → Running migration engine ($old_ver → $new_ver)..."

    # ERR trap bypass: || engine_rc=$? is POSIX-guaranteed to suppress
    # the ERR trap in bash 3.2 (set +e does NOT suppress an armed trap).
    local engine_rc=0
    bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src" || engine_rc=$?

    case $engine_rc in
        0)
            log_success "  → Migration completed successfully"
            ;;
        2)
            log_warn "  → Migration skipped: manifest invalid or chain gap (exit 2)"
            log_warn "    If upgrading from a very old version, consider a clean reinstall"
            ;;
        1)
            log_warn "  → Migration had execution errors (exit 1)"
            log_warn "    Backup exists in .tad-backup/ for recovery"
            ;;
        *)
            log_warn "  → Migration returned unexpected exit code: $engine_rc"
            ;;
    esac
}

# ============================================
# Phase 4b: Apply Deprecations (v2.8.2+)
# ============================================
# Reads .tad/deprecation.yaml and removes files listed for versions ≤ the
# comparison version: the pre-install target version when the target had one
# (AC2.6 floor — entries newer than what the target ran are inert for this
# run), else the source version (fresh install). Simple semver parser — no
# yq dependency. Safe: deletion errors are non-fatal.
apply_deprecations() {
    local src="$1"
    local old_version="${2:-}"
    local dep_file="$src/.tad/deprecation.yaml"

    [ -f "$dep_file" ] || return 0

    # AC2.6 version-floor: compare against the OLD (pre-install, pre-sync)
    # target version passed by the caller. Entries newer than what the target
    # ran are inert for this run (old=2.2.0 → 2.3.0 inert; old=2.3.1 → the 3
    # TAD-owned 2.3.0 paths apply). Empty old (fresh install) falls back to
    # the file reads below (post-sync source version — inert by absence).
    local current_version
    if [ -n "$old_version" ]; then
        current_version="$old_version"
    elif [ -f ".tad/version.txt" ]; then
        current_version=$(head -1 .tad/version.txt | tr -d '[:space:]')
    elif [ -f "$src/.tad/version.txt" ]; then
        current_version=$(head -1 "$src/.tad/version.txt" | tr -d '[:space:]')
    else
        current_version="${TARGET_VERSION}"
    fi

    log_info "  → Applying deprecations for versions ≤ $current_version..."

    # ── F-02: route deletions through migration-engine's guard chain ──────────
    # Rationale: apply_deprecations previously deleted with an unguarded recursive
    # remove, bypassing the containment + zero-touch guards that already exist in
    # migration-engine.sh. Guarding must live at the EXECUTION point (after path
    # resolution), not at the declaration layer — see
    # patterns/ac-verification.md "五版全败" (2026-08-16).
    #
    # Sourced INSIDE this function (not at top level): the engine defines main(),
    # which at top level would silently replace the installer's main() and make the
    # installer print engine usage and exit 2 (Gate 2 round-3 sandbox finding).
    # The engine's `main "$@"` is BASH_SOURCE-guarded so sourcing does not run it.
    local engine="$src/.tad/hooks/lib/migration-engine.sh"
    local backup_base=""
    if [ -f "$engine" ]; then
        # shellcheck source=/dev/null
        source "$engine"
        # Engine line 15 resets TARGET/SOURCE/FROM_VER/TO_VER on source →
        # these MUST be assigned AFTER the source, not before.
        TARGET="$(pwd)"
        SOURCE="$src"
        # do_backup reads TARGET/M_FROM/M_TO (all three REQUIRED — an unset one is a
        # fatal `unbound variable` that neither `|| rc=$?` nor the ERR trap can catch).
        # current→current keeps this backup namespace distinct from call_migration_engine's
        # (${old_ver}-to-${new_ver}), so paths present in both manifests are not refused
        # by do_backup's "refuse to overwrite existing backup" check.
        M_FROM="$current_version"
        M_TO="$current_version"
        backup_base="$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"
        # ZT_LIST must come from derive-sync-set.sh (FR-4). Omitting this call fails
        # OPEN: an empty ZT_LIST makes check_zero_touch pass everything.
        #
        # load_zero_touch exits 2 when the authority is unreadable — a hard exit that
        # bypasses `|| rc=$?` AND the rollback trap, killing the installer mid-run and
        # leaving a half-updated target (files copied, version.txt not yet updated).
        # Fail-closed is the right DIRECTION for a deletion path, but killing the whole
        # install is disproportionate and asymmetric with the engine-missing branch below.
        # So: probe the authority in a SUBSHELL first (its exit 2 dies with the subshell),
        # and degrade to warn+skip when it is unusable. Skipping deprecations is equally
        # fail-closed — no authority means nothing gets deleted.
        # `trap - ERR` inside the probe: the subshell inherits the armed rollback trap,
        # and rollback_on_failure runs with cwd=target (it would wipe .tad). No command
        # in load_zero_touch can currently trip it, but disarming costs one word and
        # removes the whole class.
        if ( trap - ERR; load_zero_touch "$src" ) >/dev/null 2>&1; then
            load_zero_touch "$src"
        else
            log_warn "  → Zero-touch authority unavailable; deprecations skipped (nothing deleted)"
            return 0
        fi
    else
        log_warn "  → Migration engine not found in source; deprecations skipped (guarded deletion unavailable)"
        return 0
    fi

    local deleted=0
    local refused=0
    local current_dep_version=""
    local in_files=0

    # Very simple YAML parser: we process one deprecation version at a time.
    # When we encounter a version key (e.g. "  \"2.8.2\":"), we record it.
    # When we encounter "    files:", we start reading file paths.
    # File paths are lines starting with "      - " (YAML list item).
    while IFS= read -r line; do
        # Match version key: e.g.   "2.8.2":
        if printf '%s' "$line" | grep -qE '^[[:space:]]+"[0-9]+\.[0-9]+\.[0-9]+":'; then
            current_dep_version=$(printf '%s' "$line" | sed -E 's/^[[:space:]]+"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')
            in_files=0
            continue
        fi
        # Match files: line
        if printf '%s' "$line" | grep -qE '^[[:space:]]+files:[[:space:]]*$'; then
            in_files=1
            continue
        fi
        # Non-file line (description, date, note) → exit files section
        if [ "$in_files" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+[a-z_]+:'; then
            in_files=0
            continue
        fi
        # File list item: e.g.       - ".claude/commands/foo.md"
        if [ "$in_files" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+-[[:space:]]+'; then
            # Only process if dep_version ≤ current_version (version_le uses sort -V)
            if version_le "$current_dep_version" "$current_version"; then
                local target
                target=$(printf '%s' "$line" | sed -E 's/^[[:space:]]+-[[:space:]]+//' | tr -d '"')
                if [ -e "$target" ]; then
                    local rc=0
                    # Traversal / self-reference pre-check BEFORE do_backup.
                    # check_containment only inspects the PARENT of "$base/$p", which
                    # degenerates for paths that resolve back to base itself ("..", ".",
                    # "./", "a/./"), so such an entry would reach do_backup and get
                    # cp -a'd — for "./" that is a RECURSIVE self-copy of the whole
                    # target into its own .tad-backup (nests until the path is too long)
                    # and makes every later entry in the run fail with "backup already
                    # exists". Predicate (^|/)\.\.?(/|$) covers "." and ".." in every
                    # position; plain names like "..foo" / "..." / ".foo" stay allowed.
                    # Deliberately NARROWER than the engine's validate_path: that one
                    # also enforces a prefix allow-list and rejects trailing slashes,
                    # which would refuse the legitimate entry ".tad/codex/schemas/"
                    # (1 of 82) and break NFR4. Verified: this predicate rejects 0 of
                    # the 82 real manifest entries.
                    if printf '%s' "$target" | grep -qE '(^|/)\.\.?(/|$)'; then
                        printf 'REJECT: path traversal or self-reference: %s\n' "$target" >&2
                        rc=1
                    fi
                    # ERR trap bypass: `|| rc=$?` is POSIX-guaranteed to suppress the
                    # armed ERR trap (set +e does NOT). Without this, a single refused
                    # entry would fire rollback_on_failure (which wipes .tad and exits 1),
                    # destroying the whole install (FR-3 / hard-prohibition #5).
                    #
                    # do_backup runs BEFORE the guards (same order as the engine's own
                    # delete flow, migration-engine.sh:898-899), so a refused entry has
                    # already been cp -a'd into .tad-backup by the time we learn it is
                    # refused. For a zero-touch path that means a COPY of the user's
                    # private data (e.g. .tad/memory) is left behind in a directory the
                    # target project does not necessarily gitignore — the guard saved the
                    # original but leaked a duplicate. So: if this run created the backup
                    # and the entry was then refused, remove that copy again.
                    local backup_preexisted=0
                    [ -e "$backup_base/$target" ] && backup_preexisted=1
                    [ "$rc" -eq 0 ] && { do_backup "$target" "$backup_base" || rc=$?; }
                    [ "$rc" -eq 0 ] && { guarded_remove "$TARGET/$target" "$backup_base/$target" "$target" "$TARGET" || rc=$?; }
                    if [ "$rc" -ne 0 ] && [ "$backup_preexisted" -eq 0 ] && [ -e "$backup_base/$target" ]; then
                        # find -depth -delete (not a recursive rm) so the AC that forbids
                        # unguarded recursive removal inside this function stays meaningful:
                        # the only thing removed here is the copy THIS run just made under
                        # .tad-backup, never anything in the target project itself.
                        # `|| true` because find exits 1 when the path is already gone,
                        # which would trip the ERR trap under set -e.
                        find "$backup_base/$target" -depth -delete 2>/dev/null || true # RM-OK:deprecation-backup-copy-purge
                    fi
                    if [ "$rc" -eq 0 ]; then
                        deleted=$(( deleted + 1 ))
                    else
                        refused=$(( refused + 1 ))
                        log_warn "  ⚠ refused (rc=$rc): $target"
                    fi
                fi
            fi
        fi
    done < "$dep_file"

    if [ "$deleted" -gt 0 ]; then
        log_success "  → Removed $deleted deprecated file(s)"
    else
        log_info "  → No deprecated files to remove"
    fi
    if [ "$refused" -gt 0 ]; then
        log_warn "  → $refused deprecated path(s) refused by guards (see ABORT lines above)"
    fi
}

# Compare two semver versions: returns 0 if $1 ≤ $2, 1 otherwise
version_le() {
    local v1="$1"
    local v2="$2"
    # Sort the two versions and see if v1 comes first (or equal)
    [ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -1)" = "$v1" ]
}

# ============================================
# Phase 6b: Validation
# ============================================
validate_generated_configs() {
    log_info "Validating generated configurations..."

    local errors=0

    # Check required files exist
    for file in ".tad/config.yaml" ".tad/version.txt"; do
        if [ ! -f "$file" ]; then
            log_error "Missing required file: $file"
            ((errors++))
        fi
    done

    # Check skills directory
    if [ ! -d ".tad/skills" ]; then
        log_error "Missing skills directory"
        ((errors++))
    fi

    # Check agents directory
    if [ ! -d ".tad/agents" ]; then
        log_error "Missing agents directory"
        ((errors++))
    fi

    # Check templates directory
    if [ ! -d ".tad/templates" ]; then
        log_error "Missing templates directory"
        ((errors++))
    fi

    # Check skills directory (commands migrated to skills in v2.8.1)
    if [ ! -d "$TARGET_SKILL_DIR" ]; then
        log_error "Missing $TARGET_SKILL_DIR directory"
        ((errors++))
    fi

    if [ $errors -gt 0 ]; then
        return 1
    fi

    log_success "All configurations validated"
}

# ============================================
# Phase 7: Rollback on Failure (F-06: coverage-extended, absolutized, atomic)
# ============================================
# snap_one <relpath> — copy an existing target surface into ROLLBACK_SNAP.
snap_one() {
    local _p="$1"
    if [ -e "$_p" ]; then
        mkdir -p "$ROLLBACK_SNAP/$(dirname "$_p")"
        cp -R "$_p" "$ROLLBACK_SNAP/$_p"
    fi
}

# take_rollback_snapshot — capture the absolute target root, absolutize
# BACKUP_PATH (a relative BACKUP_PATH is cwd-sensitive: the red defect), and
# snapshot EVERY surface mutated after NEED_ROLLBACK=1: .tad/ is covered by
# BACKUP_PATH; CLAUDE.md + timestamped backup, skills trees, root files,
# .codex/hooks.json, settings/workflows are snapshotted here. Runs once,
# immediately after NEED_ROLLBACK=1, before the first project mutation.
take_rollback_snapshot() {
    TARGET_ROOT="$(pwd -P)" || { log_error "cannot resolve target root for rollback snapshot"; exit 1; }
    if [ -z "$TARGET_ROOT" ] || [ "$TARGET_ROOT" = "/" ]; then
        log_error "refusing to snapshot: unsafe TARGET_ROOT ('$TARGET_ROOT')"
        exit 1
    fi
    if [ -n "${BACKUP_PATH:-}" ]; then
        case "$BACKUP_PATH" in
            /*) BACKUP_PATH_ABS="$BACKUP_PATH" ;;
            *) BACKUP_PATH_ABS="$TARGET_ROOT/$BACKUP_PATH" ;;
        esac
    fi
    ROLLBACK_SNAP="$(mktemp -d "$(resolve_tmpdir)/tad-rollback.XXXXXX")" || { log_error "rollback snapshot mktemp failed"; exit 1; }
    chmod 700 "$ROLLBACK_SNAP"
    # Record which top-level framework surfaces pre-exist: on rollback, a
    # framework top dir that did NOT pre-exist is entirely run-created and is
    # removed wholesale (step 4); pre-existing ones restore file-precisely.
    local _pre
    ROLLBACK_PRE_TOP=""
    for _pre in CLAUDE.md AGENTS.md GEMINI.md .tad .claude .agents .codex .opencode; do
        if [ -e "$_pre" ]; then ROLLBACK_PRE_TOP="${ROLLBACK_PRE_TOP}${_pre} "; fi
    done
    snap_one "CLAUDE.md"
    snap_one "AGENTS.md"
    snap_one "GEMINI.md"
    snap_one ".codex/hooks.json"
    snap_one ".claude/settings.json"
    snap_one ".claude/workflows"
    snap_one ".claude/skills"
    snap_one ".agents/skills"
    snap_one ".tad/project-knowledge/README.md"
}

# discard_rollback_snap — success-path only: the install verified complete,
# so the snapshot (a recovery copy) is consumed. Failure paths NEVER call
# this (a failed restore must preserve its recovery sources).
discard_rollback_snap() {
    local _s="${ROLLBACK_SNAP:-}"
    if [ -n "$_s" ] && [ -d "$_s" ]; then
        case "$(basename "$_s")" in
            tad-rollback.*) rm -rf "$_s" ;; # RM-OK:rollback-snap-consumed
        esac
    fi
    ROLLBACK_SNAP=""
}

# note_created_top <relpath> — record a run-created top-level file for
# rollback removal (only files this run created, never pre-existing bytes).
note_created_top() {
    ROLLBACK_CREATED_TOP="${ROLLBACK_CREATED_TOP:-}${1}
"
}

# restore_dir_entry <snap_entry> <dst_path> — atomic DIRECTORY restore via a
# same-filesystem staging dir + rename (never diff-output parsing, never a
# merging cp-over that would leave run-created extras behind): stage ← snap,
# verify stage, clear dst, rename stage → dst, re-verify. ANY failure returns
# 1 with the recovery source (snap entry / backup) ALWAYS preserved — the
# caller prints the explicit failed-state message naming it.
restore_dir_entry() {
    local _snap_e="$1" _dst="$2"
    local _stage="${_dst}.rollback-staging"
    rm -rf "$_stage" # RM-OK:rollback-stage-preclean
    if cp -R "$_snap_e" "$_stage" 2>/dev/null \
       && diff -rq "$_snap_e" "$_stage" >/dev/null 2>&1; then
        if rm -rf "$_dst"; then # RM-OK:rollback-dst-clear
            mkdir -p "$(dirname "$_dst")"
            if mv "$_stage" "$_dst" \
               && diff -rq "$_snap_e" "$_dst" >/dev/null 2>&1; then
                return 0
            fi
        fi
    fi
    rm -rf "$_stage" 2>/dev/null # RM-OK:rollback-stage-abort
    return 1
}

rollback_on_failure() {
    log_error "Installation failed. Rolling back..."
    if [ -z "${TARGET_ROOT:-}" ]; then
        TARGET_ROOT="$(pwd -P 2>/dev/null)" || TARGET_ROOT=""
    fi
    if [ -z "${TARGET_ROOT:-}" ] || [ "$TARGET_ROOT" = "/" ]; then
        log_error "Rollback REFUSED: unsafe target root ('${TARGET_ROOT:-<empty>}'). Backup preserved at '${BACKUP_PATH_ABS:-${BACKUP_PATH:-<none>}}' / snapshot '${ROLLBACK_SNAP:-<none>}'. Restore manually."
        exit 1
    fi
    local _restored_list="" _kept_list="" _removed_list=""

    # 1. .tad/ via the absolutized backup: atomic stage-verify-rename (extras
    # from the half-installed tree cannot survive — a merging cp-over would
    # leave run-created files behind). A failed restore NEVER deletes the
    # backup (ENOSPC class) — the failed-state message names the preserved path.
    if [ -n "${BACKUP_PATH_ABS:-}" ] && [ -d "$BACKUP_PATH_ABS" ]; then
        if restore_dir_entry "$BACKUP_PATH_ABS" "$TARGET_ROOT/.tad"; then
            rm -rf "$BACKUP_PATH_ABS" # RM-OK:rollback-backup-consumed
            log_info "Restored from backup: $BACKUP_PATH_ABS (.tad/ verified, backup consumed)"
            _restored_list="${_restored_list}.tad/ "
        else
            log_error "Rollback FAILED for .tad/ (stage, rename, or verify failed) — backup PRESERVED at $BACKUP_PATH_ABS; restore manually."
            _kept_list="${_kept_list}.tad-backup "
        fi
    elif [ -z "${BACKUP_PATH_ABS:-}" ] && [ -d "$TARGET_ROOT/.tad" ]; then
        # Fresh install: .tad/ is entirely run-created → guarded removal.
        rm -rf "$TARGET_ROOT/.tad" # RM-OK:rollback-fresh-tad-created
        log_info "Removed run-created .tad/ (fresh-install rollback)"
        _removed_list="${_removed_list}.tad/ "
    fi

    # 2. Snapshot surfaces (CLAUDE.md, skills trees, root files, hooks.json,
    # settings/workflows): directories restore ATOMICALLY via staging+rename
    # (merging cp-over would leave run-created extras — the ac2.8 skills
    # residue class); files copy over + verify. The snapshot is the recovery
    # copy — PRESERVED here regardless of outcome.
    if [ -n "${ROLLBACK_SNAP:-}" ] && [ -d "$ROLLBACK_SNAP" ]; then
        local _top _rel
        for _top in "$ROLLBACK_SNAP"/* "$ROLLBACK_SNAP"/.*; do
            [ -e "$_top" ] || continue
            _rel="$(basename "$_top")"
            case "$_rel" in .|..) continue ;; esac
            if [ -d "$_top" ] && [ ! -L "$_top" ]; then
                if restore_dir_entry "$_top" "$TARGET_ROOT/$_rel"; then
                    _restored_list="${_restored_list}${_rel} "
                else
                    log_error "Rollback FAILED for $_rel — snapshot PRESERVED at $ROLLBACK_SNAP/$_rel; restore manually."
                    _kept_list="${_kept_list}snap-$_rel "
                fi
            else
                mkdir -p "$(dirname "$TARGET_ROOT/$_rel")"
                if cp -R "$_top" "$TARGET_ROOT/$_rel" 2>/dev/null \
                   && diff -rq "$_top" "$TARGET_ROOT/$_rel" >/dev/null 2>&1; then
                    _restored_list="${_restored_list}${_rel} "
                else
                    log_error "Rollback FAILED for $_rel — snapshot PRESERVED at $ROLLBACK_SNAP/$_rel; restore manually."
                    _kept_list="${_kept_list}snap-$_rel "
                fi
            fi
        done
    fi

    # 3. Undo exactly the OpenCode command this run created (FR-4 rollback):
    # pre-existing OpenCode content was never touched by construction.
    if [ "${OPCODE_CREATED_FILE:-0}" = "1" ]; then
        rollback_opencode_projection
        _removed_list="${_removed_list}.opencode/commands/tad-update.md "
    fi

    # 4. Remove exactly the files THIS run created (merge backup, fresh
    # PROJECT_CONTEXT.md/NEXT.md, .pre-tad backups) — never user bytes.
    if [ -n "${MERGE_CREATED_BACKUP:-}" ] && [ -e "$TARGET_ROOT/$MERGE_CREATED_BACKUP" ]; then
        rm -f "$TARGET_ROOT/$MERGE_CREATED_BACKUP" # RM-OK:rollback-merge-backup
        _removed_list="${_removed_list}${MERGE_CREATED_BACKUP} "
    fi
    local _c
    while IFS= read -r _c; do
        [ -n "$_c" ] || continue
        case "$_c" in /*|*..*) continue ;; esac
        if [ -e "$TARGET_ROOT/$_c" ]; then
            rm -rf "$TARGET_ROOT/$_c" # RM-OK:rollback-created-top
            _removed_list="${_removed_list}${_c} "
        fi
    done <<< "${ROLLBACK_CREATED_TOP:-}"

    # 4b. Framework top dirs that did NOT pre-exist are entirely run-created
    # (.tad is owned by step 1; the rest fall here). Fixed names under the
    # absolutized root — pre-existing dirs are exempt via ROLLBACK_PRE_TOP,
    # so user content inside them is never touched by this sweep.
    local _td
    for _td in .claude .agents .codex .opencode; do
        case " ${ROLLBACK_PRE_TOP:-} " in
            *" $_td "*) ;;
            *)
                if [ -e "$TARGET_ROOT/$_td" ]; then
                    rm -rf "$TARGET_ROOT/$_td" # RM-OK:rollback-fresh-top-dirs
                    _removed_list="${_removed_list}${_td}/ "
                fi
                ;;
        esac
    done
    # 4c. Possibly-emptied parents (run-created skill/workflow dirs removed
    # above can leave empty shells): rmdir removes ONLY empty dirs, never
    # content — a non-empty dir (user content) stays, silently by design.
    rmdir "$TARGET_ROOT/.claude/skills" 2>/dev/null || true # RM-OK:rollback-rmdir-skills
    rmdir "$TARGET_ROOT/.agents/skills" 2>/dev/null || true # RM-OK:rollback-rmdir-agents-skills
    rmdir "$TARGET_ROOT/.claude/workflows" 2>/dev/null || true # RM-OK:rollback-rmdir-workflows
    # 4d. Structural migration backups are recovery copies — enumerated as
    # preserved-for-manual-recovery, never removed here.
    local _mb
    for _mb in "$TARGET_ROOT"/.tad-migrate-backup.*; do
        [ -e "$_mb" ] || continue
        _kept_list="${_kept_list}$(basename "$_mb") "
    done

    # 5. Downloaded source residue via the single chokepoint (user-supplied
    # --source trees stay inert here by construction).
    cleanup_source_tree

    # Coverage-enumerating message (R2 P0-1: coverage wins over message-only —
    # every surface is listed as restored / removed / preserved-for-recovery).
    log_info "Rollback coverage — restored: [${_restored_list:-none}] removed-run-created: [${_removed_list:-none}] preserved-for-manual-recovery: [${_kept_list:-none}]"
    log_error "Rollback complete. Please check logs."
    exit 1
}

# --verify-denylist: release-time drift check. Runs BEFORE the rollback trap is
# set (it must never trigger rollback) and exits immediately — it never installs.
if [ "$VERIFY_DENYLIST" = "1" ]; then
    verify_denylist_drift
    exit $?
fi

# archive_old_skill_mds <skills_dir> — F-08: move legacy top-level *.md skill
# files (except doc-organization.md) into a UNIQUE timestamped _archived.<ts>
# dir (backup_existing()-style increment loop — skip-if-exists is WRONG per
# audit: it silently drops the 2nd run's files). No legacy files → no dir is
# created. A failed move is LOUD (return 1 → set -e → rollback restores the
# skills tree from snapshot); the silent `mv || true` swallowing is removed
# (scoped purge per MQ5 covers ONLY these two _archived call sites' success
# path — there is no `|| true` left on the move itself).
archive_old_skill_mds() {
    local skill_base="$1"
    [ -d "$skill_base" ] || return 0
    local f found=0
    for f in "$skill_base"/*.md; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "doc-organization.md" ] && continue
        found=1
        break
    done
    [ "$found" = "1" ] || return 0
    local ts base dest n
    ts="$(date +%Y%m%d_%H%M%S)"
    base="$skill_base/_archived.$ts"
    dest="$base"; n=1
    while [ -e "$dest" ]; do dest="${base}.$n"; n=$((n + 1)); done
    mkdir -p "$dest"
    note_created_top "$dest"
    local moved=0
    for f in "$skill_base"/*.md; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "doc-organization.md" ] && continue
        if mv "$f" "$dest/"; then
            moved=$((moved + 1))
        else
            log_error "archive move failed: $f → $dest/ (refusing to swallow; rollback restores the skills tree)"
            return 1
        fi
    done
    log_info "  → Archived $moved legacy skill file(s) → $(basename "$dest")"
}

# Standalone pack management commands — exit before install flow
if [ -n "$FORK_PACK" ]; then fork_pack "$FORK_PACK"; exit 0; fi
if [ -n "$UNFORK_PACK" ]; then unfork_pack "$UNFORK_PACK"; exit 0; fi
if [ "$LIST_PACKS" = "1" ]; then list_packs; exit 0; fi

# Set trap for automatic rollback
# ⚠️ 2026-09-02 (v2.43.1): ERR trap does NOT fire for failures inside a
# `case` branch (verified: `case x in x) g;; esac` where g returns 1 exits
# via set -e with NO ERR trap). merge_claude_md and other ACTION-branch steps
# therefore never triggered rollback. Rollback now lives on the EXIT trap,
# gated by NEED_ROLLBACK — set immediately before the first project mutation
# and cleared on the success path. Every exit (set -e, explicit, signal) that
# happens while NEED_ROLLBACK=1 restores the project.
NEED_ROLLBACK=0
trap 'cleanup_installer_temp; cleanup_source_tree; if [ "${NEED_ROLLBACK:-0}" = "1" ]; then rollback_on_failure; fi' EXIT

# ============================================
# CLAUDE.md Merge (marker-based)
# ============================================
merge_claude_md() {
    local src="$1"
    local marker="<!-- TAD:PROJECT-CONTENT-BELOW -->"

    if [ ! -f "$src/CLAUDE.md" ]; then
        log_error "Source CLAUDE.md not found: $src/CLAUDE.md"
        return 1
    fi

    if [ ! -f "CLAUDE.md" ]; then
        cp "$src/CLAUDE.md" ./
        return
    fi

    # F-05: namespaced timestamped backup (backup_existing() scheme). The bare
    # `CLAUDE.md.bak` name is USER-OWNED — a pre-existing user file of that
    # name must survive byte-identical (AC2.9), so the installer never
    # creates, overwrites, or deletes it. The run-created backup path is
    # recorded for rollback (removed on failure; original restored from snap).
    MERGE_CREATED_BACKUP=""
    local _ts _backup _n
    _ts="$(date +%Y%m%d_%H%M%S)"
    _backup="CLAUDE.md.backup.${_ts}"
    _n=1
    while [ -e "$_backup" ]; do _backup="CLAUDE.md.backup.${_ts}.$_n"; _n=$((_n + 1)); done
    cp "CLAUDE.md" "$_backup"
    MERGE_CREATED_BACKUP="$_backup"

    local marker_line
    marker_line=$(grep -nF "$marker" "CLAUDE.md" | head -1 | cut -d: -f1 || true)

    if [ -n "$marker_line" ]; then
        local content_start=$((marker_line + 1))

        # Merge tmp lives in the validated TMPDIR, never in the project root
        # (F-07: zero stray writes into the target).
        local tmpfile
        tmpfile=$(mktemp "$(resolve_tmpdir)/CLAUDE.md.merge.XXXXXX") || return 1

        # Invariant: source CLAUDE.md MUST end with the marker as its last line.
        # The full source (including marker) is written, then project content appended.
        cat "$src/CLAUDE.md" > "$tmpfile" || { rm -f "$tmpfile"; return 1; } # RM-OK:merge-tmp-abort

        # tail -n +N on a file shorter than N lines outputs nothing (safe no-op)
        tail -n +"$content_start" "CLAUDE.md" >> "$tmpfile" || { rm -f "$tmpfile"; return 1; } # RM-OK:merge-tmp-abort-tail

        mv "$tmpfile" "CLAUDE.md" || { rm -f "$tmpfile"; return 1; } # RM-OK:merge-tmp-abort-mv
        log_success "  → CLAUDE.md merged (project content preserved below marker; backup: $(basename "$_backup"))"
    else
        cp "$src/CLAUDE.md" ./
        log_warn "CLAUDE.md backed up to $(basename "$_backup") (no merge marker found)"
        log_warn "If you had project-specific rules, restore them from the backup"
    fi
}

# ============================================
# Detect current state
# ============================================
# numeric semver compare. echoes -1 if $1<$2, 0 if ==, 1 if $1>$2. Pure bash, BSD-safe.
_tad_ver_cmp() {
    [ "$1" = "$2" ] && { echo 0; return; }
    local IFS=.; local -a A=($1) B=($2); local i ai bi
    for i in 0 1 2; do
        ai="${A[i]:-0}"; bi="${B[i]:-0}"
        [[ "$ai" =~ ^[0-9]+$ ]] || ai=0
        [[ "$bi" =~ ^[0-9]+$ ]] || bi=0
        if [ "$ai" -gt "$bi" ]; then echo 1; return; fi
        if [ "$ai" -lt "$bi" ]; then echo -1; return; fi
    done
    echo 0
}

detect_state() {
    if [ ! -d ".tad" ] && [ ! -d ".claude/commands" ]; then
        echo "fresh"
    elif [ -f ".tad/version.txt" ]; then
        local ver; ver=$(cat .tad/version.txt)
        ver="${ver//[$'\r\n ']/}"               # CRLF/whitespace trim (safe equality)
        local tmaj="${TARGET_VERSION%%.*}"       # TARGET_VERSION is a trusted constant (not separately guarded by design)
        local vmaj="${ver%%.*}"
        if [ "$ver" = "$TARGET_VERSION" ]; then
            echo "current"
        elif ! [[ "$vmaj" =~ ^[0-9]+$ ]]; then
            echo "old"                            # unparseable → fail-safe to migrate path
        elif [ "$(_tad_ver_cmp "$ver" "$TARGET_VERSION")" = "1" ]; then
            echo "current"                        # installed NEWER than target → no-op (never downgrade)
        elif [ "$vmaj" -eq "$tmaj" ]; then
            echo "upgrade"                         # same major, older → plain upgrade
        else
            # installed major < target major → cross-major migration territory.
            # GLOB SAFETY: use dot-bounded patterns (1.8|1.8.*), NOT prefix globs (1.8*).
            # Prefix globs match across minor boundaries (1.8* matches 1.80.0).
            case "$ver" in
                1.8|1.8.*)          echo "v1.8" ;;  # preserve existing v1.x granular routing
                1.6|1.6.*|1.5|1.5.*) echo "v1.6" ;;
                1.4|1.4.*)          echo "v1.4" ;;
                *)                  echo "old" ;;   # incl. v2-into-newer-major → migrate (gets .tad-migrate-backup)
            esac
        fi
    elif [ -d ".tad" ]; then
        echo "old"
    else
        echo "partial"
    fi
}

# ============================================
# Pinned-source download (FR-2 immutable release binding)
# ============================================
# Downloads the immutable tag archive into a private mode-0700 temp root OUTSIDE
# the project, validates the payload, discovers exactly one safe extracted source
# root (no symlinked / escaping / multiple roots), and compares the derived
# authoritative version against the pinned expected version BEFORE any project
# state detection or mutation. On failure: prints the error, trap-cleans the
# temp root, and exits 1 — the project tree is never touched.
# Sets TAD_SRC (the verified root) and TAD_TMP_ROOT (cleaned by the EXIT trap).
# discover_single_source_root <tmp_root> — print the exactly-one safe extracted
# source root (real directory, not a link). Fail CLOSED otherwise.
discover_single_source_root() {
    local tmp_root="$1"
    local roots=0 root=""
    local entry
    for entry in "$tmp_root"/src/*; do
        [ -e "$entry" ] || continue
        if [ ! -d "$entry" ] || [ -L "$entry" ]; then
            log_error "Unsafe extracted root: $entry (must be a real directory, not a link)"
            return 1
        fi
        roots=$((roots + 1))
        root="$entry"
    done
    if [ "$roots" -ne 1 ]; then
        log_error "Expected exactly one extracted source root, found $roots"
        return 1
    fi
    printf '%s' "$root"
}

download_pinned_source() {
    local ref="$1" expected="$2"
    TAD_SRC_DOWNLOADED=0
    local tmp_root
    tmp_root=$(mktemp -d "$(resolve_tmpdir)/tad-update.XXXXXX") || { log_error "mktemp failed for pinned download"; exit 1; }
    chmod 700 "$tmp_root"
    local archive="$tmp_root/tad.tar.gz"
    local tag_url="https://github.com/Sheldon-92/TAD/archive/refs/tags/${ref}.tar.gz"

    log_info "  → Downloading pinned tag archive ${ref}..."
    curl -fsSL --max-time 60 "$tag_url" -o "$archive" 2>/dev/null || {
        log_error "Download failed for ${tag_url}"
        discard_tmp_root "$tmp_root"; exit 1
    }
    if [ ! -s "$archive" ]; then
        log_error "Downloaded archive is empty — refusing to continue"
        discard_tmp_root "$tmp_root"; exit 1
    fi
    # F-07: tar-slip member validation BEFORE extraction (both paths).
    validate_tar_members "$archive" || { discard_tmp_root "$tmp_root"; exit 1; }
    mkdir -p "$tmp_root/src"
    tar -xzf "$archive" -C "$tmp_root/src" 2>/dev/null || {
        log_error "Archive extraction failed"
        discard_tmp_root "$tmp_root"; exit 1
    }

    local root
    root="$(discover_single_source_root "$tmp_root")" || { discard_tmp_root "$tmp_root"; exit 1; }
    if [ ! -f "$root/.tad/version.txt" ]; then
        log_error "Pinned source has no .tad/version.txt — refusing to install"
        discard_tmp_root "$tmp_root"; TAD_SRC=""; exit 1
    fi

    TAD_SRC="$root"
    TAD_TMP_ROOT="$tmp_root"

    # Authoritative version comparison BEFORE any project mutation. Fail CLOSED
    # on a missing/empty version.txt: derive_target_version's literal fallback
    # must never stand in for an unverifiable archive version (FR-2 binding).
    derive_target_version "$TAD_SRC"
    if [ "$TARGET_VERSION" != "$expected" ]; then
        log_error "Pinned version mismatch: expected ${expected}, archive source contains ${TARGET_VERSION}"
        discard_tmp_root "$tmp_root"; TAD_SRC=""; TAD_TMP_ROOT=""; exit 1
    fi
    log_info "  → Pinned source verified: v${TARGET_VERSION} (ref ${ref})"
}

# download_unpinned_source — F-07: the mutable-main path extracts into a
# private mode-0700 temp root (TMPDIR-validated), never into the project cwd.
# Tar-slip members are rejected pre-extraction with zero outside writes.
download_unpinned_source() {
    TAD_SRC_DOWNLOADED=0
    local tmp_root
    tmp_root=$(mktemp -d "$(resolve_tmpdir)/tad-update.XXXXXX") || { log_error "mktemp failed for download"; exit 1; }
    chmod 700 "$tmp_root"
    local archive="$tmp_root/tad.tar.gz"

    log_info "  → Downloading TAD Framework v${TARGET_VERSION}..."
    curl -sSL --max-time 60 "$DOWNLOAD_URL" -o "$archive" 2>/dev/null \
        || curl -sSL --http1.1 --max-time 60 "$DOWNLOAD_URL" -o "$archive" 2>/dev/null \
        || {
            log_error "Download failed for $DOWNLOAD_URL"
            discard_tmp_root "$tmp_root"; exit 1
        }
    if [ ! -s "$archive" ]; then
        log_error "Downloaded archive is empty — refusing to continue"
        discard_tmp_root "$tmp_root"; exit 1
    fi
    # F-07: tar-slip member validation BEFORE extraction (both paths).
    validate_tar_members "$archive" || { discard_tmp_root "$tmp_root"; exit 1; }
    mkdir -p "$tmp_root/src"
    tar -xzf "$archive" -C "$tmp_root/src" 2>/dev/null || {
        log_error "Archive extraction failed"
        discard_tmp_root "$tmp_root"; exit 1
    }

    local root
    root="$(discover_single_source_root "$tmp_root")" || { discard_tmp_root "$tmp_root"; exit 1; }
    if [ ! -f "$root/.tad/version.txt" ]; then
        log_error "Downloaded source has no .tad/version.txt — refusing to install"
        discard_tmp_root "$tmp_root"; exit 1
    fi

    TAD_SRC="$root"
    TAD_TMP_ROOT="$tmp_root"
    TAD_SRC_DOWNLOADED=1

    derive_target_version "$TAD_SRC"
    log_info "  → Source version: v${TARGET_VERSION}"
}

# ============================================
# OpenCode updater-only projection (FR-4)
# ============================================
# Every install/upgrade mode projects exactly ONE TAD-owned command into
# .opencode/commands/: tad-update.md. This function:
#   - PREFLIGHT: if the target file already exists and differs from the source,
#     fail before ANY .tad/.claude/.agents/root-file/.opencode mutation and print
#     the deterministic recovery instruction. Identical content is accepted.
#   - PROJECT: create parent dirs as needed, copy only that one file, and compare
#     it with the source (byte-identical).
#   - ROLLBACK: if this run created the file, record that fact so rollback can
#     remove exactly that TAD-created file (and empty TAD-created parents),
#     never pre-existing OpenCode content.
# Never deletes or recursively synchronizes .opencode.
OPCODE_CREATED_FILE=0

opencode_preflight() {
    local src="$1"
    local src_f="$src/.opencode/commands/tad-update.md"
    local tgt_f=".opencode/commands/tad-update.md"
    [ -f "$src_f" ] || return 0
    if [ -f "$tgt_f" ] && ! cmp -s "$src_f" "$tgt_f"; then
        log_error "OpenCode conflict: .opencode/commands/tad-update.md already exists and differs from TAD's copy."
        echo "  Recovery: rename or remove your file, then re-run the installer. Example:"
        echo "    mv .opencode/commands/tad-update.md .opencode/commands/tad-update.md.local"
        echo "  No files were changed by this run."
        exit 1
    fi
}

project_opencode_command() {
    local src="$1"
    local src_f="$src/.opencode/commands/tad-update.md"
    [ -f "$src_f" ] || return 0
    local tgt_f=".opencode/commands/tad-update.md"

    if [ ! -f "$tgt_f" ]; then
        OPCODE_CREATED_FILE=1
    fi
    mkdir -p .opencode/commands
    cp "$src_f" "$tgt_f"
    if ! cmp -s "$src_f" "$tgt_f"; then
        log_error "OpenCode projection verification FAILED: .opencode/commands/tad-update.md differs from source"
        return 1
    fi
    log_success "  → Projected .opencode/commands/tad-update.md (updater-only)"
}

# Rollback of an OpenCode command created by THIS run: remove exactly the file
# this run created plus empty TAD-created parent directories. Never touches
# pre-existing OpenCode content (the preflight guarantees a divergent file was
# never reached, so only a fresh creation can be undone here).
rollback_opencode_projection() {
    if [ "$OPCODE_CREATED_FILE" = "1" ]; then
        # F-06: absolute-target-only (the pre-fix relative form is the
        # foreign-cwd clobber class). Empty-dir rmdirs keep `|| true`: a
        # non-empty dir (user content) must NOT fail the rollback.
        local _t="${TARGET_ROOT:-.}"
        rm -f "$_t/.opencode/commands/tad-update.md" # RM-OK:rollback-opencode-created
        rmdir "$_t/.opencode/commands" 2>/dev/null || true # RM-OK:rollback-opencode-rmdir-commands
        rmdir "$_t/.opencode" 2>/dev/null || true # RM-OK:rollback-opencode-rmdir-root
    fi
}
main() {
    echo ""
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}   TAD Framework v${TARGET_VERSION}${NC}"
    echo -e "${CYAN}   Claude Code Integration${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo ""

    validate_environment

    # Resolve platform (from --platform flag or auto-detect)
    resolve_platform

    # Set platform-aware skill directory (used by copy, verify, and main)
    # "both" uses .claude/skills as primary + .agents/skills as secondary
    if [ "$PLATFORM" = "codex" ]; then
        TARGET_SKILL_DIR=".agents/skills"
    else
        TARGET_SKILL_DIR=".claude/skills"
    fi

    # Codex CLI version detection (non-blocking)
    if [ "$PLATFORM" = "codex" ]; then
        if command -v codex >/dev/null 2>&1; then
            local codex_version
            codex_version=$(codex --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
            codex_version="${codex_version:-unknown}"
            log_info "Codex CLI detected: $codex_version"
            if ! codex --help 2>/dev/null </dev/null | grep -q 'skills\|\.agents'; then
                log_warn "Codex CLI may not support skills system. TAD skills will be installed but may not auto-load. Consider upgrading Codex CLI."
            fi
        else
            log_warn "Codex CLI not found. Installing TAD files for Codex layout, but codex command unavailable."
        fi
    fi

    echo ""

    if [ "$SOURCE_MODE" = "1" ]; then
        # FR-1 offline: the target was already derived from the trusted tree at
        # arg-parse time — the probe is bypassed (same as the pinned branch) and
        # the network is never touched.
        :
    elif [ "$PINNED_MODE" != "1" ]; then
        probe_remote_version
    else
        # Pinned mode: the target comes from the validated immutable tag archive,
        # never from a mutable-main probe (FR-2). TARGET_VERSION was already set
        # from the pinned expected version.
        TARGET_VERSION="$EXPECTED_VERSION"
    fi
    STATE=$(detect_state)
    CURRENT_VERSION="none"
    if [ -f ".tad/version.txt" ]; then
        CURRENT_VERSION=$(cat .tad/version.txt)
        CURRENT_VERSION="${CURRENT_VERSION//[$'\r\n ']/}"   # CRLF/whitespace trim (align with detect_state L1349)
    fi

    # Display current state
    echo -e "${BLUE}📍 Installation Status:${NC}"
    echo ""

    case $STATE in
        "fresh")
            echo -e "   Status: ${GREEN}Fresh install${NC}"
            echo "   No existing TAD installation found"
            ACTION="install"
            ;;
        "current")
            echo -e "   Status: ${GREEN}Already v${TARGET_VERSION}${NC}"
            echo "   You're on the latest version!"
            ACTION="none"
            ;;
        "upgrade")
            echo -e "   Status: ${YELLOW}Upgrade available${NC}"
            echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
            echo "   (Framework upgrade)"
            ACTION="upgrade"
            ;;
        "v1.8")
            echo -e "   Status: ${YELLOW}Upgrade available${NC}"
            echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
            ACTION="upgrade"
            ;;
        "v1.6")
            echo -e "   Status: ${YELLOW}Upgrade available${NC}"
            echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
            ACTION="upgrade"
            ;;
        "v1.4"|"old")
            echo -e "   Status: ${YELLOW}Migration + Upgrade needed${NC}"
            echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
            ACTION="migrate"
            ;;
        "partial")
            echo -e "   Status: ${YELLOW}Partial installation${NC}"
            echo "   Will complete installation"
            ACTION="install"
            ;;
    esac

    echo ""

    # If already current, check --force
    if [ "$ACTION" == "none" ]; then
        if [ "$PINNED_MODE" = "1" ]; then
            # Pinned mode target is exact by construction (tag archive verified
            # against expected version); current == expected is a true no-op.
            echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
            echo ""
            exit 0
        elif [ "$FORCE" = "1" ]; then
            local cmp_result
            cmp_result="$(_tad_ver_cmp "$CURRENT_VERSION" "$TARGET_VERSION")"
            if [ "$cmp_result" = "0" ]; then
                log_info "Force reinstall requested (same version: $CURRENT_VERSION)"
                ACTION="upgrade"
            else
                log_warn "Installed v${CURRENT_VERSION} is NEWER than target v${TARGET_VERSION}. --force does not downgrade."
                exit 0
            fi
        elif [ "$PROBE_OK" != "1" ]; then
            # 目标版本未经证实（探测失败）——绝不基于猜测宣称已是最新。
            # 继续走下去，由 M7 的权威复判定夺；最坏结果是一次多余的重装，
            # 而不是一次静默的不升级。
            ACTION="upgrade"
        else
            echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
            echo ""
            echo "Available commands:"
            echo "  /alex, /blake, /gate     - Default"
            echo "  /alex-lite, /blake-lite  - Frozen experiment (still usable if invoked explicitly)"
            echo ""
            exit 0
        fi
    fi

    # Show what will happen
    echo -e "${BLUE}📋 What will happen:${NC}"
    echo ""

    case $ACTION in
        "install")
            echo "  1. Create .tad/ directory structure"
            echo "  2. Create .tad/skills/ with 8 P0 skills (NEW)"
            echo "  3. Create $TARGET_SKILL_DIR/ with TAD skill files"
            echo "  4. Create CLAUDE.md project rules"
            ;;
        "upgrade")
            echo "  1. Update $TARGET_SKILL_DIR/"
            echo "  2. Install .tad/skills/ (8 P0 skills) (NEW)"
            echo "  3. Update .tad/config.yaml and templates/"
            echo ""
            echo -e "  ${GREEN}✓ Preserved:${NC} handoffs, evidence, project-knowledge"
            ;;
        "migrate")
            echo "  1. Backup existing .tad/ to a unique .tad-migrate-backup.*/ directory"
            echo "  2. Create new v2.1 directory structure"
            echo "  3. Migrate your handoffs and evidence"
            echo "  4. Install skills"
            echo ""
            echo -e "  ${GREEN}✓ Preserved:${NC} All your work data will be migrated"
            ;;
    esac

    echo ""
    if [ "$AUTO_YES" = "1" ]; then
        REPLY="y"
        echo "Continue? (y/n): y  [--yes]"
    else
        # EOF guard: a non-TTY run WITHOUT --yes degrades to clean "Cancelled."
        # instead of a set -e opaque abort when /dev/tty is unavailable.
        read -p "Continue? (y/n): " -n 1 -r < /dev/tty || REPLY=""
        echo ""
    fi

    # ${REPLY:-} is set -u-safe on BOTH paths regardless of branch assignment.
    if [[ ! ${REPLY:-} =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo ""
    log_info "Downloading TAD Framework v${TARGET_VERSION}..."

    if [ "$SOURCE_MODE" = "1" ]; then
        # FR-1 offline: skip curl/tar entirely. TAD_SRC is the validated
        # user-supplied tree (TAD_SRC_DOWNLOADED=0) — cleanup stays inert
        # for it via the single cleanup_source_tree chokepoint (FR-1b).
        log_info "  → Offline source: $TAD_SRC (no download; probe bypassed)"
        log_info "  → Source version: v${TARGET_VERSION}"
    elif [ "$PINNED_MODE" = "1" ]; then
        download_pinned_source "$RELEASE_REF" "$EXPECTED_VERSION"
    else
        # Unpinned mutable-main path: temp-dir extraction (F-07), never cwd.
        download_unpinned_source
    fi

    # ROOT FIX：「已是最新」的判定，要么在状态闸用探测到的实时版本完成（探测成功，
    # 多数情况），要么推迟到这里用已下载源树的版本确认（探测失败）。两条路径都不再
    # 依赖 L22 的字面量，因此字面量陈旧不可能再产生静默 no-op。本块是后一条路径。
    if [ "$FORCE" != "1" ] && [ "$CURRENT_VERSION" != "none" ] \
       && [ "$(_tad_ver_cmp "$CURRENT_VERSION" "$TARGET_VERSION")" != "-1" ]; then
        # FR-1b: 只清理本次下载产生的临时目录。--source <dir> 传入的用户
        # 路径（TAD_SRC_DOWNLOADED=0）绝不能删 —— 经由单一 cleanup_source_tree
        # 收口（AC 断言：没有别的 rm 引用 TAD_SRC）。
        cleanup_source_tree
        echo ""
        echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
        exit 0
    fi

    # OpenCode collision preflight — AFTER immutable version validation, BEFORE
    # any project mutation. A divergent existing .opencode/commands/tad-update.md
    # fails here with zero changes across every managed surface and prints the
    # deterministic rename/remove recovery instruction.
    opencode_preflight "$TAD_SRC"

    # FR-1: the normal project backup occurs immediately before the first
    # project mutation — AFTER download, immutable-version validation, platform
    # resolution, OpenCode collision preflight, and human confirmation. A failed
    # backup aborts (set -e → EXIT trap → rollback) before any copy/migration.
    backup_existing
    # From here on, any non-success exit restores the project from the backup.
    NEED_ROLLBACK=1
    # F-06: absolutize target + backup and snapshot every mutable surface
    # (CLAUDE.md, skills trees, root files, hooks.json, settings/workflows)
    # BEFORE the first project mutation below.
    take_rollback_snapshot

    # Execute based on action
    case $ACTION in
        "install")
            log_info "Installing TAD Framework..."

            # Create project-specific directories (not in source repo)
            mkdir -p .tad/active/handoffs
            mkdir -p .tad/active/designs
            mkdir -p .tad/active/epics
            mkdir -p .tad/active/playground
            mkdir -p .tad/archive/handoffs
            mkdir -p .tad/archive/epics
            mkdir -p .tad/archive/playground
            mkdir -p .tad/evidence/reviews
            mkdir -p .tad/evidence/completions
            mkdir -p .tad/evidence/ralph-loops
            mkdir -p .tad/evidence/reviews/_iterations
            mkdir -p .tad/evidence/pair-tests
            mkdir -p .tad/evidence/acceptance-tests
            mkdir -p .tad/project-knowledge
            mkdir -p .tad/pair-testing
            mkdir -p .tad/reports
            mkdir -p "$TARGET_SKILL_DIR"

            # Copy ALL framework files (comprehensive sync)
            copy_framework_files "$TAD_SRC"

            # Copy project-knowledge README
            cp -r "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

            # Copy root files
            # F-03 (EPIC-20260816 Phase 2 / 审计): install 分支原为裸 cp，会无声覆盖用户
            # 已有的 CLAUDE.md。detect_state 在 .tad/ 与 .claude/commands/ 均不存在时返回
            # fresh —— 那正是「有自写 CLAUDE.md 但从未装过 TAD」的用户状态。
            # merge_claude_md 自身已处理全新项目（无 CLAUDE.md 时直接 cp）。
            merge_claude_md "$TAD_SRC"

            # Create user files if not exist
            if [ ! -f "PROJECT_CONTEXT.md" ]; then
                cat > PROJECT_CONTEXT.md << 'CTXEOF'
# Project Context

## Project Name
[Your Project Name]

## Description
[Brief project description]

## Tech Stack
- [Technology 1]
- [Technology 2]

## Key Decisions
(Alex will update this during development)

---
*Last Updated: [Date]*
CTXEOF
                note_created_top "PROJECT_CONTEXT.md"
            fi

            if [ ! -f "NEXT.md" ]; then
                cat > NEXT.md << 'NEXTEOF'
# Next Steps

## Today

- [ ] [Your first task]

## This Week

- [ ] [Upcoming tasks]

## Completed

(Move completed items here)

---
*Managed by TAD Framework*
NEXTEOF
                note_created_top "NEXT.md"
            fi

            # Hint: codebase-memory-mcp for code intelligence (opt-in, user installs manually)
            if ! command -v codebase-memory-mcp >/dev/null 2>&1; then
                printf "  [TIP] Optional: install codebase-memory-mcp for code graph intelligence:\n"
                printf "     curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/v0.7.0/install.sh | bash\n"
                printf "     (see .tad/guides/codebase-memory-integration.md for details)\n"
            fi

            # Set version
            echo "$TARGET_VERSION" > .tad/version.txt
            ;;

        "upgrade")
            log_info "Upgrading to v${TARGET_VERSION}..."

            # Ensure project-specific directories exist
            mkdir -p .tad/active/handoffs
            mkdir -p .tad/active/designs
            mkdir -p .tad/active/epics
            mkdir -p .tad/active/playground
            mkdir -p .tad/archive/handoffs
            mkdir -p .tad/archive/epics
            mkdir -p .tad/archive/playground
            mkdir -p .tad/evidence/reviews
            mkdir -p .tad/evidence/completions
            mkdir -p .tad/evidence/ralph-loops
            mkdir -p .tad/evidence/reviews/_iterations
            mkdir -p .tad/evidence/pair-tests
            mkdir -p .tad/evidence/acceptance-tests
            mkdir -p .tad/project-knowledge
            mkdir -p .tad/pair-testing
            mkdir -p .tad/reports

            # Archive legacy top-level skill files (F-08: unique timestamped
            # dir per run via the shared increment loop — never skip-if-exists).
            archive_old_skill_mds ".claude/skills"

            # Copy ALL framework files (comprehensive sync)
            copy_framework_files "$TAD_SRC"

            # Run migration engine (after copy makes engine available; before version.txt update)
            call_migration_engine "$TAD_SRC" "$CURRENT_VERSION" "$TARGET_VERSION"

            # Update CLAUDE.md (merge: preserve project content below marker)
            log_info "  → Updating CLAUDE.md..."
            merge_claude_md "$TAD_SRC"

            # Update project-knowledge README
            cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

            # Hint: codebase-memory-mcp for code intelligence (opt-in, user installs manually)
            if ! command -v codebase-memory-mcp >/dev/null 2>&1; then
                printf "  [TIP] Optional: install codebase-memory-mcp for code graph intelligence:\n"
                printf "     curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/v0.7.0/install.sh | bash\n"
                printf "     (see .tad/guides/codebase-memory-integration.md for details)\n"
            fi

            # Set version
            echo "$TARGET_VERSION" > .tad/version.txt
            ;;

        "migrate")
            log_info "Migrating and upgrading to v${TARGET_VERSION}..."

            # Structural backup for v1.x→v2.x migration (separate from engine's .tad-backup/)
            # FR-1: unique destination captured ONCE; never delete or overwrite a
            # pre-existing recovery copy; every later migration read and the final
            # report use the same captured variable.
            log_info "  → Creating migration backup..."
            local mb_base=".tad-migrate-backup.$(date +%Y%m%d_%H%M%S)"
            MIGRATE_BACKUP_DIR="$mb_base"
            local mb_n=1
            while [ -e "$MIGRATE_BACKUP_DIR" ]; do
                MIGRATE_BACKUP_DIR="${mb_base}.$mb_n"
                mb_n=$((mb_n + 1))
            done
            cp -R .tad "$MIGRATE_BACKUP_DIR"

            # Create project-specific directories
            mkdir -p .tad/active/handoffs
            mkdir -p .tad/active/designs
            mkdir -p .tad/active/epics
            mkdir -p .tad/active/playground
            mkdir -p .tad/archive/handoffs
            mkdir -p .tad/archive/epics
            mkdir -p .tad/archive/playground
            mkdir -p .tad/evidence/reviews
            mkdir -p .tad/evidence/completions
            mkdir -p .tad/evidence/ralph-loops
            mkdir -p .tad/evidence/reviews/_iterations
            mkdir -p .tad/evidence/pair-tests
            mkdir -p .tad/evidence/acceptance-tests
            mkdir -p .tad/project-knowledge
            mkdir -p .tad/pair-testing
            mkdir -p .tad/reports

            # Migrate user data from backup (old directory layouts)
            # cp -R (not -r): the backup may contain user-owned dangling
            # symlinks; lowercase -r would dereference and fail, dropping the
            # migration for that subtree (same class as FR-1).
            log_info "  → Migrating user data..."
            if [ -d "$MIGRATE_BACKUP_DIR/handoffs" ]; then
                cp -R "$MIGRATE_BACKUP_DIR/handoffs/"* .tad/active/handoffs/ 2>/dev/null || true
            fi
            if [ -d "$MIGRATE_BACKUP_DIR/active/handoffs" ]; then
                cp -R "$MIGRATE_BACKUP_DIR/active/handoffs/"* .tad/active/handoffs/ 2>/dev/null || true
            fi
            if [ -d "$MIGRATE_BACKUP_DIR/working" ]; then
                cp -R "$MIGRATE_BACKUP_DIR/working/"* .tad/active/ 2>/dev/null || true
            fi
            if [ -d "$MIGRATE_BACKUP_DIR/context" ]; then
                cp -R "$MIGRATE_BACKUP_DIR/context/"* .tad/active/ 2>/dev/null || true
            fi

            # Archive legacy top-level skill files (F-08: same unique
            # timestamped-dir rule as the upgrade branch).
            archive_old_skill_mds ".claude/skills"

            # Copy ALL framework files (comprehensive sync)
            copy_framework_files "$TAD_SRC"

            # Run migration engine (after copy makes engine available; before version.txt update)
            call_migration_engine "$TAD_SRC" "$CURRENT_VERSION" "$TARGET_VERSION"

            # Merge CLAUDE.md (preserve project content below marker)
            merge_claude_md "$TAD_SRC"

            # Copy project-knowledge README
            cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

            # Create user files if not exist
            if [ ! -f "PROJECT_CONTEXT.md" ]; then
                cat > PROJECT_CONTEXT.md << 'CTXEOF'
# Project Context

## Project Name
[Your Project Name]

## Description
[Brief project description]

## Tech Stack
- [Technology 1]
- [Technology 2]

## Key Decisions
(Alex will update this during development)

---
*Last Updated: [Date]*
CTXEOF
                note_created_top "PROJECT_CONTEXT.md"
            fi

            if [ ! -f "NEXT.md" ]; then
                cat > NEXT.md << 'NEXTEOF'
# Next Steps

## Today

- [ ] [Your first task]

## This Week

- [ ] [Upcoming tasks]

## Completed

(Move completed items here)

---
*Managed by TAD Framework*
NEXTEOF
                note_created_top "NEXT.md"
            fi

            # Hint: codebase-memory-mcp for code intelligence (opt-in, user installs manually)
            if ! command -v codebase-memory-mcp >/dev/null 2>&1; then
                printf "  [TIP] Optional: install codebase-memory-mcp for code graph intelligence:\n"
                printf "     curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/v0.7.0/install.sh | bash\n"
                printf "     (see .tad/guides/codebase-memory-integration.md for details)\n"
            fi

            # Set version
            echo "$TARGET_VERSION" > .tad/version.txt

            echo ""
            log_success "Backup saved to $MIGRATE_BACKUP_DIR/"
            ;;
    esac

    # Validate everything
    validate_generated_configs
    # Success path: snapshot consumed (recovery copy no longer needed), then
    # disarm rollback so the EXIT trap leaves the tree in place.
    discard_rollback_snap
    NEED_ROLLBACK=0

    # Cleanup
    # FR-1b: 只清理本次下载产生的临时目录。--source <dir> 传入的用户路径绝不能删
    # —— 经由单一 cleanup_source_tree 收口（AC 断言：没有别的 rm 引用 TAD_SRC）。
    # 下载产生的 temp root 由 EXIT trap 经 cleanup_installer_temp 清理。
    cleanup_source_tree

    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}   ✅ TAD v${TARGET_VERSION} Ready!${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo "Directory structure:"
    echo "  .tad/"
    echo "  ├── active/handoffs/     # Current work"
    echo "  ├── agents/              # Agent definitions"
    echo "  ├── archive/handoffs/    # Completed work"
    echo "  ├── evidence/            # Gate & test evidence"
    echo "  ├── pair-testing/        # Pair test sessions"
    echo "  ├── project-knowledge/   # Project-specific knowledge"
    echo "  ├── ralph-config/        # Ralph Loop configuration"
    echo "  ├── skills/              # Platform-agnostic skills"
    echo "  ├── sub-agents/          # Sub-agent definitions"
    echo "  └── templates/           # Handoff & output templates"
    echo ""
    echo "Quick start:"
    echo "  1. Restart Claude Code (or open new terminal)"
    echo -e "  2. ${CYAN}/alex${NC}, ${CYAN}/blake${NC}, ${CYAN}/gate${NC} (default) · ${CYAN}/alex-lite${NC}, ${CYAN}/blake-lite${NC} (frozen)"

    echo ""
    echo "Learn more: ${BLUE}${REPO_URL}${NC}"
    echo ""
}

# Run main function
main
