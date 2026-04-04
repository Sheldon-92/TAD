---
Title: SessionStart Full Component Health Check
Date: 2026-04-03
Status: captured
Scope: medium
---

## Summary & Problem
TAD Alex/Blake 启动时做文档健康检查（handoff/NEXT.md），但不检查框架组件完整性。OpenHarness 的 RuntimeBundle 模式在启动时组装并验证所有组件（API client, MCP, tools, hooks, engine）。如果 hook 脚本缺失、config 版本不一致、模板文件损坏，TAD 当前不会在启动时发现。

## Open Questions
- 应该检查哪些组件？（hook 脚本存在性、config 版本一致、模板完整性）
- 检查失败时：阻塞 vs 警告？
- 是否集成到现有 SessionStart hook？

## Potential Scope
Medium — SessionStart hook 扩展 + 检查脚本

## Source
OpenHarness ui/runtime.py (build_runtime → RuntimeBundle assembly)
