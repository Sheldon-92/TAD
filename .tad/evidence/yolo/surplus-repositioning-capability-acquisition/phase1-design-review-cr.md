# Phase 1 Design Review — code-reviewer lens

**Handoff**: `.tad/active/handoffs/HANDOFF-surplus-repositioning-capability-acquisition.md`
**Reviewer**: code-reviewer (Gate 2 mandatory default)
**Date**: 2026-07-05
**Verdict**: CONDITIONAL — no blocking defects; 2 P1 AC-verifiability gaps should be fixed before Gate 3, since Gate 3 executes §9.1 verbatim and these gaps let a non-conforming doc pass.

Scope of review per instruction: file-list completeness, AC verifiability, frontmatter correctness, design coherence. All fact checks run against the real repo at HEAD.

---

## Fact checks (run on target machine)

| Check | Result |
|-------|--------|
| `grep -c '  - ' .tad/sync-registry.yaml` | 14 ✅ matches AC0c |
| `grep -c '^## O' OBJECTIVES.md` | 3 ✅ matches AC2 expectation |
| `grep -c '^## ' README.md` | 15, Philosophy@L9, Installation@L80 ✅ FR1 insertion window valid |
| AC4 awk+`grep -oE '...\x60...'` on macOS BSD grep | Works; backtick correctly excluded, paths extracted ✅ |
| OBJECTIVES tail HTML research-provenance comment | Present ✅ (edge-case 8.3 "preserve" is correct) |
| AC1 alternation with only "Devin" present | returns `1` → **passes AC1 while violating FR1** ❌ |
| `docs/` index | `docs/README.md` IS a live doc index (`## Current Documentation`) ❌ new doc not covered by scope |

Frontmatter is correctly and completely filled: `task_type: doc-only`, `e2e_required: no`, `research_required: no`, `git_tracked_dirs: ["docs"]`, `skip_knowledge_assessment: no` — all coherent for a docs-synthesis task with a new git-tracked deliverable. No frontmatter defects.

---

## P1 — Should fix (AC does not verify its own requirement)

### P1-1 — AC1 under-verifies FR1: "at least Devin AND LangGraph" collapses to "either/or"
FR1(b) mandates naming **at least these two** comparators (Devin AND LangGraph). AC1's method is
`grep -ciE 'Devin|LangGraph' README.md` with expected `≥1`. This is an OR: a positioning section
that names only Devin (or only LangGraph) returns `1` and **passes AC1 while violating FR1**
(verified above: a line with only "Devin" → count 1). Gate 3 executes AC1 verbatim, so the
requirement's core "both named as contrast" is never actually enforced.
**Fix**: split into two conjunct greps, e.g.
`grep -ci 'devin' README.md && grep -ci 'langgraph' README.md` (each expected ≥1), or
`[ $(grep -ciE 'devin' README.md) -ge 1 ] && [ $(grep -ciE 'langgraph' README.md) -ge 1 ]`.

### P1-2 — FR4 (consistency sweep) has NO verification row in §9.1
§9 states "FR1-FR4 全部实现并按 §9.1 逐行验证," but §9.1 contains no AC for FR4. Micro-task 6
maps FR4 → AC5, yet AC5 only checks `git status` scope (which files changed), not content —
it cannot detect a residual contradictory-identity sentence (e.g. "software dev framework" as the
primary identity) coexisting with the new positioning inside the same file. As written, FR4 is
mechanically unverifiable and Gate 3 will silently skip it (it is the requirement most at risk of
being half-done, since it is the "clean up the old framing" step).
**Fix**: add an AC6 with a negative grep scoped to the 3 delivery files, e.g.
`grep -niE 'software.dev(elopment)? framework|development methodology' README.md OBJECTIVES.md docs/value-proposition.md`
and require every hit (if any) to be inside a quoted/non-goal context — or expected empty. Even a
partial mechanical floor beats zero coverage. This aligns with the project-knowledge lesson that a
sweep must be scoped (FR4 already scopes to 3 files — good — it just lacks an AC).

---

## P2 — Nice to have

### P2-1 — AC4 mixes a runnable command with prose obligations
AC4's Verification Method emits the sorted unique path list but the "≥5 count" and "per-path
`test -e`" are prose, not in the pipeline. Gate 3 "executes each row" — this row is not a single
runnable pass/fail. Make it self-contained, e.g.:
`P=$(awk '/^## The Evidence/,/^## [^T]/' docs/value-proposition.md | grep -oE '(\.tad|\.claude|docs)/[^ )\x60]*' | sort -u); echo "$P" | wc -l; for p in $P; do test -e "$p" && echo "OK $p" || echo "MISSING $p"; done`
so the count and existence checks are one artifact.

### P2-2 — AC4 awk range end-pattern couples to section ordering
The range `/^## The Evidence/,/^## [^T]/` relies on the section after "The Evidence" starting with a
non-`T` letter. It works for the FR3-listed order (What / Who both start with W), but if Blake
reorders so a `## The ...`-prefixed section follows Evidence, the range over-runs. Low risk, but add
a one-line note in FR3/AC4 that Evidence must be followed by a non-`The` H2, or Blake keeps the FR3
heading order. (Verified working on current test fixture — this is a latent fragility, not a live bug.)

### P2-3 — New `docs/value-proposition.md` leaves `docs/README.md` index stale, and FR4 won't catch it
`docs/README.md` is a live documentation index (`## Current Documentation`). Adding a new doc under
`docs/` without listing it there is a real inconsistency, but NFR2 forbids touching any 4th file and
FR4's sweep is scoped to only the 3 delivery files, so nothing detects it. This is a deliberate
scope trade-off, not an omission — flagging so it is a conscious decision. Options: (a) accept and
note "index update deferred" in completion notes, or (b) expand the file list to include
`docs/README.md` (relaxing NFR2 by one line). Recommend (a) to preserve tight scope.

### P2-4 — AC4 cannot detect evidence-padding (validation-theater residue)
AC4 proves ≥5 paths exist, not that each backs a genuine cross-domain value claim (NFR1). A doc
could pad with trivially-existing paths (`docs/README.md`, `.tad/`) and still pass. This is the
YOLO-audit "validation theater" pattern and is inherently human-domain (Gate 4). No mechanical fix
expected — just confirm the completion notes present the 5 evidence rows as a **choice-style**
summary (domain — one-line outcome — path) for the human, per the handoff's own AI/Human-domain rule.

---

## Positives (worth reinforcing)
- Pre-impl baselines AC0a/AC0b/AC0c are excellent: they prove the handoff is non-empty work and were
  independently re-verified here (registry=14, headers=3).
- Scope discipline is strong and machine-enforced (AC5 git-status negative grep), matching the
  deny-list/scoped-sweep principle in project-knowledge.
- Single-source-of-truth design (value-proposition.md full text; README/OBJECTIVES = summary+link)
  correctly minimizes the drift surface (MQ5). Coherent with the stated data flow.
- Correct handling of the missing `phase1-grounding.md`: Alex substituted direct on-disk grounding
  and documented it (Gate 2 note + §7.3 + 8.4 EQUIVALENT_SUBSTITUTE). No Blake blocker.
- Edge cases (spaces in repo path, OBJECTIVES tail comment preservation, <5 evidence honest-partial)
  are all anticipated in §8.3/§10.

---

## Summary
Well-formed, tightly-scoped doc-only handoff. Frontmatter complete and correct; file list complete
for the stated scope (one conscious index-staleness trade-off, P2-3). Design is coherent with the
requirements. The only substantive issues are two AC-verifiability gaps where §9.1 fails to enforce
its own requirement: AC1 collapses FR1's "name both Devin and LangGraph" into an OR (P1-1), and FR4
has no verification row at all (P1-2). Both are cheap grep fixes and should be corrected before
Gate 3, since Gate 3 runs §9.1 verbatim.

P0: 0 | P1: 2 | P2: 4
