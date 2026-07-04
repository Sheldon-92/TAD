# IDEA: Single-Loop Agent 拒绝 LangChain/LangGraph

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — PostHog AI (35.3k stars)

---

## Context

PostHog AI (产品分析平台内置 agent) 明确拒绝 LangChain/LangGraph，选择直接 API 调用 + 单循环 agent 架构。核心 loop 用 Claude Sonnet 4.5，复杂推理用 OpenAI o4-mini（cost-effective reasoning）。一个 "switch mode tool" 让 agent 在 PostHog 全产品表面切换。

## Summary & Problem

大多数 agent 项目默认选择 LangChain/LangGraph 作为 orchestration 层，但 PostHog 团队发现直接 API 调用 + 单循环比框架更简单、更可控。这与 TAD 的 "judgment rules in SKILL.md, not in framework abstractions" 哲学一致。

关键设计选择：
- 无 workflow graph、无 subagent — 单循环 + tool switching
- Claude Sonnet 做主循环，o4-mini 做性价比推理（双模型策略）
- 每周 "Traces Hour" 团队分析真实生产 trace（见 IDEA-20260703-traces-hour-practice）

## Open Questions

- 单循环在什么规模/复杂度下开始吃力？PostHog 的产品表面有多大？
- "switch mode tool" 的具体设计 — 类似 TAD 的 intent router 吗？
- 双模型策略（贵模型做主循环 + 便宜模型做推理）是否适用于 TAD workflow?

## Relevance to Us

TAD 已经在 SKILL.md 层面做 judgment rules，但 orchestration 仍依赖 Claude Code 的 Workflow tool。PostHog 的经验说明：对于产品内嵌 agent，框架层可能是多余的。
