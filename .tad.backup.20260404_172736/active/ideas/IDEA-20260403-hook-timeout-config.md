---
Title: Hook Timeout Configuration
Date: 2026-04-03
Status: captured
Scope: small
---

## Summary & Problem
TAD hooks 没有超时控制。OpenHarness 对每种 hook 类型有明确超时（command/http/prompt: 30s, agent: 60s）。如果 hook 脚本挂起，TAD 会无限等待。

## Open Questions
- Claude Code 原生 hook 是否已有超时机制？需要验证
- 超时后的行为：静默跳过 vs 阻塞 vs 警告？

## Potential Scope
Small — 在 settings.json hooks 定义中加 timeout_seconds 字段

## Source
OpenHarness §Hooks (hooks/schemas.py: timeout_seconds=30)
