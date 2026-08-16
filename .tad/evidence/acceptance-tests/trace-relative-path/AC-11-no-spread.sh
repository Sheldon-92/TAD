#!/usr/bin/env bash
# AC11 (no spread, whitelist-style): new items vs base-status ⊆ whitelist.
# Whitelist: §5 paths, .tad/evidence/traces/*.jsonl, .tad/evidence/decisions/*.jsonl,
#            COMPLETION/journal/session-state.
# 扩展（Blake 2026-08-16，注释在案供 Gate 4 复核）: reviews/ 与 ralph-loops/ 是 TAD 执行协议
# 的强制证据/状态位置（Layer 2 审查证据、*develop state 文件），不是实现蔓延——AC11 的意图
# 是防"实现"越界，协议产物必须允许，否则 AC11 在 Layer 2 之后重跑必然红。
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
# 基线快照优先读 fixture 内提交版(可独立复跑);回退 .tr-path(同会话运行)
SCRATCH_DIR=$(mktemp -d)   # 运行时临时目录,结尾清理,不污染工作区
if [ -f "$FIX/baseline-status.txt" ]; then
  BASE="$FIX/baseline-status.txt"
else
  TR="$(cat "$FIX/.tr-path" 2>/dev/null)"
  [ -n "$TR" ] && [ -f "$TR/base-status.txt" ] && BASE="$TR/base-status.txt"
  [ -n "${BASE:-}" ] || { echo "AC11 FAIL: baseline-status.txt missing (run Phase 0 first)" >&2; exit 1; }
fi
CUR_SORTED="$SCRATCH_DIR/cur-status.txt"

cd "$ROOT"
git status --porcelain -uall | sort > "$CUR_SORTED"

# 相对基线的全部新增行(comm -13 needs both sorted; BASE already sorted)
# F3 修复:不再只取 ?? —— 把 M (tracked 修改)也纳入断言:
#   - ?? 必须 ⊆ 白名单
#   -  M 必须 ∈ {common.sh} ∪ 环境 jsonl(traces/decisions)
NEW=$(comm -13 "$BASE" "$CUR_SORTED" || true)

[ -z "$NEW" ] && { rm -rf "$SCRATCH_DIR"; echo "AC11 PASS (no new items vs baseline)"; exit 0; }

NEW_LIST="$SCRATCH_DIR/ac11-new.txt"
printf '%s\n' "$NEW" > "$NEW_LIST"
FAIL=0
while IFS= read -r line; do
  path=$(printf '%s' "$line" | sed -E 's/^.. //')
  code=$(printf '%s' "$line" | cut -c1-2)
  if [ "$code" = "??" ]; then
    case "$path" in
      .tad/evidence/acceptance-tests/trace-relative-path/*) : ;;
      .tad/evidence/traces/*.jsonl) : ;;
      .tad/evidence/decisions/*.jsonl) : ;;
      .tad/evidence/reviews/*) : ;;            # Layer 2 协议证据
      .tad/evidence/ralph-loops/*) : ;;        # *develop 状态文件
      *COMPLETION*|*journal*|*session-state*) : ;;
      *)
        echo "AC11 FAIL: new untracked item outside whitelist: $line" >&2
        FAIL=1
        ;;
    esac
  else
    # tracked modification: must be common.sh or env jsonl (AC10 covers common.sh details)
    case "$path" in
      .tad/hooks/lib/common.sh) : ;;
      .tad/evidence/traces/*.jsonl) : ;;
      .tad/evidence/decisions/*.jsonl) : ;;
      *)
        echo "AC11 FAIL: modified tracked file outside allowlist: $line" >&2
        FAIL=1
        ;;
    esac
  fi
done < "$NEW_LIST"
rm -rf "$SCRATCH_DIR"
[ "$FAIL" = 0 ] && echo "AC11 PASS (new items all in whitelist)" || exit 1