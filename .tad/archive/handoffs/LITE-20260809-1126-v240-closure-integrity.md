# LITE Handoff: v2.40 收尾完整性——把已验收成果闭合到可追踪基线

**Date**: 2026-08-09

## 目标

把已经技术验收的 `tad.sh` 版本权威根因修复真正纳入 Git 基线，并清除 v2.40 Lite-first 改造留下的两类现行矛盾：README 的 Codex 入口仍推荐 full、已 COMPLETE 的 Epic 仍占据 active 生命周期且残留已废除的 SC2 主判据。

本单完成后，“方向正确、实现已验证、文档一致、生命周期闭合、成果已进入本地可追踪基线”五项必须同时成立；这就是本次“10 分”的可验证定义。为什么现在做：当前 `v2.40.0`/`origin/main` 仍不包含结构性根因修复，若下一次发版忘记带上，陈旧字面量故障仍可能第三次复发。

## 不做什么

- 不改 `tad.sh` 已验收内容；其 md5 必须保持 `887658f1581b660de79feccb14ff2f80`。
- 不改 README 的历史版本说明，包括 v2.35 当时“≤5 files”的历史描述；只修现行 Codex 使用入口。
- 不改任何 `.tad/hooks/**`、skill、配置、版本号或发布物镜像。
- 不 push、不 tag、不 publish、不 sync；两个 commit 均只留在本地。
- 不顺带优化 2.85M token 的历史流程成本。本单只关闭已经实证的成品完整性缺口；流程效率是独立产品问题，不能用一次文档清理冒充解决。
- 不清理或提交工作区中与本单无关的既有脏项。

## 文件清单

### A. 已验收包：只提交，不再编辑

本地 Commit A 精确包含以下 7 个路径：

1. `tad.sh`
2. `.tad/archive/handoffs/LITE-20260807-1050-tadsh-version-authority.md`
3. `.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md`
4. `.tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md`
5. `.tad/evidence/journal/lite-discoveries.md`
6. `.tad/project-knowledge/patterns/ac-verification.md`
7. `.tad/project-knowledge/patterns/_index.md`

建议 commit subject：`fix(installer): make remote version authoritative before no-op`

#### Commit A 批准后 blob manifest（mode + Git blob ID）

这 7 行是用户验收与 Knowledge Closeout 完成后、契约起草时对工作树实测的不可变成品 manifest。Commit A 不只要路径集相等，每个 blob 与 mode 也必须逐一相等：

```text
100755 f09964fb4d1abf556d70c69ebf87b9ea5a1df1c6 tad.sh
100644 2bf98f63505311315a90c135f3eabdf40e8dc032 .tad/archive/handoffs/LITE-20260807-1050-tadsh-version-authority.md
100644 f15af234ba161e399c945e3d3845bdf9b0b3984a .tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md
100644 b8971adcdce9d5565aaeb532b5a77c9114c5221c .tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md
100644 d142e43a948b9b4f5477eff5cd54d0fdfcf516cc .tad/evidence/journal/lite-discoveries.md
100644 6b1d296d7d8696d6a2c908b3a8e7efeba36b5f9c .tad/project-knowledge/patterns/ac-verification.md
100644 4acca4a8872a162cab2fdbe701953cb9411969d0 .tad/project-knowledge/patterns/_index.md
```

### B. 本单实现与收尾

- 修改 `README.md`：仅修改 `## 🔄 Codex CLI Support (v2.26.0)` 当前入口段。
- 修改后归档 `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md`：删除已失效的“SC2 是主判据”句；通过 copy → cmp → 删除源文件的两阶段方式迁移为 `.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md`。
- 创建 `.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md`。
- 创建 `.tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md`。
- 本 handoff 在人工验收后迁移为 `.tad/archive/handoffs/LITE-20260809-1126-v240-closure-integrity.md`。
- 本单 Commit B **不允许**再改 `.tad/evidence/journal/lite-discoveries.md`；它已被 Commit A blob manifest 冻结。若实现期真产生可复用 discovery，停下返回 Alex-Lite 做增量契约审查并重新定价，不得将共享 journal 即兴塞入 Commit B。

本地 Commit B 在人工验收与 handoff 归档后创建。路径集固定为 README、Epic 删除/新增、归档 handoff、两份本单 evidence，不得额外扩展。

建议 commit subject：`chore(tad): close v2.40 lite-first lifecycle`

## 实现决策

1. **两个 commit，不混成一个。** Commit A 固化已经独立验收的根因修复；Commit B 固化本单的文档与生命周期收尾。这样任何回滚、审计或 cherry-pick 都不必把根因修复与文档清理绑死。
2. **Commit A 在本单 Technical Gate PASS 后创建；Commit B 在人工验收并归档本 handoff 后创建。** commit 不改变文件字节，故独立实现审查先审工作树即可；第二个 commit 必须等生命周期终态，否则会把 pending handoff 提交进“完成”基线。
3. **所有提交使用显式 pathspec。** 当前工作区有大量历史脏项，禁止裸 `git add -A`、裸 `git commit` 或按目录批量暂存。
4. **README 只修现行入口。** 目标语义：Codex 默认 `$alex-lite` / `$blake-lite`；`$alex` / `$blake` 明示为 reserved。历史发行说明是当时事实，不追写历史。
5. **Epic 归档采用两阶段安全迁移。** 先修正文，复制到 archive，`cmp` 字节验证，再删除 active 源；不直接依赖不可核验的单步移动。
6. **Commit B 有真实人工门。** Blake-Lite 必须先展示 AC1–AC6、实现 reviewer 与 Technical Gate 证据，然后 STOP；只有人类当轮原文明确表示「验收通过，批准创建 Commit B」或同等清晰意思，才能归档 handoff 并创建 Commit B。未收到则不得自行推定。

## AC

- AC1: **已验收 `tad.sh` 成品零漂移。**
  ```bash
  OUT=$(mktemp)
  if [ "$(md5 -q tad.sh)" = "887658f1581b660de79feccb14ff2f80" ] \
     && bash -n tad.sh \
     && bash .tad/hooks/lib/detect-state-test.sh > "$OUT" \
     && tail -2 "$OUT" | grep -Fq 'TALLY: PASS=12 FAIL=0'; then
    echo AC1-PASS
  else
    echo AC1-FAIL
  fi
  rm -f "$OUT"
  ```
  判据：输出 `AC1-PASS`。任何 md5 变化都意味着本单越权重写已验收实现，必须停下解释，不得更新基线哈希迁就改动。

- AC2: **README 当前 Codex 入口与 Lite-first 一致，历史 v2.35 段零漂移。**
  ```bash
  SEC=$(mktemp)
  sed -n '/^## 🔄 Codex CLI Support/,/^---$/p' README.md > "$SEC"
  grep -Fq 'Use `$alex-lite` or `$blake-lite`' "$SEC" \
    && grep -Fq '# In Codex: $alex-lite or $blake-lite' "$SEC" \
    && grep -Fq '`$alex` / `$blake` remain reserved' "$SEC" \
    && ! grep -Fq 'Use `$alex` or `$blake` to activate roles' "$SEC" \
    && [ "$(sed -n '/^### v2\.35\.0 /,/^### v2\.34\.0 /p' README.md | md5)" = "6fb50d0183ea66542374d61103d83335" ] \
    && echo AC2-PASS || echo AC2-FAIL
  rm -f "$SEC"
  ```
  实现文本允许自然措辞，但必须逐字包含上述三个稳定语义锚。改前基线：旧句存在、新三锚不存在，故 FAIL。

- AC3: **Epic 生命周期闭合且历史结论自洽。**

  Admission 硬前置（任何 Epic 编辑/copy 之前运行，原始输出写入 `ac-results.md`）：
  ```bash
  S=.tad/active/epics/EPIC-20260804-lite-as-tad-body.md
  E=.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md
  git cat-file -e "HEAD:$S" \
    && [ -f "$S" ] \
    && [ ! -e "$E" ] \
    && echo AC3-ADMISSION-PASS \
    || { echo 'AC3-ADMISSION-FAIL: source missing or archive destination exists'; exit 1; }
  ```
  未输出 `AC3-ADMISSION-PASS` 必须停；尤其不得覆盖已存 archive 来追求终态绿灯。

  实现后运行：
  ```bash
  S=.tad/active/epics/EPIC-20260804-lite-as-tad-body.md
  E=.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md
  PRE=$(mktemp)
  git show "HEAD:$S" \
    | sed '\|^\*\*SC2 是主判据\*\*——SC1 是手段，SC2 才是你实际付的钱。$|d' > "$PRE"
  [ ! -e "$S" ] \
    && [ -f "$E" ] \
    && grep -Fq '**Status**: ✅ **COMPLETE**' "$E" \
    && grep -Fq 'SC2' "$E" \
    && grep -Fq '2026-08-06 废除' "$E" \
    && ! grep -Fq '**SC2 是主判据**' "$E" \
    && cmp -s "$PRE" "$E" \
    && echo AC3-PASS || echo AC3-FAIL
  rm -f "$PRE"
  ```
  改前基线：Epic 仍在 active 且命中 `**SC2 是主判据**`，故 FAIL。归档目标若实现前已存在，必须停下，不得覆盖。

- AC4: **v2.40 三个现有发布闸保持绿色。**

  前置 STOP：这是全局闸，只能在人类确认没有其他终端正在改 `.claude/skills` / `.agents/skills` / 版本注册路径的 quiet point 运行。若当下不是 quiet point，记录 `UNVERIFIED: concurrent mutation`、不运行 `--fix`、等待静默窗口后重跑；未重跑绿不得进 Technical Gate。
  ```bash
  bash .tad/hooks/lib/release-verify.sh version . 2.40.0 \
    && bash .tad/hooks/lib/release-verify.sh version-sweep . 2.40.0 \
    && bash .tad/hooks/lib/release-verify.sh parity . \
    && echo AC4-PASS || echo AC4-FAIL
  ```
  判据：三个 verifier 均 exit 0，最终输出 `AC4-PASS`。`version-sweep` Layer 2 的历史版本命中是 advisory，不得伪装成零；Layer 1 必须 12 verified / 0 warnings。

- AC5: **实现阶段状态差是机械白名单，不只打印给人看。** Blake-Lite admission 时、任何实现写入前运行（使用 `--untracked-files=all` 展开既有未跟踪目录）：
  ```bash
  git status --porcelain=v1 --untracked-files=all | LC_ALL=C sort > /tmp/v240-closure-before.txt
  LC_ALL=C sort -c /tmp/v240-closure-before.txt
  ```
  Technical Gate 前、任何 staging/commit 之前运行：
  ```bash
  git status --porcelain=v1 --untracked-files=all | LC_ALL=C sort > /tmp/v240-closure-after.txt
  LC_ALL=C sort -c /tmp/v240-closure-after.txt
  ADD=$(mktemp); DEL=$(mktemp); EXP=$(mktemp)
  LC_ALL=C comm -13 /tmp/v240-closure-before.txt /tmp/v240-closure-after.txt > "$ADD"
  LC_ALL=C comm -23 /tmp/v240-closure-before.txt /tmp/v240-closure-after.txt > "$DEL"
  printf '%s\n' \
    ' D .tad/active/epics/EPIC-20260804-lite-as-tad-body.md' \
    ' M README.md' \
    '?? .tad/archive/epics/EPIC-20260804-lite-as-tad-body.md' \
    '?? .tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md' \
    '?? .tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md' \
    | LC_ALL=C sort > "$EXP"
  diff -u "$EXP" "$ADD" && [ ! -s "$DEL" ] \
    && echo AC5-PASS || echo AC5-FAIL
  rm -f "$ADD" "$DEL" "$EXP"
  ```
  判据：必须输出 `AC5-PASS`。当前 handoff 在 admission 前已存在，故不应出现在新增差集。Commit A 的 7 个既有脏路径不允许内容漂移，另由 AC6 blob manifest 逐文件封闭。

- AC6: **Commit A 精确封装 7 路径，零 rider。** Technical Gate PASS 后用显式 pathspec 创建 Commit A，随即运行：
  ```bash
  A=$(git rev-parse HEAD)
  EXP=$(mktemp); GOT=$(mktemp); MAN=$(mktemp)
  printf '%s\n' \
    '.tad/archive/handoffs/LITE-20260807-1050-tadsh-version-authority.md' \
    '.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md' \
    '.tad/evidence/journal/lite-discoveries.md' \
    '.tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md' \
    '.tad/project-knowledge/patterns/_index.md' \
    '.tad/project-knowledge/patterns/ac-verification.md' \
    'tad.sh' | LC_ALL=C sort > "$EXP"
  git show --no-renames --format= --name-only "$A" | sed '/^$/d' | LC_ALL=C sort > "$GOT"
  printf '%s\n' \
    '100755 f09964fb4d1abf556d70c69ebf87b9ea5a1df1c6 tad.sh' \
    '100644 2bf98f63505311315a90c135f3eabdf40e8dc032 .tad/archive/handoffs/LITE-20260807-1050-tadsh-version-authority.md' \
    '100644 f15af234ba161e399c945e3d3845bdf9b0b3984a .tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md' \
    '100644 b8971adcdce9d5565aaeb532b5a77c9114c5221c .tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md' \
    '100644 d142e43a948b9b4f5477eff5cd54d0fdfcf516cc .tad/evidence/journal/lite-discoveries.md' \
    '100644 6b1d296d7d8696d6a2c908b3a8e7efeba36b5f9c .tad/project-knowledge/patterns/ac-verification.md' \
    '100644 4acca4a8872a162cab2fdbe701953cb9411969d0 .tad/project-knowledge/patterns/_index.md' > "$MAN"
  OK=1
  while read -r mode hash path; do
    git ls-tree "$A" -- "$path" | awk -v m="$mode" -v h="$hash" \
      '$1 == m && $3 == h { ok=1 } END { exit !ok }' || OK=0
  done < "$MAN"
  diff -u "$EXP" "$GOT" \
    && [ "$OK" -eq 1 ] \
    && [ "$(git log -1 --format=%s "$A")" = 'fix(installer): make remote version authoritative before no-op' ] \
    && echo AC6-PASS || echo AC6-FAIL
  rm -f "$EXP" "$GOT" "$MAN"
  ```
  commit subject 必须为 `fix(installer): make remote version authoritative before no-op`。失败时不得 amend 猜修；先报告差异并确认 rider 来源。

- AC7: **Commit B 在人工验收后闭合本单，且没有遗留本单范围内未提交改动。** 归档 handoff、创建 Commit B 后运行：
  ```bash
  B=$(git rev-parse HEAD)
  A=$(git rev-parse "$B^")
  EXP=$(mktemp); GOT=$(mktemp)
  printf '%s\n' \
    '.tad/active/epics/EPIC-20260804-lite-as-tad-body.md' \
    '.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md' \
    '.tad/archive/handoffs/LITE-20260809-1126-v240-closure-integrity.md' \
    '.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md' \
    '.tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md' \
    'README.md' | LC_ALL=C sort > "$EXP"
  git show --no-renames --format= --name-only "$B" | sed '/^$/d' | LC_ALL=C sort > "$GOT"
  PRE=$(mktemp); POST=$(mktemp)
  git show "$B^:.tad/active/epics/EPIC-20260804-lite-as-tad-body.md" \
    | sed '\|^\*\*SC2 是主判据\*\*——SC1 是手段，SC2 才是你实际付的钱。$|d' > "$PRE"
  git show "$B:.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md" > "$POST"
  diff -u "$EXP" "$GOT" \
    && cmp -s "$PRE" "$POST" \
    && [ "$(git log -1 --format=%s "$A")" = 'fix(installer): make remote version authoritative before no-op' ] \
    && [ "$(git log -1 --format=%s "$B")" = 'chore(tad): close v2.40 lite-first lifecycle' ] \
    && git diff --quiet HEAD -- README.md tad.sh \
         .tad/active/epics/EPIC-20260804-lite-as-tad-body.md \
         .tad/archive/epics/EPIC-20260804-lite-as-tad-body.md \
         .tad/archive/handoffs/LITE-20260807-1050-tadsh-version-authority.md \
         .tad/archive/handoffs/LITE-20260809-1126-v240-closure-integrity.md \
         .tad/evidence/acceptance-tests/v240-closure-integrity \
         .tad/evidence/reviews/blake/v240-closure-integrity \
         .tad/project-knowledge/patterns/ac-verification.md \
         .tad/project-knowledge/patterns/_index.md \
    && ! git ls-files --others --exclude-standard -- \
         README.md tad.sh \
         .tad/active/epics/EPIC-20260804-lite-as-tad-body.md \
         .tad/archive/epics/EPIC-20260804-lite-as-tad-body.md \
         .tad/archive/handoffs/LITE-20260807-1050-tadsh-version-authority.md \
         .tad/archive/handoffs/LITE-20260809-1126-v240-closure-integrity.md \
         .tad/evidence/acceptance-tests/v240-closure-integrity \
         .tad/evidence/reviews/blake/v240-closure-integrity \
         .tad/project-knowledge/patterns/ac-verification.md \
         .tad/project-knowledge/patterns/_index.md | grep -q . \
    && echo AC7-PASS || echo AC7-FAIL
  rm -f "$EXP" "$GOT" "$PRE" "$POST"
  ```
  `git diff --quiet` 只检查本单命名路径；其他历史脏项允许继续存在，禁止为了“全仓干净”捎带提交。

## AC 空跑记录（2026-08-09）

- 空跑记录 AC1：当前 `tad.sh` md5=`887658f1581b660de79feccb14ff2f80`；`bash -n` exit 0；既有测试 `TALLY: PASS=12 FAIL=0`，正确基线 PASS。
- 空跑记录 AC2：当前 Codex 段 md5=`5977d6caad179161a4e1fca12d943a73`，旧句存在、新三锚不存在，改前 FAIL；历史 v2.35 段 md5=`6fb50d0183ea66542374d61103d83335`。
- 空跑记录 AC3：active 源存在、archive 目标不存在、废弃主判据句存在，改前 FAIL。
- 空跑记录 AC4：三闸本机实跑均 exit 0；version-sweep Layer 1=`12 verified, 0 warnings`，Layer 2=`483 advisory hits`；parity byte-identical。
- 空跑记录 AC5：设计时状态快照经 `LC_ALL=C sort -c` 通过；不把设计时总数写进判据。增量集改为机械 allowlist 差，并用 `--untracked-files=all` 避免目录折叠盲区。
- 空跑记录 AC6/AC7：命令只读取将来 commit 对象；`printf` 构造，无 heredoc；路径含空格的仓库根不进入 path list，命令在 repo root 运行。AC6 同时核 blob+mode+subject；AC7 使用 `--no-renames`、直接 parent subject、Epic 完整内容差与 tracked/staged/untracked residue 检查。

## 知识引用

- `.tad/project-knowledge/patterns/handoff-design.md` §`Concurrent Terminals Share the Git Index...` — 当前工作区有大量其他任务脏项；两个 commit 必须 pathspec 精确封装，不能裸提交。
- `.tad/project-knowledge/patterns/handoff-design.md` §`Manifest + Directory Isolation for Multi-Instance Resources` — 生命周期以目录位置为真值；COMPLETE Epic 留在 active 会持续污染状态消费者。
- `.tad/project-knowledge/patterns/ac-verification.md` §`An Extracted Harness Cannot Prove Its Own Extraction Boundary` — 已验收 `tad.sh` 以成品 md5 + 既有行为测试冻结，本单不重新用文本锚替代核心行为验证。
- `.tad/project-knowledge/patterns/release-sync.md` §`Content Guard Must Run Before Identity Early-Exit` — parity 的绿色只证明双树一致，不证明所有发布属性；所以本单同时跑 version、version-sweep、parity 三个不同职责的闸。
- `.agents/skills/tad-maintain/SKILL.md` §`Check 1 - STALE` — 明确定义“全部 phase Done 但仍在 active/epics”为 STALE，并规定两阶段迁移到 archive。此为本单唯一工具编排文档引用。

## Contract Review (2026-08-09)

Reviewer: Codex independent subagent | model=GPT-5.6-Sol, harness=Codex, route=/root/v240_closure_contract_review
首轮 verdict: **FAIL**
增量复核 1 (2026-08-09): **CONDITIONAL**——原 P0 全部关闭；剩余 P1 为 archive 目标不存在未机械准入、AC7 目录级 residual pathspec 会被其它 Epic 误伤。已补 AC3 admission 命令并改为两个 Epic 精确文件 pathspec。
增量复核 2 (2026-08-09): **PASS**——AC3 admission 当前基线实跑 `AC3-ADMISSION-PASS`；AC7 两处 residual 检查均已收窄为唯一目标 Epic 文件。7 条 AC 全部已审、命令与前置条件可执行，可交接。
增量复核 3 (2026-08-09): **PASS**——Blake-Lite L0.5 实测发现「AC 空跑记录」的 6 条摘要复用 `- AC…` 前缀，使机械计数 7→13。只将摘要标签改为 `- 空跑记录 AC…`；7 个 AC 的标题、命令、目标与范围未变。原 L0.5 命令重跑 `COUNT=7`，仅输出 AC1–AC7，与 `已审 AC 条数: 7` 一致。
最终 verdict: **PASS**
P0=2(fixed), P1=6(fixed), P2=2(fixed); 已审 AC 条数: 7
关键发现: AC3 锚点无法证明 Epic 完整迁移；Commit A/B 路径集无法阻止共享 journal 的同路径 rider；AC5 只打印差集且折叠 untracked 目录；AC7 漏 staged/untracked residue；AC4 缺 quiet-point 前置；AC1 管道掩盖上游退出码；AC6 漏 subject/rename 差异。均已按 reviewer 给出的可执行方向修订。

## 风险与注意

1. **Git index 是共享状态。** 当前 tracked/untracked 脏项很多；Commit A/B 任一裸 add/commit 都可能捎带其他终端成果。AC6/AC7 用提交对象的路径集合做事后封闭验证。
2. **Commit B 只能在人工验收后产生。** 若在 handoff 仍位于 active 时提交，会立刻制造下一条生命周期残留，直接违背本单目标。
3. **Epic consumer 有界检查已做。** `.tad/hooks/startup-health.sh` 与 `precompact-session-snapshot.sh` 只读取 active，用于计数/快照，归档后应自然变为 0 active；`.tad/hooks/lib/audit-yolo.sh` 在 active 查不到时会回退 archive，历史查找仍可达；`tad-maintain` 明确定义本状态为 STALE 并要求归档。未声称无下游影响。
4. **三闸目前为绿，不代表可以发布。** 本单禁止 push/tag/publish/sync；它只建立本地可追踪基线。远端发布仍需另一次明确人授权。
5. **README 历史段不是现行路由。** 修改 v2.35 历史描述会篡改版本史且扩大范围，AC2 用 md5 保持它不动；只修当前 Codex 使用入口。
6. **Commit A 包含 SAFETY 索引更新。** 用户已于 2026-08-09 明确选择授权更新 `patterns/_index.md`；本单只提交已完成的授权改动，不再改变其内容。

## Lite Progress

### Admission — 2026-08-09
Phase=admission
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/active/handoffs/LITE-20260809-1126-v240-closure-integrity.md (L0.5 COUNT=7, verdict PASS; AC3-ADMISSION-PASS; AC5-ADMISSION-SNAPSHOT-PASS)
Next Action=按文件清单实现 README 当前入口与 Epic 两阶段迁移
Context refresh=.tad/project-knowledge/principles.md; .tad/project-knowledge/patterns/_index.md; .tad/project-knowledge/patterns/handoff-design.md §§ Manifest + Directory Isolation for Multi-Instance Resources, Concurrent Terminals Share the Git Index and Source Trees: Pathspec-Scope Commits; Run Global Gates at Quiet Points; .tad/project-knowledge/patterns/ac-verification.md § An Extracted Harness Cannot Prove Its Own Extraction Boundary; .tad/project-knowledge/patterns/release-sync.md § Identity Early-Exits Blind Downstream Checks; .agents/skills/tad-maintain/SKILL.md § Step 2e Epic Lifecycle Audit
Phase=implement | 改动文件=README.md、active Epic（两阶段迁移）、v240-closure-integrity/ac-results.md | 最后 AC=AC3-COPY-CMP-DELETE-PASS | 下一动作=L2 逐条自验 | 阻塞/错误类别=首次 AC3 cmp 暴露空行形状差异，已按契约修复 | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md | Next Action=运行 AC1–AC5（AC4 先确认 quiet point）

### Reflexion
- 失败：AC3 copy 前 `cmp` 发现源文件比契约的 `HEAD - 删除单行` 少一个空行 / 假设：删除废弃句时可连同相邻空行一并清理 / 动作：恢复契约要求的空行，重新 `cmp` 后再 copy、cmp、删除 / 结果：`AC3-COPY-CMP-DELETE-PASS`，repair_round=1/3
Phase=ac | 改动文件=README.md、Epic 归档、v240-closure-integrity/ac-results.md | 最后 AC=AC3 PASS | 下一动作=确认 quiet point 后运行 AC4，L3 reviewer 生成载体后重跑 AC5 | 阻塞/错误类别=AC4 全局闸等待人工 quiet-point 确认 | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md | Next Action=WAITING USER-GATED AC
Phase=review | 改动文件=README.md、Epic 归档、v240-closure-integrity/ac-results.md | 最后 AC=AC4 PASS | 下一动作=spawn 独立 code-reviewer | 阻塞/错误类别=无 | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md + .tad/active/handoffs/LITE-20260809-1126-v240-closure-integrity.md | Next Action=独立 reviewer 只读检查并逐条重跑 AC
Phase=review | 改动文件=README.md、Epic 归档、两份本单 evidence | 最后 AC=AC5 PASS | 下一动作=对 reviewer 条件做增量独立复核 | 阻塞/错误类别=首轮 verdict CONDITIONAL（仅因 reviewer 载体尚未落盘），无 P0/P1/P2 | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md + .tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md | Next Action=确认最终 reviewer PASS 后进入 Technical Gate
Phase=review | 改动文件=两份本单 evidence | 最后 AC=AC5 PASS | 下一动作=Technical Gate | 阻塞/错误类别=无；增量 reviewer PASS，P0=0、P1=0、P2=0 | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md + .tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md | Next Action=逐项确认 Technical Gate
Phase=technical-gate | 改动文件=无新增 | 最后 AC=AC5 PASS（AC1–AC4 已有证据） | 下一动作=L4 Completion 并创建 Commit A | 阻塞/错误类别=无；AC/evidence、reviewer、quiet-point friction、scope fence、Knowledge Assessment 均满足 | repair_round=1/3 | same_error_count=1/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md + .tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md | Next Action=显式 pathspec 创建 Commit A
Phase=technical-gate | 改动文件=Commit A 七路径（已封装） | 最后 AC=AC6 PASS | 下一动作=L4 Completion，随后等待人工验收 | 阻塞/错误类别=无；Commit A blob+mode+path+subject 均通过 | repair_round=1/3 | same_error_count=1/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md + commit ac0699f | Next Action=展示 Completion，等待批准 Commit B
Phase=human-gate | 改动文件=Completion 待追加 | 最后 AC=AC6 PASS | 下一动作=等待人类验收与 Commit B 明确授权 | 阻塞/错误类别=AC7 依赖真实人工验收，尚未运行 | repair_round=1/3 | same_error_count=1/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md + .tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md + commit ac0699f | Next Action=L5 展示 Completion，停止等待

## Completion (2026-08-09)

**Commit**: `ac0699f` — Commit A created with the exact seven-path blob+mode manifest; human approval for Commit B received, Commit B pending creation.
**Model**: harness=codex | model=GPT-5 | route=unknown
- Human decision (2026-08-09): `验收通过`；`批准创建 Commit B`。
- 上下文刷新：`.tad/project-knowledge/principles.md`; `.tad/project-knowledge/patterns/_index.md`; `.tad/project-knowledge/patterns/handoff-design.md` §§ Manifest + Directory Isolation for Multi-Instance Resources, Concurrent Terminals Share the Git Index and Source Trees: Pathspec-Scope Commits; Run Global Gates at Quiet Points; `.tad/project-knowledge/patterns/ac-verification.md` § An Extracted Harness Cannot Prove Its Own Extraction Boundary; `.tad/project-knowledge/patterns/release-sync.md` § Identity Early-Exits Blind Downstream Checks; `.agents/skills/tad-maintain/SKILL.md` § Step 2e Epic Lifecycle Audit | 关键约束：不改 tad.sh 已验收内容；README 只改现行 Codex 入口；Epic 两阶段迁移；Commit A/B 显式 pathspec；禁止 push/tag/publish/sync；Commit B 等真实人工验收 | 成功条件：README 路由一致、Epic 离开 active、AC1–AC7 可追踪、Commit A/B 本地精确闭合
- 改动文件：`README.md`; 删除 `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md`; 新增 `.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md`; 新增 `.tad/evidence/acceptance-tests/v240-closure-integrity/ac-results.md`; 新增 `.tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md`; 本 handoff 的 Lite Progress/Completion（workflow artifact）；Commit A 固化的七个既有验收路径按 manifest 纳入，内容未在本单重新编辑
- AC 结果：
  - ✅ AC1 `AC1-PASS` — tad.sh md5、语法与既有测试均通过，证据：`ac-results.md`
  - ✅ AC2 `AC2-PASS` — Lite-first 当前入口锚点通过，v2.35.0 历史段 md5 未变，证据：`ac-results.md`
  - ✅ AC3 `AC3-PASS` — 两阶段 copy/cmp/delete、COMPLETE/SC2/废除历史与 `HEAD` 单行差异通过；迁移前 admission 原始输出保存在 `ac-results.md`
  - ✅ AC4 `AC4-PASS` — quiet point 已由人确认；version PASS、version-sweep Layer 1 为 12 verified / 0 warnings、Layer 2 483 advisory、parity PASS
  - ✅ AC5 `AC5-PASS` — 五项精确状态差 allowlist 命中，零 removals
  - ✅ AC6 `AC6-PASS` — Commit A `ac0699f` 的路径、blob、mode、subject 全部匹配
  - PENDING（Commit B post-commit gate）AC7 尚未运行；本次归档 handoff、创建 Commit B 后立即执行
- Reviewer: `PASS` | model=GPT-5 | harness=Codex | route=unknown | P0=0, P1=0, P2=0；初轮 `CONDITIONAL` 仅因 reviewer artifact 尚未落盘，增量复核已实证关闭该条件并确认 AC5 PASS。关键发现：**执行实证** README/Epic/AC5 scope 均符合；**阅读推断** 未触及安全敏感可执行、权限、依赖或配置面；AC6/AC7 在 commit 前提缺失时保持 `UNVERIFIED-BY-EXECUTION`，未伪造 PASS。证据：`.tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md`
- Technical Gate: `GATE PASS`（AC/evidence 完整至 AC6；reviewer 最终 PASS；AC4 quiet-point friction 已解决；scope fence 通过；无新增 caller/consumer 风险；Knowledge Assessment 已标记）
- Knowledge Assessment: `none`（未修改 project knowledge；Commit A 冻结 journal）
- 意外发现：AC6 是 Bash fenced command；在 zsh 中其循环变量 `path` 会覆盖特殊 PATH 数组，导致 `git/awk/diff not found`。改用 `/bin/bash` 重跑原命令后 `AC6-PASS`。这次是执行环境摩擦，不改变实现范围。
- follow-up：
  - AC7：已取得真实人工验收与“批准创建 Commit B”明确授权；待 Commit B 后执行；owner=本单执行流程
  - AC 命令的 shell portability：建议后续 Alex-Lite 将执行 principal 显式写为 Bash，避免 zsh `path` 特殊变量；本单不改契约、不改冻结 journal，非本单实现阻塞

## Reflexion

- 失败：AC3 copy 前 `cmp` 发现源文件比契约的 `HEAD - 删除单行` 少一个空行 / 假设：删除废弃句时可连同相邻空行一并清理 / 动作：恢复契约要求的空行，重新 `cmp` 后再 copy、cmp、删除 / 结果：`AC3-COPY-CMP-DELETE-PASS`，repair_round=1/3
