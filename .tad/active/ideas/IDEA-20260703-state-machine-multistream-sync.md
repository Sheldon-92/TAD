# IDEA: 状态机驱动 + 多流同步的自适应交互架构

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — Simer: AI Developer Interviewing Platform (Simreen Siraj, Abu Dhabi)

---

## Context

Simer 是一个 AI 面试平台。核心架构：
- **Phase-based state machine** 驱动面试流程（不是自由对话）
- **三流同步**: Monaco 编辑器状态 + 语音 transcript + 职位需求，实时同步到 voice interviewer 的 context
- 输出结构化产物：transcript、technical scorecard、decision card
- 候选人通过唯一链接进入，简历自动加载

项目未开源，早期阶段。Tech stack: Next.js, React 18, AWS Bedrock。

## Summary & Problem

Simer 的 "状态机 + 多流同步" 是一个通用的 agent 交互架构：

**状态机驱动**：面试分阶段（introduction → coding → system design → behavioral），每阶段有明确的入口/出口条件和可用工具。这比自由对话更可控，但比纯脚本更灵活。

**多流同步**：agent 同时感知多个数据流（代码变化 + 语音 + 背景需求），综合判断下一步行动。这比单一文本输入更像真人交互。

**结构化输出**：不是自由文本总结，而是预定义格式的 scorecard + decision card。

## Open Questions

- TAD 的 Alex/Blake 交互是否可以建模为状态机？当前的 protocol steps 其实就是隐式状态机
- 多流同步在 coding agent 场景：同时感知编辑器变化 + terminal 输出 + test 结果？
- 结构化输出（scorecard 模式）是否适合 Gate review — 标准化评分卡而不是自由文本

## Relevance to Us

TAD 的 Gate 系统和 protocol steps 本质上是隐式状态机。Simer 的做法提示：将这些隐式状态显式化（可视化状态转移、明确每个状态的可用 action 和退出条件）可能提高可靠性和可调试性。
