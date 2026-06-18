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
# repo's .tad/version.txt at download time (see derive_target_version), so this
# literal can never go stale (fixes the 2.19.1-class hand-edit straggler).
# It is used ONLY before the source is fetched (banner) and as a last-resort
# fallback if the source version.txt is unreadable.
TARGET_VERSION="2.31.1"
REPO_URL="https://github.com/Sheldon-92/TAD"
DOWNLOAD_URL="https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz"

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

# Global variables
BACKUP_PATH=""
DETECTED_PLATFORMS=""

# Argument parsing — while-loop + shift (supports --key value two-token args).
# --yes/-y skips the interactive confirmation prompt (non-TTY: Claude Code Bash,
# CI, curl|bash). "$@" is set -u-safe even with zero args.
AUTO_YES=0
VERIFY_DENYLIST=0
FORCE=0
PLATFORM=""
PACKS=""
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
    --help|-h)
      echo "Usage: tad.sh [--yes|-y] [--force] [--platform <name>] [--packs <list>] [--verify-denylist]"
      echo "  --yes              skip the interactive confirmation prompt"
      echo "  --force            reinstall even if already on the same version"
      echo "  --platform <name>  target platform (claude-code, codex). Default: claude-code"
      echo "  --packs <list>     comma-separated pack names to install (default: all)"
      echo "  --verify-denylist  (TAD repo only) assert tad.sh's inlined DENY_LIST == derive-sync-set.sh"
      exit 0 ;;
    *) echo "tad.sh: unknown option '$1' (use --help)" >&2; exit 1 ;;
  esac
done

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
    local backup_dir=".tad.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -d ".tad" ]; then
        log_info "Backing up existing .tad/ to $backup_dir"
        cp -r .tad "$backup_dir"
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
        PLATFORM="claude-code"
        if command -v claude &> /dev/null || [ -d "$HOME/.claude" ]; then
            log_info "Detected: Claude Code (default platform)"
        else
            log_warn "Claude Code not detected. Using default platform: claude-code"
        fi
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
github-registry
research-notebooks
skill-library
skillify-candidates"
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

# generate_pack_meta <skill_dir> — write .tad-pack-meta.yaml with SHA-256 hashes
generate_pack_meta() {
    local skill_dir="$1"
    skill_dir="${skill_dir%/}"
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
        find "$skill_dir" -type f -not -name '.tad-pack-meta.yaml' -not -path '*/local/*' | sort | while read -r f; do
            local rel
            rel="${f#"$skill_dir"/}"
            local hash
            hash="$($sha_cmd "$f" 2>/dev/null | cut -d' ' -f1)" || continue
            printf '  - path: "%s"\n' "$rel"
            printf '    sha256: "%s"\n' "$hash"
        done
    } > "$meta_file"
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

    # --- .tad/ framework files (copy everything except project data) ---

    # Top-level config & metadata files — DENY-LIST derived (every regular file
    # under $src/.tad/ EXCEPT TAD_TOP_DENY), NOT a fixed extension allow-list.
    # A new top-level framework file (.sh/.json/…) auto-copies — this is what
    # makes .tad/portable-extract.sh land on a fresh machine.
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
            cp -r "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"
        done
    fi
    # settings.json — platform deny check
    if ! is_denied ".claude/settings.json" "$platform_deny"; then
        cp "$src"/.claude/settings.json .claude/ 2>/dev/null || true
    fi
    # Workflow scripts — platform deny check
    if ! is_denied ".claude/workflows" "$platform_deny"; then
        if [ -d "$src/.claude/workflows" ]; then
            mkdir -p .claude/workflows
            cp -r "$src"/.claude/workflows/* .claude/workflows/ 2>/dev/null || true
        fi
    fi

    # --- Pack meta generation (Phase 1: hash manifest) ---
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
                generate_pack_meta "$skill_dir_m" || log_warn "Meta generation failed for $sn, skipping"
            done
        done
    fi

    # --- Deprecation cleanup (v2.8.2) ---
    # Read .tad/deprecation.yaml and delete files listed for deprecation
    # versions ≤ current TARGET_VERSION. Previously no deprecation processing,
    # which caused 2.8.1 command file cleanup to never execute on downstream projects.
    apply_deprecations "$src"

    # --- Root files from platform extra_root_files ---
    # Placed AFTER apply_deprecations because deprecation.yaml v2.3.0 removes
    # AGENTS.md (old full-runtime cleanup). For codex platform, we re-install it.
    local root_files=""
    if [ -f "$src/.tad/platform-codes.yaml" ]; then
        root_files="$(parse_platform_root_files "$src/.tad/platform-codes.yaml" "$PLATFORM")"
    fi
    if [ -n "$root_files" ]; then
        local rf
        while IFS= read -r rf; do
            [ -n "$rf" ] || continue
            if [ -f "$src/$rf" ]; then
                cp "$src/$rf" ./ 2>/dev/null || true
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
                cp -r "$skill_dir_b" ".agents/skills/$skill_name_b"
            done
        fi
        log_info "  → Copied skills to .agents/skills/ (Codex secondary path)"
    fi

    # --- Codex hooks.json generation ---
    if [ "$PLATFORM" = "codex" ] || [ "$PLATFORM" = "both" ]; then
        mkdir -p .codex
        cat > .codex/hooks.json << 'HOOKS_EOF'
{
  "SessionStart": [
    {
      "matcher": "startup|resume",
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
# Reads .tad/deprecation.yaml and removes files listed for versions
# from (old_version, current_version]. Simple semver parser — no yq dependency.
# Safe: deletion errors are non-fatal.
apply_deprecations() {
    local src="$1"
    local dep_file="$src/.tad/deprecation.yaml"

    [ -f "$dep_file" ] || return 0

    # Read TARGET_VERSION (MAJOR.MINOR) and actual full version
    local current_version
    if [ -f ".tad/version.txt" ]; then
        current_version=$(head -1 .tad/version.txt | tr -d '[:space:]')
    elif [ -f "$src/.tad/version.txt" ]; then
        current_version=$(head -1 "$src/.tad/version.txt" | tr -d '[:space:]')
    else
        current_version="${TARGET_VERSION}"
    fi

    log_info "  → Applying deprecations for versions ≤ $current_version..."

    local deleted=0
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
                    rm -rf -- "$target" 2>/dev/null && deleted=$((deleted + 1))
                fi
            fi
        fi
    done < "$dep_file"

    if [ "$deleted" -gt 0 ]; then
        log_success "  → Removed $deleted deprecated file(s)"
    else
        log_info "  → No deprecated files to remove"
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
# Phase 7: Rollback on Failure
# ============================================
rollback_on_failure() {
    log_error "Installation failed. Rolling back..."

    if [ -n "${BACKUP_PATH:-}" ] && [ -d "$BACKUP_PATH" ]; then
        rm -rf .tad
        mv "$BACKUP_PATH" .tad
        log_info "Restored from backup: $BACKUP_PATH"
    fi

    log_error "Rollback complete. Please check logs."
    exit 1
}

# --verify-denylist: release-time drift check. Runs BEFORE the rollback trap is
# set (it must never trigger rollback) and exits immediately — it never installs.
if [ "$VERIFY_DENYLIST" = "1" ]; then
    verify_denylist_drift
    exit $?
fi

# Set trap for automatic rollback
trap 'rollback_on_failure' ERR

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

    # Always backup first
    cp "CLAUDE.md" "CLAUDE.md.bak"

    local marker_line
    marker_line=$(grep -nF "$marker" "CLAUDE.md" | head -1 | cut -d: -f1 || true)

    if [ -n "$marker_line" ]; then
        local content_start=$((marker_line + 1))

        local tmpfile
        tmpfile=$(mktemp "CLAUDE.md.merge.XXXXXX")

        # Invariant: source CLAUDE.md MUST end with the marker as its last line.
        # The full source (including marker) is written, then project content appended.
        cat "$src/CLAUDE.md" > "$tmpfile" || { rm -f "$tmpfile"; return 1; }

        # tail -n +N on a file shorter than N lines outputs nothing (safe no-op)
        tail -n +"$content_start" "CLAUDE.md" >> "$tmpfile" || { rm -f "$tmpfile"; return 1; }

        mv "$tmpfile" "CLAUDE.md" || { rm -f "$tmpfile"; return 1; }
        log_success "  → CLAUDE.md merged (project content preserved below marker)"
        rm -f "CLAUDE.md.bak"
    else
        cp "$src/CLAUDE.md" ./
        log_warn "CLAUDE.md backed up to CLAUDE.md.bak (no merge marker found)"
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
            case "$ver" in
                1.8*)        echo "v1.8" ;;        # preserve existing v1.x granular routing
                1.6*|1.5*)   echo "v1.6" ;;
                1.4*)        echo "v1.4" ;;
                *)           echo "old" ;;         # incl. v2-into-newer-major → migrate (gets .tad-migrate-backup)
            esac
        fi
    elif [ -d ".tad" ]; then
        echo "old"
    else
        echo "partial"
    fi
}

# ============================================
# Main Installation Flow
# ============================================
main() {
    echo ""
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}   TAD Framework v${TARGET_VERSION}${NC}"
    echo -e "${CYAN}   Claude Code Integration${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo ""

    validate_environment
    backup_existing

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

    STATE=$(detect_state)
    CURRENT_VERSION="none"
    if [ -f ".tad/version.txt" ]; then
        CURRENT_VERSION=$(cat .tad/version.txt)
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
        if [ "$FORCE" = "1" ]; then
            local cmp_result
            cmp_result="$(_tad_ver_cmp "$CURRENT_VERSION" "$TARGET_VERSION")"
            if [ "$cmp_result" = "0" ]; then
                log_info "Force reinstall requested (same version: $CURRENT_VERSION)"
                ACTION="upgrade"
            else
                log_warn "Installed v${CURRENT_VERSION} is NEWER than target v${TARGET_VERSION}. --force does not downgrade."
                exit 0
            fi
        else
            echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
            echo ""
            echo "Available commands:"
            echo "  /alex  - Start Agent A (Solution Lead)"
            echo "  /blake - Start Agent B (Execution Master)"
            echo "  /gate  - Run quality gate"
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
            echo "  1. Backup existing .tad/ to .tad-migrate-backup/"
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

    # Download (--http1.1 fallback for GitHub HTTP2 framing errors)
    curl -sSL "$DOWNLOAD_URL" | tar -xz 2>/dev/null || \
    curl -sSL --http1.1 "$DOWNLOAD_URL" | tar -xz
    TAD_SRC="TAD-main"

    # AC2: derive the authoritative version from the freshly-downloaded source's
    # .tad/version.txt — so TARGET_VERSION can never go stale vs the literal above.
    derive_target_version "$TAD_SRC"
    log_info "  → Source version: v${TARGET_VERSION}"

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
            cp "$TAD_SRC"/CLAUDE.md ./

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

            # Archive old skills if needed
            if [ -d ".claude/skills" ] && [ ! -d ".claude/skills/_archived" ]; then
                mkdir -p .claude/skills/_archived
                for f in .claude/skills/*.md; do
                    if [ -f "$f" ] && [ "$(basename "$f")" != "doc-organization.md" ]; then
                        mv "$f" .claude/skills/_archived/ 2>/dev/null || true
                    fi
                done
            fi

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
            log_info "  → Creating migration backup..."
            if [ -d ".tad-migrate-backup" ]; then
                rm -rf .tad-migrate-backup
            fi
            cp -r .tad .tad-migrate-backup

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
            if [ -d ".claude/skills" ]; then
                mkdir -p .claude/skills/_archived
            fi

            # Migrate user data from backup (old directory layouts)
            log_info "  → Migrating user data..."
            if [ -d ".tad-migrate-backup/handoffs" ]; then
                cp -r .tad-migrate-backup/handoffs/* .tad/active/handoffs/ 2>/dev/null || true
            fi
            if [ -d ".tad-migrate-backup/active/handoffs" ]; then
                cp -r .tad-migrate-backup/active/handoffs/* .tad/active/handoffs/ 2>/dev/null || true
            fi
            if [ -d ".tad-migrate-backup/working" ]; then
                cp -r .tad-migrate-backup/working/* .tad/active/ 2>/dev/null || true
            fi
            if [ -d ".tad-migrate-backup/context" ]; then
                cp -r .tad-migrate-backup/context/* .tad/active/ 2>/dev/null || true
            fi

            # Archive old skills if needed
            if [ -d ".claude/skills" ]; then
                for f in .claude/skills/*.md; do
                    if [ -f "$f" ] && [ "$(basename "$f")" != "doc-organization.md" ]; then
                        mv "$f" .claude/skills/_archived/ 2>/dev/null || true
                    fi
                done
            fi

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
            log_success "Backup saved to .tad-migrate-backup/"
            ;;
    esac

    # Validate everything
    validate_generated_configs

    # Cleanup
    rm -rf "$TAD_SRC"

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
    echo -e "  2. ${CYAN}/alex${NC}, ${CYAN}/blake${NC}, ${CYAN}/gate${NC}"

    echo ""
    echo "Learn more: ${BLUE}${REPO_URL}${NC}"
    echo ""
}

# Run main function
main
