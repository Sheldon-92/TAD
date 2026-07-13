# IDEA: pack 经 subagent skills 字段预载 (代替 handoff 文本转述)
**Date**: 2026-07-12 | **Status**: captured | **Scope**: small-medium | **Source**: S1 chain
subagent frontmatter `skills` 字段可全量预载 skill 到 agent context。实现/审查 agent 直接预载
匹配的 capability pack,替代现在 handoff §"Capability Pack References" 的转述+自行 Read。
与 pack≤2 护栏组合使用。
