# IDEA: Release 全量版本扫描 Gate — 防止历史版本漂移

**Date:** 2026-07-03
**Status:** captured
**Scope:** small
**Source:** v2.33.0 发布时发现 6 个文件版本落后 3-22 个版本

---

## Context

v2.33.0 发布前审查发现：
- Alex SKILL.md 卡在 v2.15.0（落后 18 个版本）
- Blake SKILL.md 卡在 v2.10.4（落后 22 个版本）
- PROJECT_CONTEXT.md 卡在 2.27.0（落后 6 个版本）
- docs/MULTI-PLATFORM.md 卡在 2.30.0（落后 3 个版本）

## Summary & Problem

`release-verify.sh version` 只检查 `$OLD`（上一个版本）→ `$NEW` 的转换。如果一个文件在很久以前就漏了（比如卡在 2.27.0），后续每次 release 都找不到它，因为不会去搜 "2.27.0" 这个字符串。

**根因**：版本 gate 只做相邻版本检测，不做全量扫描。一旦漏掉一次，永远漏。

## Proposed Fix

给 `release-verify.sh` 加一个 `version-sweep` 模式：
1. 用 regex 找所有看起来像版本号的字符串 (`[0-9]+\.[0-9]+\.[0-9]+`)
2. 排除：.git/、archive/、evidence/、CHANGELOG.md 历史行
3. 剩下的如果不等于 `$NEW`，全部报出来
4. 每次 *publish 时在 step3c 之后运行（advisory 或 blocking）

## Proposed Fix (expanded)

不只是版本号，release 流程应该覆盖 3 类内容：

### A. 全量版本扫描 (version-sweep mode)
- regex 找所有 `X.Y.Z` 字符串
- 排除 archive/evidence/CHANGELOG 历史行
- 不等于 $NEW 的全部报出来

### B. README "What's New" 自动提示
- *publish 时检测 README.md 的 "What's New" section 引用的最高版本
- 如果不是 $NEW → 报 WARN："README What's New 未更新到 v{NEW}"
- 不自动写内容（需要人类写 changelog 描述），但确保不会遗忘

### C. GitHub repo description 同步
- *publish 时检查 `gh repo view --json description` 是否包含 $NEW
- 如果不包含 → 提示更新（或自动拼接版本号到 description 末尾）

### D. Agent SKILL.md 版本注释
- 决定：SKILL.md 里的 `<!-- TAD vX.Y.Z Framework -->` 是"当前版本"（v2.33.0 选了这个）
- 那就应该在 version bump 的 grep 范围内
- 具体做法：release-verify 的 grep 应该覆盖 .claude/skills/ 和 .agents/skills/ 目录

## Open Questions

- version-sweep 是 advisory 还是 blocking？建议 blocking on minor+
- 历史引用（deprecation.yaml "added_in: 2.30.0"）的排除规则：只排除 `added_in:`/`deprecated_in:` 前缀的行？
- README "What's New" 检查是否应该也检查 INSTALLATION_GUIDE.md？
