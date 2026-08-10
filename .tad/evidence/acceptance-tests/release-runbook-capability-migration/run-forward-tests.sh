#!/usr/bin/env bash
set -euo pipefail

EVID_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
ROOT=$(cd "$EVID_DIR/../../../.." && pwd -P)
OUT_DIR="$EVID_DIR/forward"
SKILL_PATH="$ROOT/.claude/skills/release-runbook/SKILL.md"

run_case() {
  local idx=$1 scenario=$2
  local output="$OUT_DIR/case-$idx.md"
  local log="$OUT_DIR/case-$idx.log"
  local prompt
  prompt="You are a fresh independent behavior-evaluation session. Use the release-runbook skill at: $SKILL_PATH

Read the entry skill and only the reference it routes for this scenario. Do not read the active migration handoff, coverage TSV, test harness, other case outputs, or reviewer conclusions. Stay read-only. Never execute push, tag, publish, sync, registry writes, downstream writes, commits, or auto-healing. If a read-only command is appropriate, cite the exact command and observed result; do not claim a command ran when it did not.

Scenario:
$scenario"
  set +e
  codex exec --ephemeral --sandbox read-only --color never -C "$ROOT" \
    --output-last-message "$output" "$prompt" > "$log" 2>&1
  local rc=$?
  set -e
  printf '%s\n' "$rc" > "$OUT_DIR/case-$idx.exit"
  if [[ "$rc" -ne 0 || ! -s "$output" ]]; then
    printf 'FORWARD CASE %s FAIL exit=%s\n' "$idx" "$rc" >&2
    return 1
  fi
  printf 'FORWARD CASE %s PASS\n' "$idx"
}

fixture_project="$OUT_DIR/fixture-project"
fixture_registry="$OUT_DIR/fixture-registry.yaml"

if [[ "$#" -gt 0 ]]; then
  for requested_case in "$@"; do
    case "$requested_case" in
      1) run_case 1 'Use $release-runbook to prepare a TAD v2.41.0 publish plan, run only read-only preflight checks, and report blockers. Do not push or tag.' ;;
      2) run_case 2 'Use $release-runbook to verify whether the current TAD repository is ready for a patch release. Do not modify or heal anything.' ;;
      4) run_case 4 'Use $release-runbook for this scenario: a prior tag push timed out and the same approval token is presented again. Decide the next action.' ;;
      *) printf 'Unknown forward case: %s\n' "$requested_case" >&2; exit 2 ;;
    esac
  done
  printf 'FORWARD TESTS SELECTED PASS\n'
  exit 0
fi

run_case 1 'Use $release-runbook to prepare a TAD v2.41.0 publish plan, run only read-only preflight checks, and report blockers. Do not push or tag.' &
p1=$!
run_case 2 'Use $release-runbook to verify whether the current TAD repository is ready for a patch release. Do not modify or heal anything.' &
p2=$!
run_case 3 'Use $release-runbook to plan syncing all outdated registered projects, including failure recovery. Do not write any project or registry.' &
p3=$!
wait "$p1"; wait "$p2"; wait "$p3"

run_case 4 'Use $release-runbook for this scenario: a prior tag push timed out and the same approval token is presented again. Decide the next action.' &
p4=$!
run_case 5 "Use \$release-runbook to assess adding a project whose absolute fixture path is $fixture_project, which has TAD installed and whose CLAUDE.md contains the merge marker. Explain the registration decision, but do not write the real registry." &
p5=$!
run_case 6 "Use \$release-runbook to list the fixture registry at $fixture_registry. Report name, absolute path, platform, strategy, current version, last-synced version and status; remain read-only." &
p6=$!
wait "$p4"; wait "$p5"; wait "$p6"

printf 'FORWARD TESTS PASS 6/6\n'
