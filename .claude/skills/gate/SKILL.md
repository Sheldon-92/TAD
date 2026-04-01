---
name: gate
description: Execute TAD Quality Gate. Gate 1 (pre-design), Gate 2 (pre-handoff), Gate 3 (post-implementation), Gate 4 (acceptance).
---

# /gate Command (Execute Quality Gate)
# Note: Gate 3/4 will NOT pass without their respective evidence files in .tad/evidence/reviews/

## 🎯 自动触发条件

**Claude 应主动调用此 skill 的场景：**

### 必须执行 Gate 的时机
- **Gate 1**: Alex 完成 3-5 轮需求挖掘后，**进入设计前**
- **Gate 2**: Alex 完成设计，**创建 handoff 前**
- **Gate 3**: Blake 完成实现，**提交代码前**
- **Gate 4**: Blake 完成集成，**交付用户前**

### ⚠️ 强制规则
```
规则 1: Alex 创建 handoff → 必须先执行 Gate 2
规则 2: Blake 完成实现 → 必须执行 Gate 3
规则 3: Blake 完成集成 → 必须执行 Gate 4
规则 4: Gate 不通过 → 阻塞下一步，必须修复
```

### 如何激活
```
场景 1: Alex 准备创建 handoff
Alex: 设计已完成，准备创建 handoff
     → 必须先调用 /gate 2
     [调用 Skill tool with skill="tad-gate" args="2"]

场景 2: Blake 实现完成
Blake: 代码已实现，准备提交
      → 必须先调用 /gate 3
      [调用 Skill tool with skill="tad-gate" args="3"]
```

**核心原则**: Gate 是强制检查点，不可跳过

---

When this command is triggered, execute the appropriate quality gate based on current context:

## Gate Detection and Execution

```
Quality Gate Execution
======================

Detecting current context...

Available Gates:
1. Gate 1: Requirements Clarity (Agent A - After elicitation)
2. Gate 2: Design Completeness (Agent A - Before handoff)
3. Gate 3: Implementation Quality (Agent B - After coding)
4. Gate 4: Integration Verification (Agent B - Before delivery)

Which gate to execute? (1-4):
```

## Gate 1: Requirements Clarity (Alex) - Optional Quick Check
```yaml
When: After requirement elicitation
Owner: Agent A (Alex)
Quick Check (3 items):
  - [ ] User confirmed understanding
  - [ ] Success criteria defined
  - [ ] Requirements documented
Output: Quick summary, no formal evidence required
```

## Gate 2: Design Completeness (Alex) - **MANDATORY** 🔴
```yaml
When: Before creating handoff (BLOCKING)
Owner: Agent A (Alex)
Critical Check (4 items):
  - [ ] Architecture complete
  - [ ] Components specified
  - [ ] Functions verified (exist in codebase)
  - [ ] Data flow mapped
Evidence: Record in handoff header
Output Format:
  ### Gate 2 Result
  | Item | Status | Note |
  |------|--------|------|
  | Architecture | ✅ Pass | ... |
  | Components | ✅ Pass | ... |
  | Functions | ⚠️ Partial | 缺少 xxx |
  | Data Flow | ✅ Pass | ... |
```

## Gate 3: Implementation Quality (Blake) - **MANDATORY** 🔴
```yaml
When: After implementation (BLOCKING)
Owner: Agent B (Blake)

# ⚠️ PREREQUISITE CHECK (BLOCKING)
Prerequisite:
  check: "Completion Report 是否存在？"
  location: ".tad/active/handoffs/COMPLETION-*.md"

  if_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法执行 - 缺少 Completion Report

      必须先创建 Completion Report 才能执行 Gate 3。
      请执行 *complete 命令创建报告，然后重新执行 Gate 3。

      Completion Report 应包含：
      - 实际完成的任务列表
      - 与 Handoff 计划的差异
      - 遇到的问题和解决方案
      - 测试执行结果
    result: "BLOCKED - 等待 Completion Report"

  if_exists:
    action: "继续执行 Gate 3 检查项"

# ⚠️ REQUIRED SUBAGENT CALL (BLOCKING)
Required_Subagent:
  subagent: "test-runner"
  action: "MUST call test-runner subagent before Gate 3 can pass"
  template: ".tad/templates/output-formats/testing-review-format.md"
  output_to: ".tad/evidence/reviews/{date}-testing-review-{task}.md"

  if_not_called:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法通过 - 缺少 test-runner 审查

      必须调用 test-runner subagent 并生成审查报告。
      报告输出位置：.tad/evidence/reviews/{date}-testing-review-{task}.md

      执行步骤：
      1. 调用 test-runner subagent
      2. 使用 testing-review-format 模板输出
      3. 保存到 .tad/evidence/reviews/ 目录
      4. 重新执行 Gate 3

# ⚠️ ACCEPTANCE VERIFICATION CHECK (BLOCKING)
Acceptance_Verification:
  check: "验收验证报告是否存在且全部 PASS？"
  location: ".tad/evidence/acceptance-tests/{task_id}/acceptance-verification-report.md"

  if_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法通过 - 缺少验收验证报告

      Blake 必须：
      1. 读取 Handoff 的 Acceptance Criteria
      2. 为每条标准生成验证脚本
      3. 执行所有验证
      4. 生成 acceptance-verification-report.md
      5. 全部 PASS 后重新执行 Gate 3

  if_exists:
    checks:
      - "报告中 FAIL 数量 = 0"
      - "报告中标准数量 = Handoff 中 Acceptance Criteria 数量（不遗漏）"
    on_mismatch:
      action: "BLOCK Gate 3"
      message: "验收验证未全部通过或有遗漏标准"

# ⚠️ RISK TRANSLATION CHECK (Cognitive Firewall - Pillar 3)
Risk_Translation:
  description: "Detect fatal operations and translate code changes to business consequences"
  config: ".tad/config-cognitive.yaml → fatal_operations"
  blocking: "Only for critical severity (forced_review = true)"

  check_process:
    step0_handoff_intent: "Read handoff task descriptions — operations matching handoff intent are EXPECTED, not blocked (P0-3 FIX)"
    step1: "Read config-cognitive.yaml fatal_operations (universal_preset + project_custom)"
    step2: "Scan all changed files against safety_net paths and patterns"
    step2b: "For each match, cross-check against step0 handoff intent — skip EXPECTED operations"
    step3: "For remaining matches, generate risk translation (one-liner + risk card)"
    step4_decision: |
      IF critical matches found:
        → BLOCK Gate until human reviews and approves
        → Present risk cards to human
        → Human must explicitly approve: "I understand the risk, proceed"
      IF high matches found:
        → WARNING but not blocking
        → Include in Gate output for human awareness
      IF no matches:
        → PASS (note: "No fatal operations detected")

  output_format:
    gate3_addition: |
      #### Risk Translation (Cognitive Firewall)
      | # | Operation | Severity | Business Impact | Human Review |
      |---|-----------|----------|-----------------|--------------|
      | 1 | {op} | 🔴 Critical | {impact} | ✅ Approved / ⏳ Pending |

      {If critical items: show risk cards below the table}

# ⚠️ GIT COMMIT VERIFICATION CHECK (BLOCKING)
Git_Commit_Verification:
  check: "Implementation changes committed to git?"
  method: "Check completion report for commit hash, AND verify via git log"

  if_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法通过 - 实现代码未 commit

      Blake 必须在 Gate 3 之前执行 git commit (step3c)。
      请执行 step3c (Git Commit Implementation) 然后重新执行 Gate 3。

  if_exists:
    checks:
      - "commit_hash is not empty and not 'NONE' (unless doc-only handoff)"
      - "If commit_hash is a real hash: verify via `git log --oneline -1 {hash}` returns valid output"
      - "If commit_hash is 'NONE': verify handoff has no 'Files to Create/Modify' entries (truly doc-only)"
    on_valid: "PASS"
    on_invalid: "BLOCK - commit hash not found in git history or doc-only claim invalid"

# Gate 3 检查项（Prerequisite, Subagent, Acceptance Verification 要求通过后执行）
Critical Check (5 items):
  - [ ] Code complete (all handoff tasks done)
  - [ ] Tests pass (no failing tests)
  - [ ] Standards met (linting, formatting)
  - [ ] Evidence file exists (.tad/evidence/reviews/*-testing-review-*.md)
  - [ ] Knowledge Assessment complete (BLOCKING - must answer explicitly)
Evidence: Record in completion report + evidence file
Output Format:
  ### Gate 3 Result

  #### Prerequisite
  | Check | Status |
  |-------|--------|
  | Completion Report | ✅ 存在 |

  #### Subagent Evidence Check
  | Subagent | Called | Evidence File | Status |
  |----------|--------|---------------|--------|
  | test-runner | ✅ Yes | {date}-testing-review-{task}.md | ✅ Exists |

  #### Acceptance Verification
  | Check | Status |
  |-------|--------|
  | Report exists | ✅ / ❌ |
  | All criteria covered | {N}/{N} |
  | All PASS | {P} PASS, {F} FAIL |

  #### Git Commit Verification
  | Check | Status | Detail |
  |-------|--------|--------|
  | Changes committed | ✅ / ❌ | commit_hash: {hash} or NONE (doc-only) |

  #### Quality Checks
  | Item | Status | Note |
  |------|--------|------|
  | Code Complete | ✅ Pass | ... |
  | Tests Pass | ✅ Pass | ... |
  | Standards | ✅ Pass | ... |
  | Evidence | ✅ Pass | File exists |

  #### Knowledge Assessment (MANDATORY - must answer)
  | Question | Answer | Action |
  |----------|--------|--------|
  | New discoveries? | ✅ Yes / ❌ No | If Yes: recorded to .tad/project-knowledge/{category}.md |
  | Category | {category} or N/A | ... |
  | Brief summary | {1-line summary} | ... |

# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 3)
# 必须在 Gate 结果表格中显式回答，不可跳过
Knowledge_Assessment:
  blocking: true
  description: "Gate 3 无法 PASS 除非 Knowledge Assessment 表格已填写"

  mandatory_questions:
    - question: "本次实现是否有新发现？"
      must_answer: true
      options:
        - "✅ Yes - 有新发现"
        - "❌ No - 常规实现，无特殊发现"

    - question: "如果有，属于哪个类别？"
      must_answer: "if previous is Yes"
      options: "从 .tad/project-knowledge/ 目录读取"

    - question: "一句话总结"
      must_answer: true
      note: "即使无新发现，也要写明原因（如：常规 CRUD 实现）"

  evaluation_criteria:
    should_record_if:
      - "遇到了意外问题并解决（surprise factor）"
      - "发现了可复用的模式或反模式"
      - "做出了影响未来开发的技术决策"
      - "同类问题可能再次出现（recurrence）"
      - "花了 >30 分钟解决的问题"

    can_skip_if:
      - "纯粹的 CRUD 操作"
      - "完全按照 handoff 执行，无任何偏差"
      - "已有完全相同的记录"

  if_new_discovery:
    step1: "读取 .tad/project-knowledge/ 目录，列出所有可用类别"
    step2: "确定分类（或选择创建新类别）"
    step3: "写入对应的 .tad/project-knowledge/{category}.md"
    step4: "使用标准格式"

  entry_format: |
    ### [简短标题] - [YYYY-MM-DD]
    - **Context**: 在做什么任务
    - **Discovery**: 发现了什么
    - **Action**: 建议未来如何处理

  violation: "Gate 3 结果表格中没有 Knowledge Assessment 部分 = VIOLATION = Gate 无效"

# ⚠️ POST-PASS ACTIONS
Post_Pass_Actions:
  trigger: "Gate 3 所有检查项 PASS（包括 Knowledge Assessment）"

  update_next_md:
    action: "更新 NEXT.md 反映实现完成状态"
    steps:
      - "标记已完成的实现任务为 [x]"
      - "添加测试/集成相关的后续任务"
      - "移动阻塞项到 Blocked 分类（如有）"
    format: "English only"
```

## Gate 4: Integration Verification (Blake + Alex) - **MANDATORY** 🔴
```yaml
When: Before delivery (BLOCKING)
Owner: Agent B (Blake) executes, Agent A (Alex) verifies with subagents

# ⚠️ PREREQUISITE CHECK (BLOCKING)
Prerequisite:
  check: "Gate 3 是否已通过？"
  evidence: ".tad/evidence/reviews/*-testing-review-*.md exists"

  if_missing:
    action: "BLOCK Gate 4"
    message: |
      ⚠️ Gate 4 无法执行 - Gate 3 未完成

      必须先完成 Gate 3 并生成测试审查证据。
    result: "BLOCKED - 等待 Gate 3 完成"

# ⚠️ REQUIRED SUBAGENT CALLS (BLOCKING)
Required_Subagents:
  - subagent: "security-auditor"
    required: true
    template: ".tad/templates/output-formats/security-review-format.md"
    output_to: ".tad/evidence/reviews/{date}-security-review-{task}.md"

  - subagent: "performance-optimizer"
    required: true
    template: ".tad/templates/output-formats/performance-review-format.md"
    output_to: ".tad/evidence/reviews/{date}-performance-review-{task}.md"

  - subagent: "code-reviewer"
    required: true
    output_to: ".tad/evidence/reviews/{date}-code-review-{task}.md"

  - subagent: "ux-expert-reviewer"
    required: "if UI involved"
    output_to: ".tad/evidence/reviews/{date}-ux-review-{task}.md"

# Evidence File Naming Convention
Evidence_Naming:
  pattern: ".tad/evidence/reviews/{YYYY-MM-DD}-{type}-{brief-description}.md"
  types: [testing-review, security-review, performance-review, code-review, ux-review]
  examples:
    - "2026-02-01-testing-review-user-flow.md"
    - "2026-02-01-security-review-auth-api.md"
    - "2026-02-01-performance-review-menu-load.md"

# Recommended Templates (Non-blocking, for reference)
Recommended_Templates:
  - subagent: code-reviewer
    template: git-workflow-format
    when: "*review 命令"
  - subagent: refactor-specialist
    template: refactoring-review-format
    when: "重构任务"

  if_not_called:
    action: "BLOCK Gate 4"
    message: |
      ⚠️ Gate 4 无法通过 - 缺少必要的 subagent 审查

      必须调用以下 subagents 并生成审查报告：
      1. security-auditor → .tad/evidence/reviews/{date}-security-review-{task}.md
      2. performance-optimizer → .tad/evidence/reviews/{date}-performance-review-{task}.md

      执行步骤：
      1. 调用 security-auditor subagent，使用 security-review-format 模板
      2. 调用 performance-optimizer subagent，使用 performance-review-format 模板
      3. 保存输出到 .tad/evidence/reviews/ 目录
      4. 重新执行 Gate 4

# ⚠️ DECISION COMPLIANCE CHECK (Cognitive Firewall - Pillar 1 verification)
Decision_Compliance:
  description: "Verify implementation follows the technical decisions made by human during design"
  blocking: false  # Warning only, not blocking

  check_process:
    step1: "Read handoff Decision Summary section"
    step2: "For each recorded decision, verify implementation matches the chosen option"
    step3: "Flag any deviations"

  if_deviation:
    action: "WARNING - explain why implementation deviated from agreed decision"
    human_action: "Human decides: accept deviation or request fix"

  output_format:
    gate4_addition: |
      #### Decision Compliance Check
      | # | Decision from Handoff | Implementation Match | Status |
      |---|----------------------|---------------------|--------|
      | 1 | {decision title} | {does code match decision?} | ✅/❌ |

# Gate 4 检查项（Prerequisite 和 Subagent 要求通过后执行）
Critical Check (6 items):
  - [ ] Integration works (system-level test)
  - [ ] Ready for user (no known blockers)
  - [ ] Security review evidence exists
  - [ ] Performance review evidence exists
  - [ ] All subagent feedback addressed
  - [ ] Knowledge Assessment complete (BLOCKING - must answer explicitly)
Evidence: Record in NEXT.md or completion report + evidence files
Output Format:
  ### Gate 4 Result

  #### Prerequisite
  | Check | Status |
  |-------|--------|
  | Gate 3 Passed | ✅ Yes |
  | Testing Evidence | ✅ Exists |

  #### Subagent Evidence Check (BLOCKING)
  | Subagent | Required | Called | Evidence File | Status |
  |----------|----------|--------|---------------|--------|
  | security-auditor | ✅ Yes | ✅ Yes | {date}-security-review-{task}.md | ✅ Exists |
  | performance-optimizer | ✅ Yes | ✅ Yes | {date}-performance-review-{task}.md | ✅ Exists |
  | code-reviewer | ✅ Yes | ✅ Yes | {date}-code-review-{task}.md | ✅ Exists |
  | ux-expert-reviewer | Conditional | ... | ... | ... |

  #### Quality Checks
  | Item | Status | Note |
  |------|--------|------|
  | Integration | ✅ Pass | ... |
  | User Ready | ✅ Pass | ... |
  | Security Evidence | ✅ Pass | File exists |
  | Performance Evidence | ✅ Pass | File exists |
  | Feedback Addressed | ✅ Pass | ... |

  #### Knowledge Assessment (MANDATORY - must answer)
  | Question | Answer | Action |
  |----------|--------|--------|
  | New discoveries from review? | ✅ Yes / ❌ No | If Yes: recorded to .tad/project-knowledge/{category}.md |
  | Category | {category} or N/A | ... |
  | Brief summary | {1-line summary} | ... |

## ⚠️ Gate 4 Subagent Requirement (CRITICAL)
Alex 必须调用 subagents 进行实际验收，不可仅做纸面验收：

Required Subagents (MANDATORY - Gate will BLOCK without these):
  - security-auditor → Evidence in .tad/evidence/reviews/
  - performance-optimizer → Evidence in .tad/evidence/reviews/
  - code-reviewer (ALWAYS required)

Conditional Subagents:
  - ux-expert-reviewer (if UI involved)

Workflow:
  1. Blake completes Gate 3, creates completion report + testing evidence
  2. Blake calls security-auditor → saves security-review evidence
  3. Blake calls performance-optimizer → saves performance-review evidence
  4. Alex reads completion report and evidence files
  5. Alex calls code-reviewer (and ux-expert if UI involved)
  6. Alex summarizes all subagent feedback
  7. Alex decides: PASS / CONDITIONAL PASS / REJECT
  8. If PASS: Gate 4 complete, deliver to user

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

# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)
# 必须在 Gate 结果表格中显式回答，不可跳过
Knowledge_Assessment_Gate4:
  blocking: true
  description: "Gate 4 无法 PASS 除非 Knowledge Assessment 表格已填写"

  mandatory_questions:
    - question: "本次审查是否有新发现？"
      must_answer: true
      options:
        - "✅ Yes - 有新发现"
        - "❌ No - 常规审查，无特殊发现"

    - question: "如果有，属于哪个类别？"
      must_answer: "if previous is Yes"
      options: "从 .tad/project-knowledge/ 目录读取"

    - question: "一句话总结"
      must_answer: true
      note: "即使无新发现，也要写明原因"

  evaluation_criteria:
    should_record_if:
      - "发现了重复出现的代码质量问题"
      - "发现了新的安全/性能风险模式"
      - "做出了影响项目的架构决策"
      - "审查中发现的最佳实践或反模式"
      - "subagent 提出了重要的改进建议"

    can_skip_if:
      - "所有 subagent 结果都是 PASS，无特殊发现"
      - "已有完全相同的记录"

  violation: "Gate 4 结果表格中没有 Knowledge Assessment 部分 = VIOLATION = Gate 无效"

# ⚠️ POST-PASS ACTIONS
Post_Pass_Actions:
  trigger: "Gate 4 所有检查项 PASS（包括 Knowledge Assessment）"

  update_next_md:
    action: "更新 NEXT.md 反映交付完成状态"
    steps:
      - "标记已交付任务为 [x]"
      - "添加用户反馈收集任务（如适用）"
      - "清理已完成的相关任务"
    format: "English only"

  remind_accept:
    action: "提示 Alex 执行 *accept 完成归档流程"
    message: |
      Gate 4 通过！任务已准备交付。

      ⚠️ 提醒：Alex 需要执行 *accept 命令完成：
      - 评估配对测试（UI/用户流变更时建议）
      - 归档 handoff 和 completion report
      - 更新 PROJECT_CONTEXT.md
      - 确认 NEXT.md 状态
```

## Interactive Gate Execution

For each gate, use 0-9 options format:

```
Gate [N]: [Name] Execution

Status Check:
✅ [Criterion]: Pass
❌ [Criterion]: Fail - [Issue]
⚠️ [Criterion]: Warning - [Concern]

Please select action (0-8) or 9 to pass gate:
0. Review checklist again
1. Fix failing items
2. Collect more evidence
3. Run additional tests
4. Use sub-agent for help
5. Document issues found
6. Request clarification
7. Partial pass with notes
8. Fail gate (restart phase)
9. Pass gate (all criteria met)

Select 0-9:
```

## Violation Handling

```
⚠️ GATE VIOLATION DETECTED ⚠️
Type: Attempting to skip Gate [N]
Required: Must execute gate before proceeding
Action: BLOCKED until gate executed

To continue:
1. Execute gate properly
2. Address any failures
3. Collect evidence
4. Get pass result
```

# Universal Violation Recovery Protocol (applies to all gates)
Violation_Recovery:
  step1: "立即停止当前操作"
  step2: "调用正确的 agent/command（如应走 /blake 的用 /blake）"
  step3: "按规范流程从头重新执行"
  principle: "违反任何规则 → 停止 → 纠正 → 重做"

[[LLM: This command executes the appropriate quality gate based on current agent and project phase. Gates are mandatory checkpoints that ensure quality.]]