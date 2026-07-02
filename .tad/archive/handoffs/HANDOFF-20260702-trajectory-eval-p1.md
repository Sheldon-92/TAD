---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: research   # code | yaml | research | e2e | mixed
e2e_required: no      # yes | no
research_required: yes # yes | no - Blake 必须产出研究文件（audit report 即研究产物）
git_tracked_dirs: [".tad/eval"]
skip_knowledge_assessment: no
gate4_delta:
  - field: "§6 Phase C step4 / AC9 (blind-label protocol)"
    alex_said: "Human blind-scores 3 trajectories at Gate 4 as calibration ground truth"
    actual: "Human cannot perform trajectory-forensics labeling — substituted 2 independent blind subagent raters + Alex adjudication of >=2 divergences, user-approved (DEGRADED_WITH_APPROVAL)"
    caught_by: "human walkthrough at Gate 4"
  - field: "AC11"
    alex_said: "Baseline line-set diff neutralizes all non-task noise"
    actual: "2 cross-session files (.mcp.json + .tad/evidence/research/ldr-poc/) from concurrent LDR Epic appeared post-baseline; Blake's completion reported only 1 of 2 — both same root cause (concurrent-session contamination), neither created by this task"
    caught_by: "Alex raw recompute"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-02
**Project:** TAD
**Task ID:** TASK-20260702-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260701-trajectory-eval-harness.md (Phase 1/3)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-02

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review complete (min 2) | ✅ | code-reviewer + data-analyst，evidence 落盘 `.tad/evidence/reviews/alex/trajectory-eval-p1/` |
| All P0 resolved | ✅ | 6 P0（CR 2 + DA 4）全部 Resolved，见 §9.2 Audit Trail |
| Architecture Complete | ✅ | §4.1 目录结构 + §4.2A bundle 定义完整；无代码架构（research 任务） |
| Components Specified | ✅ | §4.2 B/C/D/E 四个格式约定 + 组成规则全部显式化（AC 机械依赖） |
| Functions Verified | ✅ | 不调用项目内函数（MQ2）；jq/grep 系统工具已验证；AC raw form 全部 bash -n + 实测 |
| Data Flow Mapped | ✅ | 单向：archive/traces（只读）→ .tad/eval/ + audit report（MQ5） |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
Trajectory Eval Harness 的 Phase 1：(a) 数据充分性审计 —— 验证现有 artifacts 能否还原可评分的执行轨迹；(b) ≥5 维评分 rubric（锚定 Gate canonical checklist）；(c) ≥10 条人工标注 golden set（含 ≥2 条已知差的轨迹）。

### 1.2 Why We're Building It
**业务价值**：TAD 的 gate ROI 从未被测量（2026-06-09 定位研究判定为差异化核心缺口），Gate 报告由执行 agent 自己撰写，无法独立验证。本 Phase 产出后续 judge 校准所需的"尺子"（rubric）和"标准样本"（golden set）。
**用户受益**：TAD 维护者获得回答"这个质量机制真的有效吗"的数据基础。
**成功的样子**：当 Phase 2 的 judge 可以拿着 rubric 对 golden set 打分并测量一致性时，这个 Phase 就成功了。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：为"用没校准的尺子量 Gate"这个风险建立防线——先证明数据够用（审计），再定义尺子（rubric），再准备校准标准（golden set）。三者的顺序是本 Phase 的核心设计（Measure Before Optimizing）。

**不是要做的（避免误解）**：
- ❌ 不是实现 judge（那是 Phase 2）
- ❌ 不是改 trace 采集机制（如果审计发现数据缺口，只写"最小 schema 增量提案"，不实现）
- ❌ 不是给 Gate 加任何阻断行为（本 Epic 全程 offline 测量）
- ❌ 不是 agent 自己确认标注就算数（golden set 标签必须人类确认——这是校准的 ground truth）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 为什么审计必须在 rubric 设计之前？
3. golden set 的标签为什么必须人类确认？
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read `.tad/project-knowledge/principles.md`
2. Read `.tad/project-knowledge/patterns/gate-design.md` + `patterns/ac-verification.md` + `patterns/memory-and-learning.md`
3. Read 本节"⚠️ Blake 必须注意的历史教训"

### 步骤 1：识别相关类别
- [x] architecture - 架构决策（测量子系统）
- [x] testing - 验证模式（rubric/golden set 即测试基础设施）
- [x] code-quality - grep/awk 验证命令正确性

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| patterns/gate-design.md | 5 条直接相关 | rubric gate 必须能 FAIL；judge≠producer；Claims Need Carriers |
| patterns/ac-verification.md | 4 条直接相关 | AC 命令必须 dry-run；grep -oE 不用 grep -c；awk range 陷阱 |
| patterns/memory-and-learning.md | 2 条直接相关 | observational emission；parser 必须传播 VALUE 字段 |
| principles.md | 3 条直接相关 | Measure Before Optimizing；validation theater（YOLO audit）；知识在 distill 时锻造 |

**⚠️ Blake 必须注意的历史教训**：

1. **A Rubric Gate Is Only Credible If It Can FAIL** (gate-design.md 2026-05-31/2026-06-06)
   - 问题：只会 PASS 的质量门是未经证明的 theater
   - 应用：golden set 必须含 ≥2 条已知差的轨迹，且 rubric 的每个维度锚点要能区分它们；band 标准只描述 rigor，不描述结论

2. **Claims Need Carriers** (gate-design.md 2026-06-10)
   - 问题：只存在于对话文本的完成声明对下游验证器不可见
   - 应用：人工确认必须有载体文件（INDEX.md 的 `human_confirmed` 字段），不是对话里说"确认了"

3. **AC Verification Drift** (ac-verification.md 2026-04-25, 4 个 phase 反复出现)
   - 问题：没在真实 artifact 上 dry-run 的验证命令在 Blake runtime 出错
   - 应用：§9.1 每条命令 Alex 已 dry-run（见 Verified Output 列）；Blake 修改格式约定时必须同步修改验证命令并重新 dry-run

4. **A Parser Feeding a Human-Review Queue Must Propagate VALUE Fields** (memory-and-learning.md 2026-05-31)
   - 问题：dream-scanner 只提取 label 丢弃 rationale，产出零信号候选，6/6 被拒
   - 应用：golden set 每个维度的标注必须带 1 行 rationale，不能只有分数

5. **Batch Migration failure_mode Inferability ~70/30** (memory-and-learning.md 2026-06-22)
   - 问题：~30% 的历史条目缺关键上下文，强行填充比诚实标记 gap 更危险
   - 应用：审计中无法还原的轨迹维度，诚实标记 UNRECOVERABLE，不要编造覆盖率

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题

---

## 2. Background Context

### 2.1 Previous Work
- **Trace 采集（emission 侧，live）**：`.tad/hooks/post-write-sync.sh` 观察式解析 agent 写的 artifacts → `.tad/evidence/traces/{date}.jsonl`（schema v2.0）；`.tad/hooks/lib/trace-writer.sh` 提供 helpers。**本 Phase 只读不改。**
- **Trace 分析（reading 侧，retired）**：dream-scanner 已于 2026-06-10 Self-Evolution Pruning 退役归档。本 Phase 的 bundle 组装是新建，不复活 dream-scanner。
- **Gate 定义 SSOT**：`.tad/gates/gate-canonical-checklist.md`（2026-06-23 MECE pass）—— rubric 维度的锚定源。

### 2.2 Current State（Alex 已实测，2026-07-02）
- 归档 handoff：468 个文件，其中 179 份 COMPLETION 报告
- Gate 4 evidence：`.tad/evidence/acceptance-tests/` 56 个目录
- 专家审查 evidence：`.tad/evidence/reviews/`（含 blake/ 子目录）
- Trace 事件分布（2026 全部日文件）：evidence_created 1179 / handoff_created 922 / task_completed 158 / decision_point 131 / expert_review_finding 72 / gate_result 66 / reflexion_diagnosis 9 —— 事件带 `slug` 字段可与 handoff 关联
- `.tad/eval/` 不存在（本 Phase 创建）

### 2.3 Dependencies
- jq（已安装，trace-writer 已依赖）
- 无新增外部依赖，无网络需求，无 NotebookLM 需求

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 数据充分性审计——对 ≥10 个抽样归档轨迹（覆盖 code/yaml/research 类型 + 不同时期），尝试重建"trajectory bundle"，产出 维度×数据源 覆盖矩阵
- FR2: Rubric——≥5 个维度，每维 1-5 分锚点，锚定 gate-canonical-checklist，维度间 MECE
- FR3: Golden set——≥10 条轨迹的逐维人工标注（Blake 起草 + 人类确认），含 ≥2 条已知差的
- FR4: 如审计发现数据缺口——写"最小 schema 增量提案"章节（提案 only，禁止实现）

### 3.2 Non-Functional Requirements
- NFR1: Anti-Goodhart——rubric 文件不得被任何执行 agent 的常驻 context 引用（CLAUDE.md / .claude/skills / .agents/skills 零引用）
- NFR2: 诚实覆盖——审计中无法重建的部分标记 UNRECOVERABLE，禁止编造覆盖率

---

## 4. Technical Design

### 4.1 Architecture Overview
```
.tad/eval/                        ← 新目录（评估基础设施，独立于执行链路）
├── rubric.md                     ← 尺子：≥5 维，### D{n}: 标题 + 1-5 锚点
└── golden-set/
    ├── INDEX.md                  ← 清单 + human_confirmed 字段（人工确认载体）
    └── GS-{nn}-{slug}.md         ← 每条轨迹：frontmatter 逐维分数 + rationale

.tad/evidence/designs/
└── trajectory-data-audit.md      ← 审计报告：## Coverage Matrix + 抽样清单 + 缺口
```

### 4.2 Component Specifications

**A. Trajectory Bundle 定义（审计的对象）**
一条轨迹 = 一个归档 handoff slug 关联的全部 artifacts：
1. `HANDOFF-{date}-{slug}.md`（含 §9.1 AC 表 + §9.2 Audit Trail）
2. `COMPLETION-{date}-{slug}.md`（如存在；468 中 179 有）
3. `.tad/evidence/acceptance-tests/{slug}/`（Gate 4 evidence，如存在）
4. `.tad/evidence/reviews/**/{slug}*`（专家审查，如存在）
5. trace 事件：`grep '"slug":"{slug}"' .tad/evidence/traces/*.jsonl`（gate_result / expert_review_finding / decision_point 等）

**B. Rubric 格式约定（AC 依赖此约定，不可擅改）**
```markdown
### D1: {维度名}
> Grounding: gate-canonical-checklist.md {对应条目}
> Data source: {bundle 中的哪些 artifact 支撑此维度评分}
- **1**: {最差表现锚点描述}
- **2**: ...
- **3**: ...
- **4**: ...
- **5**: {最佳表现锚点描述}
```
候选维度（Blake 基于审计结果最终确定，不必照抄）：AC/需求对齐度、验证完整性（声称的验证是否真的跑了、evidence 是否存在）、约束遵守（forbidden actions / 流程契约）、升级诚实度（honest_partial vs 掩盖）、知识捕获质量。
⚠️ 锚点措辞只描述 **rigor（证据深度/覆盖）**，禁止描述结论方向（gate-design.md 2026-06-06 教训）。
⚠️ **存在性维度 vs 质量维度须区分**（DA P1-4）：trace 事件以存在性为主（evidence_created 等），只依赖 trace 的维度实际是"有/无"量表撑不起 1-5 锚点——此类维度必须结合 artifact 内容（如 review 文件的发现深度）设计质量锚点，或在 Data source 行显式标注 `type: existence`（此类维度锚点允许 1/3/5 三级语义）。

**C. Golden Set 文件格式约定（AC 依赖此约定）**
```markdown
---
trajectory: {archived handoff slug}
label_class: known-good | known-bad | mixed
borderline: []          # 可选：边界分维度列表，如 [D2, D4]（DA P1-2，within-1 评估时参考）
scores:
  D1: {1-5}
  D2: UNRECOVERABLE     # 数据不可还原的维度用此标记（DA P0-4）——禁止编造分数
  ...（键数与 rubric 维度数严格一致；缩进恰好 2 空格，AC8 依赖 [CR P2]）
---
# GS-{nn}: {slug}
## Per-dimension rationale
- D1 ({score}): {1 行理由，引用 bundle 中的具体 artifact}
- ...
```
INDEX.md 格式：轨迹清单表 + 末尾三行：
```
human_confirmed: false
blind_label_divergences: (pending Gate 4)
human_modifications: (pending Gate 4)
```
（Blake 写 false/pending；人类在 Gate 4 盲评+审阅后由 Alex 填实际值并翻 true——Claims Need Carriers。`human_modifications: 0` 将被视为锚定警告信号，DA P0-2。）

**Phase 2 预声明（UNRECOVERABLE 处理规则，不留给 Phase 2 自由发挥）**：judge 校准计算相关性时对 UNRECOVERABLE 维度做 pairwise 排除；任一维度的完整评分轨迹数 <8 → 该维度标记 data-poor，不参与止损判定但记录在校准报告。

**E. 审计抽样清单表格式约定（AC2 依赖，CR P1-1）**
审计报告的抽样清单表每行以 `| S{n} ` 开头（S1…S{n} 为抽样编号列），列含：slug、任务类型、时期、5 类 artifact 存在性、trace 事件数、bundle 可重建判定。

**D. 已知差轨迹候选（known-bad ≥2，Blake 从中选可重建的）**
1. 2026-04-14 express plain-language 事件（自查出 4 P0，principles.md "Express Handoff is NOT Review-Exemption" 的来源）
2. sep-phase2 Gate 4 首轮 PARTIAL（claims-without-carriers：声称 review 完成但 evidence/reviews/ 零文件）——`.tad/evidence/acceptance-tests/sep-phase2/`
3. surplus-scan Phase 1 Gate 3 live-run 失败（4 轮专家审查全 PASS 但首次真实运行连爆 2 个 bug——validation theater 实例）——ac-verification.md 2026-06-08 条目

⚠️ **知名度选择偏差防御（DA P0-3）**：以上全是"极端差"案例，只用它们会人为抬高 Phase 2 判别缺口。强制要求：
- ≥1 条 **silent-bad**：当时通过全部 Gate、后来被发现有质量问题的轨迹。机械检索法：`ls .tad/archive/handoffs/ | grep -iE 'bugfix|fix-'` 找修复型 handoff，其**前驱轨迹**即 silent-bad 候选（如 bugfix-dream-scanner-override-content 的前驱 dream-scanner 轨迹）；另可查 frontmatter `gate4_delta` 非空的 handoff
- ≥1 条 known-bad 在部分维度得分落在 **2-3**（非全 1）——测试 judge 的中间区间判别，不只是两极
- 抽样分层加入 Gate 结果维度：≥3 条抽样轨迹有非全绿历史（PARTIAL/FAIL/被修复），DA P1-3
如候选不足，审计报告中说明并向 Alex 提出替代（honest_partial）。

### 4.3 Data Models
见 4.2 B/C 的格式约定。分数域：整数 1-5。

### 4.4 API Specifications
N/A（无 API）

### 4.5 User Interface Requirements
N/A（无 UI）

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
**回答**：[x] 是
```bash
grep -rl "traces" .tad/hooks/ | head -5
# → trace-step.sh, post-write-sync.sh, lib/common.sh, lib/trace-rotate.sh（emission 侧，live，只读）
ls .tad/archive/ | grep -i dream
# → dream-scanner 相关已归档（reading 侧，retired，不复活）
```
- **决定**：emission 侧复用（只读）；bundle 组装逻辑新建（审计报告中的 bash 片段，无常驻脚本）
- **原因**：dream-scanner 因 18→1 yield 被测量淘汰；本任务的 bundle 是审计文档的一部分，不是新常驻工具

### MQ2: 函数存在性验证
**回答**：本 Phase 不调用任何项目内函数（纯文档+数据产出）。jq / grep / ls 为系统工具，已验证存在（trace-writer.sh 已依赖 jq）。

### MQ3: 数据流完整性
N/A —— 无前后端数据流。数据流向单向：archive/traces（读）→ 审计报告 + rubric + golden set（写）。

### MQ4: 视觉层级
N/A —— 无 UI。

### MQ5: 状态同步
单一存储：`.tad/eval/` 是唯一产出位置，无同步需求。
```
[archive + traces (只读)] → .tad/eval/ + .tad/evidence/designs/trajectory-data-audit.md (唯一写入)
✅ 只有一个状态，无需同步
```

---

## 6. Implementation Steps（分Phase）

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | (读操作) | 抽样 ≥10 归档轨迹（分层：code/yaml/research × 早/中/近期），逐条尝试 bundle 重建 | 审计报告抽样清单表 ≥10 行 | 30-45 min |
| 2 | .tad/evidence/designs/trajectory-data-audit.md | 写审计报告：抽样清单 + `## Coverage Matrix`（维度×源）+ 缺口 + （如需）最小增量提案 | `grep -c '^## Coverage Matrix' <file>` = 1 | 20-30 min |
| 3 | .tad/eval/rubric.md | 按 4.2B 格式写 ≥5 维 rubric，每维含 Grounding + Data source 行 | `grep -cE '^### D[0-9]+:' <file>` ≥ 5 | 30-45 min |
| 4 | .tad/eval/golden-set/GS-*.md | 起草 ≥10 条标注（≥2 known-bad），逐维分数+rationale | `ls .tad/eval/golden-set/GS-*.md \| wc -l` ≥ 10 | 45-60 min |
| 5 | .tad/eval/golden-set/INDEX.md | 写清单 + `human_confirmed: false` + blind_label 字段 | `grep -c '^human_confirmed: false' <file>` = 1（与 AC9 对齐） | 5 min |
| 6 | .tad/eval/golden-set/BLIND-PACK.md | 3 条轨迹的无分数盲评摘要 | `test -f <file>` | 15 min |

### Phase A: 审计（约 1 小时）
1. 分层抽样 ≥10 个归档 slug（用 `ls .tad/archive/handoffs/ | grep -v COMPLETION` + 按日期分段）
2. 每条按 4.2A 定义重建 bundle，记录：5 类 artifact 各自存在与否、trace 事件数（按 slug grep）
3. 输出审计报告。**判断点**：如果 >50% 抽样轨迹连 handoff+completion 对都凑不齐 → 停下向 Alex 报告（honest_partial），不要硬做 rubric

#### Phase A 完成证据
- [ ] trajectory-data-audit.md（含 Coverage Matrix + 抽样清单）

### Phase B: Rubric（约 1 小时）
1. 读 gate-canonical-checklist.md，把 Gate 3/4 检查项归纳为质量维度
2. 对照审计结果：每个候选维度必须有 ≥1 个今天就存在的数据源，否则该维度改设计或标记依赖增量提案
3. 按 4.2B 格式写 rubric；自查 MECE（无两个维度的锚点描述同一 artifact 的同一属性）

#### Phase B 完成证据
- [ ] rubric.md（≥5 维 × 5 锚点，每维含 Grounding + Data source）

### Phase C: Golden Set（约 2 小时）
1. 从审计抽样 + 4.2D 候选中选 ≥10 条（建议 12-15；构成：≥2 known-bad 其中 ≥1 silent-bad、≥4 known-good、其余 mixed）
2. 逐条逐维打分 + 1 行 rationale（引用具体 artifact，不引用记忆）；数据不可还原的维度标 UNRECOVERABLE
3. 自查 AC8b：每维分数跨 ≥3 个层级；不满足 → 换样本或补充中间质量轨迹
4. **盲评包准备（DA P0-2 锚定防御）**：选 3 条轨迹（含 ≥1 known-bad），准备"无分数 bundle 摘要"（每条 ≤1 页：artifact 清单 + 关键片段引用，不含 Blake 的分数与 rationale），存 `.tad/eval/golden-set/BLIND-PACK.md`。Gate 4 流程：人类先对这 3 条独立打分 → 再对照 Blake 草稿 → 任一维度差异 ≥2 → 讨论并修订 rubric 锚点措辞。Alex 将差异数与人类修改数写入 INDEX（`human_modifications: 0` = 锚定警告）
5. **维度间相关性自查（DA P1-1）**：打分完成后计算维度对之间的 Spearman（10-15 条样本手工/脚本皆可），r>0.75 的维度对在完成报告标记为潜在 MECE 违规（advisory，供 rubric 修订参考）
6. ⚠️ 标签是"起草"——完成报告中明确写"标签待人类确认（Gate 4 盲评 + 审阅）"

#### Phase C 完成证据
- [ ] GS-*.md ≥10 + INDEX.md + BLIND-PACK.md + 维度间相关性表（完成报告内）

## 6.7 AC Dry-Run Log

**AC Dry-Run Log** (Alex step1d 实际 dry-runs at 2026-07-02):
- AC10: ✅ pre-impl-verifiable, raw cmd: `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills 2>/dev/null | wc -l`, 实际输出 `0` = expected
- AC1/AC3-AC9: ✅ post-impl-verifiable, 全部 raw form 经 `bash -n` 语法验证通过（heredoc 批量），目标文件尚不存在，不 mock
- AC2: ✅ post-impl-verifiable, 语法验证通过。注意：raw form 为 `grep -cE '^[|] *(GS-|S)[0-9]+' ...`（alternation 用裸 `|`；行首字面 pipe 用 `[|]` 字符类）——表格单元格里的 `\|` 仅为 markdown 转义，运行时必须还原
- AC11: ⚠️ 首版全树 grep 在当前 tree 实测输出 `8`（先前 session 未提交噪音：REGISTRY.yaml/NEXT.md/旧 evidence 文件）→ 已修正为 baseline line-set diff 形式（快照文件 + comm -13），修正后逻辑经语法验证
- Advisory linter (verify-ac-commands.sh): 2 × Rule B WARN（AC2/AC11 的 `\|`）——均为 markdown 表格转义，raw form 已确认用裸 `|` 并 dry-run；AC11 warning 同时触发了上面的真修正
- 专家审查后修订版 re-dry-run (2026-07-02 第二轮)：AC2 新字符类形式在样例表行实测（匹配 S 行=1、表头=0）；AC8/AC8b/AC9/AC11 修订版 raw form `bash -n` 通过；linter 4 WARN 复核均为误报（Rule B = 表格转义；Rule A 对 AC8b 系将 `D=` 赋值的 `-c` 与 `grep -h` 计数管道误关联，实际计数管道无 `-c`）

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/designs/trajectory-data-audit.md            # 审计报告
.tad/evidence/designs/trajectory-eval-p1-git-baseline.txt # AC11 基线快照（Blake 开工第一步）
.tad/eval/rubric.md                                       # 评分 rubric
.tad/eval/golden-set/INDEX.md                             # 清单 + human_confirmed 载体
.tad/eval/golden-set/GS-{nn}-{slug}.md × ≥10              # 标注轨迹
.tad/eval/golden-set/BLIND-PACK.md                        # Gate 4 盲评包（3 条无分数摘要）
.tad/evidence/reviews/blake/trajectory-eval-p1/*.md       # Blake Layer 2 review 文件（CR P0-2：已加入 AC11 允许清单）
```

### 7.2 Files to Modify
```
(无 — 本 Phase 零修改现有文件；epic/session-state 由 Alex/协议维护)
```

### 7.3 Grounded Against (Alex step1c)

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- .tad/gates/gate-canonical-checklist.md (full 58 lines, read at 2026-07-02) — rubric 锚定源，Gate 1-4 条目已确认
- .tad/evidence/traces/2026-07-01.jsonl (tail sample, read at 2026-07-02) — schema v2.0 字段确认（ts/type/slug/actor_tag/detail_level）
- .tad/hooks/lib/trace-writer.sh (head 30, read at 2026-07-02) — 事件 helpers 带 slug 字段确认
- .tad/archive/handoffs/ (ls 计数 468 files / 179 COMPLETION, at 2026-07-02)
- .tad/evidence/acceptance-tests/ (ls 计数 56 dirs, at 2026-07-02)
- .tad/eval/ (确认不存在 — new, will be created)

---

## 8. Testing Requirements

### 8.1 Unit Tests
N/A（无代码）。格式约定的机械可验证性由 §9.1 grep ACs 承担。

### 8.2 Integration Tests
审计报告的 bundle 重建 bash 片段必须在报告中附实际输出（不是伪代码）——每条抽样轨迹的 artifact 存在性是实测结果。

### 8.3 Edge Cases
- 早期 handoff（2026-02 之前）无 §9.1/frontmatter → 审计中标记为格式代际差异，golden set 优先选 2026-04 之后的轨迹
- trace 文件只覆盖近期（daily rotate）→ 老轨迹 trace 维度标 UNRECOVERABLE，rubric 的 Data source 不得只依赖 trace
- 同 slug 多个 handoff 版本（supersedes 链）→ bundle 以最终版为准，审计报告注明

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| 人类标注确认需要用户时间 | golden set 标签人类确认 | 打包为一次 Gate 4 审阅（Alex 呈现 10 条标注摘要表） | 无 — agent 自我确认 NEVER equivalent（这是校准 ground truth） | INDEX human_confirmed 未翻 true → Epic Phase 2 校准不可信；Gate 4 前 false 是预期状态，不阻塞 Gate 3 |
| 已知差轨迹 artifacts 可能不完整 | known-bad ≥2 可重建 | 按 4.2D 三个候选逐一尝试 | 向 Alex 提替代候选（honest_partial） | AC5 <2 → Gate 3 FAIL |

其余无 friction-sensitive prerequisites（无安装/auth/网络/审批需求）。

## 8.5 Feedback Collection (Non-Code Artifacts)
N/A —— 产物是结构化数据文件，质量由 §9.1 机械验证 + Gate 4 人工标签审阅覆盖，不需要 overlay feedback HTML。

## 8.6 🆕 Test Evidence Required
- [ ] 审计报告中的 bundle 重建命令 + 实际输出（≥10 条轨迹）
- [ ] §9.1 全部 post-impl 行的 Verified Output（Blake Gate 3 填写）

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] FR1-FR4 实现并有证据
- [ ] §9.1 全行 PASS
- [ ] 完成报告明确声明"golden set 标签待人类确认"

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | 审计报告存在且含覆盖矩阵 | post-impl-verifiable | `test -f .tad/evidence/designs/trajectory-data-audit.md && grep -c '^## Coverage Matrix' .tad/evidence/designs/trajectory-data-audit.md` | 输出 `1` | (post-impl; syntax-validated) |
| AC2 | 审计抽样 ≥10 条轨迹 | post-impl-verifiable | `grep -cE '^[\|] *S[0-9]+ ' .tad/evidence/designs/trajectory-data-audit.md`（抽样清单表行，格式见 §4.2E） | ≥ 10 | (post-impl; syntax-validated — 行首字面 pipe 用 `[\|]` 字符类，blanket un-escape 后语义正确 [CR P0-1 fix]) |
| AC3 | Rubric ≥5 维 | post-impl-verifiable | `grep -cE '^### D[0-9]+:' .tad/eval/rubric.md` | ≥ 5 | (post-impl; syntax-validated) |
| AC4 | 每维恰好 5 个锚点 | post-impl-verifiable | `test $(grep -cE '^- \*\*[1-5]\*\*:' .tad/eval/rubric.md) -eq $((5 * $(grep -cE '^### D[0-9]+:' .tad/eval/rubric.md))) && echo OK` | 输出 `OK` | (post-impl; syntax-validated) |
| AC5 | 每维含 Grounding + Data source 行 | post-impl-verifiable | `test $(grep -c '^> Grounding:' .tad/eval/rubric.md) -eq $(grep -cE '^### D[0-9]+:' .tad/eval/rubric.md) && test $(grep -c '^> Data source:' .tad/eval/rubric.md) -eq $(grep -cE '^### D[0-9]+:' .tad/eval/rubric.md) && echo OK` | 输出 `OK` | (post-impl; syntax-validated) |
| AC6 | Golden set ≥10 条 | post-impl-verifiable | `ls .tad/eval/golden-set/GS-*.md \| wc -l` | ≥ 10 | (post-impl; syntax-validated) |
| AC7 | known-bad ≥2 条 | post-impl-verifiable | `grep -l '^label_class: known-bad' .tad/eval/golden-set/GS-*.md \| wc -l` | ≥ 2 | (post-impl; syntax-validated) |
| AC8 | 每条 GS 分数维度数 = rubric 维度数（UNRECOVERABLE 合法） | post-impl-verifiable | `D=$(grep -cE '^### D[0-9]+:' .tad/eval/rubric.md); for f in .tad/eval/golden-set/GS-*.md; do [ $(grep -cE '^  D[0-9]+: ([1-5]\|UNRECOVERABLE)$' "$f") -eq $D ] \|\| echo "FAIL $f"; done` | 无输出（零 FAIL 行） | (post-impl; syntax-validated [DA P0-4 fix]) |
| AC8b | 每维分数跨 ≥3 个不同层级 | post-impl-verifiable | `D=$(grep -cE '^### D[0-9]+:' .tad/eval/rubric.md); for d in $(seq 1 $D); do lv=$(grep -hE "^  D${d}: [1-5]$" .tad/eval/golden-set/GS-*.md \| sort -u \| wc -l); [ "$lv" -ge 3 ] \|\| echo "FAIL D${d} (only $lv levels)"; done` | 无输出（防两极化分布使 Phase 2 Spearman 退化） | (post-impl; syntax-validated [DA P0-1 fix]) |
| AC9 | INDEX 含 human_confirmed + blind-label 记录字段 | post-impl-verifiable | `grep -c '^human_confirmed: false' .tad/eval/golden-set/INDEX.md && grep -c '^blind_label_divergences:' .tad/eval/golden-set/INDEX.md` | 两行各输出 `1`（Blake 写 false + 盲评差异记录字段；Gate 4 人类确认后 Alex 翻 true） | (post-impl; syntax-validated [DA P0-2]) |
| AC10 | Anti-Goodhart：执行 context 零引用 rubric | pre-impl-verifiable | `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills 2>/dev/null \| wc -l` | 输出 `0` | `0`（Alex 实测 2026-07-02） |
| AC11 | 变更范围仅限声明文件（相对基线） | post-impl-verifiable | Blake 开工第一步先快照：`git status --porcelain \| sort > .tad/evidence/designs/trajectory-eval-p1-git-baseline.txt`；Gate 3 验证（两步，避免 bashism）：`git status --porcelain \| sort > /tmp/te-p1-post.txt; comm -13 .tad/evidence/designs/trajectory-eval-p1-git-baseline.txt /tmp/te-p1-post.txt \| grep -vE '(\.tad/eval/\|trajectory-data-audit\|trajectory-eval-p1-git-baseline\|\.tad/active/\|\.tad/evidence/traces/\|\.tad/evidence/decisions/\|\.tad/evidence/reviews/\|COMPLETION-20260702-trajectory-eval-p1)' \| wc -l` | 输出 `0`（新增变化全在允许清单内；Layer 2 review 文件已加入允许清单 [CR P0-2 fix]；先前 session 噪音被基线抵消） | (post-impl; syntax-validated — 首版全树 grep 实测误伤 8 行既有噪音，故用基线 line-set diff + temp-file 形式 [CR P1-2]) |

> **Pipe-escape note**: 表格内 `\|` 提取到 bash 运行时须还原为 `|`（step1d Sub-rule 1）。

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC2 的 `\|` blanket un-escape 后 `^\|` 匹配所有行，AC 永不 FAIL | §9.1 AC2（改用 `[\|]` 字符类）+ §4.2E 表格约定 | Resolved |
| code-reviewer | P0-2: AC11 允许清单漏 `.tad/evidence/reviews/`，做强制 review 反而 FAIL | §9.1 AC11 允许清单 + §7.1 新增 reviews 路径 | Resolved |
| code-reviewer | P1-1: AC2 依赖的抽样表行格式未定义 | §4.2E（新增格式约定） | Resolved |
| code-reviewer | P1-2: AC11 `<(...)` bashism | §9.1 AC11（改两步 temp-file 形式） | Resolved |
| code-reviewer | P1-3: journal 落点未钉死可能触发 AC11 误伤 | §10.2（journal 钉死在完成报告 `## Journal` 章节） | Resolved |
| code-reviewer | P2: micro-task 5 grep 与 AC9 不一致；AC8 缩进假设；AC4 空文件依赖 AC3 | §6.1 task 5（已对齐）；§4.2C（2 空格缩进显式化）；AC4 依赖 AC3 属预期组合 | Resolved |
| data-analyst | P0-1: n=10 时 Spearman ±0.28 CI，止损线无统计意义 | §9.1 AC8b（每维 ≥3 层级强制）+ §10.2 统计功效诚实声明（within-1 为主指标）+ §6 Phase C（建议 12-15 条） | Resolved |
| data-analyst | P0-2: 起草-确认流程锚定偏差，无独立 ground truth | §6 Phase C step4（盲评包 + 差异 ≥2 讨论机制）+ §4.2C INDEX 字段（blind_label_divergences / human_modifications 载体）+ AC9 | Resolved |
| data-analyst | P0-3: known-bad 全是极端知名事件，判别缺口被人为抬高 | §4.2D（强制 ≥1 silent-bad + ≥1 中间区间 known-bad + 机械检索法 + 抽样加 Gate 结果分层） | Resolved |
| data-analyst | P0-4: 无 UNRECOVERABLE 协议，GS 条目不可比 | §4.2C（UNRECOVERABLE 标记 + Phase 2 pairwise 排除预声明）+ AC8 regex 扩展 | Resolved |
| data-analyst | P1-1: MECE 自查只到操作层，缺构念相关性检查 | §6 Phase C step5（维度间 Spearman 矩阵，r>0.75 标记，advisory） | Resolved |
| data-analyst | P1-2: 边界分数缺不确定性标记 | §4.2C `borderline` 可选字段 | Resolved |
| data-analyst | P1-3: 抽样分层缺 Gate 结果维度 | §4.2D（≥3 条非全绿历史轨迹） | Resolved |
| data-analyst | P1-4: 存在性量表与质量量表混淆 | §4.2B（existence 型维度显式标注规则） | Resolved |

### Experts Selected
1. **code-reviewer** — 必选；AC 验证命令正确性 + 格式约定机械可验证性是本 handoff 最大风险面（AC-drift 是 4 次复发的历史教训）
2. **data-analyst** — rubric 评分设计 / golden set 抽样分层 / 标注方法学（inter-rater 可靠性、锚点区分度）是测量系统的核心质量面

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 2 P0 + 3 P1 + 3 P2 全部 Resolved
- data-analyst: CONDITIONAL PASS → 4 P0 + 4 P1 全部 Resolved
- Review evidence: `.tad/evidence/reviews/alex/trajectory-eval-p1/{code-reviewer,data-analyst}.md`

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **禁止实现 schema 增量**——审计发现缺口只写提案章节；实现属于未来 handoff
- ⚠️ **禁止把 rubric 引入任何 SKILL/CLAUDE.md**（AC10 会抓）——rubric 只被 Phase 2 judge 的独立 context 读取
- ⚠️ **禁止编造覆盖率**——重建不了就标 UNRECOVERABLE（诚实的 gap > 好看的矩阵）
- ⚠️ **标签起草 ≠ 标签确认**——完成报告必须声明待人类确认

### 10.2 Known Constraints
- 格式约定（4.2 B/C/E）是 AC 的机械依赖——若 Blake 有更好的格式设计，先回 Alex 同步修改 AC，不要单方面改
- Golden set 优先 2026-04 之后的轨迹（格式代际一致性）
- **统计功效诚实声明（DA P0-1）**：n=10-15 时 Spearman 的 95% CI 约 ±0.25-0.28，Phase 2 校准以 **within-1 ≥80% 为主指标**（小样本更稳健），Spearman 为方向性参考；此声明须写入审计报告，Phase 2 handoff 继承
- **Journal 位置钉死（CR P1-3）**：Gate 3 KA 如产出 journal，写在完成报告的 `## Journal` 章节内（不另开文件，避免 AC11 允许清单外的新路径）

### 10.3 🆕 Sub-Agent使用建议
- [ ] **general-purpose / Explore** — 抽样轨迹的 bundle 重建可并行 fan-out（每 agent 3-4 条）
- [ ] **data-analyst** — Phase C 打分前可让其独立 review rubric 锚点的区分度

---

## 11. 🆕 Learning Content

### 11.1 Decision Rationale: 审计先于 Rubric

**选择的方案**：Phase A（审计）→ Phase B（rubric）→ Phase C（golden set）严格顺序

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 审计先行（选中）| rubric 每维保证有数据支撑 | 慢半步 | ✅ 选中 |
| 直接设计 rubric | 快 | 可能定义出喂不了数据的维度（风险 #2） | Measure Before Optimizing 的直接应用 |
| 先改 trace schema 再设计 | 数据最全 | 在证明需要之前就动采集层 | 违反最小增量约束 |

**💡 Human学习点**：测量系统自身也要先测量（数据够不够）再设计（尺子长什么样）。

---

## 12. 🆕 Sub-Agent使用记录
(Blake完成后填写)

---

## Required Evidence Manifest

```yaml
required_evidence:
  completion: ".tad/active/handoffs/COMPLETION-20260702-trajectory-eval-p1.md"
  audit_report: ".tad/evidence/designs/trajectory-data-audit.md"
  rubric: ".tad/eval/rubric.md"
  golden_set_index: ".tad/eval/golden-set/INDEX.md"
  golden_set_files: ".tad/eval/golden-set/GS-*.md (>=10)"
  blind_pack: ".tad/eval/golden-set/BLIND-PACK.md"
  git_baseline: ".tad/evidence/designs/trajectory-eval-p1-git-baseline.txt"
  blake_layer2_reviews: ".tad/evidence/reviews/blake/trajectory-eval-p1/{reviewer}.md (>=2 distinct)"
  knowledge_updates: "journal entry OR explicit 'no discovery' in completion report"
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-02
**Version**: 3.1.0
