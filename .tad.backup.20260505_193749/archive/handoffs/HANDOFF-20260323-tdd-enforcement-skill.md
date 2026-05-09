# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-23
**Project:** TAD Framework
**Task ID:** TASK-20260323-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260323-superpowers-tactical-upgrades.md (Phase 3/5)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-23

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Skill file + config toggle + Blake integration point defined |
| Components Specified | ✅ | SKILL.md content, config field, develop_command integration |
| Functions Verified | ✅ | Existing skill format verified, develop_command insertion point verified |
| Data Flow Mapped | ✅ | config.yaml → Blake reads at *develop → adjusts implementation |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了 `.tad/project-knowledge/architecture.md`**
- [ ] 理解这是 opt-in 功能（默认关闭）
- [ ] 理解轻量集成：不删代码，只注入 TDD 指导
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
An opt-in TDD Enforcement Skill that, when enabled via config.yaml, instructs Blake to follow RED-GREEN-REFACTOR cycle during `*develop`. Lightweight integration — no code deletion enforcement, just structured guidance.

### 1.2 Why We're Building It
**业务价值**：Superpowers 的 TDD 纪律是其最有效的模式之一。TAD 通过 opt-in 方式引入，让用户在需要时获得 TDD 结构，不需要时不受影响。

### 1.3 Intent Statement

**真正要解决的问题**：Blake 实现代码时没有结构化的测试驱动流程指导。

**不是要做的**：
- ❌ 不是强制所有项目 TDD（opt-in）
- ❌ 不是删除未测试的代码（Superpowers 的极端模式）
- ❌ 不是修改 Ralph Loop 或 Gate 逻辑

---

## 📚 Project Knowledge（Blake 必读）

Read `.tad/project-knowledge/architecture.md` — 注意 "Measure Before Optimizing" 原则。

---

## 2. Background Context

### 2.1 Reference: Superpowers TDD
Superpowers 的 TDD 模式：先写测试，测试失败(RED)，写代码使测试通过(GREEN)，重构(REFACTOR)。违反则删代码。

TAD 版本更温和：引导 Blake 先写测试，但不强制删除代码。

### 2.2 Current State
- `.tad/skills/` 目录已有 8 个 skill（testing, code-review, security-audit 等）
- Blake 的 `develop_command` 在 `1_5_context_refresh` 和 `2_layer1_loop` 之间没有 TDD 检查
- `config.yaml` 没有 TDD 相关配置

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 创建 `.tad/skills/tdd-enforcement/SKILL.md` — TDD 流程定义 + 反合理化条目
- FR2: `config.yaml` 新增 `tdd_enforcement.enabled: false` 开关（默认关闭）
- FR3: `tad-blake.md` `develop_command` 新增 `1_6_tdd_check` 步骤（在 context_refresh 后、layer1 前）
- FR4: 当 TDD 启用时，Blake 的实现步骤变为 RED→GREEN→REFACTOR 循环
- FR5: SKILL.md 包含 5 条 TDD 专属反合理化条目

### 3.2 Non-Functional Requirements
- NFR1: 默认关闭 — 不影响现有项目
- NFR2: Blake 文件增加量 ≤30 行
- NFR3: 与现有 Ralph Loop 兼容（TDD 在 Layer 1 之前引导，不改变 Layer 1/2 逻辑）

---

## 4. Technical Design

### 4.1 SKILL.md Content

```markdown
---
name: "TDD Enforcement"
id: "tdd-enforcement"
version: "1.0"
claude_subagent: "test-runner"
fallback: "self-check"
min_tad_version: "2.5"
platforms: ["claude"]
# New fields for opt-in skills (establishing pattern for future opt-in skills):
opt_in: true
config_key: "optional_features.tdd_enforcement.enabled"
---

# TDD Enforcement Skill

## Purpose
Guide Blake through RED-GREEN-REFACTOR cycle for each implementation unit.
Opt-in via config.yaml — disabled by default.

## When to Use
- Enabled: `tdd_enforcement.enabled: true` in `.tad/config.yaml`
- Best for: New features, API changes, business logic
- Less suited for: UI prototyping, config changes, documentation

## RED-GREEN-REFACTOR Cycle

### RED: Write Failing Test First
1. Read the acceptance criterion / task requirement
2. Write a test that verifies the requirement
3. Run test — confirm it FAILS (this proves the test checks something real)
4. If test passes without implementation → test is not specific enough, rewrite

### GREEN: Write Minimum Code to Pass
1. Write the simplest code that makes the failing test pass
2. Run test — confirm it PASSES
3. Do NOT add extra functionality beyond what the test requires

### REFACTOR: Clean Up
1. Review both test and implementation code
2. Remove duplication, improve naming, simplify
3. Run tests again — confirm all still pass
4. Commit

## Per-Task Application
For each task/AC in the handoff:
1. Run one RED-GREEN-REFACTOR cycle
2. Commit after each GREEN (small, atomic commits)
3. Move to next task/AC

## Anti-Rationalization (TDD-Specific)

| # | Excuse | Rebuttal |
|---|--------|----------|
| TDD1 | "太简单不需要测试" | 简单代码也会在重构中坏掉。测试只要 30 秒写。 |
| TDD2 | "我先写完代码再补测试" | 事后测试只测你写的，不测应该写的。先写测试确保测试独立于实现。 |
| TDD3 | "这是 UI 代码，没法 TDD" | UI 逻辑（状态管理、数据转换）可以 TDD。视觉渲染不需要。分离逻辑层。 |
| TDD4 | "测试框架还没配好" | 配置测试框架是实现的第一步，不是跳过 TDD 的理由。 |
| TDD5 | "时间紧迫，TDD 太慢" | TDD 前期投入换来后期零调试时间。总时间通常更短。 |

## Checklist (for Blake's self-check)

### Before Writing Any Implementation Code
- [ ] Test file created for this task/AC
- [ ] Test written and confirmed FAILING (RED)

### After Implementation
- [ ] Test passes (GREEN)
- [ ] Code refactored if needed (REFACTOR)
- [ ] No extra code beyond test requirements
- [ ] Committed with descriptive message
```

### 4.2 config.yaml Addition

Add to `config.yaml` — insert AFTER the `backward_compatibility` section and BEFORE the `# ==================== 外部配置引用 ====================` comment:

```yaml
# ==================== Optional Features ====================
optional_features:
  tdd_enforcement:
    enabled: false  # Set to true to enable TDD mode in Blake's *develop
    description: "When enabled, Blake follows RED-GREEN-REFACTOR cycle during implementation"
    skill_path: ".tad/skills/tdd-enforcement/SKILL.md"
```

### 4.3 Blake develop_command Integration

Add a new step `1_6_tdd_check` between `1_5_context_refresh` and `2_layer1_loop`:

```yaml
      1_6_tdd_check:
        description: "Check if TDD mode is enabled and set implementation guidance"
        action: |
          1. Read .tad/config.yaml → check optional_features.tdd_enforcement.enabled
             (If config is malformed or field missing → treat as disabled, log warning)
          2. If false → skip, proceed to normal implementation (no change to existing flow)
          3. If true:
             a. Read .tad/skills/tdd-enforcement/SKILL.md
             b. Announce: "TDD mode enabled. Following RED-GREEN-REFACTOR cycle."
             c. Set TDD guidance flag — Blake's IMPLEMENTATION phase (between 1_6 and 2_layer1)
                follows RED-GREEN-REFACTOR per task/AC:
                - RED: Write failing test first
                - GREEN: Write minimum code to pass
                - REFACTOR: Clean up, commit
             d. Layer 1 then runs as normal VALIDATION (build/test/lint/tsc on all code)
        interaction_with_layer1: |
          TDD mode does NOT replace Layer 1. It changes HOW Blake writes code (test-first),
          but Layer 1 still runs all checks as validation. The difference:
          - Without TDD: Blake implements freely → Layer 1 catches issues
          - With TDD: Blake implements test-first → Layer 1 validates (usually passes on first try)
        optional: true
        skip_if: "tdd_enforcement.enabled == false or field not found"
```

---

## 5. 强制问题回答

### MQ1-MQ5: N/A (config + documentation task, no data flow or UI)

---

## 6. Implementation Steps

### Phase 1: Skill File (预计 15 分钟)

#### 交付物
- [ ] `.tad/skills/tdd-enforcement/SKILL.md` created

#### 实施步骤
1. Create directory `.tad/skills/tdd-enforcement/`
2. Create `SKILL.md` with content from Section 4.1

### Phase 2: Config Integration (预计 15 分钟)

#### 交付物
- [ ] `config.yaml` updated with `optional_features.tdd_enforcement` section

#### 实施步骤
1. Search for `# ==================== 外部配置引用 ====================` in `config.yaml`
2. Add `optional_features` section AFTER `backward_compatibility` and BEFORE that comment line (from Section 4.2)
3. If `skills-config.yaml` has a skills inventory, no registration needed — skills are discovered from `.tad/skills/` directory

### Phase 3: Blake Integration (预计 20 分钟)

#### 交付物
- [ ] `tad-blake.md` updated with `1_6_tdd_check` step

#### 实施步骤
1. Search for `1_5_context_refresh` in `develop_command.steps`
2. Add `1_6_tdd_check` step AFTER it, BEFORE `2_layer1_loop` (from Section 4.3)
3. Search for develop command flow description/diagrams and update to mention TDD check
4. Keep changes minimal (≤30 lines added)

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/skills/tdd-enforcement/SKILL.md    # TDD skill definition + anti-rationalization
```

### 7.2 Files to Modify
```
.tad/config.yaml                        # Add optional_features.tdd_enforcement toggle
.claude/commands/tad-blake.md           # Add 1_6_tdd_check step in develop_command
```

---

## 8. Testing Requirements

### 8.1 Verification
- `config.yaml` valid YAML after changes
- `tdd_enforcement.enabled` defaults to `false`
- SKILL.md follows existing skill format (frontmatter + sections)
- `1_6_tdd_check` positioned correctly (after 1_5, before 2_)

### 8.2 Grep Check
```bash
# Verify TDD references
grep -rn "tdd_enforcement\|tdd-enforcement\|TDD" .tad/config.yaml .tad/skills/ .claude/commands/tad-blake.md
```

---

## 9. Acceptance Criteria

- [ ] AC1: `.tad/skills/tdd-enforcement/SKILL.md` exists with RED-GREEN-REFACTOR cycle definition
- [ ] AC2: SKILL.md has frontmatter matching existing skill format (name, id, version, opt_in: true)
- [ ] AC3: SKILL.md includes 5 TDD-specific anti-rationalization entries (TDD1-TDD5)
- [ ] AC4: `config.yaml` has `optional_features.tdd_enforcement.enabled: false` (default off)
- [ ] AC5: `tad-blake.md` has `1_6_tdd_check` step between context_refresh and layer1_loop
- [ ] AC6: TDD check is skippable when disabled (skip_if logic documented)
- [ ] AC7: All modified YAML files valid
- [ ] AC8: Blake file increase ≤30 lines
- [ ] AC9: Existing *develop flow unchanged when TDD is disabled

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ TDD must default to OFF. This is opt-in.
- ⚠️ Do NOT modify Layer 1 or Layer 2 logic. TDD guidance happens BEFORE Layer 1.
- ⚠️ Do NOT implement "delete code" enforcement (Superpowers' extreme mode). TAD uses guidance, not punishment.

---

---

## Expert Review Status

| Expert | Verdict | P0 | P0 Fixed | P1 Integrated | Overall |
|--------|---------|----|----|----------------|---------|
| code-reviewer | CONDITIONAL PASS | 2 | 2 ✅ | 2/4 key items | PASS (after fixes) |

### P0 Fixed
1. **SKILL.md frontmatter** → Added `platforms: ["claude"]`, documented `opt_in`/`config_key` as new pattern
2. **config.yaml insertion** → Exact anchor: after `backward_compatibility`, before `外部配置引用` comment

### P1 Integrated
- TDD step vs Layer 1 interaction clarified → TDD sets guidance, Layer 1 validates (explicit `interaction_with_layer1` field)
- Config parse error handling → treat as disabled, log warning

**Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-23
**Version**: 3.1.0 (post-expert-review)
