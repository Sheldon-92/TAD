# Phase 1 Design Review — code-reviewer lens

**Handoff**: HANDOFF-surplus-saveable-skills-from-conversation.md
**Reviewer**: code-reviewer (design review, Gate 2)
**Date**: 2026-07-05
**Verdict**: CONDITIONAL PASS — 0 P0, 1 P1, 4 P2. Well-grounded, honest handoff; one AC-state contradiction should be fixed before Gate 3 to avoid a false-FAIL/hard-block.

---

## Summary

The handoff defines a single self-contained skill (`.claude/skills/save-workflow/SKILL.md`)
that captures the just-executed conversation workflow into a local, reusable file.
Scope, file list, frontmatter metadata, and intent boundaries are clear and honest.
Grounding was verified against the live repo (I re-ran the key checks): the flat-file
non-registration precedent (`doc-organization.md` present on disk but absent from the
harness skill list) and the `name`/`description`/optional `trigger:` frontmatter
convention (`surplus/SKILL.md`) both hold. The "grounding file absent → grounded directly"
disclosure is honest and the alternatives table for the `local/` runtime-creation decision
is sound and aligns with the 2026-06-01 deny-list/copy-granularity principle.

The one real defect is an AC state contradiction (Row 8 vs Row 10 / `git_tracked_dirs`),
verified by simulation below.

---

## P0 (Blocking)

None.

---

## P1 (Should Fix)

### P1-1 — Row 8 scope guard contradicts Row 10 / `git_tracked_dirs` depending on git state

§9.1 Row 8 verifies "no framework mutation" with:
```
git status --porcelain | grep -vE '^\?\? \.claude/skills/save-workflow/|\.tad/(active|evidence)/' | grep -vE 'session-state'
```
The exclusion for the deliverable is anchored to the **untracked** porcelain form `^\?\? `.
But the handoff metadata sets `git_tracked_dirs: [".claude/skills/save-workflow"]`
("must have ≥1 git-tracked file at Gate 3") and Row 10 requires the file to be
git-tracked/staged. Once `git add` runs, the porcelain line becomes `A  .claude/skills/save-workflow/SKILL.md`,
which matches neither exclusion → it survives both `grep -v` filters → non-empty output
→ Row 8 FAILs (reports a phantom scope violation).

Verified by simulation:
- Untracked (`?? …`) → empty output → Row 8 PASS
- Staged (`A  …`) → line leaks → Row 8 FAIL

So Row 8 passes **only** in the untracked state, while Gate 3's `git_tracked_dirs` hook
and Row 10 demand the tracked state. If the file is staged-but-not-committed at verification
time (a plausible Gate 3 window), Row 8 is a guaranteed false-FAIL / hard block. It only
"self-resolves" if Blake fully commits (committed files drop out of porcelain) — but that
resolution is undocumented and fragile.

**Fix (pick one):**
(a) Broaden Row 8's deliverable exclusion to also match staged/modified forms, e.g.
`grep -vE '^(\?\?|A |AM| M|MM) \.claude/skills/save-workflow/|\.tad/(active|evidence)/'`; OR
(b) explicitly sequence the ACs: run Row 8 before `git add`, then stage/commit for Row 10,
and state that ordering in §6.1; OR
(c) require a commit (not just stage) and change Row 8 to tolerate the committed-clean state.
Option (a) is the most robust (state-independent).

---

## P2 (Nice to Have)

### P2-1 — FR1 `trigger:` frontmatter field is not covered by any AC
FR1 requires "a `trigger:` line listing `*save-workflow`", and §4.2 lists it, but no §9.1
row greps for `^trigger:`. Row 1 only checks `name` + `description`. The convention is real
(`surplus/SKILL.md` uses `trigger:`), so the field should be verifiable. Add
`grep -c '^trigger:' "$F"` ≥ 1 (and optionally that it contains `*save-workflow`).

### P2-2 — Row 3 section check is line-count based, not distinct-section based
`grep -icE '…purpose|when to use|…steps|usage instruction|gotcha'` ≥ 4 counts matching
LINES, so 4 mentions of (say) "steps" and "gotcha" alone can pass without all five sections
present. Low-severity discriminativeness gap. Consider anchoring each section header with a
per-header presence assertion (5 separate greps each ≥1) rather than one aggregate ≥4.

### P2-3 — No behavioral/functional AC (all ACs are structural greps)
Every post-impl row proves the file contains the right strings, not that the skill actually
reconstructs a workflow, derives keywords, and honors the overwrite guard at runtime. This is
the "Validation Theater" failure mode named in principles.md (YOLO Audit Findings). The
handoff §8.2 deliberately defers a real invocation to Gate-4 natural-use dogfood to avoid a
pseudo-e2e — a defensible call for a judgment-text single-file skill. Recommend a lightweight
one-shot dogfood at Gate 4 (capture one real conversation workflow, confirm overwrite guard
fires) rather than accepting greps as the sole quality signal.

### P2-4 — Description routing quality (vs future `*save-skill`) is not mechanically verifiable
FR1 wants a `description` that routes cleanly against the not-yet-built `*save-skill`. Row 1
only confirms a description exists. Routing discriminativeness is inherently non-grep-able;
flag it for the Conductor/human review lens rather than a grep AC. (Informational.)

---

## Frontmatter correctness (handoff metadata)

- `task_type: code` — correct (skill markdown treated as code for gate purposes).
- `e2e_required: no` — justified in §8.2.
- `research_required: no` — appropriate (pure authoring, no external unknowns).
- `git_tracked_dirs: [".claude/skills/save-workflow"]` — matches the sole deliverable. See P1-1 for the interaction with Row 8.
All required fields are filled.

## File-list completeness

Complete. Files to Create = the one SKILL.md; Files to Modify = none; §11 justifies NOT
pre-creating `.claude/skills/local/` (runtime-only). Bookkeeping under `.tad/` is accounted
for. No missing target files identified.

## Design coherence

Requirements (FR1-FR6, NFR1-NFR4) map cleanly to the technical design (§4) and to §9.1 rows,
with one caveat: generated `local/<name>.md` files are flat and therefore NOT auto-registered
as invokable skills — the handoff is explicit about this (§10.2: usage is Read-on-mention).
This weakens the "reusable skill" framing but is honestly scoped out; no coherence defect,
noted for the Conductor.

---

## Grounding re-verification (reviewer-run)

- `.claude/skills/doc-organization.md` exists as a flat file and is absent from the harness available-skills list → flat-file-not-registered precedent confirmed.
- `surplus/SKILL.md` frontmatter = `name:` + `description:` + `trigger:` → convention confirmed.
- `ls .claude/skills/ | grep -ic save` → 0; `.claude/skills/local` absent → baseline confirmed.
- Row 8 regex behavior simulated (untracked PASS / staged FAIL) → P1-1 confirmed.
