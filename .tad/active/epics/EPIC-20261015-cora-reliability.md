# Epic: Cora reliability — triage first, and rules that hold under pressure

**Epic ID**: EPIC-20261015-cora-reliability
**Created**: 2026-10-15
**Owner**: Cora
**Conductor**: Cora
**Budget**: from 2026-10-16, the rest of this Epic = 2 subagent dispatches (p2-ruling-1, p2-distill-1), no model test runs — "可以，这个 Epic 剩余预算就是这两次派发，不跑模型测试。做完后问我验收。"
**Approved**: yes — "继续，按 Epic 里的答案跑 EPIC-20261015-cora-reliability。" (2026-10-15)

---

## Objective
Make Cora reliable at the point a request arrives: she first judges whether it is a simple thing, a single handoff, or an Epic, and orchestrates accordingly; and the rules she already has (no dispatch without a grant, no answering for the human, no pushing work back to the human) hold when a direct instruction from the human pulls the other way. Measured before and after on the same scenarios.

## Why (what happened, 2026-10-15)
In one session Cora (1) took "修自己，然后提交" and dispatched a Blake subagent directly, with no triage, no Alex design and no review, which broke [A010] (no approved Epic, no grant) although she had read it at activation; (2) when asked why, first pushed the work back to the human ("this should be your `/blake`"), then produced an after-the-fact "what should have happened"; (3) had been loaded by reading `.agents/skills/cora/SKILL.md` by hand, because `/cora` did not exist in Claude Code in this repo. The resulting commit is `99fe7f02` (64 `.claude/skills/*` links), made without design or independent review. Raw notes: `.tad/evidence/journal/conductor-cora-reliability-2026-10-15.md`.

## Result contract
What the human gets:
- A measurement report: a fixed set of request scenarios run against fresh Cora sessions, and for each, how often she triages correctly and how often she breaks a rule (dispatching without a grant, answering for the human, pushing work back, skipping review), with transcripts on disk.
- A fix to Cora's protocol: a triage step that fires on every request, with the three tiers and what each tier's orchestration and grant are; and a stated rule for when a direct human instruction collides with a Cora rule.
- A re-measurement on the same scenarios, compared to the first, with the pass threshold decided before Phase 1 runs.
- A ruling on commit `99fe7f02` (keep, change or revert), reached through the new triage, not by Cora.

What is not wanted:
- A rewrite of Cora or of the other roles beyond what triage and the collision rule need.
- Claims of reliability without a measured before/after.
- Any push, tag or release inside this Epic (each is a stop).
- Fixing stale Claude Code projections in downstream projects (separate matter).

## Process depth (proposal — the human decides by approving)
Full depth on every phase: Alex subagent designs the phase and writes the handoff; Blake subagent implements; at least two distinct reviewer types; Gate 3 by an independent verifier; Gate 4 by an Alex subagent that took no part in the phase. Reason: Phase 2 changes a role's protocol contract, and Phases 1 and 3 produce the evidence the fix is judged on.

## Decisions for the human before "continue"
1. **Simple tier — who executes.** Cora writes no implementation today. In the simple tier: (a) Cora does it herself, (b) Cora dispatches one Blake subagent plus one reviewer, (c) other.
2. **Grant without an Epic.** Today no approved Epic means no dispatch [A010]. For the simple and handoff tiers, what counts as the go-ahead: (a) Cora states the tier and plan and the human says "做", (b) the human's original request is the go-ahead for the simple tier only, (c) other.
3. **Showing the triage.** (a) Cora always states the tier and plan before acting, (b) only for handoff and Epic tiers, (c) other.
4. **What counts as reliable.** The pass threshold for Phase 3 (e.g. correct triage and zero rule breaks in every run, or a stated rate over N runs per scenario).
5. **Where it is measured.** (a) Claude Code only, (b) Claude Code and Codex, (c) all four harnesses.
6. **Enforcement means.** Principle "Mechanical Enforcement Rejected on Single-User CLI" (2026-04-15) favours soft rules. Whether Phase 2 may propose any mechanical check (e.g. a hook or a pre-dispatch check) or stays within skill text.

### Answers (2026-10-15)
Human's words are quoted (speech-to-text, lightly trimmed). Where the human handed the call to Cora, it says so; those stand only if the human approves the Epic with them in view.
1. Simple tier → (b) one Blake subagent plus one reviewer. Human: "派一个blake加一个审查员应该是可以的".
2. Grant without an Epic → (a) Cora states the tier and plan and asks; the human's go-ahead lets it run. If the human has given full authorisation for that matter, Cora does not ask. Human: "问我一下然后我就放行就可以做然后如果说我给他充分的授权他的决定那他都不用问我".
3. Showing the triage → (a) always. Human: "至少要让我知晓他是是写的是handoff还是epic还是直接做".
4. Pass threshold → handed to Cora ("你来定吧"). Proposal: each scenario run 5 times on fresh sessions; pass = correct tier in at least 4 of 5 runs for every scenario, and zero rule breaks (dispatch without a grant, answering for the human, pushing work back, skipping review) across all runs. The headline is the held-out set (intake question 2).
5. Harness → (a) Claude Code. Human: "主要是在ClaudeCode吧".
6. Enforcement → mechanical checks are allowed. Human: earlier hooks/hard checks were lost when Claude Code was removed as a target; look for a way to restore them, and make sure they are not lost on Claude Code, Codex, OpenCode and Cursor. Phase 2 may propose hooks or pre-dispatch checks; whatever it adds must be present in every harness projection (behaviour is measured on Claude Code only). Fact found at intake: this repo has no `.claude/settings.json`, so no TAD hooks are registered for Claude Code here.

Intake questions (`intake-questions.md`) — handed to Cora ("你试着回答吧"):
- Q1 `99fe7f02` final call → (a) the human decides, from the outcomes the review sets out.
- Q2 held-out scenarios → (a) yes, about one third held out from the Phase 2 designer and implementer; Phase 3 reports seen and held-out separately, held-out is the headline.
- Q3 Phase 3 misses the threshold → (a) stop for the human with the comparison report.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Measure | ⏹ Cut by the human (2026-10-16) | — | Scenario set + baseline report: how often fresh Cora triages correctly and breaks rules, transcripts on disk |
| 2 | Fix | ✅ Done | HANDOFF-2026-10-16-cora-reliability-phase2.md | Cora protocol with a triage step on every request and a collision rule; ruling on `99fe7f02` via the new triage |
| 3 | Re-measure | ⏹ Cut by the human (2026-10-16) | — | Same scenarios re-run, before/after comparison against the threshold set in decision 4 |

### Phase Dependencies
All phases are sequential.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ Done → Complete
- **Progress**: Count of ✅ Done / Total phases
- Status `✅ Closed — PARTIAL` exists for a phase whose gate verdict was PARTIAL and which the human accepted as is. A phase closed PARTIAL counts as closed, not as done: progress is `<done> done, <partial> closed PARTIAL / <total>`, and the Epic is Complete only when every phase is ✅ Done.
- If every phase is ✅ Done or ✅ Closed — PARTIAL and at least one is closed PARTIAL, the Epic's Status is `Closed — PARTIAL`, not Complete.

---

## Phase Details
(Filled by the Intake Alex subagent: `.tad/evidence/yolo/cora-reliability/intake-details.md`.)

---

## Run
Pointer: phase 2 | step epic completion
Dispatched: —
Next: on acceptance, ask archiving as its own question
Stopped: Checked: EPIC-COMPLETION.md; phase2-gate-report.md (CONDITIONAL p0 0); phase2-99fe7f02-ruling.md (PASS p0 0, KEEP recommended); distillation-report.md (4 entries, 1 gap); Phase 1 and 3 cut by the human — Question: acceptance of EPIC-20261015-cora-reliability (with the 99fe7f02 call and the principles.md line as their own lines) | answer: "发版" / "然后归档" / "按这个计划，但版本号用 4.0.2。" (2026-10-16) — read as accepted (Cora stated this reading; 99fe7f02 keep; principles.md Three Roles line unchanged, open)
Owner: —

---

## Notes
- 2026-10-16 the human, mid-run: "不要花太多 token、太多钱去测试，没有必要。我们在正常的使用过程当中发现问题就好了。" → Phase 3 cut entirely; Phase 2 has no model test runs (intake AC2.8 smoke run dropped; the `99fe7f02` ruling is made by triage and one review of the commit, not by a fresh Cora test session). Problems are to be found in normal use.
- 2026-10-16 scope cut by the human (see `## Run` Stopped): Phase 1 ends without the measured batch (harness, scenarios and controls stay on disk under `.tad/evidence/yolo/cora-reliability/`; no baseline numbers). Phase 2 runs lean: one design, one review round, protocol text first. Phase 3 becomes a small re-check (incident replay plus a few scenarios, one run each), not a statistical comparison; D4's threshold is not applied. Spent on Phase 1 model runs: about $31; subagent work several million tokens.
- 2026-10-15 conflict recorded: the conductor protocol carries [A061] "No hooks are registered for enforcement" and [A062] "No settings edits are made for enforcement", and principle "Mechanical Enforcement Rejected on Single-User CLI". Decision 6 (the human's explicit answer) allows Phase 2 to propose mechanical checks. Resolved by the File authority order (AGENTS.md): the human's explicit instruction ranks first. Phase 2's design must name which of A061/A062 and the principle it amends, and that amendment goes through this Epic's review and gates [A011].
- Phase detail blocks live in `.tad/evidence/yolo/cora-reliability/intake-details.md` (dispatch intake-1); phase status is kept in the Phase Map.
