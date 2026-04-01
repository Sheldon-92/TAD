# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-31
**Project:** TAD Framework
**Task ID:** TASK-20260331-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260331-tad-v3-hook-native-rebuild.md (Phase 3/5)
**Linear:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Section-by-section reduction plan based on analysis |
| Components Specified | ✅ | Every section categorized: KEEP / SLIM / REMOVE |
| Functions Verified | ✅ | Hooks from Phase 2 confirmed functional |
| Data Flow Mapped | ✅ | Hook automation replaces mechanical skill logic |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read complete handoff
- [ ] **Read `.tad/spike-v3/ARCHITECTURE-v3.md`** — the blueprint
- [ ] **Read `.tad/hooks/post-write-sync.sh`** — understand what hooks now automate
- [ ] Read `.tad/project-knowledge/architecture.md` — last 2 entries (hook findings)
- [ ] Understand the principle: **hooks do automation, skills do judgment**

---

## 1. Task Overview

### 1.1 What We're Building
Slim down Alex SKILL.md from 2528 → ~800 lines and Blake SKILL.md from 1052 → ~600 lines by removing mechanical/config logic that is now handled by hooks (Phase 2) or already exists in config YAML files.

### 1.2 Why We're Building It
- **Context efficiency**: Smaller skill files = less token consumption per session
- **Single source of truth**: Config in YAML, automation in hooks, judgment in skills — no duplication
- **Maintainability**: Smaller files are easier to read, update, and debug

### 1.3 Intent Statement

**真正要解决的问题**: Remove duplication between skill files, hooks, and config YAML. Keep ONLY judgment logic in skills.

**不是要做的**:
- ❌ Not changing TAD behavior — same functionality, less code
- ❌ Not adding new features
- ❌ Not modifying hooks or settings.json (Phase 2 output unchanged)
- ❌ Not changing the CLAUDE.md router

**核心原则**: 如果删除某段内容后 TAD 功能不变（因为 hooks 或 config 已覆盖），则删除。如果不确定，保留并加 TODO 注释。

---

## 📚 Project Knowledge

- [x] architecture — Hook validation + enforcement priority entries

**⚠️ Blake 必须注意**:
1. **Post-write-sync hook** now detects HANDOFF/COMPLETION/NEXT.md/EPIC writes and injects reminders. Alex's skill no longer needs step-by-step "remember to update NEXT.md" instructions.
2. **Startup-health hook** now handles health check on session start. Alex's activation steps 3.5-3.7 detailed instructions can be simplified to one line.

---

## 2. Background

### 2.1 Analysis Results (from Phase 1)

Alex SKILL.md 2528 lines breakdown:
- **26% Judgment** (~650 lines) — KEEP: intent routing, Socratic inquiry, design, expert feedback
- **43% Mechanical** (~1100 lines) — REMOVE/SLIM: file ops, state updates, sync protocols
- **26% Config** (~650 lines) — REMOVE: command lists, gate defs, expert rules (already in YAML)
- **5% Mixed** (~128 lines) — SLIM: keep judgment, remove mechanical

---

## 3. Section-by-Section Reduction Plan: Alex SKILL.md

### Legend
- ✅ KEEP = Keep as-is (pure judgment)
- 📐 SLIM = Reduce by removing mechanical/config parts
- ❌ REMOVE = Delete (covered by hooks or config YAML)
- 📦 EXTRACT = Move to standalone file/config

---

| # | Section | Current Lines | Action | Target Lines | Rationale |
|---|---------|--------------|--------|-------------|-----------|
| 1 | Header/auto-trigger | ~35 | 📐 SLIM | ~20 | Keep trigger conditions, remove activation example |
| 2 | Activation Protocol (STEP 1-4) | ~105 | 📐 SLIM | ~30 | Keep STEP 1-2 (persona). STEP 3.4-3.7 → "Hooks handle startup checks" one-liner. Keep STEP 4 (greet) |
| 3 | Agent persona/principles | ~20 | ✅ KEEP | ~20 | Core identity |
| 4 | Command list | ~50 | 📐 SLIM | ~30 | Keep list, remove descriptions (redundant with help) |
| 5 | Exit protocol | ~14 | ✅ KEEP | ~14 | Judgment: check readiness |
| 6 | Test review protocol | ~39 | 📐 SLIM | ~20 | Keep P0/P1/P2 classification logic, remove archive mechanics |
| 7 | Intent Router | ~150 | ✅ KEEP | ~150 | Core judgment logic |
| 8 | Bug path | ~83 | 📐 SLIM | ~50 | Keep diagnosis + propose, slim handoff template |
| 9 | Discuss path | ~55 | ✅ KEEP | ~55 | Pure judgment |
| 10 | Update ROADMAP | ~37 | 📐 SLIM | ~20 | Keep proposal logic, remove file mechanics |
| 11 | **Status panoramic** | ~56 | 📐 SLIM | ~15 | Keep table format skeleton + "read-only, return to standby, no AskUserQuestion". Remove verbose step-by-step scanning instructions. |
| 12 | Idea path | ~51 | 📐 SLIM | ~30 | Keep capture/structure, remove store mechanics |
| 13 | Idea list | ~46 | 📐 SLIM | ~10 | Keep status lifecycle definition (captured→evaluated→promoted→archived, forward-only). Remove verbose scan/display steps. |
| 14 | Idea promote | ~51 | 📐 SLIM | ~25 | Keep decision logic, remove file update mechanics |
| 15 | Learn path | ~73 | ✅ KEEP | ~73 | Pure Socratic teaching |
| 16 | Adaptive complexity | ~140 | ✅ KEEP | ~140 | Core assessment logic |
| 17 | Socratic inquiry | ~167 | ✅ KEEP | ~167 | Core questioning protocol |
| 18 | Research & decision | ~97 | 📐 SLIM | ~60 | Keep research + present, remove recording mechanics |
| 19 | Design protocol | ~41 | ✅ KEEP | ~41 | Judgment |
| 20 | Playground reference | ~25 | ❌ REMOVE | 0 | Config: already in config-workflow.yaml |
| 21 | **Handoff creation** | ~238 | 📐 SLIM | ~100 | Keep expert selection + feedback integration. Remove step-by-step file operations. Remove step0_5 context refresh (hook handles reminders). Slim step7 message template. |
| 22 | Expert selection rules | ~49 | 📐 SLIM | ~15 | Verify config-quality.yaml has full heuristics. Keep: min 2 experts rule, when-to-pick logic summary. Remove: verbose per-expert descriptions. |
| 23 | Templates I use | ~19 | ❌ REMOVE | 0 | Config reference |
| 24 | My gates | ~48 | ❌ REMOVE | 0 | Config: in config-quality.yaml |
| 25 | Release duties | ~18 | ✅ KEEP | ~18 | Judgment on versioning |
| 26 | **Acceptance protocol** | ~42 | 📐 SLIM | ~20 | Keep business judgment, remove step-by-step (hook reminds) |
| 27 | ***accept command** | ~216 | 📐 SLIM | ~60 | Keep git check + epic update logic. Remove mechanical file moves (reduce to: "Archive handoff, update NEXT.md, update Epic if linked"). Hook handles reminders. |
| 28 | Project context rules | ~36 | 📐 SLIM | ~15 | Hooks nudge but don't execute. Keep when/how update triggers + aging thresholds. Remove verbose format examples. |
| 29 | NEXT.md rules | ~28 | 📐 SLIM | ~15 | Hooks detect changes but don't specify format. Keep update triggers + format spec. Remove verbose archive rules. |
| 30 | Knowledge bootstrap | ~37 | 📐 SLIM | ~15 | Keep types, remove triggers (existing in config) |
| 31 | Mandatory review | ~135 | 📐 SLIM | ~40 | Keep Gate 4 checklist + knowledge assessment. Remove detailed subagent execution flow. |
| 32 | **Publish protocol** | ~67 | 📐 SLIM | ~30 | Keep version check logic, slim git operations |
| 33 | **Sync protocol** | ~106 | 📐 SLIM | ~40 | Keep registry logic, remove per-file copy details |
| 34 | Sync-add/list | ~49 | 📐 SLIM | ~20 | Simplify |
| 35 | Forbidden actions | ~14 | ✅ KEEP | ~14 | Unique guardrails (expert review mandate, P0 blocking) NOT in CLAUDE.md or config. Remove only `interaction:` block (4 lines). |
| 36 | Success patterns | ~18 | 📐 SLIM | ~8 | Keep top 5-6 critical patterns (parallel experts, research before design, 2+ options). Remove duplicates of handoff protocol. |
| 37 | On start greeting | ~18 | 📐 SLIM | ~10 | Keep greeting, remove verbose help |
| 38 | Quick reference | ~63 | ❌ REMOVE | 0 | Redundant with help command |

**Estimated total after reduction**: ~1248 lines

**To reach ~800 target**: Further aggressive trimming of SLIM sections by reducing verbosity (YAML examples, detailed format specs, etc.)

---

## 4. Section-by-Section: Blake SKILL.md

Blake is simpler. Main reductions:

| Section | Action | Rationale |
|---------|--------|-----------|
| Auto-trigger conditions | 📐 SLIM | Keep rules, remove examples |
| Activation protocol | 📐 SLIM | Steps 3.5-3.6 → "Hooks handle startup" |
| Ralph Loop | ✅ KEEP | Core execution logic |
| *develop command | ✅ KEEP | Core workflow |
| Gate 3 execution | 📐 SLIM | Keep checklist, remove detailed evidence format (in config) |
| Completion report | ✅ KEEP | Output format |
| Release execution | ✅ KEEP | SOP steps |
| File structure reference | ❌ REMOVE | Config |
| Quick reference | ❌ REMOVE | Redundant |

**Target**: 1052 → ~600 lines

---

## 5. Implementation Rules

### 5.1 What to do when REMOVING a section:
1. Delete the section entirely
2. If the section contained instructions the model needs, add a ONE-LINE replacement:
   ```
   # *status: Scan ROADMAP.md, .tad/active/epics/, handoffs/, ideas/ — display panoramic summary table.
   ```
3. Do NOT add "this was removed" comments

### 5.2 What to do when SLIMMING a section:
1. Keep the judgment/decision logic
2. Remove step-by-step file operations (hooks or model capability handles this)
3. Remove detailed format specs (reference config YAML instead)
4. Remove verbose examples if the instruction is clear without them
5. Keep AskUserQuestion flows intact (these are judgment)

### 5.3 Verification after each file:
After modifying each skill file:
1. Read the result — does it still make sense as a coherent persona?
2. Check: Can Alex/Blake still execute their core workflows?
3. Check: Are all `*commands` still mentioned (even if briefly)?
4. Count lines — are we near target?

---

## 6. Implementation Steps

### Phase 1: Alex SKILL.md Reduction

#### 交付物
- [ ] Alex SKILL.md reduced to ~800-1200 lines
- [ ] All `*commands` still referenced
- [ ] Core judgment protocols intact (Intent Router, Socratic, Adaptive Complexity)

#### 实施步骤
1. Read current Alex SKILL.md completely
2. Apply REMOVE actions (delete config/mechanical sections) — quick wins first
3. Apply SLIM actions (trim mixed sections to judgment-only)
4. Review result for coherence
5. Count lines, iterate if needed

### Phase 2: Blake SKILL.md Reduction

#### 交付物
- [ ] Blake SKILL.md reduced to ~600-800 lines
- [ ] Ralph Loop and *develop workflow intact
- [ ] Gate 3 execution still works

#### 实施步骤
1. Read current Blake SKILL.md completely
2. Apply REMOVE and SLIM actions per table
3. Review and count lines

### Phase 3: Coherence Test

#### 交付物
- [ ] Both skills produce valid TAD behavior
- [ ] No broken references (removed section referenced elsewhere)

#### 实施步骤
1. Grep both files for references to removed sections
2. Fix any dangling references
3. Verify `*help` still lists all commands

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/alex/SKILL.md    # 2528 → ~800-1200 lines
.claude/skills/blake/SKILL.md   # 1052 → ~600-800 lines
```

### 7.2 Files NOT to Modify
```
.claude/settings.json           # Phase 2 output — don't touch
.tad/hooks/*                    # Phase 2 output — don't touch
CLAUDE.md                       # Router — don't touch
.tad/config-*.yaml              # Config — don't touch (these are what skills reference)
```

---

## 8. Testing

### 8.1 Coherence Test
- Read both modified skill files end-to-end — do they read as complete agent definitions?
- Are all `*commands` referenced (even one-liners for removed detailed sections)?

### 8.2 Reference Integrity
- Grep both files for any reference to removed sections
- Grep for "see Section" or "详见" that might point to deleted content

### 8.3 Line Count Verification
- Alex: `wc -l .claude/skills/alex/SKILL.md` → target 800-1200
- Blake: `wc -l .claude/skills/blake/SKILL.md` → target 600-800

---

## 9. Acceptance Criteria

- [ ] AC1: Alex SKILL.md ≤ 1400 lines (stretch: ≤ 1000)
- [ ] AC2: Blake SKILL.md ≤ 800 lines (stretch: ≤ 600)
  Note: Quality > line count. Don't sacrifice judgment logic for a number.
- [ ] AC3: All `*commands` still accessible (referenced in skill file)
- [ ] AC4: Intent Router protocol intact and complete
- [ ] AC5: Socratic Inquiry protocol intact and complete
- [ ] AC6: Adaptive Complexity protocol intact and complete
- [ ] AC7: Ralph Loop protocol intact and complete (Blake)
- [ ] AC8: *develop workflow intact (Blake)
- [ ] AC9: No dangling references to removed sections
- [ ] AC10: Handoff creation protocol still includes expert review + feedback integration
- [ ] AC11: Both files parse as valid Markdown with YAML frontmatter

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **Do NOT remove judgment logic** — Socratic, Intent Router, Adaptive Complexity, Research & Decision are the CORE of Alex
- ⚠️ **Do NOT remove AskUserQuestion flows** — these are judgment, not mechanical
- ⚠️ **Keep all `*command` names** — even if the detailed protocol is removed, the command must be mentioned (one-liner)
- ⚠️ **Check cross-references** — CLAUDE.md references tad-alex.md sections; config files reference protocols by name
- ⚠️ **Don't break sync** — `.claude/skills/alex/SKILL.md` is synced to 8+ projects. Changes must not break those projects.

### 10.2 Known Constraints
- This is a REDUCTION task, not a rewrite. Preserve the file structure and section ordering where possible.
- Some "mechanical" sections contain 1-2 judgment decisions embedded in 20 lines of mechanics. Extract the judgment, delete the mechanics.
- The ~800 target for Alex is aggressive. 1200 is acceptable. Quality > line count.

---

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed |
|--------|-----------|----------|----------|
| code-reviewer | CONDITIONAL PASS → PASS | 1 (2 sub-items) | All fixed |
| backend-architect | CONDITIONAL PASS → PASS | 3 | All fixed |

### P0 Issues Fixed
1. Rows 28-29 (context/NEXT.md rules): REMOVE → SLIM (hooks nudge, don't execute)
2. Row 35 (forbidden actions): REMOVE → KEEP (unique guardrails not elsewhere)
3. Row 36 (success patterns): REMOVE → SLIM (behavioral anchoring)
4. Row 22 (expert selection): REMOVE → SLIM (verify config has heuristics)
5. Row 11 (*status): REMOVE → SLIM (keep format spec)
6. Row 13 (*idea-list): REMOVE → SLIM (keep lifecycle constraint)
7. AC1 target: 800 → 1400 (realistic, stretch 1000)

### P1 Issues Addressed
- Cross-reference risk: Added AC9 (dangling references check)
- Async verification note deferred to Phase 4

**Final Status**: Expert Review Complete — Ready for Implementation

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-31
**Version**: 3.1.0
