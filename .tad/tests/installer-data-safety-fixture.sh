#!/usr/bin/env bash
# installer-data-safety-fixture.sh — sandbox acceptance suite for the installer
# data-safety remainder (FR-1 + FR-5 + F-05/F-06/F-07/F-08 + F-34 + AC2.5).
#
# Usage: bash installer-data-safety-fixture.sh --case ac2.1|...|ac2.12|r1|all
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
    --help|-h) echo "Usage: bash installer-data-safety-fixture.sh --case ac2.1|...|ac2.12|r1|all" >&2; exit 0 ;;
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
  local d="$1"
  if [ -z "$d" ]; then echo "fixture: refusing cleanup of empty path" >&2; return 1; fi
  case "$d" in
    /tmp/tad-ac.*)
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
  cp "$REPO/tad.sh" "$REPO/CLAUDE.md" "$REPO/AGENTS.md" "$SOURCE/"
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
  # .claude/: exactly the three paths the installer reads (skills cluster +
  # settings + workflows). Local/ephemeral trees (worktrees, agents, projects,
  # rules, commands, *.local) are NOT staged.
  mkdir -p "$SOURCE/.claude/skills" "$SOURCE/.claude/workflows"
  cp -R "$REPO/.claude/skills/." "$SOURCE/.claude/skills/"
  cp "$REPO/.claude/settings.json" "$SOURCE/.claude/" 2>/dev/null || true
  if [ -d "$REPO/.claude/workflows" ]; then
    cp -R "$REPO/.claude/workflows/." "$SOURCE/.claude/workflows/" 2>/dev/null || true
  fi
  # .agents mirror (sentinel dir; installer generates the target side).
  mkdir -p "$SOURCE/.agents"
  cp -R "$REPO/.agents/skills" "$SOURCE/.agents/skills"
  # OpenCode updater-only command (exact single-file projection).
  mkdir -p "$SOURCE/.opencode/commands"
  cp "$REPO/.opencode/commands/tad-update.md" "$SOURCE/.opencode/commands/"
  # Sentinel self-check: the staged tree carries the 4 sentinels + version.
  local s
  for s in tad.sh .tad .claude .agents; do
    if [ ! -e "$SOURCE/$s" ]; then echo "fixture: staged source missing sentinel $s" >&2; exit 2; fi
  done
  if [ ! -f "$SOURCE/.tad/version.txt" ]; then echo "fixture: staged source missing version.txt" >&2; exit 2; fi
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
  rc="$(run_install both "$SANDBOX/install.log")"
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
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$TARGET" --platform both --yes >"$SANDBOX/reject.log" 2>&1 ) || rc2=$?
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
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform both --yes --force >"$SANDBOX/prefail.log" 2>&1 ) || rc3=$?
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
# on codex/both follows the documented FR-4b backup-and-install semantics.
matrix_assert() {
  local plat="$1" ok=0
  local f
  for f in .codex/config.toml .codex/prompts/mine.md .gemini/settings.json GEMINI.md; do
    if cmp -s "$SNAP/pre/$f" "$TARGET/$f"; then pass "ac2.x[$plat]: $f byte-identical"; else fail "ac2.x[$plat]: $f MODIFIED"; ok=1; fi
  done
  if [ ! -f "$TARGET/CLAUDE.md" ]; then fail "ac2.x[$plat]: CLAUDE.md missing"; ok=1; fi
  if [ "$plat" = "claude-code" ]; then
    if cmp -s "$SNAP/pre/AGENTS.md" "$TARGET/AGENTS.md"; then pass "ac2.x[$plat]: AGENTS.md byte-identical (not a root file here)"; else fail "ac2.x[$plat]: AGENTS.md MODIFIED"; ok=1; fi
  else
    local bk
    bk="$(ls "$TARGET"/AGENTS.md.pre-tad.* 2>/dev/null | head -1)" || bk=""
    if [ -n "$bk" ] && cmp -s "$SNAP/pre/AGENTS.md" "$bk"; then
      pass "ac2.x[$plat]: AGENTS.md user bytes preserved in $(basename "$bk")"
    else
      fail "ac2.x[$plat]: AGENTS.md user bytes NOT preserved via .pre-tad backup"; ok=1
    fi
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
  rc="$(run_install both "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.2: run rc=0"; else fail "ac2.2: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  matrix_assert both || true
}

# ════════════════════════ AC2.3 (×3 platforms) ════════════════════════
case_ac23() {
  CURRENT_CASE="ac2.3"
  local plat
  for plat in claude-code codex both; do
    new_sandbox
    stage_pruned_source
    plant_user_matrix
    snapshot_target "$SNAP/pre"
    local want rc
    want="$(source_version)"
    rc="$(run_install "$plat" "$SANDBOX/install-$plat.log")"
    if [ "$rc" = "0" ]; then pass "ac2.3[$plat]: run rc=0"; else fail "ac2.3[$plat]: run rc=$rc"; fi
    assert_no_network
    assert_version_proof "$want"
    CURRENT_CASE="ac2.3"
    matrix_assert "$plat" || true
    guarded_cleanup "$SANDBOX"; SANDBOX=""
  done
}

# ════════════════════════ AC2.4 (F-05 marker-less CLAUDE.md) ════════════════════════
case_ac24() {
  CURRENT_CASE="ac2.4"
  new_sandbox
  stage_pruned_source
  printf '# My custom rules\nNo marker here\n' > "$TARGET/CLAUDE.md"
  cp "$TARGET/CLAUDE.md" "$SNAP/claude-orig.md"
  local want rc
  want="$(source_version)"
  rc="$(run_install both "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.4: run rc=0"; else fail "ac2.4: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  local bk
  bk="$(ls "$TARGET"/CLAUDE.md.backup.* 2>/dev/null | head -1)" || bk=""
  if [ -n "$bk" ] && cmp -s "$SNAP/claude-orig.md" "$bk"; then
    pass "ac2.4: marker-less CLAUDE.md preserved in timestamped $(basename "$bk")"
  else
    fail "ac2.4: timestamped backup missing or content differs"
  fi
  if cmp -s "$SOURCE/CLAUDE.md" "$TARGET/CLAUDE.md"; then
    pass "ac2.4: CLAUDE.md now matches source"
  else
    fail "ac2.4: CLAUDE.md does not match source"
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
  rc="$(run_install claude-code "$SANDBOX/install-220.log")"
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
  rc="$(run_install claude-code "$SANDBOX/install-231.log")"
  if [ "$rc" = "0" ]; then pass "ac2.6b: run rc=0"; else fail "ac2.6b: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  local ok26b=0
  for f in AGENTS.md GEMINI.md .codex/config.toml; do
    if cmp -s "$SNAP/pre/$f" "$TARGET/$f"; then :; else fail "ac2.6b: user file $f touched"; ok26b=1; fi
  done
  if [ "$ok26b" = "0" ]; then pass "ac2.6b: user files untouched"; fi
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
  # Upgrade-shaped target (current=2.2.0: every deprecation inert, so the
  # failure lands purely on the cp fault → rollback coverage is isolated).
  mkdir -p "$TARGET/.tad" "$TARGET/.tad/project-knowledge" "$TARGET/.claude/skills/custom" "$TARGET/.codex" "$TARGET/.codex/prompts" "$TARGET/.claude/commands"
  printf '2.2.0\n' > "$TARGET/.tad/version.txt"
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
  # AND a .claude/skills path (the first framework-skills copy — an UNGUARDED
  # `cp -r`, deterministically past NEED_ROLLBACK=1; the `.tad/skills-config`
  # top file and snapshot copies are excluded by the dotted predicate), then
  # pass again so rollback's own copies succeed.
  printf '0\n' > "$SANDBOX/failcp"
  printf '#!/bin/sh\nprintf "%%s\\n" "CP-CALL $*" >> "%s/cp.log"\ncase "$*" in\n  *"%s"*) case "$*" in\n    *.claude/skills*) n=$(cat "%s/failcp"); if [ "$n" = "0" ]; then echo 1 > "%s/failcp"; exit 1; fi ;;\n  esac ;;\nesac\nexec /bin/cp "$@"\n' \
    "$SANDBOX" "$SOURCE" "$SANDBOX" "$SANDBOX" > "$SHIMBIN/cp"
  chmod +x "$SHIMBIN/cp"
  local rc=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform both --yes >"$SANDBOX/install-fail.log" 2>&1 ) || rc=$?
  if [ "$rc" != "0" ]; then pass "ac2.8: faulted run non-zero (rc=$rc)"; else fail "ac2.8: faulted run unexpectedly rc=0"; fi
  # Coverage: every user surface byte-identical after rollback (allowlist: the
  # run log itself lives outside the target; .tad-backup recovery copies are
  # documented below if present).
  local d
  d="$(diff -r "$SNAP/pre" "$TARGET" 2>&1)" || true
  # Filter the known-benign recovery-copy dir (engine backup namespace).
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

  # (b) sed-extracted rollback_on_failure under a FOREIGN cwd with absolute
  # BACKUP_PATH → target restored, foreign cwd untouched (absolutization).
  CURRENT_CASE="ac2.8"
  new_sandbox
  # Extract rollback + its dir-restore helper (BACKUP_PATH_ABS semantics: the
  # dir whose CONTENT is the .tad content, exactly like .tad.backup.TS).
  # Helper fns are load-bearing for the exercised guard path — extract them
  # strictly when present (a half-extracted harness must never go vacuous).
  extract_fn restore_dir_entry "$SANDBOX/rb.fn.sh" "rollback-staging"
  extract_fn rollback_on_failure "$SANDBOX/rb2.fn.sh" "Rollback coverage"
  cat "$SANDBOX/rb2.fn.sh" >> "$SANDBOX/rb.fn.sh"
  if grep -q -e '^_literal_has_prefix() {' "$TADSH"; then
    extract_fn _literal_has_prefix "$SANDBOX/rb-h1.fn.sh" "lhp_esc"
    extract_fn assert_under_root "$SANDBOX/rb-h2.fn.sh" "TARGET_ROOT"
    cat "$SANDBOX/rb-h1.fn.sh" "$SANDBOX/rb-h2.fn.sh" >> "$SANDBOX/rb.fn.sh"
  fi
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/rb.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/rb.log"; }\nrollback_opencode_projection() { printf "OPCODE-ROLLBACK-CALLED\\n" >> "%s/rb.log"; }\ncleanup_source_tree() { printf "CLEANUP-SOURCE-CALLED\\n" >> "%s/rb.log"; }\n' \
    "$SANDBOX" "$SANDBOX" "$SANDBOX" "$SANDBOX" > "$SANDBOX/stubs.sh"
  mkdir -p "$TARGET/.tad" "$SANDBOX/foreign" "$TARGET/.tad.backup.PROBE"
  printf 'ORIGINAL-TAD\n' > "$TARGET/.tad.backup.PROBE/data.txt"
  printf 'HALF-INSTALLED\n' > "$TARGET/.tad/data.txt"
  printf 'FOREIGN-TAD\n' > "$SANDBOX/foreign/marker.txt"
  local rc4=0
  ( cd "$SANDBOX/foreign" && TARGET_ROOT="$TARGET" BACKUP_PATH_ABS="$TARGET/.tad.backup.PROBE" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs.sh"; source "'"$SANDBOX"'/rb.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb.log" 2>&1 ) || rc4=$?
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
  guarded_cleanup "$SANDBOX"; SANDBOX=""

  # (c) ENOSPC injection: restore under `ulimit -f` → backup preserved +
  # explicit failed-state message (calibrated to the host; fallback fault-shim
  # proves the same branch and is logged as such, never silent).
  # Backup layout mirrors production (backup_existing creates .tad.backup.TS
  # UNDER the target) — a sibling-dir backup would trip the under-root guard
  # and pass vacuously, so the probe must not use one.
  CURRENT_CASE="ac2.8"
  new_sandbox
  extract_fn restore_dir_entry "$SANDBOX/rollback.fn.sh" "rollback-staging"
  extract_fn rollback_on_failure "$SANDBOX/rollback3.fn.sh" "Rollback coverage"
  cat "$SANDBOX/rollback3.fn.sh" >> "$SANDBOX/rollback.fn.sh"
  if grep -q -e '^_literal_has_prefix() {' "$TADSH"; then
    extract_fn _literal_has_prefix "$SANDBOX/rb-h1.fn.sh" "lhp_esc"
    extract_fn assert_under_root "$SANDBOX/rb-h2.fn.sh" "TARGET_ROOT"
    cat "$SANDBOX/rb-h1.fn.sh" "$SANDBOX/rb-h2.fn.sh" >> "$SANDBOX/rollback.fn.sh"
  fi
  printf 'log_error() { printf "ERROR: %%s\\n" "$*" >> "%s/rb2.log"; }\nlog_info() { printf "INFO: %%s\\n" "$*" >> "%s/rb2.log"; }\nrollback_opencode_projection() { :; }\ncleanup_source_tree() { :; }\n' \
    "$SANDBOX" "$SANDBOX" > "$SANDBOX/stubs2.sh"
  mkdir -p "$TARGET/.tad" "$TARGET/.tad.backup.BIG"
  head -c 200000 /dev/zero | tr '\0' 'B' > "$TARGET/.tad.backup.BIG/big.bin"
  printf 'HALF\n' > "$TARGET/.tad/data.txt"
  local mech="ulimit"
  if ! ( ulimit -f 20; cp "$TARGET/.tad.backup.BIG/big.bin" "$SANDBOX/probe.bin" 2>/dev/null ); then
    mech="ulimit"
  else
    mech="fault-shim"
  fi
  rm -f "$SANDBOX/probe.bin"
  if [ "$mech" = "ulimit" ]; then
    ( cd "$TARGET" && ulimit -f 20; TARGET_ROOT="$TARGET" BACKUP_PATH_ABS="$TARGET/.tad.backup.BIG" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs2.sh"; source "'"$SANDBOX"'/rollback.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb2.log" 2>&1 ) || true
  else
    printf '#!/bin/sh\nexit 1\n' > "$SHIMBIN/cp"
    chmod +x "$SHIMBIN/cp"
    ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" TARGET_ROOT="$TARGET" BACKUP_PATH_ABS="$TARGET/.tad.backup.BIG" ROLLBACK_SNAP="" MERGE_CREATED_BACKUP="" ROLLBACK_CREATED_TOP="" OPCODE_CREATED_FILE=0 bash -c 'source "'"$SANDBOX"'/stubs2.sh"; source "'"$SANDBOX"'/rollback.fn.sh"; rollback_on_failure' >>"$SANDBOX/rb2.log" 2>&1 ) || true
  fi
  if [ -d "$TARGET/.tad.backup.BIG" ]; then
    pass "ac2.8: ENOSPC ($mech) → backup preserved"
  else
    fail "ac2.8: ENOSPC ($mech) → backup GONE"
  fi
  if grep -qF -e 'PRESERVED' "$SANDBOX/rb2.log"; then
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
  local want rc
  want="$(source_version)"
  rc="$(run_install both "$SANDBOX/install.log")"
  if [ "$rc" = "0" ]; then pass "ac2.9: run rc=0"; else fail "ac2.9: run rc=$rc"; fi
  assert_no_network
  assert_version_proof "$want"
  if cmp -s "$SNAP/user-bak.orig" "$TARGET/CLAUDE.md.bak"; then
    pass "ac2.9: pre-existing user CLAUDE.md.bak byte-identical"
  else
    fail "ac2.9: user CLAUDE.md.bak clobbered"
  fi
  local bk
  bk="$(ls "$TARGET"/CLAUDE.md.backup.* 2>/dev/null | head -1)" || bk=""
  if [ -n "$bk" ]; then
    pass "ac2.9: new backups namespaced+timestamped ($(basename "$bk"))"
  else
    fail "ac2.9: no namespaced backup found"
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
  rc="$(run_install both "$SANDBOX/install.log")"
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
  mkdir -p "$TARGET/.claude/skills" "$TARGET/.tad"
  printf '2.2.0\n' > "$TARGET/.tad/version.txt"
  printf 'LEGACY-ONE\n' > "$TARGET/.claude/skills/legacy-one.md"
  local rc
  rc="$(run_install both "$SANDBOX/install1.log")"
  printf 'LEGACY-TWO\n' > "$TARGET/.claude/skills/legacy-two.md"
  local rc2=0
  ( cd "$TARGET" && PATH="$SHIMBIN:$PATH" bash "$TADSH" --source "$SOURCE" --platform both --yes --force >"$SANDBOX/install2.log" 2>&1 ) || rc2=$?
  local want
  want="$(source_version)"
  if [ "$rc" = "0" ] && [ "$rc2" = "0" ]; then pass "ac2.11: integration double-run rc=0/0"; else fail "ac2.11: integration rcs $rc/$rc2"; fi
  assert_version_proof "$want"
  local idirs
  idirs="$(ls -d "$TARGET"/.claude/skills/_archived.* 2>/dev/null | LC_ALL=C wc -l | tr -d ' ')"
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

# ════════════════════════ R1 (scope fence) ════════════════════════
case_r1() {
  CURRENT_CASE="r1"
  printf '  fence report (informational — pre-existing track dirt excluded by path):\n'
  ( cd "$REPO" && git status --porcelain ) || true
  local bad=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    local f
    f="$(printf '%s' "$line" | sed -e 's/^...//')"
    case "$f" in
      tad.sh|.tad/tests/installer-data-safety-fixture.sh|.tad/tests/fixtures/*|.tad/hooks/lib/release-verify.sh|.tad/tests/upgrade-acceptance.sh) ;;
      *) printf '  ⚠️  out-of-fence change: %s\n' "$line"; bad=1 ;;
    esac
  done <<< "$(cd "$REPO" && git status --porcelain)"
  if [ "$bad" = "0" ]; then pass "r1: working tree matches §7 fence"; else fail "r1: out-of-fence entries present (see above)"; fi
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
    r1) case_r1 ;;
    *) echo "fixture: unknown case '$1'" >&2; exit 2 ;;
  esac
  if [ -n "$SANDBOX" ] && [ -d "$SANDBOX" ]; then guarded_cleanup "$SANDBOX" || true; fi
  SANDBOX=""
}

printf '=== installer-data-safety fixture ===\n'
printf '  repo: %s\n' "$REPO"
printf '  case: %s\n' "$CASE"
if [ "$CASE" = "all" ]; then
  run_case ac2.1; run_case ac2.2; run_case ac2.3; run_case ac2.4
  run_case ac2.5; run_case ac2.6; run_case ac2.7; run_case ac2.8
  run_case ac2.9; run_case ac2.10; run_case ac2.11; run_case ac2.12
  run_case r1
else
  run_case "$CASE"
fi
printf '\n=== Summary: PASS=%s FAIL=%s ===\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then printf 'VERDICT: FAIL\n'; exit 1; fi
printf 'VERDICT: PASS\n'
exit 0
