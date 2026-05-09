---
title: DeerFlow 模式借鉴 — Sandbox 隔离 + 持久化记忆 + Message Gateway
date: 2026-04-02
status: captured
scope: medium
---

## Summary

DeerFlow 2.0（ByteDance，45K stars）和 TAD 做同一件事（agent harness），但有几个 TAD 没有的模式值得借鉴。

## 值得借鉴的模式

### 1. Sandbox 隔离
DeerFlow: 每个 agent 在容器内执行（local/Docker/K8s 三级）
TAD: 依赖 Claude Code 的 OS 级沙箱（单进程）
价值: Blake 执行不信任代码时，容器隔离更安全

### 2. 持久化记忆
DeerFlow: 两层 — session 记忆（短期）+ user profile（长期，跨 session）
TAD: 1M context + project-knowledge files（手动管理）
价值: 跨 session 的结构化记忆比文件更可靠

### 3. Message Gateway
DeerFlow: 原生支持 Slack/Telegram/Feishu 作为通信渠道
TAD: 只有 CLI terminal
价值: 如果 TAD 扩展到非开发者用户，需要多渠道

## TAD 做得更好的

- Quality Gate 系统（DeerFlow 没有等价物）
- Domain Pack（比 DeerFlow 的 flat skill 更丰富）
- Human-as-bridge（比 optional checkpoint 更强制）
