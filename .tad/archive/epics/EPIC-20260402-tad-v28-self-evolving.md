# Epic: TAD v2.8.0 — Self-Evolving Framework

**Epic ID**: EPIC-20260402-tad-v28-self-evolving
**Created**: 2026-04-02
**Owner**: Alex

---

## Objective

升级 TAD 从静态框架到自我进化框架。两层进化：项目内 Domain Pack 优化 + 跨项目 TAD 方法论优化。基于 Meta-Harness、Self-Evolving Agent、DeerFlow 的研究成果。

## Success Criteria
- [ ] 执行 trace 自动记录（Hook 驱动，step 级别）
- [ ] Gate 4 后自动分析 trace 并提议改进
- [ ] 项目级 Domain Pack 优化可用（单项目内 trace → quality_criteria 更新）
- [ ] 框架级 TAD 优化可用（跨项目 trace 聚合 → SKILL.md/Hook 更新）
- [ ] 人审批所有自动提议的变更
- [ ] 在至少 1 个真实项目上验证进化循环
- [ ] 版本 bump 到 v2.8.0

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | 深度源码研究 | ✅ Done | v28-research-synthesis.md | 6 agent 完成，5 项目源码 + Claude Code trace 机制全部研究 |
| 1 | Trace 基础设施 | ✅ Done | HANDOFF-20260402-tad-v28-trace-infrastructure.md | record_trace() + JSONL + 递归防护 + 跨平台 |
| 2 | 项目级分析 Agent | ⬚ Planned | — | Gate 4 后自动 spawn 分析 agent → 读 trace → 提议改进 |
| 3 | 跨项目聚合 | ⬚ Planned | — | TAD 主项目的 *evolve 命令 → 聚合所有项目 trace → 提议框架修改 |
| 4 | 人审批工作流 | ⬚ Planned | — | AskUserQuestion 展示提议 → 人选择接受/拒绝/修改 → 应用变更 |
| 5 | 验证 + 发布 | ⬚ Planned | — | 在真实项目验证 → version bump → push → sync |

### Phase Dependencies
- Phase 0 → Phase 1（源码研究发现 inform 设计）
- Phase 1 → Phase 2（trace 基础设施必须先有）
- Phase 2 → Phase 3（项目级先跑通再做跨项目）
- Phase 2 + 3 → Phase 4（分析结果需要审批工作流）
- Phase 4 → Phase 5（审批机制必须先有）

---

## Context for Next Phase

### Research Assets（已有）
- DeerFlow 源码: `/Users/sheldonzhao/01-on progress programs/references/deer-flow/`
- Meta-Harness 源码: `.../references/meta-harness-tbench2-artifact/`
- EvoAgentX 源码: `.../references/EvoAgentX/`
- AutoHarness 源码: `.../references/AutoHarness/`
- NeMo Guardrails 源码: `.../references/NeMo-Guardrails/`
- 研究报告: `.tad/spike-v3/domain-pack-tools/ai-agent-architecture-research.md`
- Ideas: `.tad/active/ideas/IDEA-20260402-self-evolving-domain-pack.md`

### Decisions Made So Far
- Trace 粒度: Domain Pack step 级别（不是每个工具调用）
- Trace 存储: Hook 自动记 + Blake 手动补分析
- 触发时机: 每次 Gate 4 通过后
- 审批: 人审批所有变更
- 两层进化: 项目级 + 框架级
- 版本: v2.8.0

### Next Phase Scope
Phase 0: 深度读 5 个克隆的源码项目，提取：
- DeerFlow: skill 系统怎么做的、memory 怎么持久化的
- Meta-Harness: proposer 怎么读 trace、怎么生成改进提议
- EvoAgentX: 反馈循环怎么实现的
- NeMo Guardrails: Input/Output/Execution rails 怎么配置的
- AutoHarness: governance 框架怎么设计的

---

## Notes
- 这是 TAD 的第三次重大升级（v2.0 Ralph Loop → v2.7 Hook 架构 → v2.8 自我进化）
- 参考源码已克隆到 /Users/sheldonzhao/01-on progress programs/references/
