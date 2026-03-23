# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-23
**Project:** TAD Framework
**Task ID:** TASK-20260323-005
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260323-superpowers-tactical-upgrades.md (Phase 4/5)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Template addition + standalone guide |
| Components Specified | ✅ | All content pre-written in handoff |
| Functions Verified | ✅ | Handoff template insertion point verified |
| Data Flow Mapped | ✅ | N/A (documentation task) |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Two deliverables:
1. **Micro-Tasks section** in handoff template — optional table for breaking work into 2-5 minute tasks with precise file paths and verification commands
2. **Pressure Testing guide** — methodology for testing TAD skills/rules by intentionally trying to break them (RED-GREEN-REFACTOR for rules)

### 1.2 Why
**Micro-Tasks**: Superpowers' writing-plans skill requires 2-5 min tasks with exact file paths. TAD handoffs are feature-level — adding optional micro-tasks gives Blake finer guidance for complex tasks.

**Pressure Testing**: Superpowers tests each skill by running without it (RED), adding the skill (GREEN), then finding bypass holes (REFACTOR). TAD lacks a systematic methodology for validating its own rules.

### 1.3 Intent Statement

**不是要做的**：
- ❌ 不是要强制所有 handoff 都有 micro-tasks（可选，Full/Standard TAD 建议使用）
- ❌ 不是要立刻对所有现有规则做 pressure testing（guide 是方法论，按需使用）

---

## 📚 Project Knowledge

Read `.tad/project-knowledge/architecture.md` — 注意 "Minimal Viable Cross-Cutting Enhancement" 原则。

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Handoff template (`handoff-a-to-b.md`) gains optional `## 6.1 Micro-Tasks` section after `## 6. Implementation Steps（分Phase）` (exact heading text — note the trailing Chinese chars)
- FR2: Micro-task table format: `| # | File | Operation | Verification | Est. Time |`
- FR3: Alex's handoff creation protocol gains a note about when to include micro-tasks
- FR4: `.tad/guides/skill-pressure-testing.md` — RED-GREEN-REFACTOR methodology for rule validation
- FR5: Pressure testing guide includes a worked example using an existing TAD rule

### 3.2 Non-Functional Requirements
- NFR1: Micro-tasks section is OPTIONAL — Alex includes it for Full/Standard TAD, skips for Light
- NFR2: Pressure testing guide ≤150 lines
- NFR3: No changes to Blake's execution flow (micro-tasks are guidance, not enforced steps)

---

## 4. Technical Design

### 4.1 Micro-Tasks Template Section

Add after `## 6. Implementation Steps（分Phase）` in `handoff-a-to-b.md`:

```markdown
## 6.1 Micro-Tasks (Optional — recommended for Full/Standard TAD)

> Break implementation into 2-5 minute tasks with precise targets.
> Each micro-task should be independently verifiable.
> Skip this section for Light TAD or simple tasks.

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | {path/to/file.ts} | {Add function X / Modify Y / Create Z} | {grep/test/build command to verify} | {2-5 min} |
| 2 | {path/to/file.ts} | {description} | {verification} | {2-5 min} |

### Micro-Task Rules
- Each task targets ONE file (or 2-3 closely related files)
- Operation is specific: "Add validateInput() function" not "add validation"
- Verification is runnable: a grep, test, or build command
- If TDD mode is enabled, each micro-task = one RED-GREEN-REFACTOR cycle
```

### 4.2 Alex Protocol Note

Add a brief note in `tad-alex.md` in `handoff_creation_protocol.step1` (Draft Creation) content list:

```yaml
# After existing content items:
- "Micro-Tasks (optional — include for Full/Standard TAD when task has 5+ files)"
```

### 4.3 Pressure Testing Guide

```markdown
# Skill Pressure Testing Methodology

> Test TAD rules and skills by intentionally trying to break them.
> Adapted from Superpowers' TDD approach to skill development.

## Purpose
Validate that TAD rules actually prevent the behavior they claim to prevent.
Find bypass holes before agents find them in production.

## RED-GREEN-REFACTOR for Rules

### RED: Run Without the Rule
1. Pick a TAD rule to test (e.g., "Alex must use AskUserQuestion for Socratic inquiry")
2. Simulate a scenario where the rule would apply
3. WITHOUT the rule: observe what the agent does — document violations
4. Record: What went wrong? How did the agent bypass the intent?

### GREEN: Run With the Rule
1. Enable/enforce the rule
2. Re-run the same scenario
3. Verify: Does the agent now comply?
4. Record: What changed? Is compliance genuine or superficial?

### REFACTOR: Find Bypass Holes
1. Think like an agent trying to comply in letter but not spirit
2. Try variations:
   - Edge cases the rule doesn't cover
   - Combining multiple rules to create contradictions
   - Legitimate-sounding excuses (→ add to anti-rationalization tables)
3. For each bypass found:
   - Document in the rule's anti-rationalization section
   - Tighten the rule if needed
   - Re-run GREEN to verify the fix

## Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Rule Hold Rate | ≥90% | (compliant runs / total runs) across 10 test scenarios |
| Bypass Discovery Rate | Document all found | Count of new anti-rationalization entries generated |
| False Positive Rate | ≤10% | Rules blocking legitimate actions |

## Worked Example: Socratic Inquiry Rule

**Rule**: "Alex must call AskUserQuestion before writing handoff"

**RED** (without rule enforcement):
- Scenario: User says "I need a login page, just do it fast"
- Agent behavior: Skips AskUserQuestion, writes handoff directly
- Violation: No structured requirement capture

**GREEN** (with rule):
- Same scenario, rule enforced
- Agent: Calls AskUserQuestion with 3 questions
- Compliance: ✅ Questions asked, answers recorded

**REFACTOR** (bypass hunting):
- Bypass attempt 1: "User said 'fast' so I'll ask just 1 trivial question"
  → Add anti-rationalization: "Minimum question count is set by adaptive complexity, not agent"
- Bypass attempt 2: "I'll ask AskUserQuestion but pre-fill all options to guide toward my design"
  → Add anti-rationalization: "Options must represent genuine alternatives, not lead to predetermined answer"

**Result**: 2 new anti-rationalization entries, rule tightened.

## When to Pressure Test
- After creating a new TAD rule or skill
- After modifying an existing rule
- When an agent bypass is observed in practice (add the bypass as a test case)
- Periodically (quarterly review of critical rules)

## Output
For each pressure test session, record:
- Rule tested
- Scenarios run
- Bypasses found
- Anti-rationalization entries added
- Rule modifications made
```

---

## 6. Implementation Steps（分Phase）

### Phase 1: Handoff Template (预计 10 分钟)
1. Search for `## 6. Implementation Steps（分Phase）` in `handoff-a-to-b.md`
2. Add `## 6.1 Micro-Tasks` section AFTER the Implementation Steps section (from Section 4.1)
3. Ensure it's marked as OPTIONAL

### Phase 2: Alex Protocol Note (预计 5 分钟)
1. Search for `handoff_creation_protocol` → `step1` → `content:` list in `tad-alex.md`
2. Add one line about micro-tasks (from Section 4.2)

### Phase 3: Pressure Testing Guide (预计 10 分钟)
1. Create `.tad/guides/skill-pressure-testing.md` with content from Section 4.3

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/guides/skill-pressure-testing.md   # Pressure testing methodology
```

### 7.2 Files to Modify
```
.tad/templates/handoff-a-to-b.md        # Add §6.1 Micro-Tasks section
.claude/commands/tad-alex.md            # Add micro-tasks note in handoff creation
```

---

## 9. Acceptance Criteria

- [ ] AC1: `handoff-a-to-b.md` has `## 6.1 Micro-Tasks` section after `## 6. Implementation Steps（分Phase）`
- [ ] AC2: Micro-tasks section is marked OPTIONAL with guidance on when to use
- [ ] AC3: Micro-task table has columns: #, File, Operation, Verification Command, Est. Time
- [ ] AC4: `tad-alex.md` handoff_creation_protocol.step1 mentions micro-tasks for Full/Standard TAD
- [ ] AC5: `.tad/guides/skill-pressure-testing.md` exists with RED-GREEN-REFACTOR methodology
- [ ] AC6: Guide includes worked example (Socratic Inquiry rule)
- [ ] AC7: Guide includes metrics table (Rule Hold Rate, Bypass Discovery Rate, False Positive Rate)
- [ ] AC8: Guide ≤150 lines
- [ ] AC9: All modified files remain valid

---

## 10. Important Notes

- ⚠️ Micro-tasks are OPTIONAL guidance. Do NOT modify Blake's *develop flow.
- ⚠️ Pressure testing guide is a reference document. No runtime integration needed.
- ⚠️ Keep Alex protocol change to ONE line — minimal footprint.

---

---

## Expert Review Status

| Expert | Verdict | P0 | P1 Fixed | Overall |
|--------|---------|----|----|---------|
| code-reviewer | CONDITIONAL PASS | 0 | 1 ✅ (heading mismatch) | PASS |

**Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-23
**Version**: 3.1.0 (post-expert-review)
