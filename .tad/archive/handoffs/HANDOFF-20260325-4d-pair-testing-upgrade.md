# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-25
**Project:** TAD Framework
**Task ID:** TASK-20260325-001
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-25

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Template structure + protocol changes clearly defined |
| Components Specified | ✅ | 7 files identified with specific changes per file |
| Functions Verified | ✅ | All target files exist and have been read |
| Data Flow Mapped | ✅ | Template → Alex fills → Blake executes test → Report generated |

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
Upgrade TAD's pair testing templates and protocol to incorporate the "4D Protocol" (Discover→Discuss→Decide→Deliver) methodology, learned from menu-snap S04 pair testing. Remove Mode A (Chrome MCP), keep only Mode B (Claude Code + Playwright).

### 1.2 Why We're Building It
**业务价值**：1M context window makes real-time discovery+decision possible during pair testing. The old "find bugs → fix later" approach loses context. 4D keeps decisions in-session.
**用户受益**：Pair test reports become actionable decision logs, not just bug lists.
**成功的样子**：When Alex generates a TEST_BRIEF using the new template, it produces S04-level quality output with 4D methodology built in.

### 1.3 Intent Statement

**真正要解决的问题**：Pair testing currently separates "finding" from "deciding". With long context, these should be merged into a single session using the 4D Protocol.

**不是要做的**：
- ❌ 不是重写整个 pair testing 系统
- ❌ 不是改变 session management 机制（SESSIONS.yaml 等不变）
- ❌ 不是添加新的测试工具集成

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - 架构决策

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 2 条 | Manifest + Directory Isolation pattern; Minimal Viable Cross-Cutting Enhancement |

**⚠️ Blake 必须注意的历史教训**：

1. **Manifest + Directory Isolation for Multi-Instance Resources** (architecture.md)
   - Directories are ground truth, manifest can be rebuilt — don't break this pattern
   - SESSIONS.yaml structure stays unchanged

2. **Minimal Viable Cross-Cutting Enhancement** (architecture.md)
   - When adding cross-cutting features, start with the 2 most critical points
   - Don't over-engineer the template — keep it as a framework Alex fills, not a rigid checklist

---

## 2. Background Context

### 2.1 Source Material (menu-snap S04)

The following files from menu-snap inform this upgrade:

| File | Role | Key Innovation |
|------|------|----------------|
| `.tad/pair-testing/S04/TEST_BRIEF.md` | Evolved brief (700 lines) | Dual-mode, detailed Rounds, 4b inheritance |
| `.tad/pair-testing/S04/S04-FINDINGS-COMPLETE.md` | Evolved report format | Findings + Solutions Decided per Round |
| `docs/templates/TEST_BRIEF_TEMPLATE.md` | Old brief template (160 lines) | Original simple version (to be replaced) |

### 2.2 Current State (TAD)

| File | Lines | Status |
|------|-------|--------|
| `.tad/templates/test-brief-template.md` | 572 | Has Mode A + Mode B, no 4D |
| `.tad/templates/pair-test-report-template.md` | 134 | No "Solutions Decided" section |
| `.tad/config-workflow.yaml` (pair_testing section) | ~50 lines | References "Claude Desktop" in ownership |
| `tad-alex.md` (pair testing sections) | ~100 lines | No 4D reference |

### 2.3 Key Insight Driving This Change

**Long context (1M) changes the methodology**: With full session context preserved across 10+ Rounds, the pair test becomes a real-time product decision session, not just a bug-finding exercise. Solutions are decided at the moment of discovery, when context is richest.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Remove all Mode A (Chrome MCP / Claude Desktop) references from test-brief-template.md
- FR2: Add 4D Protocol (Discover→Discuss→Decide→Deliver) as core methodology in Section 6
- FR3: Update Round Summary format to include "Solutions Decided" table alongside Findings table
- FR4: Update pair-test-report-template.md to include per-Round "Solutions Decided" section
- FR5: Update config-workflow.yaml pair_testing.ownership to remove Claude Desktop reference
- FR6: Update tad-alex.md: fix 2 "Claude Desktop" references + add 4D Protocol mention
- FR7: Update tad-test-brief.md: remove Mode A, add 4D Protocol
- FR8: Update tad-help.md and tad.md: fix "Claude Desktop" text references
- FR9: Keep Round definitions as placeholder (6d) — Alex fills per project, template provides format + example

### 3.2 Non-Functional Requirements
- NFR1: Template should be shorter than S04's 700 lines (since Round content is project-specific)
- NFR2: All {placeholder} variables should be clearly marked
- NFR3: No breaking changes to SESSIONS.yaml or session directory structure

---

## 4. Technical Design

### 4.1 Changes Overview

```
7 files to modify:
├── .tad/templates/test-brief-template.md      ← MAJOR rewrite
├── .tad/templates/pair-test-report-template.md ← Add Solutions Decided
├── .tad/config-workflow.yaml                   ← Minor text update
├── .claude/commands/tad-alex.md               ← Update 2 "Claude Desktop" refs + add 4D
├── .claude/commands/tad-test-brief.md         ← Remove Mode A refs, add 4D
├── .claude/commands/tad-help.md               ← Minor text update (1-2 lines)
└── .claude/commands/tad.md                    ← Minor text update (1 line)
```

### 4.2 test-brief-template.md — Detailed Changes

**REMOVE:**
- Section 6.0 Mode Selection (entire table + "How to choose" block)
- Section 6e-A Mode A screenshots (Chrome MCP gif_creator instructions)
- All references to "Mode A", "Claude Desktop", "Chrome MCP", ".gif"
- The "Two modes are supported" language from Section 6 header

**ADD:**
- 4D Protocol definition at the top of Section 6 (before 6a):

```markdown
### 4D Protocol: Discover → Discuss → Decide → Deliver

> Core methodology for pair testing with long-context AI.
> Instead of "find bugs now, fix later", use the 1M context window to
> discover, discuss, and decide solutions in the same session.

| Phase | What Happens | Output |
|-------|-------------|--------|
| **Discover** | Execute test step, observe, screenshot | Observation (OK / MAYBE / ISSUE) |
| **Discuss** | Human + AI discuss the finding together | Shared understanding of root cause |
| **Decide** | Agree on the solution approach on the spot | "Solutions Decided" entry |
| **Deliver** | Record finding + solution in Round summary | Actionable decision log |

**Why this works**: With 1M context, Round 10 still has full detail from Round 1.
Decisions made at discovery time have the richest context — don't defer them.
```

- Update 6f Round Summary format to include Solutions Decided table:

```markdown
### Solutions Decided (Round {N})
| # | Change | Detail |
|---|--------|--------|
| 1 | {change_title} | {specific_change_description} |
```

- Update Section 6g Final Report to reference 4D:
  - Report structure: Per-Round sections with Findings + Solutions Decided (not just a flat findings list)

**MODIFY:**
- Section 6 header: Remove "Two modes supported", replace with "Uses Claude Code + Playwright (Mode B)"
- Section 6e: Remove `.gif` extension mention, keep only `.png`
- Section 6h: Rename from "Mode B Setup" to just "Browser Controller Setup" (remove Mode B prefix)
- Section 7 report format: Add "Solutions Decided per Round" to expected output

**KEEP UNCHANGED:**
- Sections 1-5 (Product Overview, Test Scope, Accounts, Known Issues, Previous Session Context, Focus Areas)
- Section 6a (Role Definition)
- Section 6b (Overall Rhythm — action lifecycle, round lifecycle, forbidden list)
- Section 6c (Pre-Test Preparation)
- Section 6d (Round Definitions — placeholder structure)
- Section 6e-B → becomes Section 6e (the only screenshot method now)
- Section 6h architecture, controller script, command reference (just remove "Mode B" prefix)
- Section 8 (Technical Notes)

### 4.3 pair-test-report-template.md — Detailed Changes

**ADD after Section 2b (Regression Verification):**

New Section 2c: "Per-Round Findings & Decisions"

```markdown
## 2c. Per-Round Findings & Decisions (4D Protocol)

### Round {N}: {title}

#### Findings
| # | Finding | Severity | Screenshot |
|---|---------|----------|------------|
| R{N}-1 | {description} | P0/P1/P2 | {ref} |

#### Solutions Decided
| # | Change | Detail |
|---|--------|--------|
| 1 | {change_title} | {specific_change} |

#### S03 Regression Verified (if applicable)
- [x] {regression_item} ✅
- [ ] {regression_item} ❌ {note}

<!-- Repeat for each Round -->
```

**MODIFY:**
- File header (line 2): Change "Generated by Claude Desktop + human pair testing" to "Generated by Claude Code + human pair testing (4D Protocol)"
- Section 1: Change "Participants" default from "Product owner + Claude Desktop" to "Product owner + Claude Code"
- Section 5 (Per-Round Detail): Replace body with a single line: `See Section 2c above for per-round findings and decisions.` (avoids duplication — 2c IS the per-round detail)
- Section 8: Change "Suggested Action" column to "Decided Solution" (solutions are already decided via 4D)

### 4.4 config-workflow.yaml — Changes

```yaml
# Change line:
ownership: "Alex generates brief, human decides, Claude Desktop executes with human"
# To:
ownership: "Alex generates brief, human decides, Claude Code + Playwright executes with human"

# Add under pair_testing:
methodology: "4D Protocol (Discover→Discuss→Decide→Deliver)"
```

### 4.5 tad-alex.md — Changes

**Two "Claude Desktop" references to update:**

1. In `step_pair_testing_assessment`, AskUserQuestion description:
   - From: "生成 .tad/pair-testing/{session_id}/TEST_BRIEF.md 用于 Claude Desktop Cowork 配对测试"
   - To: "生成 .tad/pair-testing/{session_id}/TEST_BRIEF.md 用于 Claude Code + Playwright 配对测试 (4D Protocol)"

2. In `step_pair_testing_assessment`, the "Remind human" text block (~5 lines below):
   - From: "请将 .tad/pair-testing/{session_id}/TEST_BRIEF.md 拖入 Claude Desktop Cowork 进行配对 E2E 测试。"
   - To: "请在 Claude Code 中打开新 terminal，运行配对测试脚本（参考 TEST_BRIEF Section 6h）进行 E2E 测试。"

**Verification**: `grep "Claude Desktop" .claude/commands/tad-alex.md` → 0 hits in pair_testing sections

In `test_review_protocol`, no structural changes needed (it processes reports, format is backward compatible). Note: test_review_protocol currently only extracts Finding/Priority patterns — it does not read "Solutions Decided" entries. This is acceptable for now; future enhancement can add decision extraction.

### 4.6 tad-test-brief.md — Changes

This is the **dedicated pair testing command** file. It must be updated to match the template changes.

- Replace all "Claude Desktop" references with "Claude Code + Playwright"
- Replace "Mode A" / "Mode B" dual-mode language with single-mode (Playwright only)
- Add mention of 4D Protocol in the command description

### 4.7 tad-help.md and tad.md — Minor Text Updates

These files contain brief descriptions of pair testing that reference "Claude Desktop":

- `tad-help.md`: Update pair testing description to "Claude Code + Playwright"
- `tad.md`: Update pair testing entry to "Claude Code + Playwright"

These are simple text replacements (1-2 lines each).

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 否 → 这是模板/配置更新，不涉及"之前的代码"复用

### MQ2: 函数存在性验证
N/A — no code functions involved, only template and config files.

### MQ3-MQ5
N/A — no data flow, no visual states, no state sync. This is a documentation/template task.

---

## 6. Implementation Steps

### Phase 1: Update test-brief-template.md (~30 min)

#### 交付物
- [ ] Mode A references removed
- [ ] 4D Protocol section added to Section 6
- [ ] Round Summary format updated with "Solutions Decided"
- [ ] Section 6h renamed (Mode B prefix removed)
- [ ] Screenshot section unified to .png only

#### 实施步骤
1. Read current `.tad/templates/test-brief-template.md` (already in context)
2. Remove Mode A blocks: Section 6.0, 6e-A, all "Mode A" / "Chrome MCP" / ".gif" references
3. Add 4D Protocol definition between Section 6 header and 6a
4. Update 6f Round Summary to include "Solutions Decided" table
5. Update 6g Final Report generation to reference 4D per-Round structure
6. Rename 6h from "Mode B Setup" to "Browser Controller Setup"
7. Update Section 7 report format expectations

#### 验证方法
- Grep for "Mode A", "Chrome MCP", "gif_creator", "Claude Desktop" — should return 0 hits
- Grep for "4D Protocol" — should return at least 2 hits
- Grep for "Solutions Decided" — should return at least 2 hits

### Phase 2: Update pair-test-report-template.md (~15 min)

#### 交付物
- [ ] Section 2c added (Per-Round Findings & Decisions)
- [ ] Section 1 "Participants" updated
- [ ] Section 8 "Suggested Action" → "Decided Solution"

#### 实施步骤
1. Add Section 2c after Section 2b
2. Update Section 1 participant text
3. Update Section 5 to reference 2c
4. Update Section 8 column header

#### 验证方法
- Section 2c exists with Findings + Solutions Decided tables
- No references to "Claude Desktop" in participant field

### Phase 3: Update config + command files (~25 min)

#### 交付物
- [ ] config-workflow.yaml pair_testing.ownership updated + methodology added
- [ ] tad-alex.md: 2 "Claude Desktop" refs updated + 4D mentioned
- [ ] tad-test-brief.md: Mode A removed, 4D added
- [ ] tad-help.md: pair testing description updated
- [ ] tad.md: pair testing entry updated

#### 实施步骤
1. Edit config-workflow.yaml: update ownership line, add methodology field
2. Edit tad-alex.md: update 2 "Claude Desktop" references in step_pair_testing_assessment (AskUserQuestion + remind human block)
3. Edit tad-test-brief.md: replace "Claude Desktop" with "Claude Code + Playwright", remove Mode A references, add 4D Protocol mention
4. Edit tad-help.md: update pair testing description line(s)
5. Edit tad.md: update pair testing entry

#### 验证方法
- `grep "Claude Desktop" .tad/config-workflow.yaml` — 0 hits in pair_testing section
- `grep "Claude Desktop" .claude/commands/tad-alex.md` — 0 hits in pair_testing sections
- `grep "Claude Desktop" .claude/commands/tad-test-brief.md` — 0 hits
- `grep "Claude Desktop" .claude/commands/tad-help.md` — 0 hits in pair testing refs
- `grep "Claude Desktop" .claude/commands/tad.md` — 0 hits in pair testing refs
- `grep "4D" .claude/commands/tad-alex.md` — at least 1 hit

### Phase 4: Sync to menu-snap (~5 min)

Note: This phase is executed by human via `*sync` in Alex terminal, not by Blake.
Blake only handles Phase 1-3.

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/templates/test-brief-template.md       # Major: remove Mode A, add 4D
.tad/templates/pair-test-report-template.md  # Medium: add Section 2c, update header
.tad/config-workflow.yaml                    # Minor: 2 line changes
.claude/commands/tad-alex.md                 # Minor: 2 text updates
.claude/commands/tad-test-brief.md           # Medium: remove Mode A refs, add 4D
.claude/commands/tad-help.md                 # Minor: 1-2 line text updates
.claude/commands/tad.md                      # Minor: 1 line text update
```

### 7.2 Files NOT to Modify
```
.tad/pair-testing/SESSIONS.yaml              # Session structure unchanged
.tad/config-agents.yaml                      # Not related
.tad/config-execution.yaml                   # Blake-specific, not related
```

---

## 8. Testing Requirements

### 8.1 Verification Checklist
- [ ] `grep -r "Mode A" .tad/templates/test-brief-template.md` → 0 results
- [ ] `grep -r "Chrome MCP" .tad/templates/test-brief-template.md` → 0 results
- [ ] `grep -r "gif_creator" .tad/templates/test-brief-template.md` → 0 results
- [ ] `grep -r "Claude Desktop" .tad/templates/test-brief-template.md` → 0 results
- [ ] `grep -r "4D Protocol" .tad/templates/test-brief-template.md` → ≥2 results
- [ ] `grep -r "Solutions Decided" .tad/templates/test-brief-template.md` → ≥2 results
- [ ] `grep -r "Solutions Decided" .tad/templates/pair-test-report-template.md` → ≥1 result
- [ ] `grep -r "Claude Desktop" .tad/config-workflow.yaml` → 0 results in pair_testing section
- [ ] `grep "Claude Desktop" .claude/commands/tad-alex.md` → 0 results in pair_testing sections
- [ ] `grep "Claude Desktop" .claude/commands/tad-test-brief.md` → 0 results
- [ ] `grep "Claude Desktop" .claude/commands/tad-help.md` → 0 results in pair testing refs
- [ ] `grep "Claude Desktop" .claude/commands/tad.md` → 0 results in pair testing refs
- [ ] `grep "4D" .claude/commands/tad-alex.md` → ≥1 result

### 8.2 Manual Review
- Read through updated test-brief-template.md end-to-end for coherence
- Verify placeholder variables are consistent ({session_id}, {N}, etc.)

---

## 9. Acceptance Criteria

- [ ] AC1: Mode A (Chrome MCP) completely removed from test-brief-template.md
- [ ] AC2: 4D Protocol defined as core methodology in Section 6 of test-brief-template.md
- [ ] AC3: Round Summary format includes "Solutions Decided" table
- [ ] AC4: pair-test-report-template.md has per-Round Findings + Solutions Decided structure
- [ ] AC5: config-workflow.yaml references Claude Code (not Claude Desktop) and 4D methodology
- [ ] AC6: tad-alex.md references 4D Protocol, no "Claude Desktop" in pair testing sections
- [ ] AC7: tad-test-brief.md references Claude Code + Playwright, no "Claude Desktop"
- [ ] AC8: tad-help.md and tad.md pair testing entries updated (no "Claude Desktop")
- [ ] AC9: No "Claude Desktop", "Mode A", "Chrome MCP", "gif_creator" strings in updated templates
- [ ] AC10: Template remains generic (Round definitions are placeholder, not project-specific)

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | Mode A removed | grep "Mode A\|Chrome MCP\|gif_creator" in template | 0 matches |
| 2 | 4D Protocol in brief template | grep "4D Protocol" in test-brief-template.md | ≥2 matches |
| 3 | Solutions Decided in brief | grep "Solutions Decided" in test-brief-template.md | ≥2 matches |
| 4 | Solutions Decided in report | grep "Solutions Decided" in pair-test-report-template.md | ≥1 match |
| 5 | Config updated | grep "Claude Desktop" in config-workflow.yaml pair_testing | 0 matches |
| 6 | Alex references 4D | grep "4D" in tad-alex.md | ≥1 match |
| 7 | tad-test-brief.md clean | grep "Claude Desktop" in tad-test-brief.md | 0 matches |
| 8 | tad-help + tad clean | grep "Claude Desktop" in tad-help.md and tad.md pair testing refs | 0 matches |
| 9 | Round defs are placeholder | Section 6d has `<!-- Alex fills -->` comment | Present |
| 10 | Template shorter than S04 | wc -l test-brief-template.md | < 570 (vs S04's 700) |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Do NOT modify SESSIONS.yaml schema or session directory structure
- ⚠️ The Playwright controller script in 6h stays as-is (it works, tested in S04)
- ⚠️ Keep all {placeholder} syntax consistent with current template conventions

### 10.2 Reference Material
- menu-snap S04 TEST_BRIEF: `.tad/pair-testing/S04/TEST_BRIEF.md` (in menu-snap project)
- menu-snap S04 Report: `.tad/pair-testing/S04/S04-FINDINGS-COMPLETE.md` (in menu-snap project)
- These are READ-ONLY references — do not copy project-specific content into TAD generic templates

---

## Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Remove Mode A | Keep both / Remove A / Remove B | Remove A | User found Chrome MCP unreliable and limited |
| 2 | 4D as core methodology | Core / Recommended / Just format change | Core | 4D is the main insight from S04 — it should be the organizing principle |
| 3 | Round definitions | Pre-built generic rounds / Placeholder | Placeholder | Rounds are project-specific; template provides format + example |

---

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed | Result |
|--------|-----------|----------|----------|--------|
| code-reviewer | CONDITIONAL PASS → PASS | 2 | 2 ✅ | All P0 addressed |
| backend-architect | CONDITIONAL PASS → PASS | 2 | 2 ✅ | All P0 addressed |

**P0 Issues Fixed:**
1. ✅ tad-alex.md second "Claude Desktop" ref (remind human text) — added to Section 4.5
2. ✅ tad-test-brief.md + tad-help.md + tad.md scope gap — added Sections 4.6 + 4.7, updated file list, FR, Phase 3, AC, verification

**P1 Issues Addressed:**
- ✅ Report template header "Claude Desktop" — added to Section 4.3 MODIFY
- ✅ Section 5 vs 2c ambiguity — explicit instruction to replace Section 5 body with pointer
- ✅ Line count AC — relaxed from < 500 to < 570
- ✅ Section 6e .gif reference — covered in MODIFY instructions

**Final Status: Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-25
**Version**: 3.1.0
