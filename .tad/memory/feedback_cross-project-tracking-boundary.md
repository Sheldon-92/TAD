---
name: cross-project-tracking-boundary
description: 跨项目工作项（如 smart-home 的修复单）不得记录进 TAD 的 NEXT.md / session-state
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 31388152-3f92-467f-9624-6d6364cb20f7
  modified: 2026-08-04T00:56:59.364Z
---

用户裁定（2026-08-03）：别的项目的工作项（例：smart-home 生产 P0 修复单）跟 TAD 没关系，
不要记录在 TAD 项目的跟踪文件里（NEXT.md、session-state.md 的 Next Action 等）。

**Why:** 每个项目的 backlog 归各自项目管；TAD 里混入其他项目的 to-do 会污染 TAD 的
状态账本，也造成"TAD 在替别的项目排期"的越界。TAD 侧只保留与 TAD 自身相关的事实
（如某次审计作为 gate-escape 数据点的记录），不保留对方项目的行动项。

**How to apply:** 在 TAD 会话中提及其他项目的待办时，口头建议可以，但写入 NEXT.md /
session-state / handoff 前先判断归属：行动项属于哪个仓库，就记到哪个仓库。跨项目
证据（审计报告副本等）已有先例：拷贝到对方项目的 .tad/evidence/ 下。
