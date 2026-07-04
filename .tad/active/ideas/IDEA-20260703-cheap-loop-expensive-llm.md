# IDEA: Cheap Deterministic Loop + Expensive LLM 介入的混合架构

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — petri: LLM-driven artificial life (Jeff Rhatigan, NH)

---

## Context

petri 是一个人工生命模拟器：一个快速的遗传 swarm 持续演化（deterministic inner loop），LLM 偶尔作为 "variation operator" 介入，发明新工具让种群采纳。关键设计：LLM 不控制模拟，只是偶尔注入变异。模拟可以在没有 LLM 的情况下持续运行（deterministic fallback）。

项目未开源。作者 Jeff Rhatigan 另有 JEN-R8 Discovery Engine（预注册 falsification gates 的 AI 研究引擎）。

## Summary & Problem

大多数 "AI agent" 设计让 LLM 做所有决策（每步都调用 LLM）。petri 的架构把 LLM 定位为 "偶尔介入的昂贵顾问"，而不是 "每步都在场的控制器"。

这个模式的通用化：
- **Cheap inner loop**: 确定性逻辑持续运行（规则引擎、遗传算法、状态机）
- **Expensive LLM**: 在关键节点介入（生成新变异、判断方向、注入创意）
- **Deterministic fallback**: LLM 不可用时系统仍然运行

## Open Questions

- TAD 的哪些环节适合这种架构？例如 document health check 可以是 cheap loop，LLM 只在发现异常时介入
- "variation operator" 模式是否适合 skill evolution？cheap loop 做 skill 版本管理，LLM 偶尔提议新 skill
- petri 如何决定 "什么时候让 LLM 介入"？是周期性的还是事件触发的？

## Relevance to Us

TAD 的 startup activation (STEP 3.x) 目前是纯 LLM 驱动的。如果部分检查可以用 cheap deterministic logic（bash scripts, grep, file age checks）做，只在发现问题时才 invoke LLM 判断，可以显著减少 activation overhead。
