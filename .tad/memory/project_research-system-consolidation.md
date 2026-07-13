---
name: research-system-consolidation
description: 9 个研究入口的完整摸底 + 统一为 *research 的整合方案（用户待确认）
metadata: 
  node_type: memory
  type: project
  originSessionId: b693b41f-8374-4847-82bd-f63bbff6642d
---

## 现状诊断（2026-06-16 *discuss）

TAD 自然生长出 9 个研究入口，职责严重重叠，用户最大痛点是"想要 NotebookLM 研究但 Alex 经常走 WebSearch"。

### 9 个入口逐个摸底

1. **`*research-plan`（Alex 协议）**：最重路径。OBJECTIVES.md gap → 6 子阶段（Phase 0 定义→0class 分级→0c 对抗→Phase 1 GitHub-First 加源→Phase 2 清理→Phase 3 报告→Phase 4 种子+动态 Ask+CRAG+对抗→Phase 5 AC 提取）。用 NotebookLM。10-20 分钟/题。
2. **`/research-methodology`（Capability Pack）**：另一套 5 阶段流水线（Plan→Source→Curate→Analyze→Output），有自己的 `.research/research-state.yaml`。用 NotebookLM。**和 #1 90% 重叠**，但各自独立演化。自称是 research-notebook 和 research-github 的"严格超集"但未实际废弃它们。
3. **`/research-notebook`（19 个子命令）**：NotebookLM CRUD 工具集。`ask` 命令自带动态追问（4 轮上限、6 策略：saturated/contradiction/follow_thread/perspective_shift/gap_enrichment/so_what）。**是唯一直接操作 NotebookLM 的接口**。
4. **`research-engine`（Workflow）**：多 Agent 迭代研究（Plan→Deepen 循环→Verify→Synthesize）。**不用 NotebookLM**，纯 WebSearch+WebFetch。
5. **内置 `deep-research`（Claude Code 自带）**：一次性 fan-out WebSearch → 验证 → 报告。**不用 NotebookLM**。CLAUDE.md 禁止 Alex 调用。
6. **`*research-review`（Alex 协议）**：组合管理。扫描所有 notebooks 按目标对齐分类（🔥/✅/🔄/📦）。不做研究。
7. **`*research`（设计流内嵌）**：research_decision_protocol 中的 WebSearch 选型，3-5 查询 → 对比表。不是独立命令。
8. **`/research-github`**：GitHub awesome-list 注册表管理。源发现工具。
9. **`/academic-research`（Capability Pack）**：学术专用（PRISMA、系统性综述）。领域专用不冲突。

### 4 个核心问题

1. **两套重复流水线**：#1（research-plan）和 #2（research-methodology）做 90% 相同的事
2. **默认路径偏离**：用户期望 NotebookLM，但 intent router 常匹配到 WebSearch 路径（#4/#5）
3. **能力藏在子命令里**：#3 的 ask 动态追问是完整的迭代研究引擎，但藏在 19 个子命令之一
4. **用户选择负担**：9 个入口太多，很多区别连 Alex 也分不清

## 提议方案（用户待确认）

### 统一为 `*research`，3 个深度级别

| 深度 | 触发 | 机制 | NotebookLM | 耗时 |
|------|------|------|------------|------|
| Quick | 单一事实查询 | WebSearch 直接回答 | 否 | 秒级 |
| Standard（默认） | "研究一下 X"、"对比 A 和 B" | 找到/新建 notebook → ask 动态追问 | 是 | 3-8 分钟 |
| Deep | "深入研究"、"建知识库"、"landscape" | GitHub-First 加源 → 清理 → 多轮种子+动态 Ask → 报告 | 是 | 15-30 分钟 |

**关键改变**：无明确指示时默认 Standard（NotebookLM），不是 Quick（WebSearch）。

### 砍掉

- `/research-methodology` Capability Pack — 和 research-plan 重复
- `research-engine` workflow — NotebookLM ask 动态追问已覆盖迭代深化
- CLAUDE.md 研究排除规则 — 统一入口后不需要

### 保留重新定位

- `/research-notebook` → 实现层（*research 的底层工具，用户通常不直接调）
- `*research-review` → 改名 `*research status`（组合管理）
- `/research-github` → 保留（源发现）
- `/academic-research` → 保留（学术专用）
- 内置 `deep-research` → NotebookLM 不可用时的降级方案

## 质量提升（6 项，用户已确认 2026-06-16）

入口整合是前提，质量改进是目的。

| # | 改什么 | 现在 | 改成 |
|---|--------|------|------|
| Q1 | 问题生成 | 泛搜清单题 | 从 OBJECTIVES/用户意图推导决策题（"基于 Y，X 哪个方案在 Z 方面证据最强？"） |
| Q2 | 源的控制 | Deep 加 50+ 源，curate 只清错误 | Standard 上限 15 源；加源后 ask 验证相关性，不相关删掉再加 |
| Q3 | 饱和判断 | 连续 N 轮 0 新引用（机械） | 每轮反问"能回答研究目标吗？"（语义），指出缺信息的子问题 |
| Q4 | 产出格式 | 原始问答链 + 通用报告 | 决策简报：选项→证据→推荐→未知风险，结构固定 |
| Q5 | 轻量验证 | Standard 无验证 | 提取前 3 个具体 claim → WebSearch 验证（不需 Codex/Gemini） |
| Q6 | 闭环反馈 | 研究完就结束 | 交付后问"回答了吗？哪里没到位？"→ 针对性补充 |

Q1-Q3 = 输入端（挖多深多准）。Q4-Q6 = 输出端（交付物是否可用）。

**Why:** 用户反复反馈"想要 NotebookLM 研究但 Alex 做了别的"，根因是入口太多 + 默认路径不对 + 研究产出质量不为决策设计。
**How to apply:** ✅ EPIC COMPLETE (2026-06-17). 4/4 Phase 全部完成（commits: 4dbb5a3, 05efd2e, b1c13a0, be7afb5）。*sync 到 14 项目延至下次 *publish。下次 Alex 会话用 `*research` 验证行为（AC15 deferred）。
