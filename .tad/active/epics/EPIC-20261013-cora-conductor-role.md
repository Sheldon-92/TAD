# Epic: Cora — a third TAD role: the human's entry point and the conductor (A-B-C)

**Epic ID**: EPIC-20261013-cora-conductor-role
**Created**: 2026-10-13
**Owner**: Alex
**Conductor**: Cora (from 2026-10-14, Phase 3 close onward; taken over with the human's answer)
**Approved**: yes — "继续我要把整个流程整个都完成啊" (2026-10-14; reply to Cora: 回"继续"：今天这段的结果就按现在这样收下，我接手原来那个大 Epic，一路跑下去。中途只在三个地方停下来找你：README 开头给你两三种写法挑一个；push 前让你确认；发布前让你确认)
**Map status**: APPROVED — by the human (Sheldon), 2026-10-13, in conversation with Alex; the version approved is the four-phase map below (Cora herself / Wiring / Real run / Release), with the release treated as a major one.

---

## Objective

Add a third role, **Cora**: Alex designs, Blake executes, Cora is the one the human talks to
and the one who dispatches. Alex today carries two kinds of work — work that faces the human
and the project, and work that faces the technology. The first kind moves to Cora; Alex keeps
the second. The human discusses direction with Cora, agrees a result with her, and gets the
finished work back; Alex, Blake, reviewers and gates run as subagents that Cora dispatches.

**Who the human goes to**

- What to do, why, whether to do it, what comes next → Cora.
- How to do it technically → Cora dispatches Alex; for a hands-on technical conversation the
  human can still call `/alex` directly.
- Not sure → Cora; she routes.

This matches the chat platforms, where the human already goes to the PM first.

**How Alex's duties split**

| To Cora (faces the human and the project) | Stays with Alex (faces the technology) |
|---|---|
| Discussing product and project direction | Technical design |
| Agreeing a goal, fixing it as an Epic, cutting phases | Technical research and option comparison |
| Conducting Epic execution | Writing handoffs |
| The panoramic view of the project and its progress | Design review |
| Capturing ideas, browsing them, promoting one to an Epic *(second batch)* | Recomputing acceptance as an independent subagent |
| Health checks at activation *(second batch)* | Diagnosing bugs |
| Keeping `NEXT.md`, the roadmap and similar ledgers *(second batch)* | Teaching technical concepts |

The first version of Cora takes the first four rows on the left. The three marked *second
batch* move only after those four have run well; they are not in this Epic's Phase 1.

## Result contract (agreed with the human, 2026-10-13)

**What the human gets**

- In any harness, saying "you are Cora" (or `/cora`, `$cora`) is enough: she knows she is the
  PM and what to do.
- Opening a harness to talk about where the project should go next, the human talks to Cora.
- For a piece of work, the human speaks only to Cora. She asks about the result (what will be
  looked at in the end, what is not wanted, which way to lean in a trade-off), fixes it as an
  Epic, then runs it.
- Start small: the first version does the basic job — shape a goal into an Epic and run that
  Epic. Whether Cora becomes a standing project manager (digests, standing goals) is added
  later if needed, and the role is written so that it can grow that way.
- Chat-type seats (Grok, Muse) are not designed for in this Epic. The expectation for later:
  a seat is told to read Cora's role from the files and act by it, which simplifies what the
  platform has to define itself.

**What is not wanted**

- No GM or portfolio layer in TAD: roster, morning and evening digests, wake-up webhooks,
  model routing and chat cards stay on the platform side.
- No second set of progress books. Her progress state is the Epic file, `session-state.md`
  and `NEXT.md`. No open cards, stamps or restatement files. (What she should remember beyond
  progress is an open question — see "Not yet checked with the human".)
- Cora writes no implementation and edits no handoff. She issues no gate verdict.
- `/alex` and `/blake` are not removed; small work, discussion and single bugs still go to
  them directly.

**Trade-offs already decided**

| Question | Decision |
|---|---|
| Who talks to the human about requirements | Cora, at result level only. Technical design goes to an Alex subagent; its questions come back to Cora, who answers from the Epic or asks the human. |
| Who gives the Gate 4 verdict | An independent Alex subagent that took no part in the implementation recomputes acceptance from disk. Cora only reads the verdict and routes. |
| Entry points | Cora is additive. Epic-level work goes through her; `/alex` and `/blake` remain. |
| Harness priority | Claude Code and Codex first. Cursor and OpenCode use the same method and are stated honestly as untested until someone runs them. Chat seats are out of scope. |
| Human checkpoints | The human agrees the result; Cora gets the Epic written, then stops and waits for the human's "continue"; after that she runs to the end and shows the result. Mid-run the human is asked only when the Epic's result itself would change, or before an irreversible or outward action. |

## Checked with the human (2026-10-13, second round)

1. **What Cora remembers — same way as Alex and Blake; who records and how is a design item.**
   The human's direction: Cora remembers what Alex and Blake remember, by the mechanism TAD
   already has. Phase 1 designs who writes and how, and shows it to the human before it is
   built. The existing mechanism, for reference:
   - *Progress*: `session-state.md`, `NEXT.md`, the Epic file, pre-compaction snapshots.
   - *Knowledge*: the one who did the work writes a raw journal; a role that did not do the
     work distils it into a typed entry in `.tad/project-knowledge/` (the doer does not write
     finished knowledge). At activation a role reads `principles.md` and the patterns index.
   - *Decisions*: decision records in `.tad/decisions/`.
   Open inside this item: for conducting, Cora is the doer, so someone else must distil her
   journal; and the human's standing preferences and past rulings per project have no
   structured home in TAD today.
2. **When the human is contacted — once the Epic is written, Cora stops and waits; the human
   replies "continue" and she runs it to the end, then shows the result.** Confirmed by the
   human. Mid-run she stops only for something she cannot get past herself (a permission, a
   real blocker), a change to the result itself, or an irreversible or outward action. She
   does not stop between phases.
   **Several Epics.** The human expects to be able to give Cora two or three Epics and have
   her finish all of them before stopping. First version: she takes them as a queue and runs
   them one after another. Running Epics at the same time in one repository (separate
   worktrees, no shared files) is a design question for Phase 1, not a promise of the first
   version.
3. **Chat seats — out of scope for this Epic.** Design for harnesses only. A chat seat will
   later be told to read Cora's role from the files and follow it; whatever is particular to
   a platform stays maintained on that platform.

## Success Criteria

- [ ] A session opened with "you are Cora" and a question about the project's direction is
      handled by her as a discussion, without her starting a design or a handoff.
- [ ] In a real project, a real Epic is taken by Cora from the requirements conversation to
      delivered work, on Claude Code.
- [ ] The session is closed mid-Epic; a new session told only "you are Cora" reads the disk
      and continues from the right step without the human re-explaining anything.
- [ ] The same Epic flow is run on Codex, and what worked and what did not is written down.
- [ ] In none of these runs did Cora write implementation, edit a handoff, or write a gate
      verdict; every verdict file on disk was written by a subagent that did not do the work
      it judges.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Cora herself | ✅ Done | `HANDOFF-2026-10-13-cora-phase1-slim.md` + addenda 1–2 (branch `feat/cora-role`, ad6feb80) | The Cora skill, activatable on Claude Code and Codex, with the conductor protocol moved out of Alex |
| 2 | Wiring into the framework | ✅ Done | `HANDOFF-2026-10-14-cora-phase2-slim.md` (feat/cora-role, 1320ba8f) | Three-role wording in principles, config, `AGENTS.md`; installer and per-harness projection ship Cora |
| 3 | Real run | ✅ Closed — PARTIAL (P0 CF-1 carried to Phase 4) | sub-Epic `EPIC-20261014-cora-carry-forward-fixes.md` | One real Epic conducted by Cora end to end, including a mid-run restart |
| 4 | Release | 🔄 Active | — | Everything from Phases 1–3 pushed and published as one major release, with the README and the introduction of TAD rewritten around A-B-C |

### Phase Dependencies

All phases are sequential.

### Derived Status

Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Run

Pointer: phase 4 | 4b+4c step Y6 round 2 (review of 1c68551b + 288fec0e); 4d step Y5
Dispatched: p4bc-y6-r2-cr -> .tad/evidence/yolo/cora-conductor-role/phase4bc-impl-review-cr-r2.md
Dispatched: p4bc-y6-r2-dom -> .tad/evidence/yolo/cora-conductor-role/phase4bc-impl-review-docs-r2.md
Dispatched: p4d-y5-1 -> .tad/evidence/yolo/cora-conductor-role/phase4d-completion.md
Next: 4b+4c Gate 3 (p4bc-y7-g3-1) and Gate 4 (p4bc-y7-g4-1); 4d review; then the human confirms push
Stopped: —  (previous: Checked on disk — README.md draft (uncommitted, 162 lines, Opening A + C table, p4c-y5-2), phase4c-fresh-reader.md (p4c-y7-reader-1). Please read the README draft: commit as is, or what to change? | answer: "提交" (2026-10-14))
---

## Phase Details

### Phase 1: Cora herself

**Status:** ✅ Done — Gate 4 PASS 2026-10-14 (`.tad/evidence/yolo/cora-conductor-role/phase1-gate-report.md`, by an Alex subagent that took no part); one P1 carried into Phase 2 by the human's decision; carry-forward list C1–C12 in that report
**Execution:** started 2026-10-13; conducted by Alex through subagents (see "Execution mode" under Decisions)

#### Scope

Create the Cora role with her first four duties and take those four out of Alex: discussing
direction, shaping a goal into an Epic, conducting the Epic, and the panoramic project view.
In scope: the Cora skill (persona, routing rule, the five conducting actions,
resume-from-disk, what she may not do), the discussion, Epic-intake, status and conductor
protocols re-homed under Cora, and Alex's skill reduced by what moved. Not in scope: ideas,
activation health checks and ledger upkeep (second batch); the installer, `AGENTS.md`,
`principles.md`, other harnesses' projections (Phase 2); any run in another project (Phase 3).

The five conducting actions, which must live in the skill body, not in a reference:

1. **Intake** — agree the result with the human and get an Epic written (an Alex subagent
   drafts the technical part; Cora owns the result contract and the phase map shown to the human).
2. **Dispatch** — hand one step to one subagent, passing file paths, never business content.
3. **Read** — re-read verdict and completion files from disk before deciding anything.
4. **Route** — next step, rework, or stop and ask the human.
5. **Record** — update the Epic's phase status, `session-state.md` and `NEXT.md` before the
   next dispatch.

#### Input

- `.agents/skills/alex/references/yolo-execution-protocol.md` and
  `yolo-manual-conductor-protocol.md` (the conductor steps Y1–Y8 as they exist under Alex).
- `.tad/guides/yolo-recovery.md`, `.tad/guides/yolo-multi-harness.md`.
- Conductor lessons already in `.tad/project-knowledge/patterns/` (`gate-design.md`,
  `handoff-design.md`, `memory-and-learning.md`, `ac-verification.md`).
- The Lite Execution Mandate model (outcome-level grant; the closed list of boundary changes
  that send a decision back to the human).

#### Output

- `.agents/skills/cora/SKILL.md` plus its references.
- Alex's skill no longer presents Alex as the conductor; it points to Cora for Epic execution.
- A written statement of how Cora dispatches on Claude Code and on Codex.

#### Acceptance Criteria

- [ ] On Claude Code and on Codex, a fresh session told "you are Cora" states her role, her
      five actions and what she may not do, and reads the current Epic state from disk.
      (Amended 2026-10-13 from the design: in Phase 1 this is shown by `/cora`, `$cora`, or
      the explicit sentence "Read `.agents/skills/cora/SKILL.md` and follow it. You are
      Cora." The bare phrase "you are Cora" needs the trigger table in `AGENTS.md` and the
      harness projection, which are Phase 2; that part of this criterion stays open until
      Phase 2, and Phase 1 records what the bare phrase does today.)
- [ ] Given a direction question ("what should this project do next?"), Cora discusses it and
      produces no handoff. Given a how-to-build-it question, she dispatches Alex or tells the
      human to call `/alex`; she does not design it herself.
- [ ] Alex's skill is smaller by the sections that moved, measured in lines and bytes before
      and after. (Corrected 2026-10-13 after grounding: the earlier wording required the file
      to fit one read. Grounding measured 1671 lines / 99,170 bytes today and about 1410 lines
      after the four moves, so one-read size is not reachable in this Epic; the largest
      remaining block is the research protocol with its retired NotebookLM steps. Getting
      Alex under the single-read limit is carried as its own item, not claimed here.)
- [ ] Three behaviours of today's conductor protocol are changed, each visibly:
      (a) the conductor no longer judges Gate 3 and Gate 4 itself (today: step Y7 "Conductor
      judges") — an independent subagent writes the verdict;
      (b) the conductor no longer fixes a handoff or code itself (today: Y3b step 6, Y4 step
      5a, Y6 step 6b) — rework is dispatched;
      (c) the mid-run pause is replaced by the boundary-change rule — the human is asked only
      when the result, scope or consequences change.
- [ ] Every constraint line (MUST / forbidden) that the conductor protocol and Alex's skill
      carry today is either still in Alex, now in Cora, or listed as deliberately removed with
      a reason. Checked per constraint, not by a total count.
- [ ] The five standard actions are in the Cora skill body.
- [ ] A fresh session that reads only the Cora skill and an Epic file can name the next step
      of that Epic without any other briefing.
- [ ] Given two approved Epics, Cora finishes the first and starts the second without asking
      the human in between, and stops only after both are done or one is honestly blocked.

#### Files Likely Affected

- `.agents/skills/cora/SKILL.md` (CREATE)
- `.agents/skills/cora/references/*.md` (CREATE — conductor protocol, recovery)
- `.agents/skills/alex/SKILL.md` (MODIFY — conducting duties out, pointer in)
- `.agents/skills/alex/references/yolo-execution-protocol.md`,
  `yolo-manual-conductor-protocol.md` (MOVE or replace with pointers)
- `.agents/skills/alex/references/discuss-path-protocol.md`,
  `status-panoramic-protocol.md`, `update-roadmap-protocol.md` (MOVE or split — product and
  project discussion to Cora, technical discussion stays reachable from Alex)
- `.agents/skills/blake/SKILL.md` (MODIFY only where it names Alex as the conductor)

#### Dependencies

None.

#### Notes

- A subagent cannot spawn subagents. Cora therefore has to be the main session, and reviewers
  must be spawned by her, not by the Alex or Blake subagent.
- On Codex, TAD's custom agents are still drafts; dispatch there is by explicit subagent
  prompting or sequential `codex exec` sessions. Phase 1 has to say which, from a real run.
- Removing constraints while slimming Alex is the failure that broke the quality chain in
  v2.7. The per-constraint check above exists for that reason.
- The Claude Code `Workflow` path (`yolo-epic.workflow.js`) stays available to Cora; whether
  it remains the default is a design question for this phase.

### Phase 2: Wiring into the framework

**Status:** ✅ Done — Gate 4 PASS 2026-10-14 (`.tad/evidence/yolo/cora-conductor-role/phase2-gate-report.md`, Alex subagent that took no part); carry-forward to Phases 3–4 listed there
**Execution:** commits 4a01fa32..1320ba8f on `feat/cora-role`

#### Scope

Make Cora part of what TAD says it is and what it installs. In scope: the wording of the
first principle (two roles → three), `config-agents.yaml` (terminal isolation is still stated
there as blocking), role routing in `AGENTS.md`, the installer and the four harness
projections, and the docs that describe the roles. Not in scope: the release itself (that is
Phase 4), anything for chat seats, and any change to the GM or platform documents outside
this repository.

#### Input

Phase 1 output. `tad.sh`, `.tad/hooks/lib/derive-sync-set.sh`, `release-verify.sh`,
`docs/MULTI-PLATFORM.md`, `.tad/codex/README.md`, the per-harness projection code.

#### Output

- A fresh install on Claude Code and on Codex contains Cora and can activate her.
- `principles.md`, `config-agents.yaml`, `AGENTS.md`, `README.md` describe three roles and
  describe physical terminal separation as one way to get independence, not the only one.

#### Acceptance Criteria

- [ ] `tad.sh --source <this repo> --platform claude-code` and `--platform codex` into an
      empty directory each produce an install in which Cora activates.
- [ ] `release-verify.sh` passes, including parity between the skill trees.
- [ ] No current document still states that Alex and Blake must run in separate terminals as
      a blocking rule, and none states that Alex is the conductor.
- [ ] The change to the first principle is shown to the human as a before/after and approved
      by the human before it is written (that entry requires human review).
- [ ] Cursor and OpenCode are described as "same method, not yet run" unless they were run.

#### Files Likely Affected

- `.tad/project-knowledge/principles.md` (MODIFY — human-reviewed)
- `.tad/config-agents.yaml`, `.tad/config.yaml` (MODIFY)
- `AGENTS.md`, `README.md`, `docs/MULTI-PLATFORM.md`, `CHANGELOG.md` (MODIFY)
- `tad.sh`, projection scripts, `.tad/codex/README.md` (MODIFY)

#### Dependencies

Phase 1.

#### Notes

- About 490 current files mention Alex or Blake. Most need no change; the risk is missing one
  of the few that carry the install or the routing, which would ship a TAD without Cora.

### Phase 3: Real run

**Status:** ✅ Closed as PARTIAL — Gate 4 PARTIAL p0 1 (`.tad/evidence/yolo/cora-conductor-role/phase3-gate-report.md`, p3-y7-g4-1), Gate 3 PARTIAL p0 1 (`phase3-gate3-verdict.md`, p3-y7-g3-2); the open P0 (CF-1) and the list in the gate report section 5 go to Phase 4 by the human's instruction. Verdicts not upgraded. Real run: `EPIC-20261014-cora-carry-forward-fixes.md`
**Execution:** Cora conducted the real run (Claude Code, restart into Codex, back to Claude Code); evidence `.tad/evidence/yolo/cora-carry-forward-fixes/`

#### Scope

Prove Cora on real work. One real Epic, conducted by Cora from the requirements conversation
to delivered work on Claude Code, with a deliberate mid-run restart; then the same flow on
Codex. Not in scope: chat seats, changing the platform-side GM or PM documents, or moving
other projects over.

#### Input

Phases 1 and 2. A real Epic chosen by the human.

#### Output

- The run's evidence on disk, in the project where it ran.
- A short record in this repository: what worked, what did not, per harness.
- Fixes to Cora that the run showed to be necessary, as their own handoffs.

#### Acceptance Criteria

- [ ] The five success criteria at the top of this Epic, each with a pointer to evidence.
- [ ] The human looked at the delivered result and said whether it is what was asked for.
- [ ] After the run, the project has one set of books: its Epic, `session-state.md` and
      `NEXT.md` agree with each other and with `git log`.

#### Files Likely Affected

- `.tad/evidence/` in this repository (CREATE — the per-harness record)
- The Cora skill (MODIFY — only what the run shows)

#### Dependencies

Phases 1 and 2.

#### Notes

- Proposed project: 买卖 (most active; its PM books and its TAD books disagree most). Not yet
  confirmed by the human.
- Capability Builder's dogfood phase, which also had to run in another project, has been
  parked since September. To avoid the same, the first real run may be the next real Epic in
  this repository, with the other project second. The human decides when Phase 3 opens.
- Work items that belong to the other project stay in that project's own `NEXT.md`.

### Phase 4: Release

**Status:** 🔄 Active
**Execution:** pending

#### Scope

The human's requirement (2026-10-13): this Epic ends with a push and one unified release
version, and it is a big release — a large change to what TAD is — so the README and every
place that introduces TAD are to be written in a new way, not patched.

Two parts:

**A. The new introduction.** TAD has been introduced as two agents in two terminals with the
human carrying messages between them. That is no longer the main way it is used. The new
introduction presents:

- three roles — Alex designs, Blake executes, Cora is who you talk to and who dispatches;
- how a piece of work goes: you agree a result with Cora, she gets an Epic written and stops,
  you say continue, she runs it to the end through subagents and gates, you look at the result;
- where quality comes from: the one who checks did not see the reasoning of the one who did
  the work, and only questions a human can answer go to the human. Separate terminals remain
  one way to get that, described as such;
- who to go to for what (the three-line rule in this Epic's Objective);
- per harness, what has been run and what has not.

Places to rewrite: `README.md` (and its translations if any exist), the introduction in
`AGENTS.md`, `docs/MULTI-PLATFORM.md`, the getting-started and help texts (`tad-help`,
`tad-init`), `package.json` and the repository description, `PROJECT_CONTEXT.md`,
`ROADMAP.md`. The human reads the README draft before it is committed: how TAD presents
itself is the human's call, and the draft is offered as a choice between two or three
openings, not as a text to approve.

**B. The release itself.** Publish everything from Phases 1–3 as a single release through the
existing release flow (`*publish`, the release runbook, `release-verify.sh`): version bump
(treated as a major release, since the first principle and the default way of working change;
the number is set at release time and recorded only where the release flow puts it), a
detailed changelog and release note, regenerated ledgers, push to `main`, annotated tag,
GitHub release, and upgrade notes for projects that already have TAD installed (what changes
for them, what keeps working unchanged — `/alex` and `/blake` do).

Not in scope: new features, and upgrading downstream projects (each project pulls for itself).

#### Input

Phases 1–3 accepted. The per-harness record from Phase 3.

#### Output

- `main` and a new annotated tag on GitHub; a release note that says what Cora is, how the
  roles split, and — per harness — what was run and what was not.

#### Acceptance Criteria

- [ ] `release-verify.sh` passes in full on the release commit (version consistency, parity,
      freshness, structural).
- [ ] The release note and `docs/MULTI-PLATFORM.md` state per harness what was actually run;
      nothing unrun is described as verified.
- [ ] Someone who has never seen TAD, reading only the new README, can say what the three
      roles do, who to talk to first, and what happens after they say "continue" (checked by
      a fresh subagent given only the README and those three questions).
- [ ] No current document still introduces TAD as two agents in two terminals as the main
      way of working.
- [ ] The human chose the README's opening from the alternatives offered and read the draft
      before it was committed.
- [ ] The upgrade notes say what an existing install has to do and what keeps working.
- [ ] A fresh install from the published tag on Claude Code and on Codex activates Cora.
- [ ] The push and the tag were made only after the human confirmed them at that moment.

#### Files Likely Affected

- `README.md`, `AGENTS.md`, `docs/MULTI-PLATFORM.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`,
  `.agents/skills/tad-help/`, `.agents/skills/tad-init/` (REWRITE the introduction)
- `.tad/version.txt`, `CHANGELOG.md`, `package.json`, release ledgers (MODIFY)

#### Dependencies

Phases 1–3.

#### Notes

- Pushing and tagging are outward and hard to undo. The human asking for a release here sets
  the goal; the push itself is still confirmed when it happens.
- Skills change in this Epic, so the ledgers must be regenerated before the release commit.
- The download install paths (`curl`, `npx github:`) were untested at the last release; the
  fresh-install criterion above is the place to test them.

---

## Context for Next Phase

### Completed Work Summary

None yet.

### Decisions Made So Far

- 2026-10-13 — Role name: Cora (a C name, a woman's name to balance Alex and Blake, two
  syllables that survive voice input). The human used the name in conversation; a different
  name can still be chosen before Phase 1 ships.
- 2026-10-13 — The four trade-offs in the result contract above.
- 2026-10-13 — Cora is the human's entry point, not only the conductor; Alex's
  human-and-project-facing duties move to her (the human: "可以"). First version takes four
  of them; three more wait for a second batch.
- 2026-10-13 — Start small; a standing project manager is a later addition.
- 2026-10-13 — Execution mode: the human said "执行吧" after approving the map. Alex conducts
  the Epic through subagents (manual conductor protocol; evidence under
  `.tad/evidence/yolo/cora-conductor-role/`). The three behaviours this Epic changes are
  applied to this run already: Alex as conductor writes no implementation and edits no
  handoff or code (rework is dispatched), issues no gate verdict (independent subagents write
  them), and does not pause between phases. Stops that remain, because only the human can
  answer them: the before/after of the first principle (Phase 2), which real Epic the real
  run uses (Phase 3), the README opening (Phase 4), and the push and tag (Phase 4).
- 2026-10-13 — Subagent models are chosen by tier, never by model name (the human's
  instruction, corrected by the human the same day): design (Alex subagent) on the strongest
  tier the harness offers; review and execution (reviewers, Blake subagent) on the middle
  tier; purely mechanical judgment on the cheapest tier. Nothing Cora ships may name a
  concrete model: models change, and other harnesses do not have the same ones. How the
  tiers map in this run's harness is recorded in `session-state.md` only, as a fact about
  this run.
- 2026-10-13 — The human, shown the three open questions (H1–H3) and the provisional
  positions, answered: "你自yolo完成吧" — finish it yourself in YOLO mode. Alex's reading: the
  human delegates the open design choices to the conductor's stated recommendations and does
  not want to be asked again along the way. The provisional positions therefore stand as the
  working decisions (they stay marked as the conductor's recommendations, adopted by
  delegation, not as the human's own words): a blocked Epic in a queue does not stop the
  independent Epics behind it; judging work by Alex subagents runs on the middle tier; the
  rulings file holds the human's words verbatim, narrowest scope by default, standing rulings
  only; nothing is archived mid-run; a new session takes over a run only after a recorded
  idle period, otherwise asks; each irreversible or outward action is still confirmed when it
  happens. Human stops that remain in this run: the before/after of the first principle
  (that entry requires human review by the framework's own rule) and the push and tag. The
  README opening and the choice of the real-run Epic are no longer mid-run stops: the
  conductor picks, and both are shown to the human with the result before the push.
- 2026-10-13 — Design review of the Phase 1 handoff: round 1 both CONDITIONAL (17 P1),
  round 2 on revision 2 both CONDITIONAL (11 P1, 0 P0; nearly all on mechanisms revision 2
  had added). `handoff-creation-protocol.md` caps design review at two rounds and then
  pauses for the human. The conductor goes one round past the cap — a third rework and one
  confirming review — acting on the human's instruction to finish in YOLO mode (the user's
  instruction in the conversation ranks above the repository protocol; recorded here as the
  conflict and the reason). Hard limit: if the confirming review still has a P0 or P1, the
  run stops and goes to the human.
- 2026-10-13 — Positions changed for revision 3, after round 2 showed the earlier ones
  unsafe or unusable: (a) a blocked Epic stops the whole queue (the earlier position,
  continue past it, is unsafe in one shared working tree: the blocked Epic's unaccepted
  commits stay underneath the next one); (b) no timed takeover — resume is decided from
  facts on disk, and the human is asked only when a dispatch was started, has no result and
  left no output; (c) archiving is asked as its own question at the end, not implied by the
  human accepting the result; (d) this run's conductor stays the same human-authorised
  session for Phases 2–4 and follows Cora's protocol once Phase 1 has passed.
- 2026-10-13 — Confirming review (round 3) of handoff revision 3: both CONDITIONAL, 0 P0,
  4 P1 (CR 3, ARCH 1), all in the resume table and the between-Epics rule (rule order lets
  the next Epic start after a stop; "open question" is checked after the rows that dispatch;
  a scenario contradicts the rework budget; the human's answer to a stop is not recorded
  where resume reads it). By the hard limit set above, the run is stopped and the human is
  asked how to proceed. Nothing was dispatched after round 3.
- 2026-10-13 — The human, shown the stop after round 3 and three ways forward, chose:
  "选A，修完直接往下跑" — one targeted fix of the 4 P1, a narrow re-check of exactly those
  by one reviewer, then straight on into implementation. The remaining P2 findings are
  settled during implementation and answered in Blake's completion report. If the narrow
  re-check is not clean, the run stops again.
- 2026-10-13 — Narrow re-check of handoff revision 4: CONDITIONAL, 0 P0, 5 new P1. The
  four round-3 P1 are resolved; the new five were found by walking the resume table on disk
  states the fixtures do not build. Rounds 3 and 4 produced defects only in that table, and
  each fix added rows. The human's option A was conditional on a clean re-check, so the run
  is stopped again and nothing is dispatched.
- 2026-10-13 — The human, shown the second stop and the conductor's recommendation,
  answered: "同意，换成指针的做法，重写完直接往下跑". Decision: Cora does not infer where a run
  is from which artifacts exist; she writes an explicit step pointer (phase, step, pointer
  state, next action, stored counters) in the Epic file before each dispatch and after each
  result, routes by a finite (step, outcome) transition table, and on resume reads the
  pointer. If pointer and disk disagree she stops with the facts. The numbered resume table
  is deleted, not kept alongside. How the conductor closes this out, so that "straight on"
  does not mean unreviewed: the rewritten part gets one review by two fresh reviewers; a P0
  stops the run; P1s are fixed by the designer and confirmed by the reviewer who raised
  them (same instance), once; then implementation is dispatched.
- 2026-10-13 — The human: "我觉得不要把事情搞得太复杂 花这么久连第一个阶段都没有跑 真的让我很震惊".
  The criticism is right: the conductor let the Phase 1 design grow to a 1113-line handoff
  with a 27-row resume table and 23 fixtures, ran four paper review rounds, and dispatched
  no implementation. Course change: Phase 1 is cut to a slim handoff (cap 250 lines; Cora
  body cap 200 lines; resume is a ten-line pointer rule, not a table; conductor steps are
  the existing ones moved with three behaviour changes; at most 6 smoke scenarios). Kept in
  full: the 162-row constraint disposition check. The slim handoff gets one quick check for
  P0 only, then Blake is dispatched; remaining review effort goes to the built result, not
  to paper. The long handoff stays on disk as reference and is not implemented.
- 2026-10-14 — Phase 1 implementation (branch `feat/cora-role`, commits 5ee1e70b, b9bdfb60,
  ad6feb80; slim handoff + addenda 1 and 2): code review PASS; smoke 12/12 PASS on Claude
  Code and Codex, judged by an independent subagent; architecture review CONDITIONAL with
  one P1 — the Blake rework prompt (Y6 4a) carries no dispatch_id, so a session that dies
  just after that rework would ask the human once and, on a "no", re-dispatch the rework
  on already-fixed code. The code reviewer rates the same gap P2. Both reworks are spent,
  so the run stopped and asked the human.
- 2026-10-14 — The human: "选A，直接往下跑" — accept Phase 1 without another rework; the
  missing dispatch_id line in the Y6 4a Blake rework prompt is carried into Phase 2 as its
  first commit (Phase 2 edits these skill files and reruns the smoke tests anyway).
- 2026-10-14 — First-principle rewrite: the human was shown the before/after text and asked to
  approve or change it; the human's reply was "继续". Recorded verbatim in
  `phase2-principle-before-after.md` with the conductor's reading (approval of the text as
  shown). Reversible: it is one commit on `feat/cora-role`.
- 2026-10-14 — Phase 3 plan (conductor's choice, under the human's delegation): the real Epic
  is "Cora carry-forward fixes" — the open items the two Gate 4 reports sent to Phase 3
  (Y4 reviewer round ids, retry-within-round id, distillation inputs C2, stop text listing what
  was checked C6, freshness rule on fixture ids C7, dispatch statement C8, queue C10). It is
  small, real, needed before the release, and lives in this repository, so it cannot get parked
  in another project. Run: the human opens a new Claude Code session on `feat/cora-role`, says
  "你是 Cora", agrees the result, says continue; one deliberate restart mid-run; the later part
  continues in a Codex session with `$cora`, resuming from the pointer. Phase 3 cannot be done
  by the conductor of this Epic alone: it is the human using Cora.
- 2026-10-13 — Two memory design items, Alex's recommendation, told to the human when
  execution started and open to the human's correction and to the design reviewers:
  (1) Cora's conducting lessons: she writes a raw journal during the run; at Epic close an
  Alex subagent that did not conduct distils it into `.tad/project-knowledge/`.
  (2) The human's standing preferences and past rulings: one file per project inside
  `.tad/project-knowledge/`, appended by Cora only when the human rules on something, each
  entry dated and quoting the human; read by Cora at activation and used to answer Alex's
  questions before asking the human again.
- 2026-10-13 — Process depth: full (two design reviewers, independent acceptance per phase),
  because the first principle changes. Proposed by Alex; the human did not object.

- 2026-10-14 — Cora took over conducting this Epic at the human's answer quoted in the header. The Phase 3 real run was EPIC-20261014-cora-carry-forward-fixes (accepted by the human the same day; `.tad/evidence/yolo/cora-carry-forward-fixes/EPIC-COMPLETION.md`). Phase 4 scope gains, by the same answer ("修掉这次发现的 10 个小问题…然后发布"): the carry-forward items in `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-gate-report.md` section 5 (CF-1..CF-10; CF-1 is the open P0: acceptance and archiving asked as one question) and `phase1-gate-report.md` section 4 (C-1..C-6, C-8), plus Phase 2's P2-C/P2-D and the 5 uncommitted pattern entries from the sub-Epic's distillation. The human's stops in Phase 4: the README opening (choose among 2–3), push, release. CF-4 (what a second, non-owning session does) needs a human design decision when Phase 4 design reaches it.

- 2026-10-14 — Phase 3 Gate 3 round 2 (`phase3-gate3-verdict.md`, p3-y7-g3-2): PARTIAL p0 1 (the carried CF-1; success criteria 2 and 4 partly met; books now Met). The one rework is spent. By the human's instruction (carry the open P0 and the rest into Phase 4, run to the end), Phase 3 is routed on to Gate 4 and then closed as PARTIAL, not upgraded; Phase 4's design must close CF-1 with a rerun of the failing queue scenario, so the P0 is carried, not dropped.

- 2026-10-14 — The human's four Phase 4 design decisions: CF-1 acceptance and archiving are two separate questions; CF-4 the `## Run` block names its conducting session and a non-owning session only reads, says so and stops; CF-5 each review round keeps its own file (round-suffixed), evidence stays out of git (C12 unchanged); CF-10 the tier-to-model line stays in session-state.md as a run fact.

- 2026-10-14 — README opening: the human chose "a" (Opening A, the flow), then added "然后加c": include Opening C's "who to go to" table; from `phase4b-readme-openings.md`.

### Known Issues / Carry-forward

- Grounding A (`.tad/evidence/designs/2026-10-13-cora-phase1-grounding-A-alex-inventory.md`,
  162 constraint lines inventoried) found, beyond what the Epic assumed: Epic shaping and the
  pause-per-phase choice live in `adaptive-complexity-protocol.md` and
  `handoff-creation-protocol.md`, not in the `yolo-*` files; the conductor's own gate
  judgments are wider than step Y7 (Y4 Gate 2 judgment, Y8 knowledge writing, the recovery
  receipt, `gate3_verdict` in the completion template); the conductor protocol lets the
  conductor edit handoffs and code while Alex's skill forbids it; and several standing rules
  (human review at every key checkpoint, human decides important technical decisions) have
  to be reconciled with the no-pause design, not dropped. The inventory's last section lists
  reference files that were only searched, not read in full.
- Carry: Alex's skill stays over the single-read limit after this Epic.

- Evidence from the platform-side PM layer (read 2026-10-13): what worked there was the TAD
  part (independent review, rework loops, human gates); what failed was the PM's own paper
  (a second set of books that went stale, rules held in chat memory and lost on compaction,
  the PM drifting into judging gates). The design answers each: one set of books, resume from
  disk, no verdicts from Cora.

### Next Phase Scope

Phase 1, after the human approves this map.

---

## Notes

- TAD's name needs no change: the triangle was the human, Alex and Blake; it becomes Alex,
  Blake and Cora, with the human outside it at the two ends.
