**PM 2026-09-10:** Human Gate2 确认通过 + 当 Blake。

---
task_id: TASK-20260910-VERIFY-DELTA
task_type: mixed
express: false
e2e_required: no
research_required: no
skip_knowledge_assessment: no
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
status: READY_FOR_BLAKE
channel: cursor
model: cursor-grok-4.6-medium
---

# HANDOFF-20260910-verify-delta — Runnable Verification Method fail-close

**From:** Alex (Agent A — Solution Lead)  
**To:** Blake (Agent B — Execution Master)  
**Date:** 2026-09-10  
**Project:** TAD upstream  
**Task ID:** TASK-20260910-VERIFY-DELTA  
**Handoff Version:** 3.1.1 (R1 P0s integrated)  
**Epic:** N/A  
**Supersedes:** N/A  
**Design pointer:** `.tad/evidence/designs/2026-09-10-verify-delta-analyze.md`  
**Discuss baseline:** `.tad/evidence/designs/2026-09-10-pstack-verify-delta-discuss.md`  
**Status:** READY_FOR_GATE2 (R1 P0s + R2 AC P0s integrated; human confirms Gate 2 → READY_FOR_BLAKE)

Do **not** start implementation until Gate 2 PASS **and** the human says **当 Blake**. Alex must not implement. This terminal must not dispatch Blake.

---

## 🔴 Gate 2: Design Completeness

**执行时间:** 2026-09-10 (draft)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reuse AC-driven Gate 3; tighten Method grammar; no new field/orchestrator |
| Components Specified | ✅ | Template + Alex refs + gate SKILL + canonical checklist + fixture |
| Functions Verified | ✅ | Existing §9.1 / Spec_Compliance / bug mini template / express path |
| Data Flow Mapped | ✅ | Alex writes Method → Gate 3 executes → Gate 4 recomputes; light tiers never enter |

**Gate 2 结果:** ✅ PASS — human confirmed 2026-09-10 → READY_FOR_BLAKE. R2 spec CONDITIONAL (P0=0); R2 code FAIL on AC12/AC14 **applied in this same draft**. No third review round.

---

## 1. Execution Mandate (Human Authorization — 2026-09-10)

- **Outcome:** Landing tiers cannot Gate 3/4 **PASS** without a **legal runnable Verification Method**. Light tiers may N/A. No new `verify:` field.
- **Target:** TAD protocol/docs listed in §7. Dual-platform skill mirrors stay byte-identical.
- **Consequence:** Future `*bug` / `*express` / formal handoffs fail closed on prose-only AC. No public release in this task.
- **Blast radius:** Skill/template/gate prose + one fixture dir. Not `principles.md`, not installer, not hooks, not publish.
- **Recovery:** Revert the commit(s) for this pathspec if Gate 3 reds a false-FAIL; do not weaken FAIL language to go green.
- **Forbidden:** Implementing from Alex terminal; dispatching Blake from Alex terminal; new YAML `verify:` key; L1 principle; hooks/settings; auto-merge; PM thicken; Dune/Grok chase; wholesale parallelism; eval **tools**; version bump.

### Socratic (pre-answered by human locks — not re-opened)

| Q | Answer |
|---|---|
| Complexity | Medium / standard TAD. Human: 可以派了. |
| Q1 ICP | TAD maintainer + Alex/Blake executing landing handoffs. |
| Q2 Problem | Prose AC (especially `*bug` mini) can still look shippable; §9.1 “must be a command” is not fail-closed on illegal Method cells. |
| Q3a In | Grammar + Gate 3/4 fail-close + bug mini Method + express cheaper-check + optional cheap `*eval` stub. |
| Q3b Out | New field; `*bug` min-1 review; L1 principle; hooks; eval tools; skipped items in §10. |
| Q4 Risk | SAFETY-count floors vs new FAIL sentences — add genuine surface only. Location-scoped greps (no self-leak). |
| Q5 AC | §9 / §9.1 below. |

**AC Conflict Matrix:** see design note §10. Binding: do **not** add `*bug` expert review; do **not** BLOCK on missing tsc/test (dev-floor stays WARN); `honest_partial` ≠ bypass for missing methods.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read this file + design pointer + discuss baseline
- [ ] Read §📚 historical lessons
- [ ] Dual-platform: edit `.claude/skills/…` then copy **byte-identical** to `.agents/skills/…` for every twin
- [ ] Do not edit `principles.md`, `tad.sh`, hooks, or settings
- [ ] Stop if a lock above would need to change — return to human/Alex

---

## 1.3 Intent Statement

**真正要解决的问题：** Landing work can still “pass” with a story instead of a command. Close that on the **existing Method column**, especially `*bug`.

**不是要做的：**
- ❌ Not a new `verify:` field or pstack playbook runtime
- ❌ Not making `*bug` review-mandatory (separate known conflict with AR-001)
- ❌ Not hook enforcement
- ❌ Not L1 methodology
- ❌ Not Workshop eval harness

**Blake请确认理解（用自己的话，等人确认后再写代码）：**
1. 这个问题是什么？
2. 成功时 Alex 写 handoff 会怎样？失败的 prose AC 会怎样？
3. 什么明确不做？

---

## 📚 Project Knowledge（Blake 必读）

**相关类别:** architecture / testing / gate-design / ac-verification / handoff-design

**已读取:** `principles.md`, `patterns/_index.md`, `patterns/ac-verification.md`, `patterns/gate-design.md`

**⚠️ Blake 必须注意的历史教训：**

1. **AC Verification Drift** (`patterns/ac-verification.md`) — dry-run commands on live artifacts; do not mentally simulate regex; section-scope greps; known-GOOD must pass / known-BAD must fail.
2. **AC Self-Leak from Removal Rationale** — do not put the forbidden checkbox sentence into a “must be absent” file’s rationale if an AC greps that file for absence. Put ILLEGAL examples in the **fixture** and/or labeled `ILLEGAL example:` lines in gate SKILL only.
3. **Claims Need Carriers** (`patterns/gate-design.md`) — Gate 4 reads disk, not chat; executing Methods must leave evidence.
4. **Mechanical Enforcement Rejected** (`principles.md`) — fail-close in Gate 3/4 **judgment**, not PreToolUse.
5. **AC-Driven Universal Gate** — empty §9.1 already BLOCKS; this patch adds **present-but-prose** row FAIL. Do not confuse with Spec_Compliance_Dev_Floor (WARN).
6. **Rewiring a Gate's Prose Can Trip grep -c SAFETY** — keep MUST/VIOLATION citations; line-set is ground truth.
7. **Express is NOT review-exemption** — this patch does **not** change `*express` ≥1 review. It only adds cheaper runnable when skipping e2e. `*bug` mini remains review-light per human lock.

Research: Local Wiki / NotebookLM — no canon hit required (discuss already established take/skip).

---

## Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/verify-delta/spec-compliance-reviewer.md
    - .tad/evidence/reviews/blake/verify-delta/code-reviewer.md
  gate_verdicts:
    - Gate 3 v2 in COMPLETION
  completion:
    - .tad/active/handoffs/COMPLETION-20260910-verify-delta.md
  blake_reviews: []
  perf_evidence: []
  fixture_results:
    - .tad/evidence/acceptance-tests/verify-delta/README.md
    - .tad/evidence/acceptance-tests/verify-delta/illegal-prose-method.example.md
    - .tad/evidence/acceptance-tests/verify-delta/legal-grep-method.example.md
  dogfood: []
  knowledge_updates: []  # no principles.md; optional L2 deferred
```

---

## 2. Background / Current State

- Formal §9.1: Gate 3 PRIMARY; empty → BLOCK; template already says Method must be a runnable command.
- Hole: `bug-path-protocol.md` mini template AC is checkbox prose; no Gate fail-close on **illegal but non-empty** Method cells; Gate 4 functional acceptance does not explicitly refuse summary-only greens.
- `*express` may skip e2e (AR-001) but does not say a cheaper runnable must remain.

## 3. Requirements

### 3.1 Functional

- **FR1** Legal/illegal Verification Method grammar documented in template §9.1 + `step1_ac_generation` (no new column/key named `verify:`).
- **FR2** `*bug` mini-handoff: ≥1 legal Method required; keep skip Socratic and skip expert review. Mini template **must include a one-row `## 9.1 Spec Compliance Checklist`** (existing Gate 3 empty-§9.1 BLOCK otherwise never sees the Method).
- **FR3** `*express`: skipping e2e allowed only if ≥1 cheaper legal runnable remains.
- **FR4** Gate 3: illegal Method → row FAIL → cannot PASS. Empty §9.1 still BLOCKS.
- **FR5** Gate 4: cannot Functional-acceptance PASS if landing Methods missing or unrun; cannot accept on Blake summary alone.
- **FR6** Light tiers: N/A + reason allowed; no fake commands (one-liners OK).
- **FR7** Dual-platform byte-identical twins.
- **FR8** Trust-curve **judgment** paragraph in `gate/SKILL.md` (not a checklist item, not L1).
- **FR9** Optional cheap `*eval` intent-shell (≤20 lines both trees) or `EVAL_STUB_DEFERRED` in completion.

### 3.2 Non-Functional

- **NFR1** No hooks/settings/`tad.sh` edits.
- **NFR2** Do not drop existing VIOLATION/paper-accept language.
- **NFR3** Distinctive tokens below must appear in the governed files (for AC greps).

### 3.3 Distinctive tokens (insert verbatim)

| Token | Where |
|-------|--------|
| `prose-only Verification Method = FAIL` | Inside `Spec_Compliance_Verification:` YAML block (both gate SKILL trees), **not** only Empty Guard / Gate 4 |
| `classify Method legality before execute` | Same `Spec_Compliance_Verification:` block, **before** the execute-Method step |
| `cannot Gate 4 PASS if landing Verification Method missing or unrun` | Gate 4 Functional acceptance item in `gate/SKILL.md` **and** `gate-canonical-checklist.md` **and** `acceptance-protocol.md` (both trees) |
| `recompute landing Verification Methods from disk` | Same three Gate 4 carriers |
| `Blake summary is not Gate 4 evidence` | Same three Gate 4 carriers |
| `Friction_Review does not waive Method recompute` | `gate/SKILL.md` Gate4_Friction_Review (both trees) |
| `mini-handoff includes §9.1 Spec Compliance Checklist` | `bug-path-protocol.md` mini template (both trees) |
| `express skip-e2e still requires a cheaper runnable check` | `express-path-protocol.md` both trees |
| `Mini-handoff AC must include a legal runnable Verification Method` | `bug-path-protocol.md` both trees |
| `legal Verification Method (command \| path-check \| fixture \| rubric-spawn \| light-tier N/A)` | `handoff-a-to-b.md` §9.1 callout (use this wording; pipe as `\|` in tables if needed) |

---

## 4. Technical Design

Reuse the AC-driven gate. **Extend judgment**, do not add a parser/hook:

```
Method cell
  → LEGAL (1–5 in design §4)? 
      yes → execute (existing Spec_Compliance_Verification)
      no  → FAIL row → Gate 3 cannot PASS
Gate 4 recomputes the same commands from disk
  → if any landing row illegal or unrun → Functional acceptance cannot PASS
```

Mini-handoff: **must** contain `## 9.1 Spec Compliance Checklist` with ≥1 legal Method row so Gate 3 empty-guard applies. Layer 1 still required. Layer 2 / expert review **not** added (lock 2).

Express: add to `required_steps` or a sibling note next to skipped e2e: cheaper grep/fixture/targeted test counts.

`*eval`: command description only — “Intent-shell: send blind-eval / eval-harness work to Agent Workshop; TAD core does not run eval tools.” No new protocol reference file unless required for the router list.

## 5. Implementation Steps (ordered)

1. Edit `.tad/gates/gate-canonical-checklist.md` first (SSOT), then propagate Gate 3/4 sentences into `gate/SKILL.md`.
2. In `Spec_Compliance_Verification.process`, add an ordered step **before execute**: classify Method legality; illegal → row FAIL. Insert tokens `classify Method legality before execute` and `prose-only Verification Method = FAIL` **in that block**. State: present-but-prose ≠ Empty Guard. Keep Empty Guard BLOCK.
3. Gate 4 Functional acceptance + canonical + `acceptance-protocol.md`: recompute Methods from disk; missing/unrun/illegal → cannot PASS; `Blake summary is not Gate 4 evidence`. Add `Friction_Review does not waive Method recompute` so friction review cannot skip recompute.
4. Tighten `.tad/templates/handoff-a-to-b.md` §9.1 (grammar + examples; **no new column**).
5. Update Alex `handoff-creation-protocol.md` `step1_ac_generation` (illegal Method = rewrite before ship). Mirror `.agents`.
6. Replace `bug-path-protocol.md` mini AC with a **§9.1 one-row table** + tokens; keep `skip Socratic, skip expert review`. Mirror.
7. Add express cheaper-runnable token. Mirror.
8. Trust-curve **judgment** (3–6 lines, not a `- [ ]` item) in gate SKILL. Keep `Spec_Compliance_Dev_Floor` **WARN not BLOCK**.
9. `acceptance-verification-guide.md` align + `*bug` mini §9.1.
10. Optional light-tier one-liners (`discuss`/`idea`/`learn`) if each is ≤5 lines. Mirror.
11. Optional `*eval` stub if ≤20 lines total; else completion `EVAL_STUB_DEFERRED`.
12. Write fixtures under `.tad/evidence/acceptance-tests/verify-delta/` (LEGAL Method **cell** vs ILLEGAL Method **cell**).
13. Parity: `diff -q` every edited twin pair (required list always; optional pairs if those files differ from HEAD).
14. Layer 1 ACs → Layer 2 (spec-compliance-reviewer + code-reviewer) → COMPLETION. **No version bump.**

## 6. Micro-Tasks

- M1 SSOT + gate SKILL fail-close + trust-curve judgment  
- M2 templates + Alex handoff-creation + acceptance-protocol + verification-guide  
- M3 bug + express (+ optional light / eval)  
- M4 fixtures + dual-platform parity + AC evidence  

## 7. Files to Modify / Create

**MODIFY**

- `.tad/gates/gate-canonical-checklist.md`
- `.tad/templates/handoff-a-to-b.md`
- `.tad/templates/acceptance-verification-guide.md`
- `.claude/skills/gate/SKILL.md`
- `.agents/skills/gate/SKILL.md`
- `.claude/skills/alex/references/handoff-creation-protocol.md`
- `.agents/skills/alex/references/handoff-creation-protocol.md`
- `.claude/skills/alex/references/bug-path-protocol.md`
- `.agents/skills/alex/references/bug-path-protocol.md`
- `.claude/skills/alex/references/express-path-protocol.md`
- `.agents/skills/alex/references/express-path-protocol.md`
- `.claude/skills/alex/references/acceptance-protocol.md`
- `.agents/skills/alex/references/acceptance-protocol.md`

**OPTIONAL MODIFY** (cheap-only)

- `.claude/skills/alex/references/discuss-path-protocol.md` + `.agents` twin  
- `.claude/skills/alex/references/idea-path-protocol.md` + `.agents` twin  
- `.claude/skills/alex/references/learn-path-protocol.md` + `.agents` twin  
- `.claude/skills/alex/SKILL.md` + `.agents/skills/alex/SKILL.md` (`*eval` command + explicit_commands)  
- `.claude/skills/alex/references/intent-router-protocol.md` + `.agents` twin  

**CREATE**

- `.tad/evidence/acceptance-tests/verify-delta/README.md`
- `.tad/evidence/acceptance-tests/verify-delta/illegal-prose-method.example.md`
- `.tad/evidence/acceptance-tests/verify-delta/eval-stub-status.txt` (contents `EVAL_STUB_PRESENT` or `EVAL_STUB_DEFERRED`)

**DO NOT MODIFY**

- `.tad/project-knowledge/principles.md`
- `tad.sh`
- `.tad/hooks/**`
- `.claude/settings.json`
- `.codex/hooks.json`
- Unrelated `NEXT.md` / publish v2.44.4 handoff (Alex may have added a NEXT pointer; do not rewrite that publish task)

## 8. Testing / Friction

No new runtime deps. `diff`/`grep`/`cmp` only.

### 8.4 Friction Preflight

- Dual skill trees present: READY.  
- Reviewers: spec-compliance-reviewer + code-reviewer (or EQUIVALENT_SUBSTITUTE generalPurpose if harness lacks the named type). Self-review NEVER equivalent.  
- No network required.  
- `verify-ac-commands.sh` advisory only if run.

### 8.5 feedback_required: false

---

## 9. Acceptance Criteria

Blake is done iff FR1–FR8 hold, FR9 is stub or deferred, ACs below pass, Layer 2 on disk, COMPLETION written. No tag/publish.

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

> **legal Verification Method (command | path-check | fixture | rubric-spawn | light-tier N/A)** — this handoff is landing-tier; every row is a runnable command. Light-tier N/A does not apply here.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|---------------------|-------------------|-------------------------------|
| AC0 | Design note exists | pre-impl-verifiable | `test -f .tad/evidence/designs/2026-09-10-verify-delta-analyze.md` | exit 0 | (step1d) |
| AC2 | Checkbox line gone from both bug-path trees | post-impl-verifiable | `c1=$(grep -cF -- '- [ ] Bug no longer reproduces under reported conditions' .claude/skills/alex/references/bug-path-protocol.md); c2=$(grep -cF -- '- [ ] Bug no longer reproduces under reported conditions' .agents/skills/alex/references/bug-path-protocol.md); test "$c1" -eq 0 && test "$c2" -eq 0` | exit 0 | (post-impl) |
| AC3 | Bug-path Method token, both trees | post-impl-verifiable | `test "$(grep -cF -- 'Mini-handoff AC must include a legal runnable Verification Method' .claude/skills/alex/references/bug-path-protocol.md)" -ge 1 && test "$(grep -cF -- 'Mini-handoff AC must include a legal runnable Verification Method' .agents/skills/alex/references/bug-path-protocol.md)" -ge 1` | exit 0 | (post-impl) |
| AC3b | Mini template has §9.1 token, both trees | post-impl-verifiable | `test "$(grep -cF -- 'mini-handoff includes §9.1 Spec Compliance Checklist' .claude/skills/alex/references/bug-path-protocol.md)" -ge 1 && test "$(grep -cF -- 'mini-handoff includes §9.1 Spec Compliance Checklist' .agents/skills/alex/references/bug-path-protocol.md)" -ge 1` | exit 0 | (post-impl) |
| AC3c | Lock 2: skip expert review kept | post-impl-verifiable | `test "$(grep -cF -- 'skip Socratic, skip expert review' .claude/skills/alex/references/bug-path-protocol.md)" -ge 1 && test "$(grep -cF -- 'skip Socratic, skip expert review' .agents/skills/alex/references/bug-path-protocol.md)" -ge 1` | exit 0 | (post-impl) |
| AC3d | Mini template literal §9.1 heading | post-impl-verifiable | `grep -F -- '## 9.1 Spec Compliance Checklist' .claude/skills/alex/references/bug-path-protocol.md && grep -F -- '## 9.1 Spec Compliance Checklist' .agents/skills/alex/references/bug-path-protocol.md` | grep exit 0 | (post-impl) |
| AC4 | Express cheaper-runnable, both trees | post-impl-verifiable | `test "$(grep -cF -- 'express skip-e2e still requires a cheaper runnable check' .claude/skills/alex/references/express-path-protocol.md)" -ge 1 && test "$(grep -cF -- 'express skip-e2e still requires a cheaper runnable check' .agents/skills/alex/references/express-path-protocol.md)" -ge 1` | exit 0 | (post-impl) |
| AC5 | Legality-before-execute inside Spec_Compliance_Verification (claude) | post-impl-verifiable | `awk '/^Spec_Compliance_Verification:/{p=1;print;next} p && /^Spec_Compliance_Empty_Guard:/{exit} p{print}' .claude/skills/gate/SKILL.md \| grep -F -- 'classify Method legality before execute'` | grep exit 0 | (post-impl) |
| AC5b | Prose-FAIL token in same block, both trees | post-impl-verifiable | `awk '/^Spec_Compliance_Verification:/{p=1;print;next} p && /^Spec_Compliance_Empty_Guard:/{exit} p{print}' .claude/skills/gate/SKILL.md \| grep -F -- 'prose-only Verification Method = FAIL' && awk '/^Spec_Compliance_Verification:/{p=1;print;next} p && /^Spec_Compliance_Empty_Guard:/{exit} p{print}' .agents/skills/gate/SKILL.md \| grep -F -- 'prose-only Verification Method = FAIL'` | both greps exit 0 | (post-impl) |
| AC5c | Empty Guard BLOCK language kept | post-impl-verifiable | `grep -F -- 'No verification criteria found in §9.1' .claude/skills/gate/SKILL.md` | grep exit 0 | (post-impl) |
| AC5d | Dev-floor stays WARN | post-impl-verifiable | `grep -F -- 'WARN (not BLOCK)' .claude/skills/gate/SKILL.md` | grep exit 0 | (post-impl) |
| AC6 | Gate 4 cannot-PASS token in SKILL, agents, canonical | post-impl-verifiable | `test "$(grep -cF -- 'cannot Gate 4 PASS if landing Verification Method missing or unrun' .claude/skills/gate/SKILL.md)" -ge 1 && test "$(grep -cF -- 'cannot Gate 4 PASS if landing Verification Method missing or unrun' .agents/skills/gate/SKILL.md)" -ge 1 && test "$(grep -cF -- 'cannot Gate 4 PASS if landing Verification Method missing or unrun' .tad/gates/gate-canonical-checklist.md)" -ge 1` | exit 0 | (post-impl) |
| AC6b | Gate 4 recompute + not-summary in acceptance-protocol both trees | post-impl-verifiable | `test "$(grep -cF -- 'recompute landing Verification Methods from disk' .claude/skills/alex/references/acceptance-protocol.md)" -ge 1 && test "$(grep -cF -- 'Blake summary is not Gate 4 evidence' .claude/skills/alex/references/acceptance-protocol.md)" -ge 1 && test "$(grep -cF -- 'recompute landing Verification Methods from disk' .agents/skills/alex/references/acceptance-protocol.md)" -ge 1` | exit 0 | (post-impl) |
| AC6c | Friction does not waive recompute | post-impl-verifiable | `test "$(grep -cF -- 'Friction_Review does not waive Method recompute' .claude/skills/gate/SKILL.md)" -ge 1 && test "$(grep -cF -- 'Friction_Review does not waive Method recompute' .agents/skills/gate/SKILL.md)" -ge 1` | exit 0 | (post-impl) |
| AC6d | Gate SKILL itself has recompute + not-summary tokens | post-impl-verifiable | `test "$(grep -cF -- 'recompute landing Verification Methods from disk' .claude/skills/gate/SKILL.md)" -ge 1 && test "$(grep -cF -- 'Blake summary is not Gate 4 evidence' .claude/skills/gate/SKILL.md)" -ge 1` | exit 0 | (post-impl) |
| AC7 | Template grammar present; no verify: column marker | post-impl-verifiable | `grep -F -- 'legal Verification Method (command' .tad/templates/handoff-a-to-b.md && grep -F -- '| # | Acceptance Criterion | Verification Type | Verification Method |' .tad/templates/handoff-a-to-b.md && test "$(grep -cF -- '| verify:' .tad/templates/handoff-a-to-b.md)" -eq 0` | exit 0 | (post-impl) |
| AC8 | Template opening YAML has no verify: key | post-impl-verifiable | `awk 'NR==1 && /^---/{p=1;next} p && /^---/{exit} p && /^verify:/{bad=1} END{exit bad+0}' .tad/templates/handoff-a-to-b.md` | exit 0 | (post-impl) |
| AC9 | principles.md not dirty vs HEAD | post-impl-verifiable | `test -z "$(git diff --name-only HEAD -- .tad/project-knowledge/principles.md)" && test -z "$(git status --porcelain -- .tad/project-knowledge/principles.md)"` | exit 0 | (post-impl) |
| AC10 | No hook/settings/tad.sh porcelain | post-impl-verifiable | `test -z "$(git status --porcelain -- .tad/hooks .claude/settings.json .codex/hooks.json tad.sh)"` | exit 0 | (post-impl) |
| AC11 | Required dual-platform pairs identical | post-impl-verifiable | `diff -q .claude/skills/gate/SKILL.md .agents/skills/gate/SKILL.md && diff -q .claude/skills/alex/references/bug-path-protocol.md .agents/skills/alex/references/bug-path-protocol.md && diff -q .claude/skills/alex/references/express-path-protocol.md .agents/skills/alex/references/express-path-protocol.md && diff -q .claude/skills/alex/references/handoff-creation-protocol.md .agents/skills/alex/references/handoff-creation-protocol.md && diff -q .claude/skills/alex/references/acceptance-protocol.md .agents/skills/alex/references/acceptance-protocol.md` | exit 0 | (post-impl) |
| AC12 | Fixtures carry method-cell tokens | post-impl-verifiable | `grep -F -- 'ILLEGAL_METHOD_CELL' .tad/evidence/acceptance-tests/verify-delta/illegal-prose-method.example.md && grep -F -- 'LEGAL_METHOD_CELL' .tad/evidence/acceptance-tests/verify-delta/legal-grep-method.example.md` | exit 0 | (post-impl) |
| AC13 | Live bug-path does not keep the old checkbox | post-impl-verifiable | `test "$(grep -cF -- '- [ ] Bug no longer reproduces under reported conditions' .claude/skills/alex/references/bug-path-protocol.md)" -eq 0` | exit 0 | (post-impl) |
| AC14 | FR9 eval stub or deferred status file | post-impl-verifiable | `if grep -q '^[[:space:]]*eval:' .claude/skills/alex/SKILL.md; then grep -F -- 'Workshop' .claude/skills/alex/SKILL.md && diff -q .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; else grep -F -- 'EVAL_STUB_DEFERRED' .tad/evidence/acceptance-tests/verify-delta/eval-stub-status.txt; fi` | exit 0 | (post-impl) |

Baseline (not a Gate 3 row): 2026-09-10 Grep found 1 match of the old checkbox in `bug-path-protocol.md` line 68. After impl AC2/AC13 require count 0.

## 9.2 Expert Review Status (Alex)

| Round | Reviewer | Carrier | Verdict |
|-------|----------|---------|---------|
| R1 | spec/protocol (generalPurpose) | `.tad/evidence/reviews/2026-09-10-gate2-verify-delta-spec.md` | FAIL — P0-1..P0-6 |
| R1 | code/AC (generalPurpose) | `.tad/evidence/reviews/2026-09-10-gate2-verify-delta-code.md` | FAIL — AC1/AC7/AC15 |
| R2 | spec/protocol | `.tad/evidence/reviews/2026-09-10-gate2-verify-delta-spec-r2.md` | CONDITIONAL — R1 P0s closed; P1 remaining |
| R2 | code/AC | `.tad/evidence/reviews/2026-09-10-gate2-verify-delta-code-r2.md` | FAIL — AC12 backtick; AC14 COMPLETION timing |
| R2b | Alex | this draft | AC12 tokens; AC14 status file; AC3d heading; AC6d Gate SKILL recompute |

### Audit Trail

| ID | Finding | Resolution |
|----|---------|------------|
| P0-1 | Token grep ≠ legality-before-execute | §5 step 2 + AC5/AC5b section-scoped to Spec_Compliance_Verification block |
| P0-2 | Gate 4 summary PASS | AC6/AC6b/AC6c + acceptance-protocol + Friction waiver token |
| P0-3 | AC1 unsatisfiable after impl | Removed AC1 from §9.1; baseline in note under table |
| P0-4 | Lock 2 unprotected | AC3c skip expert review |
| P0-5 | `! grep` / awk invert-exit / `^\\|` | AC7/AC8 rewritten to exit 0 on success |
| P0-6 | AC15 dirty-tree | Dropped unscoped `git diff --name-only HEAD`; AC9/AC10 porcelain on forbidden paths |
| R2-AC12 | LEGAL backtick grep false-FAIL | `ILLEGAL_METHOD_CELL` / `LEGAL_METHOD_CELL` tokens |
| R2-AC14 | COMPLETION not on disk at Layer 1 | `eval-stub-status.txt` |
| R2-P1 | recompute not grepped in gate SKILL | AC6d |
| R2-P1 | token vs heading | AC3d literal `## 9.1` |

---

## 10. Important Notes / Anti-patterns

- Do not add a `verify:` frontmatter key “for compatibility with pstack”.
- Do not register hooks “to make it real”.
- Do not fix AR-001 on `*bug` in this patch.
- Do not treat WARN dev-floor as this FAIL.
- Do not quote the old checkbox in bug-path as a removal rationale if AC2 greps that file.
- Trust curve is **not** a Gate `- [ ]` row.

### 10.3 Sub-Agent

Gate 3 Layer 2: spec-compliance-reviewer (this §9.1) + code-reviewer (skill/template diffs).

---

## 11. Decision Summary

| Decision | Choice | Source |
|----------|--------|--------|
| Carrier | Tighten Method grammar, no new field | Human lock 1 |
| `*bug` review | Runnable only; no min-1 review | Human lock 2 |
| Express skip e2e | grep/fixture OK | Human lock 3 |
| Fail-close | Gate 3 **and** Gate 4 cannot green | Human lock 4 |
| Trust curve | Skills/judgment; no L1 | Human lock 5 |
| `*eval` tools | Workshop; optional TAD intent-shell | Scope |
| Enforcement | Gate judgment, not hooks | principles Mechanical Enforcement |

---

## 8.4 / MQ1–MQ6 (Gate 2)

| MQ | Answer | Evidence |
|----|--------|----------|
| MQ1 Files exist | Yes — listed in §7; twins confirmed via glob | `.claude` + `.agents` trees |
| MQ2 Functions exist | Yes — Spec_Compliance_Verification, bug mini template, express path | gate SKILL; bug-path; express-path |
| MQ3 Data flow | Method text → Gate 3 execute → evidence → Gate 4 recompute | design §5 |
| MQ4 Errors | Illegal Method → FAIL; missing twin → AC11 FAIL; SAFETY count noise → line-set | §10 |
| MQ5 Tests | §9.1 commands; no e2e | this section |
| MQ6 Rollback | Revert pathspec commit | Mandate recovery |

---

## AC Dry-Run Log (Alex step1d, 2026-09-10, after R1 P0 rewrite)

Workspace Grep (Shell unavailable). Blake re-runs **literal** §9.1 commands at Gate 3. Un-escape `\|` in table cells to `|` before bash.

- **AC0:** design file exists (Write this session). Pre-impl PASS expected.
- **AC1:** removed from Gate 3 table (P0-3). Baseline: checkbox count **1** at bug-path L68.
- **AC2–AC6c, AC11–AC14:** post-impl. Tokens currently **absent** (Grep: `prose-only Verification Method = FAIL` in gate SKILL = 0; `classify Method legality before execute` = 0). Pre-impl these rows fail for missing tokens — correct fail reason.
- **AC5c:** Grep `No verification criteria found in §9.1` — present in gate SKILL today (Empty Guard). Pre-impl PASS if run now.
- **AC5d:** Grep `WARN (not BLOCK)` — present in Spec_Compliance_Dev_Floor today. Pre-impl PASS if run now.
- **AC7/AC8:** no `verify:` column/key today. After impl, grammar token must be **added**; AC8 awk on first `---` fence must stay exit 0.
- **AC9/AC10:** forbidden-path porcelain; do not use unscoped `git diff --name-only HEAD`.

**verify-ac-commands.sh:** advisory; not a skip.

---

## 📨 Message to Blake (structured)

```
task: TASK-20260910-VERIFY-DELTA
handoff: .tad/active/handoffs/HANDOFF-20260910-verify-delta.md
design: .tad/evidence/designs/2026-09-10-verify-delta-analyze.md
priority: P1
scope: Tighten §9.1 Verification Method grammar; fail-close Gate 3+4 on prose-only methods; fix *bug mini AC; express cheaper-check; optional *eval stub
files: see handoff §7
do_not: principles.md, tad.sh, hooks, settings, new verify: field, *bug min-1 review, dispatch from Alex
wait_for: Gate 2 dual reviews + human 当 Blake
channel: cursor
model: cursor-grok-4.6-medium
```

---

## 人话版

以后走落地通道（正式 handoff、\*express、\*bug）时，不能再用「看着修好了」当验收。必须留下一条现在就能跑的检查（命令、文件、或 fixture）。\*bug 先只补这一刀，先不强制加审查。\*express 可以继续跳过 e2e，但得留下更便宜的检查。Gate 3 和 Gate 4 都不能在缺检查或没跑检查时给绿灯。信任曲线先写在技能判断里，不写进 L1。你确认 Gate 2、再说「当 Blake」；这边不会替你派、也不会改 tad.sh。
