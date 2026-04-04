---
task_type: yaml
e2e_required: no
research_required: no
---

# Handoff: AI Agent Architecture Domain Pack — OpenHarness 研究补充

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-009
**Epic:** EPIC-20260403-openharness-agent-architecture-upgrade.md (Phase 2/3)

---

## Expert Review Status

| Expert | Focus | P0 | P1 | P2 | Result |
|--------|-------|----|----|----|----|
| code-reviewer | AC 可验证性、验证脚本、gap 检测 | 3 (fixed) | 4 (3 fixed) | 3 | CONDITIONAL PASS → PASS |
| backend-architect | 映射准确性、遗漏检测、架构合理性 | 0 | 3 (fixed) | 3 | CONDITIONAL PASS → PASS |

**P0 修复：**
- P0-1: Expert Review Status 已填写
- P0-2: 新增 gates: section out-of-scope 声明
- P0-3: 验证改为 before-after 表 9 行 + 每 capability 至少 1 个 OpenHarness 引用

**P1 修复：**
- Hooks (G4) 注入到 tool_system_design（lifecycle hooks 作为工具系统扩展性检查）
- G10 Error as Context 注入到 reliability_design 的 quality_criteria
- production_readiness 增加 schema 验证条目
- before-after 阈值 20→30 行
- 来源标注统一为 `— 来源: OpenHarness §{章节}`
- 版本号 bump 指令：1.0.0 → 1.1.0

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
基于 `.tad/references/openharness-architecture.md`（Phase 1 产出），更新 `ai-agent-architecture.yaml` 的 9 个 capability，注入来自 OpenHarness 的量化设计标准和工作流步骤。

### 1.2 Why We're Building It
- 现有 Domain Pack 基于 LLM 知识，缺乏真实开源实现的量化标准
- 跟 HW Domain Pack 研究补充相同模式：把抽象建议升级为有来源的具体检查项
- 每次用 TAD 设计新 agent 都会走这个 Domain Pack，一次更新所有后续受益

### 1.3 Intent Statement
**真正要解决的问题**：ai-agent-architecture.yaml 的 quality_criteria 和 steps 缺乏量化标准

**不是要做的**：
- ❌ 不是重写整个 Domain Pack
- ❌ 不是增加新 capability
- ❌ 不是写代码——只改 YAML

---

## 📚 Project Knowledge

### 步骤 1：识别相关类别
- [x] architecture — 架构决策

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 1 条 | "Workflow Steps > Quality Criteria Text" — 新 step 比纯文字 criteria 更有价值 |

**⚠️ Blake 必须注意的历史教训**：
1. **Workflow Steps > Quality Criteria Text** (来自 architecture.md)
   - 问题：第一轮 HW 研究只加了文字标准，Blake 自评不够
   - 解决方案：优先加新 step（带 tool_ref 更好），quality_criteria 文字是次要产出
   - **本次要求：每个 capability 至少 1 个新 step 或 1 个新量化 quality_criteria**

---

## 2. Background Context

### 2.1 Previous Work
- Phase 1 已完成：`.tad/references/openharness-architecture.md`（887 行，10 子系统 + G1-G10 设计指导 + TAD Mapping + Key Metrics）
- 参照成功案例：HANDOFF-20260403-hw-research-supplement（4 个 HW pack 研究补充，Gate 4 PASS）

### 2.2 Current State
- `ai-agent-architecture.yaml` — 1126 行，9 个 capability，version 1.0.0
- 缺乏来自真实 agent 框架实现的量化标准

### 2.3 Dependencies
- `.tad/references/openharness-architecture.md`（Phase 1 产出，必读）

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 更新 `ai-agent-architecture.yaml` 的 9 个 capability
- FR2: 每个 capability 至少 1 个改动（新 step / 新 quality_criteria / 新 anti_pattern）
- FR3: 产出 before-after 对比文档
- FR4: 所有新增内容标注来源（`— 来源: OpenHarness {子系统}/{文件}`）
- FR5: 改动后 YAML 语法正确

---

## 4. Technical Design

### 4.1 Capability → OpenHarness 映射（9 个 capability 的改动计划）

Blake 必须先读 `.tad/references/openharness-architecture.md` 的以下章节，然后按映射改 YAML：

| # | Capability | 参考章节 | 设计指导 | 注入类型 |
|---|-----------|---------|---------|---------|
| 1 | reliability_design | §1 Engine + §Key Metrics | G1 Loop Control + G10 Error as Context | 新 step: verify_loop_bounds（max_turns + retry）+ 新 quality_criteria: 工具失败返回错误上下文不抛异常（G10） |
| 2 | role_behavior_design | §5 Skills | G5 Skill as Prompt Injection | 新 quality_criteria: Skill 定义必须有 YAML frontmatter（name, description, when_to_use） |
| 3 | tool_system_design | §2 Tools + §4 Hooks | G2 Tool Registration + G4 Lifecycle Hooks | 新 step: verify_tool_schema（Pydantic/JSON Schema + is_read_only）+ 新 quality_criteria: agent 行为可通过 lifecycle hooks 扩展（pre/post tool_use） |
| 4 | memory_design | §7 Memory | G7 File-Based Memory | 新 quality_criteria: 持久化必须有 index file（MEMORY.md 模式）+ 多项目 memory 需命名空间隔离 |
| 5 | multi_agent_design | §6 Coordinator + §8 Tasks | G6 Minimal Coordination | 新 step: design_coordination_model（team registry + task queue vs 复杂框架） |
| 6 | safety_design | §3 Permissions | G3 Permission Layering | **最关键** — 新 step: design_permission_layers + 量化：≥3 层过滤（deny → allow → mode） |
| 7 | prompt_architecture | §9 Prompts | G8 Layered Prompt Assembly | 新 quality_criteria: system prompt 分层组装（base + environment + project + memory） |
| 8 | production_readiness | §10 Config | G9 Settings Validation | 新 quality_criteria: 配置优先级 CLI > ENV > file > defaults + 配置必须有 schema 验证（Pydantic/JSON Schema） |
| 9 | self_improvement_design | （无对应） | — | 最小改动：加 anti_pattern "无执行追踪 = 无法自我优化" |

**Scope 说明**：
- `gates:` section（YAML 末尾 gate2_design 等）**不在本次 scope 内**
- Hooks (G4) 归入 tool_system_design（工具系统扩展性）
- 版本号 bump：完成后将 `version: 1.0.0` → `1.1.0`

### 4.2 改动原则

1. **优先加 step**（行为改变 > 文字建议）
2. **标注来源**：所有新增内容后缀 `— 来源: OpenHarness {文件}` 或 `— 参考: .tad/references/openharness-architecture.md §{章节}`
3. **不删除现有内容**：只增不减（除非发现明显错误）
4. **保持 YAML 风格一致**：跟现有格式对齐

### 4.3 信息来源
- **唯一来源**：`.tad/references/openharness-architecture.md`（Phase 1 产出）
- **不需要再读 OpenHarness 源码**——参考文档已包含所需代码模式和量化标准

---

## 6. Implementation Steps

### Phase 1: 读参考文档 + 改 YAML（单 Phase）

#### 交付物
- [ ] `ai-agent-architecture.yaml` 更新（9 个 capability 全部有改动）
- [ ] `.tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md` 对比文档

#### 实施步骤

1. **读取参考文档**：
   `.tad/references/openharness-architecture.md` 全文（重点：G1-G10、TAD Mapping、Key Metrics）

2. **读取现有 YAML**：
   `.tad/domains/ai-agent-architecture.yaml` 全文

3. **逐 capability 改动**（按 4.1 映射表）：
   对每个 capability：
   a. 读参考文档对应章节
   b. 对比现有 YAML 找差距
   c. 添加新 step / quality_criteria / anti_pattern
   d. 标注来源

4. **写 before-after 对比文档**：
   `.tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md`
   格式同 HW 研究补充：

   ```markdown
   ## ai-agent-architecture 迭代记录

   ### 来自 OpenHarness 参考架构的改进
   | Capability | 来源章节 | 改进了什么 | 改进前 | 改进后 |
   |-----------|---------|-----------|--------|--------|

   ### 改动统计
   - 新增 steps: N
   - 新增 quality_criteria: N
   - 新增 anti_patterns: N
   - 修改 existing: N
   ```

5. **验证 YAML 语法**：
   `python3 -c "import yaml; yaml.safe_load(open('.tad/domains/ai-agent-architecture.yaml'))"`

#### 验证命令
```bash
# 1. YAML 语法
python3 -c "import yaml; yaml.safe_load(open('.tad/domains/ai-agent-architecture.yaml'))" && echo "✅ YAML OK" || echo "❌ YAML INVALID"

# 2. 有改动（git diff hunks ≥9）
hunks=$(git diff -U0 .tad/domains/ai-agent-architecture.yaml | grep -c '^@@')
[ "$hunks" -ge 9 ] && echo "✅ hunks: $hunks (need ≥9)" || echo "❌ hunks: $hunks"

# 3. OpenHarness 来源标注（统一格式）
oh_refs=$(grep -c 'OpenHarness' .tad/domains/ai-agent-architecture.yaml)
[ "$oh_refs" -ge 9 ] && echo "✅ OpenHarness refs: $oh_refs" || echo "❌ refs: $oh_refs (need ≥9)"

# 4. Before-after 文档存在 + 行数
test -f .tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md && echo "✅ before-after exists" || echo "❌ missing"
ba_lines=$(wc -l < .tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md 2>/dev/null || echo 0)
[ "$ba_lines" -ge 30 ] && echo "✅ before-after: $ba_lines lines" || echo "❌ before-after: $ba_lines lines (need ≥30)"

# 5. Before-after 表有 9 行（每 capability 一行）
ba_rows=$(grep -c '|.*reliability_design\|role_behavior_design\|tool_system_design\|memory_design\|multi_agent_design\|safety_design\|prompt_architecture\|production_readiness\|self_improvement_design' .tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md 2>/dev/null || echo 0)
[ "$ba_rows" -ge 9 ] && echo "✅ capability rows: $ba_rows (need ≥9)" || echo "❌ capability rows: $ba_rows"

# 6. Version bump
grep -q 'version: 1.1.0' .tad/domains/ai-agent-architecture.yaml && echo "✅ version 1.1.0" || echo "❌ version not bumped"
```

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md  # 对比文档
```

### 7.2 Files to Modify
```
.tad/domains/ai-agent-architecture.yaml  # 9 个 capability 更新
```

---

## 9. Acceptance Criteria

- [ ] AC1: 9 个 capability 全部有至少 1 个改动（before-after 表恰好 9 行，每 capability 一行）
- [ ] AC2: 改动后 YAML 语法正确
- [ ] AC3: 所有新增内容标注来源，统一格式 `— 来源: OpenHarness §{章节}`（≥9 个引用）
- [ ] AC4: git diff ≥9 个 hunks
- [ ] AC5: before-after 对比文档存在且 ≥30 行
- [ ] AC6: 至少 4 个 capability 有新 step（不只是 quality_criteria 文字）
- [ ] AC7: version 字段从 1.0.0 → 1.1.0
- [ ] AC8: 走 Ralph Loop + Gate 3

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | 9 capability 改动 | before-after 表 capability 行数 | 恰好 9 行 |
| 2 | YAML 语法 | `python3 yaml.safe_load` | 无错误 |
| 3 | OpenHarness 来源 | `grep -c 'OpenHarness'` in YAML | ≥9 |
| 4 | git diff hunks | `git diff -U0 \| grep -c '^@@'` | ≥9 |
| 5 | before-after 文档 | `test -f` + `wc -l` | 存在且 ≥30 行 |
| 6 | 新 steps ≥4 | before-after 文档统计 | ≥4 个新 step |
| 7 | version bump | `grep 'version: 1.1.0'` | 存在 |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **不要再读 OpenHarness 源码** — 参考文档已包含所有需要的信息
- ⚠️ **不要删除现有内容** — 只增不减
- ⚠️ **历史教训：步骤 > 文字** — 至少 4 个 capability 要有新 step，不能全是 quality_criteria 文字

### 10.2 Known Constraints
- self_improvement_design 无 OpenHarness 对应物，做最小改动即可
- YAML 文件 1126 行，改动后可能达 1200+ 行

---

**Handoff Created By**: Alex
**Date**: 2026-04-03
**Version**: 3.1.0
