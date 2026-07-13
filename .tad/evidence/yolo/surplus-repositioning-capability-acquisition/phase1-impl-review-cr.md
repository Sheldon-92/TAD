# Phase 1 Implementation Review — code-reviewer lens

**Handoff**: `.tad/active/handoffs/HANDOFF-surplus-repositioning-capability-acquisition.md`
**Completion report**: `.claude/worktrees/wf_35a6e2d1-e8a-12/.tad/active/handoffs/COMPLETION-surplus-repositioning-capability-acquisition.md`
**Implementation location**: git worktree `worktree-wf_35a6e2d1-e8a-12` (NOT yet merged to `main`)
**Reviewer**: code-reviewer
**Date**: 2026-07-05
**Verdict**: PASS — all ACs independently re-verified green; completion report matches the diff; no P0/P1 defects. 4 P2 polish items.

---

## Orientation note (important for the orchestrator)

The three deliverables do NOT exist in the main working tree — `docs/value-proposition.md` is
absent there, `grep -ci 'capability acquisition' README.md` = 0 on `main`. All implementation is
committed on the worktree branch `worktree-wf_35a6e2d1-e8a-12`. The completion report the task
pointed me at (`.tad/active/handoffs/COMPLETION-...`) resolves only inside that worktree. This is
the expected YOLO worktree-isolation pattern; the branch must still be merged to `main` before the
work reaches users. All checks below were run at the worktree root.

---

## Independent AC re-verification (re-ran §9.1 verbatim in the worktree)

| # | Method | Expected | Re-run result | Status |
|---|--------|----------|---------------|--------|
| AC1 | `grep -ci 'capability acquisition' README.md && grep -ciE 'Devin\|LangGraph' README.md && grep -c 'docs/value-proposition.md' README.md` | each ≥1 | `2` / `1` / `2` | ✅ |
| AC1-substance | `grep -ci devin` / `grep -ci langgraph` README.md | both ≥1 (FR1 demands BOTH named) | devin=1, langgraph=1 | ✅ both present |
| AC2 | `grep -ci 'capability acquisition' OBJECTIVES.md && grep -c 'repositioned 2026-07-05' OBJECTIVES.md && grep -c '^## O' OBJECTIVES.md` | ≥1, ≥1, =3 | `2` / `2` / `3` | ✅ |
| AC3 | `test -s ... && grep -cE '^## (The Claim\|The Evidence\|What TAD Is Not\|Who It Is For)'` | 4 | `4` | ✅ |
| AC4 | evidence-section path extract, unique count + per-path `test -e` | ≥5, all exist | 10 unique, all `OK` | ✅ |
| AC5 | porcelain minus allowed files | empty | empty | ✅ scope clean |
| FR4 | `grep -niE 'software dev(elopment)? framework\|development methodology\|dev-workflow framework'` on 3 files | no residue | exit 1, no match | ✅ |

Every number matches the completion report's pasted AC table exactly (2/1/2, 2/2/3, 4, 10 paths).
No transcription drift between claimed and actual.

## Diff-vs-claim reconciliation

- **README.md**: `git diff main` shows ONLY additions (new `## 🧭 What TAD Is` H2 after Philosophy +
  3 relaxed lines in `When to Use TAD`). ZERO deletion lines outside the replaced region →
  substantiates the "all other sections byte-for-byte untouched" claim.
- **OBJECTIVES.md**: O1 title + Why replaced (2 deletions, expected per FR2); `## O` count still 3,
  KR tables and trailing HTML provenance comments preserved. Two `<!-- repositioned 2026-07-05 -->`
  markers present → delta auditable as required.
- **docs/value-proposition.md**: created, 4 required H2s, 10 cited on-disk paths (all `test -e` OK),
  plus an explicit "What the evidence does NOT show" honesty block (satisfies NFR1 evidence-over-
  rhetoric and §10.1 no-invented-evidence).

Files-changed table in the report is accurate and complete. Scope discipline (NFR2) holds.

## Design-review carry-over (from phase1-design-review-cr.md)

- **P1-2 (FR4 had no AC row)** — ADDRESSED. Completion report adds an explicit FR4 sweep row with a
  negative grep scoped to the 3 delivery files; re-ran here, clean.
- **P1-1 (AC1 OR collapses "name both Devin AND LangGraph")** — NOT mechanically fixed in the AC
  command (it is still the OR grep), but the SHIPPED content names both comparators (verified
  devin=1, langgraph=1 on the same line), so FR1(b) is substantively met. The gap is a latent
  verification weakness for future edits, not a defect in this deliverable → downgraded to P2-1.

---

## P0 — Blocking
None.

## P1 — Should fix
None.

## P2 — Polish / follow-up

### P2-1 — AC1 verification remains an OR; content is correct but the gate is still weak
`grep -ciE 'Devin|LangGraph'` returns 1 whether one or both comparators are named. This deliverable
names both (safe), but if the section is ever re-edited to drop one, AC1 would still pass while
violating FR1(b). Cheap hardening for any future amendment: split into two conjunct greps
(`grep -ci devin && grep -ci langgraph`). Advisory only — no shipped defect.

### P2-2 — `docs/README.md` index left stale, and deferral not noted
`docs/README.md` is a live documentation index (`## Current Documentation`). The new
`docs/value-proposition.md` is not listed there. This was a conscious NFR2 scope trade-off (design
review P2-3), but the completion report does not record an "index update deferred" note. Recommend a
one-line follow-up ticket to add the entry when scope permits, or note the deferral explicitly.

### P2-3 — OBJECTIVES O1 "13+ Epics and 185+ handoffs" figures are stale
The revised O1 Why carries forward the old v2.10.4-era counts as "13+ Epics and 185+ handoffs". The
repo is now v2.33.0 with many more completed Epics; the `+` suffix keeps the statement technically
true but materially understates current reality. Not a cited value-prop claim, so low impact —
consider refreshing or dropping the specific counts to avoid re-staleness.

### P2-4 — AC4 path set includes 2 bare directory paths
`.claude/skills/` and `.tad/evidence/research/` are directory paths that exist trivially. They pass
`test -e` without backing a specific artifact (design review P2-4 "validation-theater" pattern). Not
a real problem here because 8 substantive file-path citations remain (well above the ≥5 floor even
excluding the two dirs), but the count would be more honest scoped to concrete files.

---

## Positives
- Completion report AC outputs are byte-accurate to independent re-runs — no paper acceptance.
- README untouched-section preservation is real (diff = additions only), not just asserted.
- Evidence doc's explicit "what the evidence does NOT show" block is exactly the deflated-mechanism,
  no-invented-evidence discipline the handoff (§10.1, NFR1) demanded.
- Gate 4 human questions are correctly choice-shaped (not "is this right?" rubber-stamp prompts),
  honoring the AI/Human-domain principle.
- Blake correctly did NOT self-run Gate 3 (orchestrator constraint) and flagged the N/A Layer-1
  TS/lint checks honestly rather than fabricating a pass.

## Summary
Tightly-scoped doc-only change, faithfully implemented. All 7 verification rows re-verified green
independently; the completion report matches the on-disk diff with no drift; scope is clean. No
P0/P1. Four P2 polish items, none blocking. Recommend PASS for Gate 3, with the reminder that the
work lives on worktree branch `worktree-wf_35a6e2d1-e8a-12` and must be merged before it reaches
users. Narrative quality (does the positioning read true) is a human-domain Gate 4 judgment, out of
scope for this technical review.

P0: 0 | P1: 0 | P2: 4
