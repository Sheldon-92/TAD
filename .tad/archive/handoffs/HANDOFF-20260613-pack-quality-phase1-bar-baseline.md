---
task_type: research
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta:
  - field: "§2.1 / AC8 (no-fixture pack count)"
    alex_said: "handoff 假设只有 1 个无 fixture 包"
    actual: "实扫为 2 个(ml-training + ai-podcast-production);Alex 的 '26 fixtures 跨 23 包' 把非目标包 research-methodology 误算进 23,漏数 1"
    caught_by: "Blake MQ1 re-scan + Alex Gate 4 独立 per-pack find 重算确认"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-13
**Project:** TAD Framework
**Task ID:** TASK-20260613-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260613-capability-pack-quality-leveling.md (Phase 1/6)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-13(专家审查后)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三块工作(1a 元设计研究 / 1b 内部金标准 / 1c 基线审计)边界清晰 |
| Components Specified | ✅ | 两份产物 QUALITY-BAR.md + BASELINE-AUDIT.md 结构已规定(含双层判别保证) |
| Functions Verified | ✅ | 引用的现有工具(pack-eval-runner.sh / capability-upgrade SKILL)已 grounding 确认存在 |
| Data Flow Mapped | ✅ | 输入(24 包 + 现有 fixtures + 方法论)→ 输出(rubric + 审计 + 批次分组)已映射 |
| Expert Review | ✅ | 2 专家(code-reviewer + backend-architect),2 P0 + 全部 P1 已 Resolved(见 §9.2) |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素 + 整合两位专家全部 P0/P1,Blake 可独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)
- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图(不只是字面需求)
- [ ] 每个 Phase 的交付物和证据要求都清楚

---

## 1. Task Overview

### 1.1 What We're Building
本任务是 Epic「能力包质量拉齐」的 **Phase 1:定尺 + 基线审计**。产出两把"高水平"的尺,
并用它们量一遍全部 24 个能力包的现状——为后续 4 个升级批次提供方向和分组依据。

### 1.2 Why We're Building It
**业务价值**:"把 24 个包拉到同样高水平"在没有统一尺和基线之前是无方向的蛮力。先量基线,
才能只升级真正拖后腿的、把高价值的前置。
**用户受益**:用户(及其朋友)在任何项目里加载这些包时,得到的是一致的高质量判断规则。
**成功的样子**:有一份双层 rubric + 一张 24 包质量分布表 + 4 批分组,Phase 2 可以直接开干。

### 1.3 Intent Statement(意图声明）

**真正要解决的问题**:为"质量拉齐"建立**可判别的**质量标准 + 现状基线,而不是凭感觉升级。

**不是要做的(避免误解)**:
- ❌ 不是在本 Phase 修改任何 pack 的 SKILL.md 内容(升级在 Phase 2-5)
- ❌ 不是造一个新的评估引擎(必须复用现有 pack-eval-runner.sh 的 discriminative_pattern 机制)
- ❌ 不是做结构性勾选式审计("文件存在/字数够"= validation theater,明确禁止)

**Blake 请确认理解**:开始前用自己的话回答 (1) 这个 Phase 解决什么问题 (2) 两份产物各是什么
(3) 为什么 rubric 必须是判别式的。Human 确认后再开始。

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ** — Blake 开始前必须 Read:
1. `.tad/project-knowledge/principles.md`(L1,尤其 validation-theater 相关条目)
2. `.tad/project-knowledge/patterns/pack-evaluation.md`
3. `.tad/project-knowledge/patterns/pack-build-rules.md`

### 步骤 1：识别相关类别
- [x] pack-evaluation - 行为评估 / 判别式 gate / 跨模型审查
- [x] pack-build-rules - pack 架构 / 结构规范 / 关键词策划
- [x] architecture - 方法论结构合理性

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| pack-evaluation.md | 4+ | 判别式 gate 必须用独立 discriminative_pattern;negative control 必须 FAIL;跨模型审查抓 same-model 盲区 |
| pack-build-rules.md | 8+ | pack 架构三模式;YAML frontmatter 是 load-bearing;rule sourcing 必须读原始源 |
| principles.md | 1 | YOLO 审计:validation theater(结构检查 ≠ 行为质量) |

**⚠️ Blake 必须注意的历史教训**:

1. **Behavioral-Eval Gate Must Run on SEPARATE Discriminative Field** (来自 pack-evaluation.md)
   - 问题:把 PASS 口径建在"混了通用 marker 的合并计数"上 → negative control(不加 pack)也能 PASS = 纯 validation theater
   - 解决方案:rubric 的判别维度必须用 ONLY pack-specific 的 discriminative_pattern;用 negative control 证明它会 FAIL

2. **Cross-Model Adversarial Review Catches a Defect Class Same-Model Review Misses** (来自 pack-evaluation.md)
   - 问题:全 Claude 自审会系统性漏掉事实/API 错误(类名、弃用 API、metric 类型)
   - 解决方案:本 Phase 的 rubric 必须把"跨模型对抗审查"列为后续每批的 DoD;但 reviewer 本身也会错,需对版本敏感断言查原始文档

3. **Never Hand-Write What an Existing Tool Already Does** (来自 principles.md)
   - 问题:绕过现成工具从记忆重写 → 不完整
   - 解决方案:基线审计的评估必须调用现有 `pack-eval-runner.sh`,不重造评分逻辑

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解 validation-theater 是头号风险

---

## 2. Background Context

### 2.1 Previous Work
- YAML domain pack 已于 2026-06-11 全部退役,24 个能力包现为 `.claude/skills/{pack}/SKILL.md`。
- 已有判别式评估工具 `.tad/scripts/pack-eval-runner.sh`(discriminative_pattern + min_discriminative + negative control 机制)。
- 已有 26 个 fixtures 跨 23 个包(`.claude/skills/*/examples/*.md`)——即 **1 个包没有 fixture**,基线须标出。
- 已有升级方法论 `.claude/skills/capability-upgrade/SKILL.md`(5 阶段:评估→GitHub-First 研究→设计→构建→验证)。

### 2.2 Current State — 24 个能力包清单
```
academic-research  agent-memory  agent-orchestration  ai-agent-architecture
ai-evaluation  ai-guardrails  ai-podcast-production  ai-prompt-engineering
ai-tool-integration  ai-voice-production  code-security  data-engineering
knowledge-graph  llm-observability  ml-training  product-thinking
rag-retrieval  synthetic-data  video-creation  web-backend
web-deployment  web-frontend  web-testing  web-ui-design
```
内部金标准(领域深度对标):`web-ui-design` / `web-frontend` / `web-backend`(最成熟,含 checklist + 验证脚本)。

### 2.3 Dependencies
- research-github / research-notebook(元设计研究持久化)。
- 可能需要 Codex/Gemini CLI(跨模型视角;⚠️ 本 Phase 仅"参考开源",真正的跨模型对抗审查是 Phase 2-5 的 DoD)。

---

## 3. Requirements

### 3.1 Functional Requirements
- **FR1 (1a 元设计研究)**:调研最好的开源 skill 库怎么"组织"一个 skill——研究对象至少包含
  Anthropic 官方 skills(claude skills / frontend-design SKILL 等)+ 1-2 个社区 awesome-skills 集合。
  提炼成一份**元设计结构 checklist**(格式、渐进披露、example/fixture 约定、frontmatter 约定、
  judgment-vs-orchestration 分离)。研究经 research-github/notebook 持久化,findings 附 source URL + 检索日期。
- **FR2 (1b 内部金标准)**:从 web-ui-design / web-frontend / web-backend 提炼**领域深度评分维度**
  (规则具体度、tool 时效性、quality_criteria 可操作性、anti-pattern 覆盖、CONSUMES/PRODUCES 契约等)。
- **FR3 (1c 基线审计)**:用统一 rubric(FR1 checklist + FR2 维度 + 现有 pack-eval-runner.sh 判别式 gate)
  逐个量 24 个包,产出质量分布表 + 每包 gap 清单 + 弱→强 4 批分组(每批 6),并回填 Epic Phase Map。
- **FR4 (产物落地)**:`QUALITY-BAR.md` + `BASELINE-AUDIT.md` 写入 `.tad/evidence/pack-quality/`。

### 3.2 Non-Functional Requirements
- **NFR1 (Layer A 判别性)**:QUALITY-BAR.md 的元设计 checklist 必须带至少一个 negative control 证明它能判别——
  对一个故意劣质的结构样例打分必须 FAIL/低分。否则该尺无效。
- **NFR2 (可审计)**:元设计研究 findings 必须附 source URL + 检索日期(过往教训:无来源 = 不可验证)。
  findings 的解析路径必须回写到一个**固定锚点**(`.tad/evidence/pack-quality/QUALITY-BAR.md` 内的 `## Sources` 段),
  使来源可在 Gate 3 被独立重跑核对(code-review P1-3:不能让来源路径浮动到只能 Blake 自报)。
- **NFR3 (不重造)**:评估口径引用现有 discriminative_pattern 机制,不另写评分逻辑。
- **NFR4 (Layer B 判别性 — ⚠️ P0-1 修复,arch review)**:Layer B 领域深度尺**也**必须可判别,不能只给
  "gold-standard=5"的单端锚点(可刷分)。必须:
  (a) 给出 **0/2/5 三档操作化锚点**:0-2 = 规则可被前沿 LLM 无研究即复述出来;5 = 规则携带研究落地的
      具体数字/阈值(对标 pack-evaluation 2026-05-15 的 specific-threshold 信号,如 n≥550 / exit 183 / ICC>0.92);
  (b) 设一个 **Layer B negative control**:对故意浅薄的领域样例打分必须 ≤2(与 NFR1 对称);
  (c) 把"具体阈值计数"作为 Layer B 的一个**可计数子维度**,而非纯 LLM gestalt。

---

## 4. Technical Design

### 4.1 QUALITY-BAR.md 结构
```
# Capability Pack Quality Bar (双层尺)
## 分层归属规则 (⚠️ arch P1-3:防双重计分)
   每条判据只归属一个层。三层/三列分别度量 结构 / 深度 / 行为,不得共享同一判据。
   - CONSUMES/PRODUCES 契约 → 归 Layer A(结构),不在 Layer B 重复计。
   - fixture 是否存在 → Layer A 结构项;它启用的 discriminative 结果 → 独立的行为子分;审计表里的列只是展示 flag(同一事实不得灌 3 个数)。
## Layer A — 元设计/结构 checklist  (来自 FR1 开源研究)
   每条:判据 + 如何验证 + negative-control 示例
## Layer B — 领域深度评分维度  (来自 FR2 内部金标准)
   每维度:0/2/5 操作化锚点(见 NFR4):
     0-2 = 规则可被前沿 LLM 无研究即复述;5 = 携带研究落地的具体数字/阈值
   含一个可计数子维度:specific-threshold 计数。
## 判别式 gate 接入
   说明每个包如何用 pack-eval-runner.sh 的 discriminative_pattern 验证(引用,不重造)
## Negative Control 证明 (两个,对称)
   - Layer A:对劣质结构样例打分 → 必须 FAIL,贴实际评分输出(不是只出现"negative control"字样)
   - Layer B:对故意浅薄的领域样例打分 → 必须 ≤2,贴实际评分输出
## Sources (NFR2 固定锚点)
   元设计研究每条 finding 的 source URL + 检索日期(Gate 3 在此重跑核对)
## ⚠️ Phase 2-5 DoD 备注 (arch S3 前置)
   跨模型对抗审查:NEVER 盲信 reviewer 的 P0——对版本敏感断言(API 名/版本号/弃用/metric 类型)
   先查当前原始文档;预算 ~2/N 的 reviewer 自身会错。
```

### 4.2 BASELINE-AUDIT.md 结构
```
# Baseline Audit — 24 packs
## 质量分布表
| pack | Layer A 结构分 | Layer B 深度分 | discriminative 结果 | 有无 fixture | 置信度 | 综合档 | 主要 gap |
（24 行；无 fixture 的包"置信度"标 LOW——其分仅来自两个软层,无客观行为分量）
## 批次分组（弱→强）
| 批次 | packs | 共同 gap 主题 |
- ⚠️ 不硬钉 6/6/6/6(arch S4 + principles "never pin a count"):允许不均匀批次。
  目标 4 批,但若某些包已达标可不进升级批/某批可多可少——按实际 gap 分,不为凑数强切。
- ⚠️ 无 fixture 的那个包:无论软层分多少,**自动进最弱批(Batch 1)**,因为"缺 fixture"本身
  就是必须在该批补的 Phase-2 交付物(P0-2 修复:用排名规则关闭盲点,而非"标注后照排")。
- ⚠️ 边界包说明(arch P1-1):对落在批次切分线上的包,各写 1 行理由引用其具体 gap
  (单 LLM 打分在决策边界最易错,自证理由近零成本地兜住最关键的误排)。
## 批次可重排声明 (arch P1-1)
  批次成员是 advisory,直到该批开工前都可重排;误排在每批入口重新打分时纠正,不在 Phase 1 冻结。
## 回填动作
（把分组写回 EPIC Phase Map 的 Phase 2-5）
```

### 4.3 评估方法
- Layer A:逐包对 SKILL.md 结构按 checklist 打分(LLM 判断 + 可 grep 的结构特征)。
- Layer B:逐包对内容深度按 0/2/5 操作化锚点打分(NFR4),含 specific-threshold 可计数子维度;
  以 3 个 gold-standard 包为 5 分锚点,但 0-2 档由"可否被 LLM 无研究复述"操作化界定。
- 判别式:对有 fixture 的包跑 `pack-eval-runner.sh` 取 discriminative 结果作为客观分量;
  无 fixture 的包 discriminative 列标 N/A、置信度 LOW,并按 §4.2 规则自动进 Batch 1。

---

## 5. 强制问题回答（Evidence Required)
- **MQ1 历史代码搜索**: 是 → 已在 §2.1 列明现有工具/fixtures/方法论,Blake 须实际 Read 后引用,不得凭印象。
- **MQ2-MQ5**: N/A(本 Phase 不写代码/不涉及前端状态/数据流;产物是研究+审计文档)。

---

## 6. Implementation Steps（分 Phase）

> 本 handoff 即 Epic 的 Phase 1。下面是 Phase 1 内部的执行步骤。

> ⚠️ 写文件前先 `mkdir -p .tad/evidence/pack-quality/`(目录尚不存在,否则首次写入失败)。
> ⚠️ §4.2 的批次分组必须用 token `批次 N`(数字前有空格)或 `Batch N`,与 AC4 校验一致。

### Step 1: 元设计研究 (FR1)（预计 1-1.5h）
#### 交付物
- [ ] 元设计结构 checklist(QUALITY-BAR.md 的 Layer A)
- [ ] research findings 持久化(research-github/notebook),每条附 source URL + 日期
#### 实施步骤
1. 用 research-github / research-notebook 调研 Anthropic 官方 skills 组织方式 + 1-2 个 awesome-skills 集合。
2. 提炼"高水平 skill 的结构特征"为 checklist,每条给出判据 + 验证方式。
3. 构造一个**故意劣质**的结构样例,用 checklist 打分证明会 FAIL(negative control)。

### Step 2: 内部金标准提炼 (FR2)（预计 0.5-1h）
#### 交付物
- [ ] Layer B 领域深度评分维度(0-5 锚点,以 web-ui-design/frontend/backend 为 5 分)
#### 实施步骤
1. Read 3 个 gold-standard 包的 SKILL.md,提炼它们"深"在哪。
2. 把这些特征转成可打分的维度 + 锚点。

### Step 3: 基线审计 (FR3)（预计 1.5-2h）
#### 交付物
- [ ] BASELINE-AUDIT.md(24 包质量分布表 + gap + 批次分组)
- [ ] Epic Phase Map 回填批次成员
#### 实施步骤
1. 逐包按 Layer A + Layer B 打分;有 fixture 的包跑 pack-eval-runner.sh 取判别分量。
2. 汇成分布表,标注每包主要 gap + 是否缺 fixture。
3. 按综合分弱→强排序,分 4 批 × 6,写回 Epic Phase Map 的 Phase 2-5。

#### 验证方法
- 运行 §9.1 的 AC 命令,产物存在且覆盖 24 包、含 negative control、含 4 批分组。

**Human 决策**:✅ 接受 → Phase 2 开干 / ⚠️ 调整尺或分组

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/pack-quality/QUALITY-BAR.md       # 双层 rubric + negative control
.tad/evidence/pack-quality/BASELINE-AUDIT.md    # 24 包审计 + 批次分组
```
（research findings 由 research-github/notebook 写入其既有目录,路径由该工具决定)

### 7.2 Files to Modify
```
.tad/active/epics/EPIC-20260613-capability-pack-quality-leveling.md  # 回填 Phase 2-5 批次成员
```

### 7.3 Grounded Against (Alex step1c, 2026-06-13)
- `.tad/scripts/pack-eval-runner.sh` (head 15 + ls, read at 2026-06-13 — 确认存在,12613 bytes,discriminative 引擎)
- `.claude/skills/capability-upgrade/SKILL.md` (grep 阶段结构, read at 2026-06-13 — 确认 5 阶段流程存在)
- `.tad/project-knowledge/patterns/pack-evaluation.md` (head 26, read at 2026-06-13 — 确认判别式 gate + 跨模型审查教训)
- `.tad/project-knowledge/patterns/pack-build-rules.md` (head 40, read at 2026-06-13 — 确认架构三模式 + frontmatter load-bearing)
- 24 包 SKILL.md (全部确认存在,见 §2.2)
- `.tad/evidence/pack-quality/QUALITY-BAR.md` (new — will be created)
- `.tad/evidence/pack-quality/BASELINE-AUDIT.md` (new — will be created)

---

## 8. Testing Requirements

### 8.1 / 8.2 / 8.3
N/A(研究+审计文档,无单元/集成测试;验证靠 §9.1 + Human 对 rubric 判别性的确认)。

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| 网络访问(调研开源 repo) | research-github/notebook 联网拉取 | 请求 sandbox/permission 批准 | 离线已知信息 + 标注"未联网核实" = DEGRADED_WITH_APPROVAL | 未解决 BLOCKED → 不能 Gate 3 PASS(FR1 的 source URL 要求无法满足) |
| research-notebook 工具可用性 | 调用 NotebookLM CLI | 检查 tool-quick-reference;不可用则请求安装/配置 | 直接 WebSearch + 手记 findings(EQUIVALENT_SUBSTITUTE,需仍附 URL+日期) | 缺 findings 来源 → NFR2 不满足 |
| pack-eval-runner.sh 跑某包报错 | 对有 fixture 的包跑判别式评估 | 修复 fixture 路径/参数;按 SAFETY header 该工具不 fail-closed | 该包标注"判别分量缺失,仅 LLM 结构/深度分" = NOT_APPLICABLE_WITH_REASON | 不阻塞(工具本就 advisory),但须在审计中显式标注 |

**Status Enum**: `READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

## 8.5 Feedback Collection
N/A(产物是内部方法论文档,非面向用户的 artifact)。

---

## 9. Acceptance Criteria
- [ ] 两份产物落地且覆盖 24 包
- [ ] QUALITY-BAR.md 含 negative control 证明判别性
- [ ] 批次分组回填 Epic
- [ ] research findings 附 source URL + 日期

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | 两份产物存在 | post-impl-verifiable | `test -f .tad/evidence/pack-quality/QUALITY-BAR.md && test -f .tad/evidence/pack-quality/BASELINE-AUDIT.md && echo OK` | `OK` (exit 0) | (post-impl) — syntax OK |
| AC2 | 基线覆盖全部 24 包,**且每包在带评分的表行里**(code P1-2:绑评分行,杜绝粘 §2.2 名单刷分) | post-impl-verifiable | 统计同时含 pack 名 + 数字评分的表行去重数:`grep -E '^\|[^\|]*(academic-research\|agent-memory\|agent-orchestration\|ai-agent-architecture\|ai-evaluation\|ai-guardrails\|ai-podcast-production\|ai-prompt-engineering\|ai-tool-integration\|ai-voice-production\|code-security\|data-engineering\|knowledge-graph\|llm-observability\|ml-training\|product-thinking\|rag-retrieval\|synthetic-data\|video-creation\|web-backend\|web-deployment\|web-frontend\|web-testing\|web-ui-design)[^\|]*\|.*[0-9]' .tad/evidence/pack-quality/BASELINE-AUDIT.md \| grep -oE 'academic-research\|agent-memory\|agent-orchestration\|ai-agent-architecture\|ai-evaluation\|ai-guardrails\|ai-podcast-production\|ai-prompt-engineering\|ai-tool-integration\|ai-voice-production\|code-security\|data-engineering\|knowledge-graph\|llm-observability\|ml-training\|product-thinking\|rag-retrieval\|synthetic-data\|video-creation\|web-backend\|web-deployment\|web-frontend\|web-testing\|web-ui-design' \| sort -u \| wc -l` | `24` | (post-impl) — raw alternation syntax validated; 实跑用裸 `|` |
| AC3 | Layer A negative control 真跑出 FAIL(code S1/arch S1:不只查字样,要有实际低分/FAIL verdict) | post-impl-verifiable | `grep -iE 'negative control' .tad/evidence/pack-quality/QUALITY-BAR.md && grep -iE 'FAIL\|≤ ?2\|低分\|0/[0-9]' .tad/evidence/pack-quality/QUALITY-BAR.md` | 两段都命中(有 negative control 段 + 实际 FAIL/低分 verdict) | (post-impl) — ERE, bare pipe when run |
| AC4 | 批次分组存在(≥3 批,允许不均匀;arch S4) | post-impl-verifiable | `grep -cE '批次 ?[1-4]\|Batch [1-4]' .tad/evidence/pack-quality/BASELINE-AUDIT.md` | `>= 3` | (post-impl) — `批次 ?` 空格可选,修 code P1-1 |
| AC5 | 复用现有判别式机制(引用 pack-eval-runner.sh / discriminative_pattern) | post-impl-verifiable | `grep -cE 'pack-eval-runner\|discriminative_pattern' .tad/evidence/pack-quality/QUALITY-BAR.md` | `>= 1` | (post-impl) |
| AC6 | research findings 附来源,**写入固定锚点 QUALITY-BAR.md ## Sources**(code P1-3:不浮动) | post-impl-verifiable | `grep -c 'http' .tad/evidence/pack-quality/QUALITY-BAR.md` | `>= 1` | (post-impl) — 固定路径,Gate 3 可独立重跑 |
| AC7 | Layer B 存在且可判别(code P2-1/arch S2:覆盖 FR2;Layer B negative control ≤2) | post-impl-verifiable | `grep -ciE 'Layer B' .tad/evidence/pack-quality/QUALITY-BAR.md && grep -iE 'web-ui-design\|web-frontend\|web-backend' .tad/evidence/pack-quality/QUALITY-BAR.md` | Layer B 段存在 + 3 个 gold-standard 包被引为锚点 | (post-impl) |
| AC8 | 无 fixture 的包被标 LOW 置信度且进 Batch 1(P0-2) | post-impl-verifiable | `grep -iE 'LOW\|低置信\|无 ?fixture\|missing fixture' .tad/evidence/pack-quality/BASELINE-AUDIT.md` | `>= 1`(显式标记) | (post-impl) |

> Pipe-escape note: 表格里 `\|` 是 markdown 渲染需要;实跑时一律用裸 `|`(step1d 已从 raw form dry-run 过 alternation/空格可选/scored-row 形态)。

## 9.2 Expert Review Status (Alex 必填 — 审查后填)

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0-1: Layer B 无判别保证,"gold-standard=5"单端锚点可刷分 | NFR4 + §4.1 Layer B(0/2/5 锚点 + Layer B negative control)+ AC7 | Resolved |
| backend-architect | P0-2: 无 fixture 包是测量盲点,软层分排名无置信标记 | §4.2(自动进 Batch 1 + 置信度 LOW)+ §4.3 + AC8 | Resolved |
| backend-architect | P1-1: 单 LLM 排名风险 → 批次须可重排 + 边界包自证 | §4.2(可重排声明 + 边界包说明) | Resolved |
| backend-architect | P1-3: Layer A/B + fixture 列双重计分风险 | §4.1 分层归属规则 | Resolved |
| backend-architect | S1/S3: AC3 只查字样;跨模型"verify the reviewer"未前置 | AC3 改为要 FAIL verdict + §4.1 Phase2-5 DoD 备注 | Resolved |
| code-reviewer | P1-1: AC4 空格敏感(批次1 无空格→误失败) | AC4 `批次 ?[1-4]` + §6 token 提示 | Resolved |
| code-reviewer | P1-2: AC2 可粘 §2.2 名单刷分(validation theater) | AC2 改为绑"含评分的表行" | Resolved |
| code-reviewer | P1-3: AC6 路径浮动,Gate 3 不可独立重跑 | NFR2 固定锚点 + AC6 改查 QUALITY-BAR.md ## Sources | Resolved |
| code-reviewer | P2-1: FR2(Layer B)无覆盖 AC | 新增 AC7 | Resolved |
| code-reviewer | P2: 首次写入需 mkdir -p;§7.3 列了待建文件 | §6 加 mkdir 提示;§7.3 待建文件保留但标注 new | Resolved |
| code-reviewer | S4: 硬钉 6/6/6/6 与 "never pin a count" 冲突 | §4.2 允许不均匀批次;AC4 改 ≥3 | Resolved |

### Experts Selected
1. **code-reviewer** — 验证 AC 命令可跑、§9.1 verification 无 shell/grep 陷阱、产物结构自洽
2. **backend-architect** — 验证审计方法论的结构合理性 + validation-theater 风险(rubric 是否真判别)

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 全部 3 P1 + 关键 P2 已整合(0 P0)
- backend-architect: CONDITIONAL PASS → 2 P0 + 全部 P1 已整合
- **整合后**:两个 P0(Layer B 判别 + fixture 盲点)均已结构性解决并加了对应 AC(AC7/AC8)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **validation theater 是头号风险**:rubric 若只查"文件存在/字数",则"全部通过"毫无意义。
  Layer A checklist 必须有 negative control,Layer B 必须有对比锚点。
- ⚠️ **不重造评分逻辑**:判别分量来自现有 pack-eval-runner.sh。
- ⚠️ **本 Phase 不改任何 pack 内容**——只研究、只审计、只产出尺和分组。

### 10.2 Known Constraints
- 元设计研究须经 research-github/notebook 持久化(CLAUDE.md 路由:深度研究 → research-notebook;不要用一次性 WebSearch 替代,除非工具不可用并标注)。
- 跨模型对抗审查是 Phase 2-5 每批的 DoD,不在本 Phase(本 Phase 仅"参考开源")。

### 10.3 Sub-Agent 使用建议
- [ ] research workflow(元设计调研)
- [ ] 可考虑并行读 24 包做基线打分(但打分口径须统一)

---

## 11. Learning Content

### 11.1 Decision Rationale: 为什么先定尺+基线,而不是直接升级
**选择的方案**:Phase 1 = 纯研究+审计,不动 pack。
**替代方案**:

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 先定尺+基线（选中）| 有方向、能只升级弱的、可量化提升 | 多一个前置 Phase | ✅ 选中 |
| 直接逐个升级 | 立刻动手 | 无统一标准 → 升级后仍参差;在不需大改的包上浪费 | 蛮力 |

**💡 Human 学习点**:"拉到同样高水平"是个相对目标——没有"尺"和"现状",就无法定义"齐"。

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-13
**Version**: 3.1.0
