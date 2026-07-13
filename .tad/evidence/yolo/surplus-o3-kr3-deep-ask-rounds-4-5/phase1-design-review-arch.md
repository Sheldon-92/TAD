# Phase 1 Design Review — Architecture Lens

**Handoff**: HANDOFF-surplus-o3-kr3-deep-ask-rounds-4-5.md
**Reviewer**: Backend/architecture expert (auto-detected domain)
**Date**: 2026-07-05
**Verdict**: CONDITIONAL — no P0 blockers; 2 P1 must be integrated before Blake starts.

## Domain detection

Files to Modify = two `.tad/evidence/research/*.md` findings files (doc-only, `task_type: research`,
no production code). No `.tsx/.jsx/.css`, no auth/secrets. Per the routing rule this defaults to the
**backend/pipeline architecture** lens. Here the "architecture" under review is the
research-synthesis pipeline: skill preflight → `notebooklm ask` (×2 rounds) → synthesis → 2 findings
files → grep-checkable KR bookkeeping.

## Blast radius — LOW (well contained)

- Only 2 NEW files created; NFR1 forbids edits to OBJECTIVES/SKILL/hooks/project-knowledge; the only
  sanctioned mutation is the skill's own REGISTRY.yaml `last_queried` bookkeeping.
- No code paths, no schema/API changes, no downstream consumers at runtime. A bad output is a bad
  document, recoverable by re-running; there is no data-loss or corruption surface.
- BLOCKED and honest-partial paths are both explicitly defined (§8.4, NFR2) with a hard "no web-search
  substitute" rule — good failure containment.

Containment design is sound. My findings are about **output correctness/reproducibility and the
requirement↔verifier contract**, not blast radius.

## Verified load-bearing claims (grounded, not paper-accepted)

| Claim | Result |
|---|---|
| `active_notebook` points elsewhere → `-n` mandatory | CONFIRMED: `active_notebook: "agent-computer-control"` (REGISTRY L7). The `-n` flag is genuinely required, not defensive. |
| `-n` short flag is a valid alias | CONFIRMED: CLI help shows `-n, --notebook TEXT`. |
| notebook id present exactly once | CONFIRMED: `grep -c` = 1. |
| `ask` sub-command exists | CONFIRMED: SKILL.md L271 `*research-notebook ask <question> [--notebook <id>]`. |
| Target files absent (no clobber) | CONFIRMED: both `ls` fail. |
| AC4/AC8 pipe-escape un-escapes correctly | CONFIRMED: dry-run of the un-escaped regex returns 4. |

---

## P0 — none

Blast radius is minimal and containment is well designed; no defect rises to blocking-architecture
severity.

---

## P1-1 — API spec omits conversation-state control; default `ask` CONTINUES last conversation → cross-round contamination

**Where**: §4.4 API Specifications, FR1, Micro-tasks 2 & 4.

**Evidence** (from `notebooklm ask --help`, run 2026-07-05):
> "By default, continues the last conversation. Use `--new` to start fresh."

The handoff specifies `notebooklm ask "<q>" -n 37cfefa5…` with NO conversation-state flag. Two
consequences, both hitting the core deliverable:

1. **Round 4's first ask inherits a stale/foreign conversation.** The notebook is dormant since
   2026-05-31 and `active_notebook` is a *different* notebook. `-n` selects the notebook, but the
   default conversation-continuation can splice round 4 onto whatever the last session was.
2. **Round 5 inherits Round 4's context.** FR1 insists "the round is the QUESTION" and the two rounds
   are meant to be *independent* research findings (Staleness Trap vs Human skill growth). Running
   round 5 right after round 4 in the same conversation lets round-4 framing (residue/half-life/
   hallucination-anchor) bleed into the round-5 synthesis on human skill growth — silently degrading
   the independence the whole two-file structure assumes.

Note the nuance: the *within-round* refinement asks (≤2) and skill dynamic-follow SHOULD continue the
conversation — that is desired. It is only the **first ask of each round** that must be `--new`.

**Fix**: §4.4 + FR1 must mandate `--new` on the opening ask of each round (Micro-tasks 2 and 4), and
state that refinement asks within a round continue that fresh conversation. Add an AC-level note so the
completion-report ask evidence shows the `--new` flag on the round-opening call.

## P1-2 — FR3 ↔ AC8 contract mismatch: requirement says prose "(High/Medium/Low)", verifier greps a literal `Severity:` line that no requirement mandates

**Where**: FR3 §3.1 item 3 vs AC8 §9.1 vs Data Model §4.3.

- FR3 requires `## TAD Implications` to contain "severity assessment (High/Medium/Low) with rationale".
  That is prose; nothing fixes the surface form.
- AC8 verifies `grep -cE 'Severity: (High|Medium|Low)'` ≥ 1 — a **literal `Severity: <level>` line**.
- §4.3 Data Models lists the machine-checkable invariants (H2 sections, `### SP`, `Sources:`, round
  string, notebook id) but **omits the `Severity:` line invariant entirely**.

A conscientious Blake who writes "This capability gap is High severity because…" fully satisfies FR3
and §4.3 yet FAILS AC8 → false Gate-3 failure and avoidable rework. This is exactly the
requirement/verifier drift the `ac-verification` pattern warns about.

**Fix**: promote the `Severity:` line to a stated requirement — FR3 must say `## TAD Implications`
MUST contain a line `Severity: <High|Medium|Low>` — and add it to the §4.3 invariant list so the
schema is the single source of truth the AC checks against.

---

## P2-1 — `^Sources:` anchor (AC3) collides with natural markdown formatting

FR3 says each SP ends with "a line starting `Sources:`" and AC3 greps `^Sources:`. If Blake writes the
citation naturally as `**Sources:**` (bold) or indents it under the SP as a list item, the line no
longer starts with `Sources` and AC3 silently under-counts → false FAIL. **Fix**: add an explicit
format note — the `Sources:` line MUST be plain, at column 0, no bold/indent/list-marker.

## P2-2 — AC3 is non-discriminative (global count, not per-SP)

AC3 checks `count(^Sources:) ≥ count(^### SP)` over the whole file. An SP with zero citations passes as
long as another SP carries two, and any stray `Sources:` line in `## Provenance` inflates the numerator.
So the AC can pass while a synthesis point is uncited — the precise failure it exists to catch. Per the
`ac-verification` fixture-discrimination rule, this is a weak verifier. **Fix (optional but
recommended)**: verify each SP block owns exactly one `Sources:` line (e.g., an awk per-`### SP` block
check), or at minimum scope the count to the Synthesis Points section, not the whole file.

## P2-3 — retrieval date hard-coded to `2026-07-05` in AC6 and FR3

AC6 greps the literal `2026-07-05` and FR3 fixes retrieval date to 2026-07-05. If execution slips to
2026-07-06 (dormant-notebook wake, auth re-setup, retries), the honest retrieval date differs from the
grep target — forcing either a false date to satisfy the AC (validation theater, the very thing L1
principles forbid) or a false FAIL. **Fix**: make AC6 accept the actual run date (e.g., grep for an
ISO-8601 `2026-07-0[56]` window or `date +%F` captured at run time), and phrase FR3's date as "the
actual retrieval date" rather than a frozen literal.

---

## What is well designed (keep)

- Deny-of-substitution failure path: NotebookLM failure → BLOCKED, never web-search. Matches CLAUDE.md
  §2 research-tool exclusion and the L1 validation-theater principle.
- Honest-partial path (NFR2) is first-class, with a Gate-3 status and Gate-4 human tiebreak — correctly
  routes the perception/priority judgment (severity fit) to the human as a *choice*, not a rubber-stamp
  yes/no (aligns with the 2026-07-03 AI/Human Judgment Domain principle).
- Scope containment (NFR1) + AC7 git-status check gives a clean blast-radius fence.
- Grounding is honest: the missing `phase1-grounding.md` is disclosed rather than faked.

## Summary

No P0. Blast radius is minimal and containment is well designed. Two P1s must be fixed before Blake
starts: (P1-1) mandate `--new` on each round's opening ask so the two rounds stay independent and
don't inherit a stale/foreign conversation; (P1-2) close the FR3↔AC8 severity-format contract gap so a
correct implementation can't false-FAIL. Three P2s harden the AC greps against natural-markdown drift,
non-discriminative counting, and a hard-coded date.
