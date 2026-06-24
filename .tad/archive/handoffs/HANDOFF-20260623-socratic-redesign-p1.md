---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-23
**Project:** TAD Framework
**Task ID:** TASK-20260623-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260623-community-pattern-adoption.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-23

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三阶段 co-definition 模型完整定义 |
| Components Specified | ✅ | 每阶段的问题/选项/格式明确 |
| Functions Verified | ✅ | 改动仅涉及 YAML 协议文件，无函数调用 |
| Data Flow Mapped | ✅ | ICP 从 Socratic → Design → Handoff 的传递路径明确 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
重新设计 Socratic Inquiry Protocol，从"审问模式"（Alex 问开放题，用户答）变为"共同定义模式"（Alex 做分析工作，用户提供方向并确认）。

### 1.2 Why We're Building It
**业务价值**：用户反馈当前苏格拉底提问有 4 个痛点——太抽象难回答、和任务不匹配、缺少关键维度（ICP）、问答形式不对（开放问题应该是选项确认）。
**用户受益**：提问变成协作式，用户只需回答自己能回答的问题，Alex 负责分析性工作。
**成功的样子**：当用户走完 Socratic 流程后，觉得问题被问到了点上，而且不需要回答自己答不了的问题。

### 1.3 Intent Statement

**真正要解决的问题**：当前提问在错误的维度上要求用户回答——风险预见、验收标准、技术约束这些是 Alex 应该分析的，不是拿来问用户的。同时缺少最关键的问题——"给谁用"（ICP）。

**不是要做的**：
- ❌ 不是完全删除苏格拉底提问
- ❌ 不是改变 Gate 结构或 Blake 的协议
- ❌ 不是改变 adaptive_complexity_protocol（复杂度评估不变）

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - 协议架构变更

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 2 条 | Judgment-Only Skill Files + Circular Trigger |
| patterns/handoff-design.md | 1 条 | Circular Trigger Pattern |

**⚠️ Blake 必须注意的历史教训**：

1. **Judgment-Only Skill Files** (来自 principles.md)
   - 问题：约束规则不能在精简时被移除
   - 相关：重写 socratic-inquiry-protocol.md 时，保留 blocking: true 和 violations 列表

2. **Circular Trigger Pattern** (来自 patterns/handoff-design.md)
   - 问题：如果 load_when 引用了文件内定义的概念，就会形成循环触发
   - 相关：socratic-inquiry-protocol.md 是从 SKILL.md 提取的 reference，其 load_when 是非循环的（由 adaptive_complexity 触发）——重写时保持这个触发路径不变

---

## 2. Background Context

### 2.1 Previous Work
- 当前 socratic-inquiry-protocol.md: 6 个维度（value_validation, boundary_clarification, risk_foresight, acceptance_criteria, user_scenarios, technical_constraints）
- 每个维度有 2-3 个开放式问题
- 复杂度分三级：small(2-3问), medium(4-5问), large(6-8问)

### 2.2 Current State
用户反馈：
- "价值验证类问题太开放，应该参考 product-thinking 共同定义"
- "风险预见/验收标准 — 最形式化，用户答不了"
- "技术约束 — 用户不管技术问题"
- "缺少 ICP（给谁用）"
- "所有任务类型都感觉问题不匹配"

### 2.3 Dependencies
- adaptive-complexity-protocol.md（需小改：更新维度名引用）
- design-protocol.md step3（需小改，加 ICP 引用）

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: 重新组织提问为三阶段 co-definition 模型
- FR2: Phase 1 UNDERSTAND（用户主导）：ICP 锚定 + 问题共同定义
- FR3: Phase 2 SCOPE（共创）：Alex 提出范围建议，用户确认/调整
- FR4: Phase 3 VALIDATE（Alex 主导）：Alex 呈现风险分析 + 起草 AC，用户确认
- FR5: 技术约束从用户问题移除（Alex 内部处理）
- FR6: 所有问题尽量用 AskUserQuestion 选项式，减少纯开放问题

### 3.2 Non-Functional Requirements
- NFR1: 保持现有复杂度分级（small/medium/large 的问题数量控制）
- NFR2: 保留 blocking: true 和 violations 列表（约束规则）
- NFR3: 保持与 SKILL.md 中 socratic_inquiry_protocol reference 的兼容性

---

## 4. Technical Design

### 4.1 新三阶段结构

```yaml
co_definition_model:
  phase1_understand:
    name: "理解"
    leader: "user + Alex 共创"
    questions:
      q1_icp:
        dimension: "用户画像锚定"
        format: AskUserQuestion (4 options)
        question: "这个设计/功能是给谁用的？"
        options:
          - "我来定义" → 用户提供 ICP，统一格式：[角色]在[场景]中需要[能力]，最关心[关注点]
          - "TAD 内部：未来零上下文的我" → 自动填充为 "Solo developer returning after 3+ months with no session context. Cares about: understanding what this does and why without reading commit history."
          - "帮我推断" → Alex 从已有上下文推断，输出同一 ICP 格式，用户确认
          - "跳过 ICP" → skip，合法无惩罚
        stored_as: "icp_anchor — 存储在 Socratic 输出摘要的 ICP 行中，通过对话上下文传递到 design phase，无需文件持久化"
        icp_format: "[角色]在[场景]中需要[能力]，最关心[关注点]"
        downstream: "设计阶段用作检验锚点（design-protocol step3 检查对话上下文中是否有 icp_anchor）"
        task_type_skip: |
          如果 adaptive_complexity 检测到任务属于 bug_fix / refactor / doc_update 类型，
          Q1 自动跳过或自动填充为"开发者本人"。不问用户。
          判断依据：intent_router 已识别的 route（*bug → skip, *analyze → ask）。
      
      q2_problem:
        dimension: "问题共同定义"
        format: "开放问题 + 条件追问精炼"
        question: "你想解决什么问题？描述一个具体场景。"
        goal: "从模糊的'我想做 X'精炼为'当[场景]时，[ICP]需要[能力]，但现在[障碍]'"
        note: "参考 product-thinking /define 的结构化问题定义方法——协作式，不是审问式"
        vague_detection:
          description: "判断用户回答是否需要追问的两个触发条件"
          trigger_1: "回答只描述意图/想法，没有具体场景（缺'当X时'的情境描述）"
          trigger_2: "回答描述了场景但没有障碍/痛点（缺'但现在Y'的问题描述）"
          action_if_triggered: |
            追问："能描述一个具体的场景吗？比如你在做 X 的时候遇到了什么困难？"
            如果二次回答仍触发任一条件：记录当前答案并继续（不再追问，max 1 次追问）
          action_if_not_triggered: "回答包含场景+障碍 → 直接进入 Q3"

  phase2_scope:
    name: "范围"
    leader: "Alex 提议，user 确认"
    questions:
      q3a_scope:
        dimension: "正向范围确认"
        format: AskUserQuestion
        action: "Alex 基于 Q1+Q2 分析后提出核心范围"
        question: "基于你的描述，我理解的核心范围是 [X]。对吗？"
        options:
          - "对，就是这样"
          - "范围需要调整" → Alex 追问哪里要调
          - "还缺少东西" → 用户补充
      q3b_exclusion:
        dimension: "排除项确认"
        format: AskUserQuestion
        action: "确认正向范围后，单独确认排除项（防止锚定效应掩盖遗漏）"
        question: "我理解以下不在本次范围内：[Y]。有什么我列为排除但你实际需要的吗？"
        options:
          - "确认，这些不做"
          - "其中 [Z] 其实需要" → 移回范围
          - "都需要做" → 调整范围

  phase3_validate:
    name: "验证"
    leader: "Alex 主导分析，user 确认"
    questions:
      q4_risk:
        dimension: "风险分析（两步防锚定）"
        format: "用户先答 + Alex 呈现 + AskUserQuestion 确认"
        step_1_blind_spot:
          action: "在 Alex 分析之前，先捕获用户自己看到的风险"
          question: "在我分析之前——你最担心的是什么？用一句话描述。"
          format: "开放问题（不给选项，防止锚定）"
          if_no_concern: "'没什么特别担心的' 也是有价值的信号，记录后继续"
        step_2_present:
          action: "Alex 内部分析风险，呈现时整合用户在 step_1 提到的担忧"
          presentation: "我识别到的风险：1. [risk A] 2. [risk B]。其中 [你提到的 C] 我也确认了。"
          question: "还有我遗漏的吗？"
          options:
            - "没有了"
            - "还有一个" → 用户补充
        note: "两步顺序不可颠倒——用户必须在看到 Alex 分析前独立思考，防止 anchoring 屏蔽真实盲点"

      q5_ac:
        dimension: "验收标准"
        format: "Alex 起草 + AskUserQuestion 确认"
        action: "Alex 基于 Q1-Q4 起草验收标准"
        presentation: "我建议的验收标准：1. [AC1] 2. [AC2] 3. [AC3]。"
        question: "这些标准对吗？"
        options:
          - "确认"
          - "需要修改某条" → 用户指定哪条怎么改
          - "还缺少一条" → 用户补充
    
    removed:
      technical_constraints:
        reason: "用户不管技术问题——Alex 内部调研，结果直接写入 design/handoff"
        migration: "移到 design-protocol step3 作为 Alex 的内部步骤"
      user_scenarios:
        reason: "吸收进 Q2（问题定义含具体场景）和 Q4（风险分析含边界/误用场景）"
        migration: "Q2 的 vague_detection 确保场景被捕获；Q4 的风险分析覆盖边界情况"

  # 格式选择规则（指导 Blake 在实现中遇到边界情况时的判断依据）
  format_selection_rules:
    options: "答案集合可穷举且≤4个 → AskUserQuestion 选项"
    open: "答案需要用户提供具体信息（场景、内容、描述） → 开放问题"
    present_confirm: "Alex 已做分析，用户只需接受/修正 → 呈现+确认"
    hybrid: "Q4 风险的两步模式——先开放（捕获盲点），再呈现+确认（补充分析）"
```

### 4.2 复杂度分级保持

```yaml
complexity_mapping:
  small:
    question_count: "2-3"
    which_questions: "Q2(problem) + Q3a(scope 快速确认)"
    skip: "Q1(ICP — auto-skip per task_type_skip) + Q3b(exclusion) + Q4(risk) + Q5(AC) — Alex 内部处理不问用户"
    output_summary: "Q4/Q5 行显示 'Alex 内部处理' 或省略"
  medium:
    question_count: "4-5"
    which_questions: "Q1 + Q2 + Q3a + Q3b + Q4(两步) + Q5(确认)"
  large:
    question_count: "6+ (Q2 有追问轮)"
    which_questions: "全部，Q2 问题定义可能需要 2-3 轮精炼"
```

### 4.3 Design Protocol 集成

在 design-protocol.md step3 (Architecture Design) 中加入：
```yaml
step3:
  name: "Create Architecture Design"
  action: |
    If icp_anchor was defined in Socratic Inquiry:
      Use as design test anchor throughout architecture decisions.
      For each major design decision, ask: "Would [ICP] understand/value this?"
    Design system architecture, data flow, API contracts.
```

### 4.4 Output Summary 格式（新增，修复 CR P1-1）

当前协议有 output_summary 生成 "Socratic Inquiry Summary" 表格。新协议的摘要格式：

```yaml
output_summary:
  format: |
    ## Socratic Inquiry Summary (Co-Definition)
    
    | 阶段 | 问题 | 结果 |
    |------|------|------|
    | Phase 1 | Q1 ICP | {icp_anchor 或 "skipped" 或 "auto: 开发者本人"} |
    | Phase 1 | Q2 Problem | {精炼后的问题定义} |
    | Phase 2 | Q3a Scope | {确认的范围} |
    | Phase 2 | Q3b Exclusion | {确认的排除项} |
    | Phase 3 | Q4 Risk (user) | {用户的担忧 或 "无特别担心"} |
    | Phase 3 | Q4 Risk (Alex) | {Alex 分析的风险} |
    | Phase 3 | Q5 AC | {确认的验收标准} |
    
    **ICP Anchor**: {icp_anchor 全文，或 "N/A"}
  note: "small 任务跳过的行显示 'Alex 内部处理' 或省略。icp_anchor 通过此摘要在对话上下文中传递到 design phase。"
```

### 4.5 Execution 流程（新增，修复 CR P1-4）

替换当前协议的 5-step execution flow：

```yaml
execution:
  step1:
    name: "Complexity Assessment"
    action: "不变——由 adaptive_complexity_protocol 决定 small/medium/large"
  step2:
    name: "Phase 1 — Understand"
    action: |
      根据复杂度执行：
      - small: Q2 only (Q1 auto-skip per task_type_skip)
      - medium/large: Q1 → Q2 (large 时 Q2 可追问)
  step3:
    name: "Phase 2 — Scope"
    action: |
      - small: Q3a 快速确认 (skip Q3b)
      - medium/large: Q3a → Q3b
  step4:
    name: "Phase 3 — Validate"
    action: |
      - small: skip (Alex 内部处理 risk + AC)
      - medium/large: Q4 两步 (user blind spot → Alex analysis) → Q5
  step5:
    name: "Output Summary + Confirmation"
    action: "生成 output_summary 表格，确认用户满意后进入 *design"
```

### 4.6 Adaptive Complexity Protocol 更新（新增，修复 CR P0-2）

adaptive-complexity-protocol.md 中引用了旧维度名，需同步更新：

```yaml
changes:
  line_151_152:
    old: "(risk_foresight, user_scenarios, edge cases)"
    new: "(Q4 risk blind-spot, Q3b exclusion gaps, edge cases)"
  line_38_214:
    old: "6-8 questions / ALL dimensions"
    new: "6+ questions (with follow-up rounds) / all phases Q1-Q5"
```

---

## 6. Implementation Steps

### Phase 1: 重写 socratic-inquiry-protocol.md（预计 30 分钟）

#### 交付物
- [ ] socratic-inquiry-protocol.md 完全重写为三阶段 co-definition 模型
- [ ] 保留 blocking, violations, complexity_detection 等约束规则
- [ ] 保留文件头注释（extraction source reference）

#### 实施步骤
1. Read 当前 socratic-inquiry-protocol.md 完整内容
2. 保留 description, blocking, violations, purpose 等头部
3. 重写 question_dimensions → 替换为 co_definition_model（按 §4.1 结构）
4. 更新 complexity_detection → 映射到新的 Q1-Q5（按 §4.2）
5. 更新 execution flow → 反映三阶段顺序
6. 保留文件末尾的任何 integration 说明

### Phase 2: 更新 design-protocol.md（预计 10 分钟）

#### 交付物
- [ ] step3 增加 ICP anchor 引用

#### 实施步骤
1. Read design-protocol.md
2. 在 step3 action 中加入 ICP 引用（按 §4.3）

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/alex/references/socratic-inquiry-protocol.md    # Full rewrite: 6-dimension Q&A → 3-phase co-definition
.claude/skills/alex/references/design-protocol.md               # step3: add ICP anchor reference
.claude/skills/alex/references/adaptive-complexity-protocol.md  # Update dimension name refs + question counts
.agents/skills/alex/references/socratic-inquiry-protocol.md     # Mirror of .claude/ copy
.agents/skills/alex/references/design-protocol.md               # Mirror of .claude/ copy
.agents/skills/alex/references/adaptive-complexity-protocol.md  # Mirror of .claude/ copy
```

### 7.3 Grounded Against

- .claude/skills/alex/references/socratic-inquiry-protocol.md (226 lines, read at 2026-06-23)
- .claude/skills/alex/references/design-protocol.md (178 lines, read at 2026-06-23)
- .claude/skills/alex/references/adaptive-complexity-protocol.md (226 lines, read at 2026-06-23)

---

## 8. Testing Requirements

### 8.1 验证方法
- 文件格式验证：YAML 结构有效（手动检查缩进和语法）
- 约束保留验证：grep 确认 blocking, violations 仍存在
- 维度完整性：新文件包含 Q1-Q5 全部定义

### 8.4 Friction Preflight

No friction-sensitive prerequisites identified. All changes are to YAML/markdown protocol files within the TAD repo.

### 8.5 Feedback Collection

```yaml
feedback_required: false
```

---

## 9. Acceptance Criteria

- [ ] AC1: socratic-inquiry-protocol.md 包含三阶段结构（phase1_understand, phase2_scope, phase3_validate）
- [ ] AC2: Q1(ICP) 使用 AskUserQuestion 4 选项格式，含 task_type_skip 逻辑
- [ ] AC3: Q2(问题定义) 有 vague_detection 触发条件（trigger_1 + trigger_2）和 max 1 次追问限制
- [ ] AC4: Q4(风险) 是两步防锚定：先开放问用户担忧，再 Alex 呈现分析
- [ ] AC5: 技术约束和 user_scenarios 不再作为独立维度（在 removed 段说明迁移去向）
- [ ] AC6: blocking: true 和 violations 列表保留
- [ ] AC7: 复杂度分级 (small/medium/large) 映射到新 Q1-Q5，small 跳过 Q1/Q3b/Q4/Q5
- [ ] AC8: design-protocol.md step3 包含 ICP anchor 引用
- [ ] AC9: output_summary 格式更新为阶段式表格（含 icp_anchor 行）
- [ ] AC10: execution 流程更新为 5-step（Assess → Understand → Scope → Validate → Summary）
- [ ] AC11: adaptive-complexity-protocol.md 维度名引用更新（risk_foresight → Q4, user_scenarios → removed）
- [ ] AC12: .agents/ 镜像文件与 .claude/ 字节一致（diff exit 0）

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| 1 | 三阶段结构存在 | post-impl-verifiable | `grep -c 'phase[123]_' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥3 | (post-impl) |
| 2 | ICP 4 选项 | post-impl-verifiable | `grep -c '跳过 ICP\|帮我推断\|我来定义\|TAD 内部' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥3 | (post-impl) |
| 3 | vague_detection 触发条件 | post-impl-verifiable | `grep -c 'trigger_1\|trigger_2\|vague_detection' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥2 | (post-impl) |
| 4 | Q4 两步防锚定 | post-impl-verifiable | `grep -c 'blind_spot\|step_1.*step_2\|在我分析之前' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥1 | (post-impl) |
| 5 | 技术约束移除 | post-impl-verifiable | `grep 'technical_constraints' .claude/skills/alex/references/socratic-inquiry-protocol.md \| grep -v 'removed\|reason\|migration' \| wc -l` | 0 | (post-impl) |
| 6 | blocking 保留 | post-impl-verifiable | `grep -c 'blocking: true' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥1 | (post-impl) |
| 7 | violations 保留 | post-impl-verifiable | `grep -c 'violations' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥1 | (post-impl) |
| 8 | 复杂度分级 | post-impl-verifiable | `grep -c 'small:\|medium:\|large:' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥3 | (post-impl) |
| 9 | ICP in design | post-impl-verifiable | `grep -c 'icp_anchor\|ICP' .claude/skills/alex/references/design-protocol.md` | ≥1 | (post-impl) |
| 10 | output_summary 格式 | post-impl-verifiable | `grep -c 'output_summary\|Socratic Inquiry Summary' .claude/skills/alex/references/socratic-inquiry-protocol.md` | ≥1 | (post-impl) |
| 11 | adaptive-complexity 更新 | post-impl-verifiable | `grep -c 'risk_foresight\|user_scenarios' .claude/skills/alex/references/adaptive-complexity-protocol.md` | 0 | (post-impl) |
| 12 | .agents/ 镜像一致 | post-impl-verifiable | `diff .claude/skills/alex/references/socratic-inquiry-protocol.md .agents/skills/alex/references/socratic-inquiry-protocol.md` | exit 0 (no diff) | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Experts Selected

1. **code-reviewer** — Protocol file restructure needs structural integrity review (backward compat, file mirrors, dimension name references)
2. **product-expert** — Interaction design review (does the co-definition model solve the user's 4 pain points?)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| product-expert | P0: Q4 risk is "confirmation theater" — anchoring blocks real blindspot discovery | §4.1 q4_risk rewritten as two-step (user blind spot first, then Alex analysis) | Resolved |
| product-expert | P0: Q2 vague detection has no trigger conditions | §4.1 q2_problem.vague_detection added with trigger_1 + trigger_2 + max 1 follow-up | Resolved |
| product-expert | P1: Q1 ICP feels forced for bug/refactor/doc tasks | §4.1 q1_icp.task_type_skip added — auto-skip for bug_fix/refactor/doc_update | Resolved |
| product-expert | P1: Q3 exclusion list anchoring risk | §4.1 q3a/q3b split — scope confirmed first, exclusions confirmed separately | Resolved |
| product-expert | P1: Format selection rules missing | §4.1 format_selection_rules added (options/open/present-confirm/hybrid) | Resolved |
| product-expert | P2: ICP unified output format | §4.1 q1_icp.icp_format added — all options output same structure | Resolved |
| product-expert | P2: "太多了/太少了" is one option but two directions | §4.1 q5_ac options split to "需要修改某条" + "还缺少一条" | Resolved |
| code-reviewer | P0: .agents/ mirror files missing from §7 | §7.1 updated — 3 .agents/ mirror files added + AC12 diff check | Resolved |
| code-reviewer | P0: adaptive-complexity-protocol.md refs old dimension names | §4.6 added with specific line changes + §7.1 file added + AC11 | Resolved |
| code-reviewer | P0: Expert review section blank | §9.2 filled (this table) | Resolved |
| code-reviewer | P1: output_summary unspecified | §4.4 added with full table format + icp_anchor storage note + AC9 | Resolved |
| code-reviewer | P1: AC5 verification fragile | §9.1 row 5 rewritten: grep + grep -v removed/migration | Resolved |
| code-reviewer | P1: icp_anchor storage path unclear | §4.1 q1_icp.stored_as clarified — output summary, conversation context, no file | Resolved |
| code-reviewer | P1: execution flow spec missing | §4.5 added with 5-step flow mapping to new phases + AC10 | Resolved |
| code-reviewer | P2: user_scenarios drop undocumented | §4.1 removed section added user_scenarios with migration note | Resolved |

### Overall Assessment (post-integration)

- **code-reviewer**: PASS (3 P0 resolved, 4 P1 resolved, 1 P2 resolved)
- **product-expert**: PASS (2 P0 resolved, 3 P1 resolved, 2 P2 resolved)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 不要删除 blocking: true 和 violations 列表——这些是约束规则，不是可选内容
- ⚠️ 保留文件头的 extraction source 注释（来源追溯）
- ⚠️ 不要修改 SKILL.md 中的 socratic_inquiry_protocol section（load_when trigger 不变）

### 10.2 Known Constraints
- adaptive_complexity_protocol 不改——复杂度评估流程保持不变
- 新协议必须兼容 SKILL.md 的 integration 说明（depth OVERRIDES internal complexity_detection）

---

## 11. Decision Rationale

### 11.1 为什么从"审问"改为"共同定义"

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 共同定义（选中）| 用户只答能答的；Alex 做分析工作 | 对 Alex 分析能力要求更高 | ✅ 选中 |
| 优化现有问题 | 改动小 | 不解决根本问题（形式不对） | 治标不治本 |
| 删掉苏格拉底 | 最快 | 失去盲点发现能力 | 核心价值不能丢 |

### 11.2 为什么 ICP 放在 Socratic 而不是 Design

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 放在 Socratic Q1（选中）| 最早锚定；自然；零新步骤 | — | ✅ 选中 |
| 放在 Design step1_3 | 显式独立步骤 | 增加 design protocol 复杂度；锚定太晚 | 用户建议放 Socratic 更好 |

**💡 核心洞察**：用户的关键反馈是"有些问题用户答不了"——这不是问题质量差，而是**问错了对象**。风险/AC/技术约束是分析性工作，应该由 Alex 做完呈现给用户确认。

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-23
**Version**: 3.1.0
