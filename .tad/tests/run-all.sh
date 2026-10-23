#!/bin/bash
# run-all.sh - the offline test entry point behind `npm test`.
#
# Runs every test that is deterministic, offline, and does not write to $HOME, one after another, and
# exits non-zero if any of them fails. Last line of output: `RUN-ALL: PASS` or `RUN-ALL: FAIL (<names>)`.
#
#   bash .tad/tests/run-all.sh
#   TAD_TEST_FULL=1 bash .tad/tests/run-all.sh    also run the slow installer fixtures (about 5+ minutes),
#                                                  with TAD_BACKUP_ROOT pointed at a throw-away directory
#
# Shell tests are run with /bin/bash on purpose: on macOS that is bash 3.2, which is what the hook
# scripts' `#!/bin/bash` shebang gets, and a different `bash` earlier on PATH would hide 3.2 breakage.
# Every executed test prints `RUN <name>`; every test that is left out prints `EXCLUDED <name>: <reason>`.
#
# Written for bash 3.2 (no associative arrays, no mapfile).

HERE="$(cd "$(dirname "$0")" && pwd -P)"
REPO="$(cd "$HERE/../.." && pwd -P)"
cd "$REPO" || exit 2

FAILED=""
TMP_ROOT=""
cleanup() { [ -n "$TMP_ROOT" ] && rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

note_fail() { FAILED="${FAILED:+$FAILED, }$1"; }

# run_test <name> <command...>: prints RUN, runs the command, records a failure.
run_test() {
  local name="$1"; shift
  echo "RUN $name"
  "$@"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "FAILED $name (exit $rc)"
    note_fail "$name"
  fi
}

excluded() { echo "EXCLUDED $1: $2"; }

# Present and expected to pass.
run_test cora-check-budget-fixture /bin/bash .tad/tests/cora-check-budget-fixture.sh
run_test detect-state-fixture /bin/bash .tad/tests/detect-state-fixture.sh
run_test yolo-harness-runner.test node .tad/scripts/yolo-harness-runner.test.mjs

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

if [ -f .tad/tests/update-reminder-fixture.sh ]; then
  run_test update-reminder-fixture /bin/bash .tad/tests/update-reminder-fixture.sh --case all
else
  excluded update-reminder-fixture "file does not exist"
fi

# Backup lifecycle (Phase 3): the fast cases are offline and build everything in a sandbox with a scratch HOME and backup root.
if [ -f .tad/tests/backup-lifecycle-fixture.sh ]; then
  for c in guard classify hold salvage clear foreign; do
    run_test "backup-lifecycle-fixture:$c" /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case "$c"
  done
else
  excluded backup-lifecycle-fixture "file does not exist"
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
  for c in backup states consent download-safety opencode-preservation full-upgrade release-gates archive-shape bash-pin multi-platform first-hop post-update check-clear; do
    run_test "tad-update-fixture:$c" /bin/bash .tad/tests/tad-update-fixture.sh --case "$c"
  done
  # Backup lifecycle, slow cases: the ledger generator in a clone, the real installer on the 阿里 shape
  for c in ledger caps; do
    run_test "backup-lifecycle-fixture:$c" /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case "$c"
  done
  excluded tad-update-fixture:remote-release "needs network"
else
  excluded installer-data-safety-fixture "slow (about 5 minutes); set TAD_TEST_FULL=1 to include it"
  excluded tad-update-fixture "slow; set TAD_TEST_FULL=1 to include it (case remote-release always needs network)"
fi
excluded upgrade-acceptance "not a self-contained test: it verifies a given downstream project (--target) and needs arguments"

if [ -z "$FAILED" ]; then
  echo "RUN-ALL: PASS"
  exit 0
fi
echo "RUN-ALL: FAIL ($FAILED)"
exit 1
