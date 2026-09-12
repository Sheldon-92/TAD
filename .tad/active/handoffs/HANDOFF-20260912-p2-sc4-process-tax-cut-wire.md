---
task_id: TASK-20260912-P2-SC4-TAX-CUT-WIRE
task_type: doc-only
express: true
skip_knowledge_assessment: yes
e2e_required: no
research_required: no
status: READY_FOR_BLAKE
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-20260912-p2-sc4-process-tax-cut-wire

**Task ID**: `TASK-20260912-P2-SC4-TAX-CUT-WIRE`  
**From:** Alex (Terminal 1) **To:** Blake (Terminal 2)  
**Created**: 2026-09-12  
**Status**: READY_FOR_BLAKE (dual Gate 2 PASS on disk, P0=0; human already full-authorized this close-out)  
**Epic:** `EPIC-20260912-p2-process-tax-cut.md` Phase 2 / SC4  
**Mode**: docs-only. Alex already landed the thin edits. Blake = **pathspec-only commit**. No push/tag/bump/release.  
**Design pointer** (gitignored-local): `.tad/evidence/designs/2026-09-12-p2-sc4-process-tax-cut-wire.md`  
**Channel**: Cursor / cursor-grok-4.6-medium. NO Gemini. NO Blake on the Alex turn.

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-12 (Alex land + dual review protocol)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | No new runtime. Pointers on existing load surfaces. SSOT remains `docs/process-tax-cut.md`. |
| Components Specified | ✅ | §7 pathspec; hunk rules for mixed `_index` / `ac-verification.md` |
| Functions Verified | ✅ | No code functions. Load path = `_index` + templates Alex/Blake already Read. |
| Data Flow Mapped | ✅ | Human does not hand `docs/process-tax-cut.md`; agents match `_index` / template Gate 2 / §9 / Layer 2 format. |

**Process Gate 2 = dual reviews on disk.** Do **not** wait for a human to type `/gate 2`. Human still says `当 Blake` for role switch.

**Alex确认**: thin docs landed this turn; Blake does not redesign; commit only §7.

---

## MQ (inherited — human 2026-09-12 full-authorize)

1. **User**: TAD PM / Alex+Blake sessions (not end-user product).  
2. **Problem**: checklists exist but do not load unless the path is handed → vacuous AC rounds, dirty-tree false P0, wait-for-`/gate 2` wording.  
3. **Scope**: templates + `_index` + pattern + verification guide + related templates; residual wait-phrasing in **templates only**.  
4. **Out**: GM P0/P1, KEEP11, publish, SKILL/hooks, L1 principles, wholesale historical handoffs.  
5. **Success**: agents can see the three checklists from loaded surfaces; residual forbidden wait-phrases absent from templates.  
6. **Teeth**: dual Gate 2 reviews; Alex ≠ Blake.

Gate 1 (quick): problem / ICP / scope / verifiable ACs — PASS via Epic SC4 + this §9.1.

---

## 1. Task Overview

Alex already wrote the files. Blake **commits** them with strict pathspec (and hunk-stage on mixed knowledge files). Do not re-edit unless Gate 2 P0 requires it.

### 1.3 Intent

**Solve**: load AC realism / Layer2 dirty-tree adjudicate / Gate2-disk-only without a handed path.  
**Not**: cut dual review; not merge Alex/Blake; not publish v2.44.5.

---

## 📚 Project Knowledge

- `patterns/process-tax-cut.md` (this knife)  
- `patterns/ac-verification.md` (AC realism pointer)  
- `principles.md` Two-Agent + Four-Gate (teeth)

---

## 3. Requirements

- FR1: `_index.md` routes `Process Tax Cut` → `process-tax-cut.md` with AC realism / dirty-tree / Gate2-disk keywords.  
- FR2: Pattern file exists; SSOT pointer to `docs/process-tax-cut.md`; three paste blocks present.  
- FR3: Universal handoff template Gate 2 + §9.1/§9.2 carry the disk-only + AC-realism notes.  
- FR4: Acceptance-verification-guide + spec-compliance-format carry AC realism / dirty-tree adjudicate.  
- FR5: Templates (not archive handoffs) contain no dispatch lock `blocked until user runs /gate 2` or `READY_FOR_BLAKE only after human Gate 2 command`.  
- FR6: Epic SC4 + phase map updated.  
- FR7: Commit is pathspec-only; mixed-ticket hunks in `ac-verification.md` (2026-09-10 entries) stay **unstaged**.

---

## 5. Implementation Steps (Blake)

1. Confirm `git status` vs §7. Do not `git add -A`.  
2. Hunk-stage `.tad/project-knowledge/patterns/_index.md` using a **filtered patch + `git apply --cached`** (this harness cannot `git add -p` / `-i`): **only** the AC Verification suffix `, AC realism, vacuous AC` and the new `Process Tax Cut` bullet.  
3. Same method for `.tad/project-knowledge/patterns/ac-verification.md`: **only** the `### Process tax-cut: AC realism — 2026-09-12` entry (the two 2026-09-10 entries are **prior dirt** — leave unstaged).  
4. `git add --` the remaining §7.2 whole files (they are this-knife-only).  
5. `git add --` new `patterns/process-tax-cut.md` and this handoff.  
6. Commit. Prove `git diff-tree --name-only -r HEAD` ⊆ §7.  
7. Completion report. No push.

---

## 7. Files

### 7.1 Create

| Path | Notes |
|------|--------|
| `.tad/project-knowledge/patterns/process-tax-cut.md` | Layer-2 route + three paste blocks |
| `.tad/active/handoffs/HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md` | this file |
| `.tad/evidence/designs/2026-09-12-p2-sc4-process-tax-cut-wire.md` | gitignored-local; do **not** force into commit |

### 7.2 Modify (commit set)

1. `docs/process-tax-cut.md`  
2. `.tad/active/epics/EPIC-20260912-p2-process-tax-cut.md`  
3. `.tad/project-knowledge/patterns/_index.md` *(hunk)*  
4. `.tad/project-knowledge/patterns/ac-verification.md` *(hunk)*  
5. `.tad/templates/handoff-a-to-b.md`  
6. `.tad/templates/acceptance-verification-guide.md`  
7. `.tad/templates/output-formats/spec-compliance-format.md`  
8. `.tad/templates/output-formats/git-workflow-format.md`  
9. `.tad/templates/release-handoff.md`  
10. `.tad/tasks/handoff-creation.md`  
11. `.tad/project-knowledge/patterns/process-tax-cut.md`  
12. `.tad/active/handoffs/HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md`

### 7.3 Out of commit (dirty riders)

`NEXT.md`, `PROJECT_CONTEXT.md`, `docs/pm/now.md`, `.tad/brain-index.md`, publish v2.44.5 handoff, leftover twins, KEEP11, `.tad/eval/judge/bundles/*`, 2026-09-10 `ac-verification.md` entries, `session-state.md`.

---

## 9. Acceptance Criteria

Blake commit is done iff §9.1 landing rows PASS and `git diff-tree` ⊆ §7.

## 9.1 Spec Compliance Checklist

> Landing Methods are backtick commands or path-checks. Prose-only = FAIL.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | `_index` routes Process Tax Cut | pre-impl-verifiable | `grep -F -- '- [Process Tax Cut](process-tax-cut.md)' .tad/project-knowledge/patterns/_index.md` | exit 0, exactly that bullet | HIT: `- [Process Tax Cut](process-tax-cut.md) — AC realism; …`; exit 0 |
| 2 | `_index` AC Verification hook names AC realism | pre-impl-verifiable | `grep -F -- 'AC realism, vacuous AC' .tad/project-knowledge/patterns/_index.md` | exit 0 | HIT on AC Verification bullet; exit 0 |
| 3 | Pattern file SSOT + three headings | pre-impl-verifiable | `test -f .tad/project-knowledge/patterns/process-tax-cut.md && grep -cE '^(## 1\) AC realism|## 2\) Layer 2 dirty-tree|## 3\) Gate 2 = disk dual review)' .tad/project-knowledge/patterns/process-tax-cut.md` | file exists; count == 3 | `3` |
| 4 | Pattern cites docs SSOT | pre-impl-verifiable | `grep -F -- 'docs/process-tax-cut.md' .tad/project-knowledge/patterns/process-tax-cut.md` | ≥1 | HIT SSOT line + Pointers; exit 0 |
| 5 | Handoff template Gate 2 is disk-only | pre-impl-verifiable | `awk '/^## 🔴 Gate 2: Design Completeness/{p=1} p&&/^## 📋 Handoff Checklist/{exit} p' .tad/templates/handoff-a-to-b.md \| grep -F -- 'Process Gate 2 = dual reviews on disk'` | match in Gate 2 section only | HIT quoted Process Gate 2 sentence; exit 0 |
| 6 | Handoff template §9.1 has AC realism note | pre-impl-verifiable | `awk '/^## 9.1 Spec Compliance Checklist/{p=1} p&&/^## 9.2 /{exit} p' .tad/templates/handoff-a-to-b.md \| grep -F -- 'AC realism'` | match in §9.1 | HIT `**AC realism** (P2 tax-cut…`; exit 0 |
| 7 | Acceptance guide carries AC realism | pre-impl-verifiable | `grep -F -- 'AC realism' .tad/templates/acceptance-verification-guide.md` | ≥1 | HIT; exit 0 |
| 8 | Spec-compliance format has dirty-tree adjudicate | pre-impl-verifiable | `grep -F -- 'Layer 2 dirty-tree adjudicate' .tad/templates/output-formats/spec-compliance-format.md` | ≥1 | HIT heading; exit 0 |
| 9 | Residual forbidden dispatch phrases absent from templates/tasks | pre-impl-verifiable | `grep -RInE -- 'blocked until user runs /gate 2\|READY_FOR_BLAKE only after human Gate 2 command' .tad/templates .tad/tasks; echo EXIT:$?` | no content matches (grep exit 1); EXIT:1. Ban *examples* may live in `docs/process-tax-cut.md` / `patterns/process-tax-cut.md` only — not in templates as dispatch text. | no hits; EXIT:1 (after removing self-leak of those exact strings from `handoff-a-to-b.md`) |
| 10 | Guide Pointers lists wired surfaces | pre-impl-verifiable | `grep -F -- 'Agent-loaded route' docs/process-tax-cut.md` | ≥1 | HIT Pointers bullet; exit 0 |
| 11 | Epic SC4 checked | pre-impl-verifiable | `grep -F -- '- [x] **SC4**' .tad/active/epics/EPIC-20260912-p2-process-tax-cut.md` | ≥1 | HIT; exit 0 |
| 12 | Commit names ⊆ §7.2+7.1 tracked (post-impl) | post-impl-verifiable | `git diff-tree --no-commit-id --name-only -r HEAD` | only paths listed in §7.1/7.2 except gitignored design | (post-impl) |
| 13 | `ac-verification.md` commit does not add 2026-09-10 entries | post-impl-verifiable | `git show HEAD -- .tad/project-knowledge/patterns/ac-verification.md \| grep -cE -- 'Gitignored fixtures can PASS Gate 4\|Pathspec-in-scope files can still carry a foreign hunk'` | 0 | (post-impl) |

### Verification Method grammar

LEGAL: command in backticks | path-check | fixture | rubric-spawn | light N/A.  
ILLEGAL: prose-only.

**AC realism applied**: post-impl 12–13 fail on unmodified HEAD (no this-knife commit) for the right reason. Pre-impl 1–11 must PASS on the landed WT now.

## 9.2 Expert Review Status

> Dual files on disk = process Gate 2. Not a human `/gate 2` lock.

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| Spec & Pathspec | P0 none | `.tad/evidence/reviews/2026-09-12-gate2-review-p2-sc4-spec.md` | Resolved |
| Spec & Pathspec | P2-1 AC13 one token | §9.1 AC13 now greps both 2026-09-10 titles | Resolved |
| Spec & Pathspec | P2-2 hunk HOW unnamed | §5 step 2–3: `git apply --cached`, no `add -p` | Resolved |
| Load-surface | P0 none; P2 condensed vs full paste | Expected thin-wire; full blocks on pattern file | Deferred (by design) |

### Experts Selected

1. **Gate 2 Reviewer A — Spec & pathspec** — `.tad/evidence/reviews/2026-09-12-gate2-review-p2-sc4-spec.md` — PASS, P0=0  
2. **Gate 2 Reviewer B — Load-surface completeness** — `.tad/evidence/reviews/2026-09-12-gate2-review-p2-sc4-load.md` — PASS, P0=0

### Overall Assessment (post-integration)

- Spec & pathspec: PASS (0 P0, 0 P1, 2 P2 integrated)
- Load-surface: PASS (0 P0, 0 P1, 1 P2 deferred by design)

**Gate 2 结果**: ✅ PASS (dual disk, P0=0)

---

## 10. Notes

- Teeth: dual review; Alex ≠ Blake; Layer 2 still required.  
- Do not absorb v2.44.5.  
- Design file is gitignored; Gate 4 must not treat local design as commit proof.

---

**Handoff Created By**: Alex (Agent A)  
**Date**: 2026-09-12  
**Version**: 3.1.0
