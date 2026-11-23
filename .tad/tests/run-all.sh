#!/bin/bash
# run-all.sh - the offline test entry point behind `npm test`.
#
# Runs every test that is deterministic, offline, and does not write to $HOME, one after another, and
# exits non-zero if any of them fails. Last line of output: `RUN-ALL: PASS` or `RUN-ALL: FAIL (<names>)`.
#
#   bash .tad/tests/run-all.sh
#   TAD_TEST_FULL=1 bash .tad/tests/run-all.sh    also run the slow installer fixtures, with TAD_BACKUP_ROOT
#                                                  pointed at a throw-away directory. Measured on a Mac under
#                                                  load: several hours (see the timing table in the v4.0.11
#                                                  Phase 1 completion report); run it before a release, not
#                                                  after every edit.
#   bash .tad/tests/run-all.sh --quick             (or TAD_TEST_QUICK=1) the default entries plus a short list of
#                                                  installer cases that cover the write, failure-naming and
#                                                  rollback code paths. Meant for a builder after an edit to
#                                                  tad.sh or the installer fixtures; well under 30 minutes.
#                                                  It does not replace the full run before a release.
#   TAD_TEST_RELEASE=1 ...                         also run the entries that can only pass at release time
#                                                  (see the EXCLUDED line of tad-update-fixture:release-gates)
#
# The tree must be a git work tree whose HEAD already holds the change under test: check-path-refs reads
# `git ls-files`, and several tad-update-fixture cases build their candidate with `git archive HEAD`, so an
# uncommitted edit is not what they test. Several cases also need the public tags (v4.0.5, v3.0.0) and the
# commit 165b2a39 (a clone of the public repository has them). Never run it in the cloud-sync folder itself.
#   bash .tad/tests/run-all.sh --no-git            (or TAD_TEST_NO_GIT=1) the no-git subset: every default entry and
#                                                  case that runs without git, so it may run in a folder that is no
#                                                  git work tree, the cloud-sync folder included (the one exception
#                                                  to the sentence above). It calls git zero times, prints
#                                                  `EXCLUDED <name>: <reason>` for each entry or case it leaves out,
#                                                  and fails (no-git-coverage) when a default entry, or a case of
#                                                  the two entries it runs case by case, is neither run nor named.
#                                                  Not combinable with --quick, TAD_TEST_FULL or TAD_TEST_RELEASE.
#
# Shell tests are run with /bin/bash on purpose: on macOS that is bash 3.2, which is what the hook
# scripts' `#!/bin/bash` shebang gets, and a different `bash` earlier on PATH would hide 3.2 breakage.
# Every executed test prints `RUN <name>`; every test that is left out prints `EXCLUDED <name>: <reason>`.
#
# Written for bash 3.2 (no associative arrays, no mapfile).

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
# rework 2, run P1-1: this script's own tools run from the system directories (each name below becomes a
# function that calls the tool by its absolute path), while every child it starts keeps the caller's PATH
# unchanged: the git shim, python3, node and bash the runner chose (the reason the PATH itself is not pinned:
# a pinned PATH would send the children's git calls to /usr/bin/git). Functions are not exported, so no child
# sees them. A tool missing from the system directories keeps the PATH lookup.
for _t in rm rmdir cp mv mkdir chmod chflags ln touch grep egrep sed awk find sort uniq comm cut tr wc head tail cat ls diff cmp tar shasum mktemp readlink dirname basename date sleep od stat du tee iconv; do  # FX-OWN-TOOLS
  for _d in /usr/bin /bin /usr/sbin /sbin; do
    if [ -x "$_d/$_t" ]; then eval "$_t() { $_d/$_t \"\$@\"; }"; break; fi
  done
done
unset _t _d
NL='
'
_rd() { # one absolute directory line or nothing (rework 2: CDPATH is cleared above; an answer with a newline is refused)
  local r; r="$(cd -P -- "$1" > /dev/null 2>&1 && pwd -P && printf x)" || return 1
  r="${r%x}"; r="${r%"$NL"}"; case "$r" in /*) ;; *) return 1 ;; esac; case "$r" in *"$NL"*) return 1 ;; esac; printf '%s' "$r"; }
HERE="$(_rd "$(dirname "$0")")" || { echo "run-all: cannot resolve its own directory" >&2; exit 2; }
REPO="$(_rd "$HERE/../..")" || { echo "run-all: cannot resolve the repo root" >&2; exit 2; }
cd "$REPO" || exit 2

QUICK="${TAD_TEST_QUICK:-}"
NOGIT="${TAD_TEST_NO_GIT:-}"
for _a in "$@"; do
  case "$_a" in
    --quick) QUICK=1 ;;
    --no-git) NOGIT=1 ;;
    -h|--help) sed -n '2,32p' "$0"; exit 0 ;;
    *) echo "run-all: unknown option '$_a' (use --help)" >&2; exit 2 ;;
  esac
done

FAILED=""
TMP_ROOT=""
cleanup() { [ -n "$TMP_ROOT" ] && rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

note_fail() { FAILED="${FAILED:+$FAILED, }$1"; }

# run_test <name> <command...>: prints RUN, runs the command, records a failure.
run_test() {
  local name="$1"; shift
  echo "RUN $name"
  local t0=$SECONDS
  "$@"
  local rc=$?
  echo "TIME $name $((SECONDS - t0))s"
  if [ "$rc" -ne 0 ]; then
    echo "FAILED $name (exit $rc)"
    note_fail "$name"
  fi
}

excluded() { echo "EXCLUDED $1: $2"; }

# --no-git (report-upgrades Phase 4): the no-git subset. A separate block that runs its own list and exits,
# so the three modes below are untouched. Entries and cases that call git (or need this repository's
# history or public tags) are named EXCLUDED with their reason; then every default entry, and every case of
# the two entries run case by case here, must have appeared as RUN or EXCLUDED (no-git-coverage).
if [ -n "$NOGIT" ]; then
  if [ -n "$QUICK" ] || [ "${TAD_TEST_FULL:-}" = "1" ] || [ "${TAD_TEST_RELEASE:-}" = "1" ]; then
    echo "run-all: --no-git does not combine with --quick, TAD_TEST_FULL or TAD_TEST_RELEASE (those modes need git)" >&2
    exit 2
  fi
  NG_SEEN=""
  ng_run() { NG_SEEN="$NG_SEEN$1
"; run_test "$@"; }
  ng_excl() { NG_SEEN="$NG_SEEN$1
"; excluded "$1" "$2"; }
  # ng_rerun_139 <command...>: runs an entry that starts node again (at most twice) when the node runtime
  # itself segfaulted: Node 24.7 on the maintainer's Mac (macOS 26) crashes inside process.exit() in a
  # share of runs, also outside any test (2026-11-09). A segfault is the entry ending with status 139 (node
  # run directly), or ending non-zero with a shell "Segmentation fault" line in its own output (node run
  # inside a shell fixture, which then reports its own status). Every rerun prints a NOTE line and is
  # counted in the RERUNS line before the result line; any other ending is returned at once, so a failure
  # without a segfault is never retried. Rework 1 of Phase 4 (Gate 3 r1 run P1-1): every entry of this
  # block that starts node is wrapped (measured with a recording node on PATH: the six yolo cases,
  # check-path-refs, check-path-refs-nogit-fixture, tad-install-fixture). The entry's stdout and stderr go
  # to scratch files and are printed to the same streams when it ends (so they are not streamed live).
  NG_RERUNS=0
  ng_rerun_139() {
    local try=1 rc why o e
    o="$(mktemp "${TMPDIR:-/tmp}/run-all-ng.XXXXXX")" || return 2
    e="$o.err"
    while :; do
      "$@" > "$o" 2> "$e"; rc=$?
      cat "$o"; cat "$e" >&2
      why=""
      if [ "$rc" -eq 139 ]; then why="exit 139"
      elif [ "$rc" -ne 0 ] && grep -q 'Segmentation fault' "$o" "$e" 2>/dev/null; then why="exit $rc and a 'Segmentation fault' line in its output"
      fi
      if [ -z "$why" ] || [ "$try" -ge 3 ]; then rm -f "$o" "$e"; return "$rc"; fi
      try=$((try + 1))
      NG_RERUNS=$((NG_RERUNS + 1))
      echo "NOTE $why (the node runtime segfaulted, not a test result); running it again, try $try of 3: $*"
    done
  }
  NG_GIT_CODE="calls git: the code under test runs git in a scratch repository"
  NG_HISTORY="needs this repository's git history and public tags; run it in a clone"
  NG_OPTIN="opt-in case of --quick / TAD_TEST_FULL, not part of the no-git list; run it in a clone"

  # report-upgrades Phase 5 (D13, carried G4-1): when the first python3 on PATH has no PyYAML,
  # say here what fixes it (intent-route-test needs it), from the pre-check's own --env line.
  if ! (cd / && python3 -E -c 'import yaml') > /dev/null 2>&1; then
    if [ -f .tad/scripts/harness-precheck.sh ]; then
      echo "NOTE $(/bin/bash .tad/scripts/harness-precheck.sh --env 2>/dev/null | grep '^PRECHECK-FIX python3: ' | head -1)"
    else
      echo "NOTE the first python3 on PATH has no PyYAML (intent-route-test needs it)"
    fi
  fi
  ng_run cora-check-budget-fixture /bin/bash .tad/tests/cora-check-budget-fixture.sh
  # Pre-check before a dispatch and the temp-copy helper (report-upgrades Phase 5): neither calls git.
  if [ -f .tad/tests/harness-precheck-fixture.sh ]; then
    ng_run harness-precheck-fixture /bin/bash .tad/tests/harness-precheck-fixture.sh
  else
    ng_excl harness-precheck-fixture "file does not exist"
  fi
  if [ -f .tad/tests/tad-tmp-fixture.sh ]; then
    ng_run tad-tmp-fixture /bin/bash .tad/tests/tad-tmp-fixture.sh
  else
    ng_excl tad-tmp-fixture "file does not exist"
  fi
  ng_run cora-check-judge-rounds-fixture /bin/bash .tad/tests/cora-check-judge-rounds-fixture.sh
  ng_run detect-state-fixture /bin/bash .tad/tests/detect-state-fixture.sh
  for c in profiles semantic-equivalence strict-rejection live-evidence usability release-threshold; do
    ng_run "yolo-harness-runner.test:$c" ng_rerun_139 node .tad/scripts/yolo-harness-runner.test.mjs --case "$c"
  done
  for c in fixtures resume state-safety compatibility opt-in budget; do
    ng_excl "yolo-harness-runner.test:$c" "$NG_GIT_CODE (git init)"
  done
  ng_excl yolo-harness-runner.test:scope "reads this repository's git work tree status (git status --porcelain)"
  ng_run tad-install-fixture ng_rerun_139 /bin/bash .tad/tests/tad-install-fixture.sh
  ng_run check-path-refs ng_rerun_139 node .tad/scripts/check-path-refs.mjs --no-git
  ng_run check-path-refs-nogit-fixture ng_rerun_139 /bin/bash .tad/tests/check-path-refs-nogit-fixture.sh
  ng_run hook-envelope-fixture /bin/bash .tad/tests/hook-envelope-fixture.sh
  if [ -f .tad/tests/release-verify-fixture.sh ]; then
    ng_run release-verify-fixture /bin/bash .tad/tests/release-verify-fixture.sh --case all
  else
    ng_excl release-verify-fixture "file does not exist"
  fi
  if [ -f .tad/tests/gate3-check-fixture.sh ]; then
    ng_run gate3-check-fixture /bin/bash .tad/tests/gate3-check-fixture.sh
  else
    ng_excl gate3-check-fixture "file does not exist"
  fi
  ng_run hook-timeout-conformance /bin/bash .tad/hooks/lib/hook-timeout-test.sh --conformance
  ng_run intent-route-test /bin/bash .tad/tests/intent-route-test.sh
  for c in versions silent-bounded hard-bounded cache-path once-a-day delivery no-tad reminder-only; do
    ng_run "update-reminder-fixture:$c" /bin/bash .tad/tests/update-reminder-fixture.sh --case "$c"
  done
  ng_excl update-reminder-fixture:off-switch "runs a tad.sh upgrade, which asks git about the source tree and the backup root (tad.sh is not changed by the no-git mode)"
  ng_run backup-lifecycle-fixture:guard /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case guard
  for c in classify hold salvage clear reprove foreign; do
    ng_excl "backup-lifecycle-fixture:$c" "$NG_HISTORY (git show of tagged files)"
  done
  ng_excl backup-lifecycle-fixture:caps "$NG_OPTIN"
  ng_excl backup-lifecycle-fixture:ledger "$NG_OPTIN (the ledger generator in a clone)"
  # Pack counts (report-upgrades Phase 1, wired by Phase 2) and the installer failure-path fixture (Phase 2):
  # neither calls git; the fixture runs one representative case here, all cases elsewhere.
  # The fixture's "no git" rests on its git shim: tad.sh, which it runs, does probe git (tad.sh:968, 6482),
  # and those probes reach the fixture's exit-1 `git` shim first on the installer's PATH, never the real git.
  # Removing or bypassing that shim would make this no-git run call git.
  if [ -f INSTALLATION_GUIDE.md ]; then
    ng_run pack-counts-check /bin/bash .tad/scripts/pack-counts.sh --check
    ng_run pack-counts-fixture /bin/bash .tad/tests/pack-counts-fixture.sh
  else
    ng_excl pack-counts-check "maintainer tool: INSTALLATION_GUIDE.md is not in this project"
    ng_excl pack-counts-fixture "maintainer tool: INSTALLATION_GUIDE.md is not in this project"
  fi
  if [ -f tad.sh ]; then
    ng_run failure-path-fixture:rollback /bin/bash .tad/tests/failure-path-fixture.sh --case rollback
    ng_excl failure-path-fixture "one representative case (rollback) in this mode; all cases run in the default and TAD_TEST_FULL modes and in the CI workflow"
  else
    ng_excl failure-path-fixture "no tad.sh at the repo root (a project that received .tad/tests by sync); the fixture drives the repo installer"
  fi
  ng_excl gate-exercise "no-git mode; and the default mode's reason: stale test, its temporary repo has no hop manifest"
  ng_excl yolo-recovery.test "no-git mode; and the default mode's reason: stale test, case phase2-scope-proof diffs a git range"
  ng_excl yolo-round.test "no-git mode; and the default mode's reason: stale test, case dogfood-evidence checks a recorded hash"
  ng_excl installer-data-safety-fixture "no-git mode; slow (hours under load) and opt-in (TAD_TEST_FULL=1 or --quick); this line also names every installer-data-safety-fixture:<case> of the --quick and TAD_TEST_FULL branches; run them in a clone"
  ng_excl tad-update-fixture "no-git mode; slow and opt-in, its candidate is built with git archive HEAD; this line also names every tad-update-fixture:<case> of the --quick and TAD_TEST_FULL branches (remote-release always needs network); run them in a clone"
  ng_excl upgrade-acceptance "no-git mode; and the default mode's reason: not a self-contained test, it verifies a given downstream project (--target)"

  # no-git-coverage: the default entry names are read from this script below the end marker of this block
  # (the --quick / TAD_TEST_FULL branch left out), the case names from the two files run case by case.
  NG_SELF="$HERE/$(basename "$0")"
  NG_DEFAULT="$(awk -v m='# --- end of the --no-git block ---' '
    on == 0 { if ($0 == m) on = 1; next }
    {
      l = $0; sub(/^[ \t]+/, "", l)
      if (skip) {
        if (l ~ /^if /) depth++
        else if (l ~ /^fi($|[ ;#])/) { depth--; if (depth == 0) skip = 0 }
        else if (depth == 1 && l ~ /^else($|[ ;#])/) skip = 0
        next
      }
      if (l ~ /^if \[ "\$\{TAD_TEST_FULL:-\}" = "1" \]/) { skip = 1; depth = 1; next }
      if (l ~ /^for c in /) { fl = l; sub(/^for c in /, "", fl); sub(/;[ \t]*do.*$/, "", fl); next }
      if (l ~ /^done/) { fl = ""; next }
      if (l ~ /^(run_test|excluded) /) {
        split(l, a, /[ \t]+/); n = a[2]; gsub(/"/, "", n)
        if (n ~ /\$c/ && fl != "") { k = split(fl, cs, /[ \t]+/); for (i = 1; i <= k; i++) { x = n; sub(/\$c/, cs[i], x); print x } }
        else print n
      }
    }' "$NG_SELF")"
  NG_YOLO_CASES="$(awk '/^const CASES=\{$/ { on = 1; next } on && /^\};/ { exit } on { if (match($0, /^[ \t]*'\''[^'\'']+'\''[ \t]*:/)) { s = substr($0, RSTART, RLENGTH); sub(/^[ \t]*'\''/, "", s); sub(/'\''[ \t]*:$/, "", s); print "yolo-harness-runner.test:" s } }' .tad/scripts/yolo-harness-runner.test.mjs)"
  NG_UR_CASES="$(awk '/^case "\$CASE" in$/ { on = 1; next } on && /^esac/ { exit } on { if (match($0, /^[ \t]+[a-z0-9][a-z0-9-]*\)/)) { s = substr($0, RSTART, RLENGTH); sub(/^[ \t]+/, "", s); sub(/\)$/, "", s); if (s != "all") print "update-reminder-fixture:" s } }' .tad/tests/update-reminder-fixture.sh)"
  NG_MISSING=""
  [ -n "$NG_DEFAULT" ] || NG_MISSING="(no default entry names read from $NG_SELF)"
  [ -n "$NG_YOLO_CASES" ] || NG_MISSING="${NG_MISSING:+$NG_MISSING }(no case names read from yolo-harness-runner.test.mjs)"
  [ -n "$NG_UR_CASES" ] || NG_MISSING="${NG_MISSING:+$NG_MISSING }(no case names read from update-reminder-fixture.sh)"
  # The names seen go in through the environment (an awk -v value cannot hold a newline). The checker's
  # answer starts with "checked": no answer means the check itself did not run, which fails the run too.
  NG_CHECK="$(printf '%s\n%s\n%s\n' "$NG_DEFAULT" "$NG_YOLO_CASES" "$NG_UR_CASES" | NG_SEEN="$NG_SEEN" awk '
    BEGIN { k = split(ENVIRON["NG_SEEN"], s, "\n") }
    $0 == "" { next }
    { n++; ok = 0; for (i = 1; i <= k; i++) if (s[i] != "" && (s[i] == $0 || index(s[i], $0 ":") == 1)) { ok = 1; break }
      if (!ok && !($0 in done)) { done[$0] = 1; out = out " " $0 } }
    END { print "checked " n " names, missing:" out }')"
  case "$NG_CHECK" in
    "checked "[1-9]*" names, missing:"*) NG_CHECK="${NG_CHECK#*missing:}" ;;
    *) NG_MISSING="${NG_MISSING:+$NG_MISSING }(the coverage check did not run)"; NG_CHECK="" ;;
  esac
  NG_MISSING="${NG_MISSING:+$NG_MISSING }$NG_CHECK"
  NG_MISSING="$(printf '%s' "$NG_MISSING" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  if [ -n "$NG_MISSING" ]; then
    echo "FAILED no-git-coverage ($NG_MISSING)"
    note_fail no-git-coverage
  fi
  echo "RERUNS $NG_RERUNS (entries run again after a node runtime segfault; each has a NOTE line above)"
  if [ -z "$FAILED" ]; then
    echo "RUN-ALL: PASS"
    exit 0
  fi
  echo "RUN-ALL: FAIL ($FAILED)"
  exit 1
fi
# --- end of the --no-git block ---

# Present and expected to pass.
run_test cora-check-budget-fixture /bin/bash .tad/tests/cora-check-budget-fixture.sh
run_test cora-check-judge-rounds-fixture /bin/bash .tad/tests/cora-check-judge-rounds-fixture.sh
run_test detect-state-fixture /bin/bash .tad/tests/detect-state-fixture.sh
run_test yolo-harness-runner.test node .tad/scripts/yolo-harness-runner.test.mjs
# report-upgrades Phase 5: the pre-check before a dispatch and the temp-copy helper.
if [ -f .tad/tests/harness-precheck-fixture.sh ]; then
  run_test harness-precheck-fixture /bin/bash .tad/tests/harness-precheck-fixture.sh
else
  excluded harness-precheck-fixture "file does not exist"
fi
if [ -f .tad/tests/tad-tmp-fixture.sh ]; then
  run_test tad-tmp-fixture /bin/bash .tad/tests/tad-tmp-fixture.sh
else
  excluded tad-tmp-fixture "file does not exist"
fi

if [ -f .tad/tests/tad-install-fixture.sh ]; then
  run_test tad-install-fixture /bin/bash .tad/tests/tad-install-fixture.sh
else
  excluded tad-install-fixture "file does not exist"
fi

if [ -f .tad/scripts/check-path-refs.mjs ]; then
  run_test check-path-refs node .tad/scripts/check-path-refs.mjs
else
  excluded check-path-refs "file does not exist"
fi

if [ -f .tad/tests/hook-envelope-fixture.sh ]; then
  run_test hook-envelope-fixture /bin/bash .tad/tests/hook-envelope-fixture.sh
else
  excluded hook-envelope-fixture "file does not exist"
fi

if [ -f .tad/hooks/lib/hook-timeout-test.sh ]; then
  run_test hook-timeout-conformance /bin/bash .tad/hooks/lib/hook-timeout-test.sh --conformance
else
  excluded hook-timeout-conformance "file does not exist"
fi

if [ -f .tad/tests/intent-route-test.sh ]; then
  run_test intent-route-test /bin/bash .tad/tests/intent-route-test.sh
else
  excluded intent-route-test "file does not exist"
fi

if [ -f .tad/tests/release-verify-fixture.sh ]; then
  run_test release-verify-fixture /bin/bash .tad/tests/release-verify-fixture.sh --case all
else
  excluded release-verify-fixture "file does not exist"
fi

if [ -f .tad/tests/gate3-check-fixture.sh ]; then
  run_test gate3-check-fixture /bin/bash .tad/tests/gate3-check-fixture.sh
else
  excluded gate3-check-fixture "file does not exist"
fi

if [ -f .tad/tests/update-reminder-fixture.sh ]; then
  run_test update-reminder-fixture /bin/bash .tad/tests/update-reminder-fixture.sh --case all
else
  excluded update-reminder-fixture "file does not exist"
fi

# Backup lifecycle (Phase 3): the fast cases are offline and build everything in a sandbox with a scratch HOME and backup root.
if [ -f .tad/tests/backup-lifecycle-fixture.sh ]; then
  for c in guard classify hold salvage clear reprove foreign; do
    run_test "backup-lifecycle-fixture:$c" /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case "$c"
  done
else
  excluded backup-lifecycle-fixture "file does not exist"
fi

# Pack counts (report-upgrades Phase 1, wired by Phase 2): the install guide's pack counts against the registry; no git.
if [ -f INSTALLATION_GUIDE.md ]; then
  run_test pack-counts-check /bin/bash .tad/scripts/pack-counts.sh --check
  run_test pack-counts-fixture /bin/bash .tad/tests/pack-counts-fixture.sh
else
  excluded pack-counts-check "maintainer tool: INSTALLATION_GUIDE.md is not in this project"
  excluded pack-counts-fixture "maintainer tool: INSTALLATION_GUIDE.md is not in this project"
fi

# Left out because they do not pass today. These are triaged, not fixed, by the batch that added this file.
excluded gate-exercise "stale test: its temporary repo has no hop manifest, so the migration gate now stops at 'missing hop manifest' before it reaches the unmanifested-delete check the test expects"
excluded yolo-recovery.test "stale test: case phase2-scope-proof diffs the fixed range 96bbfada..HEAD, which grows with every commit and now contains paths outside the Phase-2 scope; the other cases pass"
excluded yolo-round.test "stale test: case dogfood-evidence asserts that the sha256 of phase2-pair-driver.mjs equals the hash recorded by a past dogfood run, and the driver has changed since; the other cases pass, and the file takes minutes"

# Slow fixtures: opt-in, and only against a throw-away backup root so nothing lands in $HOME/.tad-backups.
if [ "${TAD_TEST_FULL:-}" = "1" ]; then
  TMP_ROOT="$(mktemp -d)" || exit 2
  export TAD_BACKUP_ROOT="$TMP_ROOT/backups"
  run_test installer-data-safety-fixture /bin/bash .tad/tests/installer-data-safety-fixture.sh --case all
  # `--case all` above stops at fx.c (it exits silently there, also before this phase), so the
  # update-flow cases that come after it run by name.
  for c in fx.p fx.f fx.k fx.rb fx.rep fx.agm fx.oc fx.own fx.g; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  # v4.0.11: the aw atomicity cases and the failure-naming / rollback-conclusion cases run by
  # name (`--case all` above ends at fx.c, so none of them ever ran through it).
  for c in aw.1 aw.2 aw.2b aw.3 aw.4 aw.guard; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  for c in fn.copy fn.copy-real fn.verify fn.swap fn.points fn.catchall fn.signal fn.keep fn.keep-lost; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  for c in rp.field rp.run-copy rp.backup-entry rp.snap-entry rp.unsafe-backup rp.unsafe-root; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  for c in rp.fresh rp.stamp rp.snap-incomplete rp.snap-pending rp.precopy-lost rp.leftover rp.lint-control; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  for c in pm.empty pm.nopolicy pm.nobaseline pm.maint; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  for c in backup states consent download-safety opencode-preservation full-upgrade archive-shape bash-pin multi-platform first-hop post-update check-clear; do
    run_test "tad-update-fixture:$c" /bin/bash .tad/tests/tad-update-fixture.sh --case "$c"
  done
  # release-gates runs the release preflight gates against the tree it is in. Three of the nine can only be
  # green in the state the release dispatch builds, so the entry runs there (TAD_TEST_RELEASE=1) and is
  # named, with its reason, everywhere else: gate 2 (version) lists every mention of the previous version
  # still in the tree, which the release prep classifies; gate 4 (migration) reads `git describe` of HEAD^,
  # so the version bump must already be committed on top of the previous tag; gate 7 (provenance) compares
  # the git index with the ledger regenerated after that commit.
  if [ "${TAD_TEST_RELEASE:-}" = "1" ]; then
    run_test "tad-update-fixture:release-gates" /bin/bash .tad/tests/tad-update-fixture.sh --case release-gates
  else
    excluded tad-update-fixture:release-gates "release time only: gates 2 (version), 4 (migration) and 7 (provenance) need the bump committed on the previous tag and the ledger regenerated; run with TAD_TEST_RELEASE=1 in the release dispatch"
  fi
  # Backup lifecycle, slow cases: the ledger generator in a clone, the real installer on the 阿里 shape
  for c in ledger caps; do
    run_test "backup-lifecycle-fixture:$c" /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case "$c"
  done
  # Installer failure paths (report-upgrades Phase 2): write, sync and rollback faults, each against a variant.
  if [ -f tad.sh ]; then
    run_test failure-path-fixture /bin/bash .tad/tests/failure-path-fixture.sh --case all
  else
    excluded failure-path-fixture "no tad.sh at the repo root (a project that received .tad/tests by sync); the fixture drives the repo installer"
  fi
  excluded tad-update-fixture:remote-release "needs network"
elif [ -n "$QUICK" ]; then
  # Quick mode (--quick): the installer cases that cover what a change to the write, failure-naming and
  # rollback code touches, one or two per code path, each measured (see the timing table in the v4.0.11
  # Phase 1 completion report). Everything else stays opt-in under TAD_TEST_FULL=1.
  TMP_ROOT="$(mktemp -d)" || exit 2
  export TAD_BACKUP_ROOT="$TMP_ROOT/backups"
  for c in ac2.8 fx.c aw.guard aw.3 fn.copy fn.verify fn.swap rp.field rp.stamp rp.leftover; do
    run_test "installer-data-safety-fixture:$c" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case "$c"
  done
  run_test "tad-update-fixture:states" /bin/bash .tad/tests/tad-update-fixture.sh --case states
  run_test "backup-lifecycle-fixture:caps" /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case caps
  # Installer failure paths (report-upgrades Phase 2): the representative case only.
  if [ -f tad.sh ]; then
    run_test failure-path-fixture:rollback /bin/bash .tad/tests/failure-path-fixture.sh --case rollback
    excluded failure-path-fixture "quick mode ran case rollback; the default and TAD_TEST_FULL modes run all cases"
  else
    excluded failure-path-fixture "no tad.sh at the repo root (a project that received .tad/tests by sync); the fixture drives the repo installer"
  fi
  excluded installer-data-safety-fixture "quick mode ran a subset by name; set TAD_TEST_FULL=1 for the whole fixture"
  excluded tad-update-fixture "quick mode ran a subset by name; set TAD_TEST_FULL=1 for the whole fixture (case remote-release always needs network)"
else
  # Installer failure paths (report-upgrades Phase 2): all three cases, each against a variant (one install and six upgrades).
  if [ -f tad.sh ]; then
    run_test failure-path-fixture /bin/bash .tad/tests/failure-path-fixture.sh --case all
  else
    excluded failure-path-fixture "no tad.sh at the repo root (a project that received .tad/tests by sync); the fixture drives the repo installer"
  fi
  excluded installer-data-safety-fixture "slow (hours under load); set TAD_TEST_FULL=1 to include it, or pass --quick for a subset"
  excluded tad-update-fixture "slow; set TAD_TEST_FULL=1 to include it, or pass --quick for a subset (case remote-release always needs network)"
fi
excluded upgrade-acceptance "not a self-contained test: it verifies a given downstream project (--target) and needs arguments"

if [ -z "$FAILED" ]; then
  echo "RUN-ALL: PASS"
  exit 0
fi
echo "RUN-ALL: FAIL ($FAILED)"
exit 1
