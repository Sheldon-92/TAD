#!/bin/bash
# verify.sh — install-smoke-v2410 围栏核心（AC16/AC17）
# 用法: bash verify.sh fence-fresh | fence-audit | fence-positivectl
# 契约纪律：变量全引号；comm 输入单次全局 LC_ALL=C sort；不用 awk 字符串比较；grep -E 不用 -F 配锚点

set -u

BASE=".tad/evidence/acceptance-tests/install-smoke-v2410"
REPO="$(cd "$(dirname "$0")/../../../.." && pwd -P)"
FENCE_PROBE=".tad/domains/SMOKE-FENCE-PROBE.txt"

# 排除前缀（契约 AC16）：本单产物 + 框架自写路径
is_excluded() {
  local p="$1"
  case "$p" in
    .tad/evidence/acceptance-tests/install-smoke-v2410/*) return 0 ;;
    .tad/evidence/journal/install-smoke-v2410-2026-08-11.md) return 0 ;;
    .tad/evidence/reviews/blake/install-smoke-v2410/*) return 0 ;;
    .tad/active/handoffs/LITE-20260811-1951-install-smoke-v2410.md) return 0 ;;
    .tad/active/handoffs/LITE-20260811-1951-install-smoke-v2410.md.txn-lock) return 0 ;;
    .tad/archive/handoffs/LITE-20260811-1951-install-smoke-v2410.md) return 0 ;;
    .tad/evidence/traces/*) return 0 ;;
    .tad/evidence/decisions/*) return 0 ;;
    .tad/logs/*) return 0 ;;
    .tad/active/precompact/*) return 0 ;;
    .tad/active/session-state.md) return 0 ;;
    .tad/memory/*) return 0 ;;
    .tad/research-notebooks/REGISTRY.yaml) return 0 ;;
    .tad/brain-index.md) return 0 ;;
  esac
  return 1
}

# 当前 git status 全集（与基线同形状：porcelain -uall + LC_ALL=C sort）
snapshot_status() {
  git -C "$REPO" status --porcelain -uall | LC_ALL=C sort
}

# 基线中 dirty tracked 路径（非 ?? 前缀）
baseline_dirty_tracked() {
  grep -v '^??' "$BASE/scope-baseline.txt" | grep -E '^( M|M |MM| D|D |A |A\?)' | awk '{print $2}' | LC_ALL=C sort
}

# 当前 dirty tracked 路径
current_dirty_tracked() {
  snapshot_status | grep -v '^??' | awk '{print $2}' | LC_ALL=C sort
}

fence_fresh() {
  # 快照差集：当前 untracked − 基线 untracked = 本单新增；基线已存在的 877 个历史 untracked 不构成新增
  snapshot_status > /tmp/tad-fence-now.txt
  grep '^??' /tmp/tad-fence-now.txt | sed 's/^?? //' | LC_ALL=C sort > /tmp/tad-fence-now-untracked.txt
  grep '^??' "$BASE/scope-baseline.txt" | sed 's/^?? //' | LC_ALL=C sort > /tmp/tad-fence-base-untracked.txt
  local violation=0
  comm -13 /tmp/tad-fence-base-untracked.txt /tmp/tad-fence-now-untracked.txt | while IFS= read -r p; do
    [ -z "$p" ] && continue
    if is_excluded "$p"; then
      echo "EXCLUDED $p"
    else
      echo "VIOLATION-UNTRACKED $p"
      violation=1
    fi
  done
  # 新增 tracked（基线无 → 现在有）
  git -C "$REPO" status --porcelain | grep -v '^??' | awk '{print $2}' | LC_ALL=C sort > /tmp/tad-fence-now-tracked.txt
  baseline_dirty_tracked > /tmp/tad-fence-base-tracked.txt
  comm -13 /tmp/tad-fence-base-tracked.txt /tmp/tad-fence-now-tracked.txt | while IFS= read -r p; do
    [ -z "$p" ] && continue
    if is_excluded "$p"; then
      echo "EXCLUDED $p"
    else
      echo "VIOLATION-NEW-TRACKED $p"
      violation=1
    fi
  done
  [ "$violation" -eq 0 ] && echo "FENCE-FRESH: CLEAN" || echo "FENCE-FRESH: VIOLATION"
}

fence_audit() {
  # AC16 收尾：全部 dirty tracked 摘要必须与基线一致（REGISTRY/brain-index 除外）
  local violation=0
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    case "$p" in
      .tad/research-notebooks/REGISTRY.yaml|.tad/brain-index.md) continue ;;
    esac
    local base_sha now_sha
    base_sha=$(grep -E "  ${p}$" "$BASE/scope-baseline.txt" | awk '{print $1}' | head -1)
    now_sha=$(shasum -a 256 "$REPO/$p" 2>/dev/null | awk '{print $1}')
    if [ -z "$base_sha" ]; then
      # 基线无摘要 = 本单新增（或非 dirty tracked）→ 排除面，不比对
      echo "NEW-PATH (baseline has no digest, excluded): $p"
    elif [ -n "$now_sha" ] && [ "$base_sha" = "$now_sha" ]; then
      echo "UNCHANGED $p"
    else
      echo "VIOLATION-DIGEST $p base=$base_sha now=$now_sha"
      violation=1
    fi
  done < <(current_dirty_tracked)
  # REGISTRY.yaml 限定形状：props 属性路径闭合 + 值域闭合
  if command -v yq >/dev/null 2>&1; then
    yq -o=props '.' .tad/research-notebooks/REGISTRY.yaml | LC_ALL=C sort > /tmp/tad-reg-c.props
    yq -o=props '.' "$BASE/registry-baseline.yaml" | LC_ALL=C sort > /tmp/tad-reg-b.props
    diff /tmp/tad-reg-b.props /tmp/tad-reg-c.props > "$BASE/reg.propsdiff" || true
    local regbad=0
    while IFS= read -r line; do
      case "$line" in
        \<*) : ;;
        \>*)
          local key val
          key=$(echo "${line#\>}" | sed 's/ *=.*$//' | tr -d ' ')
          val=$(echo "${line#\>}" | sed 's/^[^=]*= *//' | tr -d ' ')
          if echo "$key" | grep -qE '^notebooks\.[0-9]+\.status$'; then
            case "$val" in
              active|dormant) echo "REGISTRY-OK $key=$val" ;;
              *) echo "VIOLATION-REGISTRY-VALUE $key=$val"; regbad=1 ;;
            esac
          else
            echo "VIOLATION-REGISTRY-PATH $key"
            regbad=1
          fi
          ;;
      esac
    done < "$BASE/reg.propsdiff"
    [ "$regbad" -eq 0 ] || violation=1
  else
    # yq 缺席 → 逐字节不变（更强断言）
    if cmp -s "$BASE/registry-baseline.yaml" .tad/research-notebooks/REGISTRY.yaml; then
      echo "REGISTRY-BYTE-IDENTICAL (yq absent)"
    else
      echo "VIOLATION-REGISTRY-BYTES (yq absent)"
      violation=1
    fi
  fi
  # brain-index.md：变化必须指认 hook
  local bi_base bi_now
  bi_base=$(grep 'brain-index' "$BASE/scope-baseline.txt" | grep -oE '[0-9a-f]{64}' | head -1)
  bi_now=$(shasum -a 256 "$REPO/.tad/brain-index.md" | awk '{print $1}')
  if [ "$bi_base" = "$bi_now" ]; then
    echo "BRAIN-INDEX UNCHANGED"
  else
    echo "VIOLATION-BRAIN-INDEX base=$bi_base now=$bi_now (须指认触发 hook)"
    violation=1
  fi
  [ "$violation" -eq 0 ] && echo "FENCE-AUDIT: CLEAN" || echo "FENCE-AUDIT: VIOLATION"
}

fence_positivectl() {
  # AC17 正控：git add 全部 evidence 后 / 归档后，围栏必须静默通过（无 VIOLATION 输出）
  local out
  out=$(fence_audit 2>&1)
  local vc
  vc=$(echo "$out" | grep -c 'VIOLATION' || true)
  echo "$out"
  [ "$vc" -eq 0 ] && echo "FENCE-POSITIVE: CLEAN" || echo "FENCE-POSITIVE: VIOLATION"
}

case "${1:-}" in
  fence-fresh) fence_fresh ;;
  fence-audit) fence_audit ;;
  fence-positivectl) fence_positivectl ;;
  *) echo "usage: $0 fence-fresh|fence-audit|fence-positivectl" >&2; exit 2 ;;
esac
