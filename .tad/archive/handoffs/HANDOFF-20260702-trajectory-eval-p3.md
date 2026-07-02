---
# Quality Chain Metadata (Alex 必填)
task_type: mixed      # 协议文件编辑 + bash 脚本 + 实跑验证
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/eval"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-02
**Project:** TAD
**Task ID:** TASK-20260702-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260701-trajectory-eval-harness.md (Phase 3/3 — 最终阶段)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-02

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review (min 2) | ✅ | code-reviewer + data-analyst，evidence: `.tad/evidence/reviews/alex/trajectory-eval-p3/` |
| All P0 resolved | ✅ | 3 P0（CR 1 + DA 2）+ 6 P1 全部 Resolved + 1 项 Alex 自查（HEAD 基线漂移），见 §9.2 |
| Architecture Complete | ✅ | §4.1 流程链 + step4d-run.sh prepare/finalize 契约 |
| Components Specified | ✅ | §4.2 A/B/C + 五节 ROI 口径原地定义 |
| Functions Verified | ✅ | 全部 AC raw form dry-run；AC3/AC9 基线钉死 3a9c82e 并 LIVE 实跑 |
| Data Flow Mapped | ✅ | traces/reviews/archive（读）→ evidence（写）单向 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)
- [ ] 阅读了所有章节（⚠️ 特别是 §10.1 的三条冻结禁令）
- [ ] 阅读了「📚 Project Knowledge」历史教训
- [ ] 理解 judge 步骤是 **advisory**（不阻塞验收）且默认自动跑
- [ ] 确认可以独立完成

---

## 1. Task Overview

### 1.1 What We're Building
Epic 最终阶段：(a) 在 Alex 的 acceptance-protocol 中新增 **step4d_trajectory_judge**——每次 *accept 默认自动 spawn 已校准 judge 评当前轨迹，产出独立 evidence 文件（advisory，`--no-judge` 可跳过，失败静默降级）；(b) `gate-roi-report.sh`——30 天窗口的 Gate ROI 汇总（gates 跑了多少、P0/P1 拦下多少、漏出多少、judge 分趋势）；(c) assemble-bundle.sh 增加 active-first 路径解析（验收时轨迹还没归档）。

### 1.2 Why We're Building It
judge 已校准（within-1 94.1%）但还是"实验室仪器"。接入验收流程后：每次验收自动积累独立质量评分；ROI 报告把"Gate 到底值不值"从轶事变成数据——这份报告是"机械 enforcement 定位决断"的数据地基（2026-06-09 研究判定的 gate-ROI unproven 缺口就此闭合）。

### 1.3 🆕 Intent Statement

**真正要解决的问题**：让测量自动发生（不依赖记得手动跑——traces 无人消费的前车之鉴），同时绝不让 judge 分数变成新的阻塞点或被优化的目标。

**不是要做的**：
- ❌ judge 分不阻塞任何验收（advisory only——阻塞与否是未来"机械 enforcement 决断"的事，不在本 Epic）
- ❌ 不修改 judge-prompt.md / rubric.md / golden set（校准后冻结——改动 = 校准失效）
- ❌ 不做跨项目部署、不做 Blake 侧 Gate 3 集成
- ❌ 不重写 acceptance-protocol 现有步骤（additive sibling only）

**Blake请确认理解**：
```
1. 为什么 judge 步骤必须是 advisory？
2. 为什么 assemble-bundle.sh 只能改路径解析、不能改 bundle 内容格式？
3. ROI 报告里"escape"的定义是什么？
```

---

## 📚 Project Knowledge（Blake 必读）

**MANDATORY READ**: `principles.md` + `patterns/gate-design.md` + `patterns/ac-verification.md` + `patterns/shell-portability.md`

**⚠️ 必须注意的历史教训**：
1. **Rewiring a Gate's prose can trip SAFETY counts — line-set diff + re-cite** (principles.md 2026-05-31)——本任务直接编辑 acceptance-protocol.md：只允许 additive sibling 新增 step4d，不改写既有行；AC 用双向 line-set diff 验证
2. **判断 vs 机械：constraint rules 不可删** (principles.md AMENDED 2026-04-04)——新 step 的 advisory 定性必须显式写 `blocking: false`
3. **Observational > imperative emission** (memory-and-learning 2026-05-30)——judge 自动触发正是为了避免"记得手动跑"的 1/328 命中率宿命
4. **Pre-declared exclusion must be restated inline** (ac-verification 2026-07-02，上一 Phase 教训)——ROI 报告每个指标的口径在 §4.4 原地定义，不引用继承
5. **BSD/macOS shell 兼容** (shell-portability)——date 用 `-v-30d`（已验证可用）；grep/awk BSD 语义
6. **A false gate trains the operator to ignore it** (ac-verification 2026-06-14)——降级路径必须真的静默（exit 0 + 一行 skip 日志），不能每次验收刷报错

---

## 2. Background Context

### 2.1 Previous Work
- Phase 2 交付（全部冻结）：`judge-prompt.md`（含 D2 Evidence Scope Rule）、`assemble-bundle.sh`、校准报告（verdict: PASS）
- 集成点：`.claude/skills/alex/references/acceptance-protocol.md`（当前 SAFETY 标记 `BLOCKING|MANDATORY|VIOLATION` = **5**，Alex 2026-07-02 实测基线；与 `.agents` 镜像 byte-identical，diff -q 已验证）
- ROI 数据源现状（Alex 实测）：traces gate_result 事件 50 条（6-7 月）；archive 中 bugfix/fix 前缀 handoff 6 个；近期非空 gate4_delta 7 个；reviews/blake/ 目录逐 slug 齐全
- `date -v-30d` 在本机可用（BSD）✓

### 2.2 Current State
acceptance-protocol.md 步骤链：step4c (Layer 2 audit) → step4e_feedback → step4f_distillation → step5/6/7…。新 step4d 插入 step4c 与 step4e 之间（编号空位恰好存在）。

### 2.3 Dependencies
无新依赖。judge 调用 = Agent tool spawn（Alex 验收会话内），与 Phase 2 校准方式一致。

---

## 3. Requirements

- FR1: acceptance-protocol.md 新增 `step4d_trajectory_judge`（additive sibling，规格见 §4.2A）；`.agents` 镜像同步 byte-identical
- FR2: assemble-bundle.sh 路径解析改为 **active-first**：`ls active/handoffs/HANDOFF-*-{slug}.md` 命中则用之（completion 同理），否则回落 archive——bundle 内容格式零改动
- FR3: `gate-roi-report.sh`（规格见 §4.2C）——对历史数据可直接运行，不依赖新 judge 数据存在
- FR4: 实跑验证：对 1 条已归档轨迹执行完整 step4d 流程产出合法 trajectory-judge.json；ROI 报告对 30 天窗口跑通
- NFR1: judge 步骤全路径 advisory——judge 目录缺失/spawn 失败/JSON 非法 → 记 1 行 skip，*accept 正常继续
- NFR2: anti-Goodhart 维持（协议文本只引用 judge 目录路径，不引用/不内嵌 rubric 内容；`grep 'eval/rubric'` 基线 0 不变）

---

## 4. Technical Design

### 4.1 Architecture
```
*accept → step4c (layer2 audit)
        → step4d_trajectory_judge (NEW, blocking: false)
            1. skip 检查：用户 --no-judge？judge-prompt.md 存在？ → 否则 skip
            2. bash assemble-bundle.sh {slug}   (active-first 解析)
            3. spawn fresh Sonnet judge subagent (paths-only: judge-prompt + bundle)
            4. 写 .tad/evidence/acceptance-tests/{slug}/trajectory-judge.json
            5. 验收报告追加 1 行分数摘要（advisory 标注）
        → step4e_feedback → …
gate-roi-report.sh [--days N]  →  .tad/evidence/eval/gate-roi-{date}.md
```

### 4.2 Component Specifications

**A. step4d_trajectory_judge（协议 YAML 块，additive sibling）+ step4d-run.sh 包装脚本**

机械部分抽成脚本 `.tad/eval/judge/step4d-run.sh`（CR P1：协议 prose 不可测，脚本可测；spawn 本身留在协议——bash 不能 spawn subagent）：
- `step4d-run.sh prepare {slug}`：skip 三查（`TAD_NO_JUDGE=1` 环境变量 / judge-prompt.md 不存在 / assembler 失败）→ 任一命中输出 1 行 `judge: skipped ({reason})` **exit 0**；否则调 assemble-bundle.sh（active-first）输出 bundle 路径
- `step4d-run.sh finalize {slug} {json-path}`：P2 的 `all()` jq schema 校验 → 通过则落位 `.tad/evidence/acceptance-tests/{slug}/trajectory-judge.json`；校验失败 → `judge: skipped (invalid-json)` exit 0

协议块必含要素（AC1 在 step4d 块内 scoped grep——`blocking: false` 全文件已有 4 处，必须限定在块内查 [CR P1]）：
- `blocking: false` + 显式 "advisory — judge 分数不影响验收结论"
- 流程：`prepare` → fresh Sonnet spawn（paths-only：judge-prompt 路径 + bundle 路径；禁止提供 golden/往轮结果/本次验收结论）→ `finalize` → 验收报告 1 行摘要
- 冻结引用："judge-prompt.md 为校准冻结产物，本步骤禁止修改（改动 = 校准失效）"

**B. assemble-bundle.sh 修改（最小 diff）**
仅改 HF/CF 查找两行：active-first → archive fallback。**bundle 内容生成逻辑一字不动**（格式变化会使校准失真）。回归验证：对 sep-phase2（archive 轨迹）重新生成 bundle，与现有 `bundles/sep-phase2.md` byte-diff 为空。

**C. gate-roi-report.sh（指标口径原地定义 — ac-verification 2026-07-02 教训）**
输入：`--days N`（默认 30；BSD `date -v-${N}d`）。输出 markdown 到 `.tad/evidence/eval/gate-roi-{date}.md` 并 stdout。**五节**，每节口径如下：
1. **Gates run**：窗口内 traces `"type":"gate_result"` 事件数（按事件 `ts` 字段日期过滤），按 gate/verdict 分组
2. **Caught pre-ship**：(a) review 文件 finding-level 计数——`grep -oE 'P[01]-[0-9]+'` 去重（编号规范 P0-1/P1-2 是既有惯例）；无编号的文件回落 per-file-per-level 计数并单列；窗口归属 = review 文件按 slug 关联到带日期的 handoff 文件名 [CR P1]；(b) **Gate 4 晚期拦截**：窗口内 archived handoff 非空 gate4_delta 条目数（[DA P0-1]：gate4_delta 是 Gate 4 的**拦截**成果，不是漏出——原设计归入 escape 属语义倒置，会使 enforcement 决策高估漏出率）。本节必须含脚注 "structural lower bound"（无编号 review 的计数压缩 [DA P1-1]）
3. **Escaped post-ship**：窗口内新建 `bugfix-*`/`fix-*` 前缀 handoff 数（前驱轨迹 = escape）。**必须输出分母与率**：窗口内 accepted handoffs 总数（archive 中按文件名日期计 HANDOFF-*）、escape rate = 分子/分母/百分比三者全部打印 [DA P0-2]。**必须含 "lower bound" 免责声明**（静默修复不可见 [DA P1-2]）
4. **Judge score trend**：n<10 → 输出逐轨迹原始行（防虚假精度 [DA P1-3]）；n≥10 → 切换逐维均分表；n<3 → "insufficient data (n={N}) — accumulating"
5. **按 Gate 分层拦截归因** [DA P2-1]：gate_result 事件按 gate 编号 × verdict 交叉表——enforcement 决策真正需要的"哪道门拦最多"
（§9.2 Audit Trail 行数从第 2 节移除——衡量协议活动量不衡量发现数，代理无效 [DA P2-2]）
每节末尾附"复算命令"一行（Gate 4 一键 re-derive）。
硬约束：只读脚本（除自身报告外零副作用）；BSD-safe（**用 `find` 不用 `**` globstar** [CR P1]）；数据源缺失 → 该节 N/A 不崩溃。

### 4.3 Data Models
trajectory-judge.json：沿用 Phase 2 schema。ROI 报告：markdown + 每节复算命令行。

### 4.4 度量口径
已在 4.2C 各节原地定义（不引用继承）。gate4_delta 归入"Caught pre-ship（Gate 4 晚期拦截）"而非 escape——它是 Gate 4 抓到的差距，归 escape 属语义倒置（DA P0-1）。escape 只计 bugfix 前驱（行为性证据），且必须带分母/率 + lower-bound 免责声明。

### 4.5 UI / API
N/A

---

## 5. 🆕 强制问题回答

### MQ1: 历史代码搜索
[x] 是——step4c/step4e 的 additive-sibling 先例（本文件正是这样插入的）；assemble-bundle/judge-prompt 为 Phase 2 交付直接复用；ROI 数据源实测见 §2.1。

### MQ2: 函数存在性
`layer2-audit.sh` 同目录先例确认 `.tad/hooks/lib/` 与 `.tad/eval/judge/` 的脚本调用模式；jq/date -v 已验证。

### MQ3/4/5: 单向数据流（traces/reviews/archive 读 → evidence 写）；无 UI；无状态同步。

---

## 6. Implementation Steps

## 6.1 Micro-Tasks

| # | File | Operation | Verification | Est. |
|---|------|-----------|--------------|------|
| 1 | assemble-bundle.sh | active-first 查找（最小 diff） | AC4 sep-phase2 回归 byte-diff 空 + AC11 active 路径实跑 | 15m |
| 2 | step4d-run.sh | prepare/finalize 两子命令（4.2A 契约） | AC7 降级 + AC11 active | 30m |
| 3 | acceptance-protocol.md (.claude) | 新增 step4d 块 | AC1 scoped greps + AC3 line-set | 30m |
| 4 | acceptance-protocol.md (.agents) | byte 同步 | `diff -q` 空 | 5m |
| 5 | gate-roi-report.sh | 按 4.2C **五节**实现 | AC5 实跑（率 + lower bound + 五节） | 75m |
| 6 | 实跑 E2E | 对 trajectory-eval-p2（archived）跑 prepare→spawn→finalize 全流程 | AC6 json 合法 | 20m |
| 7 | 降级测试 | 移开 judge-prompt.md → `prepare` exit 0 + skip 行 → 恢复（test -f 确认） | AC7 | 10m |

### 判断点
micro-1 回归 diff 非空 → 停，回 Alex（格式漂移 = 校准失真风险，不许"看起来差不多"）。

## 6.7 AC Dry-Run Log
**AC Dry-Run Log** (Alex step1d at 2026-07-02):
- AC3 基线 (pre-impl): `grep -cE 'BLOCKING|MANDATORY|VIOLATION' .claude/skills/alex/references/acceptance-protocol.md` → **5**（实测）；AC3 要求 post ≥5 且 line-set forward-missing = 0
- AC2 基线 (pre-impl): `diff -q` 两镜像 → identical（实测）
- AC8 基线 (pre-impl): `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills | wc -l` → **0**（实测）
- `date -v-30d` → 2026-06-02（BSD 可用，实测）
- ROI 数据源体量 (pre-impl 实测): gate_result 50 条 / bugfix 前缀 6 / 非空 gate4_delta 7 —— AC5 的"非空输出"可满足
- AC1/AC4-AC7/AC9-AC10 (post-impl): raw form `bash -n` 语法验证通过；不 mock
- AC3 时序漏洞自查修正 (2026-07-02): `git show HEAD:` 会随 Blake 提交移动 → 基线钉死为 commit `3a9c82e`；钉死后命令对当前未修改文件 LIVE 实跑 = 0 ✓
- AC9 LIVE 实跑（当前状态）= 0 ✓（基线已钉死 `git diff 3a9c82e`）
- 专家审查后第二轮 (2026-07-02)：修订版 AC1/AC5/AC7/AC11 raw form `bash -n` 通过；AC1 awk 端模式与起始模式不互斥实测 ✓；advisory linter 1 WARN（AC3 表格转义，raw form 已实跑 0）+ 1 INFO（'judge: skipped' sentinel——AC7 断言输出存在而非文件零出现，self-leak 反转不适用）

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/eval/judge/step4d-run.sh                  (prepare/finalize 包装脚本 — CR P0/P1 fix)
.tad/eval/judge/gate-roi-report.sh
.tad/evidence/eval/gate-roi-{date}.md          (AC5 实跑产物)
.tad/evidence/acceptance-tests/trajectory-eval-p2/trajectory-judge.json  (AC6 E2E 产物)
.tad/evidence/designs/trajectory-eval-p3-git-baseline.txt (开工第一步快照)
.tad/evidence/reviews/blake/trajectory-eval-p3/*.md (Layer 2)
```

### 7.2 Files to Modify
```
.tad/eval/judge/assemble-bundle.sh                       # 仅路径解析两处
.claude/skills/alex/references/acceptance-protocol.md    # additive step4d
.agents/skills/alex/references/acceptance-protocol.md    # byte 镜像
```

### 7.3 Grounded Against (Alex step1c)
- .claude/skills/alex/references/acceptance-protocol.md (full 363 lines, read 2026-07-02 本 session) — step4c→step4e 链确认，step4d 编号空位确认
- .tad/eval/judge/assemble-bundle.sh (head 40, read 2026-07-02) — HF/CF 查找逻辑在 L17-L21，确认最小 diff 可行
- .tad/evidence/traces/*.jsonl (schema 已确认) + reviews/ + archive/ (ls 实测见 §2.1)
- .tad/eval/judge/gate-roi-report.sh (new — will be created)

---

## 8. Testing Requirements

### 8.1-8.3
核心测试即 micro-5（真实 E2E）+ micro-6（降级）+ micro-1（回归 byte-diff）。边界：ROI 窗口内某数据源为空 → 该节 N/A（AC5 对 `--days 1` 额外跑一次验证空窗口不崩溃）。

## 8.4 Friction Preflight
无新依赖/auth/网络。唯一摩擦：E2E 的 1 次 Sonnet spawn 撞配额 → 稍后重跑（结果落盘）。

## 8.5 Feedback Collection
N/A

## 8.6 Test Evidence Required
- [ ] sep-phase2 回归 byte-diff 输出（空）
- [ ] E2E trajectory-judge.json + 降级测试日志

---

## 9. Acceptance Criteria
- [ ] FR1-FR4 + NFR1-NFR2 全部有证据；§9.1 全行 PASS

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | step4d 要素齐全（**块内 scoped**） | post-impl | `awk '/^  step4d_trajectory_judge:/,/^  step4e/' .claude/skills/alex/references/acceptance-protocol.md > /tmp/s4d.txt; wc -l < /tmp/s4d.txt; for p in 'blocking: false' 'no-judge' 'judge: skipped' 'paths-only' '校准冻结' 'step4d-run.sh'; do grep -c "$p" /tmp/s4d.txt; done` | 块 ≥20 行 + 6 个 marker 在**块内**各 ≥1（全文件 grep 对 `blocking: false` 是 vacuous——已有 4 处 [CR P1 fix]） | (post-impl; syntax-validated；awk 端模式 `^  step4e` 与起始模式不互斥——已核对 awk-range 教训) |
| AC2 | 双平台 byte 镜像 | post-impl | `diff -q .claude/skills/alex/references/acceptance-protocol.md .agents/skills/alex/references/acceptance-protocol.md && echo SAME` | `SAME` | (post-impl; syntax-validated) |
| AC3 | SAFETY line-set：只增不改删 | post-impl | `comm -23 <(git show 3a9c82e:.claude/skills/alex/references/acceptance-protocol.md \| grep -vE '^\s*$' \| sort) <(grep -vE '^\s*$' .claude/skills/alex/references/acceptance-protocol.md \| sort) \| wc -l`；且 `grep -cE 'BLOCKING\|MANDATORY\|VIOLATION' <file>` ≥5 | forward-missing `0`（零行被删改）+ 标记数 ≥5（基线 5） | (post-impl — 基线 commit 钉死为 **3a9c82e**：`git show HEAD:` 在 Blake 提交后 HEAD 移动 → 对比已改版本 → 永假 PASS，step1d 自查发现并修正；基线标记数 5 已实测) |
| AC4 | assembler 回归零漂移 | post-impl | `cp .tad/eval/judge/bundles/sep-phase2.md /tmp/b-ref.md && bash .tad/eval/judge/assemble-bundle.sh sep-phase2 && diff /tmp/b-ref.md .tad/eval/judge/bundles/sep-phase2.md && echo SAME` | `SAME`（byte 零漂移） | (post-impl; syntax-validated) |
| AC5 | ROI 报告实跑（五节 + 率 + lower bound） | post-impl | `bash .tad/eval/judge/gate-roi-report.sh --days 30; echo "exit=$?"; R=$(ls -t .tad/evidence/eval/gate-roi-*.md \| head -1); grep -c '^## ' "$R"; grep -cE 'escape rate.*[0-9]+ */ *[0-9]+' "$R"; grep -ci 'lower bound' "$R"; grep -c '复算命令' "$R"`；另跑 `--days 1` 验证空窗口不崩溃 | exit=0 + 节数 ≥5 + 率行（分子/分母格式）≥1 [DA P0-2] + lower bound ≥2（第 2、3 节各一 [DA P1-1/2]）+ 复算命令 ≥5 | (post-impl; syntax-validated) |
| AC6 | E2E：真实轨迹 judge 评估落盘 | post-impl | `jq -e '[.D1,.D2,.D3,.D4,.D5] \| all(type=="object" and ((.score\|type=="number" and .>=1 and .<=5) or .score=="UNRECOVERABLE") and (.rationale\|type=="string" and length>0))' .tad/evidence/acceptance-tests/trajectory-eval-p2/trajectory-judge.json && echo VALID` | `VALID`（P2 fixture 双测过的 jq；经 prepare→spawn→finalize 全流程产出） | (post-impl; jq 已于 P2 fixture 双测) |
| AC7 | 降级路径真·静默（脚本可测 [CR P1 fix]） | post-impl | `mv .tad/eval/judge/judge-prompt.md /tmp/jp.bak; bash .tad/eval/judge/step4d-run.sh prepare sep-phase2; echo "exit=$?"; mv /tmp/jp.bak .tad/eval/judge/judge-prompt.md; test -f .tad/eval/judge/judge-prompt.md && echo RESTORED` | 输出含 `judge: skipped` + `exit=0` + `RESTORED` | (post-impl; syntax-validated) |
| AC8 | anti-Goodhart 基线不变 | pre+post | `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills 2>/dev/null \| wc -l` | `0` | `0`（pre-impl 实测 2026-07-02） |
| AC9 | judge 冻结物零改动 | post-impl | `git diff 3a9c82e --stat -- .tad/eval/judge/judge-prompt.md .tad/eval/rubric.md .tad/eval/golden-set/ \| wc -l` | `0`（三类冻结物无 diff；基线钉死 3a9c82e，与 AC3 同因） | (post-impl; LIVE 实跑当前 = 0) |
| AC10 | 变更范围（基线 diff，预置并发豁免） | post-impl | 快照 + `comm -13` + 允许清单（.tad/eval/、evidence/eval、evidence/acceptance-tests/trajectory-eval-p2/、acceptance-protocol 两镜像、trajectory-eval-p3、.tad/active/、traces/decisions/reviews/research、.mcp.json、ldr-poc、COMPLETION-20260702-trajectory-eval-p3） | `0` | (post-impl; syntax-validated) |
| AC11 | **Active-first 路径实测**（FR2 的存在目的 [CR P0 fix]） | post-impl | `bash .tad/eval/judge/step4d-run.sh prepare trajectory-eval-p3 && test $(wc -l < .tad/eval/judge/bundles/trajectory-eval-p3.md) -ge 100 && echo ACTIVE_OK` | `ACTIVE_OK`（trajectory-eval-p3 此刻在 active/——AC4 只测 archive 回落路径，若无此 AC，坏掉的 active 解析 + 全路径静默降级 = 永久无声 no-op） | (post-impl; syntax-validated) |

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: active-first 路径（FR2 的存在目的）零 AC 覆盖——AC4/AC6 全走 archive 回落；叠加全路径静默降级 = 坏掉也永久无声 no-op | AC11 新增（active slug 实测）+ §6 micro-1/2 | Resolved |
| code-reviewer | P1: step4d 是协议 prose 不可测（AC7 无 exit code 可断言） | §4.2A（抽出 step4d-run.sh prepare/finalize）+ AC7 重写为脚本测试 | Resolved |
| code-reviewer | P1: AC1 `blocking: false` 全文件 grep vacuous（已有 4 处） | AC1 改 awk 块内 scoped grep（端模式与起始模式不互斥已核对） | Resolved |
| code-reviewer | P1: reviews 路径无日期 → 窗口过滤未定义；`**` globstar BSD 不可用 | §4.2C 第 2 节（slug 关联到带日期 handoff 文件名；强制 find） | Resolved |
| code-reviewer | P2: AC3 对纯重排不敏感；trace 窗口方法未指明；active bundle 代表性 | 接受（additive-only 下重排不构成风险，已注明）；§4.2C 第 1 节（按 ts 字段过滤）；§10.2 注明 | Resolved |
| data-analyst | P0-1: gate4_delta 归入 escape 属语义倒置——会使 enforcement 决策高估漏出率 | §4.2C 第 2 节（移为"Gate 4 晚期拦截"）+ §4.4 更新 | Resolved |
| data-analyst | P0-2: 无分母/率——原始计数对战略决策不可解读 | §4.2C 第 3 节（分子/分母/百分比强制）+ AC5 率行 grep | Resolved |
| data-analyst | P1-1: per-file-per-level 去重压缩发现数、方向性低估 gate 价值 | §4.2C 第 2 节（finding-level `P[01]-[0-9]+` 去重 + 无编号回落单列 + lower bound 脚注） | Resolved |
| data-analyst | P1-2: 静默修复不可见 → escape 是下界 | §4.2C 第 3 节 + AC5（"lower bound" 免责声明强制） | Resolved |
| data-analyst | P1-3: n=3-10 逐维均值是虚假精度 | §4.2C 第 4 节（n<10 逐轨迹行，n≥10 均值表） | Resolved |
| data-analyst | P2-1: enforcement 决策需要"哪道门拦最多" | §4.2C 新增第 5 节（gate × verdict 交叉表） | Resolved |
| data-analyst | P2-2: §9.2 Audit Trail 行数是无效代理 | §4.2C 第 2 节已移除该项 | Resolved |
| (Alex step1d 自查) | AC3/AC9 `git show HEAD:` 随 Blake 提交移动 → 永假 PASS | AC3/AC9 基线钉死 commit 3a9c82e | Resolved |

### Experts Selected
1. **code-reviewer** — 协议文件 SAFETY line-set 纪律 + additive sibling 正确性 + shell 脚本边界（本任务最大风险面是改 Alex 自己的验收协议）
2. **data-analyst** — ROI 四节指标口径（escape 双口径、去重规则、空窗口行为）的测量有效性

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 1 P0 + 3 P1 + 3 P2 全部 Resolved
- data-analyst: CONDITIONAL PASS → 2 P0 + 3 P1 + 2 P2 全部 Resolved
- Review evidence: `.tad/evidence/reviews/alex/trajectory-eval-p3/{code-reviewer,data-analyst}.md`

---

## 10. Important Notes

### 10.1 Critical Warnings（三条冻结禁令）
- ⚠️ **judge-prompt.md / rubric.md / golden-set/ 一字不改**（AC9 会抓）——改动 = 校准失效
- ⚠️ **acceptance-protocol 既有行零删改**（AC3 line-set 会抓）——additive sibling only
- ⚠️ **bundle 内容格式零漂移**（AC4 byte-diff 会抓）——只许改路径解析

### 10.2 Known Constraints
- judge 分 advisory 的定性在本 Epic 内不可升级为 blocking（那是机械 enforcement 决断的事）
- ROI 报告引用判别力时注明"对比对余量 0.25"（Epic carry-forward #1）
- Token 计量 DEGRADED 常态：judge 调用成本记 wall-clock

### 10.3 Sub-Agent 使用建议
E2E 的 judge spawn（micro-5）= 1 次 fresh Sonnet subagent，契约同 Phase 2。

---

## 11. 🆕 Learning Content

### 11.1 Decision Rationale: 默认自动跑 vs 按需
| 方案 | 优点 | 缺点 | 为什么 |
|------|------|------|--------|
| 默认自动 + --no-judge（选中，用户决策） | 数据自动积累；不依赖记忆 | 每次验收 +1 次 Sonnet 调用 | ✅ traces 无人消费的教训：imperative 机制命中率 1/328 |
| 按需手动 | 省成本 | ROI 数据稀疏化 → 报告失去价值 | 违背本 Phase 的存在理由 |

---

## 12. 🆕 Sub-Agent使用记录
(Blake完成后填写)

---

## Required Evidence Manifest

```yaml
required_evidence:
  completion: ".tad/active/handoffs/COMPLETION-20260702-trajectory-eval-p3.md"
  roi_script: ".tad/eval/judge/gate-roi-report.sh"
  roi_report_sample: ".tad/evidence/eval/gate-roi-*.md"
  e2e_judge_json: ".tad/evidence/acceptance-tests/trajectory-eval-p2/trajectory-judge.json"
  regression_diff: "sep-phase2 bundle byte-diff 输出（completion 内粘贴）"
  degradation_log: "micro-6 降级测试日志（completion 内粘贴）"
  git_baseline: ".tad/evidence/designs/trajectory-eval-p3-git-baseline.txt"
  blake_layer2_reviews: ".tad/evidence/reviews/blake/trajectory-eval-p3/*.md (>=2 distinct)"
  knowledge_updates: "journal in completion OR explicit no-discovery"
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-02
**Version**: 3.1.0
