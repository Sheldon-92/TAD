#!/usr/bin/env bash
# tad-backup-test.sh — isolated-fixture harness for the tad.sh backup /
# rollback rework (TASK-20261006-TADSH-BACKUP-FIX, HANDOFF §6/§8/§9.1).
#
# Every scenario runs in its own `mktemp -d` sandbox with HOME and
# TAD_BACKUP_ROOT redirected into the sandbox. The functions under test are
# EXTRACTED VERBATIM from tad.sh (detect-state-test.sh precedent) — this
# harness never reimplements backup/rollback logic, and it never runs tad.sh
# itself, so no real project repo is ever touched (freeze order in effect).
#
# Usage:
#   bash tad-backup-test.sh              # run all cases
#   bash tad-backup-test.sh --case NAME  # run one case
#
# Cases: set-equality size location default-home retention collision
#        restore restore-failure prune-failure repo-key guard root-guard
#        root-alias legacy symlink
# Exit 0 iff every selected case passes.
set -u

# --- locate tad.sh (repo root = three dirs up from .tad/hooks/lib/) ---------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAD_SH="$SCRIPT_DIR/../../../tad.sh"
if [ ! -f "$TAD_SH" ]; then
    echo "FATAL: cannot find tad.sh at $TAD_SH" >&2
    exit 2
fi

# --- build the extraction shim ----------------------------------------------
SHIM="$(mktemp)"
trap 'rm -f "$SHIM"' EXIT

# Deny-list globals block (verbatim): from TAD_ZERO_TOUCH= to TAD_REGISTRY_FILE=.
sed -n '/^TAD_ZERO_TOUCH=/,/^TAD_REGISTRY_FILE=/p' "$TAD_SH" >> "$SHIM"
echo "" >> "$SHIM"

# Functions extracted by name (definition line to the closing brace at col 0).
# Missing functions (helpers added by the fix) extract empty on an unpatched
# tad.sh — the Phase 0 red baseline relies on this: old code paths simply do
# not call them, and the new-behavior assertions fail on the old behavior.
for fn in _literal_has_prefix assert_under_root \
          log_info log_success log_warn log_error \
          derive_framework_dirs derive_framework_top_files \
          resolve_backup_root repo_group_key prune_backups backup_existing \
          assert_under_backup_root \
          _tad_tree_equal \
          restore_dir_entry restore_file_entry cleanup_source_tree \
          rollback_on_failure; do
    sed -n "/^${fn}() {/,/^}/p" "$TAD_SH" >> "$SHIM"
    echo "" >> "$SHIM"
done

# Sanity: functions present in BOTH the old and the fixed tad.sh must extract.
for fn in _literal_has_prefix assert_under_root log_info log_error \
          derive_framework_dirs derive_framework_top_files backup_existing \
          restore_dir_entry restore_file_entry rollback_on_failure; do
    grep -q "^${fn}() {" "$SHIM" || { echo "FATAL: shim missing $fn (extraction failed)" >&2; exit 2; }
done

# Harness-side globals (colors neutralized; rollback state starts empty).
BLUE="" GREEN="" YELLOW="" RED="" NC=""
BACKUP_PATH="" BACKUP_PATH_ABS="" TARGET_ROOT=""
ROLLBACK_SNAP="" ROLLBACK_CREATED_TOP="" ROLLBACK_PRE_TOP=""
MERGE_CREATED_BACKUP="" TAD_BACKUP_ROOT_ABS="" BACKUP_GROUP=""
TAD_SRC="" TAD_SRC_DOWNLOADED=0 TAD_TMP_ROOT=""

# shellcheck disable=SC1090
source "$SHIM"

# --- small helpers ------------------------------------------------------------
FAILED=0
fail() { echo "  FAIL-ASSERT: $1"; FAILED=1; }

perm_of() { stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1" 2>/dev/null; }

tree_bytes() { find "$1" -type f -exec cat {} + | wc -c | tr -d ' '; }

# tree_manifest <dir> — deterministic content manifest:
# regular files via cksum (sorted by path), symlinks as "L <target> <path>".
tree_manifest() {
    ( cd "$1" || exit 99
      find . -type f -exec cksum {} + | LC_ALL=C sort -k 3
      find . -type l | LC_ALL=C sort | while IFS= read -r _l; do
          printf 'L %s %s\n' "$(readlink "$_l")" "$_l"
      done )
}

# data_manifest <proj> — the AC6 data-surface side: evidence/archive/active/
# project-knowledge file checksums (the surfaces rollback must never touch).
data_manifest() {
    ( cd "$1/.tad" || exit 99
      find ./evidence ./archive ./active ./project-knowledge -type f -exec cksum {} + \
          | LC_ALL=C sort -k 3 )
}

# build_fixture <proj> — the §6 Phase 0 fixture (+ SUPPLEMENT-1 S3.5):
# framework dirs with sentinels, data surfaces with unique tokens and a >=5M
# evidence fill, top-level deny pair, registry + pack tree, a dangling link
# INSIDE a framework dir (AC13), a TOP-LEVEL dangling link (S3.5), and a
# legacy in-root backup dir (AC12 sentinel).
build_fixture() {
    local p="$1"
    mkdir -p "$p/.tad/hooks" "$p/.tad/scripts" \
             "$p/.tad/evidence" "$p/.tad/archive" "$p/.tad/active" \
             "$p/.tad/project-knowledge" "$p/.tad/capability-packs/pack-a"
    printf 'HOOK-SENTINEL-v1\n' > "$p/.tad/hooks/hook.sh"
    printf 'TOOL-SENTINEL-v1\n' > "$p/.tad/scripts/tool.sh"
    ln -s /nonexistent-tad-test-target "$p/.tad/hooks/dangling-in-framework"
    printf 'EVIDENCE-SENTINEL-4c1d\n' > "$p/.tad/evidence/sentinel.txt"
    dd if=/dev/zero of="$p/.tad/evidence/big.bin" bs=1024 count=5500 2>/dev/null
    printf 'ARCHIVE-SENTINEL-91be\n' > "$p/.tad/archive/sentinel.txt"
    printf 'ACTIVE-SENTINEL-77aa\n' > "$p/.tad/active/sentinel.txt"
    printf 'PK-SENTINEL-52cd\n' > "$p/.tad/project-knowledge/sentinel.txt"
    printf '3.1.0\n' > "$p/.tad/version.txt"
    printf 'CONFIG-SENTINEL-v1\n' > "$p/.tad/config.yaml"
    printf 'BRAINIDX-SENTINEL\n' > "$p/.tad/brain-index.md"
    printf 'SYNCREG-SENTINEL\n' > "$p/.tad/sync-registry.yaml"
    printf 'registry: REGISTRY-SENTINEL-v1\n' > "$p/.tad/capability-packs/pack-registry.yaml"
    printf 'PACKTREE-SENTINEL-63ef\n' > "$p/.tad/capability-packs/pack-a/tree-sentinel.txt"
    ln -s /nonexistent-tad-test-target "$p/.tad/top-dangling"
    printf 'PROJECT-FILE-SENTINEL\n' > "$p/README.md"
    mkdir -p "$p/.tad.backup.20000101_000000"
    printf 'LEGACY-SENTINEL-20f0\n' > "$p/.tad.backup.20000101_000000/legacy.txt"
}

# do_backup <sbx> <proj> — run extracted backup_existing() in a subshell with
# cwd=<proj>; HOME always sandboxed. Root selection: DB_UNSET_ROOT=1 -> env
# unset (default-home); DB_ROOT set -> that value; else <sbx>/backups.
# Captures: stdout+stderr -> <sbx>/out.log, $BACKUP_PATH -> <sbx>/bp.txt.
DB_ROOT="" DB_UNSET_ROOT=0
do_backup() {
    local sbx="$1" proj="$2"
    ( cd "$proj" || exit 99
      export HOME="$sbx/home"
      if [ "$DB_UNSET_ROOT" = "1" ]; then
          unset TAD_BACKUP_ROOT
      elif [ -n "$DB_ROOT" ]; then
          export TAD_BACKUP_ROOT="$DB_ROOT"
      else
          export TAD_BACKUP_ROOT="$sbx/backups"
      fi
      backup_existing
      _brc=$?
      printf '%s' "${BACKUP_PATH:-}" > "$sbx/bp.txt"
      exit $_brc
    ) > "$sbx/out.log" 2>&1
    return $?
}

# do_rollback <sbx> <proj> <backup_abs> <root_abs> — run extracted
# rollback_on_failure() in a subshell, simulating the post-snapshot process
# state (snapshot itself is not under test here). Log -> <sbx>/rb.log.
# rollback_on_failure exits 1 by design; the caller asserts on that.
do_rollback() {
    local sbx="$1" proj="$2" babs="$3" rabs="$4"
    ( cd "$proj" || exit 99
      export HOME="$sbx/home"
      export TAD_BACKUP_ROOT="$sbx/backups"
      TARGET_ROOT="$(pwd -P)"
      BACKUP_PATH_ABS="$babs"
      TAD_BACKUP_ROOT_ABS="$rabs"
      ROLLBACK_SNAP=""
      ROLLBACK_CREATED_TOP=""
      ROLLBACK_PRE_TOP=""
      MERGE_CREATED_BACKUP=""
      rollback_on_failure
    ) > "$sbx/rb.log" 2>&1
    return $?
}

# plant_complete_backup <dir> <marker> — a minimal "complete" backup dir:
# manifest.txt present (the completeness marker) + origin.txt + one payload.
plant_complete_backup() {
    mkdir -p "$1/.tad"
    printf 'hooks\nversion=3.1.0\n' > "$1/manifest.txt"
    printf '%s\n' "$2" > "$1/payload.txt"
}

count_complete() { # <group_dir> -> number of manifest-bearing subdirs
    local n=0 d
    for d in "$1"/*/; do
        [ -f "${d}manifest.txt" ] && n=$((n + 1))
    done
    echo "$n"
}

# --- cases --------------------------------------------------------------------

case_set_equality() {
    local sbx proj bp exp got expf gotf tok
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup_existing rc != 0"; cat "$sbx/out.log"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    [ -n "$bp" ] && [ -d "$bp/.tad" ] || { fail "no backup tree at BACKUP_PATH='$bp'"; rm -rf "$sbx"; return 1; }

    # Top-level set: manifest lines (minus version=) == derived set, with the
    # registry-only component represented by its registry path (S2.2).
    exp="$( { derive_framework_dirs "$proj" | while IFS= read -r _d; do
                if [ "$_d" = "capability-packs" ]; then
                    echo "capability-packs/pack-registry.yaml"
                else echo "$_d"; fi
              done
              derive_framework_top_files "$proj"
            } | LC_ALL=C sort )"
    got="$(grep -v '^version=' "$bp/manifest.txt" | LC_ALL=C sort)"
    [ "$exp" = "$got" ] || fail "manifest set != derived set"
    [ "$(tail -1 "$bp/manifest.txt")" = "version=3.1.0" ] || fail "manifest last line != version=3.1.0"

    # Recursive content set (S2.4): every file/link under the backup .tad ==
    # the derived components' recursive content in the fixture.
    expf="$( cd "$proj/.tad" || exit 99
             { _dl="$(derive_framework_dirs "$proj")"
               while IFS= read -r _d; do
                   [ -n "$_d" ] || continue
                   if [ "$_d" = "capability-packs" ]; then
                       echo "capability-packs/pack-registry.yaml"
                   else
                       find "./$_d" \( -type f -o -type l \) | sed 's|^\./||'
                   fi
               done <<< "$_dl"
               derive_framework_top_files "$proj"
             } | LC_ALL=C sort )"
    gotf="$( cd "$bp/.tad" || exit 99; find . \( -type f -o -type l \) | sed 's|^\./||' | LC_ALL=C sort )"
    [ "$expf" = "$gotf" ] || fail "recursive backup content set != derived content set"

    # Load-bearing side (REQ-1): data-surface + pack-tree sentinels absent.
    for tok in EVIDENCE-SENTINEL-4c1d ARCHIVE-SENTINEL-91be ACTIVE-SENTINEL-77aa \
               PK-SENTINEL-52cd PACKTREE-SENTINEL-63ef BRAINIDX-SENTINEL SYNCREG-SENTINEL; do
        grep -rqs "$tok" "$bp"
        [ $? -eq 1 ] || fail "sentinel $tok found inside backup"
    done

    cmp -s "$proj/.tad/hooks/hook.sh" "$bp/.tad/hooks/hook.sh" || fail "hook.sh content differs in backup"

    # pre-top.txt (S3.1): full top-level enumeration incl. non-derivable entries.
    grep -Fxq -e "top-dangling" "$bp/pre-top.txt" || fail "pre-top.txt lacks top-dangling"
    grep -Fxq -e "brain-index.md" "$bp/pre-top.txt" || fail "pre-top.txt lacks brain-index.md"
    grep -Fxq -e "sync-registry.yaml" "$bp/pre-top.txt" || fail "pre-top.txt lacks sync-registry.yaml"
    grep -Fxq -e "capability-packs" "$bp/pre-top.txt" || fail "pre-top.txt lacks capability-packs"

    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_size() {
    local sbx proj bp tb total
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    [ -n "$bp" ] && [ -d "$bp" ] || { fail "no backup dir at BACKUP_PATH='$bp'"; rm -rf "$sbx"; return 1; }
    tb="$(tree_bytes "$bp")"
    total="$(tree_bytes "$proj/.tad")"
    [ "$tb" -gt 0 ] || fail "backup is empty"
    [ $((tb * 5)) -lt "$total" ] || fail "backup bytes $tb not < 20% of .tad total $total"
    [ -z "$(find "$bp" -type f -size +4M -print -quit)" ] || fail "a >=5M file entered the backup"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_location() {
    local sbx proj bp before_root after_root before_tad after_tad
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    before_root="$(ls -A "$proj" | LC_ALL=C sort)"
    before_tad="$(tree_manifest "$proj/.tad")"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    after_root="$(ls -A "$proj" | LC_ALL=C sort)"
    after_tad="$(tree_manifest "$proj/.tad")"
    [ "$before_root" = "$after_root" ] || fail "project root gained entries during backup"
    [ "$before_tad" = "$after_tad" ] || fail "project .tad changed during backup"
    case "$bp" in
        "$sbx/backups"/*) ;;
        *) fail "backup not under redirected root: $bp" ;;
    esac
    [ "$(perm_of "$sbx/backups")" = "700" ] || fail "backup root perms != 700 ($(perm_of "$sbx/backups"))"
    [ "$(perm_of "$(dirname "$bp")")" = "700" ] || fail "group dir perms != 700 ($(perm_of "$(dirname "$bp")"))"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_default_home() {
    local sbx proj bp
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    DB_UNSET_ROOT=1 do_backup "$sbx" "$proj" || { fail "backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    case "$bp" in
        "$sbx/home/.tad-backups/proj/"*) ;;
        *) fail "default backup path not \$HOME/.tad-backups/<group>/<ts>: $bp" ;;
    esac
    [ -f "$bp/manifest.txt" ] || fail "default-home backup lacks manifest"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_retention() {
    local sbx proj gdir i sbx2 proj2 g2
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    gdir="$sbx/backups/proj"
    # Another repo's group + a non-pattern junk dir: prune must never touch.
    plant_complete_backup "$sbx/backups/other/20200101_000000" "OTHER-GROUP"
    mkdir -p "$gdir/not-a-backup"
    printf 'JUNK\n' > "$gdir/not-a-backup/file.txt"

    for i in 1 2 3 4; do
        printf 'HOOK-SENTINEL-v%s\n' "$i" > "$proj/.tad/hooks/hook.sh"
        if [ "$i" = "3" ]; then
            # Residual partial backup (no manifest) planted before run 3.
            mkdir -p "$gdir/19990101_000000"
            printf 'RESIDUE\n' > "$gdir/19990101_000000/partial.txt"
        fi
        do_backup "$sbx" "$proj" || { fail "backup run $i rc != 0"; break; }
    done
    [ "$(count_complete "$gdir")" = "2" ] || fail "complete backups after 4 runs != 2 ($(count_complete "$gdir"))"
    # The two survivors are the newest two (v4 + v3 hook content).
    local _contents
    _contents="$(for _d in "$gdir"/*/; do cat "${_d}.tad/hooks/hook.sh" 2>/dev/null; done | LC_ALL=C sort | tr '\n' ' ')"
    [ "$_contents" = "HOOK-SENTINEL-v3 HOOK-SENTINEL-v4 " ] || fail "survivors are not newest two: $_contents"
    [ ! -e "$gdir/19990101_000000" ] || fail "residual partial backup not pruned"
    [ -f "$gdir/not-a-backup/file.txt" ] || fail "non-pattern dir was pruned (REQ-2)"
    [ -f "$sbx/backups/other/20200101_000000/payload.txt" ] || fail "other group's backup was pruned (REQ-2)"

    # Same-second name-reuse regression (grokbox find, 2026-10-06): with all
    # runs forced into one second via a date() shadow, run 3's prune frees
    # the base name; run 4 must NOT reuse it (it would sort oldest while
    # being newest). Deterministic on any machine.
    local sbx3 proj3 g3
    sbx3="$(mktemp -d)"; proj3="$sbx3/proj"
    build_fixture "$proj3"
    g3="$sbx3/backups/proj"
    date() {
        if [ "${1:-}" = "+%Y%m%d_%H%M%S" ]; then
            echo "20261006_120000"
        else
            command date "$@"
        fi
    }
    for i in 1 2 3 4; do
        printf 'HOOK-SENTINEL-v%s\n' "$i" > "$proj3/.tad/hooks/hook.sh"
        do_backup "$sbx3" "$proj3" || { fail "same-second run $i rc != 0"; break; }
    done
    unset -f date
    [ "$(count_complete "$g3")" = "2" ] || fail "same-second: complete count != 2 ($(count_complete "$g3"))"
    [ -f "$g3/20261006_120000.3/.tad/hooks/hook.sh" ] || fail "same-second: run 4 did not take the max+1 suffix (.3)"
    [ "$(cat "$g3/20261006_120000.3/.tad/hooks/hook.sh" 2>/dev/null)" = "HOOK-SENTINEL-v4" ] \
        || fail "same-second: newest backup content is not v4"
    [ "$(cat "$g3/20261006_120000.2/.tad/hooks/hook.sh" 2>/dev/null)" = "HOOK-SENTINEL-v3" ] \
        || fail "same-second: second-newest backup content is not v3"
    rm -rf "$sbx3"

    # N1 sub-test (same-second suffix >= 10): byte order would keep .9 over
    # .11; the (timestamp, numeric suffix) key must keep .11.
    sbx2="$(mktemp -d)"; proj2="$sbx2/proj"
    build_fixture "$proj2"
    g2="$sbx2/backups/proj"
    plant_complete_backup "$g2/20200101_000000" "P0"
    plant_complete_backup "$g2/20200101_000000.9" "P9"
    plant_complete_backup "$g2/20200101_000000.10" "P10"
    plant_complete_backup "$g2/20200101_000000.11" "P11"
    do_backup "$sbx2" "$proj2" || fail "N1 backup rc != 0"
    [ "$(count_complete "$g2")" = "2" ] || fail "N1: complete count != 2"
    [ -f "$g2/20200101_000000.11/payload.txt" ] || fail "N1: .11 (true newest planted) not retained"
    [ ! -e "$g2/20200101_000000.9" ] || fail "N1: .9 retained (byte-order sort bug)"
    rm -rf "$sbx" "$sbx2"
    [ "$FAILED" = "0" ]
}

case_collision() {
    local sbx proj names n1 n2 c1 c2
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup 1 rc != 0"; rm -rf "$sbx"; return 1; }
    printf 'HOOK-SENTINEL-v2\n' > "$proj/.tad/hooks/hook.sh"
    do_backup "$sbx" "$proj" || { fail "backup 2 rc != 0"; rm -rf "$sbx"; return 1; }
    names="$(ls "$sbx/backups/proj")"
    [ "$(printf '%s\n' "$names" | grep -c . || true)" = "2" ] || fail "expected exactly 2 backup dirs, got: $names"
    n1="$(printf '%s\n' "$names" | sed -n '1p')"
    n2="$(printf '%s\n' "$names" | sed -n '2p')"
    [ "$n1" != "$n2" ] || fail "collision: both runs used the same dir name"
    c1="$(cat "$sbx/backups/proj/$n1/.tad/hooks/hook.sh")"
    c2="$(cat "$sbx/backups/proj/$n2/.tad/hooks/hook.sh")"
    { [ "$c1" = "HOOK-SENTINEL-v1" ] && [ "$c2" = "HOOK-SENTINEL-v2" ]; } \
        || { [ "$c1" = "HOOK-SENTINEL-v2" ] && [ "$c2" = "HOOK-SENTINEL-v1" ]; } \
        || fail "collision: an earlier backup was overwritten (contents: $c1 / $c2)"
    [ -z "$(find "$sbx/backups" -name 'manifest.txt' -path '*/.tad/*' -print -quit)" ] \
        || fail "a backup was nested inside another backup's .tad"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_restore() {
    local sbx proj bp rb data_before data_after rabs
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; cat "$sbx/out.log"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    echo "  [restore] backup-time .tad manifest:"
    tree_manifest "$bp/.tad" | sed 's/^/    B /'

    # Mutations a failed run + a user would produce after the backup:
    printf 'HOOK-CHANGED\n' > "$proj/.tad/hooks/hook.sh"          # framework file edited
    rm "$proj/.tad/scripts/tool.sh"                               # framework file deleted
    printf 'CONFIG-CHANGED\n' > "$proj/.tad/config.yaml"          # top file edited
    printf 'registry: CHANGED\n' > "$proj/.tad/capability-packs/pack-registry.yaml"
    mkdir -p "$proj/.tad/newdir"                                  # run-created framework dir
    printf 'NEW\n' > "$proj/.tad/newdir/f.txt"
    printf 'EVIDENCE-USER-EDIT\n' > "$proj/.tad/evidence/sentinel.txt"  # user edit AFTER backup
    printf 'NEW-EVIDENCE\n' > "$proj/.tad/evidence/new-evidence.txt"   # user file AFTER backup
    data_before="$(data_manifest "$proj")"
    echo "  [restore] pre-rollback .tad manifest:"
    tree_manifest "$proj/.tad" | sed 's/^/    P /'

    rabs="$(cd "$sbx/backups" && pwd -P)"
    do_rollback "$sbx" "$proj" "$bp" "$rabs"
    [ $? -eq 1 ] || fail "rollback exit != 1 (rollback_on_failure always exits 1)"
    echo "  [restore] post-rollback .tad manifest:"
    tree_manifest "$proj/.tad" | sed 's/^/    A /'

    # AC6 assertion pair: framework surface back at backup-time bytes...
    [ "$(cat "$proj/.tad/hooks/hook.sh")" = "HOOK-SENTINEL-v1" ] || fail "hook.sh not restored"
    [ "$(cat "$proj/.tad/scripts/tool.sh")" = "TOOL-SENTINEL-v1" ] || fail "deleted tool.sh not restored"
    [ "$(cat "$proj/.tad/config.yaml")" = "CONFIG-SENTINEL-v1" ] || fail "config.yaml not restored"
    [ "$(cat "$proj/.tad/capability-packs/pack-registry.yaml")" = "registry: REGISTRY-SENTINEL-v1" ] \
        || fail "pack-registry.yaml not restored"
    [ ! -e "$proj/.tad/newdir" ] || fail "run-created framework dir not removed"
    # ...while the data surface keeps its post-backup state byte for byte.
    data_after="$(data_manifest "$proj")"
    [ "$data_before" = "$data_after" ] || fail "data surface drifted across rollback (REQ-3)"
    [ "$(cat "$proj/.tad/evidence/sentinel.txt")" = "EVIDENCE-USER-EDIT" ] \
        || fail "post-backup user edit was rolled back (REQ-3)"
    [ -f "$proj/.tad/evidence/new-evidence.txt" ] || fail "post-backup user file vanished (REQ-3)"
    [ "$(cat "$proj/.tad/capability-packs/pack-a/tree-sentinel.txt")" = "PACKTREE-SENTINEL-63ef" ] \
        || fail "pack tree sentinel harmed by registry restore (S2.5)"
    # S3.5: pre-existing top-level dangling symlink survives, still dangling.
    [ -L "$proj/.tad/top-dangling" ] && [ ! -e "$proj/.tad/top-dangling" ] \
        || fail "top-level dangling symlink did not survive rollback (S3.5)"
    [ ! -e "$bp" ] || fail "backup not consumed after successful rollback"
    grep -q 'restored:' "$sbx/rb.log" || fail "coverage message missing from rollback output"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_restore_failure() {
    local sbx proj bp rabs
    # (a) dir entry flipped to a file inside the backup before rollback.
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "(a) backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    printf 'HOOK-CHANGED\n' > "$proj/.tad/hooks/hook.sh"
    printf 'TOOL-CHANGED\n' > "$proj/.tad/scripts/tool.sh"
    mkdir -p "$proj/.tad/newdir"; printf 'NEW\n' > "$proj/.tad/newdir/f.txt"
    rm -rf "$bp/.tad/scripts"
    printf 'FLIPPED\n' > "$bp/.tad/scripts"
    rabs="$(cd "$sbx/backups" && pwd -P)"
    do_rollback "$sbx" "$proj" "$bp" "$rabs"
    [ -d "$bp" ] || fail "(a) backup not preserved after failed restore (AC7)"
    grep -Fq 'scripts' "$sbx/rb.log" || fail "(a) error output does not name the failed entry"
    [ "$(cat "$proj/.tad/hooks/hook.sh")" = "HOOK-SENTINEL-v1" ] \
        || fail "(a) entry restored before the failure was un-restored (AC7)"
    [ "$(cat "$proj/.tad/scripts/tool.sh")" = "TOOL-CHANGED" ] \
        || fail "(a) failed entry's target side was modified"
    [ -d "$proj/.tad/newdir" ] || fail "(a) created-entry sweep ran despite restore failure (N4)"
    [ -z "$(find "$proj" -name '*.rollback-staging' -print -quit)" ] \
        || fail "(a) .rollback-staging residue left behind (N3)"
    rm -rf "$sbx"

    # (b) file entry flipped to a directory inside the backup.
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "(b) backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    rm "$bp/.tad/config.yaml"
    mkdir "$bp/.tad/config.yaml"
    rabs="$(cd "$sbx/backups" && pwd -P)"
    do_rollback "$sbx" "$proj" "$bp" "$rabs"
    [ -d "$bp" ] || fail "(b) backup not preserved after failed restore (AC7)"
    grep -Fq 'config.yaml' "$sbx/rb.log" || fail "(b) error output does not name the failed entry"
    [ -z "$(find "$proj" -name '*.rollback-staging' -print -quit)" ] \
        || fail "(b) .rollback-staging residue left behind (N3)"
    rm -rf "$sbx"

    # (c) manifest entry payload deleted from the backup.
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "(c) backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    rm -rf "$bp/.tad/hooks"
    rabs="$(cd "$sbx/backups" && pwd -P)"
    do_rollback "$sbx" "$proj" "$bp" "$rabs"
    [ -d "$bp" ] || fail "(c) backup not preserved after failed restore (AC7)"
    grep -Fq 'hooks' "$sbx/rb.log" || fail "(c) error output does not name the failed entry"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_prune_failure() {
    local sbx proj gdir stuck bp
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    gdir="$sbx/backups/proj"
    stuck="$gdir/20200101_000000"
    plant_complete_backup "$stuck" "OLD1"
    plant_complete_backup "$gdir/20200102_000000" "OLD2"
    plant_complete_backup "$gdir/20200103_000000" "OLD3"
    # Deterministic deletion failure: an rm() shadow that refuses exactly the
    # stuck path (works as root, where chmod games do not). Everything else
    # delegates to the real rm. Defined in this shell; do_backup's subshell
    # inherits it (fork), and prune_backups resolves `rm` at call time.
    STUCK_PATH="$stuck"
    rm() {
        local _a
        for _a in "$@"; do
            [ "$_a" = "$STUCK_PATH" ] && return 1
        done
        command rm "$@"
    }
    do_backup "$sbx" "$proj"
    local rc=$?
    unset -f rm
    [ "$rc" = "0" ] || { fail "backup blocked by prune failure (AC8)"; cat "$sbx/out.log"; }
    grep -Fq "$stuck" "$sbx/out.log" || fail "prune failure did not warn naming the stuck backup (AC8)"
    bp="$(cat "$sbx/bp.txt")"
    [ -f "$bp/manifest.txt" ] || fail "new backup incomplete after prune failure (AC8)"
    [ -f "$stuck/payload.txt" ] || fail "stuck backup content harmed"
    [ ! -e "$gdir/20200102_000000" ] || fail "deletable old backup was not pruned"
    [ "$(count_complete "$gdir")" = "3" ] || fail "complete count != 3 (new + newest old + stuck): $(count_complete "$gdir")"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_repo_key() {
    local sbx ga gb phys_a phys_b
    sbx="$(mktemp -d)"
    build_fixture "$sbx/a/proj"
    build_fixture "$sbx/b/proj"
    build_fixture "$sbx/sp ace"
    phys_a="$(cd "$sbx/a/proj" && pwd -P)"
    phys_b="$(cd "$sbx/b/proj" && pwd -P)"

    do_backup "$sbx" "$sbx/a/proj" || fail "backup a rc != 0"
    ga="$(ls "$sbx/backups")"
    [ "$ga" = "proj" ] || fail "first group key != proj: $ga"
    [ "$(cat "$sbx/backups/proj"/*/origin.txt)" = "$phys_a" ] || fail "group proj origin != a/proj"

    do_backup "$sbx" "$sbx/b/proj" || fail "backup b rc != 0"
    gb="$(ls "$sbx/backups" | grep '^proj-' | head -1 || true)"
    [ -n "$gb" ] || fail "same-basename repo did not get a suffixed group"
    [ "$(cat "$sbx/backups/$gb"/*/origin.txt)" = "$phys_b" ] || fail "suffixed group origin != b/proj"
    [ "$(cat "$sbx/backups/proj"/*/origin.txt)" = "$phys_a" ] || fail "a/proj group origin clobbered"

    do_backup "$sbx" "$sbx/b/proj" || fail "backup b2 rc != 0"
    do_backup "$sbx" "$sbx/b/proj" || fail "backup b3 rc != 0"
    [ "$(count_complete "$sbx/backups/$gb")" = "2" ] || fail "b group retention != 2"
    [ "$(count_complete "$sbx/backups/proj")" = "1" ] || fail "a group retention disturbed by b runs"

    do_backup "$sbx" "$sbx/sp ace" || fail "backup space-name rc != 0"
    [ -d "$sbx/backups/sp_ace" ] || fail "space in basename not sanitized to sp_ace"
    [ -z "$(ls "$sbx/backups" | grep ' ' || true)" ] || fail "a group dir name still contains a space"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_guard() {
    local sbx proj bp rabs before after f
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    rabs="$(cd "$sbx/backups" && pwd -P)"
    before="$(tree_manifest "$proj/.tad")"

    # (i) outside the backup root entirely (manifest planted).
    mkdir -p "$sbx/outside/20260101_000000"
    printf 'hooks\nversion=3.1.0\n' > "$sbx/outside/20260101_000000/manifest.txt"
    # (ii) inside the root but name off-pattern (manifest planted).
    mkdir -p "$sbx/backups/proj/not-a-timestamp"
    printf 'hooks\nversion=3.1.0\n' > "$sbx/backups/proj/not-a-timestamp/manifest.txt"
    # (iii) inside the root, name on-pattern, but NO manifest.
    mkdir -p "$sbx/backups/proj/20260101_000000/.tad"
    # (iv) inside the TARGET root (the old assert_under_root would PASS this
    # and wholesale-restore from it — the discriminating sub-case for AC10):
    # a forged "backup" planted in the project with a manifest + payload.
    mkdir -p "$proj/forged/20260101_000000/.tad/hooks"
    printf 'hooks\nversion=3.1.0\n' > "$proj/forged/20260101_000000/manifest.txt"
    printf 'FORGED\n' > "$proj/forged/20260101_000000/.tad/hooks/hook.sh"

    for f in "$sbx/outside/20260101_000000" "$sbx/backups/proj/not-a-timestamp" "$sbx/backups/proj/20260101_000000" "$proj/forged/20260101_000000"; do
        do_rollback "$sbx" "$proj" "$f" "$rabs"
        [ $? -eq 1 ] || fail "forged path not refused with exit 1: $f"
        grep -Fq 'REFUSED' "$sbx/rb.log" || fail "no REFUSED line for forged path: $f"
        grep -Fq "$f" "$sbx/rb.log" || fail "refusal does not name the forged path: $f"
    done
    after="$(tree_manifest "$proj/.tad")"
    [ "$before" = "$after" ] || fail "target .tad bytes moved under forged backup paths (AC10)"
    [ -d "$bp" ] || fail "the genuine backup was consumed by a forged rollback"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_root_guard() {
    local sbx proj before after
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    before="$(tree_manifest "$proj")"

    DB_ROOT="$proj/inside" do_backup "$sbx" "$proj"
    [ $? -ne 0 ] || fail "root inside target not refused (AC11)"
    grep -Fq 'backup root' "$sbx/out.log" || fail "inside-root refusal not logged"
    [ ! -e "$proj/inside" ] || fail "inside-root attempt created a dir in the project"

    DB_ROOT="$proj" do_backup "$sbx" "$proj"
    [ $? -ne 0 ] || fail "root == target not refused (AC11)"

    DB_ROOT="relative/backups" do_backup "$sbx" "$proj"
    [ $? -ne 0 ] || fail "relative TAD_BACKUP_ROOT not refused"
    grep -Fq 'TAD_BACKUP_ROOT' "$sbx/out.log" || fail "relative-root refusal not logged"

    after="$(tree_manifest "$proj")"
    [ "$before" = "$after" ] || fail "project tree changed by refused backups (AC11)"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_root_alias() {
    # Gate 3 SAFETY F-S1: a symlink alias as TAD_BACKUP_ROOT pointing at an
    # EXISTING directory inside the target (755, with content) must be
    # refused with ZERO trace — the physical judgement runs before any
    # mkdir/chmod effect, so the aliased directory keeps its permissions
    # and bytes. (The pre-fix order chmod'ed it to 700 before refusing.)
    local sbx proj inner before_manifest before_entries
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    inner="$proj/inner"
    mkdir -p "$inner/sub"
    printf 'INNER-SENTINEL\n' > "$inner/keep.txt"
    printf 'INNER-SUB-SENTINEL\n' > "$inner/sub/keep2.txt"
    chmod 755 "$inner"
    ln -s "$inner" "$sbx/alias"
    before_manifest="$(tree_manifest "$inner")"
    before_entries="$(ls -A "$inner" | LC_ALL=C sort)"

    DB_ROOT="$sbx/alias" do_backup "$sbx" "$proj"
    [ $? -ne 0 ] || fail "symlink alias into target not refused (F-S1)"
    grep -Fq 'backup root' "$sbx/out.log" || fail "alias refusal not logged"
    [ "$(perm_of "$inner")" = "755" ] || fail "aliased dir perms changed by refused call: $(perm_of "$inner") (F-S1)"
    [ "$(tree_manifest "$inner")" = "$before_manifest" ] || fail "aliased dir content changed by refused call (F-S1)"
    [ "$(ls -A "$inner" | LC_ALL=C sort)" = "$before_entries" ] || fail "aliased dir gained/lost entries by refused call (F-S1)"

    # Retained C1 behaviour, now ordered after the refusal check: a
    # legitimate EXISTING root outside the target is still tightened to
    # 700 and the backup succeeds.
    mkdir -p "$sbx/existing-root"
    chmod 755 "$sbx/existing-root"
    DB_ROOT="$sbx/existing-root" do_backup "$sbx" "$proj" || fail "backup via existing outside root rc != 0"
    [ "$(perm_of "$sbx/existing-root")" = "700" ] || fail "existing outside root not tightened to 700 ($(perm_of "$sbx/existing-root"))"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_legacy() {
    local sbx proj bp rabs h0 h1
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    h0="$(tree_manifest "$proj/.tad.backup.20000101_000000")"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; rm -rf "$sbx"; return 1; }
    grep -qi 'legacy' "$sbx/out.log" || fail "no legacy notice line in backup output (FR8)"
    bp="$(cat "$sbx/bp.txt")"
    printf 'HOOK-CHANGED\n' > "$proj/.tad/hooks/hook.sh"
    rabs="$(cd "$sbx/backups" && pwd -P)"
    do_rollback "$sbx" "$proj" "$bp" "$rabs"
    h1="$(tree_manifest "$proj/.tad.backup.20000101_000000")"
    [ "$h0" = "$h1" ] || fail "legacy backup bytes changed across backup+rollback (AC12)"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

case_symlink() {
    local sbx proj bp link
    sbx="$(mktemp -d)"; proj="$sbx/proj"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0 with dangling link in framework dir (AC13)"; cat "$sbx/out.log"; rm -rf "$sbx"; return 1; }
    bp="$(cat "$sbx/bp.txt")"
    link="$bp/.tad/hooks/dangling-in-framework"
    [ -L "$link" ] || fail "dangling symlink not preserved as a symlink in backup (AC13)"
    [ "$(readlink "$link")" = "/nonexistent-tad-test-target" ] || fail "symlink target altered in backup"
    rm -rf "$sbx"
    [ "$FAILED" = "0" ]
}

# --- runner -------------------------------------------------------------------

ALL_CASES="set-equality size location default-home retention collision restore restore-failure prune-failure repo-key guard root-guard root-alias legacy symlink"

run_one() {
    local name="$1" fn
    fn="case_$(printf '%s' "$name" | tr '-' '_')"
    FAILED=0
    if "$fn"; then
        echo "PASS $name"
        return 0
    fi
    echo "FAIL $name"
    return 1
}

if [ "${1:-}" = "--case" ]; then
    [ -n "${2:-}" ] || { echo "usage: $0 --case <name>" >&2; exit 2; }
    run_one "$2"
    exit $?
fi
if [ $# -ne 0 ]; then
    echo "usage: $0 [--case <name>]" >&2
    exit 2
fi

PASS_N=0; FAIL_N=0
for _c in $ALL_CASES; do
    if run_one "$_c"; then PASS_N=$((PASS_N + 1)); else FAIL_N=$((FAIL_N + 1)); fi
done
echo ""
echo "TALLY: PASS=$PASS_N FAIL=$FAIL_N"
[ "$FAIL_N" -eq 0 ] || exit 1
exit 0
