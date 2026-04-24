#!/usr/bin/env bash
# AC-P1.2-g — backward compat with pre-Phase-1 archived handoffs
# Take 5 real archived handoffs, run slug_consistency against each.
# Expected: each emits status "info" (pre-manifest-era) or "ok" — NEVER "drift".

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
SCRIPT="${REPO_ROOT}/.tad/hooks/lib/drift-check.sh"

PASS=0
FAIL=0

# Sample 5 archived handoffs deterministically (sorted, head)
# Using `sort` for stable order; real sampling via `sort -R` would make the test non-reproducible.
mapfile -t SAMPLES < <(ls "${REPO_ROOT}/.tad/archive/handoffs/"HANDOFF-*.md 2>/dev/null | sort | head -5)

if [ "${#SAMPLES[@]}" -lt 5 ]; then
  printf 'SKIP: not enough archived handoffs for sampling (need 5, found %d)\n' "${#SAMPLES[@]}"
  exit 0
fi

# Build a throwaway active/ dir containing copies of the 5 sampled handoffs
WS=$(mktemp -d -t drift-compat.XXXXXX)
trap 'rm -rf "$WS"' EXIT
mkdir -p "$WS/.tad/active/handoffs" "$WS/.tad/archive/handoffs" "$WS/.tad/hooks/lib"
cd "$WS" || exit 1
git init -q && git config user.email a@b && git config user.name T
echo init > README && git add README && git commit -q -m init

for src in "${SAMPLES[@]}"; do
  cp "$src" "$WS/.tad/active/handoffs/"
done
cp "${REPO_ROOT}/.tad/config-workflow.yaml" "$WS/.tad/config-workflow.yaml"

stdout=$(bash "$SCRIPT" check slug_consistency 2>/dev/null)

# For each sampled handoff, verify it's NOT status=drift
for src in "${SAMPLES[@]}"; do
  base=$(basename "$src")
  status=$(printf '%s\n' "$stdout" | jq -rc --arg h "$base" \
    'select(.subcheck=="slug_consistency" and .handoff==$h) | .status' 2>/dev/null | head -1)
  if [ -z "$status" ]; then
    printf '[FAIL] AC-P1.2-g no output for %s\n' "$base"
    FAIL=$((FAIL+1))
  elif [ "$status" = "drift" ]; then
    printf '[FAIL] AC-P1.2-g %s produced drift (expected info/ok for pre-Phase-1)\n' "$base"
    FAIL=$((FAIL+1))
  else
    printf '[PASS] AC-P1.2-g %s → %s (not drift)\n' "$base" "$status"
    PASS=$((PASS+1))
  fi
done

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
