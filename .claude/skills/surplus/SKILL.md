---
name: surplus
description: "Surplus Burn Mode — find + rank the highest value-density backlog work to consume unused Claude usage productively. Phase 1 (--plan) scans and ranks. Phase 2 (+<budget>) auto-executes ranked tasks within a budget envelope (SAFETY tasks routed to needs-you list)."
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

### `*surplus +<budget>`  (e.g. `*surplus +500K`, `*surplus +2M`)

**Phase 2: Auto-execute ranked surplus tasks within a budget.**

1. **Parse budget.** Extract the numeric value: `+500K` → 500000, `+2M` → 2000000.
   If the format is unrecognized, print an error and stop.
2. **Read the latest sidecar:**
   ```
   ls -t .tad/active/SURPLUS-PLAN-*.json | head -1
   ```
   Parse the JSON. If no sidecar exists, tell the user to run `*surplus --plan` first.
3. **Stamp the date.** Same `YYYY-MM-DD` stamping as `--plan`.
4. **Invoke the execution workflow:**
   ```
   Workflow({
     scriptPath: '.claude/workflows/surplus-execute.workflow.js',
     args: {
       sidecar_rows: <parsed JSON .rows array>,
       date: '<stamp>'
     }
   })
   ```
5. **Persist the report.** Write `result.report_markdown` to `result.report_path`
   (`.tad/active/SURPLUS-REPORT-<stamp>.md`).
6. **Display summary:**
   - Executed: N tasks (tokens spent)
   - Failed: N tasks (skipped)
   - Needs You: N SAFETY tasks
   - Point user to the full report path.

## Hard boundaries (Phase 1)

- **No execution.** This mode never picks up a ranked item and works on it. It only
  scans, ranks, and reports.
- **No mutation** of backlog sources (`.tad/active/ideas/`,
  `epics/`, `NEXT.md`, `OBJECTIVES.md`). Read-only.
- **Exactly two writes:** the plan `.md` and its `.json` sidecar, both under
  `.tad/active/` at the `SURPLUS-PLAN-<stamp>` stem. Any other write is a violation.
- **auto_eligible is advisory only** in Phase 1 — it flags what *would* be safe to
  auto-run later. Phase 1 runs nothing regardless of the flag.

## Phase 2 — Budget-Loop Auto-Execution

Phase 2 is **wired** via `*surplus +<budget>`. It reads the JSON sidecar, filters
auto-eligible rows (SAFETY tasks routed to "needs-you"), synthesizes ephemeral
Epics, and runs each through yolo-epic within the budget envelope.

Key safety properties:
- **SAFETY zero-execution**: `safety_flag === true` tasks are never executed (strict equality)
- **Sidecar validation**: fail-closed (throw on malformed rows, not silent skip)
- **Circuit breaker**: 3 consecutive failures → stop loop
- **Budget guard**: stops when `budget.remaining() < 250K` reserve
- **yolo-epic contract**: 7 explicit keys, result.error/stop_reason for failures (no try/catch)
