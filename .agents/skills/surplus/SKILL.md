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

## Workflow availability

仅当你自己的可用工具里有 Workflow 工具时才走 workflow（在 Claude Code 里，工具列表中看不到 Workflow 时，先用 ToolSearch 查 `select:Workflow`，查不到再判定没有）；没有——Codex、Cursor、OpenCode、以及任何子代理都属于这种情况——就走下面的 WORKFLOW-FALLBACK。不要用 `detect-platform.sh` 的输出来判断：它在 Claude Code 的子代理里同样返回 `claude-code`。
会话工作目录不是项目根时，不要启动本 workflow：先切换到 `git rev-parse --show-toplevel` 的输出（或请用户在项目根重开会话），再按相对路径调用——workflow 脚本内部的证据、模板与 args 路径都以项目根为基准。
WORKFLOW-FALLBACK: 没有 Workflow 工具 → 明说「*surplus 在本 harness 不可用」并停止；不做静默降级。

## Commands

### `*surplus --plan`  (and bare `*surplus`)

1. **Stamp the date.** Compute today's date string `YYYY-MM-DD` (the date lives at this
   SKILL boundary so the workflow stays free of `Date.now()` / `new Date()`). Call it
   `<stamp>`. Use the **same** `<stamp>` for the filename and the artifact header.
2. **Invoke the scan workflow:**
   ```
   Workflow({
     scriptPath: '.tad/workflows/claude/surplus-scan.workflow.js',
     args: {
       date: '<stamp>',
       output_path: '.tad/active/SURPLUS-PLAN-<stamp>.md'
     }
   })
   ```
3. **Persist the two artifacts.** Determine the diff baseline `prev` BEFORE
   writing anything: the newest existing `.tad/active/SURPLUS-PLAN-*.json`. If
   its stem equals this run's target stem (a same-day re-run), copy it to a
   temporary prev file first — the persist below overwrites that path, and the
   diff must never compare this run against itself. If no prior sidecar exists,
   `prev` is the literal `NONE`. Then persist: the workflow runtime is sandboxed (no filesystem
   access), so it returns the rendered content. Write them yourself with the Write tool:
   - `result.plan_markdown` → `result.plan_path`  (`.tad/active/SURPLUS-PLAN-<stamp>.md`)
   - `result.sidecar_json`  → `result.json_path`  (`.tad/active/SURPLUS-PLAN-<stamp>.json`)
   The `.json` sidecar is the **Phase-2 contract** — Phase 2 reads JSON, never the Markdown.
4. **Append the qualification-flip alarm section.** Run
   `node .tad/scripts/surplus-plan-diff.mjs <prev|NONE> .tad/active/SURPLUS-PLAN-<stamp>.json`
   and append its stdout (the `资格翻转告警` alarm section, or the no-baseline line on a
   first run) to the end of the plan `.md` just persisted. This runs on EVERY
   `--plan`: eligibility flips between rounds are named in the plan itself,
   never silent.
5. **Display** the ranked plan table + the totals summary (total / dropped / stale /
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
     scriptPath: '.tad/workflows/claude/surplus-execute.workflow.js',
     args: {
       sidecar_rows: <parsed JSON .rows array>,
       date: '<stamp>',
       repo_root: '<absolute path of this repo root>',
       budget_total: <the numeric budget parsed in step 1>,
       fallback_agent_estimate_tokens: 20000
     }
   })
   ```
   `repo_root` is required and must be absolute — the workflow fail-closes
   without it (a defaulted root would silently write outside the repo).
   `budget_total` is required on runtimes with no native budget global
   (the workflow then runs a local ledger against it). `fallback_agent_estimate_tokens`
   is the per-agent-call estimate the ledger charges when a runtime reports
   no usage figure; omit it to default to the 250K reserve.
5. **Persist the report.** Write `result.report_markdown` to `result.report_path`
   (returned as an absolute path anchored at `repo_root`; repo-relative form
   `.tad/active/SURPLUS-REPORT-<stamp>.md`).
6. **Display summary:**
   - Executed: N tasks (tokens spent)
   - Failed: N tasks (skipped)
   - Needs You: N tasks (SAFETY holds + branch-0 reroutes)
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
- **Budget guard**: the workflow probes the runtime budget global at Validate.
  Where it exists, it delegates verbatim (stops when remaining < 250K reserve);
  where it is absent, it runs a local ledger against the `budget_total` arg with
  the same reserve and circuit-breaker semantics, and marks totals estimated
  with `(ledger est.)` when any charge was an estimate.
- **Ledger mode limit**: Ledger mode cannot drive the nested step runner: budget='ledger' with steps='nested' throws at Validate ("ledger mode does not support nested workflow").
- **Runtime-requirements probe （探针）**: both workflow scripts declare their `runtime-requirements:` in the header and probe them at entry (existence-only, before any agent activity) — a missing hard requirement (`agent` / `phase`) throws naming the missing global and stops the run cold, while a missing facade-covered global (`budget` / `workflow`) only logs a degradation line and continues on its designed fallback.
- **Run integrity (live verification runs)**: when surplus-execute is run
  for verification (Gate replays, acceptance runs), invoke a byte-identical
  copy of the workflow file kept in the chain's evidence directory, never
  the in-repo original; record the copy path and the original's sha256
  before/after in the run record, and stop on any mismatch.
- **yolo-epic contract**: 7 required keys (epic_path, epic_slug, phase_number, phase_name, handoff_path, completion_path, steps), result.error/stop_reason for failures (no try/catch); see yolo-execution-protocol.md, result.error/stop_reason for failures (no try/catch)
