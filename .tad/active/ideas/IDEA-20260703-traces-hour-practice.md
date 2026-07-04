# IDEA: Production Observation Practice — TAD 设计的 Agent 上线后如何持续改进

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — PostHog AI (Traces Hour practice)

---

## Context

PostHog 团队每周举行 "Traces Hour" — 全团队分析真实生产环境的 agent trace（用户对话 + 工具调用链）。他们发现这比预建 eval dataset 更有效。

当前 TAD 方法论覆盖：设计→实现→测试→交付。但 agent 上线后的"观测→发现问题→改进→再迭代"这段是空白。

## Summary & Problem

用 TAD 设计的 agent（如 Hermes、OpenClaw）部署后，如何系统性地改进？

两条互补路径：
1. **自动化 eval**（TAD trajectory-eval harness）— 检测回归，覆盖面广
2. **人工 trace review**（Traces Hour）— 发现自动 eval 抓不到的新失败类别

TAD 需要一个 "生产观测" 模块，让 agent 设计者知道：部署后看什么、多频繁看、发现问题后怎么反馈回设计。

## Core Design Question

TAD 的生命周期应该从：
```
设计 → 实现 → Gate → 交付 (end)
```
延伸为：
```
设计 → 实现 → Gate → 交付 → 观测 → 改进 → 再设计 (loop)
```

这个 "观测→改进" 环节需要回答：
- 看什么数据？（对话记录、工具调用链、用户反馈、放弃率）
- 多频繁看？（每周？每 N 次对话后？）
- 谁看？（agent 设计者 = Alex 角色？还是新角色？）
- 发现问题后怎么办？（走 *bug path？新 handoff？直接改 prompt？）

## Open Questions

- 这应该是 TAD 框架的新模块，还是一个 Capability Pack？
- 与现有的 trajectory-eval + Knowledge Lifecycle 如何分工？
- 不同类型的 agent 观测需求不同（聊天 agent vs 自动化 agent vs 工具 agent）

## Relevance to Us

**直接填补 TAD 方法论的缺口。** 当 TAD 推广到帮人做 agent 产品时，"做完了然后呢" 是用户第一个会问的问题。这个模块是 TAD 从 "开发方法论" 进化为 "agent 全生命周期方法论" 的关键一步。
