#!/usr/bin/env bash
# AC9-equivalent (non-Claude-Code runtime): simulate the hook input the Write tool
# would produce, drive post-write-sync.sh end-to-end, assert the trace line now
# carries a repo-relative `file` (no leading /, no /Users/), then clean up.
#   Usage: AC-09-equiv-e2e.sh [record|verify]
#   record: snapshot line count, create probe.md, emit hook JSON, (verify follows)
#   verify: assert growth + relative file, then truncate jsonl back and rm probe.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
cd "$ROOT" || { echo "AC9-EQUIV FAIL: cannot cd repo root" >&2; exit 1; }   # F2 修复:必须从仓库根跑
BEFORE_FILE="$FIX/.ac9equiv-before"
TODAY=$(date +%Y-%m-%d)
JSONL=".tad/evidence/traces/$TODAY.jsonl"
PROBE="${FIX}/probe.md"
HOOK="$ROOT/.tad/hooks/post-write-sync.sh"

is_num() { printf '%s' "${1:-}" | grep -Eq '^[0-9]+$'; }

cleanup() { rm -f "$PROBE" "$BEFORE_FILE"; }   # F7 修复:失败也清理

case "${1:-}" in
  record)
    wc -l < "$JSONL" | tr -d ' ' > "$BEFORE_FILE"
    printf '# AC9-equivalent probe\n\nWritten via hook-JSON simulation.\n' > "$PROBE"
    printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' "$PROBE" \
      | bash "$HOOK" > /dev/null 2>&1
    echo "AC9-EQUIV record: before=$(cat "$BEFORE_FILE")  hook driven once.  run: $0 verify"
    ;;
  verify)
    [ -f "$BEFORE_FILE" ] || { echo "AC9-EQUIV FAIL: run record first" >&2; exit 1; }
    BEFORE=$(cat "$BEFORE_FILE"); AFTER=$(wc -l < "$JSONL" | tr -d ' ')
    # F2 修复:非数字计数值直接 FAIL,不许进入比较后静默跳分支
    if ! is_num "$BEFORE" || ! is_num "$AFTER"; then
      echo "AC9-EQUIV FAIL: non-numeric count (before='$BEFORE' after='$AFTER')" >&2
      cleanup; exit 1
    fi
    if [ "$AFTER" -le "$BEFORE" ]; then
      echo "AC9-EQUIV FAIL: trace count did not grow (before=$BEFORE after=$AFTER)" >&2
      cleanup; exit 1
    fi
    NEWLINE=$(tail -n +$((BEFORE + 1)) "$JSONL" | head -1)
    case "$NEWLINE" in
      *'"file":"/'* ) echo "AC9-EQUIV FAIL: new line still absolute: $NEWLINE" >&2; cleanup; exit 1 ;;
      *'/Users/'* )   echo "AC9-EQUIV FAIL: new line contains /Users/: $NEWLINE" >&2; cleanup; exit 1 ;;
    esac
    rm -f "$PROBE"
    head -n "$BEFORE" "$JSONL" > "$JSONL.tmp" && mv "$JSONL.tmp" "$JSONL"
    rm -f "$BEFORE_FILE"
    echo "AC9-EQUIV PASS (count grew $BEFORE -> $AFTER, relative file, cleaned up)"
    ;;
  *) echo "usage: $0 record|verify" >&2; exit 2 ;;
esac