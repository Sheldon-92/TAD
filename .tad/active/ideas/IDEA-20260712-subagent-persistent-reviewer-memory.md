# IDEA: 常任审查员持久记忆 (subagent memory field)
**Date**: 2026-07-12 | **Status**: promoted | **Scope**: medium | **Source**: claude-native-capabilities research (S1 chain)
原生 subagent `memory` 字段给每个 subagent 一个跨会话持久目录。给 code-reviewer / security-auditor
/ spec-compliance-reviewer 配上 → 审查经验跨 session 复利(重复缺陷模式、项目特有约定)。
价值最大的 B 组机会。风险: 审查员记忆污染独立性(anchoring)——需设计 memory 内容边界(只存模式,不存verdict)。
Next: *idea-promote → 小 handoff(subagent 定义文件加 memory 字段 + 内容边界规则)。

**Promoted To**: Epic (via *analyze — 2026-07-12, native-capability-adoption)
