# EPIC-20260607: Surplus Usage Burn Mode (`*surplus`)

**Created:** 2026-06-07 · **Owner:** Alex · **Status:** (derived from Phase Map)

## Objective

Give Alex a mode that, on demand, finds the **highest value-density** work across
TAD's own backlog + auto-generated directions, then autonomously executes as much of
it as a user-supplied budget allows — turning surplus weekly Claude usage into
durable, reviewed deliverables instead of idle quota.

**Value anchor (from Socratic 2026-06-07):** value-first, consumption-as-result.
NOT token-burning theater. Every executed task must cite a concrete deliverable/AC.

## Success Criteria

- [ ] `*surplus --plan` produces a ranked, value-density-scored task list from real backlog
- [ ] `*surplus +<budget>` autonomously executes top safe-to-YOLO tasks until budget exhausted, then reports
- [ ] SAFETY-tagged work (principles.md, SKILL SAFETY zones, security, deletes) is NEVER auto-executed — routed to a "needs you" list
- [ ] Expert review (Gate 2/3) is NOT skipped for any executed task (AR-001 hard rule)
- [ ] A dogfood run completes ≥1 real backlog task end-to-end and archives it
- [ ] Zero regression to existing `*analyze`/`*accept`/YOLO flows

## Design Constraints (locked by Socratic)

| Dimension | Decision |
|-----------|----------|
| Goal | Value-first AND consumption — value/token density ranking |
| Sources | existing backlog + Alex-generated new directions + research/self-evolution. **NOT cross-project.** |
| Autonomy | full-auto a batch → single acceptance digest |
| Budget | run-to-budget-ceiling; budget is an **invocation-time parameter**, not built-in |

## Architecture (minimal core intrusion)

```
*surplus  (.claude/skills/surplus/SKILL.md)
   │
   ├─ scan ──▶ surplus-scan.workflow.js   (fan-out readers + OBJECTIVES generator → dedup → value-score → ranked plan)
   │                                         reuses loop-discover fan-out pattern
   ├─ (--plan stops here: human reads SURPLUS-PLAN-{date}.md)
   │
   └─ execute ▶ surplus-execute.workflow.js  (budget loop: pick top safe task → run yolo-epic.workflow.js → repeat
                                               until budget.remaining() < per-task reserve → report)
```

Backlog sources scanned: `.tad/active/ideas/`, `.tad/active/dream-candidates/`,
`.tad/active/epics/` (parked/planned phases), `NEXT.md` (pending), `.tad/evidence/proposals/`.
Generation source: `OBJECTIVES.md` (esp. O2) + completed-asset awareness (capability packs).

## Phase Map

| Phase | Name | Status | Handoff |
|-------|------|--------|---------|
| 1 | Scan + Value-Score + Ranked Plan (`*surplus --plan`) | ✅ Done | HANDOFF-20260607-surplus-scan-phase1.md (commits d3dbc32, 6776d85) |
| 1.1 | Fix `undated` filename (SKILL owns output path) + AC1 verifier note | ⬚ Planned | (quick-fix — see Context) |
| 2 | Budget-Loop Auto-Execution + Safety Routing + Report + Dogfood | ⬚ Planned | (TBD after Phase 1.1) |

---

## Phase Detail Blocks

### Phase 1: Scan + Value-Score + Ranked Plan

**Status:** ⬚ Planned

**Scope:** Build the read-only "find & rank" half. A workflow fans out over all backlog
sources (one reader per source type) + one generator agent (OBJECTIVES + assets) → each
returns candidate tasks → dedup → score each by value-density → write a ranked
`SURPLUS-PLAN-{date}.md`. A minimal `surplus` SKILL wires `*surplus --plan` (scan only,
NO execution). NOT in scope: any auto-execution, budget loop, file mutations beyond the plan artifact.

**Input:** backlog source files + OBJECTIVES.md (read-only).
**Output:** `SURPLUS-PLAN-{date}.md` (ranked candidates with value/cost/risk/density columns) +
`surplus` SKILL (scan path) + `*surplus` command registered in alex.

**AC:** see Phase 1 handoff §9.1.

**Files Likely Affected:**
- CREATE `.claude/workflows/surplus-scan.workflow.js`
- CREATE `.tad/templates/surplus-plan-template.md`
- CREATE `.claude/skills/surplus/SKILL.md` (scan path only; execute path = "Phase 2 — not yet wired")
- MODIFY `.claude/skills/alex/SKILL.md` (commands table + on_start menu — ONE-LINE add each; NOT a SAFETY zone)

**Dependencies:** none (standalone, read-only — safe to ship before Phase 2).

### Phase 2: Budget-Loop Auto-Execution + Safety Routing + Report

**Status:** ⬚ Planned

**Scope:** Add `surplus-execute.workflow.js` — a budget-guarded loop that picks the top
safe-to-YOLO candidate from the Phase 1 plan, runs it through the standard TAD pipeline via
`yolo-epic.workflow.js` (design→review→implement→impl-review→gate), tracks `budget.spent()`,
and stops when `budget.remaining() < per_task_reserve`. SAFETY-tagged candidates are skipped
to a "needs you" list. Circuit breaker: max 2 retries → honest_partial → next. Final unified
acceptance digest. Then a dogfood run on ≥1 real backlog task.

**Input:** Phase 1 ranked plan + invocation budget (`+<N>`).
**Output:** executed+archived tasks + `SURPLUS-REPORT-{date}.md` digest.

**Dependencies:** Phase 1 complete.

---

## Context for Next Phase

**Phase 1 accepted 2026-06-08.** Delivered: `surplus-scan.workflow.js`, `surplus` SKILL (scan path),
`surplus-plan-template.md`, `*surplus` registered in alex. Live Gate 3 run scanned the real backlog →
**53 ranked candidates** (24 auto-eligible, 19 needs-human, 0 vacuous-dropped). Artifacts:
`.tad/active/SURPLUS-PLAN-2026-06-08.md` + `.json` sidecar (53 structured rows — the Phase-2 contract).

**Verified working:** value-first ranking (live: value-5/cost-L #9 ranks above higher-density items),
mechanical SAFETY tagging (19 needs-human), read-only guarantee (backlog unmodified), JSON sidecar consumable.

**Carry-forward fixes for Phase 1.1 (do before Phase 2):**
1. **`undated` filename bug (P2):** the `date`/`output_path` args did not propagate to the workflow in
   direct invocation → `dateStamp` defaulted to `'undated'` (filename + markdown header). Robust fix:
   the SKILL should OWN the output filename (write to its own stamped path), treating the workflow's
   `plan_path` as advisory. Without this, every `*surplus --plan` overwrites `SURPLUS-PLAN-undated.md`.
   (Workaround applied this run: Conductor wrote artifacts to the correct dated path manually.)
2. **AC1 verifier defect (P2):** `node --check` false-FAILs ALL workflow files (top-level `return`).
   Replace with a wrapped-body check in any future workflow AC. (Same latent issue: epic-audit.workflow.js:80
   has a top-level-array schema that will 400 if ever run live — fix opportunistically.)

**Phase 2 inputs ready:** the JSON sidecar carries `risk_tag`/`safety_flag`/`cost_numeric`/`expected_value`/
`density`/`auto_eligible` per row — a budget loop can filter `auto_eligible===true`, sort by `expected_value`,
sum `cost_numeric` against budget. Generated items are pre-tagged never-auto-eligible.
