#!/usr/bin/env bash
# generate-inventory.sh — 只读生成 full 能力 inventory（Phase 1/2 决策底座）
#
# 用法: generate-inventory.sh <raw.tsv> <handoffs.tsv>
#   raw.tsv       — 三列 source inventory raw: TYPE<TAB>VALUE<TAB>SOURCE
#   handoffs.tsv  — legacy handoff manifest: PROJECT<TAB>REACHABILITY<TAB>ROOT_RELATIVE_HANDOFF_PATH<TAB>MIGRATION_STATE
#
# 纪律（契约 §A）:
#   - 只读仓库与 registry；不写固定 /tmp 路径（只用 mktemp -d）
#   - 不读取任何 HANDOFF-*.md 正文（无条件按文件名纳入，find -name 仅文件名）
#   - legacy triggers 从 alex/blake SKILL.md 的 `### Key Commands` 块与 CLAUDE.md §2
#     现役路由表机械提取，不凭手抄
#   - route consumer 搜索合并 git grep（tracked）与 untracked 文件扫描
#   - 排序一律 LC_ALL=C
#
# 输出约定：raw 行由下方 { } 块统一管道 LC_ALL=C sort -u 写盘；
# manifest 行显式追加到 $TMP/manifest.tsv，结尾排序落盘。

set -u
set -o pipefail   # 管道任一环节失败即整体失败（P2-2 残留：子 shell exit 1 必须传播到调用方）

# 参数检查必须先于任何 $1/$2 解引用（set -u 下未绑定变量会提前炸掉 usage 守卫）
if [ "$#" -lt 2 ]; then
  echo "usage: $0 <raw.tsv> <handoffs.tsv>" >&2
  exit 2
fi
RAW_OUT="$1"
MANIFEST_OUT="$2"
[ -f "$RAW_OUT" ] && echo "refusing to overwrite existing $RAW_OUT" >&2 && exit 2
[ -f "$MANIFEST_OUT" ] && echo "refusing to overwrite existing $MANIFEST_OUT" >&2 && exit 2

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 2

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
: > "$TMP/manifest.tsv"

# ---- 全模式（full 暴露/消费信号；-lite 变体与路径字面用边界排除）----
FULL_PATTERN='\.claude/skills/(alex|blake|gate)([^-a-zA-Z0-9]|$)|\.agents/skills/(alex|blake|gate)([^-a-zA-Z0-9]|$)|/alex([^-a-zA-Z0-9]|$)|/blake([^-a-zA-Z0-9]|$)|/gate([^-a-zA-Z0-9]|$)|HANDOFF-'

# 历史/归档/备份前缀（机械路径前缀，契约 §A route_consumer 的"现役"界定的实现）
HISTORICAL_PREFIXES=(
  '.tad/archive/' '.tad/evidence/' '.tad/memory/' '.git/'
  'docs/legacy/' 'docs/releases/' '.tad/migrations/' '.tad/spike-v3/'
  '.tad/eval/judge/bundles/' '.tad/project-knowledge/incidents/'
  'scripts/archive/' 'tad-work/archive/' '.claude/skills/local/'
)
BACKUP_BASENAME_RE='\.(bak|v[0-9]+-backup)([^a-zA-Z0-9]|$)|-backup([^a-zA-Z0-9]|$)'

# canonical 树自身不是消费者（它们是 canonical_file/mirror_file 的源）
CANONICAL_TREES=(
  '.claude/skills/alex/' '.claude/skills/blake/' '.claude/skills/gate/'
  '.agents/skills/alex/' '.agents/skills/blake/' '.agents/skills/gate/'
)

is_excluded() {
  local f="$1" p
  for p in "${HISTORICAL_PREFIXES[@]}"; do
    case "$f" in
      "$p"*) return 0 ;;
    esac
  done
  local b; b="$(basename "$f")"
  if echo "$b" | grep -qE "$BACKUP_BASENAME_RE"; then return 0; fi
  for p in "${CANONICAL_TREES[@]}"; do
    case "$f" in
      "$p"*) return 0 ;;
    esac
  done
  return 1
}

# ================= raw 行（统一走下方管道落盘）=================
{
  # ---- 1. canonical_file / mirror_file（byte parity 记录）----
  canonical="$(find .claude/skills/alex .claude/skills/blake .claude/skills/gate -type f | LC_ALL=C sort)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf 'canonical_file\t%s\tfs-walk:canonical-tree\n' "$f"
    g=".agents/${f#.claude/}"
    if cmp -s "$f" "$g"; then
      printf 'mirror_file\t%s\tparity:ok\n' "$g"
    else
      printf 'mirror_file\t%s\tparity:FAIL\n' "$g"
    fi
  done <<< "$canonical"

  # ---- 2. legacy_trigger：Key Commands 块（alex/blake）+ CLAUDE.md §2 现役路由表 ----
  # Key Commands 行可含多个反引号命令（如 "`*gate 1` or `*gate 2`"）——提取行内全部 token，
  # 只保留 *cmd / /router 形态（丢弃 --flag 等非命令 token），避免截短
  for role in alex blake; do
    awk '/^### Key Commands/{f=1} f&&/^### /&&!/^### Key Commands/{exit} f' ".claude/skills/$role/SKILL.md" \
      | grep -E '^- `' \
      | grep -oE '`[^`]+`' \
      | tr -d '`' \
      | grep -E '^[*]|^/' \
      | LC_ALL=C sort -u \
      | while IFS= read -r t; do
          printf 'legacy_trigger\t%s\tkey-commands:%s\n' "$t" "$role"
        done
  done
  # 现役路由文档：CLAUDE.md §2 全文（表行 + 正文）中反引号包裹的 *cmd / /router 标记
  # （§2 正文亦公开 full 命令，如 *deps / *tournament / *knowledge-maintain）
  awk '/^## 2\. /{f=1} f&&/^#+ 2\.5/{exit} f' CLAUDE.md \
    | grep -oE '`[^`]+`' \
    | tr -d '`' \
    | grep -E '^[*]|^/' \
    | grep -v -- '-lite' \
    | LC_ALL=C sort -u \
    | while IFS= read -r t; do
        printf 'legacy_trigger\t%s\troute-table:CLAUDE.md\n' "$t"
      done

  # ---- 3. standalone_skill：YAML existing_equivalents 引用的现有独立 skill ----
  ruby -ryaml -e '
    d=YAML.safe_load(File.read(".tad/evidence/designs/full-capability-extraction/capability-disposition.yaml"), permitted_classes:[], aliases:false)
    d.fetch("capabilities",[]).each do |r|
      r.fetch("existing_equivalents",[]).each do |s|
        puts s
      end
    end
  ' 2>/dev/null | LC_ALL=C sort -u | while IFS= read -r s; do
    printf 'standalone_skill\t%s\tyaml:existing_equivalents\n' "$s"
  done

  # ---- 4. route_consumer：tracked（git grep）+ untracked（fs 扫描）合并 ----
  # tracked 扫描排除 HANDOFF-* 路径（不得经 git grep 读 HANDOFF 正文）；
  # 所有 active HANDOFF-* 无条件按文件名纳入，统一由下方 find 循环处理
  tracked="$(git grep -lE "$FULL_PATTERN" -- . ':(exclude).tad/active/handoffs/HANDOFF-*.md' 2>/dev/null | LC_ALL=C sort -u)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    is_excluded "$f" && continue
    case "$f" in
      .tad/active/*) printf 'live_contract_consumer\t%s\tcontent-scan:tracked\n' "$f" ;;
      *) printf 'route_consumer\t%s\tgit-grep:tracked\n' "$f" ;;
    esac
  done <<< "$tracked"

  # untracked 扫描
  git ls-files --others --exclude-standard 2>/dev/null \
    | LC_ALL=C sort -u \
    | while IFS= read -r f; do
        [ -n "$f" ] || continue
        is_excluded "$f" && continue
        # 无条件纳入的 active HANDOFF-*：只碰文件名，不读正文（与下方 find 循环重叠行由 sort -u 去重）
        case "$f" in
          .tad/active/handoffs/HANDOFF-*.md)
            printf 'live_contract_consumer\t%s\tfs-walk:active-dir\n' "$f"
            continue ;;
        esac
        if grep -lqE "$FULL_PATTERN" "$f" 2>/dev/null; then
          case "$f" in
            .tad/active/*) printf 'live_contract_consumer\t%s\tcontent-scan:untracked\n' "$f" ;;
            *) printf 'route_consumer\t%s\tfs-scan:untracked\n' "$f" ;;
          esac
        fi
      done

  # 所有 active HANDOFF-* 无条件按文件名纳入（tracked + untracked，含无 full 关键词者），不读正文
  find .tad/active/handoffs -name 'HANDOFF-*.md' 2>/dev/null \
    | LC_ALL=C sort -u \
    | while IFS= read -r f; do
        printf 'live_contract_consumer\t%s\tfs-walk:active-dir\n' "$f"
      done

  # ---- 5. downstream_summary：.tad/sync-registry.yaml（SOURCE 固定）----
  # registry 是下游计数的唯一关键输入：解析失败必须显式失败（P2-2），不得静默输出全零
  registered=0; reachable=0; missing=0; with_full=0; with_lite=0; active_full_handoffs=0
  if [ ! -f .tad/sync-registry.yaml ]; then
    echo "generate-inventory: .tad/sync-registry.yaml missing — cannot compute downstream_summary" >&2
    exit 1
  fi
  if ! ruby -ryaml -e '
    reg=YAML.safe_load(File.read(".tad/sync-registry.yaml"), permitted_classes:[], aliases:false)
    reg.fetch("projects",[]).each{|p| puts [p["path"],p["name"]].join("\t") }
  ' 2>"$TMP/registry.err" > "$TMP/registry.rows"; then
    echo "generate-inventory: cannot parse .tad/sync-registry.yaml" >&2
    cat "$TMP/registry.err" >&2
    exit 1
  fi
  while IFS=$'\t' read -r path name; do
    [ -n "$path" ] || continue
    registered=$((registered+1))
    if [ -d "$path" ]; then
      reachable=$((reachable+1))
      [ -d "$path/.claude/skills/alex" ] && with_full=$((with_full+1))
      [ -d "$path/.claude/skills/alex-lite" ] && with_lite=$((with_lite+1))
      hcount="$(find "$path/.tad/active/handoffs" -name 'HANDOFF-*.md' 2>/dev/null | wc -l | tr -d ' ')"
      active_full_handoffs=$((active_full_handoffs+hcount))
    else
      missing=$((missing+1))
    fi
  done < "$TMP/registry.rows"

  printf 'downstream_summary\tregistered=%d;reachable=%d;missing=%d;with_full=%d;with_lite=%d;active_full_handoffs=%d\t.tad/sync-registry.yaml\n' \
    "$registered" "$reachable" "$missing" "$with_full" "$with_lite" "$active_full_handoffs"
} | LC_ALL=C sort -u > "$RAW_OUT" || { echo "generate-inventory: inventory generation failed" >&2; exit 1; }

# ================= manifest 行（显式追加，结尾排序落盘）=================
# 复用 §5 已校验的 registry 输出（$TMP/registry.rows），解析失败已在 §5 显式 abort
while IFS=$'\t' read -r path name; do
  [ -n "$path" ] || continue
  if [ ! -d "$path" ]; then
    printf '%s\tmissing\t\tmissing-project\n' "$name" >> "$TMP/manifest.tsv"
    continue
  fi
  find "$path/.tad/active/handoffs" -name 'HANDOFF-*.md' 2>/dev/null \
    | while IFS= read -r h; do
        rel="${h#"$path"/}"
        printf '%s\treachable\t%s\tpending\n' "$name" "$rel" >> "$TMP/manifest.tsv"
      done
done < "$TMP/registry.rows"

LC_ALL=C sort -u "$TMP/manifest.tsv" > "$MANIFEST_OUT"
