---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/blake"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-09
**Project:** TAD Framework
**Task ID:** TASK-20260609-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-skill-body-reference-boundary.md (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 3 refs to inline, 1 script to create, 1 principle to add |
| Components Specified | ✅ | Inline locations identified (stub lines 305, 494, 517) |
| Functions Verified | ✅ | Target stubs confirmed via grep |
| Data Flow Mapped | ✅ | Phase 1 audit → this phase → Phase 3 verify |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
Inline the 3 must-body Blake references back into Blake SKILL.md body, create an automated body-integrity checker, and record a new principle.

### 1.2 Why We're Building It
**业务价值**：Blake 在 Codex 上将恢复完整的执行纪律——Layer 2 专家审查、Gate 3 checklist、completion report 都会在上下文中，不再被跳过。

**成功的样子**：Blake SKILL.md body 包含所有核心执行规则，自动化脚本在每次发版时验证不回归。

### 1.3 Intent Statement

**真正要解决的问题**：把 Codex dogfood 中被跳过的 3 个执行纪律协议从 references/ 搬回 body。

**不是要做的**：
- ❌ 不动 Alex SKILL.md（Phase 1 确认 Alex refs 全部 reference-ok）
- ❌ 不动 blake/cross-model-invocation.md 和 blake/notebooklm-access.md（reference-ok）
- ❌ 不重新设计 progressive loading（架构保持不变，只修正 body/reference 边界）

**⚠️ 必须同步 `.agents/skills/blake/`**：`.agents/` 是 `.claude/skills/` 的 Codex 适配镜像（byte-identical）。修改 `.claude/skills/blake/SKILL.md` 后必须同步到 `.agents/skills/blake/SKILL.md`，同样删除 `.agents/skills/blake/references/` 下的 3 个文件。否则 Codex（原始 bug 平台）仍然看到旧 stubs 指向已删除的 references。

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ Blake 必须注意的历史教训**：

1. **Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical** (principles.md)
   - 教训：MUST/MANDATORY/VIOLATION 规则不能从 body 移除。本次 inline 时确保每一个 constraint 关键词都保留。

2. **Circular Trigger Pattern** (patterns/handoff-design.md — Phase 1 刚记录)
   - 教训：这 3 个 refs 的 load_when 是循环触发——引用了自身定义的概念。inline 后删除 reference 文件和 stub，用实际内容替换。

3. **Rewiring a Gate's Prose Can Trip grep -c SAFETY Count** (principles.md)
   - 教训：inline 时保留所有 safety 关键词的原始拼写。不要在 inline 过程中重命名、缩写或意译 MUST/MANDATORY/VIOLATION。

---

## 2. Implementation Plan

### Task 1: Inline ralph-loop.md into Blake SKILL.md

**Current stub (around line 305):**
```yaml
ralph_loop:
  reference: ".claude/skills/blake/references/ralph-loop.md"
  load_when: "..."
```

**Action:** Replace the entire stub block with the full content of `ralph-loop.md` (719 lines). Preserve the YAML structure — the content should be nested under the same section where the stub was.

**Verification:** `grep -c 'Layer 2' .claude/skills/blake/SKILL.md` should increase after inline (ralph-loop defines Layer 2 requirements).

### Task 2: Inline execution-checklist.md into Blake SKILL.md

**Current stub (around line 494):**
```yaml
execution_checklist:
  reference: ".claude/skills/blake/references/execution-checklist.md"
  load_when: "..."
```

**Action:** Replace stub with full content of `execution-checklist.md` (240 lines).

**Verification:** `grep -c 'task_type_branching\|hard_requirement_distinct_reviewers' .claude/skills/blake/SKILL.md` should return ≥2 after inline.

### Task 3: Inline completion-protocol.md into Blake SKILL.md

**Current stub (around line 517):**
```yaml
completion_protocol:
  reference: ".claude/skills/blake/references/completion-protocol.md"
  load_when: "..."
```

**Action:** Replace stub with full content of `completion-protocol.md` (333 lines).

**Verification:** `grep -c 'gate3_verdict\|completion_report' .claude/skills/blake/SKILL.md` should return ≥2 after inline.

### Task 4: Delete inlined reference files

After inline, delete:
- `.claude/skills/blake/references/completion-protocol.md`
- `.claude/skills/blake/references/execution-checklist.md`
- `.claude/skills/blake/references/ralph-loop.md`

**Verification:** `ls .claude/skills/blake/references/` should show only `cross-model-invocation.md` and `notebooklm-access.md`.

### Task 5: Create skill-body-verify.sh

Create `.tad/hooks/lib/skill-body-verify.sh` — a checker script that verifies execution-discipline keywords remain in Blake's SKILL body.

**Requirements:**
- Check that Blake SKILL.md body contains key execution-discipline markers:
  - `ralph_loop` or `Ralph Loop` (execution mechanism present)
  - `Layer 2` or `layer_2` (expert review requirement present)
  - `gate3_verdict` (Gate 3 marker present)
  - `completion_report` or `completion_protocol` (completion protocol present)
  - `task_type_branching` (execution checklist present)
  - `hard_requirement_distinct_reviewers` (reviewer requirement present)
- Accept optional file path argument: `bash .tad/hooks/lib/skill-body-verify.sh [path]` (default: `.claude/skills/blake/SKILL.md`)
- Exit 0 if all markers found, exit 1 if any missing
- Print which markers are missing on failure
- Also check: safety keyword count `grep -cE 'MUST|MANDATORY|VIOLATION'` ≥ 77 (smoke alarm — ground truth is per-protocol presence)
- Also verify `.agents/skills/blake/SKILL.md` is identical to `.claude/` copy (`diff -q`)
- Also verify reference-ok files still exist (`test -f cross-model-invocation.md && test -f notebooklm-access.md`)

**False-negative test:** Copy file to /tmp, remove a marker from the copy, run script against the copy. Real file must never be touched during testing. See AC7 for exact procedure.

### Task 6: Add principle to principles.md

Add a new entry to `.tad/project-knowledge/principles.md`:

```markdown
### Execution Discipline Content Must Stay in SKILL Body — Circular Trigger Test - 2026-06-09
- **Context**: SKILL Progressive Loading (v2.26.0) extracted 36 protocols to references/. Codex dogfood: Blake skipped Layer 2, Gate 3, completion report. Phase 1 audit classified 3 must-body, 33 reference-ok.
- **Discovery**: Must-body content has "circular triggers" — the `load_when` references a step defined inside the reference itself. Without the reference, the agent doesn't know the step exists, so the trigger never fires. Non-circular triggers (explicit *command, workflow chain) work because the agent knows the triggering event independently.
- **Action**: Before extracting any protocol to references/, verify the `load_when` trigger is non-circular. If the trigger references a concept defined inside the reference, keep it in body. Automated check: `skill-body-verify.sh` runs at release time.
- ⚠️ SAFETY ENTRY — requires human review for any modification
- **Grounded in**: .tad/evidence/designs/skill-body-reference-audit.md, EPIC-20260609-skill-body-reference-boundary.md
```

---

## 5. Files to Modify/Create

| File | Action | Description |
|------|--------|-------------|
| `.claude/skills/blake/SKILL.md` | MODIFY | Inline 3 refs, remove 3 stubs (737 → ~2029 lines) |
| `.claude/skills/blake/references/completion-protocol.md` | DELETE | Fully inlined |
| `.claude/skills/blake/references/execution-checklist.md` | DELETE | Fully inlined |
| `.claude/skills/blake/references/ralph-loop.md` | DELETE | Fully inlined |
| `.agents/skills/blake/SKILL.md` | MODIFY | Mirror of .claude/ — cp after inline |
| `.agents/skills/blake/references/completion-protocol.md` | DELETE | Mirror cleanup |
| `.agents/skills/blake/references/execution-checklist.md` | DELETE | Mirror cleanup |
| `.agents/skills/blake/references/ralph-loop.md` | DELETE | Mirror cleanup |
| `.tad/hooks/lib/skill-body-verify.sh` | CREATE | Automated body integrity checker |
| `.tad/project-knowledge/principles.md` | MODIFY | New principle entry (14/15 cap — 1 slot remaining) |

**Grounded Against** (Alex step1c):
- .claude/skills/blake/SKILL.md (lines 300-520 checked, stubs confirmed at 305, 494, 517)
- .claude/skills/blake/references/*.md (line counts: 719, 240, 333 confirmed)
- .tad/project-knowledge/principles.md (13 entries, head 50 read)

---

## 6. Required Evidence Manifest

```yaml
evidence_manifest:
  expert_reviews:
    - .tad/evidence/reviews/phase2-inline-review-{expert}.md
  gate_verdicts:
    - Gate 3 Layer 1 + Layer 2 in completion report
  completion:
    - .tad/active/handoffs/COMPLETION-20260609-skill-body-inline.md
  blake_reviews: []
  perf_evidence: []
  fixture_results: []
  dogfood: []
  knowledge_updates:
    - .tad/project-knowledge/principles.md (new principle)
    - .tad/project-knowledge/patterns/handoff-design.md (if new patterns emerge)
```

---

## 7. Important Notes

### 7.1 Inline Strategy — Precise Replacement Rules

**Definition of "stub block":** The YAML key line + `reference:` child + `load_when:` child (and any `# Extracted for progressive loading` comment between them). Example for ralph-loop:
```
ralph_loop_execution:
  # Extracted for progressive loading — full protocol in the reference below.
  reference: ".claude/skills/blake/references/ralph-loop.md"
  load_when: "..."
```
→ Delete this entire block (key line + children).

**Reference file stripping:** Each reference file starts with 3-4 lines of extraction metadata:
```
# Ralph Loop (extracted from blake/SKILL.md for progressive loading)
# Source: .claude/skills/blake/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 3)
[blank line]
```
→ Strip these extraction header lines before inlining. They are metadata about the extraction event, not protocol content.

**Replacement:** After stripping extraction headers, the reference content starts with its own key declaration (e.g., `ralph_loop_execution:`). This key replaces the stub's key 1:1. Paste the stripped reference content where the stub block was.

**Preserve surrounding context:** Section banners/comments that existed BEFORE the stub (e.g., the `═══` decorative banner above execution-checklist) are body-local and must be preserved. Only replace the stub block itself.

**After inline, replicate to `.agents/`:** `cp .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md`

### 7.2 Safety Keyword Preservation
Before and after each inline, count `grep -cE 'MUST|MANDATORY|VIOLATION'` in Blake SKILL.md. The count must be monotonically non-decreasing (29 baseline → expected ~79 final).

**AC5 is a smoke alarm, not ground truth.** AC1-AC3 (per-protocol presence checks) are the ground truth for content preservation. AC5 catches gross loss. Per principles.md "A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss" — the floor is set to ≥77 (79 minus 2 tolerance for key-line deduplication during inline). If AC5 fails but AC1-AC3 all pass, investigate before blocking — it may be a legitimate dedup.

**Extraction headers contain no safety keywords** — stripping them (per §7.1) does not affect the count.

### 7.3 Don't Touch Alex
Alex SKILL.md and all Alex references are OUT OF SCOPE. Phase 1 confirmed they're all reference-ok.

### 7.4 Keep reference-ok Blake refs
`cross-model-invocation.md` and `notebooklm-access.md` stay in references/. Do not move, modify, or delete them.

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | Ralph Loop content in body | `grep -c 'ralph_loop\|Ralph Loop' .claude/skills/blake/SKILL.md` | ≥ 5 |
| AC2 | Execution checklist in body | `grep -c 'task_type_branching\|hard_requirement_distinct_reviewers' .claude/skills/blake/SKILL.md` | ≥ 2 |
| AC3 | Completion protocol in body | `grep -c 'gate3_verdict\|completion_report\|completion_protocol' .claude/skills/blake/SKILL.md` | ≥ 3 |
| AC4 | Inlined refs deleted | `ls .claude/skills/blake/references/` | exactly: cross-model-invocation.md, notebooklm-access.md |
| AC5 | Safety keywords preserved (smoke alarm) | `grep -cE 'MUST\|MANDATORY\|VIOLATION' .claude/skills/blake/SKILL.md` | ≥ 77 (ground truth = AC1-AC3) |
| AC6 | Checker script exists and passes | `bash .tad/hooks/lib/skill-body-verify.sh .claude/skills/blake/SKILL.md` | exit 0 |
| AC7 | Checker false-negative test | `cp SKILL.md /tmp/test.md && sed -i '' '/ralph_loop/d' /tmp/test.md && bash skill-body-verify.sh /tmp/test.md; echo $?` | exit 1 (test on copy, real file untouched) |
| AC7b | .agents/ mirror synced | `diff .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` | empty (identical) |
| AC7c | .agents/ refs deleted | `ls .agents/skills/blake/references/` | exactly: cross-model-invocation.md, notebooklm-access.md |
| AC8 | New principle in principles.md | `grep -c 'Circular Trigger' .tad/project-knowledge/principles.md` | = 1 |
| AC9 | Alex SKILL untouched | `git diff --name-only .claude/skills/alex/` | empty |
| AC10 | Reference-ok Blake refs untouched | `git diff --name-only .claude/skills/blake/references/cross-model-invocation.md .claude/skills/blake/references/notebooklm-access.md` | empty |
| AC11 | Body line count in expected range | `wc -l .claude/skills/blake/SKILL.md` | 1900-2200 |
| AC12 | Change scope | `git diff --stat` | only listed files changed |

**AC Dry-Run Log** (Alex step1d at 2026-06-09):
- AC1-AC3: ✅ post-impl-verifiable, syntax-validated
- AC4: ✅ post-impl-verifiable, syntax-validated
- AC5: ✅ pre-impl baseline: `grep -cE 'MUST|MANDATORY|VIOLATION' blake/SKILL.md` = 29. Post-inline target ≥ 79.
- AC6-AC7: ✅ post-impl-verifiable (script doesn't exist yet)
- AC8: ✅ post-impl-verifiable, syntax-validated
- AC9: ✅ pre-impl-verifiable: `git diff --name-only .claude/skills/alex/` = empty
- AC10: ✅ pre-impl-verifiable (files currently unchanged)
- AC11: ✅ post-impl-verifiable (current=737, projected=~2029)
- AC12: ✅ post-impl-verifiable

### 9.2 Expert Review Status

| Expert | Focus | Status | Findings |
|--------|-------|--------|----------|
| code-reviewer | Inline correctness, YAML structure, AC verifiability | ✅ Complete | 2 P0, 5 P1, 3 P2. CONDITIONAL PASS |
| backend-architect | .agents/ mirror, safety floor, checker integration | ✅ Complete | 2 P0, 5 P1, 4 P2. CONDITIONAL PASS |

### 9.3 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| CR | P0-1: YAML key collision + extraction header ambiguity | §7.1: precise replacement rules (strip headers, key 1:1 replace) | Resolved |
| CR | P0-2: Safety floor = exact sum, zero margin | §7.2 + AC5: floor lowered to ≥77, AC1-AC3 as ground truth | Resolved |
| Arch | P0-1: .agents/skills/blake/ mirror completely ignored | §1.3 warning + §5 table + AC7b/AC7c added | Resolved |
| Arch | P0-2: Header handling ambiguity (same root as CR-P0-1) | §7.1: explicit strip instruction | Resolved |
| CR | P1-2: Checker should accept path arg | Task 5 spec updated | Resolved |
| CR | P1-3: AC7 false-negative test risks real file | AC7: uses /tmp copy, real file untouched | Resolved |
| CR | P1-4: Stub boundaries imprecise | §7.1: exact definition of "stub block" | Resolved |
| CR | P1-5: Decorative banner above exec-checklist | §7.1: "preserve surrounding context" rule | Resolved |
| Arch | P1-1: Checker should also verify .agents/ | Task 5: added diff -q check | Resolved |
| Arch | P1-3: Checker integration point undefined | Deferred to Phase 3 (release-verify integration) | Open |
| Arch | P1-4: principles.md at 14/15 cap | §5 table: noted "(14/15 cap — 1 slot remaining)" | Resolved |
| Arch | P2-4: Checker should verify ref-ok files exist | Task 5: added test -f for 2 ref-ok files | Resolved |

---

## 10. Decision Summary

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| D1 | Inline scope | Only 3 Blake refs | Phase 1 audit: circular trigger test |
| D2 | Alex SKILL | No changes | Phase 1: all 31 Alex refs reference-ok |
| D3 | Checker keywords | 6 structural markers + count floor | Covers all 3 inlined protocols |
| D4 | Safety count floor | ≥ 79 | Current body 29 + 3 refs total 50 |

---

## 11. Micro-Tasks

| # | Task | Est. Time | Files |
|---|------|-----------|-------|
| M1 | Inline ralph-loop.md (719 lines) | 10 min | blake/SKILL.md |
| M2 | Inline execution-checklist.md (240 lines) | 5 min | blake/SKILL.md |
| M3 | Inline completion-protocol.md (333 lines) | 5 min | blake/SKILL.md |
| M4 | Delete 3 reference files | 2 min | blake/references/ |
| M5 | Verify safety keyword count ≥ 79 | 2 min | — |
| M6 | Create skill-body-verify.sh | 10 min | hooks/lib/ |
| M7 | False-negative test the checker | 5 min | — |
| M8 | Add principle to principles.md | 5 min | project-knowledge/ |
| M9 | Self-review + Layer 2 | 15 min | — |
