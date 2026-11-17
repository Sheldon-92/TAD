#!/bin/bash
# failure-path-fixture.sh — the installer's three failure outputs (write, sync, rollback)
# under injected faults, asserted line by line, each against a variant that lacks its line.
#
# Usage:
#   /bin/bash .tad/tests/failure-path-fixture.sh --case write|sync|rollback|snapleft|snapkeep|snapincomplete|all
#                                                [--tadsh <path>] [--keep-log <dir>]
#   --case      required; `all` runs write, sync, rollback, snapleft, snapkeep, snapincomplete in that order
#               (the last three: report-upgrades Phase 5 — the rollback snapshot's disposal)
#   --tadsh     installer to run (default: the repo's tad.sh). With it given, each named
#               case runs once against that file and no built-in variant runs.
#   --keep-log  an existing directory; each case's installer log is copied there
#               (<case>.log, and <case>.variant.log for the built-in variant runs).
#               Give a `mktemp -d` directory outside any synced folder: logs hold absolute paths.
#
# Output: `CASE <name> PASS|FAIL` per case run against the real (or given) installer,
# `VARIANT <name> FAILS-AS-EXPECTED|PASSED` per built-in variant run, and the last line
# `FAILURE-PATH-FIXTURE: PASS|FAIL`. Exit 0 pass, 1 fail, 2 setup error (with a reason line).
#
# Safety (hard steps; each failure exits 2 before any installer run):
#   1. one sandbox from `mktemp -d`, resolved once with `pwd -P` (SB); every comparison uses SB;
#   2. SB is refused when empty, `/`, the repo, an ancestor of the repo, $HOME or an ancestor of it,
#      or inside the repo (a TMPDIR inside the repo is refused before anything is created), or when
#      its path holds `"`, `$`, a backtick or a backslash (the generated shims embed it in double quotes);
#   3. a cleanup trap on EXIT INT TERM HUP removes exactly SB (a TERM, INT or HUP takes effect when the
#      running installer call returns, which can take minutes; a SIGKILL leaves SB in the temp root);
#   4. every installer run goes through run_installer (nothing else calls an installer), with
#      HOME, TMPDIR and TAD_BACKUP_ROOT inside SB and the cwd checked to be the sandbox target;
#   5. every path the fixture compares is resolved physically before a `SB/` prefix test.
# This file calls no git and no network tool; git and curl are shimmed (exit 1) for the installer.
# The installer it runs does probe git (tad.sh:968, 6482): the "zero git calls" result of the no-git
# run rests on that git shim being first on the installer's PATH (run_installer). Removing or
# bypassing the shim makes tad.sh call the real git.
# bash 3.2 / BSD tools.

# --- environment sanitising (report-upgrades Phase 5, rework 2; ENV-SANITISE) -----------------------------
# This script trusts nothing it inherits; this block runs before any other command. Two inputs act before
# its first line and no script can close them, so they are named here instead: BASH_ENV (the file runs
# before line 1) and SHELLOPTS=xtrace with a PS4 that runs a command (the trace of line 1). Both are the
# caller running code of their own. Signals ignored when the script starts stay ignored (bash cannot reset
# them). The assignment below puts bash in posix mode, where `unset`, `set` and `exec` are found before any
# function of that name, so every inherited (exported) function can be removed; then posix mode is left.
# A third such input: SHELLOPTS=noexec or SHELLOPTS=onecmd (bash then runs no command, or only one): the script prints nothing; read an empty output as not run, never as a result.
POSIXLY_CORRECT=1
\set +e +a +k +x +v -f  # ENV-SET
\unset -f unset set builtin command declare read enable shopt unalias exec eval trap kill wait cd pwd printf echo test type local return exit export source true false 2>/dev/null
for _sz in $(\declare -F); do case "$_sz" in declare|-f|-fx|-fr|-frx) ;; *) \unset -f -- "$_sz" 2>/dev/null ;; esac; done  # ENV-NO-FUNCS
\unalias -a 2>/dev/null
\enable cd pwd printf echo read test '[' kill wait type command builtin local declare shopt unalias trap eval exec set unset export source true false 2>/dev/null
IFS=' 	
'
\unset CDPATH GLOBIGNORE GREP_OPTIONS GREP_COLOR GREP_COLORS CLICOLOR CLICOLOR_FORCE LSCOLORS ENV BASH_XTRACEFD FUNCNEST BASH_COMPAT EXECIGNORE  # ENV-UNSET
\set +o pipefail +C +b +E +T
for _sz in nullglob failglob nocaseglob nocasematch dotglob extglob expand_aliases xpg_echo; do \shopt -u "$_sz" 2>/dev/null; done
\unset POSIXLY_CORRECT _sz
\set +o posix
for _sz in $(\declare -F); do case "$_sz" in declare|-f|-fx|-fr|-frx) ;; *) \unset -f -- "$_sz" 2>/dev/null ;; esac; done  # ENV-NO-FUNCS-2
\set +f  # ENV-GLOB
\unset _sz
\exec 0</dev/null
{ \exec 3>&1; } 2>/dev/null || { printf '%s\n' "${0##*/}: stdout is closed; nothing done" >&2; exit 2; }
\exec 3>&-
# --- end of the sanitising block ---------------------------------------------------------------------------
set -u
# The fixture's own tools (rm, mktemp, grep, sed, awk …) run from the system directories only; the
# installer runs with the shim directory first and then the caller's PATH, as before (rework 1, P0-1).
USER_PATH="${PATH:-}"
PATH=/usr/bin:/bin:/usr/sbin:/sbin
NL='
'
case "${TMPDIR:-}" in /*) ;; *) TMPDIR=/tmp ;; esac  # a relative or empty TMPDIR is not used (rework 2)
_rd() { # one absolute directory line or nothing (rework 2: CDPATH is cleared above; an answer with a newline is refused)
  local r; r="$(cd -P -- "$1" > /dev/null 2>&1 && pwd -P && printf x)" || return 1
  r="${r%x}"; r="${r%"$NL"}"; case "$r" in /*) ;; *) return 1 ;; esac; case "$r" in *"$NL"*) return 1 ;; esac; printf '%s' "$r"; }

REPO="$(_rd "$(dirname "$0")/../..")" || { echo "failure-path-fixture: cannot resolve the repo root"; exit 2; }
DERIVE="$REPO/.tad/hooks/lib/derive-sync-set.sh"

CASE_ARG=""
TADSH_ARG=""
KEEP_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --case) [ $# -ge 2 ] || { echo "failure-path-fixture: --case needs a value"; exit 2; }; CASE_ARG="$2"; shift 2 ;;
    --tadsh) [ $# -ge 2 ] || { echo "failure-path-fixture: --tadsh needs a value"; exit 2; }; TADSH_ARG="$2"; shift 2 ;;
    --keep-log) [ $# -ge 2 ] || { echo "failure-path-fixture: --keep-log needs a value"; exit 2; }; KEEP_DIR="$2"; shift 2 ;;
    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "failure-path-fixture: unknown argument: $1"; exit 2 ;;
  esac
done

case "$CASE_ARG" in
  write|sync|rollback|snapleft|snapkeep|snapincomplete) CASES="$CASE_ARG" ;;
  all) CASES="write sync rollback snapleft snapkeep snapincomplete" ;;
  "") echo "failure-path-fixture: --case is required (write|sync|rollback|snapleft|snapkeep|snapincomplete|all)"; exit 2 ;;
  *) echo "failure-path-fixture: unknown case: $CASE_ARG"; exit 2 ;;
esac

if [ -n "$TADSH_ARG" ]; then
  [ -f "$TADSH_ARG" ] || { echo "failure-path-fixture: --tadsh file not found: $TADSH_ARG"; exit 2; }
  INSTALLER="$(_rd "$(dirname "$TADSH_ARG")")/$(basename "$TADSH_ARG")" || { echo "failure-path-fixture: cannot resolve --tadsh"; exit 2; }
  VARIANTS=0
else
  [ -f "$REPO/tad.sh" ] || { echo "failure-path-fixture: no tad.sh at the repo root ($REPO)"; exit 2; }
  INSTALLER="$REPO/tad.sh"
  VARIANTS=1
fi
if [ -n "$KEEP_DIR" ]; then
  [ -d "$KEEP_DIR" ] || { echo "failure-path-fixture: --keep-log directory does not exist: $KEEP_DIR"; exit 2; }
  KEEP_DIR="$(_rd "$KEEP_DIR")" || { echo "failure-path-fixture: cannot resolve --keep-log"; exit 2; }
fi
[ -f "$DERIVE" ] || { echo "failure-path-fixture: missing $DERIVE"; exit 2; }
for t in /bin/cp /bin/mkdir; do
  [ -x "$t" ] || { echo "failure-path-fixture: $t not found (the shims call the real tool by absolute path)"; exit 2; }
done

# --- sandbox: hard steps 1-3 ---------------------------------------------------------------
SB=""
SB_MADE=""
cleanup() {
  if [ -n "$SB_MADE" ] && [ "$SB" = "$SB_MADE" ] && [ -d "$SB_MADE" ]; then
    chmod -R u+w "$SB_MADE" 2>/dev/null
    rm -rf "$SB_MADE"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

# Refuse a temp root inside the repo before anything is created there (mktemp would write into the repo).
_td="$(_rd "${TMPDIR:-/tmp}")" || { echo "failure-path-fixture: cannot resolve the temp root ${TMPDIR:-/tmp}"; exit 2; }
case "$_td/" in "$REPO/"*) echo "failure-path-fixture: refusing temp root $_td: it is inside the repo (nothing created)"; exit 2 ;; esac
_mk="$(mktemp -d "${TMPDIR:-/tmp}/tad-fp.XXXXXX")" || { echo "failure-path-fixture: mktemp -d failed"; exit 2; }
SB="$(_rd "$_mk")" || { echo "failure-path-fixture: cannot resolve the sandbox $_mk"; rmdir "$_mk" 2>/dev/null; exit 2; }
SB_MADE="$SB"

refuse() { echo "failure-path-fixture: refusing sandbox $SB: $1"; SB_MADE=""; rmdir "$_mk" 2>/dev/null; exit 2; }
[ -n "$SB" ] || refuse "empty path"
[ "$SB" != "/" ] || refuse "it is /"
[ "$SB" != "$REPO" ] || refuse "it is the repo"
case "$REPO/" in "$SB/"*) refuse "it is an ancestor of the repo" ;; esac
case "$SB/" in "$REPO/"*) refuse "it is inside the repo" ;; esac
case "$SB" in *'"'*|*'$'*|*'`'*|*'\'*) refuse "its path holds a double quote, \$, a backtick or a backslash (the generated shims embed it in double quotes)" ;; esac
HOME_P=""
if [ -n "${HOME:-}" ] && [ -d "$HOME" ]; then HOME_P="$(_rd "$HOME")" || HOME_P=""; fi
if [ -n "$HOME_P" ]; then
  [ "$SB" != "$HOME_P" ] || refuse "it is \$HOME"
  case "$HOME_P/" in "$SB/"*) refuse "it is an ancestor of \$HOME" ;; esac
fi

SOURCE="$SB/source"
BIN="$SB/bin"
/bin/mkdir -p "$SOURCE" "$BIN" "$SB/home" "$SB/tmp" "$SB/backups" "$SB/logs" || { echo "failure-path-fixture: cannot create the sandbox layout"; exit 2; }

under_sb() { case "$1/" in "$SB/"*) return 0 ;; esac; return 1; }

# --- hard step 4: the one installer invocation ------------------------------------------------
# run_installer <installer> <target> <log> <tmpdir> — prints the installer's exit code. <tmpdir> is the
# run's own TMPDIR (report-upgrades Phase 5, D11: one fresh directory per installer run).
run_installer() {
  local inst="$1" target="$2" log="$3" tmpd="$4" rc=0
  under_sb "$target" || { echo "failure-path-fixture: target outside the sandbox: $target" >&2; printf 'refused'; return 0; }
  [ -d "$target" ] || { echo "failure-path-fixture: target missing: $target" >&2; printf 'refused'; return 0; }
  case "$tmpd/" in "$REPO/"*) echo "failure-path-fixture: refusing a run TMPDIR inside the repo: $tmpd" >&2; printf 'refused'; return 0 ;; esac
  under_sb "$tmpd" && [ -d "$tmpd" ] || { echo "failure-path-fixture: run TMPDIR missing or outside the sandbox: $tmpd" >&2; printf 'refused'; return 0; }
  ( cd "$target" || exit 2; [ "$(pwd -P)" = "$target" ] || exit 2; HOME="$SB/home" TMPDIR="$tmpd" TAD_BACKUP_ROOT="$SB/backups" PATH="$BIN:$USER_PATH" /bin/bash "$inst" --source "$SOURCE" --platform codex --yes ) < /dev/null > "$log" 2>&1 || rc=$?
  printf '%s' "$rc"
}

# --- shims ----------------------------------------------------------------------------------
# git and curl: log their arguments, exit 1. Present for every installer run.
printf '#!/bin/sh\nprintf "%%s\\n" "git $*" >> "%s"\nexit 1\n' "$SB/git.log" > "$BIN/git"
printf '#!/bin/sh\nprintf "%%s\\n" "curl $*" >> "%s"\nexit 1\n' "$SB/curl.log" > "$BIN/curl"
chmod +x "$BIN/git" "$BIN/curl"
: > "$SB/git.log"; : > "$SB/curl.log"

clear_case_shims() { rm -f "$BIN/cp" "$BIN/mkdir" "$BIN/rm" "$BIN/cmp" "$SB"/marker.*; }

# arm_case <case> — write the case's cp or mkdir shim (real tool by absolute path when it
# does not fire; a marker file when it fires).
arm_case() {
  clear_case_shims
  case "$1" in
    write)
      cat > "$BIN/cp" <<EOF
#!/bin/sh
for a in "\$@"; do last="\$a"; done
case "\$last" in
  *fp-write.md.tad-new.*) echo hit >> "$SB/marker.write"; echo "FPMARK-write cp: injected failure" >&2; exit 1 ;;
esac
exec /bin/cp "\$@"
EOF
      chmod +x "$BIN/cp" ;;
    sync)
      cat > "$BIN/mkdir" <<EOF
#!/bin/sh
for a in "\$@"; do last="\$a"; done
case "\$last" in
  .tad/templates) echo hit >> "$SB/marker.sync"; echo "FPMARK-sync mkdir: injected" >&2; exit 1 ;;
esac
exec /bin/mkdir "\$@"
EOF
      chmod +x "$BIN/mkdir" ;;
    rollback)
      cat > "$BIN/cp" <<EOF
#!/bin/sh
for a in "\$@"; do last="\$a"; done
case "\$last" in
  *fp-write.md.tad-new.*) echo hit >> "$SB/marker.write"; echo "FPMARK-write cp: injected failure" >&2; exit 1 ;;
  *fp-rb.md.rollback-staging) echo hit >> "$SB/marker.rollback"; echo "FPMARK-rb cp: injected failure" >&2; exit 1 ;;
esac
exec /bin/cp "\$@"
EOF
      chmod +x "$BIN/cp" ;;
    snapleft|snapkeep)
      cat > "$BIN/cp" <<EOF
#!/bin/sh
for a in "\$@"; do last="\$a"; done
case "\$last" in
  *fp-write.md.tad-new.*) echo "FPMARK-write cp: injected failure" >&2; exit 1 ;;
esac
exec /bin/cp "\$@"
EOF
      chmod +x "$BIN/cp"
      if [ "$1" = "snapleft" ]; then
        cat > "$BIN/rm" <<EOF
#!/bin/sh
for a in "\$@"; do
  case "\$a" in
    */tad-rollback.*/*) ;;
    */tad-rollback.*) echo "FPMARK-snapleft" >> "$SB/marker.snapleft"; exit 1 ;;
  esac
done
exec /bin/rm "\$@"
EOF
        chmod +x "$BIN/rm"
      else
        cat > "$BIN/cmp" <<EOF
#!/bin/sh
for a in "\$@"; do
  case "\$a" in */.pre-brain-index) echo hit >> "$SB/marker.snapkeep"; exit 1 ;; esac
done
exec /usr/bin/cmp "\$@"
EOF
        chmod +x "$BIN/cmp"
      fi ;;
    snapincomplete)
      cat > "$BIN/cp" <<EOF
#!/bin/sh
for a in "\$@"; do last="\$a"; done
case "\$last" in
  */tad-rollback.*/AGENTS.md) echo "FPMARK-snapinc" >> "$SB/marker.snapincomplete"; echo "FPMARK-snapinc cp: injected failure" >&2; exit 1 ;;
esac
exec /bin/cp "\$@"
EOF
      chmod +x "$BIN/cp" ;;
  esac
}

copy_tree() { # copy_tree <src dir> <dst dir> — clone where the filesystem allows it
  /bin/mkdir -p "$2" || return 1
  /bin/cp -Rc "$1/." "$2/" 2>/dev/null || /bin/cp -R "$1/." "$2/"
}

# --- source staging (the installer-data-safety-fixture recipe, rewritten; never the live repo) --
stage_source() {
  /bin/cp "$REPO/tad.sh" "$REPO/AGENTS.md" "$SOURCE/" || return 1
  /bin/mkdir -p "$SOURCE/.tad" || return 1
  local f bn d
  for f in "$REPO"/.tad/*; do
    [ -f "$f" ] || continue
    bn="$(basename "$f")"
    [ "$bn" = "sync-registry.yaml" ] && continue
    /bin/cp "$f" "$SOURCE/.tad/" || return 1
  done
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    if [ -d "$REPO/.tad/$d" ]; then copy_tree "$REPO/.tad/$d" "$SOURCE/.tad/$d" || return 1; fi
  done <<EOF
$(/bin/bash "$DERIVE" --dirs "$REPO")
EOF
  copy_tree "$REPO/.agents/skills" "$SOURCE/.agents/skills" || return 1
  /bin/mkdir -p "$SOURCE/.opencode/commands" "$SOURCE/.opencode/plugins" "$SOURCE/.cursor" || return 1
  /bin/cp "$REPO/.opencode/commands/tad-update.md" "$SOURCE/.opencode/commands/" || return 1
  /bin/cp "$REPO/.opencode/plugins/tad-hooks.ts" "$SOURCE/.opencode/plugins/" || return 1
  /bin/cp "$REPO/.cursor/hooks.json" "$SOURCE/.cursor/" || return 1
  [ -f "$SOURCE/.tad/version.txt" ] || return 1
  printf 'fp-rb OLD\n' > "$SOURCE/.tad/fp-rb.md"
}

next_version() {
  local v="$1" ma mi pa
  printf '%s' "$v" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || return 1
  ma="${v%%.*}"; pa="${v##*.}"; mi="${v#*.}"; mi="${mi%.*}"
  printf '%s.%s.%s' "$ma" "$mi" "$((pa + 1))"
}

# --- assertions -----------------------------------------------------------------------------
FAILS=""
note_fail() { FAILS="${FAILS}${FAILS:+; }$1"; }
# has_fixed <log> <text> — a line contains the fixed text (prefixes such as `✗ `/`ℹ ` ignored).
has_fixed() { grep -qF -e "$2" "$1"; }
# has_parts <log> <part1> <part2> — one line holds part1 and, later on it, part2 (a `<…>` between).
has_parts() { P1="$2" P2="$3" awk 'BEGIN{a=ENVIRON["P1"]; b=ENVIRON["P2"]} { i=index($0,a); if (i>0 && index(substr($0,i+length(a)),b)>0) {f=1; exit} } END{exit f?0:1}' "$1"; }
line_of() { grep -nF -e "$2" "$1" | head -1 | cut -d: -f1; }
before() { # before <log> <first> <second>
  local a b; a="$(line_of "$1" "$2")"; b="$(line_of "$1" "$3")"
  [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]
}
target_version() { head -1 "$1/.tad/version.txt" 2>/dev/null | tr -d '[:space:]'; }
resolve_path() { # physical path of an existing file or dir, else empty
  if [ -d "$1" ]; then _rd "$1"; elif [ -e "$1" ] || [ -L "$1" ]; then printf '%s/%s' "$(_rd "$(dirname "$1")")" "$(basename "$1")"; fi
}

W_LINE='INSTALL-WRITE-FAILED step=copy file=.tad/templates/fp-write.md reason=FPMARK-write cp: injected failure'
S_LINE='INSTALL-EXIT step=sync-tad-dirs status=1 last-command=mkdir -p ".tad/$dir" (unexpanded source text) reason=not captured'
R_PART1='Rollback FAILED for .tad/fp-rb.md (stage, rename, or verify failed) — backup PRESERVED at '
R_PART2='; restore manually.'
ROLLING='Installation failed. Rolling back...'
INTACT_STATE='PROJECT-STATE: intact — the project matches its pre-run state'
INTACT_ACTION='ACTION-NEEDED: no — nothing to do'
INTACT_RECOVER='RECOVER-FROM: not needed'

closing_intact() {
  has_fixed "$1" "$INTACT_STATE" || note_fail "no '$INTACT_STATE'"
  has_fixed "$1" "$INTACT_ACTION" || note_fail "no '$INTACT_ACTION'"
  has_fixed "$1" "$INTACT_RECOVER" || note_fail "no '$INTACT_RECOVER'"
}

# assert_case <case> <rc> <log> <target> — fills FAILS; KEYFAIL=1 when the case's own key line is missing.
KEYFAIL=0
assert_case() {
  local c="$1" rc="$2" log="$3" t="$4" n p rp bad
  FAILS=""; KEYFAIL=0
  [ "$rc" = "1" ] || note_fail "exit $rc, expected 1"
  [ -s "$SB/marker.$c" ] || note_fail "no witness: the injected $c fault never fired"
  [ ! -s "$SB/curl.log" ] || note_fail "curl was called"
  [ "$(target_version "$t")" = "$PRE_VERSION" ] || note_fail "version is $(target_version "$t"), expected the pre-run $PRE_VERSION"
  case "$c" in
    write)
      if has_fixed "$log" "$W_LINE"; then
        before "$log" "$W_LINE" "$ROLLING" || note_fail "the INSTALL-WRITE-FAILED line is not before '$ROLLING'"
      else KEYFAIL=1; note_fail "no '$W_LINE'"; fi
      has_fixed "$log" "INSTALL-EXIT" && note_fail "an INSTALL-EXIT line after a named failure"
      closing_intact "$log"
      [ ! -e "$t/.tad/templates/fp-write.md" ] || note_fail ".tad/templates/fp-write.md exists after the rollback" ;;
    sync)
      if has_fixed "$log" "$S_LINE"; then
        before "$log" "$S_LINE" "$ROLLING" || note_fail "the INSTALL-EXIT line is not before '$ROLLING'"
      else KEYFAIL=1; note_fail "no '$S_LINE'"; fi
      has_fixed "$log" "INSTALL-WRITE-FAILED" && note_fail "an INSTALL-WRITE-FAILED line in the sync case"
      closing_intact "$log" ;;
    rollback)
      has_fixed "$log" "$W_LINE" || note_fail "no '$W_LINE'"
      has_parts "$log" "$R_PART1" "$R_PART2" || { KEYFAIL=1; note_fail "no 'Rollback FAILED for .tad/fp-rb.md (stage, rename, or verify failed) — backup PRESERVED at <path>; restore manually.'"; }
      grep -F 'ROLLBACK-RESULT: partial ' "$log" | grep -qF ' failed=1 ' || note_fail "no 'ROLLBACK-RESULT: partial … failed=1 …' line"
      has_fixed "$log" 'MANUAL-RECOVERY: this rollback did not fully restore the project — recover by hand from the preserved copies below.' || note_fail "no MANUAL-RECOVERY line"
      has_fixed "$log" 'failed entries: .tad/fp-rb.md' || note_fail "no 'failed entries: .tad/fp-rb.md'"
      has_fixed "$log" 'PROJECT-STATE: not-intact — the rollback could not restore everything; the failed entries are listed in the line above and in the result line' || note_fail "no PROJECT-STATE not-intact line"
      has_fixed "$log" 'ACTION-NEEDED: yes — recover the failed entries from the paths below' || note_fail "no ACTION-NEEDED yes line"
      n=0; bad=0
      while IFS= read -r p; do
        [ -n "$p" ] || continue
        n=$((n + 1))
        rp="$(resolve_path "$p")"
        if [ -z "$rp" ]; then bad=1; note_fail "RECOVER-FROM path does not exist: $p"
        elif ! under_sb "$rp"; then bad=1; note_fail "RECOVER-FROM path outside the sandbox: $rp"; fi
      done <<EOF
$(grep -F 'RECOVER-FROM: ' "$log" | sed 's/^.*RECOVER-FROM: //')
EOF
      [ "$n" -ge 1 ] || note_fail "no 'RECOVER-FROM: <path>' line"
      [ "$(cat "$t/.tad/fp-rb.md" 2>/dev/null)" = "fp-rb NEW" ] || note_fail ".tad/fp-rb.md does not hold the NEW bytes" ;;
    snapleft)
      has_fixed "$log" "$W_LINE" || note_fail "no '$W_LINE'"
      closing_intact "$log" ;;
    snapkeep)
      has_fixed "$log" "$W_LINE" || note_fail "no '$W_LINE'"
      has_fixed "$log" 'PROJECT-STATE: intact-with-exceptions — the project was restored except the exceptions named below' || note_fail "no PROJECT-STATE intact-with-exceptions line"
      has_fixed "$log" 'ACTION-NEEDED: no — only generated files or recovery copies are named; nothing needs restoring' || note_fail "no ACTION-NEEDED line for generated files" ;;
    snapincomplete)
      has_fixed "$log" 'exception: rollback snapshot incomplete — nothing was restored, removed or verified' || note_fail "no 'exception: rollback snapshot incomplete' line"
      has_fixed "$log" 'PROJECT-STATE: intact-with-exceptions — the run stopped before its first project write' || note_fail "no PROJECT-STATE line for a stop before the first write"
      has_fixed "$log" 'ACTION-NEEDED: no — the project was not touched; rerun after the named fault is fixed' || note_fail "no ACTION-NEEDED line for an untouched project"
      has_fixed "$log" "$INTACT_RECOVER" || note_fail "no '$INTACT_RECOVER'" ;;
  esac
  tmp_state "$c" "$log"
  [ -z "$FAILS" ]
}

# tmp_state <case> <log> (report-upgrades Phase 5, D11): what the run's own TMPDIR ($LAST_TMP) holds.
# A failure here is the key failure for the snapshot cases and for the write-nodispose variant.
LEFT_TAIL=" — could not be deleted (exit 1); nothing below sends you to it and nothing in it is needed; it holds copies of this project's configuration files; delete that directory yourself when convenient"
tmp_state() {
  local c="$1" log="$2" names n want="" ll
  if [ -z "${LAST_TMP:-}" ] || [ ! -d "$LAST_TMP" ] || ! under_sb "$LAST_TMP"; then
    echo "  $c: temp dir of this run: ${LAST_TMP:-unset} (unset, missing or outside the sandbox)"; KEYFAIL=1; note_fail "the run's temp dir cannot be read"; return
  fi
  names="$(ls -A "$LAST_TMP" | grep '^tad-rollback\.' | tr '\n' ' ' | sed 's/ $//')"
  n="$(ls -A "$LAST_TMP" | grep -c '^tad-rollback\.')"
  echo "  $c: temp dir of this run ${LAST_TMP#"$SB"/} holds: ${names:-no tad-rollback.*}"
  case "$c" in
    write|sync|snapincomplete)
      [ "$n" = "0" ] || { KEYFAIL=1; note_fail "the run's temp dir holds $n tad-rollback.*, expected none"; }
      if has_fixed "$log" 'ROLLBACK-SNAPSHOT-LEFT:'; then KEYFAIL=1; note_fail "a ROLLBACK-SNAPSHOT-LEFT line"; fi ;;
    rollback) want="$(grep '^RECOVER-FROM: ' "$log" | sed 's/^RECOVER-FROM: //' | grep -F -e "$LAST_TMP/tad-rollback." | head -2)" ;;
    snapkeep) want="$(sed -n 's/^exception: .tad\/brain-index.md differs from its pre-run bytes (a generated file; the pre-run copy is at \(.*\)\/.pre-brain-index)$/\1/p' "$log" | head -2)"
      if [ -z "$want" ] || [ ! -f "$want/.pre-brain-index" ]; then KEYFAIL=1; note_fail "the path the exception names does not exist: ${want:-none}"; fi ;;
    snapleft)
      ll="$(grep -F 'ROLLBACK-SNAPSHOT-LEFT: ' "$log" | head -1)"
      want="${ll#*ROLLBACK-SNAPSHOT-LEFT: }"
      case "$want" in *"$LEFT_TAIL") want="${want%"$LEFT_TAIL"}" ;; *) want=""; KEYFAIL=1; note_fail "no ROLLBACK-SNAPSHOT-LEFT line in the expected wording" ;; esac
      before "$log" 'ROLLBACK-SNAPSHOT-LEFT: ' 'PROJECT-STATE: ' || note_fail "the LEFT line is not before PROJECT-STATE" ;;
  esac
  case "$c" in
    rollback|snapkeep|snapleft)
      if [ "$n" != "1" ] || [ -z "$want" ] || [ "$(printf '%s\n' "$want" | wc -l | tr -d ' ')" != "1" ] || [ "$want" != "$LAST_TMP/$names" ] || [ ! -d "$want" ]; then
        KEYFAIL=1; note_fail "the run's temp dir does not hold exactly the one snapshot its output names (holds: ${names:-none}; named: ${want:-none})"
      fi ;;
  esac
}

# --- variants -------------------------------------------------------------------------------
key_text() {
  case "$1" in
    write) printf '%s' 'INSTALL-WRITE-FAILED step=' ;;
    sync) printf '%s' 'INSTALL-EXIT step=' ;;
    rollback) printf '%s' 'Rollback FAILED for .tad/$_rb_e (stage, rename, or verify failed)' ;;
  esac
}
build_variant() { # build_variant <case> — prints the variant path, or a reason on stderr and nothing
  local c="$1" k v ko kn lo ln
  k="$(key_text "$c")"; v="$SB/variant-$c.sh"
  ko="$(grep -cF -e "$k" "$INSTALLER")"; lo="$(wc -l < "$INSTALLER" | tr -d ' ')"
  [ "$ko" -ge 1 ] || { echo "failure-path-fixture: key text of $c not found in the installer: $k" >&2; return 1; }
  grep -vF -e "$k" "$INSTALLER" > "$v"
  kn="$(grep -cF -e "$k" "$v")"; ln="$(wc -l < "$v" | tr -d ' ')"
  [ "$kn" = "0" ] || { echo "failure-path-fixture: variant $c still holds its key text" >&2; return 1; }
  [ "$ln" = "$((lo - ko))" ] || { echo "failure-path-fixture: variant $c has $ln lines, expected $((lo - ko))" >&2; return 1; }
  /bin/bash -n "$v" 2>/dev/null || { echo "failure-path-fixture: variant $c fails bash -n" >&2; return 1; }
  printf '%s' "$v"
}

# build_variant_marker <name> <marker text> [<replacement line>] — the installer with the one line that holds
# <marker text> deleted (or replaced); prints the variant path (report-upgrades Phase 5).
build_variant_marker() {
  local name="$1" m="$2" v="$SB/variant-$1.sh" n
  n="$(grep -cF -e "$m" "$INSTALLER")"
  [ "$n" = "1" ] || { echo "failure-path-fixture: variant $name: marker '$m' found $n times" >&2; return 1; }
  if [ $# -ge 3 ]; then M="$m" RP="$3" awk 'index($0, ENVIRON["M"]) { print ENVIRON["RP"]; next } { print }' "$INSTALLER" > "$v"
  else grep -vF -e "$m" "$INSTALLER" > "$v"; fi
  [ "$(grep -cF -e "$m" "$v")" = "0" ] || { echo "failure-path-fixture: variant $name still holds its marker" >&2; return 1; }
  /bin/bash -n "$v" 2>/dev/null || { echo "failure-path-fixture: variant $name fails bash -n" >&2; return 1; }
  printf '%s' "$v"
}
variant_for() { # variant_for <case> — the variants run after that case
  case "$1" in
    write) printf '%s' "write write-nodispose" ;;
    rollback) printf '%s' "rollback rollback-keepfailed" ;;
    *) printf '%s' "$1" ;;
  esac
}

RUN_N=0
# run_one <case> <installer> <label> — fresh target from the base, armed run; prints nothing,
# sets LAST_RC, LAST_LOG, LAST_T.
run_one() {
  local c="$1" inst="$2" label="$3"
  RUN_N=$((RUN_N + 1))
  LAST_T="$SB/t$RUN_N-$c"
  copy_tree "$SB/base" "$LAST_T" || { echo "failure-path-fixture: cannot copy the base target"; exit 2; }
  if [ "$c" = "snapkeep" ] && [ ! -e "$LAST_T/.tad/brain-index.md" ]; then printf 'fp brain index\n' > "$LAST_T/.tad/brain-index.md"; fi
  LAST_TMP="$SB/tmp.$RUN_N"
  /bin/mkdir "$LAST_TMP" || { echo "failure-path-fixture: cannot make the run's temp dir $LAST_TMP"; exit 2; }
  arm_case "$c"
  LAST_LOG="$SB/logs/$label.log"
  local g0; g0="$(wc -l < "$SB/git.log" | tr -d ' ')"
  LAST_RC="$(run_installer "$inst" "$LAST_T" "$LAST_LOG" "$LAST_TMP")"
  [ "$LAST_RC" != "refused" ] || { echo "failure-path-fixture: installer run refused"; exit 2; }
  LAST_GIT=$(( $(wc -l < "$SB/git.log" | tr -d ' ') - g0 ))
  if [ -n "$KEEP_DIR" ]; then /bin/cp "$LAST_LOG" "$KEEP_DIR/$label.log" || echo "failure-path-fixture: could not keep $label.log"; fi
}

# --- main -----------------------------------------------------------------------------------
stage_source || { echo "failure-path-fixture: source staging failed"; exit 2; }
PRE_VERSION="$(head -1 "$SOURCE/.tad/version.txt" | tr -d '[:space:]')"
NEXT_VERSION="$(next_version "$PRE_VERSION")" || { echo "failure-path-fixture: source version is not SemVer: $PRE_VERSION"; exit 2; }

if [ "$VARIANTS" = "1" ]; then
  for c in $CASES; do
    for vn in $(variant_for "$c"); do
      case "$vn" in
        write|sync|rollback) build_variant "$vn" > "$SB/variant-$vn.path" ;;
        snapleft) build_variant_marker snapleft '# P5-LEFT-LINE' > "$SB/variant-$vn.path" ;;
        snapkeep) build_variant_marker snapkeep '# P5-KEEP-NAMED' > "$SB/variant-$vn.path" ;;
        snapincomplete) build_variant_marker snapincomplete '# P5-KEEP-NAMED' '    if [ "$_ex_n" != "0" ]; then _snap_keep=1; fi' > "$SB/variant-$vn.path" ;;
        write-nodispose) build_variant_marker write-nodispose 'RM-OK:rollback-snap-unneeded' > "$SB/variant-$vn.path" ;;
        rollback-keepfailed) build_variant_marker rollback-keepfailed '# P5-KEEP-FAILED' > "$SB/variant-$vn.path" ;;
      esac || { echo "failure-path-fixture: variant $vn could not be built"; exit 2; }
    done
  done
fi

/bin/mkdir -p "$SB/base" || exit 2
clear_case_shims
/bin/mkdir "$SB/tmp.0" || { echo "failure-path-fixture: cannot make $SB/tmp.0"; exit 2; }
rc="$(run_installer "$INSTALLER" "$SB/base" "$SB/logs/base-install.log" "$SB/tmp.0")"
if [ "$rc" != "0" ]; then
  echo "failure-path-fixture: the clean base install failed (rc=$rc); last lines:"
  tail -5 "$SB/logs/base-install.log" 2>/dev/null
  exit 2
fi
[ "$(target_version "$SB/base")" = "$PRE_VERSION" ] || { echo "failure-path-fixture: base install has version $(target_version "$SB/base"), expected $PRE_VERSION"; exit 2; }
[ "$(cat "$SB/base/.tad/fp-rb.md" 2>/dev/null)" = "fp-rb OLD" ] || { echo "failure-path-fixture: base install lacks .tad/fp-rb.md OLD"; exit 2; }

# The upgrade source: one new template, fp-rb NEW, the next patch version.
printf 'fp-write NEW\n' > "$SOURCE/.tad/templates/fp-write.md"
printf 'fp-rb NEW\n' > "$SOURCE/.tad/fp-rb.md"
printf '%s\n' "$NEXT_VERSION" > "$SOURCE/.tad/version.txt"

ALL_OK=1
for c in $CASES; do
  run_one "$c" "$INSTALLER" "$c"
  if assert_case "$c" "$LAST_RC" "$LAST_LOG" "$LAST_T"; then
    echo "CASE $c PASS"
  else
    echo "CASE $c FAIL"; echo "  $c: $FAILS"; ALL_OK=0
  fi
  echo "  $c: git-shim calls by the installer: $LAST_GIT"
  if [ "$VARIANTS" = "1" ]; then
    for vn in $(variant_for "$c"); do
      v="$(cat "$SB/variant-$vn.path")"
      vl="$vn.variant"; [ "$vn" = "$c" ] || vl="$vn"
      run_one "$c" "$v" "$vl"
      if assert_case "$c" "$LAST_RC" "$LAST_LOG" "$LAST_T"; then
        echo "VARIANT $vn PASSED"; echo "  $vn: the case does not see its line"; ALL_OK=0
      elif [ ! -s "$SB/marker.$c" ]; then
        echo "VARIANT $vn PASSED"; echo "  $vn: the variant's fault never fired, so its failure proves nothing"; ALL_OK=0
      elif [ "$KEYFAIL" != "1" ]; then
        echo "VARIANT $vn PASSED"; echo "  $vn: the variant failed, but not on its removed line: $FAILS"; ALL_OK=0
      else
        echo "VARIANT $vn FAILS-AS-EXPECTED"
      fi
    done
  fi
  clear_case_shims
done

if [ "$ALL_OK" = "1" ]; then echo "FAILURE-PATH-FIXTURE: PASS"; exit 0; fi
echo "FAILURE-PATH-FIXTURE: FAIL"; exit 1
