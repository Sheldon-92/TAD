# Epic: OpenHarness 驱动的 AI Agent 架构升级

**Epic ID**: EPIC-20260403-openharness-agent-architecture-upgrade
**Created**: 2026-04-03
**Owner**: Alex

---

## Objective
以 OpenHarness（HKU 团队 Python 复现 Claude Code 核心架构，11.7K LOC）为参考来源，升级 TAD 的 AI Agent 设计能力。分三阶段：持久化参考文档 → Domain Pack 注入量化标准 → TAD 自身迭代。最终目标：TAD 用户设计任何新 agent 时，都能获得基于真实开源实现的具体设计标准，而不是抽象建议。

## Success Criteria
- [ ] .tad/references/openharness-architecture.md 存在且 ≥300 行（10 子系统完整文档化）
- [ ] ai-agent-architecture.yaml 9 个 capability 全部有 OpenHarness 来源的 quality_criteria / steps / anti_patterns
- [ ] 每个 capability 至少 1 个新 step 或 1 个量化标准（不只是文字增强）
- [ ] TAD 自身迭代项识别完成（记录到 NEXT.md 或新 idea）

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | 参考架构文档持久化 | ✅ Done | HANDOFF-20260403-openharness-reference-doc.md | .tad/references/openharness-architecture.md（887 行，10 子系统 + G1-G10 指导） |
| 2 | AI Agent Architecture Domain Pack upgrade | ✅ Done | HANDOFF-20260403-openharness-domain-pack-upgrade.md | v1.1.0: +4 steps, +8 criteria, +1 anti_pattern, 18 refs |
| 3 | TAD 自身迭代项识别 | ✅ Done | — (Alex only) | 2 NEXT.md 待办 + 3 ideas（hook-timeout, config-env, session-health） |

### Phase Dependencies
Phase 1 → Phase 2（Phase 2 的 YAML 迭代需要引用 Phase 1 的参考文档）
Phase 2 → Phase 3（Phase 3 基于 Phase 2 的差距分析识别 TAD 自身需要的改进）

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Detail

### Phase 1: 参考架构文档持久化
**目的**：把 OpenHarness 研究结果从对话 context 转化为可复用的持久化文档
**产出**：`.tad/references/openharness-architecture.md`
**内容**：
- 10 个子系统的架构摘要（Engine, Tools, Permissions, Hooks, Skills, Coordinator, Memory, Tasks, Prompts, Config）
- 每个子系统：核心抽象（类/接口）、数据流、关键代码模式、设计决策
- 与 TAD 的映射关系表
- 对 agent 设计的具体指导（可被 Domain Pack steps 引用）

**范围**：文档整理 + 写入，不改 YAML

### Phase 2: AI Agent Architecture Domain Pack 研究补充
**目的**：把 OpenHarness 的具体设计模式注入 ai-agent-architecture.yaml 的 9 个 capability
**方法**：跟 HW Domain Pack 研究补充相同模式
**映射**：
| Capability | OpenHarness 子系统 | 注入内容 |
|---|---|---|
| reliability_design | Engine (retry, max_turns, backoff) | 量化阈值：3 retries, 429/500/502/503 可重试, jitter |
| role_behavior_design | Skills (YAML frontmatter + markdown) | Skill 定义模式标准 |
| tool_system_design | Tools (BaseTool + ToolRegistry + Pydantic) | is_read_only() 模式、声明式注册标准 |
| memory_design | Memory (MEMORY.md index + per-file) | 轻量持久化模式标准 |
| multi_agent_design | Coordinator (TeamRecord + TaskManager) | 极简协调模式：team = agent list + message queue |
| safety_design | Permissions (3 层过滤 + command deny) | **完整参考实现**：deny → allow → path → command → mode |
| prompt_architecture | Prompts (CLAUDE.md 发现 + 环境注入) | 目录遍历发现 + 分层合并标准 |
| production_readiness | Config (CLI > ENV > file > defaults) | 12-factor 配置优先级标准 |
| self_improvement_design | （OpenHarness 未实现） | TAD 独有，可能不需要更新 |

**AC**：
- 每个 capability ≥1 个新 step 或量化 quality_criteria
- before-after 对比文档
- YAML 语法正确

### Phase 3: TAD 自身迭代项识别
**目的**：基于 Phase 2 差距分析，识别 TAD 框架本身需要改进的地方
**产出**：NEXT.md 待办项 或 .tad/active/ideas/ 中的 idea
**可能的方向**：
- Agent loop max_turns 保护（Ralph Loop 增强）
- Bash command deny patterns（PreToolUse hook）
- RuntimeBundle 式全组件初始化检查（SessionStart 增强）

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: 887 行参考架构文档，10 子系统统一模板，31 个真实代码块，G1-G10 指导。Commit 75d75f6。
- Phase 2: ai-agent-architecture.yaml v1.1.0，+4 steps, +8 quality_criteria, +1 anti_pattern, 18 OpenHarness refs。Commit f1af57e。

### Decisions Made So Far
- OpenHarness 已 clone 到 /Users/sheldonzhao/01-on progress programs/OpenHarness/
- 10 个子系统的深度研究已在当前会话完成（Explore agent）
- 优先级确认：Domain Pack > 参考文档 > TAD 迭代 > OpenClaw 迭代
- 采用 Epic 模式分 3 阶段推进（用户确认）
- Phase 1 文档超出预期 3 倍（887 vs 300 行），质量充足供 Phase 2 引用

### Known Issues / Carry-forward
- OpenHarness 刚开源 2 天（2026-04-01），代码可能快速变化
- self_improvement_design 是 TAD 独有，OpenHarness 没有对应物
- OpenHarness 的 context compression 和 memory search 还是空文件（未实现）

### Next Phase Scope
Phase 3: 基于 Phase 1 的 TAD Mapping 差距表 + Phase 2 的改动过程，识别 TAD 框架自身需要的迭代项（max_turns、command deny patterns、RuntimeBundle 初始化等），产出到 NEXT.md 或 ideas。

---

## Notes
- 来源项目：https://github.com/HKUDS/OpenHarness (HKU Data Intelligence Lab)
- 用户研究笔记：/Users/sheldonzhao/01-on progress programs/thoughts/discoveries/2026-04-03-openharness-final.md
- 本地 clone：/Users/sheldonzhao/01-on progress programs/OpenHarness/
