#!/usr/bin/env bash
set -euo pipefail

EVID_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
ROOT=$(cd "$EVID_DIR/../../../.." && pwd -P)
source "$EVID_DIR/behavior-fixtures.sh"

PASS_COUNT=0
group_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'NEG-%02d PASS %s\n' "$1" "$2"
}

fixture_root_guard
group_pass 1 malicious-origin-nested-cwd-symlink-root

[[ "$(approval_decision '' abc abc)" == DENY ]]
[[ "$(approval_decision unused abc changed)" == DENY ]]
group_pass 2 missing-or-mismatched-approval

[[ "$(approval_decision consumed-before-launch abc abc)" == DENY ]]
[[ "$(approval_decision completed abc abc)" == DENY ]]
fixture_atomic_approval_claim
group_pass 3 replay-and-concurrent-resume

require_terms "$SKILL" "Ambiguous-result recovery" \
  'Timeout, disconnect, truncated output, or unknown exit after launch means stop, not retry.' \
  '`not-started` may be retried only with a new approval ID and digest'
group_pass 4 ambiguous-timeout-no-retry

for policy in parity version migration sweep target platform; do
  [[ "$(gate_decision "$policy" minor 2)" == HARD_BLOCK ]]
done
group_pass 5 exit-two-hard-blocks

[[ "$(gate_decision parity patch 1 agents-newer)" == BLOCK ]]
require_terms "$PUB" "2.1 Canonical skill parity" '`agents-newer` or' 'must refuse'
group_pass 6 agents-newer-refuses-fix

migration_batch_fixture() (
  local injected_exit=$1 fixture_tmp target
  fixture_tmp=$(mktemp -d)
  trap 'rm -rf "$fixture_tmp"' EXIT
  mkdir -p "$fixture_tmp/source/.tad" "$fixture_tmp/target-1/.tad" "$fixture_tmp/target-2/.tad"
  printf 'framework-current\n' > "$fixture_tmp/source/.tad/framework.txt"
  printf 'target-one-old\n' > "$fixture_tmp/target-1/.tad/framework.txt"
  printf 'target-two-old\n' > "$fixture_tmp/target-2/.tad/framework.txt"
  printf 'registry-before\n' > "$fixture_tmp/registry"
  : > "$fixture_tmp/success-list"
  : > "$fixture_tmp/commit-log"
  : > "$fixture_tmp/push-log"

  fixture_migration_engine() {
    local selected_target=$1 selected_exit=$2
    mkdir -p "$selected_target/.tad-backup"
    cp "$selected_target/.tad/framework.txt.before-copy" "$selected_target/.tad-backup/framework.txt"
    if [[ "$selected_exit" -eq 1 ]]; then
      printf 'injected-partial-write\n' > "$selected_target/.tad/migration-partial.txt"
    fi
    return "$selected_exit"
  }

  for target in "$fixture_tmp/target-1" "$fixture_tmp/target-2"; do
    cp "$target/.tad/framework.txt" "$target/.tad/framework.txt.before-copy"
    cp "$fixture_tmp/source/.tad/framework.txt" "$target/.tad/framework.txt"
    if ! fixture_migration_engine "$target" "$injected_exit"; then
      printf 'partial\n' > "$target/state"
      break
    fi
    printf '%s\n' "$target" >> "$fixture_tmp/success-list"
  done

  [[ "$(cat "$fixture_tmp/target-1/state")" == partial ]]
  [[ -f "$fixture_tmp/target-1/.tad-backup/framework.txt" ]]
  [[ "$(cat "$fixture_tmp/target-1/.tad-backup/framework.txt")" == target-one-old ]]
  if [[ "$injected_exit" -eq 1 ]]; then
    [[ "$(cat "$fixture_tmp/target-1/.tad/migration-partial.txt")" == injected-partial-write ]]
  else
    [[ ! -e "$fixture_tmp/target-1/.tad/migration-partial.txt" ]]
  fi
  [[ "$(cat "$fixture_tmp/target-2/.tad/framework.txt")" == target-two-old ]]
  [[ ! -e "$fixture_tmp/target-2/.tad/framework.txt.before-copy" ]]
  [[ "$(cat "$fixture_tmp/registry")" == registry-before ]]
  [[ ! -s "$fixture_tmp/success-list" ]]
  [[ ! -s "$fixture_tmp/commit-log" ]]
  [[ ! -s "$fixture_tmp/push-log" ]]
)

[[ "$(migration_result 1)" == PARTIAL_STOP ]]
require_terms "$SYNC" "5. Execute one target" '`1`: target is `partial`' 'forbid' 'registry advancement'
migration_batch_fixture 1
group_pass 7 migration-exit-one-partial-stop

[[ "$(migration_result 2)" == PARTIAL_STOP ]]
require_terms "$SYNC" "5. Execute one target" '`2`: invalid manifest/chain/wiring after copy also means `partial`'
migration_batch_fixture 2
group_pass 8 migration-exit-two-partial-stop

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/source/.claude/skills" "$tmp/source/.agents/skills"
cp -R "$ROOT/.claude/skills/release-runbook" "$tmp/source/.claude/skills/release-runbook"
cp -R "$ROOT/.agents/skills/release-runbook" "$tmp/source/.agents/skills/release-runbook"
for edition in claude-target codex-target; do
  mkdir -p "$tmp/$edition/.claude" "$tmp/$edition/.agents"
  cp -R "$tmp/source/.claude/skills" "$tmp/$edition/.claude/skills"
  cp -R "$tmp/source/.agents/skills" "$tmp/$edition/.agents/skills"
  bash "$ROOT/.tad/hooks/lib/release-verify.sh" platform-skills "$tmp/source" "$tmp/$edition" >/dev/null
  test -f "$tmp/$edition/.claude/skills/release-runbook/SKILL.md"
  test -f "$tmp/$edition/.agents/skills/release-runbook/SKILL.md"
done
[[ "$(gate_decision target patch 0)" == ADVANCE ]]
[[ "$(gate_decision platform patch 0)" == ADVANCE ]]
group_pass 9 dual-platform-both-mirrors-and-gates

report=$(bash "$ROOT/.tad/hooks/lib/derive-sync-set.sh" --report "$ROOT")
top_deny_count=$(printf '%s\n' "$report" | grep -cE '^  \(\+ top-level file: [^)]+\)$')
[[ "$top_deny_count" -eq 1 ]]
top_deny=$(printf '%s\n' "$report" | sed -nE 's/^  \(\+ top-level file: ([^)]+)\)$/\1/p')
[[ "$top_deny" == sync-registry.yaml ]]
require_terms "$SYNC" "3. Managed Write Surface" 'Zero or multiple records block.' 'Exclude the observed basename'
require_terms "$SYNC" '8. `sync-add` registration' 'choosing `merge` blocks until the marker exists.'
if section_text "$SYNC" "3. Managed Write Surface" | sed -n '/managed-write-surface:begin/,/managed-write-surface:end/p' | grep -q '^\.tad/sync-registry.yaml$'; then
  exit 1
fi
group_pass 10 registry-path-marker-and-top-deny-fail-closed

[[ "$PASS_COUNT" -eq 10 ]]
printf 'NEGATIVE FIXTURES PASS 10/10\n'
