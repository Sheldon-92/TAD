# Idea: 跨项目 Skill Harvest 与晋升（未来 Epic 3）

**ID:** IDEA-20260407-cross-project-skill-harvest
**Date:** 2026-04-07
**Status:** captured
**Scope:** large

---

## Summary & Problem

**问题**：当多个 TAD 项目都积累了本地 skill（来自 Epic 2 的 `*save-skill`），用户需要一种方式去 review 这些"散落的智慧"，挑选有价值的"晋升"为 TAD 框架级 skill，让所有项目都能用上。

**想法**：新命令 `*skill-harvest` 扫描 `sync-registry.yaml` 里所有项目的本地 skill 目录，生成跨项目索引表。用户逐个 review，选择"晋升 / 复制到指定项目 / 保留本地 / 弃用"。晋升时 Alex 协助把草稿打磨成框架质量，然后通过 `*sync` 下行到所有项目。

**核心机制**：双向流转
- **下行（已有）**：TAD 核心 skills → `*sync` → 所有项目
- **上行（新增）**：本地 skills → `*skill-harvest` → review → 晋升 → 下次 `*sync` 下行到所有项目

## Open Questions

- **晋升时是否要 Alex 重写**：本地 skill 可能写得很草，晋升前需要打磨成框架质量（添加 frontmatter、规范化结构、补充示例）。这是 Alex 的工作还是用户的？
- **命名冲突处理**：项目 A 的 `voice-diarize` 和项目 B 的 `voice-diarize` 内容不同，harvest 时怎么 merge？是让用户选一个、合并、还是提示重命名？
- **Sync 推送预览**：晋升后下次 `*sync` 会把新 skill 推到所有注册项目。是否需要"预览"这次 sync 会推什么？某些项目能否选择不接收？
- **Hook 集成**：如果 Epic 1 的 hook 设计预留了 recipe 字段，是否在这里把已晋升的 skill 也接入 Haiku 分类（让用户在新项目自然描述需求时被提示加载相关 skill）？
- **Harvest 频率**：手动触发 vs 定期提醒？

## Notes

- **依赖关系**：必须在 Epic 2（本地 Skill 捕获机制）完成**且积累 1-2 个月本地 skill 之后**才有意义
  - 没有数据可 harvest 的情况下做这个 Epic 等于做空气
- **Phase 草案**（Epic 化时细化）：
  1. Harvest 扫描与展示（跨项目索引表）
  2. Review + 晋升流程（AskUserQuestion 4 选项）
  3. Alex 协助打磨（草稿 → 框架质量 SKILL.md 重写）
  4. (Optional) Hook 集成（接入 Epic 1 的 Haiku 分类）
- **Success Criteria 草稿**：
  - `*skill-harvest` 可扫描所有注册项目的本地 skill 并展示
  - 晋升流程包含 Alex 打磨
  - 至少 3 个本地 skill 成功晋升并下行到所有项目
  - 晋升后的 skill 在新项目首次使用时被正确触发（端到端验证）
- **关键时间点**：Epic 2 完成后**先不要立即开始 Epic 3**，而是让用户用 Epic 2 的机制在多个项目里捕获至少 1-2 个月的真实本地 skill，再用真实数据驱动 Epic 3 的设计

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (待 Epic 2 完成 + 1-2 个月数据积累后 promote)
