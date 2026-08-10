#!/usr/bin/env bash
set -euo pipefail

FIXTURE_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd -P)
SKILL="$FIXTURE_ROOT/.claude/skills/release-runbook/SKILL.md"
PUB="$FIXTURE_ROOT/.claude/skills/release-runbook/references/publish-ops.md"
SYNC="$FIXTURE_ROOT/.claude/skills/release-runbook/references/sync-ops.md"

section_text() {
  ruby -e '
    file, wanted = ARGV
    lines = File.readlines(file)
    start = nil
    level = nil
    lines.each_with_index do |line, i|
      if (m = line.match(/^(#+)\s+(.*)$/)) && m[2].strip == wanted
        start = i + 1
        level = m[1].length
        break
      end
    end
    exit 3 unless start
    out = []
    lines[start..].to_a.each do |line|
      m = line.match(/^(#+)\s+/)
      break if m && m[1].length <= level
      out << line
    end
    print out.join
  ' "$1" "$2"
}

require_terms() {
  local file=$1 section=$2
  shift 2
  local text_value
  text_value=$(section_text "$file" "$section" | tr '\n' ' ') || return 1
  local term
  for term in "$@"; do
    [[ "$text_value" == *"$term"* ]] || return 1
    local mutated=${text_value//"$term"/}
    [[ "$mutated" != *"$term"* ]] || return 1
  done
}

gate_decision() {
  local policy=$1 release_type=$2 exit_code=$3 direction=${4:-}
  case "$policy:$exit_code" in
    parity:0) echo PASS ;;
    parity:1) [[ "$direction" == claude-newer ]] && echo REMEDIATION_CONTRACT || echo BLOCK ;;
    parity:2) echo HARD_BLOCK ;;
    version:0|migration:0) echo PASS ;;
    version:1|migration:1) [[ "$release_type" == patch ]] && echo ADVISORY || echo BLOCK ;;
    version:2|migration:2) echo HARD_BLOCK ;;
    sweep:0) echo PASS ;;
    sweep:1|sweep:2) echo HARD_BLOCK ;;
    target:0|platform:0) echo ADVANCE ;;
    target:1|platform:1) echo BLOCK ;;
    target:2|platform:2) echo HARD_BLOCK ;;
    *) echo INVALID ;;
  esac
}

fixture_root_guard() (
  require_terms "$SKILL" "Source identity guard" \
    'test "$cwd_physical" = "$repo_root"' \
    'https://github.com/Sheldon-92/TAD.git' \
    'git@github.com:Sheldon-92/TAD.git' \
    'Substring matches, forks, nested cwd' || return 1

  local tmp guard repo form
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  guard="$tmp/guard.sh"
  section_text "$SKILL" "Source identity guard" | awk '/^```bash$/{on=1;next} /^```$/{if(on) exit} on' > "$guard"
  [[ -s "$guard" ]] || return 1
  for form in \
    https://github.com/Sheldon-92/TAD \
    https://github.com/Sheldon-92/TAD.git \
    git@github.com:Sheldon-92/TAD.git \
    ssh://git@github.com/Sheldon-92/TAD.git; do
    repo="$tmp/repo-${form//[^a-zA-Z0-9]/_}"
    git init -q "$repo"
    git -C "$repo" remote add origin "$form"
    (cd "$repo" && bash "$guard") || return 1
  done
  repo="$tmp/evil"
  git init -q "$repo"
  git -C "$repo" remote add origin https://evil.example/Sheldon-92/TAD-backup.git
  if (cd "$repo" && bash "$guard"); then return 1; fi
  repo="$tmp/nested"
  git init -q "$repo"
  git -C "$repo" remote add origin https://github.com/Sheldon-92/TAD.git
  mkdir -p "$repo/sub"
  if (cd "$repo/sub" && bash "$guard"); then return 1; fi
  ln -s "$repo" "$tmp/repo-link"
  (cd "$tmp/repo-link" && bash "$guard") || return 1
)

approval_decision() {
  local state=$1 expected_digest=$2 actual_digest=$3
  if [[ "$state" == unused && -n "$expected_digest" && "$expected_digest" == "$actual_digest" ]]; then
    echo CONSUME_AND_LAUNCH
  else
    echo DENY
  fi
}

claim_approval() {
  local task_state_dir=$1 approval_id=$2 expected_digest=$3 actual_digest=$4
  [[ -n "$approval_id" && -n "$expected_digest" && "$expected_digest" == "$actual_digest" ]] || return 1
  mkdir -p "$task_state_dir/approval-claims"
  mkdir "$task_state_dir/approval-claims/$approval_id" 2>/dev/null || return 1
  printf '%s\n' "$actual_digest" > "$task_state_dir/approval-claims/$approval_id/scope-digest"
  printf '%s\n' consumed-before-launch > "$task_state_dir/approval-claims/$approval_id/approval-state"
  printf '%s\n' launched > "$task_state_dir/approval-claims/$approval_id/action-state"
}

fixture_atomic_approval_claim() (
  local tmp winners
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  claim_approval "$tmp" approval-1 digest-1 digest-1 && printf 'winner\n' >> "$tmp/winners" &
  local pid1=$!
  claim_approval "$tmp" approval-1 digest-1 digest-1 && printf 'winner\n' >> "$tmp/winners" &
  local pid2=$!
  wait "$pid1" || true
  wait "$pid2" || true
  winners=$(wc -l < "$tmp/winners" | tr -d ' ')
  [[ "$winners" -eq 1 ]]
  [[ "$(cat "$tmp/approval-claims/approval-1/approval-state")" == consumed-before-launch ]]
  [[ "$(cat "$tmp/approval-claims/approval-1/action-state")" == launched ]]
  ! claim_approval "$tmp" approval-1 digest-1 digest-1
)

fixture_approval_state() {
  require_terms "$SKILL" "Human approval: consume once before launch" \
    'scope_digest: <exact command class + targets + version/ref + write scope>' \
    'consumed-before-launch' \
    'create `$task_state_dir/approval-claims/$approval_id` with one `mkdir` operation' \
    'A failed `mkdir` is DENY' \
    'Never reset a consumed approval to unused.' || return 1
  [[ "$(approval_decision unused abc abc)" == CONSUME_AND_LAUNCH ]]
  [[ "$(approval_decision consumed-before-launch abc abc)" == DENY ]]
  [[ "$(approval_decision unused abc changed)" == DENY ]]
  [[ "$(approval_decision unused '' '')" == DENY ]]
  fixture_atomic_approval_claim || return 1
  require_terms "$SKILL" "Ambiguous-result recovery" \
    '`not-started` may be retried only with a new approval' \
    '`partial`/`unknown` return to Alex-Lite.'
}

fixture_parity_gate() {
  require_terms "$PUB" "2.1 Canonical skill parity" '`agents-newer` or' '`2`: hard block' 'parity --fix' || return 1
  [[ "$(gate_decision parity patch 0)" == PASS ]]
  [[ "$(gate_decision parity patch 1 claude-newer)" == REMEDIATION_CONTRACT ]]
  [[ "$(gate_decision parity patch 1 agents-newer)" == BLOCK ]]
  [[ "$(gate_decision parity patch 2)" == HARD_BLOCK ]]
}

fixture_version_gate() {
  require_terms "$PUB" "2.2 Version zero-stale gate" 'Block minor/major' '`2`: hard block' || return 1
  [[ "$(gate_decision version patch 1)" == ADVISORY ]]
  [[ "$(gate_decision version minor 1)" == BLOCK ]]
  [[ "$(gate_decision version major 2)" == HARD_BLOCK ]]
}

fixture_version_sweep() {
  require_terms "$PUB" "2.3 Full version sweep" 'Layer 1 is blocking' 'Layer 2 findings' 'advisory' || return 1
  [[ "$(gate_decision sweep patch 1)" == HARD_BLOCK ]]
  [[ "$(gate_decision sweep major 2)" == HARD_BLOCK ]]
}

fixture_migration_gate() {
  require_terms "$PUB" "2.4 Migration-manifest gate" 'Block minor/major' '`2`: hard block' 'Do not create an inline migration or verifier wrapper.' || return 1
  [[ "$(gate_decision migration patch 1)" == ADVISORY ]]
  [[ "$(gate_decision migration minor 1)" == BLOCK ]]
  [[ "$(gate_decision migration major 2)" == HARD_BLOCK ]]
}

fixture_publish_sequence() {
  require_terms "$PUB" "4. Human-gated publish sequence" \
    'Each irreversible command below needs its own unused approval ID' \
    'tag -a' \
    'push only that tag' \
    'Never use `--force`, `--tags`, an unscoped refspec, or a combined shell chain.'
}

fixture_post_publish() {
  require_terms "$PUB" "6. Post-publish verification and report" \
    'remote main SHA equals the approved commit' \
    'peeled tag resolve to' \
    'Post-publish verification does not itself authorize sync.'
}

fixture_platform_strategy() {
  require_terms "$SYNC" "4. Platform strategy and safe preparation" \
    'Every target receives both authoritative skill trees' \
    'Platform selects settings, workflows, hooks, and entry-document strategy' \
    'Back up an existing entry document' \
    'require `<!-- TAD:PROJECT-CONTENT-BELOW -->`'
}

migration_result() {
  case "$1" in 0) echo CONTINUE ;; 1|2) echo PARTIAL_STOP ;; *) echo INVALID ;; esac
}

fixture_migration_partial() {
  require_terms "$SYNC" "5. Execute one target" \
    '`1`: target is `partial`' \
    '`2`: invalid manifest/chain/wiring after copy also means `partial`' \
    'stop the entire batch' \
    'The migration engine is the sole migration executor.' || return 1
  [[ "$(migration_result 0)" == CONTINUE ]]
  [[ "$(migration_result 1)" == PARTIAL_STOP ]]
  [[ "$(migration_result 2)" == PARTIAL_STOP ]]
}

in_deprecation_range() {
  ruby -e '
    old_v, dep_v, current_v = ARGV.map { |v| v.split(".").map(&:to_i) }
    puts((old_v <=> dep_v) < 0 && (dep_v <=> current_v) <= 0 ? "yes" : "no")
  ' "$1" "$2" "$3"
}

fixture_deprecation_range() {
  require_terms "$SYNC" "5. Execute one target" '`old_version < deprecation_version <= current_version`' || return 1
  require_terms "$SYNC" "3. Managed Write Surface" 'Zero-touch directories from `--zero-touch`' 'remain unchanged.' || return 1
  [[ "$(in_deprecation_range 2.9.0 2.10.0 2.10.0)" == yes ]]
  [[ "$(in_deprecation_range 2.10.0 2.10.0 2.11.0)" == no ]]
  [[ "$(in_deprecation_range 2.9.0 2.12.0 2.11.0)" == no ]]
}

fixture_structural_gate() {
  require_terms "$SYNC" "6. Verify before advancement" 'Patch releases do not bypass target verification.' 'Only a target with both exit codes `0`' || return 1
  [[ "$(gate_decision target patch 0)" == ADVANCE ]]
  [[ "$(gate_decision target patch 1)" == BLOCK ]]
  [[ "$(gate_decision target patch 2)" == HARD_BLOCK ]]
}

fixture_platform_gate() {
  require_terms "$SYNC" "6. Verify before advancement" 'platform-skills' '`1` is named drift/missing and blocks advancement' || return 1
  [[ "$(gate_decision platform minor 0)" == ADVANCE ]]
  [[ "$(gate_decision platform minor 1)" == BLOCK ]]
  [[ "$(gate_decision platform minor 2)" == HARD_BLOCK ]]
}

fixture_downstream_git() {
  require_terms "$SYNC" "7. Registry advancement and optional downstream git" \
    'Downstream commit and downstream push are two more independent human gates.' \
    'Stage only paths generated from the Managed Write Surface' \
    'never `git add -A`, `.tad/`, or `docs/` broadly.'
}

fixture_sync_summary() {
  require_terms "$SYNC" "9. Summary and recovery" \
    '`verified`, `partial`, `failed`, `skipped`, or `not-started`' \
    'A partial batch is not success.' \
    'consumed approvals remain consumed'
}

fixture_registration_path() (
  require_terms "$SYNC" '8. `sync-add` registration' 'absolute canonical path' '`.tad/`' 'readable version' || return 1
  local tmp
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  [[ "relative/path" != /* ]]
  [[ ! -d "$tmp/no-tad/.tad" ]]
  mkdir -p "$tmp/with-tad/.tad"
  [[ ! -r "$tmp/with-tad/.tad/version.txt" ]]
  printf '2.40.0\n' > "$tmp/with-tad/.tad/version.txt"
  [[ -r "$tmp/with-tad/.tad/version.txt" ]]
)

fixture_registration_strategy() {
  require_terms "$SYNC" '8. `sync-add` registration' \
    'marker present: propose `merge`' \
    'marker absent: propose `overwrite`' \
    'Registration does not claim a sync occurred.'
}

fixture_list_fields() {
  require_terms "$SYNC" "1. Registry and read-only listing" \
    'name, absolute path, platform, strategy' \
    'current version' \
    'last-synced version/date' \
    'Do not update stale metadata while listing.'
}

run_behavior_fixture() {
  local fixture_name=$1
  "fixture_$fixture_name"
}
