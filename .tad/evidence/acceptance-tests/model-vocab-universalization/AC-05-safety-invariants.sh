#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

BASELINE=".tad/evidence/acceptance-tests/model-vocab-universalization/baseline.md"
BASELINE_SHA="$(sed -n 's/^BASELINE_COMMIT=//p' "$BASELINE")"
TMP="$(mktemp -d "/tmp/tad-model-vocab-ac5.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

bash .tad/evidence/acceptance-tests/lite-review-hardening/AC-05-sentinel-preservation.sh

extract_safety_blocks() {
  awk '
    function leading(s) { match(s, /^[[:space:]]*/); return RLENGTH }
    /^[[:space:]]*(forbidden_implementations:|anti_rationalization(_registry)?[[:space:]:])/ {
      block++
      inside=1
      base=leading($0)
      printf "BLOCK[%03d] %s\n", block, $0
      next
    }
    inside {
      current=leading($0)
      if ($0 !~ /^[[:space:]]*$/ && current <= base && $0 !~ /^[[:space:]]*-/)
        inside=0
      if (inside) printf "BLOCK[%03d] %s\n", block, $0
    }
  '
}

extract_named_block() {
  local key="$1"
  awk -v wanted="$key" '
    function leading(s) { match(s, /^[[:space:]]*/); return RLENGTH }
    $0 ~ "^[[:space:]]*" wanted "[[:space:]]*:" {
      inside=1
      base=leading($0)
      print
      next
    }
    inside {
      current=leading($0)
      if ($0 !~ /^[[:space:]]*$/ && current <= base && $0 !~ /^[[:space:]]*-/)
        inside=0
      if (inside) print
    }
  '
}

compare_safety_blocks() {
  local path="$1" stem="$2"
  git show "$BASELINE_SHA:$path" | extract_safety_blocks |
    LC_ALL=C sort > "$TMP/$stem.before"
  extract_safety_blocks < "$path" |
    LC_ALL=C sort > "$TMP/$stem.after"
  if ! cmp -s "$TMP/$stem.before" "$TMP/$stem.after"; then
    echo "FAIL AC5b: SAFETY block content or ownership changed in $path"
    LC_ALL=C comm -3 "$TMP/$stem.before" "$TMP/$stem.after" || true
    return 1
  fi
}

compare_safety_blocks \
  ".claude/skills/blake/SKILL.md" \
  "blake-safety"
compare_safety_blocks \
  ".claude/skills/alex/references/handoff-creation-protocol.md" \
  "alex-handoff-safety"

git show "$BASELINE_SHA:.claude/skills/blake/SKILL.md" |
  extract_named_block "hard_requirement_distinct_reviewers" > "$TMP/hard.before"
extract_named_block "hard_requirement_distinct_reviewers" \
  < .claude/skills/blake/SKILL.md > "$TMP/hard.after"
if ! cmp -s "$TMP/hard.before" "$TMP/hard.after"; then
  echo "FAIL AC5c: hard_requirement_distinct_reviewers block changed"
  exit 1
fi

if ! grep -Fq -e "Criterion C and D MUST NOT auto-archive" .claude/skills/tad-maintain/SKILL.md; then
  echo "FAIL AC5d: tad-maintain Criterion C/D archive safety anchor missing"
  exit 1
fi

for line in \
  "minimum_experts: 2" \
  "- \"不经过专家审查直接发送 handoff 给 Blake = VIOLATION\"" \
  "- \"忽略专家发现的 P0 问题不修复 = VIOLATION\""; do
  if ! grep -Fq -e "$line" .claude/skills/alex/references/handoff-creation-protocol.md; then
    echo "FAIL AC5e: missing handoff safety neighbor: $line"
    exit 1
  fi
done

echo "AC5 PASS: sentinel, SAFETY block, reviewer-count, archive, and handoff-neighbor invariants hold"
