---
task_type: research
e2e_required: no
research_required: yes
---

# Handoff: OpenHarness 参考架构文档持久化

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-008
**Epic:** EPIC-20260403-openharness-agent-architecture-upgrade.md (Phase 1/3)

---

## Expert Review Status

| Expert | Focus | P0 | P1 | P2 | Result |
|--------|-------|----|----|----|----|
| code-reviewer | 任务清晰度、AC 可验证性、验证脚本 | 2 (fixed) | 4 (fixed) | 3 | CONDITIONAL PASS → PASS |
| docs-writer | 文档结构、可复用性、内容规格 | 2 (fixed) | 4 (fixed) | 3 | CONDITIONAL PASS → PASS |

**P0 修复摘要：**
- P0-1: 新增 Module Scope 章节（Section 2.3），列出 17 个排除模块 + 原因 + Other Modules 附录要求
- P0-2: Agent Design Guidelines 展开为 G1-G8+ 具名建议结构（Pattern / When to use / TAD implication）
- P0-3: grep 验证命令全部改为 `^## ` 精确匹配，新增代码块真实性抽查
- P1-1~4: 新增子系统统一模板（4.2）、映射表示例行、Key Metrics 模板、步骤 0 研究笔记读取、语言规范

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
一份结构化的 OpenHarness 架构参考文档（`.tad/references/openharness-architecture.md`），持久化已完成的深度研究结果，供后续所有 agent 设计项目引用。

### 1.2 Why We're Building It
- 研究结果目前只在对话 context 中，新会话无法访问
- Phase 2（Domain Pack YAML 迭代）需要引用此文档
- 所有后续 agent 设计任务都能直接 `参考 .tad/references/openharness-architecture.md`

### 1.3 Intent Statement
**真正要解决的问题**：OpenHarness 架构洞察需要持久化为可复用文档

**不是要做的**：
- ❌ 不是写代码或修改 YAML
- ❌ 不是翻译 OpenHarness 的 README
- ❌ 不是逐行代码注释——是架构模式提炼

---

## 📚 Project Knowledge

### 步骤 1：识别相关类别
- [x] architecture — 架构决策

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 1 条 | "Domain Pack Research: Workflow Steps > Quality Criteria Text" — 新 step 比文字 criteria 更有价值 |

**⚠️ Blake 必须注意的历史教训**：
1. **Workflow Steps > Quality Criteria Text** (来自 architecture.md)
   - 问题：第一轮只加文字标准，价值有限
   - 解决方案：提炼可操作的设计模式（代码模式 + 量化标准），而不只是描述性文字

---

## 2. Background Context

### 2.1 Previous Work
- OpenHarness 已 clone 到 `/Users/sheldonzhao/01-on progress programs/OpenHarness/`
- 10 个子系统已通过 Explore agent 完成深度研究
- 用户研究笔记：`/Users/sheldonzhao/01-on progress programs/thoughts/discoveries/2026-04-03-openharness-final.md`

### 2.2 Current State
研究结果在用户研究笔记 + OpenHarness 源码中 → 需要持久化到 `.tad/references/`

### 2.3 Module Scope（⚠️ 重要）
OpenHarness 有 27 个顶层模块，本文档聚焦 **10 个核心 Harness 子系统**。
排除的模块及原因：
- `api` — 封装 Anthropic SDK，是实现细节不是架构模式
- `bridge` — UI 通信桥接，TAD 不需要
- `commands` — CLI 命令路由，与 agent 架构无关
- `mcp` — MCP 客户端，TAD 已有 MCP 支持
- `keybindings`, `vim`, `voice` — 输入方式，非 Harness 核心
- `output_styles`, `ui` — 输出渲染，非 Harness 核心
- `plugins` — 插件加载器，可在 Config 章节简要提及
- `services` — 内部服务胶水，非独立子系统
- `state` — 应用状态存储，可在 Memory 章节简要提及
- `types`, `utils` — 工具类型，非架构层

Blake 应在文档末尾加一个 "Other Modules" 附录，一句话列出这些排除模块。

### 2.4 Dependencies
- OpenHarness repo 在本地可读

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 创建 `.tad/references/openharness-architecture.md`，≥300 行
- FR2: 覆盖全部 10 个核心子系统（Engine, Tools, Permissions, Hooks, Skills, Coordinator, Memory, Tasks, Prompts, Config）+ Other Modules 附录
- FR3: 每个子系统使用统一模板（见 4.2 子系统模板）
- FR3b: 文档语言：正文中文，技术术语/类名/代码保留英文原文
- FR4: 包含"与 TAD 映射关系"表（10 行）
- FR5: 包含"Agent 设计指导"章节（可被 Domain Pack steps 引用的具体建议）

### 3.2 Non-Functional Requirements
- NFR1: 文档结构适合被 Domain Pack 的 steps 通过路径引用
- NFR2: 代码模式用 Python 代码块展示（来自真实源码，不是伪代码）

---

## 4. Technical Design

### 4.1 文档结构

```markdown
# OpenHarness Architecture Reference
> Source: https://github.com/HKUDS/OpenHarness (HKU Data Intelligence Lab)
> Version analyzed: 2026-04-03 (first public release)
> LOC: 11,733 Python | License: MIT

## How to Use This Document
- 设计新 agent → 查阅 §Agent Design Guidelines
- 评估 TAD 能力差距 → 查阅 §TAD Mapping
- 了解某个子系统细节 → 查阅对应子系统章节

## Overview
{Harness 概念定义 + 10 子系统关系图（Mermaid 或 ASCII）}

## 1. Engine — Agent Loop
{使用 4.2 子系统模板}

## 2. Tools — Tool Registry & Execution
{使用 4.2 子系统模板}

... (10 个子系统，每个用同一模板)

## TAD Mapping
| OpenHarness 子系统 | TAD 对应物 | 差距/可借鉴 |
|---|---|---|
| Engine (Agent Loop) | Blake 执行循环 | TAD 无显式 turn 上限；OpenHarness 默认 max_turns=8 |
| ... | ... | ... |
（10 行，每个子系统一行）

## Agent Design Guidelines
### G1. Loop Control（基于 Engine）
**Pattern**: {模式名} | **When to use**: {使用场景} | **TAD implication**: {对 TAD/agent 设计的启示}

### G2. Tool Registration（基于 Tools）
{同结构}

### G3. Permission Layering（基于 Permissions）
{同结构}

... （≥8 条具名设计建议，每条对应一个子系统，至少覆盖 8/10）

## Key Metrics
| Metric | OpenHarness Default | Source File | TAD Equivalent |
|--------|--------------------|-----------:|----------------|
| max_turns | 8 | engine/query.py | 无（Ralph Loop 无 turn 上限） |
| max_retries | 3 | api/client.py | 无 |
| permission_levels | 3 modes | permissions/modes.py | 2 (deny + hook) |
| ... | ... | ... | ... |
（≥8 行量化指标）

## Other Modules
{一句话列出排除的 17 个模块及排除原因}
```

### 4.2 子系统章节统一模板

每个子系统章节必须包含以下 4 个子节：

```markdown
### Core Abstraction
{主类/接口定义，1-3 句话 + 关键类签名}

### Data Flow
{输入 → 处理 → 输出，用流程描述或伪代码}

### Key Code Pattern
```python
# 来自 {源文件路径}:{行号范围}
{核心代码片段，来自真实源码}
```

### Design Decisions
- Decision: {决策} | Rationale: {原因} | TAD Implication: {启示}
```

### 4.3 信息来源
- **主要来源**：直接读 OpenHarness 源码（`/Users/sheldonzhao/01-on progress programs/OpenHarness/src/openharness/`）
- **补充来源**：用户研究笔记（`/Users/sheldonzhao/01-on progress programs/thoughts/discoveries/2026-04-03-openharness-final.md`）
- **禁止**：编造代码或 API。所有代码块必须来自实际源文件，标注文件路径。

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 否 — 这是新建文档，不涉及历史代码

### MQ2: 函数存在性验证
- [x] 否 — 不涉及函数调用，是文档任务

### MQ3-MQ5: 不适用（research 任务）

---

## 6. Implementation Steps

### Phase 1: 读源码 + 写文档（单 Phase）

#### 交付物
- [ ] `.tad/references/openharness-architecture.md` ≥300 行
- [ ] 10 个子系统全部覆盖

#### 实施步骤

0. **读取用户研究笔记**作为初始输入：
   `/Users/sheldonzhao/01-on progress programs/thoughts/discoveries/2026-04-03-openharness-final.md`
   优先从此提炼已有洞察，再用源码验证/补充，避免重复研究。

1. **读取 OpenHarness 源码**：对每个子系统的核心文件做 Read
   - `engine/query.py`, `engine/query_engine.py`
   - `tools/base.py`
   - `permissions/checker.py`, `permissions/modes.py`
   - `hooks/executor.py`, `hooks/events.py`, `hooks/schemas.py`
   - `skills/loader.py`, `skills/registry.py`, `skills/types.py`
   - `coordinator/coordinator_mode.py`, `coordinator/agent_definitions.py`
   - `memory/manager.py`, `memory/types.py`
   - `tasks/manager.py`, `tasks/types.py`
   - `prompts/system_prompt.py`, `prompts/claudemd.py`
   - `config/settings.py`

2. **提炼架构模式**：从源码中提取核心类/接口、数据流、关键代码片段

3. **写入文档**：按 4.1 的结构写入 `.tad/references/openharness-architecture.md`

4. **补充映射表和设计指导**：基于 TAD 现有架构对照写映射表

#### 验证方法
```bash
# 文件存在 + 行数
wc -l .tad/references/openharness-architecture.md
# 期望: ≥300

# 10 个子系统标题都存在
for s in Engine Tools Permissions Hooks Skills Coordinator Memory Tasks Prompts Config; do
  grep -q "^## .*$s" .tad/references/openharness-architecture.md && echo "✅ $s" || echo "❌ $s"
done

# 二级标题数量（精确匹配 ^## ，不计 ###）
h2_count=$(grep -c '^## ' .tad/references/openharness-architecture.md)
[ "$h2_count" -ge 14 ] && echo "✅ H2 headers: $h2_count (need ≥14)" || echo "❌ H2 headers: $h2_count (need ≥14)"

# 有代码块（来自真实源码）
code_count=$(grep -c '```python' .tad/references/openharness-architecture.md)
[ "$code_count" -ge 10 ] && echo "✅ Python blocks: $code_count" || echo "❌ Python blocks: $code_count (need ≥10)"

# 代码块真实性抽查：从文档提取第一个 Python 代码块的首行非注释代码，在源码中搜索
first_code_line=$(sed -n '/```python/{n;/^#/d;p;q;}' .tad/references/openharness-architecture.md | head -1 | xargs)
if [ -n "$first_code_line" ]; then
  grep -r "$first_code_line" /Users/sheldonzhao/01-on\ progress\ programs/OpenHarness/src/ >/dev/null 2>&1 \
    && echo "✅ Code block spot-check: found in source" || echo "⚠️ Code block spot-check: not found (manual verify)"
fi

# 映射表存在
grep -q "^## TAD Mapping" .tad/references/openharness-architecture.md && echo "✅ mapping" || echo "❌ mapping"

# 设计指导存在 + ≥8 条
guidelines_count=$(grep -c '^### G[0-9]' .tad/references/openharness-architecture.md)
[ "$guidelines_count" -ge 8 ] && echo "✅ Guidelines: $guidelines_count (need ≥8)" || echo "❌ Guidelines: $guidelines_count (need ≥8)"

# Key Metrics 存在
grep -q "^## Key Metrics" .tad/references/openharness-architecture.md && echo "✅ metrics" || echo "❌ metrics"

# Other Modules 附录存在
grep -q "^## Other Modules" .tad/references/openharness-architecture.md && echo "✅ other modules" || echo "❌ other modules"
```

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/references/openharness-architecture.md  # 主交付物
```

### 7.2 Files to Modify
```
（无修改）
```

---

## 8. Testing Requirements

### 8.1 验证脚本
上述 Section 6 的验证命令即为测试要求。

### 8.2 内容质量检查
- 每个子系统至少 1 个 Python 代码块（来自真实源码）
- 代码块中的类名/函数名在 OpenHarness 源码中实际存在
- 映射表 10 行完整

---

## 9. Acceptance Criteria

- [ ] AC1: `.tad/references/openharness-architecture.md` 存在
- [ ] AC2: ≥300 行，且每个子系统章节 ≥25 行
- [ ] AC3: 10 个子系统全部有独立 `## ` 章节，总 H2 标题 ≥14
- [ ] AC4: 每个子系统使用统一模板（Core Abstraction / Data Flow / Key Code Pattern / Design Decisions）
- [ ] AC5: 每个子系统有 ≥1 个 Python 代码块，来自真实源码（标注文件路径），总计 ≥10 个代码块
- [ ] AC6: 包含 TAD Mapping 表（10 行，含差距列）
- [ ] AC7: 包含 Agent Design Guidelines 章节，≥8 条具名建议（G1-G8+），每条含 Pattern / When to use / TAD implication
- [ ] AC8: 包含 Key Metrics 量化标准汇总表，≥8 行指标
- [ ] AC9: 包含 Other Modules 附录
- [ ] AC10: 至少 3 个代码块通过 grep 在 OpenHarness 源码中验证存在
- [ ] AC11: 走 Ralph Loop + Gate 3

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | 文件存在 | `test -f .tad/references/openharness-architecture.md` | 文件存在 |
| 2 | ≥300 行 | `wc -l` | 行数 ≥300 |
| 3 | 10 子系统 H2 标题 | `grep -c '^## '` | ≥14 |
| 4 | 统一模板 | `grep -c '### Core Abstraction'` | ≥10 |
| 5 | Python 代码块 | `grep -c '```python'` | ≥10 |
| 6 | 映射表 | `grep -q '^## TAD Mapping'` | 存在 |
| 7 | 设计指导 ≥8 条 | `grep -c '^### G[0-9]'` | ≥8 |
| 8 | 量化标准表 | `grep -q '^## Key Metrics'` | 存在 |
| 9 | Other Modules 附录 | `grep -q '^## Other Modules'` | 存在 |
| 10 | 代码块真实性 | 至少 3 个 grep 验证 | 源码中找到匹配 |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **代码块必须来自真实源码** — 不要编造 Python 代码。Read 源文件后提取。
- ⚠️ **OpenHarness 路径** — `/Users/sheldonzhao/01-on progress programs/OpenHarness/src/openharness/`

### 10.2 Known Constraints
- OpenHarness 部分模块是空文件（`memory/search.py`, `prompts/context.py`），标注为"未实现"即可
- 文档是 Phase 2 的前置依赖——Phase 2 会引用此文档路径

### 10.3 Sub-Agent 使用建议
- [ ] **parallel-coordinator** — 可以并行读 10 个子系统的核心文件
- [ ] **docs-writer** — 可选，用于文档结构优化

---

**Handoff Created By**: Alex
**Date**: 2026-04-03
**Version**: 3.1.0
