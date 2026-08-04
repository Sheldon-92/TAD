#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

BASELINE=".tad/evidence/acceptance-tests/model-vocab-universalization/baseline.md"
TMP="$(mktemp -d "/tmp/tad-model-vocab-ac3.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

git grep -l "AskUserQuestion" -- ".claude/skills/*/SKILL.md" |
  LC_ALL=C sort > "$TMP/live"
grep -E '^\.claude/skills/[^[:space:]]+/SKILL\.md$' "$BASELINE" |
  LC_ALL=C sort > "$TMP/registered"

LC_ALL=C comm -3 "$TMP/live" "$TMP/registered" > "$TMP/set-diff"
if [ -s "$TMP/set-diff" ]; then
  echo "FAIL AC3a: live AskUserQuestion governance set differs from baseline:"
  cat "$TMP/set-diff"
  exit 1
fi

fail=0
while IFS= read -r file; do
  header_count="$(grep -F -c -e "平台绑定交互决策（cross-harness binding）" "$file" 2>/dev/null || true)"
  if [ "$header_count" -ne 1 ]; then
    echo "FAIL AC3a: clause header count=$header_count in $file"
    fail=1
    continue
  fi

  header_line="$(grep -n -F -e "平台绑定交互决策（cross-harness binding）" "$file" | cut -d: -f1)"
  if [ "$header_line" -gt 200 ]; then
    echo "FAIL AC3a: clause is not in the early activation/body window in $file (line $header_line)"
    fail=1
  fi

  window="$(awk -v begin="$header_line" 'NR >= begin && NR < begin + 9 { print }' "$file")"
  for needle in \
    "AskUserQuestion 调用" \
    "编号纯文本列出全部选项" \
    "停止等待用户输入" \
    "禁止代答" \
    "SAFETY 门控的调用点" \
    "非交互执行模式" \
    "blocked 停止并上报" \
    "YOLO/预授权模式"; do
    term_count="$(printf '%s\n' "$window" | grep -F -c -e "$needle" || true)"
    if [ "$term_count" -lt 1 ]; then
      echo "FAIL AC3a: clause term '$needle' missing from $file"
      fail=1
    fi
  done
done < "$TMP/live"

bad_count="$( { grep -rl -F -e "Codex: ask_user_question" .claude/skills .agents/skills || true; } | wc -l | tr -d ' ')"
if [ "$bad_count" -ne 0 ]; then
  echo "FAIL AC3b: stale Codex ask_user_question comments remain ($bad_count files)"
  { grep -rl -F -e "Codex: ask_user_question" .claude/skills .agents/skills || true; }
  fail=1
fi

if [ "$(grep -F -c -e "### Interaction decisions" AGENTS.md || true)" -ne 1 ]; then
  echo "FAIL AC3c: AGENTS.md interaction section count is not 1"
  fail=1
fi
if [ "$(grep -F -c -e "平台绑定交互决策" AGENTS.md || true)" -lt 1 ]; then
  echo "FAIL AC3c: AGENTS.md lacks platform-binding pointer"
  fail=1
fi

git show "$(sed -n 's/^BASELINE_COMMIT=//p' "$BASELINE"):.tad/portable-rules.md" |
  sed -n '27p' > "$TMP/old-line"
sed -n '27p' .tad/portable-rules.md > "$TMP/new-line"
LC_ALL=C sort "$TMP/old-line" > "$TMP/old-sorted"
LC_ALL=C sort "$TMP/new-line" > "$TMP/new-sorted"
LC_ALL=C comm -23 "$TMP/old-sorted" "$TMP/new-sorted" > "$TMP/old-only"
LC_ALL=C comm -13 "$TMP/old-sorted" "$TMP/new-sorted" > "$TMP/new-only"
if [ "$(wc -l < "$TMP/old-only" | tr -d ' ')" -ne 1 ] ||
   [ "$(wc -l < "$TMP/new-only" | tr -d ' ')" -ne 1 ]; then
  echo "FAIL AC3d: portable-rules line 27 diff is not exactly one old and one new line"
  fail=1
fi
if [ "$(grep -F -c -e "条款） |" "$TMP/new-line" || true)" -ne 1 ]; then
  echo "FAIL AC3d: runtime-authority pointer is not inside the final table cell"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "AC3 PASS: live governance set, per-term clause window, stale-comment filter, and portable-rules guard"
