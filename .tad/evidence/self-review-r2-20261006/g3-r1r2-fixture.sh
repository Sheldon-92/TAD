#!/usr/bin/env bash
# g3-r1r2-fixture.sh — isolated-fixture harness for self-review R2 group 3
# (tad.sh R1 _tad_missing_from + R2 pre-tree sweep). Same discipline as
# tad-backup-test.sh: functions EXTRACTED VERBATIM from tad.sh, every
# scenario in its own mktemp sandbox, HOME/TAD_BACKUP_ROOT redirected,
# tad.sh itself never run — no real project repo is ever touched.
#
# R1 scenes (probe semantics):
#   r1-1 src dangling symlink, dst missing it      -> detected (rc 1)
#   r1-2 dst dangling symlink, src has real file   -> present (rc 0)
#   r1-3 dangling symlinks both sides, same name   -> present (rc 0)
#   r1-4 identical trees                           -> rc 0
#   r1-5 src real file, dst missing it             -> detected (rc 1)
# R2 scenes (backup -> mutate -> rollback):
#   r2-1 nested run-created entries swept; pre-existing restored
#   r2-2 zero run-created entries: tree identical after rollback
#   r2-3 created dangling symlink swept, its target untouched;
#        pre-existing dangling symlink survives
#   r2-4 pre-R2 backup (pre-tree.txt removed): WARN + ZERO deletions
#   r2-5 run-created top-level tree removed wholesale
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAD_SH="$SCRIPT_DIR/../../../tad.sh"
[ -f "$TAD_SH" ] || { echo "FATAL: tad.sh not found at $TAD_SH" >&2; exit 2; }

SHIM="$(mktemp)"
trap 'rm -f "$SHIM"' EXIT
sed -n '/^TAD_ZERO_TOUCH=/,/^TAD_REGISTRY_FILE=/p' "$TAD_SH" >> "$SHIM"
echo "" >> "$SHIM"
for fn in _literal_has_prefix assert_under_root \
          log_info log_success log_warn log_error \
          derive_framework_dirs derive_framework_top_files \
          resolve_backup_root repo_group_key prune_backups backup_existing \
          assert_under_backup_root \
          _tad_missing_from _tad_tree_equal \
          restore_dir_entry restore_file_entry cleanup_source_tree \
          rollback_on_failure; do
    sed -n "/^${fn}() {/,/^}/p" "$TAD_SH" >> "$SHIM"
    echo "" >> "$SHIM"
done
for fn in _tad_missing_from backup_existing rollback_on_failure; do
    grep -q "^${fn}() {" "$SHIM" || { echo "FATAL: shim missing $fn" >&2; exit 2; }
done

BLUE="" GREEN="" YELLOW="" RED="" NC=""
BACKUP_PATH="" BACKUP_PATH_ABS="" TARGET_ROOT=""
ROLLBACK_SNAP="" ROLLBACK_CREATED_TOP="" ROLLBACK_PRE_TOP=""
MERGE_CREATED_BACKUP="" TAD_BACKUP_ROOT_ABS="" BACKUP_GROUP=""
TAD_SRC="" TAD_SRC_DOWNLOADED=0 TAD_TMP_ROOT=""
# shellcheck disable=SC1090
source "$SHIM"

FAILED=0
fail() { echo "  FAIL-ASSERT: $1"; FAILED=1; }
pass_scene() { [ "$FAILED" = "0" ] && echo "  SCENE PASS: $1" || echo "  SCENE FAIL: $1"; }

tree_manifest() {
    ( cd "$1" || exit 99
      find . -type f -exec cksum {} + | LC_ALL=C sort -k 3
      find . -type l | LC_ALL=C sort | while IFS= read -r _l; do
          printf 'L %s %s\n' "$(readlink "$_l")" "$_l"
      done )
}

build_fixture() {
    local p="$1"
    mkdir -p "$p/.tad/hooks" "$p/.tad/scripts" \
             "$p/.tad/evidence" "$p/.tad/archive" "$p/.tad/active" \
             "$p/.tad/project-knowledge" "$p/.tad/capability-packs/pack-a"
    printf 'HOOK-SENTINEL-v1\n' > "$p/.tad/hooks/hook.sh"
    printf 'TOOL-SENTINEL-v1\n' > "$p/.tad/scripts/tool.sh"
    ln -s /nonexistent-tad-test-target "$p/.tad/hooks/dangling-in-framework"
    printf 'EVIDENCE-SENTINEL\n' > "$p/.tad/evidence/sentinel.txt"
    printf '3.2.0\n' > "$p/.tad/version.txt"
    printf 'CONFIG-SENTINEL-v1\n' > "$p/.tad/config.yaml"
    printf 'registry: REGISTRY-SENTINEL-v1\n' > "$p/.tad/capability-packs/pack-registry.yaml"
    printf 'PACKTREE-SENTINEL\n' > "$p/.tad/capability-packs/pack-a/tree-sentinel.txt"
    printf 'PROJECT-FILE\n' > "$p/README.md"
}

do_backup() {
    local sbx="$1" proj="$2"
    ( cd "$proj" || exit 99
      export HOME="$sbx/home"
      export TAD_BACKUP_ROOT="$sbx/backups"
      backup_existing
      _brc=$?
      printf '%s' "${BACKUP_PATH:-}" > "$sbx/bp.txt"
      exit $_brc
    ) > "$sbx/out.log" 2>&1
    return $?
}

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

setup_rb() { # <sbx> <proj> -> echoes backup path; runs backup
    local sbx="$1" proj="$2"
    build_fixture "$proj"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; cat "$sbx/out.log"; return 1; }
    cat "$sbx/bp.txt"
}

run_rb() { # <sbx> <proj> <bp>
    local sbx="$1" proj="$2" bp="$3" rabs
    rabs="$(cd "$sbx/backups" && pwd -P)"
    do_rollback "$sbx" "$proj" "$bp" "$rabs"
    [ $? -eq 1 ] || fail "rollback exit != 1"
}

# ---------------- R1 scenes ----------------
r1_pair() { # fresh src/dst pair in $1
    mkdir -p "$1/src/sub" "$1/dst/sub"
    printf 'A\n' > "$1/src/sub/a.txt"; printf 'A\n' > "$1/dst/sub/a.txt"
}

scene_r1_1() { FAILED=0; local d; d="$(mktemp -d)"; r1_pair "$d"
    ln -s /nonexistent-x "$d/src/sub/dangling"
    _tad_missing_from "$d/src" "$d/dst"; [ $? -eq 1 ] || fail "dangling src entry not detected"
    rm -rf "$d"; pass_scene r1-1; }
scene_r1_2() { FAILED=0; local d; d="$(mktemp -d)"; r1_pair "$d"
    ln -s /nonexistent-x "$d/dst/sub/dangling"
    printf 'REAL\n' > "$d/src/sub/dangling"
    _tad_missing_from "$d/src" "$d/dst"; [ $? -eq 0 ] || fail "dst dangling symlink misjudged as missing"
    rm -rf "$d"; pass_scene r1-2; }
scene_r1_3() { FAILED=0; local d; d="$(mktemp -d)"; r1_pair "$d"
    ln -s /nonexistent-x "$d/src/sub/dangling"; ln -s /nonexistent-y "$d/dst/sub/dangling"
    _tad_missing_from "$d/src" "$d/dst"; [ $? -eq 0 ] || fail "double dangling same-name misjudged"
    rm -rf "$d"; pass_scene r1-3; }
scene_r1_4() { FAILED=0; local d; d="$(mktemp -d)"; r1_pair "$d"
    ln -s a.txt "$d/src/sub/link"; ln -s a.txt "$d/dst/sub/link"
    _tad_missing_from "$d/src" "$d/dst"; [ $? -eq 0 ] || fail "identical trees flagged"
    rm -rf "$d"; pass_scene r1-4; }
scene_r1_5() { FAILED=0; local d; d="$(mktemp -d)"; r1_pair "$d"
    printf 'B\n' > "$d/src/sub/b.txt"
    _tad_missing_from "$d/src" "$d/dst"; [ $? -eq 1 ] || fail "missing real file not detected"
    rm -rf "$d"; pass_scene r1-5; }

# ---------------- R2 scenes ----------------
scene_r2_1() { FAILED=0; local sbx proj bp; sbx="$(mktemp -d)"; proj="$sbx/proj"
    # Discriminating placements: capability-packs/pack-a/ and local-stuff/
    # are pre-existing dirs the manifest restore does NOT touch wholesale
    # (registry-only restores just the registry file; local-stuff is not a
    # derivation dir) — only the pre-tree sweep can remove creations there.
    build_fixture "$proj"
    mkdir -p "$proj/.tad/local-stuff"; printf 'KEEP\n' > "$proj/.tad/local-stuff/keep.txt"
    do_backup "$sbx" "$proj" || { fail "backup rc != 0"; cat "$sbx/out.log"; rm -rf "$sbx"; pass_scene r2-1; return; }
    bp="$(cat "$sbx/bp.txt")"
    [ -f "$bp/pre-tree.txt" ] || fail "pre-tree.txt not generated"
    grep -Fxq 'hooks/dangling-in-framework' "$bp/pre-tree.txt" || fail "pre-tree missing dangling entry"
    grep -Fxq 'local-stuff/keep.txt' "$bp/pre-tree.txt" || fail "pre-tree missing local-stuff entry"
    printf 'HOOK-CHANGED\n' > "$proj/.tad/hooks/hook.sh"
    printf 'CREATED\n' > "$proj/.tad/hooks/lib-created.sh"
    printf 'CREATED\n' > "$proj/.tad/capability-packs/pack-a/created-in-pack.txt"
    printf 'CREATED\n' > "$proj/.tad/local-stuff/created-local.txt"
    mkdir -p "$proj/.tad/scripts/newsub/deep"
    printf 'CREATED\n' > "$proj/.tad/scripts/newsub/deep/f.txt"
    run_rb "$sbx" "$proj" "$bp"
    [ "$(cat "$proj/.tad/hooks/hook.sh")" = "HOOK-SENTINEL-v1" ] || fail "hook.sh not restored"
    [ ! -e "$proj/.tad/hooks/lib-created.sh" ] || fail "nested created file survived rollback"
    [ ! -e "$proj/.tad/capability-packs/pack-a/created-in-pack.txt" ] || fail "sweep missed created file in pack tree"
    [ "$(cat "$proj/.tad/capability-packs/pack-a/tree-sentinel.txt")" = "PACKTREE-SENTINEL" ] || fail "pre-existing pack file harmed"
    [ ! -e "$proj/.tad/local-stuff/created-local.txt" ] || fail "sweep missed created file in pre-existing local dir"
    [ "$(cat "$proj/.tad/local-stuff/keep.txt")" = "KEEP" ] || fail "pre-existing local file harmed"
    [ ! -e "$proj/.tad/scripts/newsub" ] || fail "nested created tree survived rollback"
    [ -L "$proj/.tad/hooks/dangling-in-framework" ] || fail "pre-existing dangling link harmed"
    rm -rf "$sbx"; pass_scene r2-1; }

scene_r2_2() { FAILED=0; local sbx proj bp before after; sbx="$(mktemp -d)"; proj="$sbx/proj"
    bp="$(setup_rb "$sbx" "$proj")"
    before="$(tree_manifest "$proj/.tad")"
    printf 'HOOK-CHANGED\n' > "$proj/.tad/hooks/hook.sh"
    printf 'CONFIG-CHANGED\n' > "$proj/.tad/config.yaml"
    run_rb "$sbx" "$proj" "$bp"
    after="$(tree_manifest "$proj/.tad")"
    [ "$before" = "$after" ] || { fail "tree drifted across rollback with zero created entries"; diff <(printf '%s' "$before") <(printf '%s' "$after"); }
    rm -rf "$sbx"; pass_scene r2-2; }

scene_r2_3() { FAILED=0; local sbx proj bp; sbx="$(mktemp -d)"; proj="$sbx/proj"
    bp="$(setup_rb "$sbx" "$proj")"
    printf 'TARGET-CONTENT\n' > "$sbx/victim.txt"
    ln -s "$sbx/victim.txt" "$proj/.tad/hooks/created-dangling"
    run_rb "$sbx" "$proj" "$bp"
    [ ! -L "$proj/.tad/hooks/created-dangling" ] || fail "created dangling symlink not swept"
    [ "$(cat "$sbx/victim.txt")" = "TARGET-CONTENT" ] || fail "sweep touched the link target"
    [ -L "$proj/.tad/hooks/dangling-in-framework" ] && [ ! -e "$proj/.tad/hooks/dangling-in-framework" ] \
        || fail "pre-existing dangling symlink did not survive"
    rm -rf "$sbx"; pass_scene r2-3; }

scene_r2_4() { FAILED=0; local sbx proj bp; sbx="$(mktemp -d)"; proj="$sbx/proj"
    bp="$(setup_rb "$sbx" "$proj")"
    rm "$bp/pre-tree.txt"   # simulate a pre-R2 backup
    printf 'HOOK-CHANGED\n' > "$proj/.tad/hooks/hook.sh"
    # Placed inside the pack tree (restore does not touch pack bodies), so
    # only the sweep could delete it — with pre-tree missing it must survive.
    printf 'CREATED\n' > "$proj/.tad/capability-packs/pack-a/created-in-pack.txt"
    run_rb "$sbx" "$proj" "$bp"
    grep -q 'pre-tree.txt missing' "$sbx/rb.log" || fail "no pre-tree WARN in rollback log"
    [ -f "$proj/.tad/capability-packs/pack-a/created-in-pack.txt" ] || fail "old-backup sweep deleted entries (must be zero)"
    [ "$(cat "$proj/.tad/hooks/hook.sh")" = "HOOK-SENTINEL-v1" ] || fail "restore broken for old backup"
    rm -rf "$sbx"; pass_scene r2-4; }

scene_r2_5() { FAILED=0; local sbx proj bp; sbx="$(mktemp -d)"; proj="$sbx/proj"
    bp="$(setup_rb "$sbx" "$proj")"
    mkdir -p "$proj/.tad/brandnew/sub"
    printf 'NEW\n' > "$proj/.tad/brandnew/sub/f.txt"
    run_rb "$sbx" "$proj" "$bp"
    [ ! -e "$proj/.tad/brandnew" ] || fail "run-created top-level tree survived"
    rm -rf "$sbx"; pass_scene r2-5; }

for s in r1_1 r1_2 r1_3 r1_4 r1_5 r2_1 r2_2 r2_3 r2_4 r2_5; do
    echo "== scene $s"
    scene_$s
done
echo "== fixture done"
