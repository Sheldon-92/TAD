# Handoff: TAD v2.8 Phase 4 — Human Approval Workflow

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-018
**Epic:** EPIC-20260402-tad-v28-self-evolving.md (Phase 4/5)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. What We're Building

*optimize 提议改进后，需要一个标准化的人审批 + 变更应用工作流。这个 Phase 构建审批的基础设施 — 提议存储格式、展示方式、应用机制。

## 2. 必读

- `.tad/active/handoffs/HANDOFF-20260402-tad-v28-project-analyzer.md` — Phase 2 的 *optimize 设计
- `.tad/spike-v3/domain-pack-tools/v28-research-synthesis.md` — EvoAgentX experience JSON 格式

## 3. Technical Design

### 3.1 提议存储格式

*optimize 生成的提议存在 `.tad/evidence/proposals/` 目录下：

```
.tad/evidence/proposals/
├── PROPOSAL-20260402-001.yaml    # 单个提议
├── PROPOSAL-20260402-002.yaml
└── ...
```

每个提议文件：
```yaml
proposal_id: "PROPOSAL-20260402-001"
created: "2026-04-02T15:30:00Z"
status: "pending"  # pending | accepted | rejected | modified

target:
  file: ".tad/domains/product-definition.yaml"
  capability: "competitive_analysis"
  section: "quality_criteria"

change:
  type: "tighten_criteria"  # tighten_criteria | add_step | add_anti_pattern | fix_step
  current: "≥5 competitors found"
  proposed: "≥5 competitors with real pricing data from official websites"
  diff: |
    - "≥5 competitors found"
    + "≥5 competitors with real pricing data from official websites"

evidence:
  trace_count: 5
  failure_pattern: "3/5 runs had competitors without pricing data"
  trace_refs:
    - "2026-04-02.jsonl:line3"
    - "2026-04-02.jsonl:line7"
  confidence: 0.8

review:
  reviewed_at: null
  reviewer: null
  decision: null
  notes: null
```

### 3.2 审批展示（AskUserQuestion）

*optimize 的 step4 用 AskUserQuestion 展示提议：

```
Alex: "基于 5 次执行 trace，建议修改 product-definition.yaml:"

  目标: competitive_analysis → quality_criteria
  当前: "≥5 competitors found"
  建议: "≥5 competitors with real pricing data from official websites"
  证据: "3/5 次执行中竞品缺少定价数据"
  置信度: 0.8

  选项:
  1. 接受 — 直接应用修改
  2. 修改后接受 — 你调整措辞后应用
  3. 拒绝 — 不修改
  4. 稍后处理 — 保留提议，下次再看
```

### 3.3 变更应用机制

接受后的应用流程：

```
接受 → 读取 target file（domain.yaml）
     → 定位 section（capability → quality_criteria）
     → 替换 current → proposed
     → 写入文件
     → 更新 PROPOSAL status → "accepted"
     → Git commit（"optimize: {proposal_id} applied"）
```

**不自动应用** — Alex 执行应用（Edit 工具），不是脚本自动改。这保留了人的审查环节。

### 3.4 安全约束

提议不能修改以下内容（硬保护）：
- `"编造数据 = FAIL"` 类的核心约束（不能被弱化）
- `reviewers` 的 persona（不能删除审查角色）
- `tool_ref`（不能改工具引用，可能导致链路断裂）

**安全检查必须独立于提议生成** — 不能让生成者自评 safe/unsafe。实现方式：

```bash
# 受保护关键词列表（硬编码，不可被提议修改）
PROTECTED_PATTERNS=(
  "编造.*FAIL"
  "fabricat.*FAIL"
  "MANDATORY"
  "VIOLATION"
  "编造数据"
)
```

应用变更前，对 proposed 内容做正则检查：
- 如果提议**删除**包含受保护关键词的条目 → BLOCK + 警告
- 如果提议**弱化**受保护条目（如 "FAIL" → "WARNING"）→ BLOCK + 警告
- 其他提议 → 正常审批流程

## 4. Implementation Steps

### Step 1: 创建提议目录结构
```bash
mkdir -p .tad/evidence/proposals
```

### Step 2: 在 Alex SKILL.md 中定义提议格式

在 *optimize 的 step3（生成提议）中，定义提议文件的写入格式。

### Step 3: 在 *optimize 的 step4 中实现审批展示

用 AskUserQuestion 按 3.2 的格式展示。

### Step 4: 在 *optimize 的 step5 中实现变更应用

接受后用 Edit 工具修改 domain.yaml，更新 PROPOSAL 状态。

### Step 5: 安全约束检查

在生成提议时，检查是否触碰受保护的内容。标注 safe 标志。

## 5. AC

- [ ] AC1: `.tad/evidence/proposals/` 目录可创建
- [ ] AC2: 提议 YAML 格式正确（有 proposal_id, target, change, evidence, review）
- [ ] AC3: *optimize step4 用 AskUserQuestion 展示提议（4 选项）
- [ ] AC4: "接受"后正确修改 domain.yaml
- [ ] AC5: 提议状态更新（pending → accepted/rejected）
- [ ] AC6: 安全约束：不能弱化"编造=FAIL"类核心条款
- [ ] AC7: 变更有 git commit 记录
- [ ] AC8: 必须走 Ralph Loop + Gate 3

## 6. Notes

- ⚠️ 这个 Phase 和 Phase 2 并行 — Phase 2 做分析生成提议，Phase 4 做审批应用
- ⚠️ 两个 Phase 的接口是 PROPOSAL YAML 文件 — Phase 2 的 *optimize step3 写入 PROPOSAL 文件后，step4 立即读取并展示审批（同一个命令内顺序执行，不需要跨 Phase 同步信号）
- ⚠️ Alex 执行变更应用（Edit 工具），不是脚本自动改
- ⚠️ 核心约束（编造=FAIL）不可被自动提议弱化

**Handoff Created By**: Alex
