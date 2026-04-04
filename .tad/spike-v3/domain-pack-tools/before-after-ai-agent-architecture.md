# ai-agent-architecture Domain Pack 迭代记录

**Version**: 1.0.0 → 1.1.0
**来源**: OpenHarness 参考架构 (`.tad/references/openharness-architecture.md`)
**日期**: 2026-04-03
**Epic**: EPIC-20260403-openharness-agent-architecture-upgrade.md (Phase 2/3)

---

## 来自 OpenHarness 参考架构的改进

| Capability | 来源章节 | 改进类型 | 改进前 | 改进后 |
|-----------|---------|---------|--------|--------|
| reliability_design | §Engine + G1 + G10 | 新 step + 2 quality_criteria | 无循环上限检查步骤；无错误上下文要求 | 新增 verify_loop_bounds step（max_turns ≤10, max_retries ≤3, circuit breaker）；新增 G10 Error as Context 标准 |
| role_behavior_design | §Skills + G5 | 新 quality_criteria | 无 Skill 元数据格式要求 | 新增 YAML frontmatter 要求（name, description, source），支持 registry 自动发现 |
| tool_system_design | §Tools + §Hooks + G2 + G4 | 新 step + 1 quality_criteria | 无 schema 验证步骤；无 lifecycle hooks 要求 | 新增 verify_tool_schema step（Pydantic/JSON Schema + is_read_only 声明 + 延迟加载）；新增 lifecycle hooks 扩展性标准 |
| memory_design | §Memory + G7 | 2 quality_criteria | 无 index file 要求；无多项目隔离 | 新增 MEMORY.md index 模式要求；新增命名空间隔离（SHA1 hash） |
| multi_agent_design | §Coordinator + G6 | 新 step | 无协调模型设计步骤 | 新增 design_coordination_model step（TeamRegistry 模式 + 角色预定义 + 复杂度评估） |
| safety_design | §Permissions + G3 | 新 step | 无分层权限设计步骤 | 新增 design_permission_layers step（≥3 层过滤器 + PermissionDecision 结构 + 量化指标） |
| prompt_architecture | §Prompts + G8 | 新 quality_criteria | 无分层组装要求 | 新增 system prompt 分层组装标准（base + environment + project + memory） |
| production_readiness | §Config + G9 | 2 quality_criteria | 无配置优先级链要求；无 schema 验证要求 | 新增配置优先级链标准（CLI > ENV > file > defaults）；新增 schema 验证标准（Pydantic/JSON Schema） |
| self_improvement_design | §Engine (StreamEvent) | 新 anti_pattern | 无执行追踪要求 | 新增 anti_pattern: 无执行追踪 = 无法自我优化 |

---

## 改动统计

- 新增 steps: **4** (verify_loop_bounds, verify_tool_schema, design_coordination_model, design_permission_layers)
- 新增 quality_criteria: **8** (reliability×2, role_behavior×1, tool_system×1, memory×2, prompt×1, production×2) — 注: 部分 capability 有多条新增
- 新增 anti_patterns: **1** (self_improvement_design)
- 修改 existing: **1** (version 1.0.0 → 1.1.0)
- 总 OpenHarness 引用: **18** 处（统一格式 `— 来源: OpenHarness §{章节}`）

---

## 来源对照

所有新增内容均来自 `.tad/references/openharness-architecture.md` 的以下章节：

| 引用来源 | 对应 YAML 位置 |
|---------|---------------|
| §Engine (QueryContext.max_turns=8) | reliability_design.verify_loop_bounds |
| §Engine + §Tools (G10 Error as Context) | reliability_design.quality_criteria |
| §Skills (SkillDefinition frozen dataclass) | role_behavior_design.quality_criteria |
| §Tools (BaseTool.to_api_schema, is_read_only) | tool_system_design.verify_tool_schema |
| §Hooks (G4 Lifecycle Hooks) | tool_system_design.quality_criteria |
| §Memory (G7 File-Based Memory) | memory_design.quality_criteria |
| §Memory (SHA1 hash 隔离) | memory_design.quality_criteria |
| §Coordinator (G6 Minimal Coordination) | multi_agent_design.design_coordination_model |
| §Permissions (G3 Permission Layering) | safety_design.design_permission_layers |
| §Prompts (G8 Layered Prompt Assembly) | prompt_architecture.quality_criteria |
| §Config (G9 Settings Validation) | production_readiness.quality_criteria |
| §Engine (StreamEvent) | self_improvement_design.anti_patterns |
