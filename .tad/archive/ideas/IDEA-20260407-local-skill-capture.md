# Idea: 本地 Skill 捕获机制（未来 Epic 2）

**ID:** IDEA-20260407-local-skill-capture
**Date:** 2026-04-07
**Status:** captured
**Scope:** medium

---

## Summary & Problem

**问题**：用户在不同 TAD 项目里会摸索出独特的解决方法（例：Supreme Capstone 的"语音转文字 + 说话人识别"完整方案）。这些方法目前以原始代码形式散落在项目内，没有结构化、不可复用、跨项目时要重新摸索。

**想法**：让用户在意识到"这个方法有趣且可能复用"的当下，用一个命令（如 `*save-skill`）让 Alex 立即把它生成为本地 skill 文件（`.claude/skills/local/*` 或类似目录）。本地 skill 由项目持有，但与 TAD 框架 skill 物理隔离，`*sync` 永远不会覆盖。

**核心洞察**：用 Claude Code 原生的 skill 格式作为统一容器，不需要发明新的"recipe"层。捕获时机从"事后回顾"变成"灵光一闪当下"，准确率高 10 倍。

## Open Questions

- **目录隔离方案**：`.claude/skills/local/*` vs `.claude/skills/_user/*` vs frontmatter 标记？需要 spike 验证 Claude Code 是否能正常加载子目录里的 skill。
- **`*save-skill` 数据来源**：从对话上下文 LLM 总结起草？还是用户手动填字段？混合方案（LLM 草稿 + 用户编辑）？
- **Alex 主动建议**：是否在 Gate 4 或任务完成时主动评估"这次解决方案值得保存吗"，问用户？要可关闭（避免骚扰）。
- **`*sync` 兼容**：必须验证现有 sync 逻辑跳过本地 skill 目录，且不破坏现有所有注册项目的同步流程。
- **Skill 命名冲突**：项目 A 和项目 B 都创建了 `voice-diarize` 但内容不同，Epic 3 harvest 时如何处理？这个决策最好在 Epic 2 阶段就想清楚。

## Notes

- **依赖关系**：必须在 Epic 1（Domain Pack 可靠加载）完成后开始
- **不与 Epic 1 的 hook 冲突**：本地 skill 由 Claude Code 原生自动加载，**不进入** Haiku 分类流程。Hook 只负责 Domain Pack 匹配。
- **Phase 草案**（Epic 化时细化）：
  1. 目录隔离 + Sync 保护（spike + 实现）
  2. `*save-skill` 命令实现（从对话提取 + 生成 SKILL.md 草稿）
  3. Alex 主动建议机制（可选，可关闭）
- **Success Criteria 草稿**：
  - 用户可一个命令在当前会话语境下生成 SKILL.md
  - 本地 skill 与框架 skill 物理隔离，`*sync` 永不覆盖
  - 至少 3 个项目用此机制成功捕获 5+ 本地 skill
- **关联 Epic 3**：本 Epic 是 Epic 3（Cross-Project Skill Harvest）的前置条件 — 没有积累一段时间的本地 skill 就无 harvest 可言

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (待 Epic 1 完成后 promote)
