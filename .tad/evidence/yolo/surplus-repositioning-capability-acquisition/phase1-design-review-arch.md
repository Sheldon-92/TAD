# Phase 1 Design Review — Architecture Lens

**Handoff**: HANDOFF-surplus-repositioning-capability-acquisition.md
**Reviewer**: Backend/Documentation-architecture expert (auto-detected domain: doc-only → architecture/verification-integrity focus)
**Date**: 2026-07-05
**Verdict**: CONDITIONAL — 0 P0, 2 P1, 4 P2. No blocking design flaw; blast radius is LOW (doc-only, reversible via git). Two P1s should be resolved (or explicitly deferred with a follow-up marker) before Gate 3 sign-off because both let a gate PASS while the handoff's own stated objective is unmet.

Baseline claims independently verified on disk: README 15 H2 / `capability acquisition`=0; OBJECTIVES 3 `^## O` headers; sync-registry.yaml 14 entries; docs/value-proposition.md absent; all §5 MQ2 evidence paths `test -e` OK. Handoff grounding is accurate.

---

## P0 — Blocking
None. The design is buildable as written and blast radius is contained to 3 docs + bookkeeping.

---

## P1 — Should fix before acceptance

### P1-1 — Consistency scope (FR4) is too narrow to meet the stated positioning objective; a live cross-doc contradiction is left unaddressed
The handoff's success criterion (§1.2) is "a reader ends up able to say *TAD is a capability-acquisition methodology, not a Devin competitor*." But FR4 scopes the consistency sweep to **only the 3 delivered files** and defines contradiction as within-file ("同一文件内不得同时存在新旧定位"). It never addresses cross-document contradiction.

Confirmed live contradiction surface outside scope:
- `docs/TAD-OVERVIEW.md` L11: **"TAD ... 是一套 AI 辅助软件开发的方法论框架"**
- `docs/TAD-OVERVIEW.md` L13: **"TAD 是给 AI Coding Agent 用的「开发流程规范」"**

This is the *exact* dev-framework framing the Epic exists to correct, and it lives one click away (README already links into docs/). After this change, README says "capability acquisition, not a coding agent" while docs/TAD-OVERVIEW.md says "开发流程规范 for AI Coding Agents." A reader following docs/ gets the opposite of the intended message — the objective is not met even though every AC passes.

This is a genuine scope-vs-goal tension, not a demand to widen scope arbitrarily. Recommended resolution (pick one, don't leave it silent):
- (a) Add `docs/TAD-OVERVIEW.md` (and check `docs/README.md`, `docs/CODEX-USER-GUIDE.md`) to the sweep, at minimum the identity sentence(s); OR
- (b) Explicitly record it as a **known residual contradiction** with a follow-up Epic/idea marker, so the gate does not falsely certify "positioning is consistent." Currently the design neither fixes nor acknowledges it — that is the completeness gap.

### P1-2 — AC2 verifies only the O-header count, not the "preserve OKR structure" mandate it is supposed to guard (coverage-gate blind spot)
FR2 mandates preserving O1-O3 numbering, **KR tables, and the trailing HTML comment**. AC2 checks only `grep -c '^## O' = 3`. On disk OBJECTIVES.md has ~9 KR rows, 15 total table rows, and 5 comment lines — none of which AC2 inspects. Blake could delete/mangle a KR table or the research-provenance trailer and **AC2 still returns 3 → Gate 3 PASS**.

This is the documented failure class in principles.md ("A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover Loss" / "verify presence per-category within the must-cover scope, never via a global count"). The count-of-3 is exactly such a global tally that is blind to structural loss elsewhere. Add per-facet checks to AC2: e.g. table-row count `grep -c '^|' OBJECTIVES.md` unchanged (=15), and trailer presence `grep -c '<!--' OBJECTIVES.md` unchanged (=5). Then the gate actually enforces FR2.

---

## P2 — Nice to fix / note

### P2-1 — AC4 bare-path-with-trailing-punctuation fragility
`grep -oE '(\.tad|\.claude|docs)/[^ )\x60]*'` stops on space, `)`, backtick. For backtick-wrapped and paren-wrapped paths (the repo's dominant style) this is robust — I simulated both and trailing periods were correctly excluded. But a **bare** path followed by a period ("…at .tad/foo.md.") captures the trailing `.`, making `test -e ".tad/foo.md."` fail → false-FAIL on AC4. Mitigation is cheap: instruct Blake to always wrap Evidence paths in backticks (already the house style), or add `.` `,` to the exclusion class.

### P2-2 — "Single source of truth" (MQ5) is partly overstated; core claim is duplicated by design
FR1 requires the README H2 to contain the definition (a), the Devin/LangGraph non-goal (b), and a cross-domain summary (c). Items (a) and (b) are the same content as value-proposition.md's `## The Claim` and `## What TAD Is Not`. So the core positioning statement and the non-goal genuinely exist in two files — the very drift surface MQ5 claims to have eliminated ("不复制细节 → 不产生漂移面"). The claim should be softened to "value-proposition.md is the SoT for the *evidence detail*; the one-sentence claim + non-goal are intentionally mirrored in README." This is honesty about the drift surface, and it ties back to why P1-1 matters (drift is real, so cross-doc contradictions must be managed, not assumed away).

### P2-3 — No AC enforces NFR1 (each Evidence entry has a "what this proves" line for zero-context readers)
AC4 checks ≥5 existing paths but not that each path is accompanied by prose explaining what it proves (Blake lesson #3, "Knowledge Is Forged at Distill"). A bare list of 5 valid paths passes AC4 while failing the zero-context-verifiability intent. This is correctly a human-domain (Gate 4) judgment, so acceptable to leave to human — but a lightweight machine check (each Evidence bullet line contains both a path AND an em-dash/prose segment) would catch the naked-list failure before it reaches the human.

### P2-4 — Nothing in §9.1 verifies the frontmatter's `git_tracked_dirs: ["docs"]` requirement
The new file must be git-tracked at Gate 3 (frontmatter), but AC5's `grep -vE` excludes `docs/value-proposition\.md` regardless of tracked/untracked state, so a `??` untracked new file passes AC5. The Phase-4 hook reportedly enforces git_tracked_dirs, so this is covered elsewhere — just noting §9.1 alone does not assert it.

---

## Architecture / blast-radius summary
- **Blast radius: LOW.** Doc-only, no runtime/code/SKILL/hook/gate changes, fully reversible via git. Correctly identified in the handoff. No dependency, state, or migration concerns.
- **Data flow** (evidence → value-proposition.md → README summary; → OBJECTIVES wording) is sound and single-directional. No sync machinery needed for a one-shot edit.
- **Information architecture decision** (identity in its own section/doc, separate from Philosophy/mechanism) is the right call and well justified in §11.
- **Main design-completeness gap is P1-1**: scope discipline (NFR2, 3 files) was chosen over cross-doc consistency, but the resulting live contradiction (docs/TAD-OVERVIEW.md) is neither fixed nor acknowledged, so the gate can certify a positioning goal that a reader will still find violated one doc away.
- **Main verification-integrity gap is P1-2**: AC2's single count cannot detect the structural loss FR2 forbids.

Both P1s are the same underlying pattern the project's own principles warn about (count/scope that passes while the real must-cover objective is unmet). Fixing them is cheap and keeps the gate honest.
