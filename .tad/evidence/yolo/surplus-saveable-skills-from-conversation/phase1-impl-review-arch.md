# Phase 1 Impl Review — Architecture Lens

**Task:** surplus-saveable-skills-from-conversation (YOLO Epic, Phase 1/1)
**Reviewer:** Backend/Systems Architecture expert
**Date:** 2026-07-06
**Deliverable reviewed:** `.claude/skills/save-workflow/SKILL.md` (173 lines)
**Location:** git worktree branch `wf_296b021c-f0e-5` (commit `ef93bb5`) — NOT yet on `main`
**Focus:** architecture quality, blast radius, implementation completeness

---

## Verdict: CONDITIONAL PASS

Solid, well-grounded implementation. Zero framework mutation confirmed, all §9.1
AC rows reproduce as claimed, the load-bearing architecture decision (runtime
creation of `local/` vs source-repo pre-seeding) is correct and directly avoids
the deny-list/copy-granularity clobbering failure class from principles.md
(2026-06-01). No P0. The conditions below are one P1 value-realization gap and
three P2 hygiene/quality items.

---

## What I verified (reproduced independently)

- **Blast radius = 0 framework files.** `git show --stat HEAD` in the worktree:
  exactly 2 files — the deliverable + the completion report (bookkeeping under
  `.tad/active/handoffs/`). No edits to alex/blake SKILL.md, CLAUDE.md, tad.sh,
  derive-sync-set.sh, or any `.tad/` logic. NFR2 holds.
- **`local/` NOT pre-created in source repo.** `ls -d .claude/skills/local` →
  absent on both main and worktree. NFR3 holds.
- **AC greps reproduce:** AC1 `name`=1/`description`=1/head=`---`; AC2 `3-6`=1,
  trigger-rule=5; AC3 `local: true`=3, `source: save-workflow`=1, sections=9;
  AC11 length=173. All PASS as reported.
- **Constraint (MUST) rules preserved in body** (Judgment-Only Skill principle):
  confirm-before-write, overwrite guard, no-framework-mutation, `local: true`,
  no-scripts, no-Linear-MCP, variabilize rule — all present as MUST prose, not
  weakened. Good.
- **Isolation-by-subdirectory** prevents naming collision: a captured
  `local/surplus.md` cannot shadow the framework `skills/surplus/SKILL.md`.

---

## Findings

### P1-1 — The "discoverable" success criterion is not met as built; FR3 trigger keywords are inert
- Handoff §1.2 states the success shape as a **"discoverable, reusable local
  workflow file"**, and FR3 is a headline feature: auto-detect 3–6 trigger
  keywords and embed them in the generated file's `description`.
- But the SKILL.md's own "Known behavior and limits" correctly states that
  `.claude/skills/local/*.md` files are **NOT registered by the harness** (they
  are not `dir/SKILL.md` form). Consequence: **no runtime consumer ever reads the
  embedded trigger keywords.** There is no registration, no index, and no scan
  that routes on them. The only realized invocation path is "user remembers the
  workflow name → agent Reads the file." So FR3's auto-detected keywords are
  written into a field nothing consumes — dead metadata in v1.
- Net: the feature is not *broken against its ACs* (all greps pass), but a core
  part of the stated intent ("discoverable" + trigger-based re-invocation) is
  unrealized. This is partially acknowledged as a scope boundary (promotion/
  auto-registration out of scope), yet the acknowledgment does not flag that FR3
  specifically produces no-op output.
- **Recommendation (small, in-scope for a v1.1):** have Step 5 also append a
  one-line entry to a single `.claude/skills/local/INDEX.md` (name + trigger
  keywords + path). That gives the trigger keywords an actual consumer the agent
  can Read at session start / on intent match, turning FR3 from decorative into
  functional without any harness/framework change. Alternatively, explicitly
  restate in the handoff that FR3 is forward-looking metadata for a future
  promotion step and carries no v1 runtime behavior.

### P2-1 — No agent-facing discovery surface for local workflows
- The runtime-created `local/README.md` is human-facing ("delete freely", "never
  synced"). Nothing tells a *fresh-session agent* that any local workflow exists.
  Combined with P1-1, in a new conversation the agent is blind to previously
  captured workflows unless the user names one verbatim. The INDEX.md suggestion
  above resolves both P1-1 and this.

### P2-2 — Generated-file frontmatter `description` design vs the skill's own 373-char description
- The skill's own frontmatter `description` (line 3) is a single 373-char line
  carrying a `NOT for … that is *save-skill` negation. Long, negation-laden
  routing descriptions can dilute the routing signal and occasionally mis-route
  in either direction. Not a defect (it passes AC and routes on `*save-workflow`),
  but consider tightening to the trigger-phrase core and moving the boundary
  explanation into the body (the body already has a clean boundary table).

### P2-3 — Integration hygiene: deliverable is invisible from `main`
- The deliverable and completion report exist **only** in worktree branch
  `wf_296b021c-f0e-5`; `git ls-files .claude/skills/save-workflow/` on `main`
  returns nothing. This is expected for the YOLO worktree flow (Conductor merges
  later), but there is **no pointer on main** recording that an un-merged Phase-1
  deliverable is parked in that branch. An auditor reading only `main` sees the
  design-review evidence but no implementation. Recommend the Conductor either
  merge before Gate 3 acceptance or drop a one-line pointer (branch + commit SHA)
  into the on-main evidence dir so the artifact is traceable. AC10 ("git-tracked
  at Gate 3") is satisfied *inside the worktree* only — its value on `main`
  depends on a merge step that is not yet done.

---

## Non-issues checked and cleared
- Runtime `mkdir` of `local/` in a *consumer* project is correct and does not
  re-introduce the sync-clobber risk, because the source repo never ships a
  `local/` dir for `cp -R src/. tgt/` to overwrite. The §11 decision is sound.
- The `save-workflow/` skill dir itself *will* sync downstream — that is intended
  (it is a framework capability), not a blast-radius leak.
- FR2's inputs/preconditions + outputs are folded into the template's
  "When to use" / "Usage instructions" sections rather than dedicated headings;
  acceptable, not a completeness gap.
- No executable scripts/hooks; instruction-markdown only (NFR1). Confirmed.

---

## Summary
P0: 0 · P1: 1 · P2: 3. Architecture and blast radius are clean; the one
substantive item is that the feature's "discoverable / trigger-based re-invocation"
intent is not realized in v1 because local files have no runtime consumer — a
small, in-scope INDEX.md addition would close it. The rest are hygiene/quality.
Conductor must still run a compliant Gate 3 (incl. Knowledge Assessment) and
resolve the main-branch integration/traceability of the worktree artifact.
