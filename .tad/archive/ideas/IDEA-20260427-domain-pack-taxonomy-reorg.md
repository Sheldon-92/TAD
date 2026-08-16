# Idea: Domain Pack 分类学重组（横切 vs 垂直维度）

**ID:** IDEA-20260427-domain-pack-taxonomy-reorg
**Date:** 2026-04-27
**Status:** captured
**Scope:** large

---

## Summary & Problem

现在 21 个 Domain Pack 按"垂直维度"组织（Web / Mobile / AI / HW），但有些 Pack 实质是"横切维度"（cost-observability、security 系列、ai-tool-integration 等横跨多个垂直）。是否需要重新组织成 vertical × cross-cutting 二维分类，让用户更容易找到匹配的 pack？

## Open Questions

- 你有过"找不到该用哪个 pack"的实际痛点吗？（demote 的核心理由：没有具体痛点就不动 21 个 YAML 文件）
- 重组成本：rename 所有 pack 文件 + 更新 keywords.yaml + 更新所有引用 + 通知所有下游项目重新 sync——大工程
- 替代方案：保持现有分组，加一个 `cross_cutting: true` 标签 + 在 README 加分类索引——成本低很多
- 何时重启：当出现"明显该用某 pack 但用户找不到"的具体证据时（≥2 次跨项目）

## Notes

- 来源：EPIC-20260424 Phase 6 P6.3（demoted 2026-04-27 by user reflection — 过度工程化反思）
- 原 Epic 评估：Assumption H + Phase 4.1/4.2 新 pack 涌现暗示分类需要重审
- Demote 理由：用户判断"无具体痛点的重组 = 为重组而重组"

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote — 等出现具体使用痛点后)
