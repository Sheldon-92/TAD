# IDEA: 自批评 Generation Pipeline + Transcript Mining 个性化

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — AI Voice Tutor for iOS (Dhvanil Patel, Berlin)

---

## Context

Dhvanil Patel 的 iOS 语言学习 app 有两个独立的技术亮点：

**1. Self-Critique Image Pipeline**: 每晚用 GPT Image 2 批量生成闪卡插图，然后用模型自批评（self-critique filter）自动丢弃质量差的图片。不依赖人类审核，但保证了输出质量。

**2. Transcript Mining**: GPT-Realtime 做语音导师即兴对话，同时 mining 对话记录，提取用户的具体错误模式。这些错误反馈到 FSRS 间隔重复系统中，形成个性化学习路径。

项目未开源。作者还做 Squad（coding agent 可视化控制台）和 claw.town（AI agent 虚拟世界）。

## Summary & Problem

**Self-Critique Pattern**: 生成 → 自评 → 过滤 → 只保留合格的。这是一个通用的内容质量控制模式，不限于图片。可以应用于：
- 代码生成后自评（TAD 的 expert review 就是这个模式的外化）
- 文档生成后自评（handoff 质量检查）
- Research findings 生成后自验证（*research 的 claim verification 就是这个）

**Transcript Mining Pattern**: 从交互记录中提取用户特定模式，反馈到系统中个性化行为。这类似 TAD 的 Knowledge Assessment — 从工作记录中提取模式。

## Open Questions

- Self-critique filter 的成本效益 — 生成 N 张只用 M 张，N/M 比例多少是合理的？
- TAD 能否 mining session transcript 提取用户的工作模式（常犯错误、偏好路径）？
- FSRS 间隔重复是否适合 knowledge maintenance？旧 knowledge 定期 review

## Relevance to Us

Self-critique 已经部分存在于 TAD（claim verification in *research, expert review in handoff）。但 "批量生成 → 自动过滤" 的 pipeline 思路可以更系统化 — 比如 skill 草稿批量生成后自评质量。Transcript mining 与 TAD 的 trace 系统结合可以做 "用户行为模式学习"。
