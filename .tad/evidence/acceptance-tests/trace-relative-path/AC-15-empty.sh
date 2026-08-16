#!/usr/bin/env bash
# AC15: empty file_path → no `file` / `size_bytes` keys at all, stderr empty.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")
ERR="$BOX/err.log"

rm -rf "$BOX/.tad/evidence/traces"
LINE=$(
  (
    cd "$BOX" && source "$LIB" && record_trace "t" ""
    tail -1 "$BOX"/.tad/evidence/traces/*.jsonl
  ) 2>"$ERR"
)
# F1 修复:2> 必须在 $(…) 内、显式子 shell 整体上(F1 P0)

if [ -s "$ERR" ]; then echo "AC15 FAIL: stderr not empty: $(cat "$ERR")" >&2; exit 1; fi
# F1 修复(补):空/无 jsonl 产出必须 FAIL 且 LINE 必须是合法 trace 行
#   —— broken 实现 echo "TOTALLY BROKEN" 会进 stdout 被捕获(非空、无 file/size_bytes)落入
#   catch-all 误绿;必须以 ts/type 键判定"确实产出了一条 trace"。
if [ -z "$LINE" ]; then echo "AC15 FAIL: no trace line produced (broken lib?)" >&2; exit 1; fi
case "$LINE" in
  *'"ts":"'*'"type":"'* ) : ;;   # 合法律:含 ts 与 type 键
  *)
    echo "AC15 FAIL: output is not a valid trace line: $LINE" >&2
    exit 1
    ;;
esac
case "$LINE" in
  *'"file"'*|*'"size_bytes"'* ) echo "AC15 FAIL: empty path emitted file/size_bytes: $LINE" >&2; exit 1 ;;
  * ) echo "AC15 PASS (no file/size_bytes keys, stderr empty, valid trace)" ;;
esac