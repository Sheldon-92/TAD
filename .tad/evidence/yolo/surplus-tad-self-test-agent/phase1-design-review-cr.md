# Phase 1 Design Review — code-reviewer lens
**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-tad-self-test-agent.md` (v3.1.0)
**Reviewer:** code-reviewer (YOLO Epic Phase 1 design review)
**Date:** 2026-07-06
**Verdict:** CONDITIONAL — 2 P0 must be resolved before implementation

---

## Scope reviewed
§4 Technical Design, §6 Implementation Steps, §7 File Structure, §9.1 Spec Compliance
Checklist (16 rows), frontmatter. Grounding facts spot-checked live against the repo.

## Grounding verification (spot-check PASSED)
Confirmed accurate against disk on 2026-07-06:
- PRE1/PRE2 true: `tad-self-test.workflow.js` and `.tad/eval/self-test/` do not exist.
- Live trace vocabulary matches §2.1: `gate_result, handoff_created, evidence_created,
  expert_review_finding, task_completed, step_start, decision_point` + others all present.
- `Object.keys(args)` = 1 in loop-discover; `title:`-per-phase is the real corpus convention;
  `budget.remaining()` guard confirmed at loop-discover L96.
- `socratic_inquiry_protocol:` exists in alex/SKILL.md (L1064); 14 "socratic" mentions total.
Grounding quality is strong and the "grounding file missing → grounded against disk instead"
disclosure is honest. Good.

Frontmatter completeness: `task_type: code`, `e2e_required: yes`, `research_required: no`,
`skip_knowledge_assessment: no`, `git_tracked_dirs` all filled. **PASS.**

File list (§7.1) completeness: 8 files, matches the design; `.gitignore` + `.gitkeep` present.
One omission noted in P2-2 (mutated-SKILL fixture).

---

## P0 — Blocking

### P0-1: AC14 (the primary red/green discriminative proof) has no valid owner
AC14 text assigns the dual live run to Blake: *"Blake 在 completion report 粘贴两个 run 的原始
verdict 输出 + 两个 run dir 路径"*. But §8.4 row 1 and §10.1 explicitly forbid Blake from
live-running the workflow ("sub-agents cannot invoke Workflows") and assign live runs to the
Conductor. The §9.1 footer only defers **AC13** to the Conductor — AC14 is silently left on
Blake, who cannot execute it.

Consequence: FR2b's discriminative proof (the one thing that separates this tool from
Validation Theater) is unexecutable by the handoff's owner. Gate 3 would either be blocked or,
worse, "passed" on a fabricated verdict.

**Fix:** Reassign AC14 to the Conductor live test-run alongside AC13; update the §9.1 footer
and §8.4 to list AC14 as Conductor-owned; state Blake's completion report references the
Conductor run rather than producing it. If any part of AC14 is Blake-runnable (e.g. verifier
against a hand-crafted "socratic-stripped" observed trace), split that out as a separate
Blake-ownable AC so the red/green intent still gets a mechanical check at Gate 3.

### P0-2: Event-derivation mechanism contradicts FR2's no-enumeration rule (core detection gap)
The trace-append mechanism (§4.2 A "Execute", §4.3) appends an event **only if the matching
artifact exists via `test -f <hardcoded filename>`** — e.g. `socratic-qa.md`, `acceptance.md`,
`synthetic-handoff.md`. But FR2 mandates the agent prompts contain **no artifact list** and
every step must emerge from the agent reading the SKILL. Verified against the SKILLs:
- blake/SKILL.md **does** mandate `completion-report.md` (L1610) → derivable. OK.
- alex/SKILL.md does **not** mandate `socratic-qa.md`, `acceptance.md`, or any exact socratic
  artifact name → the SKILL-driven synthetic-alex will not reliably produce a file with the
  hardcoded name the workflow greps for.

Consequence: on the GREEN path, `test -f runDir/socratic-qa.md` fails because the agent named
its socratic evidence something else → the socratic event is never appended → GREEN yields
`MISSING: socratic` (false FAIL), making AC14-GREEN unpassable without fudging the fixture.
This is the load-bearing design question and it is unresolved: **how does the workflow map an
emergent (un-enumerated) protocol step to a named artifact it can `test -f`?**

**Fix (pick one, specify it):** (a) derive events from the agent's **structured return**
(`artifacts_written[]`, `gates_run[]`) as the primary signal and use `test -f` only against
the paths the agent itself reports — not against workflow-invented names; or (b) have the
append step scan `runDir` for ANY file whose content matches a per-step content signature
(e.g. contains "Socratic" Q&A), not a fixed filename; or (c) explicitly narrow FR2 to permit
naming the *output directory contract* while still forbidding step enumeration. Whichever is
chosen must be reconciled with §4.3's hardcoded filenames.

---

## P1 — Should fix

### P1-1: Hermetic run of the real SKILL has no human for Socratic / Gate 1
alex/SKILL.md's `socratic_inquiry_protocol` (L1064) and Gate 1 elicitation are human-blocking
by design (⚠️ BLOCKING per principles.md rule 0). The synthetic run is hermetic (NFR3, no
human). The GREEN path (AC14) requires synthetic-alex to **complete** the Socratic step with no
human to answer. The design never specifies how: does the workflow inject a stub "human"
answerer? auto-answer? If unspecified, synthetic-alex will either stall or fabricate answers —
either way GREEN becomes non-deterministic and the red/green signal is untrustworthy.
**Fix:** specify the synthetic-human substitute (e.g. a fixed answers fixture the design agent
is pointed at) and note it does not violate FR2 (it is task input, not step enumeration).

### P1-2: Verifier pattern overlap — a missing implementation event is masked by socratic
In §4.2 B, `socratic` matches fixed-string `socratic` and `implementation` matches
`"type":"evidence_created"`. Per §4.3 the socratic event **is** an `evidence_created` line
(`"context":"socratic"`). So one socratic line satisfies BOTH steps. If the real implementation
deliverable event is absent, `grep -cF '"type":"evidence_created"'` still returns ≥1 → the
`implementation` step falsely passes. The FAIL fixture (gate_3 + 1-expert) does not exercise
this collision, so the hole ships untested.
**Fix:** make the `implementation` pattern discriminating (e.g. match `"context":"deliverable"`
or a distinct type), and add a fixture that drops the deliverable event while keeping socratic.

### P1-3: AC15 is not mechanically verifiable as written
AC15's command `grep -ciE 'socratic|gate [0-9]|write.*handoff' <workflow>` will hit structural
code (the trace-event constants that reference `"Gate N"` contexts, the verifier call, the
expected-trace path) and therefore return **>0**. The AC then requires a **human** to classify
each hit as "prompt string vs structural code" and asserts "prompt hits = 0". A gate that
depends on human classification of grep output is not a mechanical check and can rubber-stamp.
**Fix:** structure the workflow so agent prompts are built from a single named constant/array
(e.g. `PROMPTS`) and grep only that region, or extract prompts to a separate section the AC can
scope to. Then the "= 0" assertion is mechanical.

### P1-4: No AC verifies the SKILL_PATH_ALEX / SKILL_PATH_BLAKE override wiring that AC14 depends on
FR2 introduces `SKILL_PATH_ALEX` / `SKILL_PATH_BLAKE` CONST defaults (arg-overridable), and
AC14-RED runs "with SKILL_PATH_ALEX pointing at the mutated copy." But AC2 only asserts
`FIXTURE_PATH|EXPECTED_TRACE_PATH|RUN_ID` consts exist — nothing asserts SKILL_PATH_ALEX is
declared as a const AND wired into the `Object.keys(args)` override loop. If Blake omits the
override wiring, AC14-RED silently cannot point at the mutated SKILL, and the failure surfaces
only during the Conductor run.
**Fix:** extend AC2 (or add an AC) to assert both SKILL_PATH consts exist and are handled in the
args-override loop.

---

## P2 — Nice to have

### P2-1: UNEXPECTED logic will false-flag the most important events
§4.2 C defines UNEXPECTED as "observed `"type"` values not appearing in any expected pattern."
But the gate patterns match on **context** (`"context":"Gate 1`), not type — so the
`gate_result` type appears in **no** expected pattern and would be reported `UNEXPECTED:
gate_result`. Non-failing, but noisy enough to train the reader to ignore UNEXPECTED — the very
anti-pattern the deny-list/version-sweep knowledge warns against.
**Fix:** compute the expected TYPE set (derive from patterns or add a type column) and flag
UNEXPECTED only against that.

### P2-2: mutated-alex-SKILL.md fixture is not in the file list and not gitignored
AC14/FR2b create `.tad/eval/self-test/fixtures/mutated-alex-SKILL.md` at run time. It lives
under `.tad/eval/self-test/` (a `git_tracked_dir`), is not in §7.1, and `.gitignore` only
excludes `runs/*`. A sed-stripped copy of the real alex SKILL would show in `git status` and
risk being committed.
**Fix:** add `fixtures/mutated-*` to `.tad/eval/self-test/.gitignore` and note the fixture as a
generated artifact.

### P2-3: The provided sed strip likely won't reach `grep -c socratic = 0`
AC14-RED's `sed '/socratic_inquiry_protocol/,/^# /d'` removes one block, but alex/SKILL.md has
14 "socratic" mentions; residual references may let synthetic-alex still perform the step,
producing a false GREEN on the RED run. The AC's `grep -c socratic = 0` gate catches this, but
the provided command will not satisfy it — Blake needs a broader strip. Flag so it is not
mistaken for copy-paste-ready.

### P2-4: AC1 `grep -c "title:"` is formatting-brittle
It counts lines containing `title:` and assumes one phase per line (true in the corpus). Fine
today; if phases are ever inlined the count breaks. Low priority.

---

## Strengths (reinforce)
- Genuine fixture discrimination pair (PASS + FAIL with two failure classes) — not PASS-only.
- Double hermetic defense (AC8 code-text grep + AC13 runtime before/after diff).
- Evidence-based principle (structured return AND `test -f`, not self-report) is the right
  instinct — P0-2 is about making it *implementable*, not wrong in spirit.
- Standalone bash verifier so the testable core gets a real Blake e2e today (§4.1 rationale is
  sound and correctly anticipates the sub-agent-can't-run-workflow constraint).
- Honest grounding disclosure about the missing Conductor grounding file.

## Recommended next step
Resolve P0-1 (reassign AC14 to Conductor + split any Blake-runnable slice) and P0-2 (specify the
emergent-step → artifact mapping) in the handoff before implementation. P1-1..P1-4 should be
folded in during the same edit since they cluster around the same live-run/SKILL-driven surface.
