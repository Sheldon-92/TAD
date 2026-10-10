#!/usr/bin/env bash
# installer-data-safety-fixture.sh — sandbox acceptance suite for the installer
# data-safety remainder (FR-1 + FR-5 + F-05/F-06/F-07/F-08 + F-34 + AC2.5).
#
# Usage: bash installer-data-safety-fixture.sh --case ac2.1|...|ac2.28|r1|all
#
# Contract (handoff §4.3 + §9.1):
#   - EVERY sandbox installer invocation carries --yes (bare runs exit 0 with
#     ZERO mutations, so rc alone is vacuous) + a positive-install proof
#     (.tad/version.txt == staged-source version) or, for failure-expected
#     runs, a pre/post zero-mutation snapshot.
#   - Offline only: a fail-closed curl() function-export shim (+ PATH shim
#     belt-and-braces) whose invocation logs are asserted EMPTY per case.
#   - Snapshots live in a SIBLING dir OUTSIDE the sandbox target
#     ($SANDBOX/snapshots vs $SANDBOX/target).
#   - Fixture preflight refuses a TARGET outside the mktemp root, == /, or ==
#     the live repo. The installer NEVER runs against the live repo and
#     --source NEVER points at it: each case stages a PRUNED source copy
#     (4 sentinels + version.txt + framework payload) under the sandbox.
#   - Fixture cleanup uses guarded removal only (prefix + non-empty + dir).
#
# Portability: baseline tools only (grep/awk/sed/comm/cmp/diff/python3/perl —
# NO rg), `grep -F -e` for literal text, LC_ALL=C on sorts, no
# `for x in $VAR` word-splitting (while-read instead). Smoke-runs under
# `bash` AND `zsh` (no arrays, no `export -f` unguarded, no bash-only
# builtins outside explicit `bash` invocations of tad.sh itself).
set -euo pipefail

FIXTURE_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO="$(cd "$FIXTURE_DIR/../.." && pwd -P)"
FIXTURES="$FIXTURE_DIR/fixtures"
TADSH="$REPO/tad.sh"
GUARD="$REPO/.tad/hooks/lib/release-verify.sh"
DERIVE="$REPO/.tad/hooks/lib/derive-sync-set.sh"
VERIFIER="$FIXTURE_DIR/upgrade-acceptance.sh"

CASE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --case) CASE="${2:-}"; shift 2 ;;
    --case=*) CASE="${1#--case=}"; shift ;;
    --help|-h) echo "Usage: bash installer-data-safety-fixture.sh --case ac2.1|...|ac2.28|r1|all" >&2; exit 0 ;;
    *) echo "fixture: unknown option '$1' (use --help)" >&2; exit 2 ;;
  esac
done
if [ -z "$CASE" ]; then echo "fixture: --case is required" >&2; exit 2; fi

PASS=0
FAIL=0
CURRENT_CASE=""

pass() { PASS=$((PASS + 1)); printf '  ✅ %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  ❌ %s\n' "$1"; }

# ── sandbox lifecycle ────────────────────────────────────────────────
SANDBOX=""; TARGET=""; SNAP=""; SOURCE=""; SHIMBIN=""
CURL_FUNC_LOG=""; CURL_PATH_LOG=""

new_sandbox() {
  SANDBOX="$(mktemp -d /tmp/tad-ac.XXXXXX)" || { echo "fixture: mktemp failed" >&2; exit 2; }
  TARGET="$SANDBOX/target"
  SNAP="$SANDBOX/snapshots"
  SOURCE="$SANDBOX/source"
  SHIMBIN="$SANDBOX/bin"
  CURL_FUNC_LOG="$SANDBOX/curl-func.log"
  CURL_PATH_LOG="$SANDBOX/curl-path.log"
  mkdir -p "$TARGET" "$SNAP" "$SHIMBIN"
  # Phase 5b rework R1: pin the backup root inside the sandbox (outside TARGET)
  # for every case, whatever the caller exported, so no installer run can write
  # to $HOME/.tad-backups. run_install_cc still overrides it per call.
  TAD_BACKUP_ROOT="$SANDBOX/tad-backups"
  export TAD_BACKUP_ROOT
  : > "$CURL_FUNC_LOG"
  : > "$CURL_PATH_LOG"
  # PATH shim (belt-and-braces; the mechanism that survives under zsh, where
  # `export -f` does not exist): a fail-closed curl early on PATH.
  printf '#!/bin/sh\nprintf "%%s\\n" "PATH-SHIM-CURL-INVOKED $*" >> "%s"\nexit 1\n' "$CURL_PATH_LOG" > "$SHIMBIN/curl"
  chmod +x "$SHIMBIN/curl"
  # Function-export shim where supported (bash): fails closed + logs.
  if [ -n "${BASH_VERSION:-}" ]; then
    curl() { printf '%s\n' "FUNC-SHIM-CURL-INVOKED $*" >> "$CURL_FUNC_LOG"; return 1; }
    export -f curl
  fi
  preflight_target
}

preflight_target() {
  local rt rs rr
  rt="$(cd "$TARGET" && pwd -P)" || { echo "fixture: cannot resolve TARGET" >&2; exit 2; }
  rs="$(cd "$SANDBOX" && pwd -P)" || { echo "fixture: cannot resolve SANDBOX" >&2; exit 2; }
  rr="$(cd "$REPO" && pwd -P)" || { echo "fixture: cannot resolve REPO" >&2; exit 2; }
  if [ "$rt" = "/" ]; then echo "fixture: TARGET refuses /" >&2; exit 2; fi
  if [ "$rt" = "$rr" ]; then echo "fixture: TARGET refuses the live repo" >&2; exit 2; fi
  case "$rt/" in
    "$rs"/*) ;;
    *) echo "fixture: TARGET escapes the mktemp root ($rt not under $rs)" >&2; exit 2 ;;
  esac
}

guarded_cleanup() {
  # Family prefix /tmp/tad-ac (NOT /tmp/tad-ac. literal): members are
  # /tmp/tad-ac.XXXXXX sandbox dirs AND /tmp/tad-ac-parent.XXXXXX sentinel
  # files — after `tad-ac` comes `-`, never `.`, so a `.*` pattern would
  # silently refuse half the family (found live 2026-09-03: vacuous FAIL).
  # This is typo-protection (never bare-rm a wrong path), not an attacker
  # boundary: non-empty + plain dir/file + symlink refusal do the real work.
  local d="$1"
  if [ -z "$d" ]; then echo "fixture: refusing cleanup of empty path" >&2; return 1; fi
  case "$d" in
    /tmp/tad-ac*)
      if [ -d "$d" ] && [ ! -L "$d" ]; then rm -rf "$d"
      elif [ -f "$d" ] && [ ! -L "$d" ]; then rm -f "$d"
      else echo "fixture: not a plain dir/file: $d" >&2; return 1; fi
      ;;
    *) echo "fixture: refusing cleanup outside mktemp root: $d" >&2; return 1 ;;
  esac
}

# ── pruned source staging (NEVER the live repo) ──────────────────────
stage_pruned_source() {
  mkdir -p "$SOURCE"
  cp "$REPO/tad.sh" "$REPO/AGENTS.md" "$SOURCE/"
  mkdir -p "$SOURCE/.tad"
  # Top-level framework FILES (every regular file minus the top-level deny).
  local f bn
  for f in "$REPO"/.tad/*; do
    [ -f "$f" ] || continue
    bn="$(basename "$f")"
    [ "$bn" = "sync-registry.yaml" ] && continue
    cp "$f" "$SOURCE/.tad/"
  done
  # Framework DIRS as derived by the single source of truth (deny-listed
  # project-data dirs are structurally excluded — they are never synced).
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$REPO/.tad/$d" ]; then
      mkdir -p "$SOURCE/.tad/$d"
      cp -R "$REPO/.tad/$d/." "$SOURCE/.tad/$d/"
    fi
  done <<< "$(bash "$DERIVE" --dirs "$REPO")"
  # v3.0.0: no .claude/ in the source tree (Claude Code path removed).
  # .agents/skills is the SOLE skill source the installer reads.
  mkdir -p "$SOURCE/.agents"
  cp -R "$REPO/.agents/skills" "$SOURCE/.agents/skills"
  # OpenCode updater-only command (exact single-file projection).
  mkdir -p "$SOURCE/.opencode/commands"
  cp "$REPO/.opencode/commands/tad-update.md" "$SOURCE/.opencode/commands/"
  # Sentinel self-check: the staged tree carries the 4 sentinels + version.
  local s
  for s in tad.sh .tad .agents; do
    if [ ! -e "$SOURCE/$s" ]; then echo "fixture: staged source missing sentinel $s" >&2; exit 2; fi
  done
  if [ ! -f "$SOURCE/.tad/version.txt" ]; then echo "fixture: staged source missing version.txt" >&2; exit 2; fi
  # Phase 2: the Claude hooks template rides in the derived framework dir
  # .tad/templates; the claude-code projection fails without it.
  if [ ! -f "$SOURCE/.tad/templates/claude/settings.json" ]; then echo "fixture: staged source missing .tad/templates/claude/settings.json" >&2; exit 2; fi
}

source_version() { head -1 "$SOURCE/.tad/version.txt" | tr -d '[:space:]'; }

# ── installer invocation (ALWAYS --yes) ──────────────────────────────
# run_install <platform> <logfile> — rc echoed on stdout (only line).
run_install() {
  local plat="$1" log="$2"
  local rc=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform "$plat" --yes >"$log" 2>&1 ) || rc=$?
  printf '%s' "$rc"
}

# run_install_cc <platform> <logfile> [extra installer flags...] — like
# run_install, but pins TAD_BACKUP_ROOT inside the sandbox (outside TARGET) so a
# --force re-run can never write backups under $HOME, and passes extra flags
# (e.g. --force). Optional env: TAD_CLAUDE_SKILL_MODE is inherited as-is.
run_install_cc() {
  local plat="$1" log="$2"; shift 2
  local rc=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" TAD_BACKUP_ROOT="$SANDBOX/cc-backups" bash "$TADSH" --source "$SOURCE" --platform "$plat" --yes "$@" >"$log" 2>&1 ) || rc=$?
  printf '%s' "$rc"
}

assert_no_network() {
  if [ -s "$CURL_FUNC_LOG" ] || [ -s "$CURL_PATH_LOG" ]; then
    fail "$CURRENT_CASE: network shim tripped (curl invoked)"; return 1
  fi
  pass "$CURRENT_CASE: zero network (both curl-shim logs empty)"
}

assert_version_proof() {
  local want="$1"
  local got=""
  got="$(head -1 "$TARGET/.tad/version.txt" 2>/dev/null | tr -d '[:space:]')" || got=""
  if [ "$got" = "$want" ]; then
    pass "$CURRENT_CASE: positive-install proof (.tad/version.txt == $want)"
  else
    fail "$CURRENT_CASE: version proof (want=$want got=${got:-<missing>})"; return 1
  fi
}

snapshot_target() { # $1 = snapshot dest dir (under $SNAP)
  mkdir -p "$1"
  cp -R "$TARGET/." "$1/"
}

diff_snapshot() { # $1 = snapshot dir; prints diff, rc=0 when identical
  diff -r "$1" "$TARGET" 2>&1 || true
}

# sed-extract ONE top-level function from tad.sh into a harness file.
# Hardened (R2 P1-8): the extraction must end at the function's closing lone
# `}` (a future inner lone-`}` would otherwise truncate silently into a
# vacuous PASS) and must contain the expected body token when given.
extract_fn() { # $1=fn-name $2=outfile [$3=required body token]
  sed -n "/^$1() {/,/^}/p" "$TADSH" > "$2"
  if [ ! -s "$2" ]; then echo "fixture: cannot extract $1" >&2; exit 2; fi
  if [ "$(tail -n 1 "$2")" != "}" ]; then echo "fixture: $1 extraction truncated (tail is not })" >&2; exit 2; fi
  if [ -n "${3:-}" ] && ! grep -qF -e "$3" "$2"; then echo "fixture: $1 extraction missing token: $3" >&2; exit 2; fi
}

# extract_rollback_harness <outfile> — every tad.sh function the manifest-scoped
# rollback_on_failure path calls (f9f397bc): the two restore helpers and the
# tree comparison they verify with, the backup-root gate, and the prefix
# helpers behind both gates. A missing one must stop the fixture (exit 2),
# never degrade the probe into a vacuous PASS.
extract_rollback_harness() { # $1 = outfile
  local out="$1" fn part
  : > "$out"
  for fn in _tad_tree_equal restore_dir_entry restore_file_entry _literal_has_prefix assert_under_root assert_under_backup_root rollback_on_failure; do
    part="$out.$fn"
    case "$fn" in
      _tad_tree_equal) extract_fn "$fn" "$part" "cmp -s" ;;
      restore_dir_entry|restore_file_entry) extract_fn "$fn" "$part" "rollback-staging" ;;
      _literal_has_prefix) extract_fn "$fn" "$part" "lhp_esc" ;;
      assert_under_root) extract_fn "$fn" "$part" "TARGET_ROOT" ;;
      assert_under_backup_root) extract_fn "$fn" "$part" "manifest.txt" ;;
      rollback_on_failure) extract_fn "$fn" "$part" "Rollback coverage" ;;
    esac
    cat "$part" >> "$out"
  done
}

# make_probe_backup <backup_dir> <content> — a production-shaped backup as
# backup_existing writes it: <dir>/.tad/data.txt holding <content> and a
# manifest.txt (written last, version= trailer) that lists data.txt. <dir> must
# be under the caller's backup root and named YYYYMMDD_HHMMSS.
make_probe_backup() { # $1 = dir, $2 = data.txt content
  mkdir -p "$1/.tad"
  printf '%s\n' "$2" > "$1/.tad/data.txt"
  printf 'data.txt\nversion=3.1.0\n' > "$1/manifest.txt"
}

# ════════════════════════ AC2.1 (FR-1) ════════════════════════
case_ac21() {
  CURRENT_CASE="ac2.1"
  new_sandbox
  stage_pruned_source
  local want rc
  want="$(source_version)"
  # (a) offline full run → rc=0, zero network, version proof, source intact.
  mkdir -p "$SNAP/source-pre"
  cp -R "$SOURCE/." "$SNAP/source-pre/"
  rc="$(run_install codex "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.1: offline run rc=0"; else fail "ac2.1: offline run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  if diff -r "$SNAP/source-pre" "$SOURCE" >/dev/null 2>&1; then
    pass "ac2.1: source tree byte-identical after success run"
  else
    fail "ac2.1: source tree mutated by success run"
  fi
  # (b) --source == target (post-resolution) → usage error + zero mutations.
  snapshot_target "$SNAP/target-pre"
  local rc2=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$TARGET" --platform codex --yes >"$SANDBOX/reject.log" 2>&1 ) || rc2=$?
  if [ "$rc2" != "0" ]; then pass "ac2.1: --source==target rejected (rc=$rc2)"; else fail "ac2.1: --source==target NOT rejected"; fi
  if diff -r "$SNAP/target-pre" "$TARGET" >/dev/null 2>&1; then
    pass "ac2.1: zero mutations on --source==target rejection"
  else
    fail "ac2.1: rejection run mutated the target"
  fi
  # (c) failed-run source inertia: divergent opencode preflight fails AFTER
  # source validation but BEFORE any mutation → source still identical.
  # (--force: the target is already-current, which would otherwise short-
  # circuit before the preflight; force routes ACTION=upgrade into it.)
  mkdir -p "$TARGET/.opencode/commands"
  printf 'DIVERGENT-USER-CONTENT\n' > "$TARGET/.opencode/commands/tad-update.md"
  local rc3=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform codex --yes --force >"$SANDBOX/prefail.log" 2>&1 ) || rc3=$?
  if [ "$rc3" != "0" ]; then pass "ac2.1: preflight-failure run non-zero (rc=$rc3)"; else fail "ac2.1: preflight-failure run unexpectedly rc=0"; fi
  if diff -r "$SNAP/source-pre" "$SOURCE" >/dev/null 2>&1; then
    pass "ac2.1: source tree byte-identical after failed run"
  else
    fail "ac2.1: source tree mutated by failed run"
  fi
  assert_no_network
}

# ── shared user-file matrix (AC2.2/AC2.3/FR-5) ──
plant_user_matrix() {
  mkdir -p "$TARGET/.codex/prompts" "$TARGET/.gemini"
  printf 'USER-CODECX-CONFIG\n' > "$TARGET/.codex/config.toml"
  printf 'USER-PROMPT-BYTES\n' > "$TARGET/.codex/prompts/mine.md"
  printf 'USER-GEMINI-SETTINGS\n' > "$TARGET/.gemini/settings.json"
  printf 'USER-AGENTS-MD\n' > "$TARGET/AGENTS.md"
  printf 'USER-GEMINI-MD\n' > "$TARGET/GEMINI.md"
  printf '# User rules\nNo marker here\n' > "$TARGET/CLAUDE.md"
}

# matrix_assert <platform> — byte-identity where owned by the user; AGENTS.md
# follows the documented FR-4b backup-and-install semantics; user CLAUDE.md is
# NEVER written by the v3 installer (byte-identical, no backup).
# v3.0.0: only platform is codex (claude-code/both are tombstoned elsewhere).
matrix_assert() {
  local plat="$1" ok=0
  local f
  for f in .codex/config.toml .codex/prompts/mine.md .gemini/settings.json GEMINI.md CLAUDE.md; do
    if cmp -s "$SNAP/pre/$f" "$TARGET/$f"; then pass "ac2.x[$plat]: $f byte-identical"; else fail "ac2.x[$plat]: $f MODIFIED"; ok=1; fi
  done
  local bk
  bk="$(ls "$TARGET"/AGENTS.md.pre-tad.* 2>/dev/null | head -1)" || bk=""
  if [ -n "$bk" ] && cmp -s "$SNAP/pre/AGENTS.md" "$bk"; then
    pass "ac2.x[$plat]: AGENTS.md user bytes preserved in $(basename "$bk")"
  else
    fail "ac2.x[$plat]: AGENTS.md user bytes NOT preserved via .pre-tad backup"; ok=1
  fi
  return "$ok"
}

# ════════════════════════ AC2.2 ════════════════════════
case_ac22() {
  CURRENT_CASE="ac2.2"
  new_sandbox
  stage_pruned_source
  plant_user_matrix
  snapshot_target "$SNAP/pre"
  local want rc
  want="$(source_version)"
  rc="$(run_install codex "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.2: run rc=0"; else fail "ac2.2: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  matrix_assert codex || true
}

# ════════════════════════ AC2.3 (codex success + tombstone zero-mutation) ════════════════════════
case_ac23() {
  CURRENT_CASE="ac2.3"
  local plat
  # v3.0.0: codex is the only install target. claude-code/both must
  # fail-before-mutation (tombstone) with a recovery command.
  new_sandbox
  stage_pruned_source
  plant_user_matrix
  snapshot_target "$SNAP/pre"
  local want rc
  want="$(source_version)"
  rc="$(run_install codex "$SANDBOX/install-codex.log")"
  if [ "$rc" = "0" ]; then pass "ac2.3[codex]: run rc=0"; else fail "ac2.3[codex]: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  CURRENT_CASE="ac2.3"
  matrix_assert "codex" || true
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # Phase 2 (Epic multi-harness-restore): `claude-code` is an accepted target
  # again and installs the Claude projection; `both` stays a tombstone.
  new_sandbox
  stage_pruned_source
  plant_user_matrix
  snapshot_target "$SNAP/pre"
  rc="$(run_install_cc claude-code "$SANDBOX/install-claude-code.log")"
  if [ "$rc" = "0" ]; then pass "ac2.3[claude-code]: accepted (rc=0)"; else fail "ac2.3[claude-code]: rejected or failed (rc=$rc)"; fi
  assert_version_proof "$want"
  if [ -L "$TARGET/.claude/skills/alex" ] && [ "$(readlink "$TARGET/.claude/skills/alex")" = "../../.agents/skills/alex" ]; then
    pass "ac2.3[claude-code]: .claude/skills/alex is the relative link to the canonical skill"
  else
    fail "ac2.3[claude-code]: .claude/skills/alex link missing or wrong"
  fi
  if cmp -s "$SOURCE/.tad/templates/claude/settings.json" "$TARGET/.claude/settings.json"; then
    pass "ac2.3[claude-code]: .claude/settings.json is the hooks template"
  else
    fail "ac2.3[claude-code]: .claude/settings.json missing or differs from the template"
  fi
  local f
  for f in .codex/config.toml .codex/prompts/mine.md .gemini/settings.json GEMINI.md; do
    if cmp -s "$SNAP/pre/$f" "$TARGET/$f"; then pass "ac2.3[claude-code]: $f byte-identical"; else fail "ac2.3[claude-code]: $f MODIFIED"; fi
  done
  if [ "$(head -c "$(wc -c < "$SNAP/pre/CLAUDE.md" | tr -d ' ')" "$TARGET/CLAUDE.md")" = "$(cat "$SNAP/pre/CLAUDE.md")" ] \
     && grep -qxF '@AGENTS.md' "$TARGET/CLAUDE.md"; then
    pass "ac2.3[claude-code]: user CLAUDE.md bytes kept as prefix and @AGENTS.md block appended"
  else
    fail "ac2.3[claude-code]: CLAUDE.md prefix/block wrong"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  for plat in both; do
    CURRENT_CASE="ac2.3"
    new_sandbox
    stage_pruned_source
    plant_user_matrix
    snapshot_target "$SNAP/pre"
    rc="$(run_install "$plat" "$SANDBOX/install-$plat.log")"
    if [ "$rc" != "0" ]; then pass "ac2.3[$plat]: tombstone rejects (rc=$rc)"; else fail "ac2.3[$plat]: tombstone NOT rejected"; fi
    if grep -qF -e '--platform codex' "$SANDBOX/install-$plat.log" 2>/dev/null; then
      pass "ac2.3[$plat]: recovery command printed"
    else
      fail "ac2.3[$plat]: recovery command missing"
    fi
    local d_unexp
    d_unexp="$(diff -r "$SNAP/pre" "$TARGET" 2>&1 || true)"
    if [ -z "$d_unexp" ]; then
      pass "ac2.3[$plat]: zero mutation on tombstone reject"
    else
      fail "ac2.3[$plat]: target mutated on reject:"; printf '%s\n' "$d_unexp" | head -5
    fi
    guarded_cleanup "$SANDBOX"; SANDBOX=""
  done
}

# ════════════════════════ AC2.4 (v3: user CLAUDE.md byte-identical, never written) ════════════════════════
case_ac24() {
  CURRENT_CASE="ac2.4"
  new_sandbox
  stage_pruned_source
  printf '# My custom rules\nNo marker here\n' > "$TARGET/CLAUDE.md"
  cp "$TARGET/CLAUDE.md" "$SNAP/claude-orig.md"
  local want rc
  want="$(source_version)"
  rc="$(run_install codex "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.4: run rc=0"; else fail "ac2.4: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  if cmp -s "$SNAP/claude-orig.md" "$TARGET/CLAUDE.md"; then
    pass "ac2.4: user CLAUDE.md byte-identical (installer never writes it)"
  else
    fail "ac2.4: user CLAUDE.md MODIFIED"
  fi
  local bk
  bk="$(ls "$TARGET"/CLAUDE.md.backup.* 2>/dev/null | head -1)" || bk=""
  if [ -z "$bk" ]; then
    pass "ac2.4: no CLAUDE.md backup created (nothing to merge)"
  else
    fail "ac2.4: unexpected CLAUDE.md backup $(basename "$bk")"
  fi
}

# ════════════════════════ AC2.5 (guard) ════════════════════════
case_ac25() {
  CURRENT_CASE="ac2.5"
  local out rc=0
  out="$(bash "$GUARD" installer-destructive-guard "$REPO" 2>&1)" || rc=$?
  if [ "$rc" = "0" ]; then pass "ac2.5: installer-destructive-guard exit 0"; else fail "ac2.5: guard exit $rc"; printf '%s\n' "$out" | head -10; fi
  # Same-line binding: every marker id sits on its destructive line.
  local bad=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    case "$line" in *"# RM-OK:"*) : ;; *) bad=1; printf '  ❌ marker not same-line: %s\n' "$line" | head -c 160; printf '\n' ;; esac
  done <<< "$(grep -nE -e 'RM-OK:' "$REPO/tad.sh")"
  if [ "$bad" = "0" ]; then pass "ac2.5: all markers same-line bound"; else fail "ac2.5: off-line marker found"; fi
  # Uniqueness re-asserted here (guard's verdict is primary; this is the belt).
  local dupes
  dupes="$(grep -o -e 'RM-OK:[A-Za-z0-9][A-Za-z0-9_-]*' "$REPO/tad.sh" | LC_ALL=C sort | LC_ALL=C uniq -d)" || true
  if [ -z "$dupes" ]; then pass "ac2.5: marker ids unique"; else fail "ac2.5: duplicate ids: $dupes"; fi
  # Mutation probe: an unmarked rm in a sandbox copy MUST fail the guard.
  new_sandbox
  cp "$REPO/tad.sh" "$SANDBOX/tad.sh"
  printf '\nrm -rf "$HOME/.ssh"\n' >> "$SANDBOX/tad.sh"
  local mrc=0
  bash "$GUARD" installer-destructive-guard "$SANDBOX" >/dev/null 2>&1 || mrc=$?
  if [ "$mrc" != "0" ]; then pass "ac2.5: mutation probe fails guard on demand (rc=$mrc)"; else fail "ac2.5: mutation probe did NOT fail guard"; fi
  # Second mutation (R2 P1-6): a LIVE call wearing a baked-literal comment
  # must ALSO fail — exclusions cover comment-only lines, never live calls.
  cp "$REPO/tad.sh" "$SANDBOX/tad.sh"
  printf '\nrm -rf "$TARGET" # so the AC that forbids\n' >> "$SANDBOX/tad.sh"
  local mrc2=0
  bash "$GUARD" installer-destructive-guard "$SANDBOX" >/dev/null 2>&1 || mrc2=$?
  if [ "$mrc2" != "0" ]; then pass "ac2.5: exclusion-masked live call fails guard (rc=$mrc2)"; else fail "ac2.5: exclusion-masked live call did NOT fail guard"; fi
}

# ════════════════════════ AC2.6 (version floor, both directions) ════════════════════════
case_ac26() {
  CURRENT_CASE="ac2.6"
  # (a) current=2.2.0 → 2.3.0 entries inert (every deprecation version is
  # higher, so zero deletion attempts + planted TAD-owned files intact).
  #
  # Phase 5b (B1) — what changed and why. This half was written 2026-09-03
  # (f61c1892) with `run_install claude-code`, a platform that then generated
  # no hooks, so ".codex/hooks.json must be byte-identical" could hold. The
  # v3.0.0 commit (20223774) mechanically retargeted it to `codex`; but a
  # codex install regenerates .codex/hooks.json unconditionally (tad.sh
  # `if [ "$PLATFORM" = "codex" ]`, the .codex/hooks.json projection), so the
  # assertion could never hold again. The thing this case protects is "a
  # deprecation entry whose version is higher than the target's current
  # version deletes/rewrites nothing", and that is platform-independent, so
  # the run now uses `opencode`: the platform that, like the original
  # claude-code, never writes .codex/hooks.json. The three byte-identity
  # assertions (hooks.json + the two .tad/templates/*.template) are unchanged.
  # The codex-regenerates-hooks behaviour is covered by the installer's own
  # projection cases, not by this inertness check.
  new_sandbox
  stage_pruned_source
  local want rc
  want="$(source_version)"
  mkdir -p "$TARGET/.tad/templates" "$TARGET/.codex"
  printf '2.2.0\n' > "$TARGET/.tad/version.txt"
  printf 'STALE-HOOKS\n' > "$TARGET/.codex/hooks.json"
  printf 'STALE-AGENTS-TPL\n' > "$TARGET/.tad/templates/AGENTS.md.template"
  printf 'STALE-GEMINI-TPL\n' > "$TARGET/.tad/templates/GEMINI.md.template"
  snapshot_target "$SNAP/pre"
  rc="$(run_install opencode "$SANDBOX/install-220.log")"
  if [ "$rc" = "0" ]; then pass "ac2.6a: run rc=0"; else fail "ac2.6a: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  local f ok26a=0
  for f in .codex/hooks.json .tad/templates/AGENTS.md.template .tad/templates/GEMINI.md.template; do
    if cmp -s "$SNAP/pre/$f" "$TARGET/$f"; then :; else fail "ac2.6a: $f touched (must be inert)"; ok26a=1; fi
  done
  if [ "$ok26a" = "0" ]; then pass "ac2.6a: 2.3.0 entries inert (3 TAD-owned paths intact)"; fi
  if grep -qF -e 'Removed ' "$SANDBOX/install-220.log" 2>/dev/null; then
    fail "ac2.6a: deletion-attempt log lines present"
  else
    pass "ac2.6a: zero deletion-attempt log lines"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # (b) current=2.3.1 → only the 3 listed TAD-owned paths touched; user files
  # byte-identical. (Target version read from source version.txt at run time.)
  CURRENT_CASE="ac2.6"
  new_sandbox
  stage_pruned_source
  want="$(source_version)"
  mkdir -p "$TARGET/.tad/templates" "$TARGET/.codex"
  printf '2.3.1\n' > "$TARGET/.tad/version.txt"
  printf 'STALE-HOOKS\n' > "$TARGET/.codex/hooks.json"
  printf 'STALE-AGENTS-TPL\n' > "$TARGET/.tad/templates/AGENTS.md.template"
  printf 'STALE-GEMINI-TPL\n' > "$TARGET/.tad/templates/GEMINI.md.template"
  printf 'USER-AGENTS\n' > "$TARGET/AGENTS.md"
  printf 'USER-GEMINI\n' > "$TARGET/GEMINI.md"
  printf 'USER-CONFIG\n' > "$TARGET/.codex/config.toml"
  snapshot_target "$SNAP/pre"
  rc="$(run_install codex "$SANDBOX/install-231.log")"
  if [ "$rc" = "0" ]; then pass "ac2.6b: run rc=0"; else fail "ac2.6b: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  # Phase 5b (B2) — what changed and why. This half protects "a user's own
  # files survive an upgrade install". It was written when the root AGENTS.md
  # was not a TAD-installed file for the platform under test (f61c1892 ran it
  # with `claude-code`, which then listed no root files; 20223774 retargeted it
  # to `codex`, which installs AGENTS.md). The installer's contract for a root
  # file it installs has been "back up the user's copy to <name>.pre-tad.<ts>,
  # then overwrite" since 46af019c (2026-08-17, FR-4b), so "AGENTS.md
  # byte-identical in place" cannot be true under codex. The data-safety
  # guarantee the case exists for is unchanged and is asserted directly: the
  # user's original AGENTS.md bytes must still exist, byte-identical, in a
  # .pre-tad.* backup next to it (no user byte lost). GEMINI.md and
  # .codex/config.toml are not installed root files under this platform and
  # keep the original in-place byte-identity assertion.
  local ok26b=0 pre_tad_bk="" pre_tad_hit=0 pre_tad_f
  for f in GEMINI.md .codex/config.toml; do
    if cmp -s "$SNAP/pre/$f" "$TARGET/$f"; then :; else fail "ac2.6b: user file $f touched"; ok26b=1; fi
  done
  if [ "$ok26b" = "0" ]; then pass "ac2.6b: GEMINI.md and .codex/config.toml untouched"; fi
  for pre_tad_f in "$TARGET"/AGENTS.md.pre-tad.*; do
    [ -f "$pre_tad_f" ] || continue
    if cmp -s "$SNAP/pre/AGENTS.md" "$pre_tad_f"; then pre_tad_hit=1; pre_tad_bk="$pre_tad_f"; break; fi
  done
  if [ "$pre_tad_hit" = "1" ]; then
    pass "ac2.6b: user AGENTS.md preserved byte-identical in $(basename "$pre_tad_bk")"
  else
    fail "ac2.6b: no AGENTS.md.pre-tad.* backup holds the user's original AGENTS.md bytes"
  fi
  if [ ! -e "$TARGET/.tad/templates/AGENTS.md.template" ] && [ ! -e "$TARGET/.tad/templates/GEMINI.md.template" ]; then
    pass "ac2.6b: stale TAD-owned templates removed"
  else
    fail "ac2.6b: stale templates still present"
  fi
}

# ════════════════════════ AC2.7 (F-34 Check-3 direction) ════════════════════════
case_ac27() {
  CURRENT_CASE="ac2.7"
  new_sandbox
  # (a) user .codex/ + AGENTS.md present → Check 3 (deprecated files) PASS.
  # The REAL verifier runs UNMODIFIED here (AC2.7 tests must not grade own
  # edits — upgrade-acceptance.sh is untouched).
  mkdir -p "$TARGET/.tad" "$TARGET/.codex/prompts"
  printf '2.43.1\n' > "$TARGET/.tad/version.txt"
  printf 'USER-AGENTS-MD\n' > "$TARGET/AGENTS.md"
  printf 'USER-CONFIG\n' > "$TARGET/.codex/config.toml"
  printf 'USER-PROMPT\n' > "$TARGET/.codex/prompts/mine.md"
  local rc=0
  bash "$VERIFIER" --target "$TARGET" --expected-version 2.43.1 >"$SANDBOX/check3.log" 2>&1 || rc=$?
  if [ "$rc" = "0" ]; then pass "ac2.7: user .codex/+AGENTS.md → Check 3 PASS"; else fail "ac2.7: Check 3 rc=$rc (user files must not flag)"; fi
  if grep -qF -e 'AGENTS.md' "$SANDBOX/check3.log"; then
    fail "ac2.7: AGENTS.md named in Check-3 output (direction leak)"
  else
    pass "ac2.7: AGENTS.md never named by Check 3"
  fi
  # Negative control (vacuity guard): a genuinely stale deprecated file MUST
  # still FAIL — proves the PASS above is not a dead check.
  mkdir -p "$TARGET/.claude/commands"
  printf 'STALE\n' > "$TARGET/.claude/commands/tad-alex.md"
  local rc2=0
  bash "$VERIFIER" --target "$TARGET" --expected-version 2.43.1 >"$SANDBOX/check3-neg.log" 2>&1 || rc2=$?
  rm -f "$TARGET/.claude/commands/tad-alex.md"
  if [ "$rc2" != "0" ] && grep -qF -e 'tad-alex.md' "$SANDBOX/check3-neg.log"; then
    pass "ac2.7: negative control FAILs on truly-stale file (check is live)"
  else
    fail "ac2.7: negative control did not catch a stale file (vacuous check?)"
  fi
  # (b) adversarial YAML battery: the parser (same awk, sandbox-rewired copy
  # of the verifier — the fenced file is never edited) never flags user files
  # under reordered sections, removed_from_this_list-first, extra versions.
  local y
  for y in deprecation-adversarial-reordered.yaml deprecation-adversarial-extraversions.yaml; do
    if [ ! -f "$FIXTURES/$y" ]; then fail "ac2.7: fixture $y missing"; continue; fi
    sed -e "s|^DEPRECATION_YAML=.*|DEPRECATION_YAML=\"$FIXTURES/$y\"|" "$VERIFIER" > "$SANDBOX/verifier-adv.sh"
    local rc3=0
    bash "$SANDBOX/verifier-adv.sh" --target "$TARGET" --expected-version 2.43.1 >"$SANDBOX/check3-adv.log" 2>&1 || rc3=$?
    if [ "$rc3" = "0" ]; then pass "ac2.7: adversarial $y green (user files never flag)"; else fail "ac2.7: adversarial $y rc=$rc3"; fi
  done
}

# ════════════════════════ AC2.8 (F-06 rollback) ════════════════════════
case_ac28() {
  CURRENT_CASE="ac2.8"
  new_sandbox
  stage_pruned_source
  # Upgrade-shaped target (current=3.1.0, so the installer takes the plain
  # upgrade path and the failure lands purely on the cp fault → rollback
  # coverage is isolated).
  #
  # Phase 5b (B4) — what changed and why. The premise used to be current=2.2.0
  # ("every deprecation inert"). Since the v3 major bump a 2.x target routes to
  # the `migrate` state, which first copies .tad to .tad-migrate-backup.<ts>;
  # rollback_on_failure deliberately keeps that copy ("preserved-for-manual-
  # recovery", step 4d) and lists it in the coverage message, so the
  # whole-tree diff below correctly reported it as new. The discriminator
  # (find of .tad/{active,archive,evidence,pair-testing,reports} after the
  # faulted run, taken before sandbox cleanup) returned NO files and no
  # directories: the migrate skeleton dirs are swept by rollback, and the
  # migrate backup was the only drift. So this was a stale premise/filter, not
  # an installer sweep defect. The case now uses an upgrade-shaped 3.1.0 target
  # (what the case was written to cover: an in-place upgrade whose copy phase
  # fails). Rework R2/R3: the migrate-path variant now lives in its own
  # sub-case below, and only that sub-case tolerates .tad-migrate-backup.*.
  mkdir -p "$TARGET/.tad" "$TARGET/.tad/project-knowledge" "$TARGET/.claude/skills/custom" "$TARGET/.codex" "$TARGET/.codex/prompts" "$TARGET/.claude/commands"
  printf '3.1.0\n' > "$TARGET/.tad/version.txt"
  printf '# Project\n<!-- TAD:PROJECT-CONTENT-BELOW -->\nMY-PROJECT-BYTES\n' > "$TARGET/CLAUDE.md"
  printf 'CUSTOM-SKILL-BYTES\n' > "$TARGET/.claude/skills/custom/skill.md"
  printf 'USER-HOOKS\n' > "$TARGET/.codex/hooks.json"
  # R2 P0-1/P0-2 siblings: NEVER snapshotted as wholes, must survive rollback.
  # config.toml + prompts (P0-1: wholesale .codex restore wiped them),
  # user commands file (P0-1: wholesale .claude restore wiped it),
  # project-knowledge README (P0-2: $SNAP/.tad wholesale restore clobbered .tad/).
  printf 'USER-CONFIG-TOML\n' > "$TARGET/.codex/config.toml"
  printf 'USER-PROMPT\n' > "$TARGET/.codex/prompts/mine.md"
  printf 'USER-COMMAND\n' > "$TARGET/.claude/commands/my-cmd.md"
  printf 'KNOWLEDGE-README\n' > "$TARGET/.tad/project-knowledge/README.md"
  snapshot_target "$SNAP/pre"
  # One-shot cp fault: fail the FIRST cp whose args name the staged source
  # AND a .agents/skills path (the first framework-skills copy —
  # deterministically past NEED_ROLLBACK=1; the `.tad/skills-config`
  # top file and snapshot copies are excluded by the dotted predicate), then
  # pass again so rollback's own copies succeed.
  printf '0\n' > "$SANDBOX/failcp"
  printf '#!/bin/sh\nprintf "%%s\\n" "CP-CALL $*" >> "%s/cp.log"\ncase "$*" in\n  *"%s"*) case "$*" in\n    *.agents/skills*) n=$(cat "%s/failcp"); if [ "$n" = "0" ]; then echo 1 > "%s/failcp"; exit 1; fi ;;\n  esac ;;\nesac\nexec /bin/cp "$@"\n' \
    "$SANDBOX" "$SOURCE" "$SANDBOX" "$SANDBOX" > "$SHIMBIN/cp"
  chmod +x "$SHIMBIN/cp"
  local rc=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform codex --yes >"$SANDBOX/install-fail.log" 2>&1 ) || rc=$?
  if [ "$rc" != "0" ]; then pass "ac2.8: faulted run non-zero (rc=$rc)"; else fail "ac2.8: faulted run unexpectedly rc=0"; fi
  # Coverage: every user surface byte-identical after rollback (allowlist: the
  # run log itself lives outside the target; .tad-backup recovery copies are
  # documented below if present).
  local d
  d="$(diff -r "$SNAP/pre" "$TARGET" 2>&1)" || true
  # Filter the known-benign recovery-copy dir (engine backup namespace). The
  # migrate-backup namespace is NOT filtered here: on this plain-upgrade premise
  # a stray .tad-migrate-backup.* would be a real finding (the migrate path is
  # covered by the sub-case below).
  local d_unexp
  d_unexp="$(printf '%s\n' "$d" | grep -v -e '.tad-backup' || true)"
  if [ -z "$d_unexp" ]; then
    pass "ac2.8: all post-NEED_ROLLBACK surfaces byte-identical after rollback"
  else
    fail "ac2.8: post-rollback drift:"; printf '%s\n' "$d_unexp" | head -10
  fi
  if grep -qF -e 'Rollback coverage' "$SANDBOX/install-fail.log"; then
    pass "ac2.8: message enumerates rollback coverage"
  else
    fail "ac2.8: coverage-enumerating message missing"
  fi
  assert_no_network
  guarded_cleanup "$SANDBOX"; SANDBOX=""

  # (a2) Phase 5b rework R3: the migrate-path variant of (a). A 2.2.0 target
  # routes to the `migrate` state; after the same one-shot cp fault, rollback
  # must leave every user surface byte-identical, and the ONLY extra entry is
  # exactly one .tad-migrate-backup.<ts> directory (kept on purpose, step 4d of
  # rollback_on_failure, and listed in the coverage message).
  CURRENT_CASE="ac2.8"
  new_sandbox
  stage_pruned_source
  mkdir -p "$TARGET/.tad" "$TARGET/.tad/project-knowledge" "$TARGET/.claude/skills/custom" "$TARGET/.codex" "$TARGET/.codex/prompts" "$TARGET/.claude/commands"
  printf '2.2.0\n' > "$TARGET/.tad/version.txt"
  printf '# Project\n<!-- TAD:PROJECT-CONTENT-BELOW -->\nMY-PROJECT-BYTES\n' > "$TARGET/CLAUDE.md"
  printf 'CUSTOM-SKILL-BYTES\n' > "$TARGET/.claude/skills/custom/skill.md"
  printf 'USER-HOOKS\n' > "$TARGET/.codex/hooks.json"
  printf 'USER-CONFIG-TOML\n' > "$TARGET/.codex/config.toml"
  printf 'USER-PROMPT\n' > "$TARGET/.codex/prompts/mine.md"
  printf 'USER-COMMAND\n' > "$TARGET/.claude/commands/my-cmd.md"
  printf 'KNOWLEDGE-README\n' > "$TARGET/.tad/project-knowledge/README.md"
  snapshot_target "$SNAP/pre"
  printf '0\n' > "$SANDBOX/failcp"
  printf '#!/bin/sh\nprintf "%%s\\n" "CP-CALL $*" >> "%s/cp.log"\ncase "$*" in\n  *"%s"*) case "$*" in\n    *.agents/skills*) n=$(cat "%s/failcp"); if [ "$n" = "0" ]; then echo 1 > "%s/failcp"; exit 1; fi ;;\n  esac ;;\nesac\nexec /bin/cp "$@"\n' \
    "$SANDBOX" "$SOURCE" "$SANDBOX" "$SANDBOX" > "$SHIMBIN/cp"
  chmod +x "$SHIMBIN/cp"
  rc=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform codex --yes >"$SANDBOX/install-fail-mig.log" 2>&1 ) || rc=$?
  if [ "$rc" != "0" ]; then pass "ac2.8: migrate-path faulted run non-zero (rc=$rc)"; else fail "ac2.8: migrate-path faulted run unexpectedly rc=0"; fi
  d="$(diff -r "$SNAP/pre" "$TARGET" 2>&1)" || true
  d_unexp="$(printf '%s\n' "$d" | grep -v -e '.tad-backup' | grep -v -E '^Only in [^:]*: \.tad-migrate-backup\.[0-9]{8}_[0-9]{6}(\.[0-9]+)?$' || true)"
  if [ -z "$(printf '%s' "$d_unexp" | tr -d '[:space:]')" ]; then
    pass "ac2.8: migrate path: user surfaces byte-identical after rollback"
  else
    fail "ac2.8: migrate path: unexpected drift:"; printf '%s\n' "$d_unexp" | head -10
  fi
  local mig_n
  mig_n="$(find "$TARGET" -maxdepth 1 -name '.tad-migrate-backup.*' -type d | wc -l | tr -d ' ')"
  if [ "$mig_n" = "1" ]; then
    pass "ac2.8: migrate path: exactly one .tad-migrate-backup.<ts> kept"
  else
    fail "ac2.8: migrate path: expected exactly 1 .tad-migrate-backup.*, found $mig_n"
  fi
  if grep -qF -e 'Rollback coverage' "$SANDBOX/install-fail-mig.log"; then
    pass "ac2.8: migrate path: coverage message present"
  else
    fail "ac2.8: migrate path: coverage message missing"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""

  # (b) sed-extracted rollback_on_failure under a FOREIGN cwd with absolute
  # BACKUP_PATH → target restored, foreign cwd untouched (absolutization).
  #
  # Phase 5b (B3) — what changed and why. The original probe built a sibling
  # `$TARGET/.tad.backup.PROBE` whose CONTENT was the .tad content. Since
  # f9f397bc (2026-10-06, "manifest-scoped rollback") rollback_on_failure only
  # accepts a backup that assert_under_backup_root approves: strictly under
  # $TAD_BACKUP_ROOT_ABS, named YYYYMMDD_HHMMSS, holding manifest.txt; it then
  # restores only the entries listed in that manifest, from <backup>/.tad/.
  # The old probe could never pass that gate, so the case failed for a reason
  # unrelated to what it protects. The protected property is unchanged: with
  # a valid backup and an absolute BACKUP_PATH_ABS, rollback run from an
  # unrelated cwd restores the target through absolute paths and creates
  # nothing in that cwd. The probe now builds a production-shaped backup under
  # a sandbox backup root and the harness extracts every function the current
  # rollback path calls. A second probe (added with this rewrite) feeds the
  # old-style in-project backup and requires the new gate to refuse it.
  CURRENT_CASE="ac2.8"
  new_sandbox
  extract_rollback_harness "$SANDBOX/rb.fn.sh"
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/rb.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/rb.log"; }\nlog_warn() { printf "WARN: %%s\\n" "$*" >> "%s/rb.log"; }\nrollback_opencode_projection() { printf "OPCODE-ROLLBACK-CALLED\\n" >> "%s/rb.log"; }\ncleanup_source_tree() { printf "CLEANUP-SOURCE-CALLED\\n" >> "%s/rb.log"; }\n' \
    "$SANDBOX" "$SANDBOX" "$SANDBOX" "$SANDBOX" "$SANDBOX" > "$SANDBOX/stubs.sh"
  mkdir -p "$TARGET/.tad" "$SANDBOX/foreign"
  local rb_bk="$SANDBOX/bk-root/20260101_000000"
  make_probe_backup "$rb_bk" "ORIGINAL-TAD"
  printf 'HALF-INSTALLED\n' > "$TARGET/.tad/data.txt"
  printf 'FOREIGN-TAD\n' > "$SANDBOX/foreign/marker.txt"
  local rc4=0
  ( cd "$SANDBOX/foreign" && TARGET_ROOT="$TARGET" TAD_BACKUP_ROOT_ABS="$SANDBOX/bk-root" BACKUP_PATH_ABS="$rb_bk" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs.sh"; source "'"$SANDBOX"'/rb.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb.log" 2>&1 ) || rc4=$?
  if [ "$(cat "$TARGET/.tad/data.txt" 2>/dev/null)" = "ORIGINAL-TAD" ]; then
    pass "ac2.8: foreign-cwd rollback restored target via absolute paths"
  else
    fail "ac2.8: foreign-cwd rollback did NOT restore target"
  fi
  if [ -f "$SANDBOX/foreign/marker.txt" ] && [ ! -e "$SANDBOX/foreign/.tad" ]; then
    pass "ac2.8: foreign cwd untouched (no .tad created)"
  else
    fail "ac2.8: foreign cwd polluted"
  fi
  # Negative control for the new gate: an old-style backup planted INSIDE the
  # project (no manifest, outside the backup root) must be refused, the target
  # left exactly as the failed run left it, and the planted dir preserved.
  rm -f "$SANDBOX/rb.log"
  printf 'HALF-INSTALLED\n' > "$TARGET/.tad/data.txt"
  mkdir -p "$TARGET/.tad.backup.PROBE"
  printf 'FORGED-TAD\n' > "$TARGET/.tad.backup.PROBE/data.txt"
  ( cd "$SANDBOX/foreign" && TARGET_ROOT="$TARGET" TAD_BACKUP_ROOT_ABS="$SANDBOX/bk-root" BACKUP_PATH_ABS="$TARGET/.tad.backup.PROBE" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs.sh"; source "'"$SANDBOX"'/rb.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb.log" 2>&1 ) || true
  if [ "$(cat "$TARGET/.tad/data.txt" 2>/dev/null)" = "HALF-INSTALLED" ] \
     && [ -d "$TARGET/.tad.backup.PROBE" ] && grep -qF -e 'REFUSED' "$SANDBOX/rb.log"; then
    pass "ac2.8: in-project forged backup refused (target untouched, backup preserved, REFUSED named)"
  else
    fail "ac2.8: in-project forged backup was NOT refused"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""

  # (c) ENOSPC injection: restore under `ulimit -f` → backup preserved +
  # explicit failed-state message (calibrated to the host; fallback fault-shim
  # proves the same branch and is logged as such, never silent).
  # Phase 5b (B3, same cause as (b)): the backup used to be a sibling
  # `.tad.backup.BIG` that the manifest-scoped gate (f9f397bc) now refuses
  # outright, which made both assertions below pass vacuously (a REFUSED
  # message also contains "PRESERVED" and nothing was removed). The backup is
  # now production-shaped (under a sandbox backup root, timestamp name,
  # manifest listing big.bin) so the restore really starts and really fails on
  # the size limit; the failed-state message asserted is the restore failure
  # one ("Rollback FAILED for .tad/big.bin"), not the refusal.
  CURRENT_CASE="ac2.8"
  new_sandbox
  extract_rollback_harness "$SANDBOX/rollback.fn.sh"
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/rb2.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/rb2.log"; }\nlog_warn() { printf "WARN: %%s\\n" "$*" >> "%s/rb2.log"; }\nrollback_opencode_projection() { :; }\ncleanup_source_tree() { :; }\n' \
    "$SANDBOX" "$SANDBOX" "$SANDBOX" > "$SANDBOX/stubs2.sh"
  local big_bk="$SANDBOX/bk-root/20260101_000000"
  mkdir -p "$TARGET/.tad" "$big_bk/.tad"
  head -c 200000 /dev/zero | tr '\0' 'B' > "$big_bk/.tad/big.bin"
  printf 'big.bin\nversion=3.1.0\n' > "$big_bk/manifest.txt"
  printf 'HALF\n' > "$TARGET/.tad/data.txt"
  local mech="ulimit"
  if ! ( ulimit -f 20; cp "$big_bk/.tad/big.bin" "$SANDBOX/probe.bin" 2>/dev/null ); then
    mech="ulimit"
  else
    mech="fault-shim"
  fi
  rm -f "$SANDBOX/probe.bin"
  if [ "$mech" = "ulimit" ]; then
    ( cd "$TARGET" && ulimit -f 20; TARGET_ROOT="$TARGET" TAD_BACKUP_ROOT_ABS="$SANDBOX/bk-root" BACKUP_PATH_ABS="$big_bk" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs2.sh"; source "'"$SANDBOX"'/rollback.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb2.log" 2>&1 ) || true
  else
    printf '#!/bin/sh\nexit 1\n' > "$SHIMBIN/cp"
    chmod +x "$SHIMBIN/cp"
    ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" TARGET_ROOT="$TARGET" TAD_BACKUP_ROOT_ABS="$SANDBOX/bk-root" BACKUP_PATH_ABS="$big_bk" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs2.sh"; source "'"$SANDBOX"'/rollback.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb2.log" 2>&1 ) || true
  fi
  if [ -f "$big_bk/.tad/big.bin" ] && [ -f "$big_bk/manifest.txt" ]; then
    pass "ac2.8: ENOSPC ($mech) → backup preserved"
  else
    fail "ac2.8: ENOSPC ($mech) → backup GONE"
  fi
  if grep -qF -e 'Rollback FAILED for .tad/big.bin' "$SANDBOX/rb2.log" && grep -qF -e 'PRESERVED' "$SANDBOX/rb2.log"; then
    pass "ac2.8: ENOSPC ($mech) → explicit failed-state message"
  else
    fail "ac2.8: ENOSPC ($mech) → failed-state message missing"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""

  # (d) File-restore atomicity (R2 P0-3): in-place cp-over loses dst on a
  # mid-copy failure; staged restore leaves dst intact. Snap layout works on
  # BOTH code generations (top-level file for the old glob loop, .manifest
  # for the new manifest loop). Fault-cp truncates-then-fails every call.
  CURRENT_CASE="ac2.8"
  new_sandbox
  extract_fn restore_dir_entry "$SANDBOX/rb.fn.sh" "rollback-staging"
  extract_fn rollback_on_failure "$SANDBOX/rb2.fn.sh" "Rollback coverage"
  cat "$SANDBOX/rb2.fn.sh" >> "$SANDBOX/rb.fn.sh"
  # New-generation helpers (absent pre-fix): extract strictly when present so
  # a half-extracted harness can never produce a vacuous GREEN.
  if grep -q -e '^restore_file_entry() {' "$TADSH"; then
    extract_fn restore_file_entry "$SANDBOX/rb3.fn.sh" "rollback-staging"
    cat "$SANDBOX/rb3.fn.sh" >> "$SANDBOX/rb.fn.sh"
  fi
  if grep -q -e '^_literal_has_prefix() {' "$TADSH"; then
    extract_fn _literal_has_prefix "$SANDBOX/helpers.fn.sh" "lhp_esc"
    extract_fn assert_under_root "$SANDBOX/helpers2.fn.sh" "TARGET_ROOT"
    cat "$SANDBOX/helpers.fn.sh" "$SANDBOX/helpers2.fn.sh" >> "$SANDBOX/rb.fn.sh"
  fi
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/rb3.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/rb3.log"; }\nrollback_opencode_projection() { :; }\ncleanup_source_tree() { :; }\n' \
    "$SANDBOX" "$SANDBOX" > "$SANDBOX/stubs3.sh"
  printf '#!/bin/sh\nfor _a in "$@"; do _last="$_a"; done\n: > "$_last"\nexit 1\n' > "$SHIMBIN/cp"
  chmod +x "$SHIMBIN/cp"
  mkdir -p "$SANDBOX/rsnap"
  printf 'VICTIM-ORIG\n' > "$TARGET/victim.txt"
  printf 'VICTIM-ORIG\n' > "$SANDBOX/rsnap/victim.txt"
  printf 'victim.txt\n' > "$SANDBOX/rsnap/.manifest"
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" TARGET_ROOT="$TARGET" BACKUP_PATH_ABS="" ROLLBACK_SNAP="$SANDBOX/rsnap" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" ROLLBACK_PRE_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs3.sh"; source "'"$SANDBOX"'/rb.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb3.log" 2>&1 ) || true
  if [ "$(cat "$TARGET/victim.txt" 2>/dev/null)" = "VICTIM-ORIG" ]; then
    pass "ac2.8: truncating-cp fault → file dst preserved (atomic restore)"
  else
    fail "ac2.8: truncating-cp fault → file dst LOST (in-place cp-over)"
  fi
}

# ════════════════════════ AC2.9 (F-05 user .bak) ════════════════════════
case_ac29() {
  CURRENT_CASE="ac2.9"
  new_sandbox
  stage_pruned_source
  printf 'USER-BAK-ORIGINAL-BYTES\n' > "$TARGET/CLAUDE.md.bak"
  cp "$TARGET/CLAUDE.md.bak" "$SNAP/user-bak.orig"
  printf '# Mine\nNo marker\n' > "$TARGET/CLAUDE.md"
  cp "$TARGET/CLAUDE.md" "$SNAP/claude-orig.md"
  local want rc
  want="$(source_version)"
  rc="$(run_install codex "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.9: run rc=0"; else fail "ac2.9: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  if cmp -s "$SNAP/user-bak.orig" "$TARGET/CLAUDE.md.bak"; then
    pass "ac2.9: pre-existing user CLAUDE.md.bak byte-identical"
  else
    fail "ac2.9: user CLAUDE.md.bak clobbered"
  fi
  if cmp -s "$SNAP/claude-orig.md" "$TARGET/CLAUDE.md"; then
    pass "ac2.9: user CLAUDE.md byte-identical (v3 never merges)"
  else
    fail "ac2.9: user CLAUDE.md MODIFIED"
  fi
}

# ════════════════════════ AC2.10 (F-07 temp extract + tar-slip) ════════════════════════
case_ac210() {
  CURRENT_CASE="ac2.10"
  new_sandbox
  stage_pruned_source
  # User TAD-main/ must survive (the pre-fix cwd-extract merged into it).
  mkdir -p "$TARGET/TAD-main"
  printf 'PRECIOUS-USER-BYTES\n' > "$TARGET/TAD-main/precious.txt"
  printf 'ROOT-SENTINEL\n' > "$TARGET/.root-sentinel"
  # Parent sentinel OUTSIDE the target (R2 P1-7): mktemp-unique (no fixed
  # /tmp name → no parallel race) + guarded cleanup (never bare rm).
  local _parent_sent
  _parent_sent="$(mktemp /tmp/tad-ac-parent.XXXXXX)" || { fail "ac2.10: parent sentinel mktemp failed"; return; }
  printf 'PARENT-SENTINEL\n' > "$_parent_sent"
  cp "$TARGET/TAD-main/precious.txt" "$SNAP/precious.orig"
  local want rc
  want="$(source_version)"
  rc="$(run_install codex "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.10: run rc=0"; else fail "ac2.10: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  if cmp -s "$SNAP/precious.orig" "$TARGET/TAD-main/precious.txt"; then
    pass "ac2.10: user TAD-main/ identical"
  else
    fail "ac2.10: user TAD-main/ clobbered"
  fi
  if [ "$(cat "$TARGET/.root-sentinel")" = "ROOT-SENTINEL" ] && [ "$(cat "$_parent_sent")" = "PARENT-SENTINEL" ]; then
    pass "ac2.10: root+parent sentinels identical (zero outside writes)"
  else
    fail "ac2.10: sentinel drift (outside write)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  guarded_cleanup "$_parent_sent" || { fail "ac2.10: parent sentinel cleanup failed"; return; }
  # Malicious-tar unit probe against the REAL validate_tar_members
  # (sed-extracted; tad.sh executes on source so it cannot be sourced).
  CURRENT_CASE="ac2.10"
  new_sandbox
  extract_fn validate_tar_members "$SANDBOX/validate.fn.sh" "link to"
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/v.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/v.log"; }\n' \
    "$SANDBOX" "$SANDBOX" > "$SANDBOX/vstubs.sh"
  mkdir -p "$SANDBOX/payload/evil" "$SANDBOX/outside"
  printf 'OUTSIDE-BYTES\n' > "$SANDBOX/outside/keeper.txt"
  printf 'evil\n' > "$SANDBOX/payload/evil.txt"
  ( cd "$SANDBOX/payload" && tar -czf "$SANDBOX/evil.tar.gz" evil.txt 2>/dev/null ) || true
  # Craft absolute members (BSD/GNU tar -P preserves the absolute path arg).
  ( cd "$SANDBOX" && tar -czPf "$SANDBOX/evil-abs.tar.gz" "$SANDBOX/payload/evil.txt" 2>/dev/null ) || true
  printf 'x\n' > "$SANDBOX/payload2.txt"
  local vrc=0
  bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/evil.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc=$?
  if [ "$vrc" = "0" ]; then pass "ac2.10: benign tar passes member validation"; else fail "ac2.10: benign tar rejected (rc=$vrc)"; fi
  # Absolute-member tar must be rejected pre-extraction (skip if this tar
  # cannot emit absolute members — logged, never silent).
  if tar -tzf "$SANDBOX/evil-abs.tar.gz" 2>/dev/null | grep -q -e '^/'; then
    local vrc2=0
    bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/evil-abs.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc2=$?
    if [ "$vrc2" != "0" ]; then pass "ac2.10: absolute-member tar rejected pre-extraction"; else fail "ac2.10: absolute-member tar NOT rejected"; fi
  else
    pass "ac2.10: absolute-member crafting unsupported here (documented skip)"
  fi
  # Dot-dot member: hand-built via python3 (baseline tool) for determinism.
  python3 - "$SANDBOX/evil-dd.tar.gz" <<'PYEOF' 2>/dev/null || true
import tarfile, sys
with tarfile.open(sys.argv[1], "w:gz") as t:
    ti = tarfile.TarInfo("../escape.txt")
    ti.size = 5
    import io
    t.addfile(ti, io.BytesIO(b"evil\n"))
PYEOF
  if [ -f "$SANDBOX/evil-dd.tar.gz" ]; then
    local vrc3=0
    bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/evil-dd.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc3=$?
    if [ "$vrc3" != "0" ]; then pass "ac2.10: dot-dot-member tar rejected pre-extraction"; else fail "ac2.10: dot-dot-member tar NOT rejected"; fi
  else
    fail "ac2.10: could not craft dot-dot tar"
  fi
  # N5: symlink/hardlink members — `->` target predicate. Escaping targets
  # (absolute + dot-dot) must reject; benign in-tree relative links must pass
  # (the predicate is escaping-only, not link-phobic).
  python3 - "$SANDBOX" <<'PYEOF' 2>/dev/null || true
import tarfile, sys, io
base = sys.argv[1]
with tarfile.open(base + "/evil-abslink.tar.gz", "w:gz") as t:
    ti = tarfile.TarInfo("evil-abs")
    ti.type = tarfile.SYMTYPE
    ti.linkname = "/etc/passwd"
    t.addfile(ti)
with tarfile.open(base + "/evil-rellink.tar.gz", "w:gz") as t:
    ti = tarfile.TarInfo("evil-rel")
    ti.type = tarfile.SYMTYPE
    ti.linkname = "../outside/keeper.txt"
    t.addfile(ti)
with tarfile.open(base + "/ok-link.tar.gz", "w:gz") as t:
    ti = tarfile.TarInfo("ok.txt")
    ti.size = 3
    t.addfile(ti, io.BytesIO(b"ok\n"))
    li = tarfile.TarInfo("ok-link")
    li.type = tarfile.SYMTYPE
    li.linkname = "ok.txt"
    t.addfile(li)
with tarfile.open(base + "/evil-hardlink.tar.gz", "w:gz") as t:
    ti = tarfile.TarInfo("victim.txt")
    ti.size = 2
    t.addfile(ti, io.BytesIO(b"v\n"))
    hi = tarfile.TarInfo("evil-hard")
    hi.type = tarfile.LNKTYPE
    hi.linkname = "/etc/passwd"
    t.addfile(hi)
with tarfile.open(base + "/ok-hardlink.tar.gz", "w:gz") as t:
    ti = tarfile.TarInfo("base.txt")
    ti.size = 2
    t.addfile(ti, io.BytesIO(b"b\n"))
    hi = tarfile.TarInfo("ok-hard")
    hi.type = tarfile.LNKTYPE
    hi.linkname = "base.txt"
    t.addfile(hi)
PYEOF
  local vrc4=0 vrc5=0 vrc6=0 vrc7=0 vrc8=0
  bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/evil-abslink.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc4=$?
  bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/evil-rellink.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc5=$?
  bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/ok-link.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc6=$?
  bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/evil-hardlink.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc7=$?
  bash -c 'source "'"$SANDBOX"'/vstubs.sh"; source "'"$SANDBOX"'/validate.fn.sh"; validate_tar_members "'"$SANDBOX"'/ok-hardlink.tar.gz"' >>"$SANDBOX/v.log" 2>&1 || vrc8=$?
  if [ "$vrc4" != "0" ]; then pass "ac2.10: absolute-link-target tar rejected pre-extraction"; else fail "ac2.10: absolute-link-target tar NOT rejected"; fi
  if [ "$vrc5" != "0" ]; then pass "ac2.10: dot-dot-link-target tar rejected pre-extraction"; else fail "ac2.10: dot-dot-link-target tar NOT rejected"; fi
  if [ "$vrc6" = "0" ]; then pass "ac2.10: benign in-tree link tar passes (predicate is escaping-only)"; else fail "ac2.10: benign in-tree link tar wrongly rejected (rc=$vrc6)"; fi
  if [ "$vrc7" != "0" ]; then pass "ac2.10: absolute hardlink-target tar rejected pre-extraction"; else fail "ac2.10: absolute hardlink-target tar NOT rejected"; fi
  if [ "$vrc8" = "0" ]; then pass "ac2.10: benign in-tree hardlink tar passes"; else fail "ac2.10: benign in-tree hardlink tar wrongly rejected (rc=$vrc8)"; fi
  if [ "$(cat "$SANDBOX/outside/keeper.txt")" = "OUTSIDE-BYTES" ]; then
    pass "ac2.10: zero outside writes across tar probes"
  else
    fail "ac2.10: outside write detected"
  fi
}

# ════════════════════════ AC2.11 (F-08 _archived) ════════════════════════
case_ac211() {
  CURRENT_CASE="ac2.11"
  new_sandbox
  # Unit level: the REAL archive_old_skill_mds, twice in the same second.
  extract_fn archive_old_skill_mds "$SANDBOX/archive.fn.sh" "_archived."
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/a.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/a.log"; }\nnote_created_top() { :; }\n' \
    "$SANDBOX" "$SANDBOX" > "$SANDBOX/astubs.sh"
  mkdir -p "$SANDBOX/skills"
  printf 'OLD1\n' > "$SANDBOX/skills/old1.md"
  printf 'DOC\n' > "$SANDBOX/skills/doc-organization.md"
  bash -c 'source "'"$SANDBOX"'/astubs.sh"; source "'"$SANDBOX"'/archive.fn.sh"; archive_old_skill_mds "'"$SANDBOX"'/skills"' >>"$SANDBOX/a.log" 2>&1 || true
  printf 'OLD2\n' > "$SANDBOX/skills/old2.md"
  bash -c 'source "'"$SANDBOX"'/astubs.sh"; source "'"$SANDBOX"'/archive.fn.sh"; archive_old_skill_mds "'"$SANDBOX"'/skills"' >>"$SANDBOX/a.log" 2>&1 || true
  local ndirs
  ndirs="$(ls -d "$SANDBOX"/skills/_archived.* 2>/dev/null | LC_ALL=C wc -l | tr -d ' ')"
  if [ "$ndirs" = "2" ]; then
    pass "ac2.11: double archive → two timestamped dirs (same-second safe)"
  else
    fail "ac2.11: expected 2 timestamped dirs, found $ndirs"
  fi
  if [ -f "$SANDBOX/skills/_archived."*/old1.md ] && [ ! -f "$SANDBOX/skills/old1.md" ]; then
    pass "ac2.11: zero overwrites (first archive intact, source moved)"
  else
    fail "ac2.11: archive content anomaly"
  fi
  # Loud failure: read-only skills dir → non-zero (no silent swallow).
  mkdir -p "$SANDBOX/ro"
  printf 'X\n' > "$SANDBOX/ro/locked.md"
  chmod -w "$SANDBOX/ro"
  local arc=0
  bash -c 'source "'"$SANDBOX"'/astubs.sh"; source "'"$SANDBOX"'/archive.fn.sh"; archive_old_skill_mds "'"$SANDBOX"'/ro"' >>"$SANDBOX/a.log" 2>&1 || arc=$?
  chmod +w "$SANDBOX/ro"
  if [ "$arc" != "0" ]; then pass "ac2.11: chmod -w move failure loud (rc=$arc)"; else fail "ac2.11: chmod -w failure swallowed"; fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # Integration: full-installer double run (2nd via --force) → 2 dirs.
  CURRENT_CASE="ac2.11"
  new_sandbox
  stage_pruned_source
  mkdir -p "$TARGET/.agents/skills" "$TARGET/.tad"
  printf '2.2.0\n' > "$TARGET/.tad/version.txt"
  printf 'LEGACY-ONE\n' > "$TARGET/.agents/skills/legacy-one.md"
  local rc
  rc="$(run_install codex "$SANDBOX/install1.log")"
  printf 'LEGACY-TWO\n' > "$TARGET/.agents/skills/legacy-two.md"
  local rc2=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform codex --yes --force >"$SANDBOX/install2.log" 2>&1 ) || rc2=$?
  local want
  want="$(source_version)"
  if [ "$rc" = "0" ] && [ "$rc2" = "0" ]; then pass "ac2.11: integration double-run rc=0/0"; else fail "ac2.11: integration rcs $rc/$rc2"; fi
  assert_version_proof "$want"
  local idirs
  idirs="$(ls -d "$TARGET"/.agents/skills/_archived.* 2>/dev/null | LC_ALL=C wc -l | tr -d ' ')"
  if [ "$idirs" = "2" ]; then
    pass "ac2.11: integration produced two timestamped _archived dirs"
  else
    fail "ac2.11: integration found $idirs timestamped dirs (want 2)"
  fi
  assert_no_network
}

# ════════════════════════ AC2.12 ════════════════════════
case_ac212() {
  CURRENT_CASE="ac2.12"
  local dirs zer inter
  dirs="$(bash "$DERIVE" --dirs "$REPO" | LC_ALL=C sort -u)"
  zer="$(bash "$DERIVE" --zero-touch "$REPO" | LC_ALL=C sort -u)"
  inter="$(LC_ALL=C comm -12 <(printf '%s\n' "$dirs") <(printf '%s\n' "$zer"))" || true
  if [ -z "$inter" ]; then
    pass "ac2.12: --dirs ∩ --zero-touch = ∅"
  else
    fail "ac2.12: intersection non-empty: $inter"
  fi
  local rc=0 gtmp
  gtmp="$(mktemp /tmp/tad-ac-guard.XXXXXX)" || { fail "ac2.12: mktemp failed"; return; }
  bash "$TADSH" --verify-denylist >"$gtmp" 2>&1 || rc=$?
  rm -f "$gtmp"
  if [ "$rc" = "0" ]; then pass "ac2.12: --verify-denylist PASS"; else fail "ac2.12: --verify-denylist rc=$rc"; fi
}

# ════════════════════════ AC2.13 (v3 upgrade safety: pre-existing user .claude/ byte-identical) ════════════════════════
case_ac213() {
  CURRENT_CASE="ac2.13"
  new_sandbox
  stage_pruned_source
  local want rc
  want="$(source_version)"
  # Pre-existing downstream .claude tree with user assets (hooks / MCP /
  # permissions / skills / commands). The v3 installer must never write,
  # delete, or recurse into it.
  mkdir -p "$TARGET/.claude/skills/alex" "$TARGET/.claude/commands" "$TARGET/.agents/skills"
  printf 'USER-SKILL-BYTES\n' > "$TARGET/.claude/skills/alex/SKILL.md"
  printf '{"hooks": ["user-hook"]}\n' > "$TARGET/.claude/settings.json"
  printf '{"local": true}\n' > "$TARGET/.claude/settings.local.json"
  printf '{"mcpServers": {"mine": {}}}\n' > "$TARGET/.claude/.mcp.json"
  printf 'USER-COMMAND\n' > "$TARGET/.claude/commands/mine.md"
  mkdir -p "$TARGET/.tad"
  printf '2.44.6\n' > "$TARGET/.tad/version.txt"
  mkdir -p "$TARGET/.tad/project-knowledge"
  # Simulate the 2.44.6→3.0.0 upgrade: staged source carries the new version
  # (sandbox copy only — the repo version.txt is bumped separately in S9).
  printf '3.0.0\n' > "$SOURCE/.tad/version.txt"
  want="3.0.0"
  snapshot_target "$SNAP/pre-claude"
  rc="$(run_install codex "$SANDBOX/install-upgrade.log")"
  if [ "$rc" = "0" ]; then pass "ac2.13: upgrade run rc=0"; else fail "ac2.13: upgrade run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  local d_unexp
  d_unexp="$(diff -r "$SNAP/pre-claude/.claude" "$TARGET/.claude" 2>&1 || true)"
  if [ -z "$d_unexp" ]; then
    pass "ac2.13: pre-existing user .claude/ byte-identical after upgrade"
  else
    fail "ac2.13: user .claude/ MUTATED:"; printf '%s\n' "$d_unexp" | head -10
  fi
  if [ -d "$TARGET/.agents/skills/alex" ]; then
    pass "ac2.13: new .agents/skills/ installed alongside"
  else
    fail "ac2.13: .agents/skills/ missing after upgrade"
  fi
}

# ════════════════════════ Phase 2: Claude Code projection (AC2.14 to AC2.17) ════════════════════════
# claude_sig <dir> <relpath> — stable listing of a path (symlink targets, cksum, no .git).
claude_sig() {
  ( cd "$1" 2>/dev/null || exit 0
    [ -e "$2" ] || [ -L "$2" ] || exit 0
    find "$2" -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r p; do
      if [ -L "$p" ]; then printf 'L %s -> %s\n' "$p" "$(readlink "$p")"
      elif [ -d "$p" ]; then printf 'D %s\n' "$p"
      else printf 'F %s %s\n' "$p" "$(cksum < "$p")"; fi
    done ) || true
}

# AC2.14: fresh claude-code install projects links + hooks template, creates no
# CLAUDE.md, is a no-op on plain re-run and idempotent on --force; the other
# platforms leave a bare target without .claude/ and CLAUDE.md.
case_ac214() {
  CURRENT_CASE="ac2.14"
  new_sandbox
  stage_pruned_source
  local rc n links bad s p
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.14: fresh claude-code install rc=0"; else fail "ac2.14: fresh claude-code install rc=$rc"; fi
  assert_version_proof "$(source_version)"
  n=0; links=0; bad=0
  for s in "$TARGET"/.agents/skills/*/; do
    s="${s%/}"; p="${s##*/}"
    [ -f "$s/SKILL.md" ] || continue
    n=$((n + 1))
    if [ -L "$TARGET/.claude/skills/$p" ] && [ "$(readlink "$TARGET/.claude/skills/$p")" = "../../.agents/skills/$p" ]; then links=$((links + 1)); fi
    cmp -s "$s/SKILL.md" "$TARGET/.claude/skills/$p/SKILL.md" || bad=$((bad + 1))
  done
  if [ "$n" -gt 0 ] && [ "$links" = "$n" ] && [ "$bad" = "0" ]; then
    pass "ac2.14: all $n skills have a relative link that resolves to the canonical SKILL.md"
  else
    fail "ac2.14: links=$links of $n, unresolved=$bad"
  fi
  if cmp -s "$SOURCE/.tad/templates/claude/settings.json" "$TARGET/.claude/settings.json"; then
    pass "ac2.14: settings.json is the template, byte for byte"
  else
    fail "ac2.14: settings.json missing or differs from the template"
  fi
  if [ ! -e "$TARGET/CLAUDE.md" ] && [ ! -L "$TARGET/CLAUDE.md" ]; then pass "ac2.14: CLAUDE.md not created"; else fail "ac2.14: CLAUDE.md was created"; fi
  if grep -qF 'CLAUDE-SUMMARY' "$SANDBOX/install.log" && ! grep -qF 'TAD hooks are NOT registered' "$SANDBOX/install.log"; then
    pass "ac2.14: summary present and does not claim hooks are missing"
  else
    fail "ac2.14: summary missing, or it claims hooks are missing"
  fi
  claude_sig "$TARGET" .claude > "$SNAP/sig1"
  rc="$(run_install_cc claude-code "$SANDBOX/rerun.log")"
  if [ "$rc" = "0" ] && grep -qF 'Nothing to do' "$SANDBOX/rerun.log" && ! grep -qF 'CLAUDE-HINT' "$SANDBOX/rerun.log"; then
    pass "ac2.14: plain re-run is the ordinary no-op without a hint"
  else
    fail "ac2.14: plain re-run not a clean no-op (rc=$rc)"
  fi
  rc="$(run_install_cc claude-code "$SANDBOX/force.log" --force)"
  claude_sig "$TARGET" .claude > "$SNAP/sig2"
  if [ "$rc" = "0" ] && grep -qF 'framework files' "$SANDBOX/force.log" && cmp -s "$SNAP/sig1" "$SNAP/sig2"; then
    pass "ac2.14: --force re-run executes and leaves .claude/ identical"
  else
    fail "ac2.14: --force re-run rc=$rc or .claude/ changed"
  fi
  assert_no_network
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # Other platforms: a bare target gets neither .claude/ nor CLAUDE.md.
  local plat
  for plat in codex cursor opencode; do
    new_sandbox
    stage_pruned_source
    rc="$(run_install_cc "$plat" "$SANDBOX/install.log")"
    if [ "$rc" = "0" ] && [ ! -e "$TARGET/.claude" ] && [ ! -L "$TARGET/.claude" ] && [ ! -e "$TARGET/CLAUDE.md" ]; then
      pass "ac2.14[$plat]: no .claude/ and no CLAUDE.md created"
    else
      fail "ac2.14[$plat]: rc=$rc or .claude/CLAUDE.md appeared"
    fi
    guarded_cleanup "$SANDBOX"; SANDBOX=""
  done
}

# AC2.15: everything the user already had is kept; CLAUDE.md gets exactly one
# managed block; a differing settings.json is kept and the summary says so.
case_ac215() {
  CURRENT_CASE="ac2.15"
  new_sandbox
  stage_pruned_source
  mkdir -p "$TARGET/.claude/skills/alex" "$TARGET/.claude/skills/blake" "$TARGET/.claude/commands"
  printf 'USER-ALEX\n' > "$TARGET/.claude/skills/alex/SKILL.md"
  printf 'notes\n' > "$TARGET/.claude/skills/blake/notes.txt"
  ln -s /nonexistent/elsewhere "$TARGET/.claude/skills/gate"
  printf '{"permissions":{"allow":["Bash(ls:*)"]}}\n' > "$TARGET/.claude/settings.json"
  printf 'MY RESEARCH\n' > "$TARGET/.claude/commands/research.md"
  printf '# Mine\n\nrules\n' > "$TARGET/CLAUDE.md"; chmod 600 "$TARGET/CLAUDE.md"
  cp -p "$TARGET/CLAUDE.md" "$SNAP/claude.before"
  claude_sig "$TARGET" .claude > "$SNAP/pre.sig"
  local rc osz
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.15: install rc=0"; else fail "ac2.15: install rc=$rc"; fi
  if [ "$(cat "$TARGET/.claude/settings.json")" = '{"permissions":{"allow":["Bash(ls:*)"]}}' ] \
     && [ "$(cat "$TARGET/.claude/commands/research.md")" = 'MY RESEARCH' ] \
     && [ "$(cat "$TARGET/.claude/skills/alex/SKILL.md")" = 'USER-ALEX' ] \
     && [ -f "$TARGET/.claude/skills/blake/notes.txt" ] && [ -L "$TARGET/.claude/skills/gate" ] \
     && [ "$(readlink "$TARGET/.claude/skills/gate")" = "/nonexistent/elsewhere" ]; then
    pass "ac2.15: user settings, command, skill dir, notes and foreign link all kept"
  else
    fail "ac2.15: a pre-existing .claude entry was changed"
  fi
  if grep -qF 'CLAUDE-HOOKS-KEPT' "$SANDBOX/install.log" && grep -qF 'TAD hooks are NOT registered' "$SANDBOX/install.log" \
     && grep -qF 'CLAUDE-SKILL-KEPT' "$SANDBOX/install.log"; then
    pass "ac2.15: log reports kept hooks/skills and the summary says hooks are not registered"
  else
    fail "ac2.15: kept tokens or the NOT-registered line missing"
  fi
  osz="$(wc -c < "$SNAP/claude.before" | tr -d ' ')"
  if cmp -s <(head -c "$osz" "$TARGET/CLAUDE.md") "$SNAP/claude.before" \
     && [ "$(grep -c '^@AGENTS.md$' "$TARGET/CLAUDE.md")" = "1" ] \
     && [ "$(stat -f '%Lp' "$TARGET/CLAUDE.md" 2>/dev/null || stat -c '%a' "$TARGET/CLAUDE.md")" = "600" ]; then
    pass "ac2.15: CLAUDE.md kept as prefix, one block appended, mode 600 preserved"
  else
    fail "ac2.15: CLAUDE.md prefix/block/mode wrong"
  fi
  cp -p "$TARGET/CLAUDE.md" "$SNAP/claude.after1"
  claude_sig "$TARGET" .claude > "$SNAP/sig1"
  rc="$(run_install_cc claude-code "$SANDBOX/force.log" --force)"
  claude_sig "$TARGET" .claude > "$SNAP/sig2"
  if [ "$rc" = "0" ] && cmp -s "$TARGET/CLAUDE.md" "$SNAP/claude.after1" && cmp -s "$SNAP/sig1" "$SNAP/sig2"; then
    pass "ac2.15: --force re-run adds no second block and changes nothing under .claude/ (research.md kept)"
  else
    fail "ac2.15: --force re-run changed CLAUDE.md or .claude/ (rc=$rc)"
  fi
  assert_no_network
}

# AC2.16: a failure in the last stage (hooks) rolls everything back, including
# the CLAUDE.md append (bytes and permission bits) and the created links.
case_ac216() {
  CURRENT_CASE="ac2.16"
  new_sandbox
  stage_pruned_source
  mkdir -p "$TARGET/.claude/skills"
  printf 'keep\n' > "$TARGET/.claude/keep.txt"
  printf '# My rules\nline two\n' > "$TARGET/CLAUDE.md"; chmod 664 "$TARGET/CLAUDE.md"
  chmod 555 "$TARGET/.claude"
  snapshot_target "$SNAP/pre"
  claude_sig "$TARGET" . > "$SNAP/pre.sig"
  local rc
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" != "0" ]; then pass "ac2.16: install failed as expected (rc=$rc)"; else fail "ac2.16: install succeeded although .claude is read-only"; fi
  if grep -qF 'CLAUDE-SKILLS-DONE' "$SANDBOX/install.log" && grep -qF 'CLAUDE-MD-APPENDED' "$SANDBOX/install.log" \
     && grep -qF 'CLAUDE-HOOKS-FAILED' "$SANDBOX/install.log"; then
    pass "ac2.16: failure came from the hooks stage, after links and the append"
  else
    fail "ac2.16: expected stage tokens missing (failure came from another stage)"
  fi
  claude_sig "$TARGET" . > "$SNAP/post.sig"
  if cmp -s "$SNAP/pre.sig" "$SNAP/post.sig"; then pass "ac2.16: target tree identical to pre-install state"; else fail "ac2.16: rollback left a different tree"; fi
  if [ "$(stat -f '%Lp' "$TARGET/CLAUDE.md" 2>/dev/null || stat -c '%a' "$TARGET/CLAUDE.md")" = "664" ]; then
    pass "ac2.16: CLAUDE.md permission bits restored (664)"
  else
    fail "ac2.16: CLAUDE.md permission bits not restored"
  fi
  chmod 755 "$TARGET/.claude"
}

# AC2.17: symlinks at .claude/skills, .claude/settings.json and CLAUDE.md are
# never written through, replaced or removed.
case_ac217() {
  CURRENT_CASE="ac2.17"
  local rc
  # (a) .claude/skills is a user symlink
  new_sandbox; stage_pruned_source
  mkdir -p "$SANDBOX/elsewhere" "$TARGET/.claude"; ln -s "$SANDBOX/elsewhere" "$TARGET/.claude/skills"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && [ -L "$TARGET/.claude/skills" ] && [ -z "$(ls -A "$SANDBOX/elsewhere")" ] && grep -qF 'CLAUDE-SKILLS-SKIPPED' "$SANDBOX/install.log"; then
    pass "ac2.17: .claude/skills symlink skipped, nothing written through"
  else
    fail "ac2.17: .claude/skills symlink mishandled (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # (b) .claude is a dangling symlink
  new_sandbox; stage_pruned_source
  mkdir -p "$SANDBOX/outside"; ln -s "$SANDBOX/outside/not-there" "$TARGET/.claude"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && [ -L "$TARGET/.claude" ] && [ -z "$(ls -A "$SANDBOX/outside")" ] \
     && grep -qF 'CLAUDE-SKILLS-SKIPPED' "$SANDBOX/install.log" && grep -qF 'CLAUDE-HOOKS-SKIPPED' "$SANDBOX/install.log"; then
    pass "ac2.17: dangling .claude symlink skipped for skills and hooks, nothing created behind it"
  else
    fail "ac2.17: dangling .claude symlink mishandled (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # (c) .claude/settings.json is a dangling symlink
  new_sandbox; stage_pruned_source
  mkdir -p "$SANDBOX/outside" "$TARGET/.claude"; ln -s "$SANDBOX/outside/project-settings.json" "$TARGET/.claude/settings.json"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && [ -L "$TARGET/.claude/settings.json" ] && [ -z "$(ls -A "$SANDBOX/outside")" ] && grep -qF 'CLAUDE-HOOKS-SKIPPED' "$SANDBOX/install.log"; then
    pass "ac2.17: dangling settings.json symlink not written through"
  else
    fail "ac2.17: dangling settings.json symlink mishandled (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # (d) CLAUDE.md is a dangling symlink
  new_sandbox; stage_pruned_source
  mkdir -p "$SANDBOX/outside"; ln -s "$SANDBOX/outside/shared.md" "$TARGET/CLAUDE.md"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && [ -L "$TARGET/CLAUDE.md" ] && [ -z "$(ls -A "$SANDBOX/outside")" ] && grep -qF 'CLAUDE-MD-SKIPPED (symlink)' "$SANDBOX/install.log"; then
    pass "ac2.17: dangling CLAUDE.md symlink skipped"
  else
    fail "ac2.17: dangling CLAUDE.md symlink mishandled (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  # (e) AGENTS.md is a symlink: CLAUDE.md is left alone
  new_sandbox; stage_pruned_source
  mkdir -p "$SANDBOX/outside"; printf 'x\n' > "$SANDBOX/outside/agents.md"; ln -s "$SANDBOX/outside/agents.md" "$TARGET/AGENTS.md"
  printf '# Mine\n' > "$TARGET/CLAUDE.md"; cp "$TARGET/CLAUDE.md" "$SNAP/claude.before"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && cmp -s "$TARGET/CLAUDE.md" "$SNAP/claude.before" && grep -qF 'CLAUDE-MD-SKIPPED (no regular AGENTS.md)' "$SANDBOX/install.log"; then
    pass "ac2.17: symlinked AGENTS.md -> CLAUDE.md untouched"
  else
    fail "ac2.17: symlinked AGENTS.md mishandled (rc=$rc)"
  fi
}

# ════════════════════════ R1 (scope fence) ════════════════════════
case_r1() {
  CURRENT_CASE="r1"
  # Phase 5b (B5) — what changed and why. r1 was a scope fence hard-coded to
  # the 2026-09-03 handoff §7 (five allowed paths): any change to ANY other
  # file made it fail, so it measured the state of the working tree, not the
  # fixture, and it has been red since the first unrelated edit. The property
  # worth keeping is the one the fence was a proxy for: "running this fixture
  # did not dirty the live repo" (every case stages its own sandbox and must
  # never write into $REPO). So r1 now compares `git status --porcelain`
  # captured when the fixture started (R1_PORCELAIN_BEFORE, taken before the
  # first case runs) with the output now; pre-existing dirt is irrelevant,
  # only a difference fails. Limits: porcelain shows paths and status codes,
  # not content, so a fixture edit to an already-modified file is not seen, and
  # edits made by someone else while the fixture runs are indistinguishable
  # from the fixture's own.
  local after
  after="$(cd "$REPO" && git status --porcelain 2>&1)" || true
  if [ "$after" = "$R1_PORCELAIN_BEFORE" ]; then
    pass "r1: fixture run left the live repo's git status unchanged"
  else
    printf '  diff of git status --porcelain (before -> after this run):\n'
    diff <(printf '%s\n' "$R1_PORCELAIN_BEFORE") <(printf '%s\n' "$after") | head -20 || true
    fail "r1: git status changed during the fixture run"
  fi
}

# ── Phase 4a: legacy Claude Code install adoption ────────────────────
# The stage_pruned_source copy omits .tad/provenance (it is a TAD_TRANSIENT dir,
# never copied to targets); the adoption cases stage the ledger explicitly.
stage_provenance() {
  mkdir -p "$SOURCE/.tad/provenance"
  cp "$REPO"/.tad/provenance/claude-legacy.tsv "$REPO"/.tad/provenance/MANIFEST.sha1 "$SOURCE/.tad/provenance/"
}

# legacy_claude_target — a v2.44.6-style Claude Code install claiming 3.1.0 (so the
# installer takes the plain upgrade path): alex, gate, blake, settings.json and a
# CLAUDE.md, all straight from the released tag.
legacy_claude_target() {
  if ! git -C "$REPO" rev-parse -q --verify 'v2.44.6^{commit}' >/dev/null 2>&1; then
    fail "$CURRENT_CASE: tag v2.44.6 missing (cannot build the legacy fixture)"; return 1
  fi
  mkdir -p "$TARGET/.tad/active/handoffs"; printf '3.1.0\n' > "$TARGET/.tad/version.txt"
  ( cd "$REPO" && git archive v2.44.6 .claude/skills/alex .claude/skills/gate .claude/skills/blake .claude/settings.json CLAUDE.md ) | tar -x -C "$TARGET" || { fail "$CURRENT_CASE: git archive failed"; return 1; }
  return 0
}

adopt_archive_dir() { find "$SANDBOX/cc-backups" -type d -path '*/claude-adopt/*' -mindepth 3 -maxdepth 3 2>/dev/null | head -1; }
adopt_tomb_count() { find "$TARGET/.claude" -name '.tad-adopt-tomb*' 2>/dev/null | wc -l | tr -d ' '; }

# AC2.18: a read-only sub-directory inside an adopted skill must not fail the install.
case_ac218() {
  CURRENT_CASE="ac2.18"
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  local ro rc a
  ro="$(find "$TARGET/.claude/skills/alex" -mindepth 1 -type d | head -1)"
  if [ -z "$ro" ]; then fail "ac2.18: legacy alex has no sub-directory to make read-only"; return 0; fi
  chmod 555 "$ro"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && [ -L "$TARGET/.claude/skills/alex" ] && [ "$(readlink "$TARGET/.claude/skills/alex")" = "../../.agents/skills/alex" ]; then
    pass "ac2.18: install rc=0 and the skill with a read-only sub-directory was adopted"
  else
    fail "ac2.18: install rc=$rc or alex not adopted"
  fi
  a="$(adopt_archive_dir)"
  if [ -n "$a" ] && [ -d "$a/tree/.claude/skills/alex" ]; then pass "ac2.18: the archive holds the skill"; else fail "ac2.18: archive copy missing"; fi
  if [ "$(adopt_tomb_count)" = "0" ] || grep -qF 'Tombstones kept' "$SANDBOX/install.log"; then
    pass "ac2.18: the tombstone is gone, or its being kept is stated in the summary"
  else
    fail "ac2.18: a tombstone is left behind without a word"
  fi
  chmod -R u+w "$SANDBOX" 2>/dev/null || true
  assert_no_network
}

# AC2.19: a skill directory that cannot be renamed (mode 0555) is left, not fatal.
case_ac219() {
  CURRENT_CASE="ac2.19"
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  local rc a
  cp "$TARGET/.claude/skills/alex/SKILL.md" "$SNAP/alex.skill.before"
  chmod 555 "$TARGET/.claude/skills/alex"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" != "0" ]; then fail "ac2.19: install rc=$rc"; chmod -R u+w "$SANDBOX" 2>/dev/null || true; return 0; fi
  pass "ac2.19: install rc=0"
  if [ -L "$TARGET/.claude/skills/alex" ]; then
    pass "ac2.19: SKIP-NOT-APPLICABLE here the rename of a 0555 directory is allowed; adopted instead"
  elif [ -d "$TARGET/.claude/skills/alex" ] && cmp -s "$TARGET/.claude/skills/alex/SKILL.md" "$SNAP/alex.skill.before" \
       && grep -qF 'CLAUDE-ADOPT-LEFT .claude/skills/alex (cannot be moved)' "$SANDBOX/install.log"; then
    pass "ac2.19: the 0555 skill directory stayed byte-identical and is reported as left (cannot be moved)"
    a="$(adopt_archive_dir)"
    if [ -n "$a" ] && grep -qF "$(printf 'REVERTED\t.claude/skills/alex')" "$a/done.tsv"; then pass "ac2.19: the journal marks it REVERTED"; else fail "ac2.19: journal lacks the REVERTED line"; fi
  else
    fail "ac2.19: the 0555 skill directory was neither adopted nor left intact"
  fi
  if [ -L "$TARGET/.claude/skills/gate" ]; then pass "ac2.19: positive control: gate was adopted in the same run"; else fail "ac2.19: gate not adopted"; fi
  if [ "$(adopt_tomb_count)" = "0" ]; then pass "ac2.19: no tombstone left"; else fail "ac2.19: tombstone left behind"; fi
  chmod -R u+w "$SANDBOX" 2>/dev/null || true
  assert_no_network
}

# AC2.20: no usable SHA-1 tool means report-only: the install succeeds and nothing is vacated.
case_ac220() {
  CURRENT_CASE="ac2.20"
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  local rc t real
  # Shims in front of PATH: SHA-1 requests fail, everything else reaches the real tool.
  for t in shasum sha1sum openssl; do
    real="$(command -v "$t" 2>/dev/null || true)"
    [ -n "$real" ] || continue
    case "$t" in
      shasum) printf '#!/bin/sh\ncase " $* " in *" -a 1 "*|*" -a1 "*) exit 1 ;; esac\nexec "%s" "$@"\n' "$real" > "$SHIMBIN/$t" ;;
      sha1sum) printf '#!/bin/sh\nexit 1\n' > "$SHIMBIN/$t" ;;
      openssl) printf '#!/bin/sh\ncase "$1" in sha1|dgst) exit 1 ;; esac\nexec "%s" "$@"\n' "$real" > "$SHIMBIN/$t" ;;
    esac
    chmod +x "$SHIMBIN/$t"
  done
  claude_sig "$TARGET" .claude > "$SNAP/pre.sig"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && grep -qF 'CLAUDE-ADOPT-DEGRADED no SHA-1 tool' "$SANDBOX/install.log"; then
    pass "ac2.20: rc=0 and CLAUDE-ADOPT-DEGRADED names the missing SHA-1 tool"
  else
    fail "ac2.20: rc=$rc or no degraded line"
  fi
  if [ -d "$TARGET/.claude/skills/alex" ] && [ ! -L "$TARGET/.claude/skills/alex" ] && [ -d "$TARGET/.claude/skills/gate" ] && [ ! -L "$TARGET/.claude/skills/gate" ] \
     && [ -z "$(adopt_archive_dir)" ] && [ "$(adopt_tomb_count)" = "0" ]; then
    pass "ac2.20: legacy skill directories untouched, no archive, no tombstone"
  else
    fail "ac2.20: something was vacated without a SHA-1 tool"
  fi
  assert_no_network
}

# AC2.21: pack meta rule: sync_policy upstream and the generator's line shapes are provable, forked and free text are not.
case_ac221() {
  CURRENT_CASE="ac2.21"
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  local rc meta
  meta() { # $1 policy $2 extra line
    printf '# Auto-generated by tad.sh \xe2\x80\x94 do not edit manually\ninstalled_version: "2.44.6"\ninstalled_date: "2026-09-15"\nsync_policy: %s\nbaseline_source: fresh_install\nfiles:\n  - path: "SKILL.md"\n    sha256: "0000000000000000000000000000000000000000000000000000000000000000"\n%s' "$1" "$2"
  }
  meta upstream '' > "$TARGET/.claude/skills/alex/.tad-pack-meta.yaml"
  meta forked '' > "$TARGET/.claude/skills/gate/.tad-pack-meta.yaml"
  meta upstream 'this is free text, not a generator line
' > "$TARGET/.claude/skills/blake/.tad-pack-meta.yaml"
  claude_sig "$TARGET" .claude/skills/gate > "$SNAP/gate.sig"; claude_sig "$TARGET" .claude/skills/blake > "$SNAP/blake.sig"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  [ "$rc" = "0" ] && pass "ac2.21: install rc=0" || fail "ac2.21: install rc=$rc"
  [ -L "$TARGET/.claude/skills/alex" ] && pass "ac2.21: positive control: alex with an upstream meta was adopted" || fail "ac2.21: alex with an upstream meta was not adopted"
  claude_sig "$TARGET" .claude/skills/gate > "$SNAP/gate.sig2"; claude_sig "$TARGET" .claude/skills/blake > "$SNAP/blake.sig2"
  if cmp -s "$SNAP/gate.sig" "$SNAP/gate.sig2" && [ ! -L "$TARGET/.claude/skills/gate" ] && grep -qF 'CLAUDE-ADOPT-LEFT .claude/skills/gate' "$SANDBOX/install.log"; then
    pass "ac2.21: sync_policy forked: the skill stays byte-identical and is reported as left"
  else
    fail "ac2.21: sync_policy forked skill was changed or not reported"
  fi
  if cmp -s "$SNAP/blake.sig" "$SNAP/blake.sig2" && [ ! -L "$TARGET/.claude/skills/blake" ] && grep -qF 'CLAUDE-ADOPT-LEFT .claude/skills/blake' "$SANDBOX/install.log"; then
    pass "ac2.21: free text in the pack meta: the skill stays byte-identical and is reported as left"
  else
    fail "ac2.21: skill with a free-text pack meta was changed or not reported"
  fi
  assert_no_network
}

# harness_run <script> — run a generated harness with bash; stdout echoed.
harness_run() { bash "$1" 2>&1; }

# AC2.22: moving an original back out of its tombstone never nests into an
# occupied slot and never goes through a link.
case_ac222() {
  CURRENT_CASE="ac2.22"
  new_sandbox
  extract_fn claude_adopt_move_back "$SANDBOX/mb.fn.sh" "CLAUDE-ADOPT-MANUAL"
  extract_fn claude_adopt_path_ok "$SANDBOX/po.fn.sh" "_type"
  local P="$SANDBOX/proj" out
  cat > "$SANDBOX/h.sh" <<HEOF
set -uo pipefail
log_error() { printf 'ERR: %s\n' "\$1"; }
. "$SANDBOX/po.fn.sh"
. "$SANDBOX/mb.fn.sh"
cd "$P"
HEOF
  mk() { rm -rf "$P"; mkdir -p "$P/.claude/skills/.tad-adopt-tomb.1/alex" "$SANDBOX/outside"; printf 'ORIGINAL\n' > "$P/.claude/skills/.tad-adopt-tomb.1/alex/SKILL.md"; }
  # (a) occupied by a real directory: no nesting, nothing overwritten
  mk; mkdir -p "$P/.claude/skills/alex"; printf 'NEW\n' > "$P/.claude/skills/alex/SKILL.md"
  out="$(cat "$SANDBOX/h.sh"; printf 'claude_adopt_move_back .claude/skills/alex .claude/skills/.tad-adopt-tomb.1/alex; echo "rc=$?"\n')"
  printf '%s\n' "$out" > "$SANDBOX/ha.sh"; out="$(harness_run "$SANDBOX/ha.sh")"
  if printf '%s' "$out" | grep -qF 'rc=1' && printf '%s' "$out" | grep -qF 'CLAUDE-ADOPT-MANUAL' \
     && [ ! -e "$P/.claude/skills/alex/alex" ] && [ "$(cat "$P/.claude/skills/alex/SKILL.md")" = "NEW" ] \
     && [ "$(cat "$P/.claude/skills/.tad-adopt-tomb.1/alex/SKILL.md")" = "ORIGINAL" ]; then
    pass "ac2.22: occupied slot (directory): rc=1, both paths reported, no nesting, original stays in the tombstone"
  else
    fail "ac2.22: occupied directory slot mishandled: $out"
  fi
  # (b) occupied by a link to a directory: nothing created behind the link
  mk; ln -s "$SANDBOX/outside" "$P/.claude/skills/alex"
  printf '%s\n' "$(cat "$SANDBOX/h.sh"; printf 'claude_adopt_move_back .claude/skills/alex .claude/skills/.tad-adopt-tomb.1/alex; echo "rc=$?"\n')" > "$SANDBOX/hb.sh"; out="$(harness_run "$SANDBOX/hb.sh")"
  if printf '%s' "$out" | grep -qF 'rc=1' && [ -z "$(ls -A "$SANDBOX/outside")" ] && [ -L "$P/.claude/skills/alex" ] \
     && [ "$(cat "$P/.claude/skills/.tad-adopt-tomb.1/alex/SKILL.md")" = "ORIGINAL" ]; then
    pass "ac2.22: slot holds a link: rc=1, nothing written through the link, original stays in the tombstone"
  else
    fail "ac2.22: link slot mishandled: $out"
  fi
  # (c) free slot: moved back, tombstone slot empty
  mk
  printf '%s\n' "$(cat "$SANDBOX/h.sh"; printf 'claude_adopt_move_back .claude/skills/alex .claude/skills/.tad-adopt-tomb.1/alex; echo "rc=$?"\n')" > "$SANDBOX/hc.sh"; out="$(harness_run "$SANDBOX/hc.sh")"
  if printf '%s' "$out" | grep -qF 'rc=0' && [ "$(cat "$P/.claude/skills/alex/SKILL.md")" = "ORIGINAL" ] && [ ! -e "$P/.claude/skills/.tad-adopt-tomb.1/alex" ]; then
    pass "ac2.22: positive control: a free slot gets the original back"
  else
    fail "ac2.22: free slot move-back failed: $out"
  fi
  # (d) nothing in the tombstone: rc=2
  mk; rm -rf "$P/.claude/skills/.tad-adopt-tomb.1/alex"
  printf '%s\n' "$(cat "$SANDBOX/h.sh"; printf 'claude_adopt_move_back .claude/skills/alex .claude/skills/.tad-adopt-tomb.1/alex; echo "rc=$?"\n')" > "$SANDBOX/hd.sh"; out="$(harness_run "$SANDBOX/hd.sh")"
  if printf '%s' "$out" | grep -qF 'rc=2'; then pass "ac2.22: empty tombstone slot: rc=2, nothing moved"; else fail "ac2.22: empty tombstone slot: $out"; fi
  # (e) the tombstone directory itself is a link: path guard refuses
  mk; mv "$P/.claude/skills/.tad-adopt-tomb.1" "$SANDBOX/real-tomb"; ln -s "$SANDBOX/real-tomb" "$P/.claude/skills/.tad-adopt-tomb.1"
  printf '%s\n' "$(cat "$SANDBOX/h.sh"; printf 'claude_adopt_move_back .claude/skills/alex .claude/skills/.tad-adopt-tomb.1/alex; echo "rc=$?"\n')" > "$SANDBOX/he.sh"; out="$(harness_run "$SANDBOX/he.sh")"
  if printf '%s' "$out" | grep -qF 'rc=1' && [ ! -e "$P/.claude/skills/alex" ] && [ "$(cat "$SANDBOX/real-tomb/alex/SKILL.md")" = "ORIGINAL" ]; then
    pass "ac2.22: tombstone parent is a link: guard refuses, nothing moved"
  else
    fail "ac2.22: symlinked tombstone parent mishandled: $out"
  fi
}

# AC2.23: at commit time a tombstone whose content no longer equals the archive copy is kept.
case_ac223() {
  CURRENT_CASE="ac2.23"
  new_sandbox
  extract_fn claude_adopt_commit "$SANDBOX/c.fn.sh" "CLAUDE_ADOPT_KEPT_TOMBS"
  extract_fn claude_adopt_path_ok "$SANDBOX/po.fn.sh" "_type"
  extract_fn claude_adopt_same "$SANDBOX/same.fn.sh" "cmp -s"
  extract_fn assert_under_root "$SANDBOX/aur.fn.sh" "TARGET_ROOT"
  extract_fn _literal_has_prefix "$SANDBOX/lhp.fn.sh" "lhp_esc"
  local P A out T
  P="$(cd "$SANDBOX" && pwd -P)/proj"; A="$SANDBOX/arch"
  T=".claude/skills/.tad-adopt-tomb.9"
  mkdir -p "$P/$T/alex" "$P/$T/gate" "$A/tree/.claude/skills/alex" "$A/tree/.claude/skills/gate"
  printf 'ARCHIVED\n' > "$A/tree/.claude/skills/alex/SKILL.md"; printf 'GATE\n' > "$A/tree/.claude/skills/gate/SKILL.md"
  printf 'CHANGED AFTER THE ARCHIVE\n' > "$P/$T/alex/SKILL.md"; printf 'GATE\n' > "$P/$T/gate/SKILL.md"
  printf '%s\t%s\n%s\t%s\n' ".claude/skills/alex" "$T/alex" ".claude/skills/gate" "$T/gate" > "$A/done.tsv"
  printf '.claude/skills/alex\n.claude/skills/gate\n' > "$A/manifest.txt"
  cat > "$SANDBOX/h.sh" <<HEOF
set -euo pipefail
log_info() { :; }
log_warn() { :; }
claude_adopt_write_report() { return 0; }
. "$SANDBOX/lhp.fn.sh"; . "$SANDBOX/aur.fn.sh"; . "$SANDBOX/po.fn.sh"; . "$SANDBOX/same.fn.sh"; . "$SANDBOX/c.fn.sh"
CLAUDE_PROJECTION=1; CLAUDE_ADOPT_DIR="$A"; CLAUDE_TOMB_SK="$T"; CLAUDE_TOMB_WF=""; CLAUDE_ADOPT_WF_DONE=0
CLAUDE_ADOPT_KEPT_TOMBS=""; TARGET_ROOT="$P"
cd "$P"
claude_adopt_commit
echo "rc=\$?"
printf 'KEPT:%s' "\$CLAUDE_ADOPT_KEPT_TOMBS"
HEOF
  out="$(harness_run "$SANDBOX/h.sh")"
  if printf '%s' "$out" | grep -qF 'rc=0' && [ "$(cat "$P/$T/alex/SKILL.md")" = "CHANGED AFTER THE ARCHIVE" ] && printf '%s' "$out" | grep -qF "$T/alex" \
     && [ ! -e "$P/$T/gate" ] && [ -d "$P/$T" ]; then
    pass "ac2.23: a tombstone that differs from the archive copy is kept and named; an identical one is deleted; commit returns 0"
  else
    fail "ac2.23: commit step mishandled a differing tombstone: $out"
  fi
}

# AC2.24: claude-adopt archives live next to the backups but are never pruned by the retention policy.
case_ac224() {
  CURRENT_CASE="ac2.24"
  new_sandbox
  extract_fn prune_backups "$SANDBOX/pb.fn.sh" "retention"
  local G="$SANDBOX/grp" ts out
  mkdir -p "$G/claude-adopt/20260101_000000/tree"
  printf 'keep me\n' > "$G/claude-adopt/20260101_000000/manifest.txt"
  for ts in 20260102_000000 20260103_000000 20260104_000000 20260105_000000; do
    mkdir -p "$G/$ts"; : > "$G/$ts/manifest.txt"
  done
  cat > "$SANDBOX/h.sh" <<HEOF
set -uo pipefail
log_info() { :; }
log_warn() { printf 'WARN: %s\n' "\$1"; }
. "$SANDBOX/pb.fn.sh"
prune_backups "$G" "$G/20260105_000000"
HEOF
  out="$(harness_run "$SANDBOX/h.sh")"
  if [ -f "$G/claude-adopt/20260101_000000/manifest.txt" ] && [ -d "$G/20260105_000000" ] && [ -d "$G/20260104_000000" ] \
     && [ ! -d "$G/20260102_000000" ] && [ ! -d "$G/20260103_000000" ]; then
    pass "ac2.24: retention trimmed the timestamped backups to 2 and left claude-adopt/ alone"
  else
    fail "ac2.24: retention touched claude-adopt/ or kept the wrong backups: $out"
  fi
}

# AC2.25 (R7): a legacy directory without a SKILL.md twin in the source (_archived) is retired when
# every file is proven by the ledger; one extra user file keeps it exactly as it is.
case_ac225() {
  CURRENT_CASE="ac2.25"
  local rc a
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  ( cd "$REPO" && git archive v2.44.6 .claude/skills/_archived ) | tar -x -C "$TARGET"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  a="$(adopt_archive_dir)"
  if [ "$rc" = "0" ] && [ ! -e "$TARGET/.claude/skills/_archived" ] && grep -qF 'CLAUDE-ADOPTED .claude/skills/_archived' "$SANDBOX/install.log" \
     && [ -n "$a" ] && [ -d "$a/tree/.claude/skills/_archived" ]; then
    pass "ac2.25: pristine _archived (no SKILL.md twin) archived and removed"
  else
    fail "ac2.25: pristine _archived not retired (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  ( cd "$REPO" && git archive v2.44.6 .claude/skills/_archived ) | tar -x -C "$TARGET"
  printf 'mine\n' > "$TARGET/.claude/skills/_archived/my-notes.txt"
  claude_sig "$TARGET" .claude/skills/_archived > "$SNAP/arch.sig"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  claude_sig "$TARGET" .claude/skills/_archived > "$SNAP/arch.sig2"
  if [ "$rc" = "0" ] && cmp -s "$SNAP/arch.sig" "$SNAP/arch.sig2" && [ -f "$TARGET/.claude/skills/_archived/my-notes.txt" ] \
     && grep -qF 'CLAUDE-ADOPT-LEFT .claude/skills/_archived' "$SANDBOX/install.log"; then
    pass "ac2.25: _archived with one extra user file stays byte-identical and is reported as left"
  else
    fail "ac2.25: _archived with a user file was changed or not reported (rc=$rc)"
  fi
  assert_no_network
}

# AC2.26 (R8): a failed install removes the empty directories it created, not the ones the user had.
case_ac226() {
  CURRENT_CASE="ac2.26"
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  mkdir -p "$TARGET/.tad/active/designs" "$TARGET/.tad/evidence/mine-empty"
  chmod 555 "$TARGET/.claude"
  local rc
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  chmod 755 "$TARGET/.claude"
  if [ "$rc" != "0" ] && grep -qF 'CLAUDE-ADOPT-FAILED' "$SANDBOX/install.log"; then pass "ac2.26: install failed as forced"; else fail "ac2.26: install did not fail (rc=$rc)"; fi
  if [ -d "$TARGET/.tad/active/designs" ] && [ -d "$TARGET/.tad/evidence/mine-empty" ]; then
    pass "ac2.26: (i) empty directories the user had before the run survive"
  else
    fail "ac2.26: (i) a user's empty directory was removed"
  fi
  if [ ! -e "$TARGET/.tad/archive" ] && [ ! -e "$TARGET/.tad/active/epics" ] && [ ! -e "$TARGET/.tad/active/playground" ]; then
    pass "ac2.26: (ii) directories created by the failed run are gone"
  else
    fail "ac2.26: (ii) the failed run left its own empty directories"
  fi
  assert_no_network
}

# AC2.27 (R1, R2): without a ledger nothing is called "modified"; the FR9 hint carries --force.
case_ac227() {
  CURRENT_CASE="ac2.27"
  new_sandbox; stage_pruned_source; stage_provenance
  rm -f "$SOURCE/.tad/provenance/claude-legacy.tsv"
  legacy_claude_target || return 0
  local rc
  rc="$(run_install_cc claude-code "$SANDBOX/install.log" --claude-adopt=plan)"
  if [ "$rc" = "0" ] && grep -qF 'CLAUDE-ADOPT-DEGRADED' "$SANDBOX/install.log" && grep -qF 'not checked' "$SANDBOX/install.log" \
     && ! grep -qF 'modified' "$SANDBOX/install.log" && ! grep -qF 'differs from every' "$SANDBOX/install.log"; then
    pass "ac2.27: missing ledger: plan says 'not checked', never 'modified'"
  else
    fail "ac2.27: missing ledger plan wording wrong (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  rc="$(run_install_cc codex "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && grep -qF 'CLAUDE-LEGACY-DETECTED' "$SANDBOX/install.log" && grep -qF -e '--platform claude-code --force' "$SANDBOX/install.log"; then
    pass "ac2.27: CLAUDE-LEGACY-DETECTED suggests --force"
  else
    fail "ac2.27: CLAUDE-LEGACY-DETECTED text wrong (rc=$rc)"
  fi
  assert_no_network
}

# AC2.28 (R5, R6): the notice fires for a settings-only legacy install; leftover tombstones are all listed.
case_ac228() {
  CURRENT_CASE="ac2.28"
  new_sandbox; stage_pruned_source; stage_provenance
  mkdir -p "$TARGET/.tad/active/handoffs"; printf '3.1.0\n' > "$TARGET/.tad/version.txt"
  ( cd "$REPO" && git archive v2.44.6 .claude/settings.json ) | tar -x -C "$TARGET"
  local rc
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && grep -qF 'Possible legacy Claude Code install' "$SANDBOX/install.log" && grep -qF 'hooks only the old file registered' "$SANDBOX/install.log"; then
    pass "ac2.28: notice appears for a settings.json-only legacy install and names the hook replacement"
  else
    fail "ac2.28: notice missing for a settings-only install (rc=$rc)"
  fi
  guarded_cleanup "$SANDBOX"; SANDBOX=""
  new_sandbox; stage_pruned_source; stage_provenance
  legacy_claude_target || return 0
  mkdir -p "$TARGET/.claude/skills/.tad-adopt-tomb.11/alex" "$TARGET/.claude/workflows/.tad-adopt-tomb.12"
  rc="$(run_install_cc claude-code "$SANDBOX/install.log")"
  if [ "$rc" = "0" ] && grep -qF '.tad-adopt-tomb.11' "$SANDBOX/install.log" && grep -qF '.tad-adopt-tomb.12' "$SANDBOX/install.log" \
     && grep -qF 'BEFORE moving anything back' "$SANDBOX/install.log"; then
    pass "ac2.28: every leftover tombstone is listed with the compare-first guidance"
  else
    fail "ac2.28: leftover tombstone listing incomplete (rc=$rc)"
  fi
  assert_no_network
}

# ── runner ───────────────────────────────────────────────────────────
run_case() {
  case "$1" in
    ac2.1) case_ac21 ;;
    ac2.2) case_ac22 ;;
    ac2.3) case_ac23 ;;
    ac2.4) case_ac24 ;;
    ac2.5) case_ac25 ;;
    ac2.6) case_ac26 ;;
    ac2.7) case_ac27 ;;
    ac2.8) case_ac28 ;;
    ac2.9) case_ac29 ;;
    ac2.10) case_ac210 ;;
    ac2.11) case_ac211 ;;
    ac2.12) case_ac212 ;;
    ac2.13) case_ac213 ;;
    ac2.14) case_ac214 ;;
    ac2.15) case_ac215 ;;
    ac2.16) case_ac216 ;;
    ac2.17) case_ac217 ;;
    ac2.18) case_ac218 ;;
    ac2.19) case_ac219 ;;
    ac2.20) case_ac220 ;;
    ac2.21) case_ac221 ;;
    ac2.22) case_ac222 ;;
    ac2.23) case_ac223 ;;
    ac2.24) case_ac224 ;;
    ac2.25) case_ac225 ;;
    ac2.26) case_ac226 ;;
    ac2.27) case_ac227 ;;
    ac2.28) case_ac228 ;;
    r1) case_r1 ;;
    *) echo "fixture: unknown case '$1'" >&2; exit 2 ;;
  esac
  if [ -n "$SANDBOX" ] && [ -d "$SANDBOX" ]; then guarded_cleanup "$SANDBOX" || true; fi
  SANDBOX=""
}

R1_PORCELAIN_BEFORE="$(cd "$REPO" && git status --porcelain 2>&1)" || true
printf '=== installer-data-safety fixture ===\n'
printf '  repo: %s\n' "$REPO"
printf '  case: %s\n' "$CASE"
if [ "$CASE" = "all" ]; then
  run_case ac2.1; run_case ac2.2; run_case ac2.3; run_case ac2.4
  run_case ac2.5; run_case ac2.6; run_case ac2.7; run_case ac2.8
  run_case ac2.9; run_case ac2.10; run_case ac2.11; run_case ac2.12
  run_case ac2.13
  run_case ac2.14; run_case ac2.15; run_case ac2.16; run_case ac2.17
  run_case ac2.18; run_case ac2.19; run_case ac2.20; run_case ac2.21
  run_case ac2.22; run_case ac2.23; run_case ac2.24
  run_case ac2.25; run_case ac2.26; run_case ac2.27; run_case ac2.28
  run_case r1
else
  run_case "$CASE"
fi
printf '\n=== Summary: PASS=%s FAIL=%s ===\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then printf 'VERDICT: FAIL\n'; exit 1; fi
printf 'VERDICT: PASS\n'
exit 0
