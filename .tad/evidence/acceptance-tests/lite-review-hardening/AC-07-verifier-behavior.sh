#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
V=.tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh
before=$(md5 -q "$V")
out=$(bash -c 'rg(){ grep -E "$@"; }; export -f rg; bash .tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh' 2>&1)
rc=$?
[ "$rc" -eq 0 ] || { echo "FAIL: baseline shim exit=$rc"; printf '%s\n' "$out"; exit 1; }
printf '%s\n' "$out" | grep -q "OK: decision_record field 'model' required" || { echo 'FAIL: baseline model OK line missing'; exit 1; }
scratch=$(mktemp -d "${TMPDIR:-/tmp}/lite-review-hardening-ac7.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/.tad" "$scratch/.claude/skills/alex-lite" "$scratch/.claude/skills/blake-lite"
cp .tad/routing-contract.yaml "$scratch/.tad/routing-contract.yaml"
cp .claude/skills/alex-lite/SKILL.md "$scratch/.claude/skills/alex-lite/SKILL.md"
cp .claude/skills/blake-lite/SKILL.md "$scratch/.claude/skills/blake-lite/SKILL.md"
cp "$V" "$scratch/verify-state-flow.sh"
sed -i '' 's/state, model]/state]/' "$scratch/.tad/routing-contract.yaml"
grep -q 'state, model]' "$scratch/.tad/routing-contract.yaml" && { echo 'FAIL: mutation did not remove model'; exit 1; }
mut_out=$(cd "$scratch" && bash -c 'rg(){ grep -E "$@"; }; export -f rg; bash ./verify-state-flow.sh' 2>&1)
mut_rc=$?
[ "$mut_rc" -eq 1 ] || { echo "FAIL: mutated verifier exit=$mut_rc"; printf '%s\n' "$mut_out"; exit 1; }
printf '%s\n' "$mut_out" | grep -q "FAIL: decision_record missing required field 'model'" || { echo 'FAIL: mutation diagnostic missing'; printf '%s\n' "$mut_out"; exit 1; }
after=$(md5 -q "$V")
[ "$before" = "$after" ] || { echo 'FAIL: root verifier changed during scratch mutation'; exit 1; }
echo 'PASS: AC7 verifier shim PASS + scratch mutation FAIL + root restore byte-identical'
