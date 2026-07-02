---
# Quality Chain Metadata (Alex 必填)
task_type: mixed      # bash 脚本 + judge prompt 协议 + 校准运行
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/eval"]
skip_knowledge_assessment: no
gate4_delta:
  - field: "§4.4 对比对均分口径"
    alex_said: "均分口径'与配对规则一致'已足够明确"
    actual: "D4 排除只在 GATE within-1 定义中显式声明，对比对定义靠引用继承 → 产生 1.75 PASS vs 1.40 FAIL 的口径歧义；Blake 依 Phase 1 预声明选 D4-excluded，Gate 4 验证两轮口径一致（round1 两种口径都 FAIL）后裁决接受"
    caught_by: "Blake 主动上报 P1 + Alex 双口径重算"
  - field: "AC5 对比对余量"
    alex_said: "对比对 >=1.5 是稳健的判别门"
    actual: "实测 1.75，余量仅 0.25，而稳定性探针显示单维 Δ可达 1 — 判别门通过但属薄余量，Phase 3 的 ROI 结论引用判别力时须注明"
    caught_by: "Alex raw recompute + stability probe 交叉"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-02
**Project:** TAD
**Task ID:** TASK-20260702-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260701-trajectory-eval-harness.md (Phase 2/3)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-02

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review (min 2) | ✅ | code-reviewer + data-analyst，evidence: `.tad/evidence/reviews/alex/trajectory-eval-p2/` |
| All P0 resolved | ✅ | 4 P0（CR 2 + DA 2）+ 5 P1 全部 Resolved，见 §9.2 Audit Trail |
| Architecture Complete | ✅ | §4.1 judge 目录结构 + 运行协议 |
| Components Specified | ✅ | §4.2 A/B/C 规格 + §4.4 度量契约（含有效性前置） |
| Functions Verified | ✅ | 系统工具 only；全部 AC raw form dry-run/fixture 双测 |
| Data Flow Mapped | ✅ | archive→bundles→judge results→report 单向（MQ5） |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)
- [ ] 阅读了所有章节（含 §4.4 度量计算规范——这是本 Phase 的核心契约）
- [ ] 阅读了「📚 Project Knowledge」历史教训
- [ ] 理解 kill switch：round 上限内 within-1 <80% → 写 pivot report，Phase 3 保持 blocked
- [ ] 确认可以独立完成

---

## 1. Task Overview

### 1.1 What We're Building
Judge Harness Spike：(a) judge prompt 模板 + trajectory bundle 组装脚本 + 运行协议；(b) 对 12 条 golden set 轨迹跑校准（judge = Sonnet subagent，盲评），计算一致性/对比对判别/成本延迟；(c) 校准报告 + 机器可读 verdict（PASS → Phase 3 解锁 / PIVOT → Epic 止损）。

### 1.2 Why We're Building It
Phase 1 造好了尺子（rubric）和标准样本（golden set，标签已确认冻结）。本 Phase 回答唯一问题：**一个 LLM judge 拿这把尺子量出的分，跟已确认的标准分够不够一致？** 不一致就止损，不带着歪尺子进 Phase 3。

### 1.3 🆕 Intent Statement

**真正要解决的问题**：用可复算的一致性数字（within-1 ≥80%）决定"judge 可信/不可信"，替代感觉判断。

**不是要做的**：
- ❌ 不做 Gate 4 / ROI 集成（Phase 3，且 GATED on 本 Phase PASS）
- ❌ 不动 golden 分数（冻结——rubric 只允许**措辞澄清**，与 judge prompt 迭代共享轮次上限）
- ❌ 不用 Haiku（用户决定：Sonnet-class，质量优先）
- ❌ judge 不是脚本调 API——是 **fresh Sonnet subagent**（与 Phase 1 盲评同机制，零配置）

**Blake请确认理解**：
```
1. 为什么 judge 必须对 golden 标签盲评？
2. 为什么 rubric 分数冻结但措辞可澄清？
3. within-1 <80% 时你的动作是什么（做什么、不做什么）？
```

---

## 📚 Project Knowledge（Blake 必读）

**MANDATORY READ**: `.tad/project-knowledge/principles.md` + `patterns/gate-design.md` + `patterns/ac-verification.md`

**⚠️ 必须注意的历史教训**：
1. **judge ≠ producer：fresh spawn + paths-only**（gate-design 2026-05-31/06-06）——每次 judge 评估 = 一个全新 subagent，prompt 只给路径，绝不给前一轮分数或任何人的 reasoning；轮间不复用 judge
2. **评 rigor 不评结论 + order-of-emission**（gate-design 2026-06-06）——judge 必须先写 per-dim rationale 再给分；prompt 含 swap test
3. **A gate is only credible if it can FAIL**（gate-design 2026-05-31）——pivot 路径是本 Phase 的合法出口，不是失败；不许为凑 80% 而放宽度量口径
4. **AC 命令必须在真实 artifact 上 dry-run**（ac-verification 2026-04-25 ×4 复发）——§4.4 的计算公式 Blake 实现后必须先在 round1 真实数据上手工核对 ≥3 个样本点
5. **Human-in-the-loop 步骤要区分决策 vs 判断数据**（gate-design 2026-07-02，上一 Phase 的教训）——本 Phase 无人工评分环节；人类只在 Gate 4 做验收决策

---

## 2. Background Context

### 2.1 Previous Work（Phase 1 产出，全部已 Gate 4 确认）
- `.tad/eval/rubric.md` — 5 维 × 5 锚点（D2 含首次提交口径澄清）
- `.tad/eval/golden-set/` — 12 条轨迹，43 个数值维度分 + UNRECOVERABLE 标记；INDEX human_confirmed: true
- Golden 统计（Alex 2026-07-02 实算，AC 设计依据）：
  - 池化数值分：known-good n=18 mean=2.94 / known-bad n=20 mean=3.30 / mixed n=5 mean=3.60 —— **类均值倒挂，类间分差不可用作判别指标**
  - 对比对：GS-11 mean 5.00 vs GS-03 mean 2.80（golden 自身差 2.2）
  - GS-06（silent-bad）mean 4.20 —— 反锚定检验基准
  - D4 数值 n=7 <8 → data-poor（advisory，不进 gate 指标）

### 2.2 Current State
`.tad/eval/judge/` 不存在（本 Phase 创建）。Bundle 重建配方在 `.tad/evidence/designs/trajectory-data-audit.md`（Phase 1 审计报告）。

### 2.3 Dependencies
jq（已装）。Agent tool（Blake 会话内可用）。无 API key、无网络、无新安装。

---

## 3. Requirements

- FR1: Judge prompt 模板——输入 = rubric 路径 + bundle 路径；输出 = 严格 JSON（D1-D5 各为 1-5 整数或 "UNRECOVERABLE"，+ per-dim rationale）
- FR2: Bundle 组装脚本——slug → 摘录式 bundle 文件（控制 token，见 §4.2B），**排除一切 golden 标签路径**
- FR3: 校准运行——每轮 12 条轨迹 × 1 次 fresh Sonnet subagent 评估；最多 3 轮（baseline + 2 次迭代）
- FR4: 校准报告——§4.4 全部指标 + 迭代日志 + 机器可读 `calibration_verdict: PASS|PIVOT`
- NFR1: 单次评估 subagent_tokens ≤ 80K 且 wall ≤5min（Sonnet；从 Agent tool usage 输出记录）
- NFR2: Anti-Goodhart 维持（rubric 零引用于执行 context）

---

## 4. Technical Design

### 4.1 Architecture
```
.tad/eval/judge/
├── judge-prompt.md          ← judge subagent 指令模板（含盲评禁令 + order-of-emission + swap test）
├── assemble-bundle.sh       ← slug → bundles/{slug}.md（摘录式，排除 golden）
├── README.md                ← 运行协议（怎么 spawn、怎么记录 usage）
├── bundles/{slug}.md        ← 12 个 bundle
└── results/round{N}/{slug}.json ← 每轮 12 个结果
.tad/evidence/eval/calibration-report-{date}.md ← 校准报告（+ pivot-report.md 如触发）
```

### 4.2 Component Specifications

**A. judge-prompt.md 必含要素**（AC1 逐项 grep；以下 5 个英文标记词必须以英文原样出现在文件中，即使正文用中文——AC1 的 grep 依赖它们：`golden-set`, `rationale`, `swap`, `UNRECOVERABLE`, `"score"`）：
1. 盲评禁令：禁止读取 `.tad/eval/golden-set/`、`.tad/evidence/eval/`、两个 trajectory-eval handoff/completion
2. Order-of-emission：每维先写 rationale（引用 bundle 内具体 artifact）再给分
3. Rigor-not-outcome 指令 + swap test（"若把轨迹结局反转，你的分会变吗？会 → 你在评结论"）
4. 输出 schema：`{"D1": {"score": 1-5|"UNRECOVERABLE", "rationale": "..."}, ...}` 严格 JSON，无多余文本
5. UNRECOVERABLE 规则：数据不足以评该维 → 标 UNRECOVERABLE，禁止猜分。**必须附每维一个 UNRECOVERABLE 判例**（如 D2: "bundle 中无任何 review/acceptance/trace 证据条目时"）防止 judge 滥用或不敢用 [DA P2-4]
6. D2 保守规则 [DA P1-3]：D2 按"首次提交口径"评分；bundle 中时间序列不足以区分"首次就有"vs"被打回后补"时，向下保守取分并在 rationale 中注明 temporal-ambiguity

**B. assemble-bundle.sh**：
- 输入 slug → 输出 `bundles/{slug}.md`：handoff 摘录（frontmatter + §9.1 表 + §6 头部）、completion 全文（通常 <200 行）、每个 review 文件 head 80、gate 报告 head 80、trace 事件行（按 slug grep，**按时间戳升序排列并保留 ts 字段**——D2 首次提交口径依赖时间序列 [DA P1-3]）
- 硬上限：单 bundle ≤1500 行（AC12 逐文件验证）；**逼近上限时的截断优先级**：completion 全文 > review 文件 > gate 报告 > handoff 摘录（评分证据密度排序，防止 review 被截导致对比对锚点被系统性拉低 [DA P2-3]）
- 禁令：任何 `.tad/eval/golden-set/` 路径不得进入 bundle（AC10 grep 兜底）

**C. 运行协议（README.md 固化）**：
- 每条轨迹 = 1 个 fresh Agent spawn（model: sonnet），prompt = judge-prompt.md 路径 + bundle 路径，**不含任何往轮结果**
- Blake 记录每次调用的 subagent_tokens 与 duration（Agent tool 返回值里有）到报告表格
- 轮次定义：round1 = baseline；若 gate 指标未达标 → 诊断分歧表 → 允许修改 judge prompt 和/或 rubric **措辞**（分数冻结）→ round2 全量 12 条重跑；最多到 round3。round3 仍未达标 → PIVOT

### 4.3 Data Models
Judge 结果 JSON（见 4.2A.4）。校准报告含逐轮 12×5 分数矩阵表。

### 4.4 度量计算规范（⚠️ 本 Phase 的核心契约——口径不许现场发明）

**配对规则**：一个 (trajectory, dim) 对参与计算当且仅当 golden 分和 judge 分**都是数值**（任一方 UNRECOVERABLE → pairwise 排除）。

| 指标 | 定义 | 角色 |
|------|------|------|
| **within-1 (GATE)** | 池化 D1,D2,D3,D5 配对（**排除 D4**，data-poor 预声明）：\|judge−golden\|≤1 的比例 ≥80% | **止损门** |
| within-1 per-dim | 各维单独（含 D4） | 报告 |
| Spearman | 12 条轨迹的池化均分排名相关 | 方向性参考（n=12 CI ±~0.28，不作 gate） |
| 对比对判别 | judge(GS-11 池化均分) − judge(GS-03 池化均分) ≥ 1.5 且方向正确 | **止损门**（golden 自身差 2.2） |
| 反锚定 | judge(GS-06 池化均分) ≥ 3.5（silent-bad 高流程分不被结局拖低） | **止损门** |
| 成本/延迟 | 每次评估 subagent_tokens ≤80K 且 ≤5min（12 次全记录，报 p50/max） | 门（超限 → 优化 bundle 再跑，不算迭代轮） |

**有效性前置条件（不满足则该轮结果无效，视为 harness/prompt 缺陷，修复重跑不消耗迭代轮次）**：
- **配对数下限 [DA P0-1]**：GATE within-1 的有效配对数 ≥27（36 上限的 75%）——防 judge 滥标 UNRECOVERABLE 缩小分母凑百分比
- **轨迹均分最小维度数 [DA P0-2]**：GS-11/GS-03/GS-06 各自的 judge 数值维度 ≥3，否则对比对/反锚定门的均值无效
- **均分口径 [CR P1]**：对比对/反锚定门的"池化均分"= 该轨迹上 golden 与 judge **双方均为数值**的维度的 judge 均分（与配对规则一致，不引入 golden-side 无值维度）
- **Gate 关键轨迹 EVAL_ERROR [CR P0-2]**：GS-11/GS-03/GS-06 任一发生 EVAL_ERROR → 立即单条 fresh 重 spawn（不受 §8.3 ≥2 条阈值限制）；重跑仍失败 → 该止损门 inconclusive → **判 PIVOT**（不许现场解释成 PASS）

**PASS = 三个止损门全过 AND 全部有效性前置满足 AND 稳定性探针无红旗；任一不过且轮次用尽 = PIVOT。**

**稳定性探针（强制 [DA P1-2 升级]）**：最终轮通过后，对 GS-11 + GS-09 各追加 1 次 fresh 重评（+2 spawn）；报告逐维差异；任一维两次评分差 ≥2 → 报告标记 `judge_instability: true` 并在 verdict 行改判需 Gate 4 裁决（PASS 不得自动宣布）。
**Spearman 报告须附 caveat**：n=12 CI ±~0.28 且 golden 类均值倒挂 → 仅方向性参考 [DA P2-1]。
Blake 实现计算脚本/一行命令后，必须先对 round1 数据手工核对 ≥3 个样本点（防公式实现错）。

### 4.5 UI / API
N/A

---

## 5. 🆕 强制问题回答

### MQ1: 历史代码搜索
**回答**：[x] 是——Phase 1 已建 bundle 重建配方（audit report §方法节）；assemble-bundle.sh 是其脚本化，不另起炉灶。盲评 subagent 机制复用 Gate 4 已验证的做法（fresh spawn + paths-only + 禁读清单）。

### MQ2: 函数存在性
不调用项目内函数；jq/grep/awk 系统工具已验证。

### MQ3/MQ4: 数据流 / 视觉
单向：archive + traces（读）→ bundles → judge results → 报告。无 UI。

### MQ5: 状态同步
唯一写入区 `.tad/eval/judge/` + `.tad/evidence/eval/`。无同步。

---

## 6. Implementation Steps

## 6.1 Micro-Tasks

| # | File | Operation | Verification | Est. |
|---|------|-----------|--------------|------|
| 1 | judge-prompt.md | 按 4.2A 写模板 | AC1 greps | 30m |
| 2 | assemble-bundle.sh | 按 4.2B 写脚本 | `bash -n` + 样例 slug 实跑 | 30m |
| 3 | bundles/×12 | 组装全部 bundle | AC10 grep = 0 | 15m |
| 4 | results/round1/×12 | 12 次 fresh Sonnet spawn | AC3 count + jq schema | ~1h |
| 5 | 计算 + 核对 | §4.4 全指标 + 手工核对 3 点 | AC4-AC6 | 30m |
| 6 | （条件）迭代轮 | 分歧诊断 → 措辞修订（记录逐字 diff）→ 全量重跑 | 迭代日志 + Final Scoring Basis | 0-2h |
| 6b | 稳定性探针 | GS-11 + GS-09 各追加 1 次 fresh 评分，逐维对比 | AC13 | 15m |
| 7 | calibration-report | 报告 + verdict 行 + Final Scoring Basis + Stability Probe 节 | AC8 + AC13 | 30m |

### Phase A: 构建（micro 1-3）→ Phase B: Round 1（micro 4-5）→ Phase C: 迭代/收尾（micro 6-7）

**Phase B 判断点**：round1 后如果 within-1 <50%（远低于门槛），先怀疑 bundle 摘录不足或 JSON 解析错，检查 ≥2 条最大分歧轨迹的 judge rationale 是否引用了真实 artifact——数据问题不消耗迭代轮次。

## 6.7 AC Dry-Run Log
**AC Dry-Run Log** (Alex step1d at 2026-07-02):
- AC9 (pre-impl): raw cmd `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills 2>/dev/null | wc -l` → 实际输出 `0` ✅
- Golden 统计基准 (pre-impl，AC6 依据): known-good 2.94 / known-bad 3.30 / GS-11 5.00 / GS-03 2.80 / GS-06 4.20 —— Alex 实算 2026-07-02（见 §2.1）
- AC1-AC8/AC10-AC11 (post-impl): raw form 全部经 `bash -n` 语法验证（heredoc 批量）；不 mock
- AC10 known-BAD/known-GOOD 双测（2026-07-02）：初版 `grep -rl '<a>\|<b>'` 无 `-E` → BRE 字面 pipe → 对含泄漏的 fixture 也输出 0（假 PASS）；已改 `grep -rlE`，fixture 实测泄漏文件被正确捕获（输出 1）
- Advisory linter: 表格 `\|` 转义 WARN 为已知误报类；运行时按 §9.1 pipe-note 还原
- 专家审查后第二轮 dry-run (2026-07-02)：新 AC3 jq 在 5 个 fixture 上双测——good PASS；bad1(null score)/bad2(缺 D1 键)/bad3(score=7 越界)/bad4(空 rationale) 全部 FAIL；旧命令对 bad1 实测假 PASS（证实 CR P0-1）。AC8/AC12/AC13 新命令 `bash -n` 通过

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/eval/judge/judge-prompt.md
.tad/eval/judge/assemble-bundle.sh
.tad/eval/judge/README.md
.tad/eval/judge/bundles/{slug}.md × 12
.tad/eval/judge/results/round{N}/{slug}.json × 12/轮
.tad/evidence/eval/calibration-report-{date}.md（+ pivot-report.md 如触发）
.tad/evidence/designs/trajectory-eval-p2-git-baseline.txt（开工第一步快照）
.tad/evidence/reviews/blake/trajectory-eval-p2/*.md（Layer 2）
```

### 7.2 Files to Modify
```
(无——rubric 措辞澄清仅在迭代轮触发时允许，且必须在报告迭代日志中记录 diff)
```

### 7.3 Grounded Against (Alex step1c)
- .tad/eval/rubric.md (full, read 2026-07-02) — 5 维锚点 + D2 澄清确认
- .tad/eval/golden-set/INDEX.md (full, read 2026-07-02) — 12 条构成 + human_confirmed: true
- .tad/eval/golden-set/GS-07/GS-09 (full, read 2026-07-02) — frontmatter 格式确认（2 空格缩进 D 键）
- .tad/evidence/acceptance-tests/trajectory-eval-p1/gate4-acceptance-report.md (Alex 本人所写)
- .tad/eval/judge/ (确认不存在 — new)

---

## 8. Testing Requirements

### 8.1-8.3
计算公式的正确性由"手工核对 ≥3 样本点"承担（§4.4）；bundle 脚本用 sep-phase2 样例实跑验证。

**EVAL_ERROR 规则**（judge 返回非法 JSON / 拒评）：
- 重跑该条一次（记录）→ 再失败 → 写 `results/round{N}/{slug}.EVAL_ERROR` 标记文件（**不是 .json**——保持 AC3 的 *.json 计数只含合法结果），该条从配对中排除
- ≥2 条 EVAL_ERROR → harness 缺陷，修复后重跑整轮（不消耗迭代轮次）
- **GS-11/GS-03/GS-06 例外**：见 §4.4 Gate 关键轨迹规则——单条即触发强制重 spawn，仍失败 → 该门 inconclusive → PIVOT [CR P0-2]
- AC3 的预期 = 合法 .json 数 + EVAL_ERROR 标记数 = 12，且 EVAL_ERROR 逐条列入报告

## 8.4 Friction Preflight
| Friction Point | Required Step | Fix Path | Substitute | Gate Impact |
|---|---|---|---|---|
| Sonnet subagent 配额/限流 | 12×3 轮评估 | 分批跑（结果落盘可续） | 无（模型是用户决定） | 未跑完 → honest_partial |
| Agent usage 未报 token | NFR1 成本记录 | 从工具返回 usage 读取 | 记录 duration + bundle 行数为 proxy，报告注明 DEGRADED | AC7 改用 proxy 需注明 |

## 8.5 Feedback Collection
N/A（结构化数据产物）

## 8.6 Test Evidence Required
- [ ] 12×N 轮全部结果 JSON 落盘
- [ ] 手工核对 3 样本点的过程记录（报告附录）

---

## 9. Acceptance Criteria
- [ ] FR1-FR4 + NFR1-NFR2 全部有证据；§9.1 全行 PASS
- [ ] 报告含机器可读 verdict 行；PIVOT 时 pivot-report 存在且 Phase 3 保持 blocked

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | judge-prompt 五要素齐全 | post-impl | `for p in 'golden-set' 'rationale' 'swap' 'UNRECOVERABLE' '"score"'; do grep -ci "$p" .tad/eval/judge/judge-prompt.md; done` | 5 行全部 ≥1 | (post-impl; syntax-validated) |
| AC2 | 组装脚本语法 + 样例实跑 | post-impl | `bash -n .tad/eval/judge/assemble-bundle.sh && bash .tad/eval/judge/assemble-bundle.sh sep-phase2 && test -s .tad/eval/judge/bundles/sep-phase2.md && echo OK` | `OK` | (post-impl; syntax-validated) |
| AC3 | round1 结果 12 条且 schema 逐维合法 | post-impl | `J=$(ls .tad/eval/judge/results/round1/*.json 2>/dev/null \| wc -l); E=$(ls .tad/eval/judge/results/round1/*.EVAL_ERROR 2>/dev/null \| wc -l); echo "$((J+E))"; for f in .tad/eval/judge/results/round1/*.json; do jq -e '[.D1,.D2,.D3,.D4,.D5] \| all(type=="object" and ((.score\|type=="number" and .>=1 and .<=5) or .score=="UNRECOVERABLE") and (.rationale\|type=="string" and length>0))' "$f" >/dev/null \|\| echo "BAD $f"; done` | `12` + 无 BAD 行（`all()` 逐维校验——初版 `[...][] \| .score` 只看最后一维的 exit code = 假 PASS [CR P0-1 fix]） | (post-impl; jq 已在 good/bad fixture 上双测，见 §6.7) |
| AC4 | GATE: 池化 within-1 ≥80%（D1,D2,D3,D5；pairwise 数值配对） | post-impl | 报告"Gate Metrics"表 + Alex Gate 4 按 §4.4 公式独立重算 | ≥80%（或 PIVOT 路径记录） | (post-impl — 最终轮) |
| AC5 | 对比对判别：judge(GS-11)−judge(GS-03) ≥1.5 | post-impl | 报告表 + Gate 4 重算 | ≥1.5 方向正确（或 PIVOT） | (post-impl) |
| AC6 | 反锚定：judge(GS-06 池化均分) ≥3.5 | post-impl | 报告表 + Gate 4 重算 | ≥3.5（或 PIVOT） | (post-impl) |
| AC7 | 延迟 ≤5min/次（强制）+ token 记录（advisory） | post-impl | 报告逐次记录表：wall-clock 全记录（p50/max）；subagent_tokens **如工具返回可得**则记录，不可得 → 记 bundle 行数为 proxy 并注明 DEGRADED [CR P1：Agent tool 不保证回报 token] | wall 全部 ≤5min；token 列存在（值或 DEGRADED 注明） | (post-impl) |
| AC8 | verdict 行 + 轮次合规 + Final Scoring Basis | post-impl | `grep -chE '^calibration_verdict: (PASS\|PIVOT)$' .tad/evidence/eval/calibration-report-*.md \| awk '{s+=$1}END{print s}'; grep -hc '^## Final Scoring Basis' .tad/evidence/eval/calibration-report-*.md`；该节须含最终计分轮次 + **rubric 措辞变更的逐字 diff**（无变更则声明 none）[DA P1-1]；迭代日志 ≤3 轮（重跑标注 counting/non-counting）；PIVOT → `test -f .tad/evidence/eval/pivot-report.md` | 两个 grep 各输出 `1` + 轮次合规 | (post-impl; syntax-validated) |
| AC9 | Anti-Goodhart 维持 | pre-impl | `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills 2>/dev/null \| wc -l` | `0` | `0`（Alex 实测 2026-07-02） |
| AC10 | Judge 盲评：bundle 零泄漏 | post-impl | `grep -rlE 'label_class\|golden-set' .tad/eval/judge/bundles/ \| wc -l` | `0` | (post-impl; syntax-validated — step1d 抓到初版漏 `-E` 导致 BRE 字面 pipe = 永假 PASS，已修) |
| AC11 | 变更范围（基线 diff，预置并发豁免） | post-impl | 开工快照 `git status --porcelain \| sort > .tad/evidence/designs/trajectory-eval-p2-git-baseline.txt`；Gate 3: `git status --porcelain \| sort > /tmp/te-p2-post.txt; comm -13 .tad/evidence/designs/trajectory-eval-p2-git-baseline.txt /tmp/te-p2-post.txt \| grep -vE '(\.tad/eval/\|\.tad/evidence/eval/\|trajectory-eval-p2\|\.tad/active/\|\.tad/evidence/traces/\|\.tad/evidence/decisions/\|\.tad/evidence/reviews/\|\.tad/evidence/research/\|\.mcp\.json\|ldr-poc\|automated-content-pipelines\|COMPLETION-20260702-trajectory-eval-p2)' \| wc -l` | `0`（并发 LDR/research 路径已预豁免 — P1 gate4_delta 教训） | (post-impl; syntax-validated) |
| AC12 | Bundle 行数上限 | post-impl | `for f in .tad/eval/judge/bundles/*.md; do [ $(wc -l < "$f") -le 1500 ] \|\| echo "FAIL $f"; done` | 无输出 | (post-impl; syntax-validated) |
| AC13 | 稳定性探针（强制） | post-impl | 报告 "Stability Probe" 表：GS-11 + GS-09 各 2 次 fresh 评分的逐维对比；`grep -hc '^## Stability Probe' .tad/evidence/eval/calibration-report-*.md` | `1`；任一维 Δ≥2 → 报告含 `judge_instability: true` 且 verdict 不得自动 PASS [DA P1-2] | (post-impl; syntax-validated) |

> Pipe-escape note: 表格内 `\|` 运行时还原为 `|`（AC1/AC3/AC10 内的 `\|` 均为此类）。

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC3 jq `[...][] \| .score` 只以最后一维定 exit code → 假 PASS | §9.1 AC3（改 `all()` 逐维校验 + score 值域 + rationale 非空；fixture 双测见 §6.7） | Resolved |
| code-reviewer | P0-2: GS-11/GS-03/GS-06 EVAL_ERROR 无规则 → 止损门缺操作数 | §4.4 Gate 关键轨迹规则 + §8.3（强制单条重 spawn；仍失败 → 门 inconclusive → PIVOT） | Resolved |
| code-reviewer | P1: EVAL_ERROR 文件与 AC3 计数冲突 | §8.3（.EVAL_ERROR 标记文件非 .json；AC3 = json+error 合计 12） | Resolved |
| code-reviewer | P1: 池化均分维度集未定义 | §4.4 均分口径（双方数值维度，与配对规则一致） | Resolved |
| code-reviewer | P1: subagent_tokens 可能不可得 → AC7 永久 DEGRADED | §9.1 AC7（token 降为 advisory + proxy 记录；wall-clock 为强制项） | Resolved |
| code-reviewer | P2: AC1 英文标记词可能被中文正文遗漏；bundle 上限无 AC；AC11 缺 research 豁免 | §4.2A（英文标记词强制）；AC12 新增；AC11 允许清单 +`.tad/evidence/research/` | Resolved |
| data-analyst | P0-1: 无配对数下限 → UNRECOVERABLE 滥标可缩分母凑 80% | §4.4 有效性前置（配对 ≥27，违反 = harness 缺陷重跑不耗轮次） | Resolved |
| data-analyst | P0-2: 门用轨迹的均分可能只剩 1-2 维 → 不稳定 | §4.4 有效性前置（GS-11/03/06 judge 数值维度 ≥3） | Resolved |
| data-analyst | P1-1: 轮间 rubric 措辞变更污染可比性 | AC8 + §6 micro-6（Final Scoring Basis 节 + 逐字 diff） | Resolved |
| data-analyst | P1-2: 单次评估随机性威胁门指标（±10-15pp） | §4.4 稳定性探针（强制，GS-11+GS-09 重评；Δ≥2 → judge_instability 阻止自动 PASS）+ AC13 | Resolved |
| data-analyst | P1-3: D2 首次提交口径在 bundle 中不可判 | §4.2B（trace 按时间戳升序保留 ts）+ §4.2A.6（temporal-ambiguity 保守规则） | Resolved |
| data-analyst | P2: Spearman 不可解释；±0.05 caveat 不可机读；截断偏差；UNRECOVERABLE 判例缺失 | §4.4 caveat 行；§10.2 保留人工裁决（不强行机读化）；§4.2B 截断优先级；§4.2A.5 判例表 | Resolved |

### Experts Selected
1. **code-reviewer** — AC 命令正确性 + JSON schema 契约 + 脚本边界（惯例必选）
2. **data-analyst** — §4.4 度量口径（pairwise 排除、gate/advisory 划分、对比对设计）是本 Phase 可信度的命门

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 2 P0 + 3 P1 + 5 P2 全部 Resolved
- data-analyst: CONDITIONAL PASS → 2 P0 + 3 P1 + 4 P2 全部 Resolved
- Review evidence: `.tad/evidence/reviews/alex/trajectory-eval-p2/{code-reviewer,data-analyst}.md`

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **golden 分数冻结**——迭代轮只许改 judge prompt / rubric 措辞；改分数 = 校准作废
- ⚠️ **judge 每次 fresh spawn**——复用 judge、给它看往轮结果 = 锚定污染，校准作废
- ⚠️ **PIVOT 是合法出口**——不许为凑 80% 改 §4.4 口径；口径含糊处回 Alex，不现场发明
- ⚠️ **禁止把 rubric 引入执行 context**（AC9）

### 10.2 Known Constraints
- D4 advisory（n=7 data-poor，Phase 1 预声明）；D2 按"首次提交口径"评（rubric 已写明）
- 若最终 gate 指标落在门槛 ±0.05 内：报告必须注明"同族模型评审员 caveat"，Gate 4 将按 Epic carry-forward #4 考虑加一轮 Codex 交叉评分再定 PASS/PIVOT

### 10.3 Sub-Agent 使用建议
- judge 评估本身 = 12×N 个 fresh Sonnet spawn（这是设计，不是建议）
- bundle 组装如需并行 fan-out 可用 general-purpose

---

## 11. 🆕 Learning Content

### 11.1 Decision Rationale: 类均值判别 → 对比对判别
| 方案 | 优点 | 缺点 | 为什么 |
|------|------|------|--------|
| 对比对 + 反锚定（选中） | 与 rigor≠outcome 设计自洽；golden 自身差 2.2 支撑 1.5 门槛 | 覆盖 3 条轨迹而非全类 | ✅ 类均值倒挂（2.94 vs 3.30）使原指标按构造不可满足 |
| 类均值差 ≥1.5（原 Epic） | 直觉简单 | golden 自身为 −0.36，judge 忠实反而 FAIL | Alex 实算后废弃（Epic 已修订） |

**💡 学习点**：判别性指标必须先在 ground truth 自身上验证可满足性——尺子自己都量不出的差距，不能要求 judge 量出来。

---

## 12. 🆕 Sub-Agent使用记录
(Blake完成后填写)

---

## Required Evidence Manifest

```yaml
required_evidence:
  completion: ".tad/active/handoffs/COMPLETION-20260702-trajectory-eval-p2.md"
  judge_prompt: ".tad/eval/judge/judge-prompt.md"
  assembler: ".tad/eval/judge/assemble-bundle.sh"
  run_protocol: ".tad/eval/judge/README.md"
  bundles: ".tad/eval/judge/bundles/*.md (12)"
  results: ".tad/eval/judge/results/round1/*.json (12; roundN 如有迭代)"
  calibration_report: ".tad/evidence/eval/calibration-report-*.md (含 calibration_verdict 行)"
  pivot_report: ".tad/evidence/eval/pivot-report.md (仅 PIVOT 时)"
  git_baseline: ".tad/evidence/designs/trajectory-eval-p2-git-baseline.txt"
  blake_layer2_reviews: ".tad/evidence/reviews/blake/trajectory-eval-p2/*.md (>=2 distinct)"
  knowledge_updates: "journal in completion ## Journal OR explicit no-discovery"
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-02
**Version**: 3.1.0
