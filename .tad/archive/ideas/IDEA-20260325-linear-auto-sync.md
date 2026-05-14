# Idea: Linear Auto-Sync — TAD Documents as Single Source of Truth

**ID:** IDEA-20260325-linear-auto-sync
**Date:** 2026-03-25
**Status:** promoted
**Scope:** medium

---

## Summary & Problem

Current Linear integration only syncs on *accept (marks issue Done). User wants a full auto-sync mechanism where TAD's documents (NEXT.md, Epics, Ideas) are the single source of truth and Linear automatically reflects their state. This eliminates manual issue management in Linear.

## Key Decisions Already Made

- **Direction**: One-way sync (TAD → Linear only, no Linear → TAD)
- **Trigger timing**: Alex startup (full sync) + *accept (incremental sync)
- **Scope**: All NEXT.md sections (In Progress, Pending, Blocked, Recently Completed, Ideas)
- **Projects**: 4 active projects (menu-snap, TAD, my-openclaw-agents, Sober Creator)
- **Prerequisite**: Linear MCP tools must be available (Phase 1 of current handoff)

## Design Sketch

```
Alex /alex 启动时:
  1. 扫描当前项目的 NEXT.md
  2. 解析 sections → 映射到 Linear 状态:
     - "## In Progress" items → Linear: In Progress
     - "## Pending" / "## Today" / "## This Week" → Linear: Todo
     - "## Blocked" → Linear: Todo (label: blocked)
     - "## Recently Completed" [x] items → Linear: Done
     - "## Ideas" → Linear: Backlog
  3. diff 对比 Linear 现有 issues (by title match within project)
  4. 创建新的 / 更新状态变化的 / 不删除 Linear 独有的

Alex *accept 时:
  5. 增量: 刚归档的 handoff → 对应 Linear issue 标 Done
```

## Open Questions

- 跨项目 sync: Alex 启动时只 sync 当前项目？还是 sync 所有 4 个项目的 NEXT.md？
- Title matching: NEXT.md 条目的文本怎么匹配到 Linear issue？（模糊匹配 vs 精确匹配）
- 去重: 如何避免重复创建？（用 title hash？用 Linear issue ID 回写到 NEXT.md？）
- Epic 映射: Epic 对应 Linear 的什么？（Project? Epic 功能? 标签?）
- 性能: 每次启动都全量扫描会不会太慢？

## Notes

- Depends on: Linear MCP tools being available + 4 projects created (Phase 1 of current handoff)
- Current step4b_linear_sync is the foundation — auto-sync builds on top of it
- Should respect the principle: "Linear is human's tool, TAD is execution framework"

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: Handoff (via *analyze — 2026-03-25)
