#!/usr/bin/env bash
# AC9 (REAL E2E — requires Write tool, not shell):
#   record: snapshot today's trace line count (run BEFORE creating probe.md via Write tool)
#   verify: assert count grew, new line's .file has no leading / and no /Users/, then clean up
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
cd "$ROOT" || { echo "AC9 FAIL: cannot cd repo root" >&2; exit 1; }   # F2 修复:必须从仓库根跑
BEFORE_FILE="$FIX/.ac9-before"
TODAY=$(date +%Y-%m-%d)
JSONL=".tad/evidence/traces/$TODAY.jsonl"

is_num() { printf '%s' "${1:-}" | grep -Eq '^[0-9]+$'; }

case "${1:-}" in
  record)
    [ -f "$JSONL" ] && wc -l < "$JSONL" | tr -d ' ' > "$BEFORE_FILE" || echo 0 > "$BEFORE_FILE"
    echo "AC9 record: before=$(cat "$BEFORE_FILE")  (now create probe.md via Write tool, then run: $0 verify)"
    ;;
  verify)
    [ -f "$BEFORE_FILE" ] || { echo "AC9 FAIL: no record phase" >&2; exit 1; }
    BEFORE=$(cat "$BEFORE_FILE"); AFTER=$(wc -l < "$JSONL" | tr -d ' ')
    # F2 修复:非数字计数值直接 FAIL,不许进入比较后静默跳分支
    is_num "$BEFORE" || { echo "AC9 FAIL: before not numeric: '$BEFORE'" >&2; exit 1; }
    is_num "$AFTER" || { echo "AC9 FAIL: after not numeric: '$AFTER'" >&2; exit 1; }
    PROBE=".tad/evidence/acceptance-tests/trace-relative-path/probe.md"
    if [ "$AFTER" -le "$BEFORE" ]; then
      echo "AC9 FAIL: trace count did not grow (before=$BEFORE after=$AFTER) — Write tool did not trigger PostToolUse" >&2
      exit 1
    fi
    NEWLINE=$(tail -n +$((BEFORE + 1)) "$JSONL" | head -1)
    case "$NEWLINE" in
      *'"file":"/'* ) echo "AC9 FAIL: new line still absolute: $NEWLINE" >&2; exit 1 ;;
      *'/Users/'*   ) echo "AC9 FAIL: new line contains /Users/: $NEWLINE" >&2; exit 1 ;;
    esac
    # Cleanup: delete probe AND truncate jsonl back to before
    rm -f "$PROBE"
    head -n "$BEFORE" "$JSONL" > "$JSONL.tmp" && mv "$JSONL.tmp" "$JSONL"
    rm -f "$BEFORE_FILE"
    echo "AC9 PASS (count grew $BEFORE -> $AFTER, relative file, cleaned up)"
    ;;
  *) echo "usage: $0 record|verify" >&2; exit 2 ;;
esac