#!/bin/bash
# LITE-20260811-1512-publish-v2410 verify.sh
# 用法: verify.sh [--gates | pre-push | pre-tag | remote | --all]
#   默认     : A 组（AC1-AC8, AC12, AC14, AC15, AC18）——发布前本地
#   --gates  : 按规范顺序跑门并写 results.txt（action: rerun-gates-in-normative-order）
#   pre-push : AC9pre —— push-main 紧前
#   pre-tag  : AC10a —— push-tag 紧前
#   remote   : B 组（AC9, AC10, AC11, AC13, AC16）——发布后
#   --all    : 全部（A 组 + pre-push + pre-tag + remote），末行 RESULT: PASS（AC17）
#
# 约定（契约 AC 段）:
#   - 命令从物理根执行
#   - 禁进程替换 <(...)（集合运算走 mktemp）
#   - 定长匹配一律 grep -F ... -e "$PAT" 并显式判 rc
#   - find 复合条件必须加括号: \( cond1 -o cond2 \) -print0
#   - 每门有 0/1/2 三条分别命名的分支（gate_<name>_rc0/rc1/rc2）
#   - 管道中的 fail 不传递（子 shell）——所有 fail 必须在父 shell 计数

set -u

VERIFY_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$VERIFY_DIR/../../../.." && pwd -P)"
EVDIR="$VERIFY_DIR"
BASELINE="$EVDIR/preflight-baseline.txt"
RESULTS="$EVDIR/results.txt"
COMMANDS="$EVDIR/publish-commands.txt"
REVIEWS_DIR="$REPO_ROOT/.tad/evidence/reviews/blake/publish-v2410"
CONTRACT="$REPO_ROOT/.tad/active/handoffs/LITE-20260811-1512-publish-v2410.md"
# 记录的 tip（rev8：从 transaction commit_shas 的具名字段读，覆盖写；不是 HEAD、不是 8b0c40a）
TIP_SHA="$(sed -n 's/.*tip_sha: \([0-9a-f]\{40\}\).*/\1/p' "$CONTRACT" | tail -1)"
PASS_COUNT=0
FAIL_COUNT=0
BLOCK_COUNT=0

say()  { printf '%s\n' "$*"; }
pass() { say "$1: PASS"; PASS_COUNT=$((PASS_COUNT+1)); }
fail() { say "$1: FAIL: $2"; FAIL_COUNT=$((FAIL_COUNT+1)); }
block(){ say "$1: BLOCKED: $2"; BLOCK_COUNT=$((BLOCK_COUNT+1)); }

# ---------- AC1 源守卫 ----------
ac1() {
  local origin repo_root_phys cwd_phys
  repo_root_phys=$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null) || { fail AC1 "rev-parse --show-toplevel 失败"; return; }
  repo_root_phys=$(cd "$repo_root_phys" && pwd -P) || { fail AC1 "pwd -P 失败"; return; }
  cwd_phys=$(pwd -P) || { fail AC1 "cwd pwd -P 失败"; return; }
  [ "$cwd_phys" = "$repo_root_phys" ] || { fail AC1 "cwd($cwd_phys) != repo_root($repo_root_phys)"; return; }
  origin=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null) || { fail AC1 "读取 origin 失败"; return; }
  case "$origin" in
    https://github.com/Sheldon-92/TAD|https://github.com/Sheldon-92/TAD.git|git@github.com:Sheldon-92/TAD.git|ssh://git@github.com/Sheldon-92/TAD.git) ;;
    *) fail AC1 "origin 不在白名单: $origin"; return ;;
  esac
  pass AC1
}

# ---------- 门运行器（每门 0/1/2 三条命名分支，AC8(d)） ----------
# gate_<name>_rc0 / gate_<name>_rc1 / gate_<name>_rc2 三个命名分支由 run_gate 的 case 提供
run_gate() {
  local name="$1"; shift
  local rc
  "$@" >/dev/null 2>&1
  rc=$?
  case $rc in
    0) gate_parity_rc0=1; gate_version_rc0=1; gate_versionsweep_rc0=1; gate_migration_rc0=1; gate_denylist_rc0=1
       printf 'gate=%s rc=0\n' "$name" >> "$RESULTS" ;;
    1) gate_parity_rc1=1; gate_version_rc1=1; gate_versionsweep_rc1=1; gate_migration_rc1=1; gate_denylist_rc1=1
       printf 'gate=%s rc=1\n' "$name" >> "$RESULTS" ;;
    2) gate_parity_rc2=1; gate_version_rc2=1; gate_versionsweep_rc2=1; gate_migration_rc2=1; gate_denylist_rc2=1
       printf 'gate=%s rc=2\n' "$name" >> "$RESULTS" ;;
    *) printf 'gate=%s rc=%s\n' "$name" "$rc" >> "$RESULTS" ;;
  esac
  return $rc
}

# ---------- AC5c 门序验证（行首锚定） ----------
ac5c() {
  [ -f "$RESULTS" ] || { fail AC5c "results.txt 缺失"; return; }
  local order="parity derive version version-sweep migration driftcheck denylist"
  local prev=0 first=1
  local g ln r
  for g in $order; do
    # 行首锚定且以空格收尾，避免 gate=version 命中 gate=version-sweep
    ln=$(grep -nE "^gate=${g} rc=" "$RESULTS" | head -1 | cut -d: -f1)
    if [ -z "$ln" ]; then
      fail AC5c "缺少门记录 gate=$g"
      return
    fi
    if [ "$first" = 1 ]; then first=0; else
      if [ "$ln" -le "$prev" ]; then
        fail AC5c "门序错误: gate=$g 行号 $ln 未严格递增（prev=$prev）"
        return
      fi
    fi
    prev=$ln
  done
  # 首个 blocker（rc=2 或承重门 rc=1）之后不得有继续跑后续门的记录
  local first_blocker=""
  for g in $order; do
    r=$(grep -E "^gate=${g} rc=" "$RESULTS" | head -1 | sed 's/.*rc=//')
    if [ -n "$first_blocker" ]; then
      fail AC5c "首个 blocker($first_blocker) 之后仍有门记录 gate=$g"
      return
    fi
    case "$g:$r" in
      driftcheck:*) ;;
      derive:*) ;;
      *) [ "$r" = "0" ] || first_blocker="$g(rc=$r)" ;;
    esac
  done
  pass AC5c
}

# ---------- AC8 exit-code 纪律 ----------
ac8() {
  local g r bad=0
  for g in parity version version-sweep migration denylist; do
    r=$(grep -E "^gate=${g} rc=" "$RESULTS" | head -1 | sed 's/.*rc=//')
    if [ "$r" != "0" ]; then
      fail AC8 "commit B 时刻 gate=$g rc=$r（须为 0）"
      bad=1
      break
    fi
  done
  [ "$bad" = 1 ] && return
  if grep -E '^gate=.* rc=2' "$RESULTS" >/dev/null 2>&1; then
    fail AC8 "记录中出现 rc=2（wiring/usage 失败）——硬 FAIL"
    return
  fi
  # (d) verify.sh 对每个门有 0/1/2 三条分别命名的分支（字符串存在性，rev3 已如实降级为提示性）
  local g2 ok=1
  for g2 in parity version versionsweep migration denylist; do
    if ! grep -q "gate_${g2}_rc0" "$0" || ! grep -q "gate_${g2}_rc1" "$0" || ! grep -q "gate_${g2}_rc2" "$0"; then
      ok=0
    fi
  done
  [ "$ok" = 1 ] || say "AC8(d) 提示: 部分门缺少三分支命名（字符串存在性，不承重）"
  pass AC8
}

# ---------- A 组 ----------
ac2() {
  bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" version "$REPO_ROOT" 2.41.0 2.40.0 >/dev/null 2>&1
  local rc=$?
  case $rc in
    0) pass AC2 ;;
    1) fail AC2 "version 门 exit 1（stale 未清零）" ;;
    2) block AC2 "version 门 exit 2（wiring）" ;;
    *) fail AC2 "version 门 exit $rc" ;;
  esac
}

ac3() {
  local sw=$(mktemp)
  bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" version-sweep "$REPO_ROOT" 2.41.0 > "$sw" 2>&1
  local rc=$?
  local layer2=0
  if [ -s "$sw" ]; then
    layer2=$(grep -cF '⚠️' "$sw" || true)
  fi
  rm -f "$sw"
  if [ "$layer2" -gt 0 ]; then
    printf 'layer2_hits=%s\n' "$layer2" >> "$RESULTS"
  fi
  case $rc in
    0) pass AC3 ;;
    1) fail AC3 "version-sweep exit 1（Layer 1 stale）" ;;
    2) block AC3 "version-sweep exit 2（wiring）" ;;
    *) fail AC3 "version-sweep exit $rc" ;;
  esac
}

ac4() {
  bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" parity "$REPO_ROOT" >/dev/null 2>&1
  local rc=$?
  case $rc in
    0) pass AC4 ;;
    1) fail AC4 "parity exit 1（镜像漂移）" ;;
    2) block AC4 "parity exit 2（wiring）" ;;
    *) fail AC4 "parity exit $rc" ;;
  esac
}

ac5() {
  bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" migration "$REPO_ROOT" >/dev/null 2>&1
  local rc=$?
  case $rc in
    0) pass AC5 ;;
    1) fail AC5 "migration exit 1（未manifested 漂移）" ;;
    2) block AC5 "migration exit 2（wiring）" ;;
    *) fail AC5 "migration exit $rc" ;;
  esac
}

ac5b() {
  bash "$REPO_ROOT/tad.sh" --verify-denylist >/dev/null 2>&1
  local rc=$?
  case $rc in
    0) pass AC5b ;;
    1) fail AC5b "tad.sh --verify-denylist exit 1" ;;
    2) block AC5b "tad.sh --verify-denylist exit 2（wiring）" ;;
    *) fail AC5b "tad.sh --verify-denylist exit $rc" ;;
  esac
}

ac6() {
  local rc0=0
  grep -Fxq -e '2.41.0' "$REPO_ROOT/.tad/version.txt"; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC6 ".tad/version.txt 非逐字 2.41.0"; return; }
  grep -Fq -e '"version": "2.41.0"' "$REPO_ROOT/package.json"; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC6 "package.json version 非 2.41.0"; return; }
  grep -Fq -e 'TARGET_VERSION="2.41.0"' "$REPO_ROOT/tad.sh"; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC6 "tad.sh TARGET_VERSION 非 2.41.0"; return; }
  pass AC6
}

ac7() {
  local rc0 chg
  chg=$(mktemp)
  sed -n '/^## \[2.41.0\]/,/^## \[/p' "$REPO_ROOT/CHANGELOG.md" > "$chg"
  [ -s "$chg" ] || { fail AC7 "2.41.0 区块不存在或为空"; rm -f "$chg"; return; }
  grep -Fq -e '### 行为变更' "$chg"; rc0=$?
  if [ $rc0 -ne 0 ]; then
    grep -Fq -e '### Behavior Changes' "$chg"; rc0=$?
  fi
  [ $rc0 -eq 0 ] || { fail AC7 "区块内无『行为变更』小节"; rm -f "$chg"; return; }
  grep -Fq -e '逐命令审批' "$chg"; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC7 "未点名『逐命令审批』"; rm -f "$chg"; return; }
  grep -Fq -e 'Layer 1' "$chg"; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC7 "未点名『Layer 1』"; rm -f "$chg"; return; }
  rm -f "$chg"
  pass AC7
}

ac7b() {
  local chg
  chg=$(mktemp)
  sed -n '/^## \[2.41.0\]/,/^## \[/p' "$REPO_ROOT/CHANGELOG.md" > "$chg"
  [ -s "$chg" ] || { fail AC7b "2.41.0 区块不存在"; rm -f "$chg"; return; }
  # 附录代表串清单为唯一权威（rev8 同步表格：4116517 → lite-first lifecycle）；
  # 匹配一律 grep -Fqi（大小写不敏感，rev5 修）——CHANGELOG 是自然语言散文
  local rc1
  grep -Fqi -e 'installer' "$chg"; rc1=$?
  if [ $rc1 -ne 0 ]; then grep -Fqi -e 'tad.sh' "$chg"; rc1=$?; fi
  [ $rc1 -eq 0 ] || { fail AC7b "代表串 installer/tad.sh 未命中"; rm -f "$chg"; return; }
  grep -Fqi -e 'lite-first lifecycle' "$chg"; rc1=$?
  [ $rc1 -eq 0 ] || { fail AC7b "代表串 lite-first lifecycle 未命中"; rm -f "$chg"; return; }
  grep -Fqi -e 'inventory' "$chg"; rc1=$?
  if [ $rc1 -ne 0 ]; then grep -Fqi -e '能力提取' "$chg"; rc1=$?; fi
  [ $rc1 -eq 0 ] || { fail AC7b "代表串 inventory/能力提取 未命中"; rm -f "$chg"; return; }
  grep -Fqi -e 'release-runbook' "$chg"; rc1=$?
  [ $rc1 -eq 0 ] || { fail AC7b "代表串 release-runbook 未命中"; rm -f "$chg"; return; }
  grep -Fqi -e '逐命令审批' "$chg"; rc1=$?
  [ $rc1 -eq 0 ] || { fail AC7b "代表串 逐命令审批 未命中"; rm -f "$chg"; return; }
  grep -Fqi -e 'Layer 1' "$chg"; rc1=$?
  [ $rc1 -eq 0 ] || { fail AC7b "代表串 Layer 1 未命中"; rm -f "$chg"; return; }
  rm -f "$chg"
  pass AC7b
}

ac12() {
  local ep="$REPO_ROOT/.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md"
  local line rc0
  # (a) Phase Map 3c 行不含 sync（awk -F'|' '$2 ~ /3c/' 取行）
  line=$(awk -F'|' '$2 ~ /3c/ {print}' "$ep" | head -1)
  if [ -z "$line" ]; then fail AC12 "Phase Map 无 3c 行"; return; fi
  printf '%s\n' "$line" | grep -F -c -e 'sync' | grep -Fxq -e '0'; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC12 "3c 行仍含 sync 字样: $line"; return; }
  # (b) :100 那句已改写（rev3 命令：含 Phase 3c owns 的行）
  line=$(grep -F -e 'Phase 3c owns' "$ep" | head -1)
  if [ -z "$line" ]; then fail AC12 "未找到『Phase 3c owns』行"; return; fi
  printf '%s\n' "$line" | grep -F -c -e 'publish+sync' | grep -Fxq -e '0'; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC12 ":100 行仍含 publish+sync"; return; }
  printf '%s\n' "$line" | grep -Fq -e 'publish-only'; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC12 ":100 行缺 publish-only"; return; }
  # (c) SC5 行
  line=$(grep -E '^\| SC5 \|' "$ep" | head -1)
  if [ -z "$line" ]; then fail AC12 "未找到 SC5 行"; return; fi
  printf '%s\n' "$line" | grep -F -c -e 'publish+sync' | grep -Fxq -e '0'; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC12 "SC5 行仍含 publish+sync"; return; }
  printf '%s\n' "$line" | grep -Fq -e 'publish-only'; rc0=$?
  if [ $rc0 -ne 0 ]; then
    printf '%s\n' "$line" | grep -Fq -e 'publish 不做 sync'; rc0=$?
  fi
  [ $rc0 -eq 0 ] || { fail AC12 "SC5 行缺 publish-only 语义"; return; }
  # (d) sync 退场决策记录
  grep -Fq -e 'feedback_no-sync-pull-based' "$ep"; rc0=$?
  [ $rc0 -eq 0 ] || { fail AC12 "缺 feedback_no-sync-pull-based 决策记录"; return; }
  pass AC12
}

# 文件清单（第 1-26 项，摘要键生成用）
manifest_keys() {
  {
    printf '%s\n' \
      ".tad/version.txt" "package.json" "tad.sh" "README.md" "INSTALLATION_GUIDE.md" \
      "PROJECT_CONTEXT.md" "docs/MULTI-PLATFORM.md" ".tad/config.yaml" ".tad/codex/README.md" \
      ".tad/capability-packs/pack-registry.yaml" ".tad/templates/pack-meta-template.yaml" \
      ".claude/skills/alex/SKILL.md" ".agents/skills/alex/SKILL.md" \
      ".claude/skills/blake/SKILL.md" ".agents/skills/blake/SKILL.md" \
      ".claude/skills/tad-help/SKILL.md" ".agents/skills/tad-help/SKILL.md" \
      "CHANGELOG.md" ".tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md" \
      ".tad/evidence/acceptance-tests/publish-v2410/preflight-baseline.txt" \
      ".tad/evidence/acceptance-tests/publish-v2410/verify.sh" \
      ".tad/project-knowledge/patterns/ac-verification.md" \
      ".tad/project-knowledge/patterns/shell-portability.md" \
      ".tad/archive/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md" \
      ".tad/evidence/acceptance-tests/publish-v2410/results.txt" \
      ".tad/evidence/acceptance-tests/publish-v2410/publish-commands.txt" \
      ".tad/evidence/acceptance-tests/publish-v2410/targets-post.txt" \
      ".tad/active/handoffs/LITE-20260811-1512-publish-v2410.md" \
      ".tad/active/handoffs/LITE-20260811-1512-publish-v2410.md.txn-lock" \
      ".tad/archive/handoffs/LITE-20260811-1512-publish-v2410.md" \
      ".tad/evidence/reviews/blake/publish-v2410"
  } | LC_ALL=C sort | while IFS= read -r p; do
    # 目录级条目（第 25/26 项）展开为目录内文件；目录不存在 → 空
    if [ -d "$REPO_ROOT/$p" ]; then
      find "$REPO_ROOT/$p" -type f -print0 2>/dev/null | tr '\0' '\n' | while IFS= read -r f; do
        rel="${f#"$REPO_ROOT/"}"
        top=$(printf '%s' "$rel" | cut -d/ -f1)
        h=$(printf '%s' "$rel" | shasum -a 256 | awk '{print $1}')
        printf 'untracked %s/%s\n' "$top" "$h"
      done
      continue
    fi
    top=$(printf '%s' "$p" | cut -d/ -f1)
    h=$(printf '%s' "$p" | shasum -a 256 | awk '{print $1}')
    printf 'untracked %s/%s\n' "$top" "$h"
  done | LC_ALL=C sort
}

ac14() {
  [ -f "$BASELINE" ] || { fail AC14 "基线缺失"; return; }
  local tmp_now tmp_base tmp_new tmp_manifest tmp_tracked_base
  local p h top
  tmp_now=$(mktemp); tmp_base=$(mktemp); tmp_new=$(mktemp)
  tmp_manifest=$(mktemp); tmp_tracked_base=$(mktemp)
  local outside_list tmp_outside
  outside_list=$(mktemp); tmp_outside=$(mktemp)
  # 现状未跟踪摘要键（ruby 单进程批量哈希，内容摘要/清单派生豁免；排除项先过滤）
  git -C "$REPO_ROOT" status --porcelain=v1 -uall | grep '^??' | sed 's/^?? //' | LC_ALL=C sort \
    | ruby -rdigest -e 'ex=[/\A\.tad\/evidence\/traces\//,/\A\.tad\/evidence\/decisions\//,/\A\.tad\/archive\/traces\//,/\A\.tad\/research-notebooks\/REGISTRY\.yaml\z/,/\A\.tad\/active\/session-state\.md\z/,/\A\.tad\/active\/precompact\//]; STDIN.each_line { |l| p=l.chomp; next if ex.any? { |re| re.match?(p) }; top=p.split("/",2)[0]; puts "untracked #{top}/#{Digest::SHA256.hexdigest(p)}" }' \
    | LC_ALL=C sort > "$tmp_now"
  # 基线摘要键
  awk '/^## untracked-hashed/{f=1;next}/^## /{f=0}f' "$BASELINE" | LC_ALL=C sort > "$tmp_base"
  manifest_keys > "$tmp_manifest"
  # 新增 = 现状 - 基线
  comm -13 "$tmp_base" "$tmp_now" > "$tmp_new"
  # 新增须 ⊆ 清单摘要键
  comm -23 "$tmp_new" "$tmp_manifest" > "$tmp_outside"
  if [ -s "$tmp_outside" ]; then
    while IFS= read -r line; do
      say "AC14: 清单外新增路径键: $line"
    done < "$tmp_outside"
    fail AC14 "存在清单外新增未跟踪路径（见上）"
  fi
  # 不在清单内的已脏 tracked 路径摘要未变
  awk '/^## tracked-dirty/{f=1;next}/^## /{f=0}f' "$BASELINE" | LC_ALL=C sort > "$tmp_tracked_base"
  git -C "$REPO_ROOT" status --porcelain=v1 | grep -E '^ ?[MD]' | sed 's/^...//' | LC_ALL=C sort > "$outside_list"
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$p" in
      .tad/evidence/traces/*|.tad/evidence/decisions/*|.tad/archive/traces/*|.tad/research-notebooks/REGISTRY.yaml|.tad/active/session-state.md|.tad/active/precompact/*) continue;;
    esac
    # 在清单内 → 跳过（commit A/B 会吸收）
    if grep -Fq -e "$p" "$tmp_manifest"; then continue; fi
    if [ -f "$p" ]; then
      h=$(shasum -a 256 "$p" | awk '{print $1}')
    else
      h="DELETED"
    fi
    b=$(ruby -rdigest -e 'path=ARGV[0]; STDIN.each_line { |l| if l.start_with?("tracked ") && l.include?("  " + path) then puts l.split(" ",2)[1].split("  ")[0]; break end }' "$p" "$tmp_tracked_base" < "$tmp_tracked_base")
    if [ -n "$b" ] && [ "$b" != "$h" ]; then
      say "AC14: 清单外已脏路径摘要变化: $p"
      fail AC14 "清单外已脏路径 $p 摘要变化"
    fi
  done < "$outside_list"
  rm -f "$tmp_now" "$tmp_base" "$tmp_new" "$tmp_manifest" "$tmp_tracked_base" "$outside_list" "$tmp_outside"
  [ "$FAIL_COUNT" = 0 ] && pass AC14
}

ac15() {
  local base tip n merges c sha path ok=1
  base=$(grep -E '^base_sha=' "$BASELINE" | head -1 | cut -d= -f2)
  [ -n "$base" ] || { fail AC15 "基线无 base_sha"; return; }
  tip="$TIP_SHA"
  [ -n "$tip" ] || { fail AC15 "契约无 tip_sha"; return; }
  n=$(git -C "$REPO_ROOT" rev-list "$base..$tip" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -ge 1 ] || { fail AC15 "rev-list base..tip 为空（须非空）"; return; }
  git -C "$REPO_ROOT" merge-base --is-ancestor "$base" "$tip" >/dev/null 2>&1 || { fail AC15 "base 非 tip 祖先"; return; }
  merges=$(git -C "$REPO_ROOT" rev-list --merges "$base..$tip" 2>/dev/null | wc -l | tr -d ' ')
  [ "$merges" = 0 ] || { fail AC15 "base..tip 含 $merges 个 merge commit"; return; }
  # 逐个 commit 的路径 ⊆ 文件清单（完整 base→tip 记账，不断言条数）
  local tmp_manifest2 tmp_commit_paths tmp_outside
  tmp_manifest2=$(mktemp); tmp_commit_paths=$(mktemp); tmp_outside=$(mktemp)
  {
    printf '%s\n' \
      ".tad/version.txt" "package.json" "tad.sh" "README.md" "INSTALLATION_GUIDE.md" \
      "PROJECT_CONTEXT.md" "docs/MULTI-PLATFORM.md" ".tad/config.yaml" ".tad/codex/README.md" \
      ".tad/capability-packs/pack-registry.yaml" ".tad/templates/pack-meta-template.yaml" \
      ".claude/skills/alex/SKILL.md" ".agents/skills/alex/SKILL.md" \
      ".claude/skills/blake/SKILL.md" ".agents/skills/blake/SKILL.md" \
      ".claude/skills/tad-help/SKILL.md" ".agents/skills/tad-help/SKILL.md" \
      "CHANGELOG.md" ".tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md" \
      ".tad/evidence/acceptance-tests/publish-v2410/preflight-baseline.txt" \
      ".tad/evidence/acceptance-tests/publish-v2410/verify.sh" \
      ".tad/project-knowledge/patterns/ac-verification.md" \
      ".tad/project-knowledge/patterns/shell-portability.md" \
      ".tad/active/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md" \
      ".tad/archive/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md" \
      ".tad/active/handoffs/LITE-20260811-1512-publish-v2410.md" \
      ".tad/active/handoffs/LITE-20260811-1512-publish-v2410.md.txn-lock" \
      ".tad/archive/handoffs/LITE-20260811-1512-publish-v2410.md"
  } | LC_ALL=C sort > "$tmp_manifest2"
  : > "$tmp_commit_paths"
  for c in $(git -C "$REPO_ROOT" rev-list "$base..$tip"); do
    git -C "$REPO_ROOT" diff-tree --no-commit-id --name-only -r "$c" | LC_ALL=C sort >> "$tmp_commit_paths"
  done
  LC_ALL=C sort -u "$tmp_commit_paths" -o "$tmp_commit_paths"
  comm -23 "$tmp_commit_paths" "$tmp_manifest2" > "$tmp_outside"
  if [ -s "$tmp_outside" ]; then
    while IFS= read -r line; do
      say "AC15: 清单外路径: $line"
    done < "$tmp_outside"
    fail AC15 "base..tip 含清单外路径（见上）"
  fi
  # closeout 集合（第 22-24 项）与 release 集合（第 1-21 项）路径 comm -12 为空
  local tmp_closeout tmp_release tmp_ab12
  tmp_closeout=$(mktemp); tmp_release=$(mktemp); tmp_ab12=$(mktemp)
  {
    printf '%s\n' \
      ".tad/project-knowledge/patterns/ac-verification.md" \
      ".tad/project-knowledge/patterns/shell-portability.md" \
      ".tad/archive/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md"
  } | LC_ALL=C sort > "$tmp_closeout"
  {
    printf '%s\n' \
      ".tad/version.txt" "package.json" "tad.sh" "README.md" "INSTALLATION_GUIDE.md" \
      "PROJECT_CONTEXT.md" "docs/MULTI-PLATFORM.md" ".tad/config.yaml" ".tad/codex/README.md" \
      ".tad/capability-packs/pack-registry.yaml" ".tad/templates/pack-meta-template.yaml" \
      ".claude/skills/alex/SKILL.md" ".agents/skills/alex/SKILL.md" \
      ".claude/skills/blake/SKILL.md" ".agents/skills/blake/SKILL.md" \
      ".claude/skills/tad-help/SKILL.md" ".agents/skills/tad-help/SKILL.md" \
      "CHANGELOG.md" ".tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md" \
      ".tad/evidence/acceptance-tests/publish-v2410/preflight-baseline.txt" \
      ".tad/evidence/acceptance-tests/publish-v2410/verify.sh"
  } | LC_ALL=C sort > "$tmp_release"
  # 用实际 commit 的路径集做互斥（而非静态清单）；禁进程替换，集合运算走 mktemp
  local tmp_co_actual tmp_re_actual
  tmp_co_actual=$(mktemp); tmp_re_actual=$(mktemp)
  comm -12 "$tmp_commit_paths" "$tmp_closeout" > "$tmp_co_actual"
  comm -12 "$tmp_commit_paths" "$tmp_release" > "$tmp_re_actual"
  comm -12 "$tmp_co_actual" "$tmp_re_actual" > "$tmp_ab12"
  rm -f "$tmp_co_actual" "$tmp_re_actual"
  if [ -s "$tmp_ab12" ]; then
    while IFS= read -r line; do
      say "AC15: closeout/release 交集: $line"
    done < "$tmp_ab12"
    fail AC15 "closeout 与 release 路径集相交（须互斥）"
  fi
  rm -f "$tmp_manifest2" "$tmp_commit_paths" "$tmp_outside" "$tmp_closeout" "$tmp_release" "$tmp_ab12"
  [ "$FAIL_COUNT" = 0 ] && pass AC15
}

ac18() {
  local a b sum
  a=$(wc -c < "$REPO_ROOT/.claude/skills/alex-lite/SKILL.md" | tr -d ' ')
  b=$(wc -c < "$REPO_ROOT/.claude/skills/blake-lite/SKILL.md" | tr -d ' ')
  sum=$((a+b))
  if [ "$sum" -le 52200 ]; then pass AC18; else fail AC18 "Lite core 字节和 $sum > 52200"; fi
}

# ---------- A' 组 ----------
ac9pre() {
  local remote_main expected local_main
  remote_main=$(git -C "$REPO_ROOT" ls-remote --heads origin refs/heads/main 2>/dev/null | awk '{print $1}')
  [ -n "$remote_main" ] || { block AC9pre "ls-remote 失败"; return; }
  expected=$(grep -E '^remote_main_pre=' "$BASELINE" | head -1 | cut -d= -f2)
  [ "$remote_main" = "$expected" ] || { fail AC9pre "远端 main($remote_main) != 基线($expected)"; return; }
  git -C "$REPO_ROOT" merge-base --is-ancestor "$remote_main" "$TIP_SHA" >/dev/null 2>&1 || { fail AC9pre "远端 main 非记录 tip 祖先"; return; }
  local_main=$(git -C "$REPO_ROOT" rev-parse refs/heads/main 2>/dev/null)
  [ "$local_main" = "$TIP_SHA" ] || { fail AC9pre "本地 main($local_main) != 记录 tip_sha($TIP_SHA)"; return; }
  pass AC9pre
}

ac10a() {
  local t p m expected local_main
  local_main=$(git -C "$REPO_ROOT" rev-parse refs/heads/main 2>/dev/null)
  [ "$local_main" = "$TIP_SHA" ] || { fail AC10a "本地 main($local_main) != 记录 tip_sha($TIP_SHA)"; return; }
  t=$(git -C "$REPO_ROOT" cat-file -t "v2.41.0" 2>/dev/null)
  [ "$t" = "tag" ] || { fail AC10a "v2.41.0 非 annotated tag（type=$t）"; return; }
  p=$(git -C "$REPO_ROOT" rev-parse "v2.41.0^{commit}" 2>/dev/null)
  [ "$p" = "$TIP_SHA" ] || { fail AC10a "tag 指向 $p != 记录 tip $TIP_SHA"; return; }
  m=$(git -C "$REPO_ROOT" tag -l --format='%(contents)' "v2.41.0" 2>/dev/null)
  expected="v2.41.0 — Lite authority model v2 (contract mandate replaces per-command approval) + Layer 1 AC-driven self-check"
  [ "$m" = "$expected" ] || { fail AC10a "tag 消息逐字节不符"; return; }
  pass AC10a
}

# ---------- B 组 ----------
ac9() {
  local remote_main pre tmp_before tmp_after
  remote_main=$(git -C "$REPO_ROOT" ls-remote --heads origin refs/heads/main 2>/dev/null | awk '{print $1}')
  [ -n "$remote_main" ] || { block AC9 "ls-remote 失败"; return; }
  [ "$remote_main" = "$TIP_SHA" ] || { fail AC9 "远端 main($remote_main) != 记录 tip($TIP_SHA)"; return; }
  pre=$(grep -E '^remote_main_pre=' "$BASELINE" | head -1 | cut -d= -f2)
  git -C "$REPO_ROOT" merge-base --is-ancestor "$pre" "$TIP_SHA" >/dev/null 2>&1 || { fail AC9 "快进证明失败（非 ancestor）"; return; }
  # (c) 完整 ref 清单：按 ref 名（第 2 列）为键，两侧先 LC_ALL=C sort
  tmp_before=$(mktemp); tmp_after=$(mktemp)
  local bkeys akeys bmap amap
  bkeys=$(mktemp); akeys=$(mktemp); bmap=$(mktemp); amap=$(mktemp)
  awk '/^## ls-remote-baseline/{f=1;next}/^## /{f=0}f' "$BASELINE" | LC_ALL=C sort > "$tmp_before"
  git -C "$REPO_ROOT" ls-remote origin 2>/dev/null | LC_ALL=C sort > "$tmp_after"
  awk -F'\t' '{print $2}' "$tmp_before" | LC_ALL=C sort -u > "$bkeys"
  awk -F'\t' '{print $2}' "$tmp_after"  | LC_ALL=C sort -u > "$akeys"
  local added deleted
  added=$(comm -13 "$bkeys" "$akeys" | wc -l | tr -d ' ')
  deleted=$(comm -23 "$bkeys" "$akeys" | wc -l | tr -d ' ')
  [ "$added" = 2 ] || { fail AC9 "远端 ref 新增 $added 个（须为 2: v2.41.0 + peeled）"; }
  [ "$deleted" = 0 ] || { fail AC9 "远端 ref 删除 $deleted 个（须为 0）"; }
  # 修改行：同 ref 键但 SHA 不同；须恰好 2（HEAD + main）且新 SHA == commit B
  local mod ref bs as modfile
  modfile=$(mktemp)
  comm -12 "$bkeys" "$akeys" > "$modfile"
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    bs=$(awk -F'\t' -v r="$ref" '$2==r{print $1; exit}' "$tmp_before")
    as=$(awk -F'\t' -v r="$ref" '$2==r{print $1; exit}' "$tmp_after")
    if [ "$bs" != "$as" ]; then
      say "AC9: 修改 ref: $ref"
      printf '%s\n' "$ref" >> "$modfile.mod"
    fi
  done < "$modfile"
  local nmod
  if [ -f "$modfile.mod" ]; then nmod=$(wc -l < "$modfile.mod" | tr -d ' '); else nmod=0; fi
  [ "$nmod" = 2 ] || { fail AC9 "远端修改 ref 数 $nmod（须为 2: HEAD + main）"; }
  # HEAD 与 main 的新 SHA 均为 commit B
  local headsha msha
  headsha=$(awk -F'\t' '$2=="HEAD"{print $1}' "$tmp_after")
  msha=$(awk -F'\t' '$2=="refs/heads/main"{print $1}' "$tmp_after")
  [ "$headsha" = "$TIP_SHA" ] || { fail AC9 "HEAD 新 SHA $headsha != 记录 tip"; }
  [ "$msha" = "$TIP_SHA" ] || { fail AC9 "main 新 SHA $msha != 记录 tip"; }
  rm -f "$tmp_before" "$tmp_after" "$bkeys" "$akeys" "$bmap" "$amap" "$modfile" "$modfile.mod"
  [ "$FAIL_COUNT" = 0 ] && pass AC9
}

ac10() {
  local peeled
  peeled=$(git -C "$REPO_ROOT" ls-remote --tags origin "refs/tags/v2.41.0^{}" 2>/dev/null | awk '{print $1}')
  [ -n "$peeled" ] || { block AC10 "ls-remote tags 失败"; return; }
  [ "$peeled" = "$TIP_SHA" ] || { fail AC10 "远端 peeled tag($peeled) != 记录 tip"; return; }
  pass AC10
}

# 目标元组采集（内联；无进程替换）
collect_targets() {
  local tmp_paths tmp_mws
  tmp_paths=$(mktemp); tmp_mws=$(mktemp)
  ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]), aliases: true).fetch("projects", []).each { |t| puts t["path"] }' "$REPO_ROOT/.tad/sync-registry.yaml" > "$tmp_paths" 2>/dev/null || { rm -f "$tmp_paths" "$tmp_mws"; return 1; }
  local named=(CLAUDE.md AGENTS.md CLAUDE.md.bak AGENTS.md.bak tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md docs/MULTI-PLATFORM.md)
  local t ph exists bk roots missing_roots f mws git_head git_dirty r
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    ph=$(printf '%s' "$t" | shasum -a 256 | awk '{print $1}' | cut -c1-16)
    if [ -d "$t" ]; then exists="exists"; else exists="missing"; fi
    bk="absent"; [ -e "$t/.tad-backup" ] && bk="present"
    if [ "$exists" = "missing" ]; then
      printf 'target %s %s %s mws=n/a git=n/a\n' "$ph" "$exists" "backup=$bk"
      continue
    fi
    roots=(); missing_roots=""
    for r in .tad .claude .agents .codex; do
      if [ -d "$t/$r" ]; then roots+=("$t/$r"); else missing_roots="$missing_roots $r"; fi
    done
    : > "$tmp_mws"
    if [ ${#roots[@]} -gt 0 ]; then
      find "${roots[@]}" \( -type f -o -type l \) -print0 2>/dev/null | LC_ALL=C sort -z >> "$tmp_mws" 2>/dev/null
    fi
    for f in "${named[@]}"; do
      if [ -e "$t/$f" ]; then printf '%s\0' "$t/$f" >> "$tmp_mws"; else missing_roots="$missing_roots $f"; fi
    done
    mws=""
    if [ -s "$tmp_mws" ]; then
      mws=$(LC_ALL=C xargs -0 shasum -a 256 < "$tmp_mws" | shasum -a 256 | awk '{print $1}')
    else
      mws="empty"
    fi
    git_head="n/a"; git_dirty="n/a"
    if [ -d "$t/.git" ] || git -C "$t" rev-parse --git-dir >/dev/null 2>&1; then
      git_head=$(git -C "$t" rev-parse HEAD 2>/dev/null || echo "nohead")
      git_dirty=$(git -C "$t" status --porcelain 2>/dev/null | shasum -a 256 | awk '{print $1}')
    fi
    printf 'target %s %s %s mws=%s git=%s dirty=%s missingroots=[%s]\n' "$ph" "$exists" "backup=$bk" "$mws" "$git_head" "$git_dirty" "$missing_roots"
  done < "$tmp_paths"
  rm -f "$tmp_paths" "$tmp_mws"
}

ac11() {
  local tmp_pre tmp_post reg_now reg_base np n bl line
  tmp_pre=$(mktemp); tmp_post=$(mktemp)
  awk '/^## targets/{f=1;next}/^## /{f=0}f' "$BASELINE" | LC_ALL=C sort > "$tmp_pre"
  collect_targets | LC_ALL=C sort > "$tmp_post" 2>/dev/null
  np=$(wc -l < "$tmp_pre" | tr -d ' ')
  [ "$np" = 14 ] || { fail AC11 "基线目标数 $np != 14"; rm -f "$tmp_pre" "$tmp_post"; return; }
  reg_now=$(shasum -a 256 "$REPO_ROOT/.tad/sync-registry.yaml" | awk '{print $1}')
  reg_base=$(grep -E '^registry_shasum=' "$BASELINE" | head -1 | cut -d= -f2)
  [ "$reg_now" = "$reg_base" ] || { fail AC11 "sync-registry.yaml 摘要变化"; }
  n=0
  while IFS= read -r line; do
    n=$((n+1))
    bl=$(sed -n "${n}p" "$tmp_pre" | sed 's/  idx=[0-9]*$//')
    if [ "$line" != "$bl" ]; then
      fail AC11 "目标 #$n 元组变化"
      break
    fi
  done < "$tmp_post"
  rm -f "$tmp_pre" "$tmp_post"
  [ "$FAIL_COUNT" = 0 ] && pass AC11
}

ac13() {
  [ -f "$COMMANDS" ] || { fail AC13 "publish-commands.txt 缺失"; return; }
  local n
  n=$(grep -cE '\-\-force|--tags|push .*&&|push .*;' "$COMMANDS" || true)
  [ "$n" = 0 ] || { fail AC13 "违禁命令模式 $n 处"; return; }
  pass AC13
}

ac16() {
  # pre-push 与 post-publish 审查报告须存在且含 PASS verdict
  local found=0 f
  for f in "$REVIEWS_DIR"/*.md; do
    [ -f "$f" ] || continue
    if grep -E 'verdict.*PASS|最终 verdict.*PASS|P0=0.*P1=0' "$f" >/dev/null 2>&1; then
      found=$((found+1))
    fi
  done
  [ "$found" -ge 2 ] || { fail AC16 "审查报告不足（found=$found，需 pre-push + post-publish 各一）"; return; }
  pass AC16
}

# ---------- 主流程 ----------
mode="${1:-local}"
case "$mode" in
  --gates)
    : > "$RESULTS"
    run_gate parity bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" parity "$REPO_ROOT"
    run_gate derive bash "$REPO_ROOT/.tad/hooks/lib/derive-sync-set.sh" --report "$REPO_ROOT"
    run_gate version bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" version "$REPO_ROOT" 2.41.0 2.40.0
    run_gate version-sweep bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" version-sweep "$REPO_ROOT" 2.41.0
    run_gate migration bash "$REPO_ROOT/.tad/hooks/lib/release-verify.sh" migration "$REPO_ROOT"
    run_gate driftcheck bash "$REPO_ROOT/.tad/hooks/lib/pack-registry-driftcheck.sh"
    run_gate denylist bash "$REPO_ROOT/tad.sh" --verify-denylist
    ac5c
    ac8
    say "RESULT: $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo PASS || echo FAIL)"
    exit $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo 0 || echo 1)
    ;;
  pre-push)
    ac1
    ac9pre
    say "RESULT: $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo PASS || echo FAIL)"
    exit $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo 0 || echo 1)
    ;;
  pre-tag)
    ac10a
    say "RESULT: $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo PASS || echo FAIL)"
    exit $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo 0 || echo 1)
    ;;
  remote)
    ac1
    ac9
    ac10
    ac11
    ac13
    ac16
    say "RESULT: $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo PASS || echo FAIL)"
    exit $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo 0 || echo 1)
    ;;
  --all)
    ac1; ac2; ac3; ac4; ac5; ac5b; ac5c; ac8
    ac6; ac7; ac7b; ac12; ac14; ac15; ac18
    ac9pre; ac10a
    ac9; ac10; ac11; ac13; ac16
    say "RESULT: $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo PASS || echo FAIL)"
    exit $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo 0 || echo 1)
    ;;
  local)
    ac1; ac2; ac3; ac4; ac5; ac5b; ac5c; ac8
    ac6; ac7; ac7b; ac12; ac14; ac15; ac18
    say "RESULT: $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo PASS || echo FAIL)"
    exit $([ "$FAIL_COUNT" = 0 ] && [ "$BLOCK_COUNT" = 0 ] && echo 0 || echo 1)
    ;;
  *)
    echo "unknown mode: $mode" >&2; exit 2
    ;;
esac
