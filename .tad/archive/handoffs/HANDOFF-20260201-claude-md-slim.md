# Handoff: CLAUDE.md Router Architecture (先补后砍)

**Status**: Draft → P0 Feedback Integrated
**Date**: 2026-02-01
**Author**: Alex (Solution Lead)
**Priority**: P1 - Structural optimization
**Epic:** N/A

### Expert Review Summary (2026-02-01)

| Expert | Verdict | P0 | P1 | P2 |
|--------|---------|:--:|:--:|:--:|
| code-reviewer | CONDITIONAL PASS | 3 | 6 | 4 |
| backend-architect | CONDITIONAL PASS | 3 | 5 | 4 |
| security-auditor | CONDITIONAL PASS | 3 | 5 | 4 |

**Consolidated unique P0 fixes (9 items, all integrated below):**
1. Task 1a/1d insertion points fixed (was inside YAML string block)
2. Task 1f added: Epic error handling codes backfill
3. New CLAUDE.md: Epic routing stub added
4. New CLAUDE.md: Knowledge Assessment → BLOCKING + "缺少则 Gate 无效"
5. New CLAUDE.md: Socratic Inquiry → BLOCKING + VIOLATION marker
6. New CLAUDE.md: "禁止仅做纸面验收" prohibition restored
7. New CLAUDE.md: "不通过 Blake 就修改代码" prohibition restored
8. New CLAUDE.md: "Alex 直接执行实现代码" prohibition restored
9. Phase 3: config-platform kept (contains agent_a_tools MCP rules)

**Design decision on P0-3 (Gate 4 subagent enforcement vs v2.0 business-only):**
Gate 4 v2 remains primarily business-focused, BUT the principle "禁止仅做纸面验收 — 必须调用 subagent 实际验证" is preserved as a cross-agent invariant in the router. Alex must still call at minimum code-reviewer for acceptance. The detailed enforcement stays in tad-gate.md and tad-alex.md.

---

## Executive Summary

将 CLAUDE.md 从 657 行的"全量规则书"重构为 ~80 行的"路由器"。
前提：先把 8 条仅存于 CLAUDE.md 的规则补进 agent 文件，15 条部分覆盖的规则补全。
确认 100% 覆盖后再精简 CLAUDE.md。同时优化 Alex 的 config 加载（5 模块 → 3 模块）。

**核心原则**：路由层（CLAUDE.md）告诉 Claude "什么时候做什么"，执行层（agent 文件）告诉 Claude "怎么做"。

---

## Phase 1: 补 — 填充 Agent 文件缺失规则

### Task 1: tad-alex.md — 补充 5 条缺失规则

**1a. Epic 派生状态公式 + 阶段动态调整** *(合并原 Task 1a + 1d，修复插入点)*
- 来源: CLAUDE.md lines 127-132, 145-150
- 插入位置: tad-alex.md line 803 之后（error_handling 块结束处），line 805 step3 之前。作为 step2b_epic_update 的**同级 peer section**，不在 `details: |` 字符串内部。
- 插入内容:
```yaml
    # Epic 派生状态（不存储独立 Status 字段，从 Phase Map 动态计算）
    epic_derived_rules:
      derived_status_formula:
        planning: "所有 phase 为 ⬚ Planned"
        in_progress: "有任何 🔄 Active 或 ✅ Done（但非全部 ✅）"
        complete: "所有 phase 为 ✅ Done"
      note: "Epic 文件中不写 Status 字段，Alex 在需要时从 Phase Map 计算状态"

      phase_adjustment:
        add: "Alex 在 Phase Map 末尾追加新行（仅 ⬚ Planned），Notes 中记录原因"
        remove: "仅限 ⬚ Planned 状态的阶段，Notes 中记录原因"
        reorder: "仅限 ⬚ Planned 状态的阶段"

      error_codes:
        epic_file_missing: "WARNING 日志，继续 *accept 流程（不阻塞归档）"
        epic_format_invalid: "WARNING 日志，跳过自动更新，提醒用户手动修复"
        handoff_ref_mismatch: "WARNING 日志，提示用户确认正确的 phase 编号"
        concurrent_active_violation: "BLOCK - 不允许激活新 phase"
        principle: "Epic 更新失败不阻塞 handoff 归档"
```
- 验证: grep "derived_status_formula" tad-alex.md → 应有结果
- 验证: grep "phase_adjustment" tad-alex.md → 应有结果
- 验证: grep "epic_file_missing" tad-alex.md → 应有结果

**1b. Knowledge Bootstrap 协议**
- 来源: CLAUDE.md lines 257-318（62 行）
- 插入位置: tad-alex.md line 922 之后（next_md_rules 结束处），作为新 section
- 插入内容:
```yaml
# Knowledge Bootstrap Protocol
knowledge_bootstrap:
  description: "项目知识的两种类型和初始化机制"

  knowledge_types:
    foundational:
      definition: "项目开始前就应确定的规范"
      when: "项目初始化时写入"
      examples: "设计系统、代码规范、技术栈"
    accumulated:
      definition: "开发过程中学到的经验"
      when: "Gate 通过后追加"
      examples: "踩坑记录、最佳实践、workaround"

  triggers:
    - trigger: "/tad-init 初始化新项目"
      action: "使用 .tad/templates/knowledge-bootstrap.md 模板填充 Foundational section"
    - trigger: "发现 knowledge 文件只有模板头（无实际内容）"
      action: "从代码中提取现有规范（tailwind.config, globals.css, package.json 等）"
    - trigger: "用户明确要求'补充项目知识'或'建立规范'"
      action: "执行完整 Bootstrap 流程"

  file_structure: |
    # {Category} Knowledge
    ---
    ## Foundational: {标题}        ← 先验知识（Bootstrap 时写入，只写一次）
    > Established at project inception.
    ### [子章节]
    ---
    ## Accumulated Learnings       ← 经验知识（Gate 通过后追加）
    ### [Short Title] - [YYYY-MM-DD]
    - **Context**: ...
    - **Discovery**: ...
    - **Action**: ...

  location: ".tad/project-knowledge/{category}.md"
```
- 验证: grep "knowledge_bootstrap" tad-alex.md → 应有结果

**1c. Alex 自用模板列表**
- 来源: CLAUDE.md lines 450-457
- 修改位置: tad-alex.md lines 642-647（my_templates section）
- 当前内容:
```yaml
my_templates:
  - requirement-tmpl.yaml
  - design-tmpl.yaml
  - handoff-tmpl.yaml
  - release-handoff.md (for major releases)
```
- 替换为:
```yaml
my_templates:
  creation:
    - requirement-tmpl.yaml
    - design-tmpl.yaml
    - handoff-tmpl.yaml
    - release-handoff.md (for major releases)
  reference_for_design:
    - api-review-format (.tad/templates/output-formats/)
    - architecture-review-format
    - database-review-format
    - ui-review-format
    - ux-research-format
  note: "reference 模板不是强制的，Alex 在 *design 时可参考以确保设计覆盖面"
```
- 验证: grep "reference_for_design" tad-alex.md → 应有结果

**1d. (已合并到 Task 1a — Epic 派生状态 + 阶段调整 + 错误代码统一插入)**

**1e. 苏格拉底提问 — 补全禁止行为**
- 来源: CLAUDE.md lines 194-197（3 条禁止行为，agent 文件只有 1 条）
- 修改位置: tad-alex.md line 337（现有 violation 行）
- 当前内容:
```yaml
      violation: "未完成 Socratic Inquiry 就开始写 handoff = VIOLATION"
```
- 替换为:
```yaml
      violations:
        - "未完成 Socratic Inquiry 就开始写 handoff = VIOLATION"
        - "问完问题不等用户回答就开始写 = VIOLATION"
        - "跳过复杂度评估，问题数量与任务不匹配 = VIOLATION"
```
- 验证: grep "不等用户回答" tad-alex.md → 应有结果

### Task 2: tad-gate.md — 补充 4 条缺失规则

**2a. Evidence 文件命名规范**
- 来源: CLAUDE.md lines 432-441
- 插入位置: tad-gate.md line 270 之后（Gate 4 Required_Subagents 结束处）
- 插入内容:
```yaml

# Evidence File Naming Convention
Evidence_Naming:
  pattern: ".tad/evidence/reviews/{YYYY-MM-DD}-{type}-{brief-description}.md"
  types: [testing-review, security-review, performance-review, code-review, ux-review]
  examples:
    - "2026-02-01-testing-review-user-flow.md"
    - "2026-02-01-security-review-auth-api.md"
    - "2026-02-01-performance-review-menu-load.md"
```
- 验证: grep "Evidence_Naming" tad-gate.md → 应有结果

**2b. 推荐模板清单（Non-blocking）**
- 来源: CLAUDE.md lines 443-448
- 插入位置: tad-gate.md 紧接 Evidence_Naming 之后
- 插入内容:
```yaml

# Recommended Templates (Non-blocking, for reference)
Recommended_Templates:
  - subagent: code-reviewer
    template: git-workflow-format
    when: "*review 命令"
  - subagent: refactor-specialist
    template: refactoring-review-format
    when: "重构任务"
```
- 验证: grep "Recommended_Templates" tad-gate.md → 应有结果

**2c. 验收报告模板增强**
- 来源: CLAUDE.md lines 364-389
- 插入位置: tad-gate.md line 348 之后（Gate 4 Workflow 结束处）
- 插入内容:
```yaml

# Alex Acceptance Report Format (used in Gate 4)
Acceptance_Report_Format: |
  ## Alex 验收报告

  ### 1. Subagent 审查结果

  **code-reviewer 结果：**
  - 审查范围：[文件列表]
  - 发现问题：[问题数量]
  - 关键反馈：[摘要]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  **security-auditor 结果：**
  - 审查范围：[模块/API]
  - 关键反馈：[摘要]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  **performance-optimizer 结果：**（如适用）
  - 关键反馈：[摘要]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  **ux-expert-reviewer 结果：**（如适用）
  - 审查范围：[页面/组件]
  - UX 评分：[分数/等级]
  - 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

  ### 2. 综合验收结论
  - [ ] 代码质量符合标准
  - [ ] 用户体验达到要求
  - [ ] 安全性无明显漏洞
  - [ ] 性能满足预期

  **最终结论**：✅ 验收通过 / ⚠️ 条件通过（需修复 N 项）/ ❌ 打回重做
```
- 验证: grep "Acceptance_Report_Format" tad-gate.md → 应有结果

**2d. 违规处理 3 步标准流程**
- 来源: CLAUDE.md lines 652-655
- 修改位置: tad-gate.md lines 436-449（现有 Violation Handling section）
- 在现有内容末尾添加:
```yaml

# Universal Violation Recovery Protocol (applies to all gates)
Violation_Recovery:
  step1: "立即停止当前操作"
  step2: "调用正确的 agent/command（如应走 /blake 的用 /blake）"
  step3: "按规范流程从头重新执行"
  principle: "违反任何规则 → 停止 → 纠正 → 重做"
```
- 验证: grep "Violation_Recovery" tad-gate.md → 应有结果

### Task 3: tad-blake.md — 补充 1 条缺失规则

**3a. Blake 自用模板列表**
- 来源: CLAUDE.md lines 459-462
- 插入位置: tad-blake.md，在 my_templates 或类似 section（如果不存在则在 release_duties 之后创建）
- 插入内容:
```yaml
# Templates Blake can reference during implementation
blake_reference_templates:
  - debugging-format (.tad/templates/output-formats/)
  - error-handling-format
  note: "参考模板，非强制。Blake 在调试/错误处理时可查阅"
```
- 验证: grep "blake_reference_templates" tad-blake.md → 应有结果

### Task 4: tad-alex.md — 补全部分覆盖规则

**4a. 专家审查 — 补充 P0 处理禁止行为**
- 来源: CLAUDE.md line 224
- 修改位置: tad-alex.md line 640（现有 violation 行）
- 当前:
```yaml
  violation: "不经过专家审查直接发送 handoff 给 Blake = 设计不完整 = VIOLATION"
```
- 替换为:
```yaml
  violations:
    - "不经过专家审查直接发送 handoff 给 Blake = VIOLATION"
    - "忽略专家发现的 P0 问题不修复 = VIOLATION"
```
- 验证: grep "P0 问题不修复" tad-alex.md → 应有结果

**4b. 输出模板使用规则**
- 来源: CLAUDE.md lines 407-412
- 插入位置: tad-alex.md，紧接 my_templates 的 reference_for_design 之后
- 插入内容:
```yaml
  usage_rules:
    - "审查类任务 → 参考对应输出模板的 checklist"
    - "输出格式 → 遵循模板定义的表格/结构"
    - "项目经验 → 参考 .tad/project-knowledge/ 中的记录"
```
- 验证: grep "usage_rules" tad-alex.md → 应有结果

---

## Phase 2: 砍 — 精简 CLAUDE.md

### Task 5: 重写 CLAUDE.md

将 657 行替换为 ~80-100 行的路由器版本。

**保留为路由规则的 section（精简后）：**

| 原 Section | 行数 | 保留内容 | 精简后行数 |
|------------|:----:|----------|:----------:|
| §1 Handoff 读取 | 29 | 核心触发 + 禁止行为 | ~10 |
| §2 使用场景 | 56 | 路由表（何时用 /alex /blake /gate）| ~20 |
| §3 Gates 概览 | 12 | 6 条规则摘要 | ~10 |
| §5 Terminal 隔离 | 55 | 核心约束 + 禁止行为 | ~15 |
| §9 违规处理 | 8 | 3 步恢复 | ~5 |

**删除（已有完整版在 agent 文件中）：**

| 原 Section | 行数 | 替代位置 |
|------------|:----:|----------|
| §2.1 Epic 规则 | 62 | tad-alex.md step2b + Task 1a |
| §3 苏格拉底详情 | 32 | tad-alex.md socratic_inquiry_protocol |
| §3 专家审查详情 | 26 | tad-alex.md handoff_creation_protocol |
| §3 Knowledge 详情 | 92 | tad-gate.md + tad-alex.md Task 1b |
| §3.1 验收规则 | 70 | tad-gate.md Gate 4 + Task 2c |
| §3.2 模板规则 | 20 | tad-alex.md Task 4b + tad-gate.md Task 2b |
| §4 模板强制规则 | 47 | tad-gate.md subagent calls + Task 2a |
| §6 版本发布 | 40 | tad-alex.md release_duties + tad-blake.md |
| §7 文档维护 | 48 | tad-maintain.md |
| §8 配对测试 | 30 | tad-alex.md step_pair_testing_assessment |

**新 CLAUDE.md 全文（目标 ~100 行，含专家反馈整合）：**

> 注意: 下方 ` ```markdown ` 和 ` ``` ` 之间的内容是完整的新 CLAUDE.md 文件内容，不包含外层代码围栏。

```markdown
# TAD 框架使用规则

> 此文件是路由层：告诉 Claude **什么时候**做什么。
> 具体执行协议在各 agent 命令文件中（/alex, /blake, /gate, /tad-maintain）。

---

## 1. Handoff 读取规则 ⚠️ CRITICAL

**读取 `.tad/active/handoffs/` 下的任何文件时：**

检测到 handoff → 必须调用 /blake → 必须过 Gate 3 + Gate 4

**禁止**:
- ❌ 读取 handoff 后直接实现（绕过 Blake）
- ❌ 实现完成后跳过 Gate 3/4
- ❌ 不通过 Blake 就修改代码

**原则**: 有 Handoff → 必须用 Blake → 必须过 Gates

---

## 2. TAD Framework 使用场景

### 使用 TAD

| 命令 | 触发条件 |
|------|----------|
| `/alex` | 新功能 (>3 文件), 架构变更, 复杂多步骤需求, 多模块重构 |
| `/blake` | 有 active handoff, Alex 已创建 handoff, 用户说"开始实现" |
| `/blake` (release) | 常规 patch/minor 版本发布（按 RELEASE.md SOP 执行）|
| `/alex` → `/blake` | Major/breaking 发布（Alex 先创建 release-handoff）|
| `/gate` | Gate 1 (设计前), Gate 2 (handoff 前), Gate 3 (实现后), Gate 4 (验收) |

### 跳过 TAD

- 单文件 Bug 修复、配置调整、文档更新、紧急热修复
- 用户明确说"不用 TAD，直接帮我..."

### Adaptive Complexity

Alex 自动评估复杂度 (Small/Medium/Large/Skip) 并建议流程深度。
**人类做最终决策**，Alex 不可自主决定流程深度。

### Epic/Roadmap

多阶段任务 (需 2+ 个 handoff) → Alex 建议创建 Epic (详见 tad-alex.md)。
**约束**: 同一 Epic 内同时只能有 1 个 Active phase。

---

## 3. Quality Gates 概览

6 条核心规则（详细协议在 /gate 和 agent 命令中）:

规则 0: Alex handoff 前 → 必须苏格拉底式提问 (⚠️ BLOCKING - 未提问直接写 handoff = VIOLATION) (详见 tad-alex.md)
规则 1: Handoff 初稿 → 必须专家审查 + P0 修复 → 再 Gate 2 (详见 tad-alex.md)
规则 2: Blake 实现后 → Gate 3 (详见 tad-gate.md)
规则 3: 集成后 → Gate 4 (详见 tad-gate.md)
规则 4: Gate 不通过 → 阻塞，必须修复
规则 5: Gate 3/4 通过 → 必须包含 Knowledge Assessment（⚠️ BLOCKING - 缺少则 Gate 无效）(详见 tad-gate.md)

**Gate 是强制检查点，不可跳过。**
**禁止**: 仅根据文档描述判定 Gate 4 通过 — 必须调用 subagent 实际验证（禁止纸面验收）。

---

## 4. Terminal 隔离 ⚠️ CRITICAL

Alex = Terminal 1, Blake = Terminal 2。
**人类是 Alex 和 Blake 之间唯一的信息桥梁。**

Alex: 需求分析 → 设计 → 写 handoff → STOP → 等人类传递
Blake: 读 handoff → 实现 → Gate 3/4 → STOP → 等人类反馈

**禁止**:
- ❌ Alex 在同一 terminal 调用 /blake
- ❌ Alex 直接执行实现代码（即使在 Terminal 1 内）
- ❌ Blake 在同一 terminal 调用 /alex
- ❌ Agent 直接与另一 Agent 通信（必须经过人类）

### Alex (Solution Lead) - Terminal 1
- ✅ 需求分析、方案设计、创建 handoff、Gate 1/2/4、验收
- ❌ 不写实现代码、不执行 Blake 的任务

### Blake (Execution Master) - Terminal 2
- ✅ 代码实现、测试、部署、Gate 3
- ❌ 不独立设计、必须基于 handoff

---

## 5. 违规处理

违反以上规则时：
1. **立即停止**当前操作
2. **调用正确的** agent/command
3. **按规范流程**从头重新执行

---

## 6. 执行层协议位置

| 协议 | 位置 |
|------|------|
| 苏格拉底提问、专家审查、Epic 管理、配对测试 | `tad-alex.md` |
| Ralph Loop、并行执行 | `tad-blake.md` |
| Gate 详细检查、Knowledge Assessment、Evidence 规则 | `tad-gate.md` |
| 文档维护、Handoff 清理 | `tad-maintain.md` |
| 版本发布 | `tad-alex.md` (策略) + `tad-blake.md` (执行) |
```

---

## Phase 3: Config 加载优化

### Task 6: Alex 模块加载精简 (5 → 4)

> **专家反馈修正**: config-platform.yaml 包含 `agent_a_tools`（MCP 工作流集成、forbidden_mcp_tools），
> 移除会导致 Alex 丢失 MCP 规则。保留 config-platform，仅去掉 config-execution。

**6a. 修改 tad-alex.md STEP 3**
- 位置: tad-alex.md line 50
- 当前:
```
3. Load required modules: config-agents, config-quality, config-workflow, config-execution, config-platform
```
- 替换为:
```
3. Load required modules: config-agents, config-quality, config-workflow, config-platform
   Note: config-execution (Ralph Loop, failure learning) is Blake-specific.
         Alex references release_duties in this file directly, no need for config-execution.
```

**6b. 修改 config.yaml command_module_binding**
- 位置: config.yaml line 90
- 当前:
```yaml
  tad-alex:
    modules: [config-agents, config-quality, config-workflow, config-execution, config-platform]
    note: "Alex needs all modules for comprehensive design support"
```
- 替换为:
```yaml
  tad-alex:
    modules: [config-agents, config-quality, config-workflow, config-platform]
    note: "Alex needs agents (role), quality (gates), workflow (handoffs/epic), platform (MCP tools). Release duties are inline."
```

**6c. 更新 config-execution.yaml loaded_by**
- 移除 `tad-alex.md  # release planning only`

**~~6d. 更新 config-platform.yaml loaded_by~~**
- ~~移除 `tad-alex.md  # MCP tools`~~ — **保留**，Alex 需要 agent_a_tools

**预期节省**: config-execution (375 行) = **375 行**不再加载

---

## Acceptance Criteria

### Phase 1 验证（补）

| # | 验证项 | 命令 | 预期 |
|---|--------|------|------|
| V1 | derived_status_formula 存在于 tad-alex.md | grep "derived_status_formula" | 1+ 匹配 |
| V2 | knowledge_bootstrap 存在于 tad-alex.md | grep "knowledge_bootstrap" | 1+ 匹配 |
| V3 | reference_for_design 存在于 tad-alex.md | grep "reference_for_design" | 1+ 匹配 |
| V4 | phase_adjustment 存在于 tad-alex.md (via Task 1a) | grep "phase_adjustment" | 1+ 匹配 |
| V4b | epic_file_missing 存在于 tad-alex.md (via Task 1a) | grep "epic_file_missing" | 1+ 匹配 |
| V5 | "不等用户回答" 存在于 tad-alex.md | grep "不等用户回答" | 1 匹配 |
| V6 | Evidence_Naming 存在于 tad-gate.md | grep "Evidence_Naming" | 1+ 匹配 |
| V7 | Recommended_Templates 存在于 tad-gate.md | grep "Recommended_Templates" | 1+ 匹配 |
| V8 | Acceptance_Report_Format 存在于 tad-gate.md | grep "Acceptance_Report_Format" | 1+ 匹配 |
| V9 | Violation_Recovery 存在于 tad-gate.md | grep "Violation_Recovery" | 1+ 匹配 |
| V10 | blake_reference_templates 存在于 tad-blake.md | grep "blake_reference_templates" | 1+ 匹配 |
| V11 | "P0 问题不修复" 存在于 tad-alex.md | grep "P0 问题不修复" | 1 匹配 |
| V12 | usage_rules 存在于 tad-alex.md | grep "usage_rules" | 1+ 匹配 |

### Phase 2 验证（砍）

| # | 验证项 | 命令 | 预期 |
|---|--------|------|------|
| V13 | CLAUDE.md 行数 | wc -l CLAUDE.md | 90-110 行 |
| V14 | 无 "苏格拉底" 详细协议 | grep "问题维度" CLAUDE.md | 0 匹配 |
| V15 | 无 "验收报告模板" | grep "Subagent 审查结果" CLAUDE.md | 0 匹配 |
| V16 | 无 "配对测试" 详情 | grep "skip_criteria" CLAUDE.md | 0 匹配 |
| V17 | 无 "版本发布" 详情 | grep "npm run" CLAUDE.md | 0 匹配 |
| V18 | 有路由表 | grep "触发条件" CLAUDE.md | 1+ 匹配 |
| V19 | 有 Terminal 隔离 | grep "Terminal 隔离" CLAUDE.md | 1+ 匹配 |
| V20 | 有违规处理 | grep "立即停止" CLAUDE.md | 1+ 匹配 |

### Phase 2 额外验证（专家反馈项）

| # | 验证项 | 命令 | 预期 |
|---|--------|------|------|
| V18b | 有 Epic routing stub | grep "Epic/Roadmap" CLAUDE.md | 1+ 匹配 |
| V18c | 有 BLOCKING 标记 | grep "BLOCKING" CLAUDE.md | 2+ 匹配 |
| V18d | 有 VIOLATION 标记 | grep "VIOLATION" CLAUDE.md | 1+ 匹配 |
| V18e | 有 "不通过 Blake" 禁止行为 | grep "不通过 Blake" CLAUDE.md | 1 匹配 |
| V18f | 有 "直接执行实现代码" 禁止行为 | grep "直接执行实现代码" CLAUDE.md | 1 匹配 |
| V18g | 有 "纸面验收" 禁止行为 | grep "纸面验收" CLAUDE.md | 1 匹配 |
| V18h | 有版本发布路由 | grep "release" CLAUDE.md | 1+ 匹配 |

### Phase 3 验证（Config 优化）

| # | 验证项 | 命令 | 预期 |
|---|--------|------|------|
| V21 | Alex 加载 4 模块 | grep "config-agents, config-quality, config-workflow, config-platform" tad-alex.md | 1 匹配 |
| V22 | config.yaml binding 更新 | grep "tad-alex" config.yaml 检查 modules | 4 模块 |
| V23 | config-execution 不引用 alex | grep "tad-alex" config-execution.yaml | 0 匹配 |
| V24 | config-platform 仍引用 alex | grep "tad-alex" config-platform.yaml | 1+ 匹配 |

---

## Files Modified (7 total)

| # | File | Change Type | Phase |
|---|------|-------------|-------|
| 1 | `.claude/commands/tad-alex.md` | Add rules (Tasks 1a-1e, merged 1d into 1a) + 2 completions (Tasks 4a-4b) + STEP 3 update | Phase 1 + 3 |
| 2 | `.claude/commands/tad-gate.md` | Add 4 rules (Tasks 2a-2d) | Phase 1 |
| 3 | `.claude/commands/tad-blake.md` | Add 1 rule (Task 3a) | Phase 1 |
| 4 | `CLAUDE.md` | Full rewrite 657→~100 lines (Task 5) | Phase 2 |
| 5 | `.tad/config.yaml` | Update Alex module binding 5→4 (Task 6b) | Phase 3 |
| 6 | `.tad/config-execution.yaml` | Remove Alex from loaded_by (Task 6c) | Phase 3 |
| 7 | `PROJECT_CONTEXT.md` | Update after completion | Post |

> Note: `.tad/config-platform.yaml` 不再修改（保留 Alex 的 MCP 规则）

## Implementation Order

```
Phase 1 (补):
  并行: Tasks 1a, 1b, 1e, 2a-2d, 3a, 4a
  顺序: Task 1c THEN Task 4b (4b 的插入锚点依赖 1c 的 reference_for_design)
  注意: Task 1d 已合并到 1a
Phase 2 (砍): Task 5 (CLAUDE.md) — 依赖 Phase 1 全部完成
  预处理: 备份 CLAUDE.md → .tad/backups/CLAUDE.md.pre-slim-backup
Phase 3 (优化): Task 6 (config) — 独立于 Phase 2
```

---

## Risk Assessment

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 补进 agent 文件的规则位置不对 | 规则被忽略 | 验证清单 V1-V12 逐条确认 + Task 1a 合并后避免行号漂移 |
| CLAUDE.md 精简后丢失某触发行为 | 流程断裂 | Phase 1 先完成，Phase 2 前备份 CLAUDE.md，逐 section 对照 |
| Config 减载后 Alex 缺少信息 | 功能退化 | 保留 config-platform（含 MCP 规则），仅去掉 config-execution |
| CLAUDE.md 太精简导致 Claude 不遵守 | 规则失效 | 保留 BLOCKING/VIOLATION/CRITICAL 标记和禁止行为清单（~100 行而非 85 行）|
| 执行层规则修改后语义漂移 | 规则弱化 | Phase 2 前验证: V18b-V18h 确认 enforcement markers 存在 |
