# Epic: Installer — does a downstream update nest skills as `.agents/skills/alex/alex/`?

**Epic ID**: EPIC-20261016-installer-skill-nesting
**Created**: 2026-10-16
**Owner**: Cora
**Conductor**: Cora
**Tier**: handoff (one-phase Epic, Cora triage 2026-10-16)
**Budget**: 10 subagent dispatches (intake, design, 2 design reviews, implementation, 2 implementation reviews, Gate 3, Gate 4, distillation); no model test runs. If the investigation finds no installer bug, the run ends after design with a report.
**Approved**: yes — "按 handoff 档查清 alex/alex 嵌套是不是安装器 bug，是就修，控制花费。修完再问我发版。" (2026-10-16)

---

## Objective
Find out whether TAD's installer/updater produces a nested skill layout (`.agents/skills/<name>/<name>/SKILL.md`) in downstream projects, as seen in a downstream project on 2026-10-16 (`.agents/skills/alex/alex/references/conductor-dispatch-mode.md` existed, `.agents/skills/alex/references/...` did not). If it is an installer bug, fix it so that updating a downstream project to the next TAD release leaves a flat layout (and repairs an already-nested one). If it is not, say what caused it.

## Result contract
What the human gets: the cause, with the evidence; if it is an installer bug, a local commit that fixes it, with the verification that a reproduced install/update yields `.agents/skills/<name>/SKILL.md` and no `<name>/<name>`.
Not wanted: any change to a downstream project; push, tag or release (each asked separately afterwards); model test runs; unrelated installer refactors.

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Investigate and fix | ✅ Done | HANDOFF-2026-10-16-installer-skill-nesting-phase1.md | Cause of the nesting; if an installer bug, the fix and its verification |

### Phase Dependencies
One phase.

---

## Phase Details
(Filled by the Intake Alex subagent: `.tad/evidence/yolo/installer-skill-nesting/intake-details.md`.)

---

## Run
Pointer: phase 1 | step epic completion
Dispatched: —
Next: on acceptance, ask the release (merge, push, version) as its own question; archive asked separately
Stopped: Checked: EPIC-COMPLETION.md; phase1-gate-report.md (PASS p0 0); phase1-gate3-verdict.md (CONDITIONAL p0 0); commit b3cfb28f; distillation-report.md — Question: acceptance of EPIC-20261016-installer-skill-nesting | answer: "发版" / "然后归档" / "按这个计划，但版本号用 4.0.2。" (2026-10-16) — read as accepted (Cora stated this reading; 99fe7f02 keep; principles.md Three Roles line unchanged, open)
Owner: —

---

## Notes
- Downstream evidence (from the human's screenshot, 2026-10-16): in a downstream project, `.claude/skills/alex/SKILL.md` was a 2026-09-22 copy with no Cora; `.agents/skills/cora/` existed (uncommitted, 20:05); the conductor dispatch-mode file was at `.agents/skills/alex/alex/references/`. The downstream project's path is not known to Cora; the investigation reproduces the layout from TAD's own installer instead.
