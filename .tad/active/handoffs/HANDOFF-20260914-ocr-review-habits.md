---
task_id: TASK-20260914-OCR-REVIEW-HABITS
task_type: doc-only
express: false
skip_knowledge_assessment: yes
e2e_required: no
research_required: no
status: READY_FOR_BLAKE
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-20260914-ocr-review-habits

**Task ID**: `TASK-20260914-OCR-REVIEW-HABITS`  
**From:** Alex (Terminal 1) **To:** Blake (Terminal 2)  
**Created**: 2026-09-14  
**Status**: READY_FOR_BLAKE (Gate 2 dual PASS on disk; **no Blake this session**)  
**Epic:** N/A  
**Mode**: docs-only. Blake pastes the design fence into three files. No push/tag/bump/release.  
**Design pointer**: `.tad/evidence/designs/2026-09-14-ocr-review-habits.md`  
**Channel**: Cursor / cursor-grok-4.6-medium. NO Gemini. Alex ≠ Blake. Dual Gate 2 stays. Do not absorb v2.44.5.

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-14 (Alex design + dual disk reviews; P1 closed same session)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | No runtime. Optional paste §4 on tax-cut SSOT + pattern duplicate + install-visible Layer 2 format. |
| Components Specified | ✅ | §6.2 pathspec; exact fence in the design pointer. |
| Functions Verified | ✅ | N/A (no code functions). MQ2 not triggered. |
| Data Flow Mapped | ✅ | N/A (docs SSOT). Downstream sees template copy; this-repo agents see docs + pattern. |

**Process Gate 2 = dual reviews on disk.** Do **not** wait for a human to type `/gate 2`. Human still says `当 Blake` for role switch. This session **stops** after Gate 2 PASS; do not implement.

**Alex确认**: Blake implements the paste; does not redesign; does not touch gates, tad.sh, packs, or role SKILLs.

---

## MQ (human lock 2026-09-14)

1. **User**: TAD maintainers + **downstream projects after `tad.sh` install/run** (Alex/Blake Layer 2), not Alibaba OCR users.  
2. **Problem**: When [scene: Layer 2 / Gate 2 review] ICP needs the five OCR honesty habits (falsify-only second look, precision default, pathspec dispatch, localizable claims, recall-up opt-in), but they live only in a PARTIAL research note — other installs never see them.  
3. **Scope**: Optional paste K1–K5 into `docs/process-tax-cut.md` §4 (SSOT) + pattern sibling + `spec-compliance-format.md` (install-visible).  
4. **Out**: OCR CLI/npm; `rule.json` / language-md SSOT; replacing Gate 2/3/Layer 2; AACR-Bench as TAD KPI; new Gates; Alibaba tooling; `tad.sh` copy-set change; L1 principles; packs; role SKILL bodies; v2.44.5.  
5. **Success**: Install-copied Layer 2 format and tax-cut paste homes contain the same K1–K5 fence; teeth lines unchanged.  
6. **Teeth**: dual Gate 2 on disk; Alex ≠ Blake; no new Gate.

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS (this §9.1 + lock).

**Socratic**: human answered KEEP/REJECT + paste home in-query. Process depth treated as **Light** (docs-only 3 files, skill-authoring analog). Remaining design choice (docs vs install-visible) resolved from parenthetical “or nearest existing install-visible guide” + measured fact that `tad.sh` does not copy `docs/` and `project-knowledge` is zero-touch.

### MQ evidence

| MQ | Triggered? | Evidence |
|----|------------|----------|
| MQ1 historical | yes | Reuse tax-cut paste sections + spec-compliance-format (already cites §2). Searched `docs/process-tax-cut.md`, `patterns/process-tax-cut.md`, templates, tad.sh `copy_framework_files`. Do not import `alibaba/open-code-review`. |
| MQ2 functions | no | Docs-only; no function calls. |
| MQ3 data flow | no | No backend/frontend fields. |
| MQ4 visual | no | No UI states. |
| MQ5 state sync | no | Docs SSOT; pattern + template must match fence bytes. |
| MQ6 research | yes | `.tad/evidence/research/2026-09-14-alibaba-open-code-review.md` PARTIAL. Options: paste-only / CLI / new Gate. Human = paste-only KEEP K1–K5. |

---

## 1. Task Overview

### 1.1 What We're Building

A **docs-only** knife: name five optional Layer 2 review habits (K1–K5) on the tax-cut paste guide, the agent-loaded pattern duplicate, and the install-copied spec-compliance format.

### 1.2 Why

Other projects never load this repo’s `docs/` or zero-touch `project-knowledge`. Putting the fence on `.tad/templates/output-formats/spec-compliance-format.md` is how install/run actually ships the habits. Docs remain SSOT for this tree.

### 1.3 Intent Statement

**Solve**: K1–K5 unpublished except in a research note.  
**Not**: import OCR CLI; cut Gate 2 dual; merge Alex/Blake; add Ultra Gate; make AACR-Bench a TAD KPI.

**Blake请确认理解** (own words before edit): paste-from-design into three files; no runtime; no gate rewrite.

---

## 📚 Project Knowledge

**Loaded this knife:** `principles.md`; `patterns/_index.md` → `process-tax-cut.md`, `ac-verification.md`, `gate-design.md` (max 3 + L1).

### Research Findings

Topic: alibaba/open-code-review thin borrow | Note: `.tad/evidence/research/2026-09-14-alibaba-open-code-review.md` §4–§5  
Local Wiki: no prior canon (ingest degraded). NotebookLM unused.

Key carriers: K1 falsify-only / less-context / filter-only / fail-open; K2 precision-over-recall; K3 pathspec dispatch; K4 localizable or unanchored; K5 recall-up = existing security-auditor trigger. REJECT list §4.

### ⚠️ Blake 必须注意的历史教训

1. **Two-Agent System** (`principles.md`) — K1 must not collapse Alex≠Blake into same-model reflection.  
2. **Four-Gate Quality System** (`principles.md`) — do not add a Gate; optional paste only.  
3. **Never Hand-Write What an Existing Tool Already Does** (`principles.md`) — XSS/SQLi stay scanner-first; do not paste OCR language-md as SSOT.  
4. **Mechanical Enforcement Rejected on Single-User CLI** (`principles.md`) — habits are paste, not a hook.  
5. **Judgment-Only Skill Files** (`principles.md`) — do not slim MUST out of SKILL bodies while adding docs cache.  
6. **Knowledge Is Forged at Distill, Not Captured** (`principles.md`) — this knife is paste, not a new L1 principle.  
7. **Process tax-cut: AC realism** (`ac-verification.md`) — post-impl rows must fail on unmodified HEAD for the right reason.  
8. **Process Tax Cut** (`patterns/process-tax-cut.md`) — three existing pastes stay; this is a fourth **optional** block, not a skip-review checklist.  
9. **Gate Responsibility Matrix** (`gate-design.md`) — Layer 2 stays Blake’s; do not replace with OCR reflector.  
10. **Expert Review Blind Spots** (`gate-design.md`) — dual independent files stay.  
11. **Deny-List Beats Allow-List… AMENDED** (`principles.md`) — do **not** widen `tad.sh` copy-set to sneak `docs/` into install; use existing templates granularity.  
12. **Knowledge seam isolation** (PROJECT_CONTEXT / 2026-09-08) — do not write framework habits only into zero-touch `project-knowledge` and call that “ships with install.”

Stale-check: not run this session (shell friction); continue without staleness data.

Pack pointers (not loaded): `code-security` (scanner-first; do not escalate). `ai-agent-architecture`, `ai-evaluation` — keyword-adjacent; do not escalate.

---

## 2. Background

Existing: `docs/process-tax-cut.md` §§1–3 paste; pattern duplicates; templates point at docs but **docs are not installed**. Research 2026-09-14 ranked K1–K5 KEEP. v2.44.5 publish handoff is a **separate** in-flight knife — out of this pathspec.

---

## 3. Requirements

- FR1: `docs/process-tax-cut.md` gains `## 4) Optional Layer 2 review habits (OCR thin borrow)` containing the design fence (K1–K5).  
- FR2: `patterns/process-tax-cut.md` gains matching `## 4)` + the **same fence bytes**.  
- FR3: `spec-compliance-format.md` gains the same fence plus one SSOT sentence pointing at docs §4.  
- FR4: Existing §§1–3 fences and Teeth line `Alex ≠ Blake stays` unchanged.  
- FR5: New section states optional / not a Gate; forbidden line includes OCR CLI/npm, replacing Gate 2/3/Layer 2, AACR-Bench as a TAD KPI.  
- FR6: No edits to `tad.sh`, `principles.md`, alex/blake SKILL, `capability-packs/**`, `gate-canonical-checklist.md`.  
- FR7: Commit ⊆ **§6.2**.

---

## 4. Technical Design

Paste-only. Design file is the spec. Append §4; do not reorder older tax-cut sections.

**Conflict matrix**: no byte-preservation × perf × behavioral triple. Optional paste vs “do not add gates” resolved by Status line in the fence.

---

## 5. Implementation Steps (Blake)

1. `git status` vs §7. Do not `git add -A`.  
2. Insert design `## 4)` + fence into `docs/process-tax-cut.md` (after §3, before “What this does **not** change”). Add one bullet under that heading: optional K1–K5 paste is not a new Gate. Update the guide header “paste the three blocks” → “paste the blocks” (do not invent a skip-review checklist — that ban stays).  
3. Insert matching `## 4)` + **identical fence** into `.tad/project-knowledge/patterns/process-tax-cut.md`. Update the pattern header “three paste blocks” → “paste blocks”.  
4. After the dirty-tree section in `.tad/templates/output-formats/spec-compliance-format.md`, append exactly: `SSOT: docs/process-tax-cut.md §4; if drift, docs win.` then the **identical fence**. Do **not** paste K1 into Gate 2 spawn prompts as a “do not mint findings” dual-review replacement — K1 is Layer 2 only.  
5. `git add --` the three files + this handoff. Do not add design unless already tracked.  
6. Commit with subject containing `TASK-20260914-OCR-REVIEW-HABITS`. Prove `git diff-tree --name-only -r HEAD` ⊆ **§6.2**.  
7. Completion report. No push.

---

## 6. Files / Grounding

### 6.1 Create

| Path | Notes |
|------|--------|
| `.tad/active/handoffs/HANDOFF-20260914-ocr-review-habits.md` | this file |
| `.tad/evidence/designs/2026-09-14-ocr-review-habits.md` | design pointer; do not force into commit if gitignored |

### 6.2 Modify (commit set)

1. `docs/process-tax-cut.md`  
2. `.tad/project-knowledge/patterns/process-tax-cut.md`  
3. `.tad/templates/output-formats/spec-compliance-format.md`  
4. `.tad/active/handoffs/HANDOFF-20260914-ocr-review-habits.md`

### 6.3 Out of commit

`NEXT.md`, `PROJECT_CONTEXT.md`, `docs/pm/now.md`, `.tad/brain-index.md`, session-state, v2.44.5 handoff, leftover twins, judge bundles, `tad.sh`, `principles.md`, capability-packs, alex/blake SKILL, `gate-canonical-checklist.md`, `_index.md`.

**Grounded Against** (Alex step1c 2026-09-14):

- `docs/process-tax-cut.md` (full; §§1–3 + Pointers; no §4 yet)  
- `.tad/project-knowledge/patterns/process-tax-cut.md` (full; duplicates §1–3; SSOT sentence)  
- `.tad/templates/output-formats/spec-compliance-format.md` (head 50 + dirty-tree §)  
- `tad.sh` `copy_framework_files` (grep: copies `.tad/` + skills; no `docs/`)  
- `.tad/hooks/lib/derive-sync-set.sh` ZERO_TOUCH includes `project-knowledge`  
- design pointer (new — Alex created this turn; Blake does not redesign)

LSP/graph: skipped (`task_type: doc-only`).

---

## 7. Required Evidence Manifest (Phase 3 Anchor A-02)

```yaml
required_evidence_manifest:
  handoff_id: "HANDOFF-20260914-ocr-review-habits"
  evidence_files:
    - path: ".tad/evidence/reviews/2026-09-14-gate2-review-ocr-review-habits-spec.md"
      description: "Gate 2 Reviewer A — spec/pathspec/AC realism"
    - path: ".tad/evidence/reviews/2026-09-14-gate2-review-ocr-review-habits-scope.md"
      description: "Gate 2 Reviewer B — scope/teeth/non-import"
    - path: ".tad/active/handoffs/COMPLETION-20260914-ocr-review-habits.md"
      description: "Blake completion after pathspec commit (later session)"
```

---

## 8. Friction / notes

### 8.4 Friction Preflight

None for Blake. Docs-only; `grep`/`python3`/`git` present. No new deps. Reviewers spawn as Task. No auth.

This Alex session: activation `Shell` health scans were harness-rejected; health is **DEGRADED_WITH_APPROVAL** for scan completeness only — not a skip of Gate 2 dual files.

### 8.5 feedback_required: false

---

## 9. Acceptance Criteria

Blake is done iff landing §9.1 rows PASS and `git diff-tree` ⊆ **§6.2**.

### AC realism (copy)

- Every landing AC has exactly one legal Verification Method: command | path-check | fixture | rubric-spawn | light-tier N/A+one-line reason.  
- Dry-run on live baseline before Gate 2 lock. Post-impl rows must fail **for the right reason** on unmodified tree.  
- Known-GOOD must PASS; known-BAD must FAIL.

### Exact paste (copy — same as design)

```
### Optional Layer 2 review habits (OCR thin borrow, copy)

Status: optional paste. Not a Gate. Not a substitute for Gate 2 dual disk reviews or Alex ≠ Blake.

- K1 Asymmetric-bound, falsify-only second pass. A later look at the same delta sees less evidence (diff + claimed findings only). Veto only when the diff directly contradicts the claim. Do not mint new findings on this pass. Parse/format failure → fail-open (keep the finding).
- K2 Precision over recall as Layer 2 default. Prefer fewer P0/P1 with replayable evidence (path + command/hunk). Comment volume is not quality. Do not lower recall on security-auditor when that Group 2 trigger fired (see K5).
- K3 Dispatch is the pathspec, not agent whim. Review handoff §7 / allowed files only. Do not expand the file set like a free agent. Do not add a rule.json or language-md rule engine.
- K4 Claims must be localizable or labeled unanchored. Every finding cites path + command/hunk, or is labeled unanchored / extra-file. Do not treat model line numbers as SSOT.
- K5 Recall-up is opt-in for high-risk deltas. Extra budget is the existing security-auditor Group 2 trigger — not a named Ultra Gate and not an extra Ralph round by default.

Forbidden in this paste: OCR CLI or npm; replacing Gate 2 / Gate 3 / Layer 2; AACR-Bench as a TAD KPI; Alibaba language rule packs as SSOT.
```

## 9.1 Spec Compliance Checklist

> Landing Methods are backtick commands or path-checks. Prose-only = FAIL.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | Tax-cut guide exists | pre-impl-verifiable | `test -f docs/process-tax-cut.md` | exit 0 | exit 0 |
| 2 | Tax-cut pattern exists | pre-impl-verifiable | `test -f .tad/project-knowledge/patterns/process-tax-cut.md` | exit 0 | exit 0 |
| 3 | Spec-compliance format exists | pre-impl-verifiable | `test -f .tad/templates/output-formats/spec-compliance-format.md` | exit 0 | exit 0 |
| 4 | Tax-cut teeth still on disk (guide) | pre-impl-verifiable | `grep -F -- 'Alex ≠ Blake stays' docs/process-tax-cut.md` | exit 0 | HIT Teeth line; exit 0 |
| 5 | Tax-cut teeth still on disk (pattern) | pre-impl-verifiable | `grep -F -- 'Alex ≠ Blake stays' .tad/project-knowledge/patterns/process-tax-cut.md` | exit 0 | HIT Teeth line; exit 0 |
| 6 | Installer still does not name `docs/process-tax-cut` | pre-impl-verifiable | `grep -F -- 'docs/process-tax-cut' tad.sh; echo EXIT:$?` | no content matches (grep exit 1); EXIT:1 | grep exit 1; EXIT:1 |
| 7 | Guide §4 heading present | post-impl-verifiable | `grep -F -- '## 4) Optional Layer 2 review habits (OCR thin borrow)' docs/process-tax-cut.md` | exit 0 | (post-impl — baseline: heading_absent, grep exit 1) |
| 8 | Guide fence has K1–K5 tokens | post-impl-verifiable | `python3 -c "from pathlib import Path; t=Path('docs/process-tax-cut.md').read_text(); i=t.find('## 4) Optional Layer 2 review habits (OCR thin borrow)'); s=t[i:] if i>=0 else ''; need=['falsify-only','Precision over recall','Dispatch is the pathspec','unanchored / extra-file','Recall-up is opt-in','Not a Gate','AACR-Bench as a TAD KPI']; print(sum(x in s for x in need)); raise SystemExit(0 if i>=0 and all(x in s for x in need) else 1)"` | exit 0; printed 7 | (post-impl — baseline printed 0, exit 1) |
| 9 | Pattern §4 same K tokens | post-impl-verifiable | `python3 -c "from pathlib import Path; t=Path('.tad/project-knowledge/patterns/process-tax-cut.md').read_text(); i=t.find('## 4) Optional Layer 2 review habits (OCR thin borrow)'); s=t[i:] if i>=0 else ''; need=['falsify-only','Precision over recall','Dispatch is the pathspec','unanchored / extra-file','Recall-up is opt-in','Not a Gate','AACR-Bench as a TAD KPI']; print(sum(x in s for x in need)); raise SystemExit(0 if i>=0 and all(x in s for x in need) else 1)"` | exit 0; printed 7 | (post-impl — baseline exit 1) |
| 10 | Template fence + unique SSOT sentence | post-impl-verifiable | `python3 -c "from pathlib import Path; t=Path('.tad/templates/output-formats/spec-compliance-format.md').read_text(); need=['### Optional Layer 2 review habits (OCR thin borrow, copy)','falsify-only','Precision over recall','Dispatch is the pathspec','unanchored / extra-file','Recall-up is opt-in','AACR-Bench as a TAD KPI','if drift, docs win']; print(sum(x in t for x in need)); raise SystemExit(0 if all(x in t for x in need) else 1)"` | exit 0; printed 8 | (post-impl — baseline missing heading/SSOT, exit 1) |
| 11 | This-knife commit names required ⊆ names ⊆ §6.2 | post-impl-verifiable | `python3 -c "import subprocess; allowed={'docs/process-tax-cut.md','.tad/project-knowledge/patterns/process-tax-cut.md','.tad/templates/output-formats/spec-compliance-format.md','.tad/active/handoffs/HANDOFF-20260914-ocr-review-habits.md'}; required={'docs/process-tax-cut.md','.tad/project-knowledge/patterns/process-tax-cut.md','.tad/templates/output-formats/spec-compliance-format.md'}; names=set(l for l in subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'], text=True).splitlines() if l); subj=subprocess.check_output(['git','log','-1','--format=%s'], text=True); ok_id='OCR-REVIEW-HABITS' in subj; ok=ok_id and required<=names<=allowed; print('SUBJ='+subj.strip()); print('\\n'.join(sorted(names))); raise SystemExit(0 if ok else 1)"` | exit 0; SUBJ contains OCR-REVIEW-HABITS; required ⊆ names ⊆ §6.2 | (post-impl — live HEAD: ok_id false → exit 1 — right fail: not this knife) |
| 12 | This-knife commit has no forbidden classes | post-impl-verifiable | `python3 -c "import subprocess; names=[l for l in subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'], text=True).splitlines() if l]; subj=subprocess.check_output(['git','log','-1','--format=%s'], text=True); ok_id='OCR-REVIEW-HABITS' in subj; bad=('capability-packs/','principles.md','tad.sh','/alex/SKILL.md','/blake/SKILL.md','gate-canonical-checklist.md'); hits=[l for l in names if any(b in l for b in bad)]; print('SUBJ='+subj.strip()); print('HITS='+repr(hits)); raise SystemExit(0 if ok_id and not hits else 1)"` | exit 0; ok_id true; HITS=[] | (post-impl — live HEAD: ok_id false → exit 1 — right fail) |
| 13 | Three files share identical fence body | post-impl-verifiable | `python3 -c "from pathlib import Path\n\ndef fence(p, marker):\n    t=Path(p).read_text(); i=t.find(marker)\n    if i<0: raise SystemExit(1)\n    rest=t[i:]; a=rest.find('```\\n'); b=rest.find('\\n```', a+4)\n    if a<0 or b<0: raise SystemExit(1)\n    return rest[a+4:b]\nm='### Optional Layer 2 review habits (OCR thin borrow, copy)'\na=fence('docs/process-tax-cut.md', m); b=fence('.tad/project-knowledge/patterns/process-tax-cut.md', m); c=fence('.tad/templates/output-formats/spec-compliance-format.md', m); print(len(a)); raise SystemExit(0 if a==b==c and 'falsify-only' in a else 1)"` | exit 0; printed fence byte length >0 | (post-impl — baseline marker absent, exit 1) |

### Verification Method grammar

LEGAL: command in backticks | path-check | fixture | rubric-spawn | light N/A.  
ILLEGAL: prose-only.

**AC realism applied**: 7–13 fail on unmodified HEAD (missing §4 / this-knife commit) for the right reason. 1–6 must PASS on live baseline now.

## AC Dry-Run Log (Alex step1d 2026-09-14 04:10 UTC)

- AC1: pre-impl, `test -f docs/process-tax-cut.md`, exit 0  
- AC2: pre-impl, pattern exists, exit 0  
- AC3: pre-impl, spec-compliance-format exists, exit 0  
- AC4: pre-impl, guide Teeth HIT; exit 0  
- AC5: pre-impl, pattern Teeth HIT; exit 0  
- AC6: pre-impl, `grep -F docs/process-tax-cut tad.sh` = no hits, grep exit 1 (expected); `echo EXIT:$?` → EXIT:1  
- AC7: post-impl; baseline heading_absent, grep exit 1 (right fail)  
- AC8: post-impl; i=-1, printed 0, exit 1 (right fail)  
- AC9: post-impl; i=-1, printed 0, exit 1 (right fail)  
- AC10: post-impl; heading/K/SSOT tokens absent (`if drift, docs win` not in template); exit 1 (right fail). Gate2 P1: old token `docs/process-tax-cut.md` was already HIT in dirty-tree — replaced.  
- AC11: live HEAD skill-authoring; required ⊈ names; ok_id false; exit 1 (right fail). Gate2 P1: now `required <= names <= allowed`.  
- AC12: same HEAD; ok_id false; HITS=[]; exit 1 (right fail: identity, not forbidden-class)  
- AC13: post-impl; fence marker absent, exit 1 (right fail). Gate2 P1: byte-identical fences.

Advisory: `verify-ac-commands.sh` 0 warnings, 1 INFO (AC6 token in table prose; Method greps `tad.sh` only — not a self-leak).

## 9.2 Expert Review Status

> Dual files on disk = process Gate 2. Not a human `/gate 2` lock.

### Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| Spec & pathspec | P1-AC11-membership (subset-only) | AC11 `required <= names <= allowed` | CLOSED |
| Spec & pathspec | P1-FR2-bytes (token subset ≠ identical fence) | AC13 fence body `a==b==c` | CLOSED |
| Spec & pathspec | P1-FR3-ssot (token already in dirty-tree) | AC10 needle `if drift, docs win` | CLOSED |
| Scope & teeth | P1-1 Gate 2 vs Group 0 surface | Documented: install sees template only; do not widen tad.sh | DEFERRED (intentional) |
| Scope & teeth | P1-2 K1 must not replace Gate 2 dual | Blake step 4 + §10: K1 is Layer 2 only | CLOSED |
| Scope & teeth | P2-1 docs still says “three blocks” | Blake step 2 header wording | CLOSED |

### Experts Selected

1. **Gate 2 Reviewer A — Spec & pathspec** — `.tad/evidence/reviews/2026-09-14-gate2-review-ocr-review-habits-spec.md` — PASS, P0=0  
2. **Gate 2 Reviewer B — Scope & teeth** — `.tad/evidence/reviews/2026-09-14-gate2-review-ocr-review-habits-scope.md` — PASS, P0=0

**Gate 2 结果**: ✅ PASS (dual disk, P0=0). Human may say `当 Blake`. This session does **not** implement.

---

## 10. Notes

- Do not absorb v2.44.5.  
- Layer 2 dirty-tree: pre-existing dirty NEXT/PROJECT_CONTEXT/publish twins / leftover skill-authoring active copy are FALSE_POSITIVE for this knife.  
- Marketing numbers from OCR README must not enter the paste (already excluded from the fence).  
- K1 is a **Layer 2** habit (falsify-only second look). Do not paste it into Gate 2 dual spawn as “no new findings.” Gate 2 stays two independent design reviews on disk.  
- Downstream install sees K1–K5 in `spec-compliance-format.md` only (`docs/` not in tad.sh; `project-knowledge` is zero-touch). Do not “fix” that by widening the installer.

## 11. Decision Summary

| Decision | Choice | Source |
|----------|--------|--------|
| K1–K5 | KEEP as optional paste | Human lock 2026-09-14 |
| CLI/npm, rule.json SSOT, replace gates, AACR-Bench KPI | REJECT | Human lock + research §4 |
| Paste home | docs SSOT + pattern duplicate + spec-compliance-format (install-visible) | User prefer docs; parenthetical install-visible; tad.sh does not copy docs/ |
| tad.sh copy-set | Do not widen | principles deny-list / L3 install path |
| Import Alibaba product | Reject | research §4 REJECT list |

---

**Handoff Created By**: Alex (Agent A)  
**Date**: 2026-09-14  
**Version**: 3.1.0
