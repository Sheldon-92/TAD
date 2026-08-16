#!/usr/bin/env bash
# AC10 (scope): git diff from base-sha on common.sh → 1 file, 0 deletions, +8..+12 lines,
# all additions inside record_trace() body.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
# 基线快照优先读 fixture 内提交版(可独立复跑);回退 .tr-path(同会话运行)
if [ -f "$FIX/baseline-sha.txt" ]; then
  BASE_SHA=$(cat "$FIX/baseline-sha.txt")
else
  TR="$(cat "$FIX/.tr-path" 2>/dev/null)"
  [ -n "$TR" ] && [ -f "$TR/base-sha.txt" ] && BASE_SHA=$(cat "$TR/base-sha.txt")
  [ -n "${BASE_SHA:-}" ] || { echo "AC10 FAIL: baseline-sha.txt missing (run Phase 0 first)" >&2; exit 1; }
fi
F=".tad/hooks/lib/common.sh"

cd "$ROOT"

# 1 file changed — numstat over the WHOLE diff (no path filter: F3 修复 — 否则"1 file"恒真)
NUMSTAT=$(git diff --numstat "$BASE_SHA")
# 环境写入白名单(traces/decisions jsonl)允许存在,按 3rd 列(路径)排除后断言剩余恰好只有 common.sh
REMAIN=$(printf '%s\n' "$NUMSTAT" | awk '$3 !~ /^\.tad\/evidence\/(traces|decisions)\//')
NFILES=$(echo "$REMAIN" | sed '/^$/d' | wc -l | tr -d ' ')
[ "$NFILES" = "1" ] || {
  echo "AC10 FAIL: expected 1 tracked file modified (excl. env jsonl), got $NFILES:" >&2
  echo "$REMAIN" >&2
  exit 1
}
printf '%s\n' "$REMAIN" | grep -q "$F" || { echo "AC10 FAIL: modified file is not $F" >&2; exit 1; }
# 从 common.sh 行取 added/deleted
CS=$(printf '%s\n' "$NUMSTAT" | grep "$F")
ADDED=$(echo "$CS" | awk '{print $1}')
DELETED=$(echo "$CS" | awk '{print $2}')

# F3 修复补回显式断言(此前只有 numstat NFILES 隐式覆盖)
[ "$DELETED" = "0" ] || { echo "AC10 FAIL: deletions=$DELETED, expected 0" >&2; exit 1; }
[ "$ADDED" -ge 8 ] && [ "$ADDED" -le 12 ] || { echo "AC10 FAIL: added=$ADDED, expected 8..12" >&2; exit 1; }

# All added lines must fall inside record_trace() body (function starts at line 72)
# Use unified=0 hunks: @@ -a,b +c,d @@ → c is first added line number
HUNKS=$(git diff --unified=0 "$BASE_SHA" -- "$F" | grep '^@@')
RECORD_START=$(grep -n '^record_trace()' "$F" | head -1 | cut -d: -f1)
# record_trace body ends at the first top-level function after it
NEXT_FUNC=$(grep -n '^[a-z_]*()' "$F" | awk -F: -v s="$RECORD_START" '$1 > s {print $1; exit}')
BODY_END=$((NEXT_FUNC - 1))

echo "$HUNKS" | while IFS= read -r h; do
  # extract the +side start line: "@@ -a,b +c,d @@" (may be "+c" without comma)
  PLUS=$(echo "$h" | sed -E 's/^@@ -[0-9]+(,[0-9]+)? \+([0-9]+)(,[0-9]+)? @@.*/\2/')
  if [ -n "$PLUS" ] && [ "$PLUS" -ge "$RECORD_START" ] && [ "$PLUS" -le "$BODY_END" ]; then
    :
  else
    echo "AC10 FAIL: hunk starts at line $PLUS, outside record_trace() ($RECORD_START..$BODY_END): $h" >&2
    exit 1
  fi
done || exit 1

echo "AC10 PASS (1 file, 0 deletions, +${ADDED} lines, all inside record_trace() $RECORD_START..$BODY_END)"