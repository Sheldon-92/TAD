#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

BASELINE=".tad/evidence/acceptance-tests/model-vocab-universalization/baseline.md"
BASELINE_SHA="$(sed -n 's/^BASELINE_COMMIT=//p' "$BASELINE")"
MANIFEST=".tad/evidence/acceptance-tests/model-vocab-universalization/registered-line-set.sha256"
TMP="$(mktemp -d "/tmp/tad-model-vocab-ac8.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

if ! git cat-file -e "$BASELINE_SHA^{commit}" 2>/dev/null; then
  echo "FAIL AC8: baseline commit is not a valid commit: $BASELINE_SHA"
  exit 1
fi
if [ ! -f "$MANIFEST" ]; then
  echo "FAIL AC8: registered line-set manifest is missing: $MANIFEST"
  exit 1
fi

# Scope is the handoff §2 product manifest: lifecycle state and evidence artifacts
# are deliberately outside this product line-set gate.
scope_paths=".claude/skills .claude/workflows .agents/skills
.tad/config-agents.yaml
.tad/eval/judge/README.md
.tad/portable-rules.md
.tad/runtime-compat/codex.md
AGENTS.md"

git diff --name-only "$BASELINE_SHA" -- $scope_paths |
  LC_ALL=C sort > "$TMP/changed"
cut -d'|' -f1 "$MANIFEST" |
  LC_ALL=C sort > "$TMP/registered"
LC_ALL=C comm -23 "$TMP/changed" "$TMP/registered" > "$TMP/unregistered"
if [ -s "$TMP/unregistered" ]; then
  echo "FAIL AC8: changed product paths absent from the registered manifest:"
  cat "$TMP/unregistered"
  exit 1
fi

untracked="$(git status --porcelain -- $scope_paths |
  awk '$1 == "??" { print $2 }' |
  LC_ALL=C sort)"
if [ -n "$untracked" ]; then
  echo "FAIL AC8: untracked product paths are outside the immutable line-set baseline:"
  printf '%s\n' "$untracked"
  exit 1
fi

fail=0
forward_missing=0
reverse_added=0
while IFS='|' read -r path expected_plus plus_hash expected_minus minus_hash; do
  [ -n "$path" ] || continue
  git diff --unified=0 "$BASELINE_SHA" -- "$path" |
    awk '/^\+\+\+ / || /^--- / { next } /^[+-]/ { print substr($0, 1, 1) "\t" substr($0, 2) }' > "$TMP/delta"
  awk -F '	' '$1 == "+" { print substr($0, 3) }' "$TMP/delta" |
    LC_ALL=C sort > "$TMP/plus"
  awk -F '	' '$1 == "-" { print substr($0, 3) }' "$TMP/delta" |
    LC_ALL=C sort > "$TMP/minus"

  actual_plus="$(wc -l < "$TMP/plus" | tr -d ' ')"
  actual_minus="$(wc -l < "$TMP/minus" | tr -d ' ')"
  actual_plus_hash="$(shasum -a 256 "$TMP/plus" | awk '{print $1}')"
  actual_minus_hash="$(shasum -a 256 "$TMP/minus" | awk '{print $1}')"

  if [ "$actual_plus" != "$expected_plus" ] || [ "$actual_plus_hash" != "$plus_hash" ]; then
    echo "FAIL AC8 forward/+ line set: $path expected $expected_plus/$plus_hash got $actual_plus/$actual_plus_hash"
    fail=1
    forward_missing=$((forward_missing + 1))
  fi
  if [ "$actual_minus" != "$expected_minus" ] || [ "$actual_minus_hash" != "$minus_hash" ]; then
    echo "FAIL AC8 reverse/- line set: $path expected $expected_minus/$minus_hash got $actual_minus/$actual_minus_hash"
    fail=1
    reverse_added=$((reverse_added + 1))
  fi
done < "$MANIFEST"

if [ "$fail" -ne 0 ]; then
  echo "AC8 FAIL: forward-missing=$forward_missing reverse-added=$reverse_added"
  exit 1
fi
echo "AC8 PASS: baseline=$BASELINE_SHA exact registered plus/minus line-set manifest is closed"
