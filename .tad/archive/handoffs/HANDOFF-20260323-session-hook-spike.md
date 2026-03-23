# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-23
**Project:** TAD Framework
**Task ID:** TASK-20260323-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260323-superpowers-tactical-upgrades.md (Phase 0/5)
**Type:** Technical Spike (time-boxed feasibility study)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-23

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ⚠️ | Spike — architecture is the deliverable, not a prerequisite |
| Components Specified | ✅ | Investigation targets clearly defined |
| Functions Verified | ✅ | Claude Code hooks API needs to be discovered (part of spike) |
| Data Flow Mapped | ✅ | Current vs target context loading flow mapped |

**Gate 2 结果**: ⚠️ PARTIAL PASS (expected for spike — design emerges from investigation)

**Alex确认**: This is a spike handoff. Blake's deliverable is the architecture decision, not implementation code. The investigation targets and success criteria are well-defined.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解这是一个 spike（产出是决策文档，不是代码）
- [ ] 理解了判定标准（可行/不可行的明确定义）
- [ ] 确认可以独立使用本文档完成调查

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
A time-boxed technical spike to determine whether Claude Code's hooks mechanism can optimize TAD's context footprint. The deliverable is a **feasibility verdict + architecture recommendation**, not production code.

### 1.2 Why We're Building It
**业务价值**：TAD's CLAUDE.md (~150 lines) loads at session start, plus @import directives for project-knowledge files. As we add more features (anti-rationalization tables, micro-tasks, TDD skill), CLAUDE.md will grow further. We need to understand whether on-demand loading mechanisms exist before adding more content.
**用户受益**：Reduced context consumption = better agent performance in long sessions, more room for actual work content.
**成功的样子**：When we have a clear YES/NO on context optimization approaches (hooks, meta-skill bootstrap, or CLAUDE.md restructuring), with a concrete architecture if YES, or a documented rationale for staying with current approach.

**⚠️ Important caveat (from expert review)**: Agent command files (tad-alex.md, tad-blake.md) already load on-demand via Skill tool invocation, NOT at session start. Most @import directives in CLAUDE.md point to non-existent files that are silently skipped. The actual optimization target may be smaller than initially assumed. **Part of this spike is to measure the real baseline.**

### 1.3 Intent Statement

**真正要解决的问题**：TAD 的上下文占用随功能增加而膨胀，需要找到按需加载机制来替代全量加载。

**不是要做的（避免误解）**：
- ❌ 不是要实现完整的 hook 系统（这是 spike，不是实现）
- ❌ 不是要安装或集成 Superpowers（只是研究它的 hook 模式作为参考）
- ❌ 不是要重写 CLAUDE.md（那是后续 Phase 的工作）

**Blake请确认理解**：
```
在开始调查前，请用你自己的话回答：
1. 这个 spike 解决什么问题？
2. 什么结果算"可行"？什么算"不可行"？
3. 产出物是什么？
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed below
2. Read the "⚠️ Blake 必须注意的历史教训" entries carefully

本次任务涉及的领域：
- [x] architecture - 架构决策
- [x] code-quality - 代码模式/反模式

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | Minimal viable enhancement, YAML structure awareness, Cognitive Firewall embed pattern |

**⚠️ Blake 必须注意的历史教训**：

1. **Minimal Viable Cross-Cutting Enhancement** (来自 architecture.md)
   - 问题：Adding cross-cutting concerns tends to expand scope (9 nodes → 2+1)
   - 解决方案：Start with the 2 most critical points. This spike should focus on the core question, not try to design the entire hook system.

2. **Cognitive Firewall: Embed Into Existing Flows** (来自 architecture.md)
   - 问题：Cross-cutting concerns are most effective when embedded into existing mandatory flows
   - 解决方案：If hooks are feasible, the hook system should trigger WITHIN existing /alex and /blake invocation, not as a separate mechanism.

3. **YAML Structure Awareness** (来自 architecture.md)
   - 问题：Protocol files mix flat and nested YAML formats
   - 解决方案：When proposing architecture changes, ensure format consistency with surrounding context.

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解 spike 应聚焦核心问题，避免范围膨胀

---

## 2. Background Context

### 2.1 Previous Work
- Superpowers uses a session hook to inject a "meta-skill" at startup (~500 tokens), then loads other skills on-demand via Skill tool
- TAD currently loads CLAUDE.md at session start, then loads agent command files on-demand when /alex or /blake is invoked via Skill tool

### 2.2 Current State (needs baseline measurement)
**Current TAD context loading flow:**
```
Session Start
  → CLAUDE.md loaded (~150 lines, includes @import for 9 project-knowledge files)
    NOTE: 7 of 9 @import targets don't exist as files — only architecture.md exists
    QUESTION: Do non-existent @imports consume zero tokens? (Blake must verify)
  → User invokes /alex or /blake (Skill tool)
  → Agent command file loaded on-demand (tad-alex.md ~800+ lines OR tad-blake.md ~600+ lines)
  → Agent's activation protocol loads config modules (config-agents, config-quality, etc.)
```

**⚠️ Expert review finding**: Agent files + config modules already load on-demand (not at session start). The only always-loaded content is CLAUDE.md + resolved @imports. Real optimization target may be smaller than assumed.

**Target (if feasible — needs baseline measurement to validate):**
```
Session Start
  → Minimal routing rules only (subset of current CLAUDE.md)
  → Project-knowledge deferred to handoff creation / develop start
  → Everything else unchanged (already on-demand)
  → Savings: TBD — baseline measurement is part of this spike
```

### 2.3 Dependencies
- Claude Code hooks mechanism (shell command hooks in settings.json `hooks` field)
- Claude Code Skill tool (already used by TAD commands)
- No external dependencies

### 2.4 Two Distinct Mechanisms to Investigate

**⚠️ Expert review clarification**: The following are TWO SEPARATE approaches, not one:

1. **Claude Code Shell Hooks** — Shell commands registered in `settings.json` that run at lifecycle points (PreToolCall, PostToolCall, etc.). These execute bash commands and inject stdout as system messages. They are NOT the same as Superpowers' session hook pattern.

2. **Meta-Skill Bootstrap Pattern** — A lightweight CLAUDE.md that uses the Skill tool for lazy loading of heavier content. This is independent of shell hooks and could work on its own.

Blake must investigate both approaches independently and assess whether they can be combined.

### 2.5 Reference: Superpowers Hook Architecture
Source: Research note at project-external path (user's personal notes, not in repo). Key points already extracted in this handoff.

Key patterns to reference (from the research note):
- Superpowers registers a SessionStart hook that injects only a `using-superpowers` meta-skill
- The meta-skill tells the agent: "skills exist, you must use the Skill tool to load them"
- Other skills load on-demand, not at startup — reducing context footprint

---

## 3. Requirements

### 3.1 Investigation Targets (Functional Requirements)

- **IT1**: Determine Claude Code hooks mechanism capabilities
  - What hook types exist? (PreToolCall, PostToolCall, SessionStart, etc.)
  - What is the execution model? (shell command → stdout injected as system message?)
  - How are hooks registered? (settings.json `hooks` field? other mechanism?)
  - Can hooks inject text into the agent's context? At what point in the lifecycle?
  - **What is the execution order between CLAUDE.md loading and hook execution?** (If CLAUDE.md loads first, hooks cannot replace it — only supplement)
  - Can hooks conditionally trigger based on command invocation?

- **IT2**: Measure current baseline + assess CLAUDE.md slimming potential
  - **Baseline measurement**: Count approximate tokens for each component loaded at session start (CLAUDE.md content, resolved @imports, any other auto-loaded content). Use character count / 4 as token approximation.
  - **@import behavior**: Do @import directives for non-existent files (e.g., `@.tad/project-knowledge/security.md` which doesn't exist) consume any tokens? Or are they silently zero-cost?
  - What MUST stay in CLAUDE.md (always-loaded routing rules)?
  - What CAN be moved to on-demand loading?
  - What is the estimated token reduction (with measured baseline)?

- **IT3**: Prototype a minimal hook (if mechanism supports it)
  - Create a proof-of-concept hook that injects a simple message at session start
  - Verify it works alongside existing TAD command system
  - Verify it does NOT break /alex, /blake, or other commands
  - **Early termination**: If within first 20 minutes Blake discovers hooks cannot inject content into conversation context at all, conclude spike immediately with ❌ verdict.

- **IT4**: Evaluate compatibility risks
  - Does the hook mechanism work with TAD's Skill-based command system?
  - Can multiple hook sources coexist (future Superpowers coexistence)?
  - Hook behavior during `claude --continue` or session resume?
  - Any platform-specific limitations?

- **IT5**: Investigate alternative context optimization approaches (if hooks are limited)
  - Can @import directives be made conditional?
  - Can CLAUDE.md be split across directory levels for layered loading?
  - Are config module loads truly on-demand, or eagerly resolved?
  - Manual CLAUDE.md slimming without any hook mechanism — is this sufficient?

### 3.2 Non-Functional Requirements
- NFR1: Spike must be time-boxed — **max 2 hours total** (Phase 1: max 60 min, Phase 2: max 30 min, Phase 3: max 30 min). If Phase 1 hits 60 min without clear picture, skip Phase 2 and go directly to verdict.
- NFR2: All findings must be documented in a structured verdict document
- NFR3: No permanent changes to TAD framework files (spike only)

---

## 4. Technical Design

### 4.1 Investigation Approach

**Phase 1: Research (max 60 min)**
1. Research Claude Code hooks mechanism:
   - Use `claude-code-guide` subagent to research hooks capabilities
   - Check if `.claude/settings.json` has a `hooks` field (NOTE: current file has no hooks field — research how to ADD hooks, not read existing ones)
   - Determine: execution model, trigger points, context injection capability, execution ordering vs CLAUDE.md
2. Measure current baseline:
   - Count CLAUDE.md tokens (character count / 4)
   - Test @import behavior: do non-existent file imports cost tokens?
   - Document what loads at session start vs on-demand
3. Categorize CLAUDE.md content by loading urgency:
   - CRITICAL (must load at startup): Terminal isolation, handoff routing rules
   - IMPORTANT (should load with agent): Gate overview, plan mode prohibition
   - DEFERRABLE (can load on-demand): @import project-knowledge, detailed protocols
4. Investigate alternative approaches (IT5) — even if hooks look promising

**Phase 2: Prototype (max 30 min, conditional — skip if Phase 1 exhausts budget)**
5. Backup `.claude/settings.json` to `.claude/settings.json.spike-backup`
6. Add minimal test hook to settings.json
7. Test: Does it fire? Does it inject context? Does it coexist with TAD?
8. Restore from backup, verify with `diff` command, delete backup
9. If hooks work → draft meta-skill bootstrap architecture with minimum requirements:
   (a) what content stays in CLAUDE.md, (b) what moves to deferred loading,
   (c) what triggers deferred loading, (d) estimated token savings with evidence

**Phase 3: Verdict (max 30 min)**
10. Write verdict document with one of:
    - ✅ FEASIBLE: Hook mechanism works, here's the architecture
    - ⚠️ PARTIAL: Hooks work but with limitations (detail them)
    - ❌ NOT FEASIBLE: Hooks don't support our needs, here's why + alternative approach
11. Include confidence level (High/Medium/Low) with the verdict
12. Include "Impact on Epic Phases" section — how does the verdict affect Phase 1-5?

### 4.2 Verdict Document Structure
Output: `.tad/active/handoffs/SPIKE-VERDICT-20260323-session-hook.md`

```markdown
# Spike Verdict: Session Hook Context Optimization

## Verdict: ✅/⚠️/❌
## Confidence: High/Medium/Low

## Baseline Measurement
### Token Budget Analysis
| Component | Tokens (approx) | Loads At | Can Defer? |
|-----------|-----------------|----------|------------|
| CLAUDE.md (routing rules) | X | Session start | Partially |
| @import (resolved files) | X | Session start | Yes |
| @import (non-existent) | X | Session start | N/A if zero-cost |
| Agent command file | X | On /alex or /blake | Already deferred |
| Config modules | X | On agent activation | Already deferred |
| **Total at session start** | **X** | | |
| **Total deferrable** | **X** | | |

## Findings
### Approach 1: Claude Code Shell Hooks
(what shell hooks can/cannot do — execution model, timing, limitations)

### Approach 2: Meta-Skill Bootstrap Pattern
(can CLAUDE.md be restructured to use Skill tool for lazy loading?)

### Approach 3: Alternative Optimizations (IT5)
(@import behavior, CLAUDE.md splitting, config module loading)

### TAD CLAUDE.md Content Analysis
(critical / important / deferrable categorization)

### Prototype Results
(if applicable — what worked, what didn't)

## Recommended Architecture
(if feasible — what content stays in CLAUDE.md, what defers, what triggers deferred loading)

## Alternative Approach
(if not feasible — what to do instead, including "current approach is acceptable" if baseline shows low overhead)

## Impact on Epic Phases
(how does this verdict affect Phase 1-5 of the Superpowers Tactical Upgrades Epic?)

## Risks & Limitations
(known constraints)
```

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
**回答**: ✅ 是 — `.claude/settings.json` 存在但目前**没有 hooks 字段**
**搜索目标**: `.claude/settings.json`（当前仅含 agents, commands, autoload, prompts 字段）
**决定**: Blake 需要研究如何 ADD hooks 到 settings.json，不是读取现有 hooks

### MQ2: 函数存在性验证
**回答**: N/A — 这是调查性 spike，不调用特定函数

### MQ3-MQ5: N/A (no data flow, no UI, no state sync for a spike)

---

## 6. Implementation Steps

### Phase 1: Research (max 60 min)

#### 交付物
- [ ] Claude Code hooks capability matrix (execution model, trigger types, context injection ability)
- [ ] Baseline token measurement (what actually loads at session start)
- [ ] @import behavior test results (do non-existent imports cost tokens?)
- [ ] TAD CLAUDE.md content categorization (critical/important/deferrable)
- [ ] Alternative approaches assessment (IT5)

#### 实施步骤
1. Read `.claude/settings.json` — confirm no existing hooks field
2. Use `claude-code-guide` subagent to research hooks mechanism in detail
3. Measure baseline: count CLAUDE.md tokens, test @import resolution behavior
4. Categorize CLAUDE.md content by loading urgency
5. Investigate alternative optimization approaches (IT5: conditional imports, CLAUDE.md splitting, config lazy loading)

#### 验证方法
- Capability matrix has concrete YES/NO for each hook capability
- Baseline measurement has actual token counts, not estimates
- @import behavior has a tested YES/NO answer

### Phase 2: Prototype (max 30 min, conditional — skip if Phase 1 exhausts time budget)

#### 交付物
- [ ] Minimal test hook in settings.json (temporary, backed up and restored)
- [ ] Test results: fires? injects context? breaks anything? execution order vs CLAUDE.md?

#### 实施步骤
1. Copy `.claude/settings.json` to `.claude/settings.json.spike-backup`
2. Add minimal hook to settings.json
3. Test hook activation and context injection
4. Test coexistence with `/alex` and `/blake` commands
5. Restore from backup: `cp .claude/settings.json.spike-backup .claude/settings.json`
6. Verify restoration: `diff .claude/settings.json .claude/settings.json.spike-backup` (should be empty)
7. Delete backup: `rm .claude/settings.json.spike-backup`

#### 验证方法
- Hook fires on expected trigger
- Existing TAD commands still work after hook addition
- Settings restored to original after testing (verified by diff)

### Phase 3: Verdict (max 30 min)

#### 交付物
- [ ] SPIKE-VERDICT-20260323-session-hook.md with clear verdict, confidence level, and architecture recommendation

#### 实施步骤
1. Synthesize research + prototype findings
2. Write verdict document following the template in Section 4.2 (including Token Budget Analysis table)
3. If feasible: draft meta-skill bootstrap architecture with: (a) what stays in CLAUDE.md, (b) what defers, (c) triggers, (d) measured savings
4. If not feasible: document why + alternative approach + impact on Epic phases
5. Include confidence level (High/Medium/Low)

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/active/handoffs/SPIKE-VERDICT-20260323-session-hook.md  # Verdict document (main deliverable)
```

### 7.2 Files to Read (not modify)
```
.claude/settings.json                    # Current config (NO hooks field exists yet)
CLAUDE.md                                # Analyze content for slimming potential
.claude/commands/tad-alex.md             # Understand current loading pattern
.claude/commands/tad-blake.md            # Understand current loading pattern
.tad/config.yaml                         # Module loading pattern
```

### 7.3 Files to Temporarily Modify (backup → modify → restore)
```
.claude/settings.json                    # Add test hook, then restore from .spike-backup
```
**Rollback procedure**: Copy to `.spike-backup` before modification. Restore with `cp`. Verify with `diff`. Delete backup.

---

## 8. Testing Requirements

### 8.1 Spike-Specific Testing
- Test: Hook registration in settings.json (does Claude Code accept it?)
- Test: Hook fires at expected moment (session start? command invoke?)
- Test: Hook context injection (does injected text appear in agent context?)
- Test: Non-interference (do /alex, /blake still work with hook active?)

### 8.2 Rollback Verification
- After prototype: verify settings.json is restored from `.spike-backup`
- `diff .claude/settings.json .claude/settings.json.spike-backup` should show no output
- Then delete backup file
- Final check: `git status .claude/settings.json` should show no changes

---

## 9. Acceptance Criteria

Blake的调查被认为完成，当且仅当：
- [ ] AC1: Claude Code hooks capability matrix documented — execution model, trigger types, context injection ability (YES/NO per capability)
- [ ] AC2: **Baseline token measurement completed** — actual token counts for CLAUDE.md, resolved @imports, verified whether non-existent @imports cost tokens
- [ ] AC3: TAD CLAUDE.md content categorized by loading urgency (critical/important/deferrable)
- [ ] AC4: Token savings estimated with **measured baseline** (not assumed numbers)
- [ ] AC5: Alternative approaches (IT5) investigated — at least 2 alternatives assessed beyond hooks
- [ ] AC6: Prototype attempted (if hooks mechanism supports it) OR documented why prototype was skipped
- [ ] AC7: Verdict document created with clear ✅/⚠️/❌ + confidence level (High/Medium/Low)
- [ ] AC8: No permanent changes to TAD framework files (spike cleanup verified via `git status`)
- [ ] AC9: If feasible: meta-skill bootstrap architecture drafted with: (a) what stays in CLAUDE.md, (b) what defers, (c) triggers, (d) measured savings
- [ ] AC10: If not feasible: alternative approach documented + **impact on Epic phases** (how Phase 1-5 are affected)
- [ ] AC11: If baseline measurement shows optimization target is <10% of total context: explicitly document this finding and recommend whether the Epic should continue or pivot

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ This is a SPIKE — do NOT implement the full hook system. Produce a verdict, not production code.
- ⚠️ Always backup `.claude/settings.json` before any modification. Restore after testing.
- ⚠️ Do NOT install Superpowers. Reference its patterns from the research note only.

### 10.2 Known Constraints
- Claude Code hooks mechanism may have limited documentation
- Hook behavior may vary between Claude Code versions
- Time-box: max 2 hours total. If Phase 1 takes >60 min, skip Phase 2, go directly to verdict.
- **Optimization target may be small**: Expert review found agent files already load on-demand. If baseline measurement confirms <10% overhead, the spike's value proposition changes — document this honestly.

### 10.3 Sub-Agent使用建议
Blake应该考虑使用：
- [ ] **claude-code-guide** subagent — to research Claude Code hooks mechanism and capabilities (this is the primary research tool for this spike)
- [ ] **Explore** agent — to search for hooks examples in codebase or documentation

---

## 11. Decision Context

### Why Session Hook First (not Spec Compliance Reviewer)?

**选择的方案**: Session Hook spike as Phase 0

**考虑的替代方案**:

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| Hook spike first (选中) | Determines architecture for all subsequent phases | Might be infeasible, delaying real improvements | ✅ Risk is bounded (time-boxed spike) |
| Spec Compliance first | Immediate quality improvement | Adds more context to already-heavy files | Context bloat makes all later work harder |
| Anti-rationalization first | Lowest effort, immediate effect | Purely additive (more content) | Adds to the problem this spike aims to solve |

**💡 核心权衡**: Investing 2 hours in a spike that could save context overhead for ALL future phases vs. immediately starting a feature that adds more context.

---

---

## Expert Review Status

| Expert | Verdict | P0 Found | P0 Fixed | P1 Integrated | Overall |
|--------|---------|----------|----------|---------------|---------|
| code-reviewer | CONDITIONAL PASS | 2 | 2 ✅ | 4/4 key items | PASS (after fixes) |
| backend-architect | CONDITIONAL PASS | 3 | 3 ✅ | 4/5 key items | PASS (after fixes) |

### P0 Issues Fixed
1. **settings.json confusion** → Clarified: TAD's settings.json has no hooks field. Blake researches how to ADD hooks.
2. **Hooks mechanism misunderstanding** → Separated into two distinct approaches: shell hooks vs meta-skill bootstrap pattern (Section 2.4).
3. **Unsupported 60% claim** → Removed. Replaced with "TBD — baseline measurement is part of this spike." Added AC2 for measured baseline.
4. **No baseline measurement method** → Added explicit token counting methodology (char/4) and @import behavior test.

### P1 Items Integrated
- IT5 added: alternative context optimization approaches
- Hook execution ordering question added to IT1
- Rollback procedure: explicit backup/restore/verify/delete steps
- Time allocation: explicit max per phase with skip-Phase-2 rule
- Not-feasible impact: AC10 requires Epic phase impact assessment
- AC11: pivot recommendation if optimization target < 10%

### P1 Items Deferred (acceptable for spike)
- P2-3 (hook behavior during `claude --continue`): Added to IT4 as question, not blocking

**Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-23
**Version**: 3.1.0 (post-expert-review)
