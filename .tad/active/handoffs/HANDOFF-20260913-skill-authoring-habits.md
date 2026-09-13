---
task_id: TASK-20260913-SKILL-AUTHORING-HABITS
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

# HANDOFF-20260913-skill-authoring-habits

**Task ID**: `TASK-20260913-SKILL-AUTHORING-HABITS`  
**From:** Alex (Terminal 1) **To:** Blake (Terminal 2)  
**Created**: 2026-09-13  
**Status**: READY_FOR_BLAKE (dual Gate 2 PASS on disk, P0=0)  
**Epic:** N/A  
**Mode**: docs-only. Blake lands the three authoring files from the design paste. No push/tag/bump/release.  
**Design pointer**: `.tad/evidence/designs/2026-09-13-skill-authoring-habits.md`  
**Channel**: Cursor / cursor-grok-4.6-medium. NO Gemini. Alex ≠ Blake. Dual Gate 2 stays.

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-13 (Alex design + dual disk reviews; P0-1 closed R2)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | No runtime. One L2 `###` + `_index` hook + skillify four bullets. |
| Components Specified | ✅ | §6.2 pathspec; paste blocks in the design pointer. |
| Functions Verified | ✅ | N/A (no code functions). MQ2 not triggered. |
| Data Flow Mapped | ✅ | N/A (docs SSOT only). Writer reads L2; skillify is the harvest outline. |

**Process Gate 2 = dual reviews on disk.** Do **not** wait for a human to type `/gate 2`. Human still says `当 Blake` for role switch.

**Alex确认**: Blake implements the paste; does not redesign; does not touch packs or role SKILLs.

---

## MQ (human lock 2026-09-13 = ②, ②, ①)

1. **User**: TAD pack/skill authors (Alex/Blake sessions), not end-user product.  
2. **Problem**: Matt-adjacent habits are unnamed on the L2 surfaces authors actually load; cargo-cult risk without a TAD-native paragraph.  
3. **Scope**: `pack-build-rules.md` + `_index.md` hook + skillify four bullets; one D3 cite sentence; optional later footnote.  
4. **Out**: wholesale Matt import; Gate 2 dual / Alex≠Blake cut; pack files; `disable-model-invocation` apply; role SKILL bodies; process-tax-cut body; L1 principles; publish.  
5. **Success**: authors hitting Pack Build Rules / skillify see D1+D2+D4 (+ D3 cite); packs unchanged.  
6. **Teeth**: dual Gate 2 on disk; Alex ≠ Blake.

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS (this §9.1 + lock).

**Socratic**: human answered Q1–Q3 in-query; Alex did not fold defaults.

### MQ evidence

| MQ | Triggered? | Evidence |
|----|------------|----------|
| MQ1 historical | yes | Reuse existing L2/loader/skillify; searched `pack-build-rules.md`, `_index.md`, skillify template, `process-tax-cut.md`, discuss + research §8. Do not import `mattpocock/skills`. |
| MQ2 functions | no | Docs-only; no function calls. |
| MQ3 data flow | no | No backend/frontend fields. |
| MQ4 visual | no | No UI states. |
| MQ5 state sync | no | Single prose SSOT (`pack-build-rules.md`); `_index` is a hook; skillify is a template. |
| MQ6 research | yes | Research note §8/§8.1 + discuss KEEP/REJECT table. Options: L2-only / L2+skillify / none. Human = L2+skillify. Rejected: `/implement`, grilling OS, tracker SSOT. |

---

## 1. Task Overview

### 1.1 What We're Building

A **docs-only** L2 knife: name TAD-native skill-authoring habits (invocation split, hard vs soft setup, docs-as-env-cache) plus one facts-vs-decisions citation and four skillify bullets.

### 1.2 Why

Pack/skill writers currently copy Matt's vocabulary or skip the split entirely. Naming it on the files they already load is cheaper than a catalog.

### 1.3 Intent Statement

**Solve**: unpublished authoring habits on L2 + skillify.  
**Not**: import Matt; cut Gate 2 dual; merge Alex/Blake; apply `disable-model-invocation` to packs; rewrite alex/blake SKILL bodies.

**Blake请确认理解** (own words before edit): this is paste-from-design into three files; packs stay untouched.

---

## 📚 Project Knowledge

**Loaded this knife:** `principles.md`; `patterns/_index.md` → `pack-build-rules.md`, `process-tax-cut.md`, `ac-verification.md` (max 3 + L1).

### Research Findings

Topic: mattpocock/skills thin deltas | Note: `.tad/evidence/research/2026-09-13-mattpocock-skills-deep.md` §8 / §8.1  
Discuss: `.tad/evidence/discuss/2026-09-13-mattpocock-borrow-deltas.md`  
Local Wiki: no prior canon. NotebookLM unavailable.

Key carriers: invocation split; ADR-0001 hard vs soft; writing-for-agents docs-as-cache; do-not-import `/implement` / grilling / tracker.

### ⚠️ Blake 必须注意的历史教训

1. **Judgment-Only Skill Files** (`principles.md`) — do not slim MUST/MANDATORY out of SKILL bodies while saying "docs cache the env."  
2. **Never Hand-Write What an Existing Tool Already Does** (`principles.md`) — D4 cites this; do not restate `--help` as SSOT.  
3. **AI/Human Judgment Domain** (`principles.md`) — D3 is one citing sentence, not a new interview OS.  
4. **Two-Agent + Four-Gate** (`principles.md`) — Gate 2 dual and Alex≠Blake are teeth.  
5. **Pack Loader Thin On-Demand** (`pack-build-rules.md` 2026-09-10) — pointer ≠ load; do not rewrite the loader.  
6. **Evaluate External Tools… host agent already has** (`pack-build-rules.md` 2026-07-03) — do not wholesale-import Matt because stars.  
7. **Process tax-cut** (`process-tax-cut.md`) — AC realism; Gate 2 = disk dual; dirty-tree adjudicate.  
8. **AC realism / vacuous AC** (`ac-verification.md`) — post-impl rows must fail on unmodified HEAD for the right reason.

Stale-check: frontend-design WARN/STALE unrelated; no matching STALE on the eight entries above.

Pack pointers (not loaded): `ai-agent-architecture`, `ai-prompt-engineering`. Do not escalate.

---

## 2. Background

Existing: loader pointer/freeze/escalate; skillify When/Steps/Anti-patterns; DR-20260712 裁决 4 unpublished in L2; `disable-model-invocation` grep 0 in `capability-packs/`.

---

## 3. Requirements

- FR1: New `### Skill Authoring Habits: Invocation Split, Hard/Soft Setup, Docs-as-Env-Cache — 2026-09-13` on `pack-build-rules.md` covering D1+D2+D4.  
- FR2: Same entry contains one D3 sentence citing `AI/Human Judgment Domain`.  
- FR3: `_index` Pack Build Rules hook ≤120 chars and contains `invocation-split`, `hard-vs-soft setup`, `docs-cache-env`.  
- FR4: Skillify Proposed Skill Outline has four bullets (`Invocation class:`, `Hard vs soft setup:`, `Docs-as-env-cache:`, `Facts vs decisions:`).  
- FR5: Pack files / role SKILLs / process-tax-cut / principles unchanged.  
- FR6: At most one later footnote on `disable-model-invocation`; no pack edits (Q3=①).  
- FR7: Commit ⊆ **§6.2** (not §7 evidence manifest).

---

## 4. Technical Design

Paste-only. Design file is the spec. Append the `###`; do not reorder older pack-build-rules entries. `_index` hunk = one line. Skillify = four bullets after existing outline items.

**Conflict matrix**: no byte-preservation × perf × behavioral triple. Docs-cache (D4) vs keep-MUST (v2.7) resolved in the same Action paragraph.

---

## 5. Implementation Steps (Blake)

1. `git status` vs §7. Do not `git add -A`.  
2. Append the design `###` to `.tad/project-knowledge/patterns/pack-build-rules.md`.  
3. Replace **only** the Pack Build Rules `_index` line with the design line.  
4. Append the four skillify bullets under `## Proposed Skill Outline`.  
5. `git add --` the three files + this handoff. Do not add design unless already tracked.  
6. Commit with subject containing `TASK-20260913-SKILL-AUTHORING-HABITS`. Prove `git diff-tree --name-only -r HEAD` ⊆ **§6.2**.  
7. Completion report. No push.

---

## 6. Files / Grounding

### 6.1 Create

| Path | Notes |
|------|--------|
| `.tad/active/handoffs/HANDOFF-20260913-skill-authoring-habits.md` | this file |
| `.tad/evidence/designs/2026-09-13-skill-authoring-habits.md` | design pointer; do not force into commit if gitignored |

### 6.2 Modify (commit set)

1. `.tad/project-knowledge/patterns/pack-build-rules.md`  
2. `.tad/project-knowledge/patterns/_index.md` *(one-line hunk)*  
3. `.tad/templates/skillify-candidate-template.md`  
4. `.tad/active/handoffs/HANDOFF-20260913-skill-authoring-habits.md`

### 6.3 Out of commit

`NEXT.md`, `PROJECT_CONTEXT.md`, `docs/pm/now.md`, `.tad/brain-index.md`, session-state, v2.44.5 handoff, leftover twins, KEEP packs, `capability-packs/**`, alex/blake SKILL, `docs/process-tax-cut.md`, `patterns/process-tax-cut.md`, `principles.md`, judge bundles.

**Grounded Against** (Alex step1c 2026-09-13):

- `.tad/project-knowledge/patterns/pack-build-rules.md` (head 50 + last `###` Pack Loader / Evaluate External Tools)  
- `.tad/project-knowledge/patterns/_index.md` (Pack Build Rules bullet)  
- `.tad/templates/skillify-candidate-template.md` (head 50 + Proposed Skill Outline)  
- design pointer (new — Alex created this turn; Blake does not redesign)

LSP/graph: skipped (`task_type: doc-only`).

---

## 7. Required Evidence Manifest (Phase 3 Anchor A-02)

```yaml
required_evidence_manifest:
  handoff_id: "HANDOFF-20260913-skill-authoring-habits"
  evidence_files:
    - path: ".tad/evidence/reviews/2026-09-13-gate2-review-skill-authoring-habits-spec.md"
      description: "Gate 2 Reviewer A — spec/pathspec/AC realism"
    - path: ".tad/evidence/reviews/2026-09-13-gate2-review-skill-authoring-habits-scope.md"
      description: "Gate 2 Reviewer B — scope/teeth/non-import"
    - path: ".tad/active/handoffs/COMPLETION-20260913-skill-authoring-habits.md"
      description: "Blake completion after pathspec commit"
    - path: ".tad/evidence/reviews/gate3-evidence-skill-authoring-habits.md"
      description: "Blake Gate 3 Layer 1 replay of §9.1"
```

---

## 8. Friction / notes

### 8.4 Friction Preflight

None. Docs-only; `grep`/`awk`/`python3`/`git` present. No new deps, reviewers spawn as Task, no auth.

### 8.5 feedback_required: false

---

## 9. Acceptance Criteria

Blake is done iff landing §9.1 rows PASS and `git diff-tree` ⊆ **§6.2**.

### AC realism (copy)

- Every landing AC has exactly one legal Verification Method: command | path-check | fixture | rubric-spawn | light-tier N/A+one-line reason.  
- Dry-run on live baseline before Gate 2 lock. Post-impl rows must fail **for the right reason** on unmodified tree.  
- Known-GOOD must PASS; known-BAD must FAIL.

## 9.1 Spec Compliance Checklist

> Landing Methods are backtick commands or path-checks. Prose-only = FAIL.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | Pack-build-rules file exists | pre-impl-verifiable | `test -f .tad/project-knowledge/patterns/pack-build-rules.md` | exit 0 | exit 0 |
| 2 | `_index` Pack Build Rules bullet exists | pre-impl-verifiable | `grep -F -- '](pack-build-rules.md)' .tad/project-knowledge/patterns/_index.md` | exit 0, ≥1 line | HIT existing bullet; exit 0 |
| 3 | Skillify template exists | pre-impl-verifiable | `test -f .tad/templates/skillify-candidate-template.md` | exit 0 | exit 0 |
| 4 | Tax-cut teeth still on disk (guide) | pre-impl-verifiable | `grep -F -- 'Alex ≠ Blake stays' docs/process-tax-cut.md` | exit 0 | HIT Teeth line; exit 0 |
| 5 | Tax-cut teeth still on disk (pattern) | pre-impl-verifiable | `grep -F -- 'Alex ≠ Blake stays' .tad/project-knowledge/patterns/process-tax-cut.md` | exit 0 | HIT Teeth line; exit 0 |
| 6 | Packs have no `disable-model-invocation` (must stay 0) | pre-impl-verifiable | `grep -RIl -- 'disable-model-invocation' .tad/capability-packs; echo EXIT:$?` | no file hits; EXIT:1 | no hits; EXIT:1 |
| 7 | New L2 heading present | post-impl-verifiable | `grep -F -- '### Skill Authoring Habits: Invocation Split, Hard/Soft Setup, Docs-as-Env-Cache — 2026-09-13' .tad/project-knowledge/patterns/pack-build-rules.md` | exit 0 | (post-impl — baseline: heading_absent, grep exit 1) |
| 8 | Same `###` covers D1+D2+D4 tokens | post-impl-verifiable | `python3 -c "import pathlib,re; t=pathlib.Path('.tad/project-knowledge/patterns/pack-build-rules.md').read_text(); m=re.search(r'^### Skill Authoring Habits: Invocation Split.*?(?=^### |\Z)', t, re.M|re.S); s=m.group(0) if m else ''; need=['user-invoked orchestrator','Hard vs soft setup','Docs-as-env-cache']; print(sum(x in s for x in need)); raise SystemExit(0 if all(x in s for x in need) else 1)"` | exit 0; printed 3 | (post-impl — baseline printed 0, exit 1) |
| 9 | Same `###` has D3 cite | post-impl-verifiable | `python3 -c "import pathlib,re; t=pathlib.Path('.tad/project-knowledge/patterns/pack-build-rules.md').read_text(); m=re.search(r'^### Skill Authoring Habits: Invocation Split.*?(?=^### |\Z)', t, re.M|re.S); s=m.group(0) if m else ''; raise SystemExit(0 if 'AI/Human Judgment Domain' in s else 1)"` | exit 0 | (post-impl — baseline exit 1) |
| 10 | `_index` hook ≤120 and three tokens | post-impl-verifiable | `python3 -c "p='.tad/project-knowledge/patterns/_index.md'\nfound=False\nfor l in open(p):\n  if '](pack-build-rules.md)' in l:\n    found=True; h=l.split(' — ',1)[1].rstrip();\n    ok=all(t in h for t in ['invocation-split','hard-vs-soft setup','docs-cache-env']) and len(h)<=120;\n    print(len(h)); print(h); raise SystemExit(0 if ok else 1)\nraise SystemExit(1)"` | exit 0; printed len ≤120 | (post-impl — baseline len=102, missing three tokens, exit 1) |
| 11 | Skillify four outline bullets | post-impl-verifiable | `python3 -c "t=open('.tad/templates/skillify-candidate-template.md').read(); s=t.split('## Proposed Skill Outline',1)[-1]; need=['Invocation class:','Hard vs soft setup:','Docs-as-env-cache:','Facts vs decisions:']; print(sum(x in s for x in need)); raise SystemExit(0 if all(x in s for x in need) else 1)"` | exit 0; printed 4 | (post-impl — baseline printed 0, exit 1) |
| 12 | This-knife commit names ⊆ §6.2 | post-impl-verifiable | `python3 -c "import subprocess; allowed={'.tad/project-knowledge/patterns/pack-build-rules.md','.tad/project-knowledge/patterns/_index.md','.tad/templates/skillify-candidate-template.md','.tad/active/handoffs/HANDOFF-20260913-skill-authoring-habits.md'}; names=[l for l in subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'], text=True).splitlines() if l]; subj=subprocess.check_output(['git','log','-1','--format=%s'], text=True); ok_id='SKILL-AUTHORING-HABITS' in subj; subset=set(names)<=allowed and bool(names); print('SUBJ='+subj.strip()); print('\\n'.join(names)); raise SystemExit(0 if ok_id and subset else 1)"` | exit 0; SUBJ contains SKILL-AUTHORING-HABITS; names nonempty ⊆ §6.2 | (post-impl — live HEAD 86c89917: tax-cut subject + 12 names not ⊆ §6.2; exit 1 — right fail: not this knife) |
| 13 | This-knife commit has no forbidden classes | post-impl-verifiable | `python3 -c "import subprocess; names=[l for l in subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'], text=True).splitlines() if l]; subj=subprocess.check_output(['git','log','-1','--format=%s'], text=True); ok_id='SKILL-AUTHORING-HABITS' in subj; bad=('capability-packs/','principles.md','process-tax-cut','/alex/SKILL.md','/blake/SKILL.md'); hits=[l for l in names if any(b in l for b in bad)]; print('SUBJ='+subj.strip()); print('HITS='+repr(hits)); raise SystemExit(0 if ok_id and not hits else 1)"` | exit 0; ok_id true; HITS=[] | (post-impl — live HEAD: ok_id false → exit 1 — right fail: not this knife) |

### Verification Method grammar

LEGAL: command in backticks | path-check | fixture | rubric-spawn | light N/A.  
ILLEGAL: prose-only.

**AC realism applied**: 7–13 fail on unmodified HEAD (missing heading / tokens / this-knife commit) for the right reason. 1–6 PASS on live baseline now.

## AC Dry-Run Log (Alex step1d 2026-09-13 10:11 UTC)

- AC1: pre-impl, `test -f pack-build-rules.md`, exit 0  
- AC2: pre-impl, `grep -F '](pack-build-rules.md)' _index.md`, HIT; exit 0  
- AC3: pre-impl, `test -f skillify-candidate-template.md`, exit 0  
- AC4: pre-impl, guide Teeth HIT; exit 0  
- AC5: pre-impl, pattern Teeth HIT; exit 0  
- AC6: pre-impl, `grep -RIl` packs = zero hits, EXIT:1 (expected)  
- AC7–11: post-impl; baseline heading_absent / count 0 / AC10 len=102 missing tokens; all exit 1 (right fails).  
- AC12/AC13 (Gate2 P0-1 rewrite, this-knife identity + exit 0 on known-GOOD): live HEAD `86c89917` both exit 1 because subject is not SKILL-AUTHORING-HABITS (right fail: not this knife). Inverted EXIT:1-is-good removed.  
- AC10 loop now `found=False` fail-closed if bullet missing (P2-1).

Advisory: `verify-ac-commands.sh` 0 warnings after python Methods.

## 9.2 Expert Review Status

> Dual files on disk = process Gate 2. Not a human `/gate 2` lock.

### Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| Spec & pathspec | P0-1 AC12/13 HEAD-relative + inverted exit | This-knife subject + ⊆ §6.2; exit 0 on known-GOOD | CLOSED |
| Spec & pathspec | P1-1 §7 vs §6.2 cites | FR7 / step 6 / Blake-done → §6.2 | CLOSED |
| Scope & teeth | P1-1 same §7 slip | Same | CLOSED |

### Experts Selected

1. **Gate 2 Reviewer A — Spec & pathspec** — `.tad/evidence/reviews/2026-09-13-gate2-review-skill-authoring-habits-spec.md` — PASS, P0=0 (R2)  
2. **Gate 2 Reviewer B — Scope & teeth** — `.tad/evidence/reviews/2026-09-13-gate2-review-skill-authoring-habits-scope.md` — PASS, P0=0

**Gate 2 结果**: ✅ PASS (dual disk, P0=0)

---

## 10. Notes

- Do not absorb v2.44.5.  
- Q3 later footnote is optional in the L2 entry; do **not** edit packs to "complete" it.  
- Layer 2 dirty-tree: pre-existing dirty NEXT/PROJECT_CONTEXT/publish twins are FALSE_POSITIVE for this knife.

## 11. Decision Summary

| Decision | Choice | Source |
|----------|--------|--------|
| Knife scope | L2 + skillify four bullets | Human Q1=② |
| D3 | One citing sentence, no grilling protocol | Human Q2=② |
| disable-model-invocation | Stay deferred; optional later footnote | Human Q3=① |
| Import Matt catalog | Reject | research §8.1 + discuss D8–D12 |

---

**Handoff Created By**: Alex (Agent A)  
**Date**: 2026-09-13  
**Version**: 3.1.0
