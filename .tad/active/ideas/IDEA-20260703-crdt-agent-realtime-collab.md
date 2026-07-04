# IDEA: CRDT + Agent 热替换的实时协作架构

**Date:** 2026-07-03
**Status:** captured
**Scope:** medium
**Source:** AI Tinkerers #33 — Jam: Collaborative AI Live-Coding Music (Grisha Szep, Tokyo)

---

## Context

Jam 是一个浏览器内的协作 live-coding 音乐平台。核心架构：
- **Yjs (CRDT)** 做实时多人协作（LAN-based）
- **AI agent** 写 Strudel（音乐 DSL）和 Hydra（视觉 DSL）代码
- 代码在 **bar boundary**（音乐小节边界）热替换 — 音乐不中断
- 共享 2D canvas + 可热重载的 micro-apps
- 不依赖昂贵 backend glue

项目未开源。作者 Grisha Szep (University of Tokyo) 的 GitHub 显示计算生物学 + 创意计算背景。

## Summary & Problem

Jam 展示了一个优雅的 "agent + 人类实时共创" 模式：
1. CRDT 保证多方编辑不冲突
2. Agent 的输出（代码）在安全边界（bar boundary）替换，不破坏正在运行的系统
3. 不需要中心服务器 — local-first, LAN-based

"安全边界热替换" 是关键创新：agent 不是任意时刻注入变更，而是等到一个 "安全切换点" 才替换。这让 agent 协作变得可预测和安全。

## Open Questions

- "安全边界" 概念能否推广？比如 TAD 的 handoff 就是一种 "安全边界" — 在 Gate 通过后才切换执行权
- CRDT 在 agent 协作中的角色：如果多个 agent 同时编辑同一文件，CRDT 能否解决冲突？
- Yjs 的性能和适用范围 — 代码/结构化数据 vs 自然语言

## Relevance to Us

"Agent 在安全边界热替换" 模式直接映射到 TAD 的 Gate 系统 — Gate 就是 "安全切换点"。Jam 的 CRDT 协作也提示：如果 TAD 支持多 agent 并行编辑（worktree isolation 之外），CRDT 可能是另一个方向。
