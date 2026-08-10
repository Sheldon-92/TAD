#!/usr/bin/env bash
set -euo pipefail

EVID_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
ROOT=$(cd "$EVID_DIR/../../../.." && pwd -P)
COVERAGE="$EVID_DIR/coverage.tsv"
SKILL="$ROOT/.claude/skills/release-runbook/SKILL.md"
PUB="$ROOT/.claude/skills/release-runbook/references/publish-ops.md"
SYNC="$ROOT/.claude/skills/release-runbook/references/sync-ops.md"
REVIEW="$ROOT/.tad/evidence/reviews/blake/release-runbook-capability-migration/implementation-review.md"
source "$EVID_DIR/behavior-fixtures.sh"

fail() {
  printf '%s FAIL %s\n' "$1" "$2" >&2
  exit 1
}

pass() {
  printf '%s PASS\n' "$1"
}

run_ac1() {
  test -f "$SKILL"
  test -f "$PUB"
  test -f "$SYNC"
  test ! -e "$ROOT/.claude/skills/release-runbook/scripts"
  test ! -e "$ROOT/.claude/skills/release-runbook/scripts/release-verify-wrapper.sh"
  pass AC1
}

run_ac2() {
  local keys lines
  keys=$(awk 'NR==1{next} /^---$/{exit} /^[a-zA-Z_]+:/{print $1}' "$SKILL" | tr -d ':' | LC_ALL=C sort)
  [[ "$keys" == $'description\nname' ]] || fail AC2 frontmatter-keys
  lines=$(wc -l < "$SKILL" | tr -d ' ')
  [[ "$lines" -le 240 ]] || fail AC2 line-budget
  grep -Fq '[references/publish-ops.md](references/publish-ops.md)' "$SKILL"
  grep -Fq '[references/sync-ops.md](references/sync-ops.md)' "$SKILL"
  ruby -e '
    require "yaml"
    text = File.read(ARGV[0])
    fm = text.split(/^---\s*$\n?/)[1]
    value = YAML.safe_load(fm, permitted_classes: [], aliases: false)
    abort unless value.keys.sort == %w[description name]
  ' "$SKILL"
  pass AC2
}

run_ac3() {
  local expected_header actual_header row_count
  expected_header=$'id\tsource_file\tsource_anchor\tdisposition\ttarget_file\ttarget_section\tassertion_type\tassertion_value\tverification_fixture\trationale'
  IFS= read -r actual_header < "$COVERAGE"
  [[ "$actual_header" == "$expected_header" ]] || fail AC3 header
  row_count=$(( $(wc -l < "$COVERAGE") - 1 ))
  [[ "$row_count" -eq 27 ]] || fail AC3 row-count

  local expected_ids actual_ids
  expected_ids=$(printf '%s\n' REL-01 REL-02 REL-03 REL-04 PUB-01 PUB-02 PUB-03 PUB-04 PUB-05 PUB-06 PUB-07 PUB-08 SYNC-01 SYNC-02 SYNC-03 SYNC-04 SYNC-05 SYNC-06 SYNC-07 SYNC-08 SYNC-09 SYNC-10 SYNC-11 SYNC-12 REG-01 REG-02 LIST-01 | LC_ALL=C sort)
  actual_ids=$(tail -n +2 "$COVERAGE" | cut -f1 | LC_ALL=C sort)
  [[ "$actual_ids" == "$expected_ids" ]] || fail AC3 id-set

  local high_risk
  high_risk='REL-01 REL-04 PUB-03 PUB-04 PUB-05 PUB-06 PUB-07 PUB-08 SYNC-04 SYNC-07 SYNC-08 SYNC-09 SYNC-10 SYNC-11 SYNC-12 REG-01 REG-02 LIST-01'

  while IFS=$'\t' read -r id source_file source_anchor disposition target_file target_section assertion_type assertion_value verification_fixture rationale; do
    [[ -n "$id" && -n "$source_file" && -n "$source_anchor" && -n "$disposition" && -n "$target_file" && -n "$target_section" && -n "$assertion_type" && -n "$assertion_value" && -n "$verification_fixture" && -n "$rationale" ]] || fail AC3 "blank-field-$id"
    [[ "$disposition" == mapped || "$disposition" == superseded ]] || fail AC3 "bad-disposition-$id"
    [[ "$assertion_type" == section-literal || "$assertion_type" == behavior-fixture ]] || fail AC3 "bad-assertion-$id"
    test -f "$ROOT/$source_file" || fail AC3 "missing-source-$id"
    test -f "$ROOT/$target_file" || fail AC3 "missing-target-$id"
    grep -Fq "$source_anchor" "$ROOT/$source_file" || fail AC3 "missing-source-anchor-$id"
    section_text "$ROOT/$target_file" "$target_section" >/dev/null || fail AC3 "missing-target-section-$id"
    if [[ " $high_risk " == *" $id "* && "$assertion_type" != behavior-fixture ]]; then
      fail AC3 "high-risk-not-fixture-$id"
    fi
    if [[ "$assertion_type" == section-literal ]]; then
      local body mutated
      body=$(section_text "$ROOT/$target_file" "$target_section" | tr '\n' ' ')
      [[ "$body" == *"$assertion_value"* ]] || fail AC3 "literal-missing-$id"
      mutated=${body/"$assertion_value"/}
      [[ "$mutated" != *"$assertion_value"* ]] || fail AC3 "literal-negative-mutation-$id"
    else
      run_behavior_fixture "$verification_fixture" || fail AC3 "fixture-$id"
    fi
  done < <(tail -n +2 "$COVERAGE")
  pass AC3
}

run_ac4() {
  require_terms "$SKILL" "Roles and modes" '`plan`' '`execute`' '`verify`'
  require_terms "$SKILL" "Effective permission and task-state owner" 'Lite role ∩ this skill' 'single task-state owner'
  fixture_approval_state
  pass AC4
}

run_ac5() {
  fixture_root_guard
  fixture_parity_gate
  fixture_version_gate
  fixture_version_sweep
  fixture_migration_gate
  fixture_migration_partial
  local report deny_count deny_name
  report=$(bash "$ROOT/.tad/hooks/lib/derive-sync-set.sh" --report "$ROOT")
  deny_count=$(printf '%s\n' "$report" | grep -cE '^  \(\+ top-level file: [^)]+\)$')
  [[ "$deny_count" -eq 1 ]] || fail AC5 top-deny-count
  deny_name=$(printf '%s\n' "$report" | sed -nE 's/^  \(\+ top-level file: ([^)]+)\)$/\1/p')
  [[ "$deny_name" == sync-registry.yaml ]] || fail AC5 top-deny-name
  grep -Fq 'Historical `TAD_RELEASE_GATE=warn` instructions are superseded and inactive.' "$SKILL"
  if grep -Fq 'run with `TAD_RELEASE_GATE=warn`' "$SKILL" "$PUB" "$SYNC"; then fail AC5 active-warn-path; fi
  pass AC5
}

run_ac6() {
  local pre_dir="$EVID_DIR/stable5-pre" post_dir="$EVID_DIR/stable5-post"
  test -d "$pre_dir" || fail AC6 missing-stable-pre
  test -d "$post_dir" || fail AC6 missing-stable-post
  for rel in head.txt refs.txt remote-refs.txt sync-registry.sha256 deprecation.sha256 carrier-hashes.tsv \
    derived-dirs.txt derived-dirs.stderr derived-dirs.exit \
    derive-report.txt derive-report.stderr derive-report.exit \
    zero-touch.txt zero-touch.stderr zero-touch.exit \
    registry-only.txt registry-only.stderr registry-only.exit top-deny.txt; do
    cmp -s "$pre_dir/source/$rel" "$post_dir/source/$rel" || fail AC6 "source-$rel-changed"
  done
  cmp -s "$pre_dir/source/status.z" "$post_dir/source/status.z" || fail AC6 source-worktree-status-changed
  diff -rq "$pre_dir/targets" "$post_dir/targets" >/dev/null || fail AC6 registered-target-state-changed
  pass AC6
}

run_ac7() {
  test ! -e "$ROOT/.claude/skills/release-runbook/local"
  test ! -e "$ROOT/.agents/skills/release-runbook/local"
  diff -rq "$ROOT/.claude/skills/release-runbook" "$ROOT/.agents/skills/release-runbook" >/dev/null
  pass AC7
}

run_ac8() {
  local rubric="$EVID_DIR/forward/rubric.tsv"
  test -f "$rubric" || fail AC8 missing-rubric
  [[ $(( $(wc -l < "$rubric") - 1 )) -eq 6 ]] || fail AC8 case-count
  awk -F '\t' 'NR==1 { next } NF != 9 { exit 1 } $3!=1 || $4!=1 || $5!=1 || $6!=1 || $7!=1 || $8!=0 { exit 1 } $9!="PASS" { exit 1 } END { if (NR != 7) exit 1 }' "$rubric" || fail AC8 rubric
  local idx
  for idx in 1 2 3 4 5 6; do test -s "$EVID_DIR/forward/case-$idx.md" || fail AC8 "missing-output-$idx"; done
  pass AC8
}

run_ac9() {
  local output
  output=$(bash "$EVID_DIR/negative-fixtures.sh") || fail AC9 fixtures
  [[ "$(printf '%s\n' "$output" | grep -cE '^NEG-[0-9][0-9] PASS ')" -eq 10 ]] || fail AC9 group-count
  printf '%s\n' "$output" > "$EVID_DIR/negative-results.txt"
  pass AC9
}

run_ac10() {
  local current_hashes="$EVID_DIR/current-carrier-hashes.tsv"
  for rel in \
    .claude/skills/alex/references/publish-protocol.md \
    .claude/skills/alex/references/sync-protocol.md \
    .claude/skills/alex/references/sync-add-protocol.md \
    .claude/skills/alex/references/sync-list-protocol.md; do
    printf '%s\t%s\n' "$rel" "$(shasum -a 256 "$ROOT/$rel" | awk '{print $1}')"
  done > "$current_hashes"
  cmp -s "$EVID_DIR/stable5-pre/source/carrier-hashes.tsv" "$current_hashes" || fail AC10 carrier-changed

  filter_forbidden_status() {
    ruby -e '
    STDIN.read.split("\0").each do |row|
      next if row.empty?
      path = row.sub(/\A.. /, "")
      basename = File.basename(path)
      if path.start_with?(".tad/hooks/") || path.start_with?(".codex/agents/") ||
         ["tad.sh", ".codex/hooks.json", ".codex/config.toml"].include?(path) ||
         basename.match?(/(?:install(?:er)?|runtime|router|settings)/)
        puts row
      end
    end
  '
  }

  local pre_forbidden current_forbidden synthetic_forbidden
  pre_forbidden=$(filter_forbidden_status < "$EVID_DIR/stable5-pre/source/status.z" | LC_ALL=C sort)
  current_forbidden=$(git -C "$ROOT" status --porcelain=v1 -z | filter_forbidden_status | LC_ALL=C sort)
  synthetic_forbidden=$(printf ' M .codex/hooks.json\0 M bin/tad-install.mjs\0 M .tad/hooks/preflight.sh\0' | filter_forbidden_status | LC_ALL=C sort)
  [[ "$(printf '%s\n' "$synthetic_forbidden" | wc -l | tr -d ' ')" -eq 3 ]] || fail AC10 forbidden-detector-negative-control
  [[ "$current_forbidden" == "$pre_forbidden" ]] || fail AC10 forbidden-runtime-status-changed

  local expected actual task_base current_delta path_value
  expected=$(printf '%s\n' \
    .agents/skills/release-runbook/SKILL.md \
    .agents/skills/release-runbook/references/publish-ops.md \
    .agents/skills/release-runbook/references/sync-ops.md \
    .claude/skills/release-runbook/SKILL.md \
    .claude/skills/release-runbook/references/publish-ops.md \
    .claude/skills/release-runbook/references/sync-ops.md | LC_ALL=C sort)
  task_base=$(cat "$EVID_DIR/stable5-pre/source/head.txt")
  git -C "$ROOT" cat-file -e "$task_base^{commit}" 2>/dev/null || fail AC10 missing-task-base
  actual=$(git -C "$ROOT" diff --name-only "$task_base" -- \
    .claude/skills/release-runbook .agents/skills/release-runbook | LC_ALL=C sort)
  [[ "$actual" == "$expected" ]] || fail AC10 product-path-set

  current_delta=$(git -C "$ROOT" status --porcelain=v1 -uall -- \
    .claude/skills/release-runbook .agents/skills/release-runbook | sed -E 's/^.. //' | LC_ALL=C sort)
  if [[ -z "$current_delta" ]]; then
    current_delta=$(git -C "$ROOT" diff-tree --no-commit-id --name-only -r HEAD -- \
      .claude/skills/release-runbook .agents/skills/release-runbook | LC_ALL=C sort)
  fi
  [[ -n "$current_delta" ]] || fail AC10 empty-current-delta
  while IFS= read -r path_value; do
    printf '%s\n' "$expected" | grep -Fxq -e "$path_value" || fail AC10 "repair-path-outside-scope-$path_value"
  done <<< "$current_delta"
  pass AC10
}

run_ac11() {
  run_ac1 >/dev/null
  run_ac2 >/dev/null
  run_ac7 >/dev/null
  test -f "$REVIEW" || fail AC11 missing-review
  grep -Eq '^Verdict: PASS$' "$REVIEW" || fail AC11 review-verdict
  grep -Eq '^P0: 0$' "$REVIEW" || fail AC11 review-p0
  grep -Eq '^P1: 0$' "$REVIEW" || fail AC11 review-p1
  grep -Eq '^P2: 0$' "$REVIEW" || fail AC11 review-p2
  pass AC11
}

run_one() {
  case "$1" in
    AC1) run_ac1 ;; AC2) run_ac2 ;; AC3) run_ac3 ;; AC4) run_ac4 ;; AC5) run_ac5 ;;
    AC6) run_ac6 ;; AC7) run_ac7 ;; AC8) run_ac8 ;; AC9) run_ac9 ;; AC10) run_ac10 ;;
    AC11) run_ac11 ;; *) fail VERIFY unknown-ac ;;
  esac
}

requested=${1:-all}
if [[ "$requested" == all ]]; then
  for ac in AC1 AC2 AC3 AC4 AC5 AC6 AC7 AC8 AC9 AC10 AC11; do run_one "$ac"; done
else
  run_one "$requested"
fi
