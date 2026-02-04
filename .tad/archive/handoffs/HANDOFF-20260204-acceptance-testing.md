# Handoff: Acceptance-Driven Testing

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-04
**Task ID:** TASK-20260204-003
**Priority:** P0
**Complexity:** Medium
**Status:** Ready for Implementation

---

## Executive Summary

为 TAD 框架添加**验收标准驱动的测试生成**机制。核心改动：Blake 实现代码后、Gate 3 前，必须为 Handoff 中的**每条 Acceptance Criteria** 生成至少 1 个可运行的验证脚本/测试，并实际执行产出 PASS/FAIL 结果。

**解决的问题**: 当前 Alex 写了详细的验收标准，但 Gate 3 只检查"证据文件存在"和"npm test 通过"——没有人系统性地验证每条验收标准是否真的满足。code-reviewer (AI) 审查 Blake (AI) 的代码是同一模型的主观判断，测试结果才是客观证据。

---

## Handoff Checklist (Blake 必读)

- [ ] 阅读了所有章节
- [ ] 理解核心改动：Ralph Loop 和 Gate 3 之间插入新步骤
- [ ] 理解：验证可以是 test file、bash script、或结构化检查——取决于项目类型

---

## 1. Task Overview

### 1.1 What We're Building

在 Blake 的工作流中增加一个**强制步骤**：

```
当前流程:
  实现代码 → Ralph Loop (build/test/lint/tsc + expert review) → Gate 3

新增流程:
  实现代码 → Ralph Loop → 【验收验证生成+执行】→ Gate 3
```

### 1.2 Why

| 当前 | 改后 |
|------|------|
| 验收标准是文字清单，靠人读代码打 ✅ | 每条标准有可运行的验证，PASS/FAIL |
| AI 审 AI 的代码（主观、同模型盲区）| 测试结果是客观证据 |
| Gate 3 检查"文件存在" | Gate 3 检查"每条标准都有验证 + 全 PASS" |
| 无回归测试积累 | 验证脚本可复用为回归测试 |

---

## 2. Technical Design

### 2.1 新步骤：Acceptance Verification (插入 completion_protocol)

**插入方式**: 在 `completion_protocol` 的 `step3` 和 `step4` 之间添加 `step3b`。使用 sub-step 编号（3b），**不修改** step4-step8 的编号和内容。

```yaml
# 插入位置：tad-blake.md completion_protocol
# step3 之后、step4 之前，新增 step3b
# step1-step3 不变，step4-step8 不变（编号和内容均保留）

step3b: "验收标准验证：为 Handoff 每条 Acceptance Criteria 生成并执行可运行验证（详见 acceptance-verification-guide）"

# step3b 的详细执行协议（写入 acceptance-verification-guide.md，Blake 参考执行）
step3b_acceptance_verification:
  description: "为每条验收标准生成并执行可运行的验证"
  blocking: true
  trigger: "Ralph Loop Layer 2 通过后（即 step3 完成后）"

  violations:
    - "跳过验收验证直接进 Gate 3 = VIOLATION"
    - "验收标准无对应验证 = VIOLATION"
    - "验证未实际执行（只写了没跑）= VIOLATION"

  process:
    step1_read_criteria:
      action: "读取 Handoff 的 Acceptance Criteria section"
      output: "验收标准列表（编号）"

    step2_generate_verifications:
      action: |
        为每条标准生成验证。验证形式根据标准类型选择：

        文件存在类: bash 脚本 (test -f path)
        内容检查类: bash 脚本 (grep/yq/jq 检查)
        代码功能类: 测试文件 (Jest/pytest/etc)
        配置正确类: bash 脚本 (验证 YAML/JSON 结构)
        行为验证类: 测试文件 或 bash 脚本 (curl/运行命令检查输出)
      output_dir: ".tad/evidence/acceptance-tests/{task_id}/"
      naming: "AC-{number}-{brief-slug}.{sh|test.ts|test.py}"

    step3_execute:
      action: "执行所有验证脚本，收集结果"
      output: "acceptance-verification-report.md"
      format: |
        # Acceptance Verification Report
        Task: {task_id}
        Date: {date}
        Total: {N} criteria, {P} PASS, {F} FAIL

        | # | Acceptance Criterion | Verification | Result | Evidence |
        |---|---------------------|-------------|--------|----------|
        | 1 | {criterion text}    | AC-01-xxx.sh | ✅ PASS | {output} |
        | 2 | {criterion text}    | AC-02-xxx.sh | ❌ FAIL | {error}  |
        ...

    step4_handle_failures:
      action: |
        IF any FAIL — 区分两种失败场景：

        场景 A: 验证脚本本身有问题（逻辑错误、路径错误等）
          → 修复验证脚本
          → 仅重新执行修复的验证
          → 更新 report

        场景 B: 验证揭示了实际代码缺陷
          → 修复代码
          → 重新执行 Ralph Loop Layer 1（build/test/lint/tsc）确保修复未引入新问题
          → 重新执行所有验证（不仅是失败的）
          → 更新 report

        IF all PASS:
          → 继续到 step4 (Gate 3)

  # 验证生成的质量标准
  verification_quality:
    - "每个验证必须可独立运行（不依赖其他验证的执行顺序）"
    - "每个验证必须产出明确的 PASS 或 FAIL（不能是'看起来OK'）"
    - "每个验证必须在 30 秒内完成（超时 = FAIL）"
    - "Bash 脚本必须以 exit 0 (PASS) 或 exit 1 (FAIL) 结束"
    - "测试文件使用项目的测试框架（Jest/pytest/etc），无框架时用 bash"
```

### 2.2 Gate 3 修改：增加验收映射检查

```yaml
# 插入位置：tad-gate.md Gate 3 section
# 位于 Required_Subagent 之后、Critical Check (5 items) 之前
# 与 Prerequisite 和 Required_Subagent 同级 — 都是 BLOCKING 前置检查
# 现有 Critical Check (5 items) 和 Knowledge Assessment 不改动

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
```

### 2.3 config-quality.yaml 修改

```yaml
# 在 gate3_v2_implementation_integration 的 evidence_required 中新增：

acceptance_verification_evidence:
  required: true
  files:
    - type: "acceptance-verification-report"
      pattern: ".tad/evidence/acceptance-tests/{task_id}/acceptance-verification-report.md"
      required: true
    - type: "verification-scripts"
      pattern: ".tad/evidence/acceptance-tests/{task_id}/AC-*.{sh,test.ts,test.py}"
      required: true
      min_count: "must match acceptance criteria count"
```

### 2.4 验证脚本示例（写入 guide 供 Blake 参考）

```markdown
# 示例 1: 文件存在类
# AC-01-design-curations-exists.sh
#!/bin/bash
if [ -f ".tad/references/design-curations.yaml" ]; then
  echo "PASS: design-curations.yaml exists"
  exit 0
else
  echo "FAIL: design-curations.yaml not found"
  exit 1
fi

# 示例 2: 内容检查类
# AC-02-five-color-palettes.sh
#!/bin/bash
count=$(grep -c "^  [a-z_]*:" .tad/references/design-curations.yaml | head -1)
# 更精确的检查：
palettes=("cool_minimal" "warm_professional" "vibrant_modern" "dark_bold" "neutral_enterprise")
pass=0
for p in "${palettes[@]}"; do
  if grep -q "^  $p:" .tad/references/design-curations.yaml; then
    ((pass++))
  fi
done
if [ "$pass" -ge 5 ]; then
  echo "PASS: Found $pass/5 color palettes"
  exit 0
else
  echo "FAIL: Found only $pass/5 color palettes"
  exit 1
fi

# 示例 3: 代码功能类 (Jest)
# AC-03-keyword-detection.test.ts
describe('Playground keyword detection', () => {
  it('triggers on strong signals', () => {
    const strong = ['UI', '界面', '前端', 'dashboard'];
    // ... test implementation
  });
  it('does NOT trigger on negative signals', () => {
    const negative = ['API', 'database', 'backend'];
    // ... test implementation
  });
});

# 示例 4: YAML 结构检查
# AC-04-protocol-structure.sh
#!/bin/bash
if grep -q "violations:" .claude/commands/tad-alex.md && \
   grep -q "step1_frontend_detection:" .claude/commands/tad-alex.md && \
   grep -q "step7_export:" .claude/commands/tad-alex.md; then
  echo "PASS: playground_protocol has required structure"
  exit 0
else
  echo "FAIL: playground_protocol missing required sections"
  exit 1
fi
```

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: tad-blake.md 新增 `step3b_acceptance_verification` 在 completion_protocol 中
- **FR2**: tad-gate.md Gate 3 新增 `Acceptance_Verification` 检查（blocking）
- **FR3**: config-quality.yaml 新增 acceptance verification evidence 要求
- **FR4**: 创建 `.tad/evidence/acceptance-tests/` 目录
- **FR5**: 创建 `.tad/templates/acceptance-verification-guide.md` 指南文件

### 3.2 Non-Functional Requirements

- **NFR1**: 新增步骤不改变现有 Ralph Loop 和 Gate 机制，只在中间插入
- **NFR2**: 验证脚本执行总时间不超过 5 分钟（单个 30 秒超时）
- **NFR3**: 对无测试框架的项目（如 TAD 本身），bash 脚本作为 fallback

---

## 4. 强制问题回答

### MQ1: 历史代码搜索

**回答**: 搜索了 tad-blake.md 的 completion_protocol（line 491-500）和 tad-gate.md 的 Gate 3 section（line 89-147），确认当前流程中没有验收标准映射验证。Ralph Loop 有 Layer 1 (build/test) 和 Layer 2 (expert review)，但无标准驱动的验证。

### MQ2: 函数存在性验证

| 文件/Section | 位置 | 验证 |
|-------------|------|------|
| completion_protocol | tad-blake.md:491 | ✅ 存在（step1-step8，需在 step3 后插入 step3b）|
| Gate 3 section | tad-gate.md:89 | ✅ 存在（需添加 Acceptance_Verification 检查）|
| gate3_v2 evidence | config-quality.yaml:119-146 | ✅ 存在（需添加新 evidence 类型）|
| mandatory rules | tad-blake.md:478 | ✅ 存在（需添加 acceptance_verification 规则）|

### MQ5: 状态同步

```
Handoff Acceptance Criteria (Source of Truth)
    ↓ Blake 读取
Verification Scripts (.tad/evidence/acceptance-tests/{task_id}/)
    ↓ 执行
Verification Report (acceptance-verification-report.md)
    ↓ Gate 3 读取
Gate 3 结果 → Completion Report

唯一 Source of Truth: Handoff 的 Acceptance Criteria
验证脚本是其可执行投影，报告是执行结果。
```

---

## 5. Implementation Steps

### Phase 1: 协议修改

#### 交付物
- [ ] `tad-blake.md` 更新 — completion_protocol 新增 step3b
- [ ] `tad-blake.md` 更新 — mandatory rules 新增 acceptance_verification
- [ ] `tad-gate.md` 更新 — Gate 3 新增 Acceptance_Verification 检查
- [ ] `config-quality.yaml` 更新 — Gate 3 evidence 新增 acceptance verification

#### 实施步骤

**1. tad-blake.md: 插入 step3b**

在 `completion_protocol` section 中，在 `step3:` 行之后、`step4:` 行之前，新增一行：

```yaml
# 原文 (tad-blake.md:495)
step3: "通过 Layer 2 专家审查（code-reviewer → parallel experts）"
# ↓ 在此处插入 ↓
step3b: "验收标准验证：为 Handoff 每条 Acceptance Criteria 生成并执行可运行验证（详见 acceptance-verification-guide）"
# ↓ 以下不变 ↓
step4: "执行 Gate 3 v2 (Implementation & Integration) - 包含 Knowledge Assessment"
```

**不修改 step1-step3 和 step4-step8 的编号与内容**。详细执行协议写在 acceptance-verification-guide.md 中，Blake 执行 step3b 时参考。

**2. tad-blake.md: mandatory rules 新增**

```yaml
mandatory:
  # ... existing rules ...
  acceptance_verification: "MUST generate and execute acceptance verification for every criterion before Gate 3"
```

**3. tad-gate.md: Gate 3 新增检查项**

在 `Required_Subagent` section 之后、`Critical Check (5 items)` section 之前，插入 `Acceptance_Verification` 作为新的 BLOCKING 前置检查。参考 Section 2.2。

**不修改** Critical Check 的 5 个检查项（它们保持不变）。新增的 Acceptance_Verification 与 Prerequisite、Required_Subagent 同级。

**4. config-quality.yaml: evidence 新增**

在 `gate3_v2_implementation_integration.expert_evidence` 中新增 acceptance verification evidence。参考 Section 2.3。

---

### Phase 2: 模板和目录

#### 交付物
- [ ] `.tad/evidence/acceptance-tests/` 目录 (with `.gitkeep`)
- [ ] `.tad/templates/acceptance-verification-guide.md` 指南

#### 实施步骤

**1. 创建目录**

```
.tad/evidence/acceptance-tests/.gitkeep
```

**2. 创建 acceptance-verification-guide.md**

内容包含：
```markdown
# Acceptance Verification Guide

## 目的
为 Handoff 的每条 Acceptance Criteria 生成可运行的验证。

## 验证类型选择

| 标准类型 | 验证形式 | 示例 |
|----------|---------|------|
| 文件/目录存在 | bash (test -f / test -d) | AC-01-file-exists.sh |
| 内容/格式正确 | bash (grep/yq/jq) | AC-02-yaml-structure.sh |
| 代码功能正确 | 测试文件 (Jest/pytest) | AC-03-function.test.ts |
| 配置值正确 | bash (检查具体值) | AC-04-config-value.sh |
| UI 行为正确 | bash (curl + 检查响应) 或 E2E 测试 | AC-05-api-response.sh |
| 协议结构正确 | bash (grep YAML keys) | AC-06-protocol.sh |

## 命名规范
AC-{NN}-{brief-slug}.{sh|test.ts|test.py}

## 质量要求
- 可独立运行，不依赖执行顺序
- 产出明确 PASS/FAIL（不是"看起来OK"）
- 单个验证 30 秒超时
- Bash 脚本: exit 0 = PASS, exit 1 = FAIL

## 报告格式
[示例报告模板]

## 常用验证模式
[各类型的代码示例 — 参考 Handoff Section 2.4]
```

---

## 6. File Structure

### Files to Modify
```
.claude/commands/tad-blake.md    # completion_protocol + mandatory rules
.claude/commands/tad-gate.md     # Gate 3 新增检查项
.tad/config-quality.yaml         # evidence 要求
```

### Files to Create
```
.tad/evidence/acceptance-tests/.gitkeep
.tad/templates/acceptance-verification-guide.md
```

---

## 7. Testing Requirements

- [ ] **场景 1**: tad-blake.md completion_protocol 包含 step3b 且位置正确（step3 和 step4 之间）
- [ ] **场景 2**: tad-gate.md Gate 3 包含 Acceptance_Verification 检查且标记为 blocking
- [ ] **场景 3**: config-quality.yaml 包含 acceptance verification evidence 定义
- [ ] **场景 4**: acceptance-verification-guide.md 包含所有验证类型和示例
- [ ] **场景 5**: 现有 Ralph Loop 流程不受影响（新步骤插入不破坏现有步骤）
- [ ] **场景 6**: mandatory rules 包含 acceptance_verification

---

## 8. Acceptance Criteria

- [ ] `tad-blake.md` completion_protocol 包含 step3b_acceptance_verification（含 violations, process, verification_quality）
- [ ] `tad-blake.md` mandatory rules 包含 acceptance_verification
- [ ] `tad-gate.md` Gate 3 包含 Acceptance_Verification 检查（blocking, 含 if_missing 和 if_exists.checks）
- [ ] `config-quality.yaml` gate3_v2 evidence 包含 acceptance-verification-report + verification-scripts
- [ ] `.tad/evidence/acceptance-tests/` 目录存在
- [ ] `.tad/templates/acceptance-verification-guide.md` 存在且包含验证类型表 + 命名规范 + 质量要求 + 示例
- [ ] 不影响现有 completion_protocol 的其他步骤 (step1-step3, step4-step8)
- [ ] 不影响现有 Gate 3 的 5 个 Critical Check

---

## 9. Important Notes

### 9.1 Critical Warnings

- **不改变 Ralph Loop 本身** — 新步骤在 Ralph Loop 之后、Gate 3 之前
- **验证失败后的 Ralph Loop 交互**:
  - 如果失败原因是验证脚本本身有 bug → 只修脚本，不需要重跑 Ralph Loop
  - 如果失败原因是实际代码缺陷 → 修代码后**必须重跑 Ralph Loop Layer 1**（build/test/lint/tsc），然后重跑所有验证
  - 不需要重跑 Layer 2（专家审查），除非 Layer 1 失败
- **验证脚本是一次性的还是持久的？** — 鼓励写成可复用的回归测试，但不强制。最低要求是能执行一次产出 PASS/FAIL
- **不需要 100% 自动化** — 对于确实无法自动验证的标准（如"不影响现有流程"），Blake 可以写一个手动验证脚本，输出检查步骤并要求人类确认

### 9.2 与其他 Handoff 的关系

本 Handoff 完成后，后续所有 Blake 执行的任务（包括 Curation Playground Handoff）都会自动受益于这个机制。

---

**Handoff Created By**: Alex (Solution Lead)
**Date**: 2026-02-04
**Version**: 2.3.0
