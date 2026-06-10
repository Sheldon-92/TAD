#!/usr/bin/env bash
# migration-engine.sh — TAD Migration Manifest Engine v1
# Consumes .tad/migrations/{from}-to-{to}.yaml manifests (schema v1)
# and safely executes rename/delete/verify operations.
#
# Usage: bash migration-engine.sh --from <ver> --to <ver> --target <dir> --source <dir> [--dry-run]
# Exit codes: 0=success, 1=execution failure (fail-fast), 2=refused (manifest invalid/env error, zero writes)
set -euo pipefail

ENGINE_VERSION="2.29.0"

# ══════════════════════════════════════════════════════════════
# Argument parsing (FR1)
# ══════════════════════════════════════════════════════════════
FROM_VER="" TO_VER="" TARGET="" SOURCE="" DRY_RUN=0

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --from)   FROM_VER="$2"; shift 2 ;;
            --to)     TO_VER="$2"; shift 2 ;;
            --target) TARGET="$2"; shift 2 ;;
            --source) SOURCE="$2"; shift 2 ;;
            --dry-run) DRY_RUN=1; shift ;;
            *) printf 'ERROR: unknown argument: %s\n' "$1" >&2; exit 2 ;;
        esac
    done
    if [ -z "$FROM_VER" ] || [ -z "$TO_VER" ] || [ -z "$TARGET" ] || [ -z "$SOURCE" ]; then
        printf 'Usage: migration-engine.sh --from <ver> --to <ver> --target <dir> --source <dir> [--dry-run]\n' >&2
        exit 2
    fi
    if [ ! -d "$TARGET" ] || [ ! -d "$SOURCE" ]; then
        printf 'ERROR: --target and --source must be existing directories\n' >&2
        exit 2
    fi
}

# ══════════════════════════════════════════════════════════════
# Path validator — extracted from schema doc (Steps 1-3)
# ══════════════════════════════════════════════════════════════
validate_path() {
    local p="$1"
    if [ -z "$p" ] || [ -z "$(printf '%s' "$p" | tr -d '[:space:]')" ]; then
        printf 'REJECT: empty or whitespace-only path\n' >&2; return 1
    fi
    if printf '%s' "$p" | grep -qE '^[[:space:]]|[[:space:]]$'; then
        printf 'REJECT: leading or trailing whitespace: %s\n' "$p" >&2; return 1
    fi
    if printf '%s' "$p" | LC_ALL=C grep -q '[[:cntrl:]]'; then
        printf 'REJECT: control character: %s\n' "$p" >&2; return 1
    fi
    if printf '%s' "$p" | grep -qE '/$'; then
        printf 'REJECT: trailing slash: %s\n' "$p" >&2; return 1
    fi
    case "$p" in
        *'*'*|*'?'*|*'['*)
            printf 'REJECT: glob character: %s\n' "$p" >&2; return 1 ;;
        *'..'*)
            printf 'REJECT: path traversal: %s\n' "$p" >&2; return 1 ;;
        '~'*)
            printf 'REJECT: tilde expansion: %s\n' "$p" >&2; return 1 ;;
        '/'*)
            printf 'REJECT: absolute path: %s\n' "$p" >&2; return 1 ;;
        *\\*)
            printf 'REJECT: backslash: %s\n' "$p" >&2; return 1 ;;
        '-'*)
            printf 'REJECT: leading dash: %s\n' "$p" >&2; return 1 ;;
        *':'*)
            printf 'REJECT: colon in path: %s\n' "$p" >&2; return 1 ;;
    esac
    case "$p" in
        .tad/*|.claude/*|.codex/*|.agents/*) ;;
        CLAUDE.md|AGENTS.md|tad.sh) ;;
        *)
            printf 'REJECT: prefix not in allow-list: %s\n' "$p" >&2; return 1 ;;
    esac
    return 0
}

# ══════════════════════════════════════════════════════════════
# Step 4: realpath containment + not-symlink (NFR2 portable)
# ══════════════════════════════════════════════════════════════
TARGET_REAL=""

check_containment() {
    local base="$1" p="$2"
    local full="$base/$p"
    local parent
    parent="$(dirname "$full")"

    # Per-component symlink check (including leaf) — no set/IFS to avoid glob expansion
    local check_path="$base"
    local remaining="$p"
    while [ -n "$remaining" ]; do
        local component="${remaining%%/*}"
        if [ "$component" = "$remaining" ]; then
            remaining=""
        else
            remaining="${remaining#*/}"
        fi
        [ -z "$component" ] && continue
        check_path="$check_path/$component"
        if [ -L "$check_path" ]; then
            printf 'REJECT: symlink component: %s in %s\n' "$component" "$p" >&2
            return 1
        fi
    done

    # Containment: parent dir must resolve inside target
    if [ -d "$parent" ]; then
        local resolved
        resolved="$(cd "$parent" && pwd -P)"
        if [ -z "$TARGET_REAL" ]; then
            TARGET_REAL="$(cd "$base" && pwd -P)"
        fi
        case "$resolved" in
            "$TARGET_REAL"|"$TARGET_REAL"/*) ;;
            *)
                printf 'REJECT: realpath escapes target: %s -> %s\n' "$p" "$resolved" >&2
                return 1 ;;
        esac
    fi
    return 0
}

# ══════════════════════════════════════════════════════════════
# Step 5: ZERO_TOUCH protection (physical-resolve comparison)
# ══════════════════════════════════════════════════════════════
ZT_LIST=""

# Authority: derive-sync-set.sh --zero-touch (sole source, never hardcode list)
load_zero_touch() {
    local src="$1"
    local zt_output rc=0
    zt_output="$(bash "$src/.tad/hooks/lib/derive-sync-set.sh" --zero-touch "$src" 2>/dev/null)" || rc=$?
    if [ "$rc" -ne 0 ] || [ -z "$zt_output" ]; then
        printf 'ABORT: ZERO_TOUCH authority unavailable (rc=%d)\n' "$rc" >&2
        exit 2
    fi
    if ! printf '%s' "$zt_output" | grep -q 'project-knowledge'; then
        printf 'ABORT: ZERO_TOUCH authority missing sentinel (project-knowledge)\n' >&2
        exit 2
    fi
    ZT_LIST="$zt_output"
}

check_zero_touch() {
    local base="$1" p="$2"
    local full="$base/$p"

    # .tad-backup protection (segment-anchored)
    case "$p" in
        .tad-backup/*|*/.tad-backup|*/.tad-backup/*) printf 'REJECT: path targets backup dir: %s\n' "$p" >&2; return 1 ;;
    esac

    # Physical-resolve comparison for ZERO_TOUCH dirs
    # Case-normalize: macOS APFS pwd -P preserves input case even on case-insensitive FS
    local candidate_parent candidate_lower
    if [ -d "$(dirname "$full")" ]; then
        candidate_parent="$(cd "$(dirname "$full")" 2>/dev/null && pwd -P)" || true
        candidate_lower="$(printf '%s' "$candidate_parent" | tr '[:upper:]' '[:lower:]')"
    else
        candidate_parent=""
        candidate_lower=""
    fi

    local zt_dir
    while IFS= read -r zt_dir; do
        [ -z "$zt_dir" ] && continue
        local zt_full="$base/.tad/$zt_dir"
        if [ -d "$zt_full" ]; then
            local zt_real zt_lower
            zt_real="$(cd "$zt_full" && pwd -P)"
            zt_lower="$(printf '%s' "$zt_real" | tr '[:upper:]' '[:lower:]')"
            # Segment-anchored: reject if candidate is zt_real itself or under it
            if [ -n "$candidate_lower" ]; then
                case "$candidate_lower" in
                    "$zt_lower"|"$zt_lower"/*) printf 'REJECT: ZERO_TOUCH: %s\n' "$p" >&2; return 1 ;;
                esac
            fi
            # Also check the full path itself
            if [ -d "$full" ]; then
                local full_real full_lower
                full_real="$(cd "$full" && pwd -P)"
                full_lower="$(printf '%s' "$full_real" | tr '[:upper:]' '[:lower:]')"
                case "$full_lower" in
                    "$zt_lower"|"$zt_lower"/*) printf 'REJECT: ZERO_TOUCH: %s\n' "$p" >&2; return 1 ;;
                esac
            fi
        fi
        # Case-insensitive textual fallback (covers targets where zt dir doesn't exist yet)
        local p_lower zt_pat_lower
        p_lower="$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')"
        zt_pat_lower=".tad/$(printf '%s' "$zt_dir" | tr '[:upper:]' '[:lower:]')"
        case "$p_lower" in
            "$zt_pat_lower"|"$zt_pat_lower"/*) printf 'REJECT: ZERO_TOUCH: %s\n' "$p" >&2; return 1 ;;
        esac
    done <<EOF
$ZT_LIST
EOF
    return 0
}

# Combined Steps 1-5 validation
validate_full() {
    local base="$1" p="$2"
    validate_path "$p" || return 1
    check_containment "$base" "$p" || return 1
    check_zero_touch "$base" "$p" || return 1
    return 0
}

# ══════════════════════════════════════════════════════════════
# guarded_remove — single deletion chokepoint (FR5f, SA-P0-3/P0-4)
# ══════════════════════════════════════════════════════════════
guarded_remove() {
    local full_path="$1" backup_path="$2" rel_path="$3" base="$4"
    # Self-contained revalidation at rm-site (TOCTOU defense)
    if ! check_containment "$base" "$rel_path"; then
        printf 'ABORT: rm-site step4 recheck failed: %s\n' "$rel_path" >&2
        return 1
    fi
    if ! check_zero_touch "$base" "$rel_path"; then
        printf 'ABORT: rm-site zero-touch recheck failed: %s\n' "$rel_path" >&2
        return 1
    fi
    if [ ! -e "$backup_path" ] && [ ! -d "$backup_path" ]; then
        printf 'ABORT: backup missing before remove: %s\n' "$rel_path" >&2
        return 1
    fi
    rm -rf -- "$full_path"
}

# ══════════════════════════════════════════════════════════════
# version_le — sort -V based comparison (mirrors tad.sh)
# ══════════════════════════════════════════════════════════════
version_le() {
    [ "$(printf '%s\n%s\n' "$1" "$2" | LC_ALL=C sort -V | head -1)" = "$1" ]
}

# ══════════════════════════════════════════════════════════════
# TSV report helpers (FR9)
# ══════════════════════════════════════════════════════════════
TSV_FILE=""
tsv_sanitize() {
    printf '%s' "$1" | tr '\t\n\r' '   '
}

report_line() {
    local action="$1" status="$2" path="$3" detail="$4"
    printf '%s\t%s\t%s\t%s\n' "$(tsv_sanitize "$action")" "$(tsv_sanitize "$status")" "$(tsv_sanitize "$path")" "$(tsv_sanitize "$detail")"
    if [ -n "$TSV_FILE" ]; then
        printf '%s\t%s\t%s\t%s\n' "$(tsv_sanitize "$action")" "$(tsv_sanitize "$status")" "$(tsv_sanitize "$path")" "$(tsv_sanitize "$detail")" >> "$TSV_FILE"
    fi
}

# ══════════════════════════════════════════════════════════════
# Fail-closed line-parser (FR2)
# ══════════════════════════════════════════════════════════════
parse_manifest() {
    local manifest_file="$1"
    [ -f "$manifest_file" ] || { printf 'ERROR: manifest not found: %s\n' "$manifest_file" >&2; return 1; }

    M_SCHEMA_VER="" M_FROM="" M_TO="" M_MIN_ENGINE="" M_GENERATED_BY=""
    DELETE_PATHS=() DELETE_TYPES=() DELETE_REASONS=()
    RENAME_FROMS=() RENAME_TOS=() RENAME_TYPES=() RENAME_REASONS=()
    MERGE_PATHS=() MERGE_STRATEGIES=() MERGE_MARKERS=() MERGE_MISSING=()
    VERIFY_TYPES=() VERIFY_PATHS=()

    local section="" in_entry=0 entry_idx=-1
    local cur_path="" cur_type="" cur_reason="" cur_from="" cur_to=""
    local cur_strategy="" cur_marker="" cur_missing=""

    flush_entry() {
        case "$section" in
            delete)
                if [ -n "$cur_path" ]; then
                    [ -z "$cur_type" ] && { printf 'REJECT: delete entry missing type field\n' >&2; return 1; }
                    DELETE_PATHS+=("$cur_path")
                    DELETE_TYPES+=("$cur_type")
                    DELETE_REASONS+=("$cur_reason")
                fi ;;
            rename)
                if [ -n "$cur_from" ]; then
                    [ -z "$cur_type" ] && { printf 'REJECT: rename entry missing type field\n' >&2; return 1; }
                    RENAME_FROMS+=("$cur_from")
                    RENAME_TOS+=("$cur_to")
                    RENAME_TYPES+=("$cur_type")
                    RENAME_REASONS+=("$cur_reason")
                fi ;;
            merge)
                if [ -n "$cur_path" ]; then
                    MERGE_PATHS+=("$cur_path")
                    MERGE_STRATEGIES+=("$cur_strategy")
                    MERGE_MARKERS+=("$cur_marker")
                    MERGE_MISSING+=("$cur_missing")
                fi ;;
            verify)
                if [ -n "$cur_path" ]; then
                    VERIFY_TYPES+=("$cur_type")
                    VERIFY_PATHS+=("$cur_path")
                fi ;;
        esac
        cur_path="" cur_type="" cur_reason="" cur_from="" cur_to=""
        cur_strategy="" cur_marker="" cur_missing=""
    }

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and blank lines
        case "$line" in
            '#'*|'---'*|'') continue ;;
        esac

        # Top-level fields
        case "$line" in
            'schema_version: '*)
                M_SCHEMA_VER="${line#schema_version: }"; continue ;;
            'from: '*)
                M_FROM="${line#from: }"; M_FROM="${M_FROM#\"}"; M_FROM="${M_FROM%\"}"; continue ;;
            'to: '*)
                M_TO="${line#to: }"; M_TO="${M_TO#\"}"; M_TO="${M_TO%\"}"; continue ;;
            'min_engine_version: '*)
                M_MIN_ENGINE="${line#min_engine_version: }"; M_MIN_ENGINE="${M_MIN_ENGINE#\"}"; M_MIN_ENGINE="${M_MIN_ENGINE%\"}"; continue ;;
            'generated_by: '*)
                M_GENERATED_BY="${line#generated_by: }"; M_GENERATED_BY="${M_GENERATED_BY#\"}"; M_GENERATED_BY="${M_GENERATED_BY%\"}"; continue ;;
        esac

        # Section headers (including empty forms)
        case "$line" in
            'delete: []'|'delete:'|'rename: []'|'rename:'|'merge: []'|'merge:'|'verify: []'|'verify:')
                flush_entry || return 1
                section="${line%%:*}"; section="${section%% *}"
                in_entry=0; continue ;;
        esac

        # List entry start
        if printf '%s' "$line" | grep -qE '^  - '; then
            flush_entry || return 1
            in_entry=1
            local field_key field_val
            field_key="$(printf '%s' "$line" | sed -E 's/^  - ([a-z_]+): .*/\1/')"
            field_val="$(printf '%s' "$line" | sed -E 's/^  - [a-z_]+: //')"
            field_val="${field_val#\"}"; field_val="${field_val%\"}"
            case "$section" in
                delete)
                    case "$field_key" in
                        path) cur_path="$field_val" ;;
                        *) printf 'REJECT: unexpected entry-start field in delete: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                rename)
                    case "$field_key" in
                        from) cur_from="$field_val" ;;
                        *) printf 'REJECT: unexpected entry-start field in rename: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                merge)
                    case "$field_key" in
                        path) cur_path="$field_val" ;;
                        *) printf 'REJECT: unexpected entry-start field in merge: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                verify)
                    case "$field_key" in
                        type) cur_type="$field_val" ;;
                        *) printf 'REJECT: unexpected entry-start field in verify: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                *)
                    printf 'REJECT: entry outside known section\n' >&2; return 1 ;;
            esac
            continue
        fi

        # Continuation fields within entry
        if printf '%s' "$line" | grep -qE '^    [a-z_]+: '; then
            local field_key field_val
            field_key="$(printf '%s' "$line" | sed -E 's/^    ([a-z_]+): .*/\1/')"
            field_val="$(printf '%s' "$line" | sed -E 's/^    [a-z_]+: //')"
            field_val="${field_val#\"}"; field_val="${field_val%\"}"
            case "$section" in
                delete)
                    case "$field_key" in
                        type) cur_type="$field_val" ;;
                        reason) cur_reason="$field_val" ;;
                        *) printf 'REJECT: unknown field in delete entry: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                rename)
                    case "$field_key" in
                        to) cur_to="$field_val" ;;
                        type) cur_type="$field_val" ;;
                        reason) cur_reason="$field_val" ;;
                        *) printf 'REJECT: unknown field in rename entry: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                merge)
                    case "$field_key" in
                        strategy) cur_strategy="$field_val" ;;
                        marker) cur_marker="$field_val" ;;
                        on_missing_marker) cur_missing="$field_val" ;;
                        *) printf 'REJECT: unknown field in merge entry: %s\n' "$field_key" >&2; return 1 ;;
                    esac ;;
                verify)
                    case "$field_key" in
                        path) cur_path="$field_val" ;;
                        *) ;; # verify: warn and ignore unknown fields (FR1.5b)
                    esac ;;
                *)
                    printf 'REJECT: field outside known section: %s\n' "$line" >&2; return 1 ;;
            esac
            continue
        fi

        # Any other line in a destructive section = reject
        if [ -n "$section" ] && [ "$section" != "verify" ]; then
            printf 'REJECT: unrecognized line in %s section: %s\n' "$section" "$line" >&2
            return 1
        fi
    done < "$manifest_file"

    flush_entry || return 1

    # schema_version check (FR1.5a)
    if [ "$M_SCHEMA_VER" != "1" ]; then
        printf 'REJECT: unsupported schema_version %s (engine supports 1). Upgrade engine or clean reinstall.\n' "$M_SCHEMA_VER" >&2
        return 1
    fi

    # min_engine_version check (FR2b)
    if [ -n "$M_MIN_ENGINE" ]; then
        if ! version_le "$M_MIN_ENGINE" "$ENGINE_VERSION"; then
            printf 'REJECT: manifest requires engine >= %s (current %s). Upgrade migration engine or clean reinstall.\n' "$M_MIN_ENGINE" "$ENGINE_VERSION" >&2
            return 1
        fi
    fi

    # Filename-field invariant (FR4e)
    local expected_name
    expected_name="${M_FROM}-to-${M_TO}.yaml"
    local actual_name
    actual_name="$(basename "$manifest_file")"
    if [ "$actual_name" != "$expected_name" ]; then
        printf 'REJECT: filename %s does not match from=%s to=%s (expected %s)\n' "$actual_name" "$M_FROM" "$M_TO" "$expected_name" >&2
        return 1
    fi

    return 0
}

# ══════════════════════════════════════════════════════════════
# Manifest validation (FR3)
# ══════════════════════════════════════════════════════════════
validate_manifest() {
    local i path

    # Collect all paths for conflict checking
    local all_delete_paths=() all_rename_froms=() all_rename_tos=() all_merge_paths=() all_verify_paths=() all_verify_types=()

    # Validate + collect delete paths
    for ((i=0; i<${#DELETE_PATHS[@]}; i++)); do
        path="${DELETE_PATHS[$i]}"
        validate_full "$TARGET" "$path" || { printf 'REJECT: delete path failed validation: %s\n' "$path" >&2; return 1; }
        all_delete_paths+=("$path")
    done

    # Validate + collect rename paths
    for ((i=0; i<${#RENAME_FROMS[@]}; i++)); do
        validate_full "$TARGET" "${RENAME_FROMS[$i]}" || { printf 'REJECT: rename.from failed validation: %s\n' "${RENAME_FROMS[$i]}" >&2; return 1; }
        validate_full "$TARGET" "${RENAME_TOS[$i]}" || { printf 'REJECT: rename.to failed validation: %s\n' "${RENAME_TOS[$i]}" >&2; return 1; }
        all_rename_froms+=("${RENAME_FROMS[$i]}")
        all_rename_tos+=("${RENAME_TOS[$i]}")
    done

    # Validate merge paths
    for ((i=0; i<${#MERGE_PATHS[@]}; i++)); do
        validate_full "$TARGET" "${MERGE_PATHS[$i]}" || { printf 'REJECT: merge path failed validation: %s\n' "${MERGE_PATHS[$i]}" >&2; return 1; }
        all_merge_paths+=("${MERGE_PATHS[$i]}")
    done

    # Validate verify paths
    for ((i=0; i<${#VERIFY_PATHS[@]}; i++)); do
        validate_full "$TARGET" "${VERIFY_PATHS[$i]}" || { printf 'REJECT: verify path failed validation: %s\n' "${VERIFY_PATHS[$i]}" >&2; return 1; }
        all_verify_paths+=("${VERIFY_PATHS[$i]}")
        all_verify_types+=("${VERIFY_TYPES[$i]}")
    done

    # Cross-section conflict detection (FR1.5c, FR3)
    local d r_f r_t m v_p v_t

    # Within-section duplicate check (bash 3.2 safe: guard empty arrays)
    local seen_path
    if [ ${#all_delete_paths[@]} -gt 0 ]; then
        seen_path="$(printf '%s\n' "${all_delete_paths[@]}" | LC_ALL=C sort | uniq -d)"
        [ -n "$seen_path" ] && { printf 'REJECT: duplicate path in delete: %s\n' "$seen_path" >&2; return 1; }
    fi

    if [ ${#all_rename_froms[@]} -gt 0 ]; then
        seen_path="$(printf '%s\n' "${all_rename_froms[@]}" | LC_ALL=C sort | uniq -d)"
        [ -n "$seen_path" ] && { printf 'REJECT: duplicate from in rename: %s\n' "$seen_path" >&2; return 1; }

        seen_path="$(printf '%s\n' "${all_rename_tos[@]}" | LC_ALL=C sort | uniq -d)"
        [ -n "$seen_path" ] && { printf 'REJECT: duplicate to in rename: %s\n' "$seen_path" >&2; return 1; }
    fi

    # Cross-section conflicts (bash 3.2 safe: guard empty arrays)
    if [ ${#all_delete_paths[@]} -gt 0 ]; then
        for d in "${all_delete_paths[@]}"; do
            if [ ${#all_rename_froms[@]} -gt 0 ]; then
                for r_f in "${all_rename_froms[@]}"; do
                    [ "$d" = "$r_f" ] && { printf 'REJECT: conflict delete+rename.from: %s\n' "$d" >&2; return 1; }
                done
            fi
            if [ ${#all_rename_tos[@]} -gt 0 ]; then
                for r_t in "${all_rename_tos[@]}"; do
                    [ "$d" = "$r_t" ] && { printf 'REJECT: conflict delete+rename.to: %s\n' "$d" >&2; return 1; }
                done
            fi
            if [ ${#all_merge_paths[@]} -gt 0 ]; then
                for m in "${all_merge_paths[@]}"; do
                    [ "$d" = "$m" ] && { printf 'REJECT: conflict delete+merge: %s\n' "$d" >&2; return 1; }
                done
            fi
            if [ ${#all_verify_paths[@]} -gt 0 ]; then
                for ((i=0; i<${#all_verify_paths[@]}; i++)); do
                    v_p="${all_verify_paths[$i]}"; v_t="${all_verify_types[$i]}"
                    if [ "$d" = "$v_p" ] && [ "$v_t" = "present" ]; then
                        printf 'REJECT: conflict delete+verify.present: %s\n' "$d" >&2; return 1
                    fi
                done
            fi
        done
    fi

    if [ ${#all_rename_froms[@]} -gt 0 ]; then
        for ((i=0; i<${#all_rename_froms[@]}; i++)); do
            r_f="${all_rename_froms[$i]}"; r_t="${all_rename_tos[$i]}"
            [ "$r_f" = "$r_t" ] && { printf 'REJECT: rename from=to: %s\n' "$r_f" >&2; return 1; }
            if [ ${#all_merge_paths[@]} -gt 0 ]; then
                for m in "${all_merge_paths[@]}"; do
                    [ "$r_f" = "$m" ] && { printf 'REJECT: conflict rename.from+merge: %s\n' "$r_f" >&2; return 1; }
                done
            fi
        done
    fi

    return 0
}

# ══════════════════════════════════════════════════════════════
# Idempotency oracle (FR7)
# ══════════════════════════════════════════════════════════════
check_oracle() {
    # Only short-circuit if verify is non-empty AND contains >=1 absent assertion AND all pass
    if [ ${#VERIFY_PATHS[@]} -eq 0 ]; then return 1; fi

    local has_absent=0 i
    for ((i=0; i<${#VERIFY_TYPES[@]}; i++)); do
        [ "${VERIFY_TYPES[$i]}" = "absent" ] && has_absent=1
    done
    [ "$has_absent" -eq 0 ] && return 1

    for ((i=0; i<${#VERIFY_PATHS[@]}; i++)); do
        local vt="${VERIFY_TYPES[$i]}" vp="${VERIFY_PATHS[$i]}"
        case "$vt" in
            absent)  [ -e "$TARGET/$vp" ] && return 1 ;;
            present) [ ! -e "$TARGET/$vp" ] && return 1 ;;
        esac
    done
    return 0
}

# ══════════════════════════════════════════════════════════════
# User-modification detection (DR-2 Amendment)
# ══════════════════════════════════════════════════════════════
GIT_AVAILABLE=0 GIT_DETECTION_MODE=""

init_detection() {
    if ! command -v git >/dev/null 2>&1; then
        GIT_DETECTION_MODE="unavailable"; return
    fi
    if ! git -C "$SOURCE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        GIT_DETECTION_MODE="unavailable"; return
    fi
    if ! git -C "$SOURCE" show "v${M_FROM}:.tad/version.txt" >/dev/null 2>&1; then
        GIT_DETECTION_MODE="unavailable"; return
    fi
    GIT_AVAILABLE=1
    GIT_DETECTION_MODE="available"
}

detect_file_modified() {
    local ver="$1" path="$2"
    # Returns: 0=unmodified, 1=modified, 2=no-baseline
    if [ "$GIT_AVAILABLE" -eq 0 ]; then return 2; fi

    local ref_content_rc=0
    git -C "$SOURCE" show "v${ver}:${path}" >/dev/null 2>&1 || ref_content_rc=$?
    if [ "$ref_content_rc" -ne 0 ]; then return 2; fi

    local target_file="$TARGET/$path"
    [ -f "$target_file" ] || return 2

    if git -C "$SOURCE" show "v${ver}:${path}" 2>/dev/null | cmp -s - "$target_file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

detect_dir_modified() {
    local ver="$1" path="$2"
    if [ "$GIT_AVAILABLE" -eq 0 ]; then return 2; fi

    local tree_files_rc=0
    local tree_files
    tree_files="$(git -C "$SOURCE" ls-tree -r --name-only "v${ver}" -- "$path" 2>/dev/null)" || tree_files_rc=$?
    if [ "$tree_files_rc" -ne 0 ] || [ -z "$tree_files" ]; then return 2; fi

    local target_dir="$TARGET/$path"
    [ -d "$target_dir" ] || return 2

    # Check each tracked file matches
    local f
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        if [ ! -f "$TARGET/$f" ]; then return 1; fi
        if ! git -C "$SOURCE" show "v${ver}:${f}" 2>/dev/null | cmp -s - "$TARGET/$f" 2>/dev/null; then
            return 1
        fi
    done <<EOF
$tree_files
EOF

    # Check for extra files not in the from version
    local actual_count expected_count
    expected_count="$(printf '%s\n' "$tree_files" | wc -l | tr -d ' ')"
    actual_count="$(find "$target_dir" -type f 2>/dev/null | wc -l | tr -d ' ')"
    [ "$actual_count" -gt "$expected_count" ] && return 1

    return 0
}

# ══════════════════════════════════════════════════════════════
# Backup (FR5g, SA-P1-1)
# ══════════════════════════════════════════════════════════════
do_backup() {
    local path="$1" backup_base="$2"
    local src="$TARGET/$path"
    local dst="$backup_base/$path"
    local dst_dir
    dst_dir="$(dirname "$dst")"

    # Backup destination containment check
    if ! check_containment "$TARGET" ".tad-backup/${M_FROM}-to-${M_TO}/$path"; then
        printf 'ABORT: backup destination escapes target: %s\n' "$path" >&2
        return 1
    fi

    # Refuse to overwrite existing backup
    if [ -e "$dst" ]; then
        printf 'ABORT: backup already exists, refusing overwrite: %s\n' "$dst" >&2
        return 1
    fi

    mkdir -p "$dst_dir"
    cp -a "$src" "$dst"
}

# ══════════════════════════════════════════════════════════════
# Chain resolution (FR4)
# ══════════════════════════════════════════════════════════════
resolve_chain() {
    local from="$1" to="$2" migrations_dir="$3"
    CHAIN_MANIFESTS=()

    if ! version_le "$from" "$to" || [ "$from" = "$to" ]; then
        printf 'REJECT: forward-only constraint violated: %s >= %s\n' "$from" "$to" >&2
        return 1
    fi

    # Find all manifests and build version graph
    local manifest_files=()
    if [ -d "$migrations_dir" ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            manifest_files+=("$f")
        done < <(find "$migrations_dir" -maxdepth 1 -name '*.yaml' -type f 2>/dev/null | LC_ALL=C sort)
    fi

    # Build chain from→to
    local current="$from"
    while [ "$current" != "$to" ]; do
        local found=0 mf
        for mf in "${manifest_files[@]}"; do
            local bn
            bn="$(basename "$mf")"
            local mf_from="${bn%-to-*}"
            local mf_to="${bn#*-to-}"; mf_to="${mf_to%.yaml}"
            if [ "$mf_from" = "$current" ]; then
                if ! version_le "$mf_from" "$mf_to" || [ "$mf_from" = "$mf_to" ]; then
                    printf 'REJECT: backward/self hop in chain: %s → %s\n' "$mf_from" "$mf_to" >&2
                    return 1
                fi
                CHAIN_MANIFESTS+=("$mf")
                current="$mf_to"
                found=1
                break
            fi
        done
        if [ "$found" -eq 0 ]; then
            printf 'REJECT: chain gap at %s — no manifest from %s. Suggest clean reinstall.\n' "$current" "$current" >&2
            return 1
        fi
    done
    return 0
}

# ══════════════════════════════════════════════════════════════
# Merge execution: tad-head-marker strategy (Phase 4)
# Returns: 0=done (content changed), 1=fatal error, 2=skipped or already-current
# ══════════════════════════════════════════════════════════════
execute_merge_entry() {
    local m_path="$1" m_marker="$2" target_base="$3" source_base="$4" dry_run="$5"
    local target_file="$target_base/$m_path"
    local source_file="$source_base/$m_path"
    local backup_base="$target_base/.tad-backup/${M_FROM}-to-${M_TO}"

    # P1-3: Reject markers shorter than 10 characters (empty marker = grep matches everything)
    if [ ${#m_marker} -lt 10 ]; then
        report_line "merge" "error" "$m_path" "marker too short (${#m_marker} chars, min 10)"
        return 1
    fi

    # 1. Source must exist
    if [ ! -f "$source_file" ]; then
        report_line "merge" "error" "$m_path" "source file not found: $source_file"
        return 1
    fi

    # 2. Target must exist (no target = no marker = skip)
    if [ ! -f "$target_file" ]; then
        report_line "merge" "skipped-no-marker" "$m_path" "target file not found"
        return 2
    fi

    # 3. Find marker in target (grep -F = fixed string, no regex)
    local marker_line_num=""
    marker_line_num="$(grep -nF "$m_marker" "$target_file" | head -1 | cut -d: -f1)" || true
    if [ -z "$marker_line_num" ]; then
        report_line "merge" "skipped-no-marker" "$m_path" "marker not found in target"
        return 2
    fi

    # 4. Find marker in source (must exist for merge to work)
    local source_marker_line=""
    source_marker_line="$(grep -nF "$m_marker" "$source_file" | head -1 | cut -d: -f1)" || true
    if [ -z "$source_marker_line" ]; then
        report_line "merge" "error" "$m_path" "marker not found in source file"
        return 1
    fi

    # 5. Idempotency check: compare current head with source head
    #    Variable capture is acceptable here — both sides extracted the same way
    #    (stripping is symmetric, not going to disk)
    local source_head="" current_head=""
    if [ "$source_marker_line" -gt 1 ]; then
        source_head="$(head -n $((source_marker_line - 1)) "$source_file")"
    fi
    if [ "$marker_line_num" -gt 1 ]; then
        current_head="$(head -n $((marker_line_num - 1)) "$target_file")"
    fi
    if [ "$current_head" = "$source_head" ]; then
        report_line "merge" "already-current" "$m_path" "head content matches source"
        return 2
    fi

    # 6. Dry-run: report but don't write
    if [ "$dry_run" -eq 1 ]; then
        report_line "merge" "would-merge" "$m_path" "would replace head ($((source_marker_line - 1)) lines from source)"
        return 2
    fi

    # 7. Backup before write
    do_backup "$m_path" "$backup_base" || return 1

    # 8. Assemble via temp file to preserve exact bytes (no variable capture for disk content)
    #    P1-2: Use mktemp for temp file instead of predictable .merge-tmp path
    local tmp_file=""
    tmp_file="$(mktemp "${target_file}.merge-XXXXXX")" || {
        report_line "merge" "error" "$m_path" "failed to create temp file"
        return 1
    }

    # P1-1: Guard temp file cleanup on pipeline failure
    # cleanup_merge_tmp: single helper for temp file removal (distinct from guarded_remove which handles user files)
    cleanup_merge_tmp() { [ -n "${1:-}" ] && [ -f "$1" ] && rm -f -- "$1"; }

    {
        if [ "$source_marker_line" -gt 1 ]; then
            head -n $((source_marker_line - 1)) "$source_file"
        fi
        tail -n +"${marker_line_num}" "$target_file"
    } > "$tmp_file" || {
        cleanup_merge_tmp "$tmp_file"
        report_line "merge" "error" "$m_path" "failed to assemble merged content"
        return 1
    }

    # P1-1: Non-empty check before mv (safety: don't replace with empty file)
    if [ ! -s "$tmp_file" ]; then
        cleanup_merge_tmp "$tmp_file"
        report_line "merge" "error" "$m_path" "assembled file is empty, aborting"
        return 1
    fi

    mv -- "$tmp_file" "$target_file" || {
        cleanup_merge_tmp "$tmp_file"
        report_line "merge" "error" "$m_path" "failed to move temp file to target"
        return 1
    }

    report_line "merge" "done" "$m_path" "head replaced from source"
    return 0
}

# ══════════════════════════════════════════════════════════════
# Execute one manifest (FR5, FR6)
# ══════════════════════════════════════════════════════════════
execute_manifest() {
    local manifest_file="$1"
    local backup_base="$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"
    local i deleted=0 skipped=0 manual=0

    init_detection

    # FR6: rename → delete → merge → verify

    # RENAME
    for ((i=0; i<${#RENAME_FROMS[@]}; i++)); do
        local r_from="${RENAME_FROMS[$i]}" r_to="${RENAME_TOS[$i]}" r_type="${RENAME_TYPES[$i]}"
        local full_from="$TARGET/$r_from"

        if [ ! -e "$full_from" ]; then
            report_line "rename" "already-absent" "$r_from" "source not found"
            continue
        fi

        local detect_rc=0
        if [ "$r_type" = "dir" ]; then
            detect_dir_modified "$M_FROM" "$r_from" || detect_rc=$?
        else
            detect_file_modified "$M_FROM" "$r_from" || detect_rc=$?
        fi

        case "$detect_rc" in
            0)
                if [ "$DRY_RUN" -eq 1 ]; then
                    report_line "rename" "would-rename" "$r_from" "→ $r_to (unmodified, would backup+mv)"
                else
                    do_backup "$r_from" "$backup_base" || exit 1
                    local to_parent
                    to_parent="$(dirname "$TARGET/$r_to")"
                    mkdir -p "$to_parent"
                    mv -- "$full_from" "$TARGET/$r_to"
                    report_line "rename" "done" "$r_from" "→ $r_to (backed up)"
                    deleted=$((deleted + 1))
                fi ;;
            1)
                report_line "rename" "skipped-user-modified" "$r_from" "content differs from v${M_FROM}"
                skipped=$((skipped + 1)) ;;
            2)
                if [ "$GIT_DETECTION_MODE" = "unavailable" ]; then
                    report_line "rename" "skipped-detection-unavailable" "$r_from" "git/tag unavailable (systemic)"
                else
                    report_line "rename" "skipped-no-baseline" "$r_from" "path absent at v${M_FROM} (per-path)"
                fi
                skipped=$((skipped + 1)) ;;
        esac
    done

    # DELETE
    for ((i=0; i<${#DELETE_PATHS[@]}; i++)); do
        local d_path="${DELETE_PATHS[$i]}" d_type="${DELETE_TYPES[$i]}"
        local full_path="$TARGET/$d_path"

        if [ ! -e "$full_path" ]; then
            report_line "delete" "already-absent" "$d_path" "not found"
            continue
        fi

        local detect_rc=0
        if [ "$d_type" = "dir" ]; then
            detect_dir_modified "$M_FROM" "$d_path" || detect_rc=$?
        else
            detect_file_modified "$M_FROM" "$d_path" || detect_rc=$?
        fi

        case "$detect_rc" in
            0)
                if [ "$DRY_RUN" -eq 1 ]; then
                    report_line "delete" "would-delete" "$d_path" "unmodified, would backup+rm"
                else
                    do_backup "$d_path" "$backup_base" || exit 1
                    guarded_remove "$full_path" "$backup_base/$d_path" "$d_path" "$TARGET" || exit 1
                    report_line "delete" "done" "$d_path" "backed up"
                    deleted=$((deleted + 1))
                fi ;;
            1)
                report_line "delete" "skipped-user-modified" "$d_path" "content differs from v${M_FROM}"
                skipped=$((skipped + 1)) ;;
            2)
                if [ "$GIT_DETECTION_MODE" = "unavailable" ]; then
                    report_line "delete" "skipped-detection-unavailable" "$d_path" "git/tag unavailable (systemic)"
                else
                    report_line "delete" "skipped-no-baseline" "$d_path" "path absent at v${M_FROM} (per-path)"
                fi
                skipped=$((skipped + 1)) ;;
        esac
    done

    # MERGE
    local merged=0
    for ((i=0; i<${#MERGE_PATHS[@]}; i++)); do
        local m_path="${MERGE_PATHS[$i]}" m_strategy="${MERGE_STRATEGIES[$i]}"
        local m_marker="${MERGE_MARKERS[$i]}"

        if [ "$m_strategy" != "tad-head-marker" ]; then
            report_line "merge" "manual-required" "$m_path" "unknown strategy=$m_strategy"
            manual=$((manual + 1))
            continue
        fi

        # Return convention: 0=done, 2=skipped/already-current, 1=fatal
        local merge_rc=0
        execute_merge_entry "$m_path" "$m_marker" "$TARGET" "$SOURCE" "$DRY_RUN" || merge_rc=$?
        if [ "$merge_rc" -eq 1 ]; then return 1; fi  # fatal → fail-fast
        if [ "$merge_rc" -eq 0 ]; then merged=$((merged + 1)); fi
        # merge_rc=2 → skipped/already-current, don't count as merged
    done

    # VERIFY (skip in dry-run — files haven't been modified)
    if [ "$DRY_RUN" -eq 1 ]; then
        for ((i=0; i<${#VERIFY_PATHS[@]}; i++)); do
            report_line "verify" "would-verify" "${VERIFY_PATHS[$i]}" "type=${VERIFY_TYPES[$i]}"
        done
    else
        for ((i=0; i<${#VERIFY_PATHS[@]}; i++)); do
            local vt="${VERIFY_TYPES[$i]}" vp="${VERIFY_PATHS[$i]}"
            case "$vt" in
                absent)
                    if [ -e "$TARGET/$vp" ]; then
                        report_line "verify" "fail" "$vp" "expected absent but exists"
                        printf 'FAIL: verify assertion failed: %s should be absent\n' "$vp" >&2
                        return 1
                    fi
                    report_line "verify" "pass" "$vp" "absent as expected" ;;
                present)
                    if [ ! -e "$TARGET/$vp" ]; then
                        report_line "verify" "fail" "$vp" "expected present but missing"
                        printf 'FAIL: verify assertion failed: %s should be present\n' "$vp" >&2
                        return 1
                    fi
                    report_line "verify" "pass" "$vp" "present as expected" ;;
            esac
        done
    fi

    report_line "summary" "ok" "-" "deleted=$deleted skipped=$skipped merged=$merged manual=$manual"
    return 0
}

# ══════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════
main() {
    parse_args "$@"
    load_zero_touch "$SOURCE"

    local migrations_dir="$SOURCE/.tad/migrations"
    resolve_chain "$FROM_VER" "$TO_VER" "$migrations_dir" || exit 2

    if [ ${#CHAIN_MANIFESTS[@]} -eq 0 ]; then
        printf 'No manifests found for %s → %s\n' "$FROM_VER" "$TO_VER"
        exit 0
    fi

    # Phase 1: Parse + validate ALL manifests before any execution (FR3 whole-chain)
    local parsed_data=()
    for mf in "${CHAIN_MANIFESTS[@]}"; do
        parse_manifest "$mf" || exit 2
        validate_manifest || exit 2
        # Store parsed state (we'll re-parse during execution since bash has no struct)
    done

    # Phase 2: Execute each manifest in chain order
    for mf in "${CHAIN_MANIFESTS[@]}"; do
        parse_manifest "$mf" || exit 2

        printf '\n=== Migration: %s → %s ===\n' "$M_FROM" "$M_TO"

        # Idempotency oracle (FR7) — check BEFORE creating TSV/backup
        if check_oracle; then
            printf 'oracle\talready-applied\t-\tall verify assertions pass, skipping\n'
            printf 'Already applied: %s → %s\n' "$M_FROM" "$M_TO"
            continue
        fi

        # Setup TSV report (only if we're actually executing)
        if [ "$DRY_RUN" -eq 0 ]; then
            local backup_dir="$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"
            mkdir -p "$backup_dir"
            TSV_FILE="$backup_dir/MIGRATION-REPORT.tsv"
            printf 'action\tstatus\tpath\tdetail\n' > "$TSV_FILE"
        else
            TSV_FILE=""
        fi

        execute_manifest "$mf" || exit 1
    done

    printf '\nMigration complete: %s → %s\n' "$FROM_VER" "$TO_VER"
}

main "$@"
