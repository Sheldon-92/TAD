---
name: surplus
description: "Surplus Burn Mode — find + rank the highest value-density backlog work to consume unused Claude usage productively. Phase 1 (--plan) is a READ-ONLY scan: it surfaces a ranked plan + JSON sidecar and executes NOTHING. Auto-burn execution is Phase 2 (not yet wired)."
trigger: "*surplus, *surplus --plan, *surplus +<budget> (e.g. +2M), or user asks to surface highest-value backlog work to use up surplus usage."
---

# Surplus Burn Mode — Phase 1 (Scan + Rank)

> **Read-only.** Phase 1 does **NO execution** and **NO mutation** of any backlog source.
> It writes **exactly two artifacts**: the ranked plan (`.md`) and its machine-readable
> sidecar (`.json`). Nothing else on disk changes.

## What this mode does

Scans TAD's backlog sources + one OBJECTIVES-driven generator, ranks every candidate
**value-first** (expected_value = value × confidence; density is only an efficiency
tiebreaker), tags risk/safety, and produces a ranked plan you can act on to consume
unused weekly Claude usage on the highest-value work.

It does **not** pick anything up and run it. Choosing what to execute (and actually
executing it) is **Phase 2** — see below.

## Commands

### `*surplus --plan`  (and bare `*surplus`)

1. **Stamp the date.** Compute today's date string `YYYY-MM-DD` (the date lives at this
   SKILL boundary so the workflow stays free of `Date.now()` / `new Date()`). Call it
   `<stamp>`. Use the **same** `<stamp>` for the filename and the artifact header.
2. **Invoke the scan workflow:**
   ```
   Workflow({
     name: 'surplus-scan',
     args: {
       date: '<stamp>',
       output_path: '.tad/active/SURPLUS-PLAN-<stamp>.md'
     }
   })
   ```
3. **Persist the two artifacts.** The workflow runtime is sandboxed (no filesystem
   access), so it returns the rendered content. Write them yourself with the Write tool:
   - `result.plan_markdown` → `result.plan_path`  (`.tad/active/SURPLUS-PLAN-<stamp>.md`)
   - `result.sidecar_json`  → `result.json_path`  (`.tad/active/SURPLUS-PLAN-<stamp>.json`)
   The `.json` sidecar is the **Phase-2 contract** — Phase 2 reads JSON, never the Markdown.
4. **Display** the ranked plan table + the totals summary (total / dropped / stale /
   auto-eligible / needs-human) and point the user at the `🔒 Needs You` section.

### `*surplus +<budget>`  (e.g. `*surplus +2M`)

Print exactly:

> ⏳ Auto-execution is Phase 2 — not yet wired. Showing ranked plan only.

…then run the **same scan path** as `*surplus --plan` (steps 1–4 above). The budget
argument is accepted but ignored in Phase 1 — there is no execution path to budget yet.

## Hard boundaries (Phase 1)

- **No execution.** This mode never picks up a ranked item and works on it. It only
  scans, ranks, and reports.
- **No mutation** of backlog sources (`.tad/active/ideas/`,
  `epics/`, `NEXT.md`, `OBJECTIVES.md`). Read-only.
- **Exactly two writes:** the plan `.md` and its `.json` sidecar, both under
  `.tad/active/` at the `SURPLUS-PLAN-<stamp>` stem. Any other write is a violation.
- **auto_eligible is advisory only** in Phase 1 — it flags what *would* be safe to
  auto-run later. Phase 1 runs nothing regardless of the flag.

## Phase 2 (not in this SKILL)

Auto-burn execution — reading the `.json` sidecar, selecting auto-eligible rows within a
budget, and running them through the TAD pipeline — is **Phase 2** and is **not yet
wired**. Until then, any budget argument only prints the Phase-2 notice above.
