---
title: Domain Pack Monthly Refresh — Tools & Skills 定期更新机制
date: 2026-04-02
status: captured
scope: small
---

## Summary & Problem

Domain Pack 的工具（tools-registry.yaml）和 skills 研究会过时。新 MCP server、CLI 工具每周都在出，不更新就落后。

## Proposed Solution

每月一次 "Domain Pack Health Check"：
1. tools-registry.yaml — 检查工具版本、搜索更好的替代
2. 每个 domain.yaml — 检查 skills 研究是否需要更新
3. 新工具扫描 — WebSearch 上月新出的 MCP server / CLI 工具
4. 产出：更新后的 registry + 变更日志

可以写成 handoff 模板，每月给 Blake 执行。或做成 `*maintain` 的扩展。

## Open Questions

- 每月还是每季度？
- 自动化（SessionStart hook 提醒"上次更新是 X 天前"）还是手动？
- 范围：只更新 registry 还是也更新 domain.yaml 的 steps？
