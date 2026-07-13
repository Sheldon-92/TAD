# Phase 1 Implementation Review — Architecture Lens

**Handoff**: HANDOFF-surplus-repositioning-capability-acquisition.md
**Epic**: EPHEMERAL-surplus-repositioning-capability-acquisition (Phase 1/1, reposition-docs)
**Reviewer**: Backend / documentation-architecture expert (doc-only task → architecture + verification-integrity focus)
**Date**: 2026-07-05
**Verdict**: FAIL — 1 P0, 2 P1, 2 P2. The implementation stage did not run: none of the three deliverables exist. There is no implementation artifact to review, and every post-impl AC (AC1–AC5) would FAIL if executed now.

---

## 0. State of the world (verified on disk at review time)

The completion report I was asked to read does not exist, and none of the three deliverables were produced:

| Expected deliverable | Required state | Actual state | Command |
|----------------------|----------------|--------------|---------|
| `docs/value-proposition.md` | created (FR3) | **ABSENT** | `test -e docs/value-proposition.md` → exit 1 |
| `README.md` positioning H2 | "capability acquisition" ≥1 (FR1) | **0** | `grep -ci 'capability acquisition' README.md` → 0 |
| `OBJECTIVES.md` revision + marker | "capability acquisition" ≥1, "repositioned 2026-07-05" ≥1 (FR2) | **0 / 0** | `grep -ci` → 0; marker grep → 0 |
| `COMPLETION-…-repositioning-…md` | present (§6/§9 evidence) | **ABSENT** | `ls COMPLETION*` → no matches |
| impl-review artifacts | present | only **design**-review artifacts present | `ls .../surplus-repositioning-…/` |

`git status --porcelain` shows README.md / OBJECTIVES.md unmodified and no untracked `docs/value-proposition.md`. `git log` on README.md/OBJECTIVES.md shows the last touch is `f1aa2a5` (pre-dates this Epic). The only new artifacts under this Epic's evidence dir are `phase1-design-review-arch.md` and `phase1-design-review-cr.md` — i.e. the DESIGN stage completed, the IMPLEMENT stage never produced output.

---

## P0 — Blocking

### P0-1 — Implementation stage not performed; phase cannot be accepted
The YOLO phase stalled after design + design-review. Zero of the three mandated deliverables exist, no completion report exists, and no impl-review predecessor exists. Concretely, running §9.1 verbatim (which Gate 3 does) yields:

- AC1 (README positioning) → FAIL (0 hits, no H2)
- AC2 (OBJECTIVES revision + marker) → FAIL (0 hits, no marker)
- AC3 (value-proposition.md 4 H2) → FAIL (`test -s` on a missing file → non-zero)
- AC4 (≥5 evidence paths) → FAIL (file absent)
- AC5 (scope) → vacuously "empty" only because nothing changed — not a pass, an empty diff

This is not a code-quality defect; it is a **completeness = 0** state. The phase must be routed back to the implement stage (or re-dispatched) to actually create the three docs per FR1–FR4, then re-reviewed. Do NOT mark Phase 1 accepted. There is nothing to certify.

**Required action:** re-run the implement stage against the existing handoff (it is buildable — both design reviews rated it CONDITIONAL, no P0), producing the 3 files + completion report + AC command outputs, then re-invoke impl-review.

---

## P1 — Must fix before the (re-)implementation can pass

> These are unresolved carry-overs from the two design reviews. Both design reviews returned CONDITIONAL with P1s, but **those P1s were never integrated back into the handoff** — AC1/AC2/FR4 in §9.1 are byte-identical to the pre-review draft. If implementation runs against the current handoff, the gate will falsely PASS a non-conforming doc. Fix the handoff FIRST, then implement.

### P1-1 — Objective-defeating cross-doc contradiction left live and unacknowledged (verified)
`docs/TAD-OVERVIEW.md` hard-codes the exact dev-framework framing the Epic exists to kill, one click from README (README already links into `docs/`):
- L11: **"TAD … 是一套 AI 辅助软件开发的方法论框架"**
- L13: **"TAD 是给 AI Coding Agent 用的「开发流程规范」"**

After this change, README will say "capability acquisition, not a coding agent" while TAD-OVERVIEW says the opposite. FR4's sweep is scoped to the 3 delivery files, so this is neither fixed nor recorded. The success criterion (§1.2 — "a reader ends up able to say TAD is capability-acquisition, not a Devin competitor") is not met even when every AC passes. Resolution (pick one, don't leave silent): (a) fold TAD-OVERVIEW.md's identity sentence into scope, or (b) record it as a known residual contradiction with a follow-up marker so the gate doesn't falsely certify "positioning is consistent." This matches the project's own "coverage/scope that passes while the real objective is unmet" lesson.

### P1-2 — §9.1 ACs under-verify their own FRs (three gaps), so Gate 3 can PASS a non-conforming doc
The gate executes §9.1 verbatim. Three rows fail to enforce their requirement:
- **AC1 collapses FR1's "name BOTH Devin AND LangGraph" into an OR**: `grep -ciE 'Devin|LangGraph'` expected `≥1` returns 1 when only one comparator is named. Fix: two conjunct greps, each `≥1`.
- **AC2's `grep -c '^## O' = 3` is a global-count floor blind to the structural loss FR2 forbids**: FR2 mandates preserving KR tables + the trailing HTML research-provenance comment; AC2 inspects neither. Blake could mangle a KR table / delete the trailer and AC2 still returns 3 → PASS. This is precisely the documented "global-count floor cannot detect must-cover loss" failure class. Fix: add per-facet checks (table-row count unchanged, `<!--` trailer count unchanged).
- **FR4 (consistency sweep) has NO verification row at all**: §9 claims "FR1–FR4 全部按 §9.1 逐行验证" but §9.1 has no AC for FR4; AC5 checks only which files changed, not content. Fix: add a negative grep scoped to the 3 files for residual primary-identity dev-framework sentences.

---

## P2 — Note / carry forward

### P2-1 — AC4 proves paths exist, not that they back a genuine cross-domain claim (validation-theater residue)
A doc could pad with trivially-existing paths (`docs/README.md`, `.tad/`) and pass AC4. NFR1 (evidence over rhetoric) and the "zero-context reader can verify" intent are human-domain (Gate 4). Ensure the completion report presents the ≥5 evidence rows as a **choice-style** summary (domain — one-line outcome — path), not a naked path list. A cheap machine floor: each Evidence bullet must contain both a path AND a prose segment (em-dash).

### P2-2 — New `docs/value-proposition.md` will leave `docs/README.md` index stale
`docs/README.md` is a live doc index (`## Current Documentation`); NFR2 forbids touching a 4th file, so nothing detects the omission. Deliberate scope trade-off, not a defect — record "index update deferred" in the completion notes so it is a conscious decision, or relax NFR2 by one line to include it.

---

## Architecture / blast-radius summary
- **Blast radius: LOW** (doc-only, no runtime/code/SKILL/hook/gate, fully reversible via git). Never in question. The problem is not risk — it is that **nothing was built**.
- **Completeness: 0/3 deliverables.** Root issue is a stalled implement stage, plus design-review P1s that were written but never fed back into the handoff, so even a successful re-run would ship a gate that certifies an unmet objective (P1-1) via ACs that don't enforce their FRs (P1-2).
- **Recommended sequence:** (1) integrate P1-1 and P1-2 fixes into the handoff §3/§9.1; (2) re-dispatch the implement stage; (3) re-run impl-review against the actual 3 files + completion report.

**P0: 1 | P1: 2 | P2: 2**
