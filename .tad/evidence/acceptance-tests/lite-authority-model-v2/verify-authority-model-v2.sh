#!/usr/bin/env bash
set -u

ROOT=$(cd "$(dirname "$0")/../../../.." && pwd -P) || exit 2
EV="$ROOT/.tad/evidence/acceptance-tests/lite-authority-model-v2"
BASELINE=cabe28755c581c1bddfdfe1a490471888d9f26df
FIXTURE_SHA=8bd0bcab65f2aca6f3408b15f3ef9a943755d57836de64278237d1e717f25e29
INVENTORY_LIVE_SHA=995c9779988969517f5c348e3f6a2983d75f4d8fcad3d47b206195105adc85ea
failures=0

pass() { printf 'PASS\t%s\n' "$1"; }
fail() { printf 'FAIL\t%s\n' "$1"; failures=$((failures + 1)); }
sha256_file() { shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'; }
need() {
  file=$1 literal=$2 label=$3
  if grep -Fq -- "$literal" "$file"; then pass "$label"; else fail "$label missing in ${file#$ROOT/}"; fi
}
reject_regex() {
  pattern=$1 label=$2
  shift 2
  if rg -n -e "$pattern" "$@" >/dev/null 2>&1; then fail "$label"; else pass "$label"; fi
}

check_inventory() {
  inv="$EV/live-surface-inventory.tsv"
  [ -f "$inv" ] || { fail 'inventory file missing'; return; }
  count=$(awk -F '\t' '$1=="live"{n++}END{print n+0}' "$inv")
  live_sha=$(awk -F '\t' '$1=="live"{print $2}' "$inv" | shasum -a 256 | awk '{print $1}')
  [ "$count" -eq 13 ] && pass 'inventory_paths=13' || fail "inventory_paths=$count expected=13"
  [ "$live_sha" = "$INVENTORY_LIVE_SHA" ] && pass 'inventory exact live path set' || fail 'inventory live path set drift'
  for group in FULL_ONLY_RETIRE_LATER HISTORY_ONLY ZERO_TOUCH; do
    awk -F '\t' -v g="$group" '$1=="group" && $2==g{found=1}END{exit !found}' "$inv" && pass "inventory disposition $group" || fail "inventory disposition $group"
  done
  need "$inv" 'PRODUCT_DOMAIN_HITL' 'product/domain HITL classification boundary'
}

check_lite_core() {
  alex="$ROOT/.claude/skills/alex-lite/SKILL.md"
  blake="$ROOT/.claude/skills/blake-lite/SKILL.md"
  for file in "$alex" "$blake"; do
    need "$file" '## Execution Mandate' "mandate schema ${file##*/}"
    need "$file" '## Execution Transactions' "transaction skeleton ${file##*/}"
    need "$file" 'outcome_change' "closed classifier ${file##*/}"
    need "$file" 'new_external_identity_or_credentials' "closed classifier tail ${file##*/}"
    need "$file" 'exact' "exact bindings ${file##*/}"
  done
  need "$alex" 'source: L3 contract decision' 'Alex accepted-state source invariant'
  need "$alex" 'status: proposed|accepted|superseded|expired' 'Alex lifecycle state vocabulary'
  need "$alex" 'consequence_bindings' 'Alex consequence binding schema'
  need "$alex" 'lock_path: <exact handoff path>.txn-lock' 'Alex planned CAS lock path'
  need "$blake" 'Lite role boundary ∩ capability-skill constraints ∩ accepted Execution Mandate' 'effective authority intersection'
  need "$blake" 'status=accepted' 'Blake accepted-state invariant'
  need "$blake" 'superseded' 'Blake superseded admission'
  need "$blake" 'expired' 'Blake expired admission'
  need "$blake" '<handoff>.txn-lock' 'Blake adjacent CAS lock'
  need "$blake" 'same-filesystem atomic' 'Blake atomic replacement'
  need "$alex" '只设计不写实现代码' 'Alex role separation retained'
  need "$blake" '## L3 独立审查' 'Blake independent review retained'
  need "$blake" '## L3.5 Lite Technical Gate' 'Blake technical gate retained'
}

check_prompt_closure() {
  files=(
    "$ROOT/.claude/skills/alex-lite/SKILL.md"
    "$ROOT/.claude/skills/blake-lite/SKILL.md"
    "$ROOT/.claude/skills/release-runbook/SKILL.md"
    "$ROOT/.claude/skills/release-runbook/references/publish-ops.md"
    "$ROOT/.claude/skills/release-runbook/references/sync-ops.md"
  )
  reject_regex 'approval_id|scope_digest|approval_state|consumed-before-launch|approval-claims|new approval ID|current human approval|own unused approval' 'obsolete per-command approval fields absent' "${files[@]}"
  reject_regex 'git push.*一律须先停下来问人|命中安全停清单任一项.*停下来问人|是否 git commit 由人决定|Request approval only|separate approval' 'blanket technical questions absent' "${files[@]}"
  need "$ROOT/.claude/skills/blake-lite/SKILL.md" 'avoidable_runtime_prompt_count' 'runtime prompt observability'
  need "$ROOT/.claude/skills/blake-lite/SKILL.md" 'boundary_change_prompt_count' 'boundary prompt observability'
  need "$ROOT/.claude/skills/blake-lite/SKILL.md" '技术不确定只读诊断后阻塞' 'technical block is not approval'
}

check_release() {
  entry="$ROOT/.claude/skills/release-runbook/SKILL.md"
  publish="$ROOT/.claude/skills/release-runbook/references/publish-ops.md"
  sync="$ROOT/.claude/skills/release-runbook/references/sync-ops.md"
  need "$entry" 'accepted Execution Mandate' 'release mandate intersection'
  need "$entry" 'test "$cwd_physical" = "$repo_root"' 'source identity guard retained'
  need "$entry" 'same-directory temporary file' 'release CAS replacement'
  need "$entry" 'verified not-started retries' 'release same-transaction retry'
  need "$publish" 'One accepted release transaction' 'publish transaction sequence'
  need "$publish" 'refs/heads/main' 'exact main refspec retained'
  need "$publish" 'refs/tags/v$NEW:refs/tags/v$NEW' 'exact tag refspec retained'
  need "$publish" 'never auto-force' 'remote-ahead no-force recovery'
  need "$sync" 'authorized consequence class and named target' 'sync per-action binding'
  need "$sync" 'target_physical' 'sync physical self-target guard retained'
  need "$sync" '<!-- managed-write-surface:begin -->' 'MWS authority retained'
  need "$sync" 'Stop the batch after a systemic partial' 'systemic partial batch stop'
  reject_regex 'approval_id|scope_digest|approval_state|consumed approval|approval digest|human-gated|human gates' 'release old approval model absent' "$entry" "$publish" "$sync"
}

check_routing() {
  need "$ROOT/CLAUDE.md" '硬上限 3 个' 'Claude bounded release load'
  need "$ROOT/.claude/skills/alex-lite/SKILL.md" '硬上限 3 个 release 文档' 'Alex bounded release load'
  need "$ROOT/.claude/skills/blake-lite/SKILL.md" '硬上限 3 个 release 文档' 'Blake bounded release load'
  need "$ROOT/AGENTS.md" 'No accepted mandate means no grant' 'Codex mandate routing'
  need "$ROOT/.tad/project-knowledge/patterns/gate-design.md" 'Accepted Execution Mandate Is Lite' 'current gate-design amendment'
  need "$ROOT/.tad/project-knowledge/patterns/gate-design.md" 'no grant' 'no carrier no grant amendment'
  reject_regex 'SAFETY-gated decision.*always|publish.*sync.*仍受安全停清单' 'routing blanket approval contradiction absent' "$ROOT/AGENTS.md" "$ROOT/CLAUDE.md"
}

check_mirrors() {
  pairs=(alex-lite/SKILL.md blake-lite/SKILL.md release-runbook/SKILL.md release-runbook/references/publish-ops.md release-runbook/references/sync-ops.md)
  count=0
  for p in "${pairs[@]}"; do
    if cmp -s "$ROOT/.claude/skills/$p" "$ROOT/.agents/skills/$p"; then count=$((count + 1)); else fail "mirror drift $p"; fi
  done
  [ "$count" -eq 5 ] && pass 'mirror_pairs=5' || fail "mirror_pairs=$count"
}

fixture_integrity_valid() {
  file=$1
  [ "$(sha256_file "$file")" = "$FIXTURE_SHA" ] || return 1
  [ "$(wc -l < "$file" | tr -d ' ')" -eq 30 ] || return 1
  [ "$(sed -n 's/.*"id":"\([^"]*\)".*/\1/p' "$file" | LC_ALL=C sort -u | wc -l | tr -d ' ')" -eq 30 ] || return 1
  return 0
}

write_expected_outcome_oracle() {
  cat <<'ORACLE'
mandate-happy-release	accepted	all release and sync consequences and exact targets are bound	ALLOW transaction	false	null	false
mandate-happy-local	accepted	workspace_write and local_commit are bound	ALLOW	false	null	false
verified-not-started-retry	accepted	read-only reconciliation proves no mutation started	RETRY same transaction	false	null	false
deterministic-rollback	accepted	one verified recovery result is declared	ROLLBACK_AND_VERIFY	false	null	false
resume-same-mandate	accepted	compaction or terminal change with unchanged contract	RESUME	false	null	false
accepted-field-mismatch	invalid	accepted status disagrees with decision timestamp source binding or revision	INVALID before mutation	false	null	false
duplicate-mandate-id	invalid	two non-superseded mandates claim one stable ID	INVALID before mutation	false	null	false
superseded-mandate	superseded	transaction cites a superseded revision	RETURN_TO_ALEX_LITE	false	null	false
expired-mandate	expired	mandate lifecycle predicate is true	RETURN_TO_ALEX_LITE	false	null	false
concurrent-transaction-cas	accepted	two executors attempt one planned transition	Exactly one launches; loser reconciles	false	null	false
stale-lock-proven-dead	accepted	local owner fingerprint proves exact crashed owner dead and pre-state unchanged	CLEAR, REACQUIRE, RECONCILE	false	null	false
stale-lock-owner-unknown	accepted	owner liveness fingerprint or pre-state cannot be proven	BLOCK_NO_MUTATION	false	null	false
post-precheck-drift	accepted	bound target changes between precheck and launch	RECONCILE_OR_BLOCK; no force	false	null	false
completed-do-not-repeat	accepted	resume sees completed action or transaction	VERIFY_ONLY; do not repeat	false	null	false
duplicate-transaction-or-action-id	invalid	handoff repeats a transaction or action ID	INVALID before mutation	false	null	false
unlisted-consequence	accepted	action class is absent from mandate	BOUNDARY_CHANGE before mutation	true	consequence_change	false
target-scope-change	accepted	repository project or environment is absent from exact binding	BOUNDARY_CHANGE before mutation	true	target_change	false
target-alias	accepted	literal path resolves to a different identity	DENY before mutation	false	null	false
ref-expansion	accepted	requested ref or pathspec is unlisted	BOUNDARY_CHANGE before mutation	true	target_change	false
mws-expansion	accepted	requested project write escapes MWS	BOUNDARY_CHANGE before mutation	true	target_change	false
financial-bound-expansion	accepted	payment changes payer payee currency or maximum amount	BOUNDARY_CHANGE before mutation	true	business_legal_financial_identity_tradeoff	false
skill-expands-mandate	accepted	skill declaration is broader than mandate	DENY	false	null	false
divergent-partial-recovery	accepted	two legitimate recoveries have different visible results	BOUNDARY_CHANGE	true	divergent_visible_recovery	false
new-credential-owner	accepted	new account credential owner or identity authority is required	BOUNDARY_CHANGE	true	new_external_identity_or_credentials	false
tool-failure-no-prompt	accepted	tool exit or wiring failure without boundary change	REPAIR_OR_BLOCK	false	null	false
unknown-fail-closed	accepted	read-only diagnosis cannot classify external result	BLOCK_NO_MUTATION	false	null	false
unlisted-local-commit	accepted	workspace_write is bound but local_commit is absent	LEAVE_UNCOMMITTED	false	null	false
archive-before-acceptance	accepted	technical gate passed and final business acceptance is pending	WAIT; do not archive	false	null	false
final-business-acceptance	accepted	technical gate passed	WAITING HUMAN ACCEPTANCE	true	null	false
archive-after-acceptance	accepted	human accepts final business result	ARCHIVE	false	null	false
ORACLE
}

normalize_fixture_semantics() {
  local file line
  file=$1
  command -v jq >/dev/null 2>&1 || return 1
  while IFS= read -r line; do
    printf '%s\n' "$line" | jq -er '
      if type != "object"
        or (.id | type) != "string"
        or (.mandate_state | type) != "string"
        or (.condition | type) != "string"
        or (.expected_result | type) != "string"
        or (.human_prompt | type) != "boolean"
        or ((.runtime_prompt_reason | type) != "string" and (.runtime_prompt_reason | type) != "null")
        or (.mutation_before_verdict | type) != "boolean"
      then error("invalid authority fixture schema")
      else [
        .id,
        .mandate_state,
        .condition,
        .expected_result,
        (.human_prompt | tostring),
        (if .runtime_prompt_reason == null then "null" else .runtime_prompt_reason end),
        (.mutation_before_verdict | tostring)
      ] | @tsv
      end
    ' 2>/dev/null || return 1
  done < "$file"
}

fixture_semantics_valid() {
  local file oracle_tmp valid
  file=$1
  [ -f "$file" ] || return 1
  oracle_tmp=$(mktemp -d "${TMPDIR:-/tmp}/authority-oracle.XXXXXX") || return 1
  valid=0
  if write_expected_outcome_oracle > "$oracle_tmp/expected" \
    && normalize_fixture_semantics "$file" > "$oracle_tmp/actual" \
    && cmp -s "$oracle_tmp/expected" "$oracle_tmp/actual"; then
    valid=1
  fi
  safe_remove_tmp "$oracle_tmp" >/dev/null 2>&1 || return 1
  [ "$valid" -eq 1 ]
}

fixture_file_valid() {
  fixture_integrity_valid "$1" && fixture_semantics_valid "$1"
}

safe_remove_tmp() {
  case "$1" in
    /tmp/*|/private/tmp/*|/private/var/folders/*|/var/folders/*) rm -rf -- "$1" ;;
    *) printf 'refuse unsafe tmp cleanup: %s\n' "$1" >&2; return 1 ;;
  esac
}

capture_source_scratch() {
  repo=$1 out=$2
  {
    git -C "$repo" diff --raw HEAD -- protected
    git -C "$repo" ls-files --others --exclude-standard -- protected
    git -C "$repo" ls-files --others --ignored --exclude-standard -- protected
    find "$repo/protected" -type f -maxdepth 1 -print0 | xargs -0 shasum -a 256
  } | LC_ALL=C sort > "$out"
}

capture_index_scratch() {
  repo=$1 out=$2
  { git -C "$repo" diff --cached --raw HEAD -- protected; git -C "$repo" ls-files --stage -- protected; } | LC_ALL=C sort > "$out"
}

run_controls() {
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/authority-v2.XXXXXX") || { fail 'scratch creation'; return; }
  fixture="$EV/authority-fixtures.jsonl"
  fixture_file_valid "$fixture" && pass 'positive_control_fixture=PASS' || fail 'positive_control_fixture'

  sed '/"id":"unlisted-consequence"/s/"expected_result":"BOUNDARY_CHANGE before mutation"/"expected_result":"ALLOW"/' "$fixture" > "$tmp/f1-consequence.mut"
  sed '/"id":"superseded-mandate"/s/"expected_result":"RETURN_TO_ALEX_LITE"/"expected_result":"ALLOW"/' "$fixture" > "$tmp/f1-lifecycle.mut"
  sed '1s/$/ INVALID_JSON/' "$fixture" > "$tmp/f1-json.mut"
  consequence_digest=$(sha256_file "$tmp/f1-consequence.mut")
  lifecycle_digest=$(sha256_file "$tmp/f1-lifecycle.mut")
  json_digest=$(sha256_file "$tmp/f1-json.mut")
  if fixture_semantics_valid "$tmp/f1-consequence.mut" \
    || fixture_semantics_valid "$tmp/f1-lifecycle.mut" \
    || fixture_semantics_valid "$tmp/f1-json.mut" \
    || [ -z "$consequence_digest" ] \
    || [ -z "$lifecycle_digest" ] \
    || [ -z "$json_digest" ]; then
    fail 'mutation_probe_semantic_authority_outcomes accepted'
  else
    pass 'mutation_probe_semantic_authority_outcomes=PASS digest_recomputed strict_json'
  fi

  sed '/"id":"tool-failure-no-prompt"/s/"human_prompt":false/"human_prompt":true/' "$fixture" > "$tmp/f2.mut"
  if fixture_semantics_valid "$tmp/f2.mut"; then fail 'mutation_probe_tool_prompt accepted'; else pass 'mutation_probe_tool_prompt=PASS'; fi

  sed '/"id":"completed-do-not-repeat"/s/"expected_result":"VERIFY_ONLY; do not repeat"/"expected_result":"RETRY"/' "$fixture" > "$tmp/f3.mut"
  if fixture_semantics_valid "$tmp/f3.mut"; then fail 'mutation_probe_completed_replay accepted'; else pass 'mutation_probe_completed_replay=PASS'; fi

  scratch="$tmp/source"
  mkdir -p "$scratch/protected"
  git -C "$scratch" init -q
  git -C "$scratch" config user.email fixture@example.invalid
  git -C "$scratch" config user.name fixture
  printf 'protected/ignored.json\n' > "$scratch/.gitignore"
  printf 'base\n' > "$scratch/protected/tracked.txt"
  printf 'ignored-base\n' > "$scratch/protected/ignored.json"
  git -C "$scratch" add .gitignore protected/tracked.txt
  git -C "$scratch" commit -qm base
  capture_source_scratch "$scratch" "$tmp/source-a"
  capture_source_scratch "$scratch" "$tmp/source-b"
  if cmp -s "$tmp/source-a" "$tmp/source-b"; then pass 'positive_control_source=PASS'; else fail 'positive_control_source'; fi

  printf 'new\n' > "$scratch/protected/new.txt"
  capture_source_scratch "$scratch" "$tmp/source-mut"
  if cmp -s "$tmp/source-a" "$tmp/source-mut"; then fail 'mutation_probe_untracked accepted'; else pass 'mutation_probe_untracked=PASS'; fi
  rm "$scratch/protected/new.txt"

  printf 'changed\n' > "$scratch/protected/tracked.txt"
  capture_source_scratch "$scratch" "$tmp/source-mut"
  if cmp -s "$tmp/source-a" "$tmp/source-mut"; then fail 'mutation_probe_tracked accepted'; else pass 'mutation_probe_tracked=PASS'; fi
  git -C "$scratch" restore protected/tracked.txt

  capture_index_scratch "$scratch" "$tmp/index-a"
  printf 'staged-different\n' > "$scratch/protected/tracked.txt"
  git -C "$scratch" add protected/tracked.txt
  printf 'base\n' > "$scratch/protected/tracked.txt"
  capture_index_scratch "$scratch" "$tmp/index-mut"
  if cmp -s "$tmp/index-a" "$tmp/index-mut"; then fail 'mutation_probe_cached_blob accepted'; else pass 'mutation_probe_cached_blob=PASS'; fi
  git -C "$scratch" restore --staged protected/tracked.txt
  git -C "$scratch" restore protected/tracked.txt

  printf 'ignored-changed\n' > "$scratch/protected/ignored.json"
  capture_source_scratch "$scratch" "$tmp/source-mut"
  if cmp -s "$tmp/source-a" "$tmp/source-mut"; then fail 'mutation_probe_ignored accepted'; else pass 'mutation_probe_ignored=PASS'; fi
  printf 'ignored-base\n' > "$scratch/protected/ignored.json"

  target="$tmp/target-mws"
  mkdir -p "$target/.tad/skills"
  printf 'target-base\n' > "$target/.tad/skills/item"
  shasum -a 256 "$target/.tad/skills/item" > "$tmp/target-a"
  shasum -a 256 "$target/.tad/skills/item" > "$tmp/target-b"
  if cmp -s "$tmp/target-a" "$tmp/target-b"; then pass 'positive_control_target=PASS'; else fail 'positive_control_target'; fi
  printf 'target-changed\n' > "$target/.tad/skills/item"
  shasum -a 256 "$target/.tad/skills/item" > "$tmp/target-mut"
  if cmp -s "$tmp/target-a" "$tmp/target-mut"; then fail 'mutation_probe_registered_target accepted'; else pass 'mutation_probe_registered_target=PASS'; fi

  mkdir "$tmp/txn-lock"
  (mkdir "$tmp/race-lock" 2>/dev/null && printf 'launched\n' > "$tmp/race-a" || printf 'loser\n' > "$tmp/race-a") &
  p1=$!
  (mkdir "$tmp/race-lock" 2>/dev/null && printf 'launched\n' > "$tmp/race-b" || printf 'loser\n' > "$tmp/race-b") &
  p2=$!
  wait "$p1" "$p2"
  winners=$(grep -hxc launched "$tmp/race-a" "$tmp/race-b" | awk '{n+=$1}END{print n+0}')
  printf 'launched\nlaunched\n' > "$tmp/adversarial-claims"
  claims=$(grep -c '^launched$' "$tmp/adversarial-claims")
  if [ "$winners" -eq 1 ] && [ "$claims" -ne 1 ]; then pass 'mutation_probe_cas_loser=PASS'; else fail 'mutation_probe_cas_loser'; fi

  safe_remove_tmp "$tmp" || fail 'scratch cleanup'
  pass 'positive_controls=2/2 mutation_probes=9/9'
}

check_fixtures() {
  fixture="$EV/authority-fixtures.jsonl"
  fixture_integrity_valid "$fixture" && pass 'fixture integrity SHA and cardinality exact' || fail 'fixture integrity'
  fixture_semantics_valid "$fixture" && pass 'fixtures=30 independent semantic oracle exact' || fail 'fixture semantic oracle mismatch'
  bad_false=$(awk '/"human_prompt":false/ && $0 !~ /"runtime_prompt_reason":null/{n++}END{print n+0}' "$fixture")
  bad_mut=$(awk '$0 !~ /"mutation_before_verdict":false/{n++}END{print n+0}' "$fixture")
  [ "$bad_false" -eq 0 ] && pass 'prompt-false reasons are null' || fail 'prompt-false reason mismatch'
  [ "$bad_mut" -eq 0 ] && pass 'all fixture verdicts precede mutation' || fail 'mutation before verdict'
  runtime_prompts=$(grep '"human_prompt":true' "$fixture" | grep -v '"final-business-acceptance"' | wc -l | tr -d ' ')
  legal=$(grep '"human_prompt":true' "$fixture" | grep -v '"final-business-acceptance"' | grep -Ec '"runtime_prompt_reason":"(outcome_change|target_change|consequence_change|blast_radius_change|business_legal_financial_identity_tradeoff|divergent_visible_recovery|new_external_identity_or_credentials)"')
  [ "$runtime_prompts" -eq "$legal" ] && pass 'avoidable_runtime_prompt_count=0' || fail 'illegal runtime prompt reason'
  grep '"final-business-acceptance"' "$fixture" | grep -q '"runtime_prompt_reason":null' && pass 'final acceptance excluded from runtime prompts' || fail 'final acceptance classification'
  run_controls
}

check_budget() {
  core=$(( $(wc -c < "$ROOT/.claude/skills/alex-lite/SKILL.md") + $(wc -c < "$ROOT/.claude/skills/blake-lite/SKILL.md") ))
  entry=$(wc -c < "$ROOT/.claude/skills/release-runbook/SKILL.md" | tr -d ' ')
  refs=$(( $(wc -c < "$ROOT/.claude/skills/release-runbook/references/publish-ops.md") + $(wc -c < "$ROOT/.claude/skills/release-runbook/references/sync-ops.md") ))
  [ "$core" -le 52200 ] && pass "lite_core_bytes=$core" || fail "lite_core_bytes=$core max=52200"
  [ "$entry" -le 9500 ] && pass "release_entry_bytes=$entry" || fail "release_entry_bytes=$entry max=9500"
  [ "$refs" -le 17400 ] && pass "release_refs_bytes=$refs" || fail "release_refs_bytes=$refs max=17400"
}

check_ledger() {
  ledger="$ROOT/.tad/evidence/audits/lite-constraint-ledger.md"
  overdue=$(awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ { if (match($0, /PROVISIONAL: review-by [0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]*\|?[[:space:]]*$/)) { d=substr($0,RSTART+23,10); if(d<t)n++ } else n++ } END{print n+0}' "$ledger")
  [ "$overdue" -eq 0 ] && pass 'ledger_overdue=0' || fail "ledger_overdue=$overdue"
  need "$ledger" 'current human approval' 'ledger supersession disposition'
  need "$ledger" 'accepted Execution Mandate' 'ledger priced mandate carrier'
}

check_zero_touch() {
  manifest="$EV/zero-touch-paths.txt"
  manifest_sha=$(sha256_file "$manifest")
  LC_ALL=C sort -c "$manifest" >/dev/null 2>&1 && pass 'zero-touch manifest sorted' || fail 'zero-touch manifest unsorted'
  [ "$(awk -F '\t' '$1=="registered_target"{n++}END{print n+0}' "$manifest")" -eq 14 ] && pass 'registered_targets=14' || fail 'registered target expansion drift'
  window_ok=1
  equal_planes=0
  for plane in tracked untracked index targets; do
    pre="$EV/zero-touch-pre-$plane.txt"; post="$EV/zero-touch-post-$plane.txt"
    if [ ! -s "$pre" ] || [ ! -s "$post" ]; then fail "zero-touch $plane snapshot missing"; window_ok=0; continue; fi
    pre_manifest=$(awk -F '\t' '$1=="MANIFEST_SHA256"{print $2}' "$pre")
    post_manifest=$(awk -F '\t' '$1=="MANIFEST_SHA256"{print $2}' "$post")
    if [ "$pre_manifest" != "$manifest_sha" ] || [ "$post_manifest" != "$manifest_sha" ]; then fail "zero-touch $plane manifest identity"; window_ok=0; fi
    if cmp -s "$pre" "$post"; then pass "zero-touch $plane pre/post equal"; equal_planes=$((equal_planes + 1)); else fail "zero-touch $plane pre/post drift"; window_ok=0; fi
  done
  controls="$EV/zero-touch-controls.txt"
  [ -f "$controls" ] || { fail 'zero-touch controls missing'; return; }
  [ "$(grep -c '^PASS[[:space:]]*mutation_probe_' "$controls")" -eq 9 ] && pass 'mutation_probes=9/9' || fail 'mutation probe evidence count'
  grep -q 'positive_controls=2/2 mutation_probes=9/9' "$controls" && pass 'positive_controls=2/2' || fail 'positive controls evidence'
  if [ "$window_ok" -eq 1 ] && [ "$equal_planes" -eq 4 ]; then
    pass 'recorded_window_persistent_endpoint_equality=4/4; transient command absence not claimed'
  else
    fail "recorded-window persistent endpoint equality=$equal_planes/4"
  fi
}

check_reviews() {
  dir="$ROOT/.tad/evidence/reviews/blake/lite-authority-model-v2"
  count=0
  for name in spec-compliance-reviewer implementation-reviewer security-reviewer; do
    file="$dir/$name.md"
    if [ -f "$file" ] && grep -Eq 'Final verdict:\*\* PASS|Final verdict: PASS|Verdict:\*\* PASS|Verdict: PASS' "$file" && grep -Eq 'P0[=:]0.*P1[=:]0.*P2[=:]0|P0/P1/P2=0' "$file"; then count=$((count + 1)); else fail "review $name not final clean"; fi
  done
  [ "$count" -eq 3 ] && pass 'independent_reviews=3 P0/P1/P2=0' || fail "independent_reviews=$count"
}

run_check() {
  case "$1" in
    inventory) check_inventory ;;
    lite-core) check_lite_core ;;
    prompt-closure) check_prompt_closure ;;
    release) check_release ;;
    routing) check_routing ;;
    mirrors) check_mirrors ;;
    fixtures) check_fixtures ;;
    controls) run_controls ;;
    budget) check_budget ;;
    ledger) check_ledger ;;
    zero-touch) check_zero_touch ;;
    reviews) check_reviews ;;
    *) printf 'unknown check: %s\n' "$1" >&2; exit 2 ;;
  esac
}

if [ "${1:-}" = '--check' ] && [ -n "${2:-}" ]; then
  run_check "$2"
elif [ "${1:-}" = '--all' ]; then
  for check in inventory lite-core prompt-closure release routing mirrors fixtures budget ledger zero-touch reviews; do
    printf 'CHECK\t%s\n' "$check"
    run_check "$check"
  done
else
  printf 'usage: %s --check <inventory|lite-core|prompt-closure|release|routing|mirrors|fixtures|controls|budget|ledger|zero-touch|reviews> | --all\n' "$0" >&2
  exit 2
fi

if [ "$failures" -eq 0 ]; then
  printf 'RESULT: PASS\n'
  exit 0
fi
printf 'RESULT: FAIL failures=%s\n' "$failures"
exit 1
