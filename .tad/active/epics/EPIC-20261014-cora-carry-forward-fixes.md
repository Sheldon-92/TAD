# Epic: Cora carry-forward fixes (the real run of Cora, parent Phase 3)

**Epic ID**: EPIC-20261014-cora-carry-forward-fixes
**Created**: 2026-10-14
**Owner**: Cora
**Conductor**: Cora
**Approved**: yes — "继续" (2026-10-14; reply to "回一句继续就行" with D1–D5 all on the recommended option: D1 a, D2 a, D3 as proposed, D4 as proposed, D5 a)
**Parent**: `.tad/active/epics/EPIC-20261013-cora-conductor-role.md`, Phase 3 "Real run" (this Epic is the real Epic that phase runs; see its Decisions, 2026-10-14 "Phase 3 plan")

---

## Objective

Close the items the Phase 2 Gate 4 report sent to Phase 3
(`.tad/evidence/yolo/cora-conductor-role/phase2-gate-report.md`, section 5), and in doing so
run Cora end to end on real work for the first time: Intake, dispatch, read, route, record,
one deliberate restart, and a continuation on Codex.

## Result contract

What the human gets:
- The Cora skill and conductor protocol with these gaps closed:
  - **P2-A** — a retry inside a Y6 round ("no, the earlier session is dead") has a defined id, so it cannot use up a review round early (`conductor-protocol.md:203`, `cora/SKILL.md:101`).
  - **P2-B** — Y4 (design review) gets the same id scheme as Y6, so a re-dispatch to a path still holding the round-1 FAIL is not read as the new result (`conductor-protocol.md:136,146-149`).
  - **C2** — Epic-close distillation receives Blake's journals and the gate reports, Y5 asks Blake for a journal, and `distillation-loop-protocol.md` no longer skips an Epic whose only material is gate-report candidates.
  - **C6** — a stop says what Cora checked on disk, not only the question.
  - **C7** — a written rule on whether the `dispatch_id` freshness check applies to a result the pointer already records as read.
- A short written record from this run, per harness (Claude Code, Codex): how Cora dispatched, where the restart happened, what resumed and what did not (**C8**).
- Queue behaviour with two Epics shown once, not only described (**C10**) — how is decision D2 below.
- The parent Epic's Phase 3 evidence: the run's files under `.tad/evidence/yolo/cora-carry-forward-fixes/`.

What is not wanted:
- No new mechanism, script or role beyond what an item needs; no rewrite of the pointer design.
- Not in scope: P2-C (brain-index churn) and P2-D (date on the approval line), C5, C12, the README and every other Phase 4 wording item, push, tag and release. These stay with the parent Epic's Phase 4.
- No work in another project.

## Decisions for the human (settle before "continue")

- **D1 — Codex continuation.** The parent plan: after a deliberate restart, the run continues in a Codex session with `$cora`, resuming from the pointer. If Codex in this setup has no subagent facility, Cora stops there (reason 1) and that is recorded as the Codex result. Options: (a) keep it as planned (recommended: it is what C8 asks for); (b) Claude Code only, restart inside Claude Code; Codex later.
- **D2 — C10, the queue.** Options: (a) a scripted headless scenario with two fixture Epics, judged by an independent subagent, as the Phase 1 smoke scenarios were (recommended: small, repeatable); (b) a second real Epic queued behind this one; (c) leave C10 text-only and say so.
- **D3 — Process depth (proposal).** Per phase: one slim handoff by an Alex subagent, one quick design check for P0 only, Blake implements, two code reviewers of different types, Gate 4 by an Alex subagent that took no part. No multi-round paper review (the human's 2026-10-13 instruction against making it complicated).
- **D4 — Where the restart happens (proposal).** The human ends the Claude Code session once Phase 1's Gate 4 file is on disk (Cora does not pause there; the human interrupts), then opens Codex and says `$cora`; Phase 2 runs there.
- **D5 — Evidence pointers for C8 and C10** (raised by the Intake Alex, `.tad/evidence/yolo/cora-carry-forward-fixes/intake-questions.md`). `.tad/evidence/` is gitignored, so C8 and C10 produce no commit. Options: (a) for C8 and C10 the pointer is the evidence path plus the independent verdict file, no commit (Alex's recommendation; no scope change); (b) put the run record in a tracked path such as `docs/`; (c) pull C12 (evidence outside git) into this Epic.

## Success Criteria

- [ ] Every item in the result contract is closed, each with a pointer to the commit and to an independent verdict file.
- [ ] The run resumed from the pointer after the restart without the human re-explaining anything.
- [ ] A per-harness record (C8) exists, and says plainly what was not run.
- [ ] After the run, this Epic, `session-state.md` and `NEXT.md` agree with each other and with `git log`.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Protocol gaps | ✅ Done | `HANDOFF-2026-10-14-cora-carry-forward-fixes-phase1.md` | P2-A, P2-B, C2, C6, C7 closed in the Cora skill, the conductor protocol and the distillation protocol, each independently verified |
| 2 | Queue and run record | ✅ Closed — PARTIAL (human: "选2") | `HANDOFF-2026-10-14-cora-carry-forward-fixes-phase2.md` (v2) | C10 shown per D2; the per-harness record C8 of this run, including the restart and the Codex part |

### Phase Dependencies

All phases are sequential. Phase 2 is the one that runs after the restart (D4).

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Run

Pointer: epic_completion | accepted by the human; archive pending (asked at the parent Epic's end)
Dispatched: —
Next: accepted. Archiving asked once, at the end of the parent Epic (parent decision: nothing archived mid-run)
Stopped: Checked on disk — Phase Map: Phase 1 ✅ Done, Phase 2 ✅ Closed PARTIAL; gate reports phase1 PASS, phase2 PARTIAL p0 1; EPIC-COMPLETION.md and distillation-report.md (5 entries in .tad/project-knowledge/patterns/, uncommitted; 4 gaps) present. Do you accept this Epic's result? | answer: "继续我要把整个流程整个都完成啊" (2026-10-14; reply to: 回"继续"：今天这段的结果就按现在这样收下，我接手原来那个大 Epic，一路跑下去)
---

## Phase Details

### Phase 1: Protocol gaps

**Status:** ✅ Done — Gate 4 PASS 2026-10-14 (`.tad/evidence/yolo/cora-carry-forward-fixes/phase1-gate-report.md`, judged c666a2de); Gate 3 PASS (`phase1-gate3-verdict.md`); smoke judge-2 PASS 6/6 + 6/6 after one rework (C6); carry-forward C-1..C-8 in the gate report section 4
**Execution:** done (Claude Code session, conducted by Cora; p1-* dispatches)

#### Scope

Close five text gaps in the Cora skill, the conductor protocol and the distillation protocol,
each with the smallest wording change that closes it. No new step, script in the skill, or
mechanism.

- **P2-A** (`conductor-protocol.md:203`, `cora/SKILL.md:99,101`): define the id of a retry
  inside a Y6 review round (the human answered "no, the earlier session is dead"). The retry
  keeps the round number `k` and takes its own suffix, so it never counts as a new round and
  cannot trip the circuit breaker early. The handoff fixes the literal id form; the same form
  is used in the Resume section of the skill.
- **P2-B** (`conductor-protocol.md:130-152`): give Y4 the Y6 scheme: reviewer ids per round
  (`p{N}-y4-r<k>-cr`, `p{N}-y4-r<k>-dom`, round 1 written in step 1), a design-fix id, and the
  sentence that a review file carrying another round's id is "output not on disk". Step 5b
  writes the pointer with the next round's ids before re-dispatching. The P2-A retry rule
  applies to Y4 too.
- **C2** (`conductor-protocol.md:154-184,256-257`, `distillation-loop-protocol.md:3-6,101-106`):
  (a) the Y5 Blake prompt asks for a journal at a named path
  (`.tad/evidence/journal/{epic-slug}-phase{N}-{date}.md`, or "No discoveries") and its path in
  the completion report; (b) epic_completion 3b gives the distiller the paths: Blake's
  journals, Cora's journal and every `phase*-gate-report.md` `## Knowledge candidates`;
  (c) `distillation-loop-protocol.md`: the Precondition's skip does not apply to a conductor
  Epic close when gate-report candidates exist, and the conductor section names Blake's
  journals and the gate reports as inputs beside Cora's journal.
- **C6** (`cora/SKILL.md` "When Cora stops"): a stop states what she checked on disk (each
  file or directory she read and what it showed), then the question.
- **C7** (`cora/SKILL.md:99`, `conductor-protocol.md:35-37`): the written rule, recommended
  form: the dispatch_id freshness check applies only to an output named on a current
  `Dispatched:` line; a result the pointer already records as read (its step is behind
  `Pointer:`/`Next:` and `Dispatched:` no longer names it) is not re-checked and is not a stop.
- After the skill edits: regenerate the Claude provenance ledger
  (`.tad/scripts/gen-claude-provenance.sh`) in its own commit.
- Behaviour check: rerun the Phase 1 smoke scenarios a-f of the parent Epic
  (`.tad/evidence/yolo/cora-conductor-role/phase1-slim-behaviour.sh`, copied into this Epic's
  evidence directory as `phase1-smoke.sh`) on Claude Code and Codex against the new commit,
  with rubric row d extended for C7 (no stop for review files lacking a dispatch_id that the
  pointer records as read) and row f extended for C6 (the stop names the Epic Phase Map, the
  handoff directory and the evidence directory as checked, with what each showed). Judged by
  an independent subagent.

Not in scope: P2-C, P2-D, C5, C12, the README and other Phase 4 wording; any change to
`status-roadmap-protocol.md`; the queue (Phase 2).

#### Acceptance Criteria

Run from the repo root under `bash` (zsh does not word-split). The handoff writes these as
one script, `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh`, rc 0 = all pass.

- [ ] AC-1 (P2-A): the retry id literal fixed in the handoff appears ≥1 time in the
      `step_Y6` block of `conductor-protocol.md` (awk range `step_Y6:` to `step_Y7:`) and ≥1
      time in the "Resume" section of `cora/SKILL.md`; the Y6 block states in one sentence
      that a retry does not start a new round (grep the sentence named in the handoff).
- [ ] AC-2 (P2-B): the `step_Y4` block (awk range `step_Y4:` to `step_Y5:`) contains
      `p{N}-y4-r<k>-cr`, `p{N}-y4-r<k>-dom` (or the literal the handoff fixes), a design-fix
      id, and "output not on disk"; step 5b says the pointer is written before the
      re-dispatch. Count of each ≥1.
- [ ] AC-3 (C2): the `step_Y5` block names `.tad/evidence/journal/` and asks for the journal
      path in the completion report; the `epic_completion` block names
      `.tad/evidence/journal/` and `gate-report` and `Knowledge candidates`;
      `distillation-loop-protocol.md` Precondition section contains the conductor exception
      (literal fixed in the handoff) and its conductor section names Blake's journals and the
      gate reports. Each grep ≥1.
- [ ] AC-4 (C6): the "When Cora stops" section of `cora/SKILL.md` contains the rule that a stop
      lists what she checked on disk (literal fixed in the handoff), grep ≥1.
- [ ] AC-5 (C7): the "Resume" section of `cora/SKILL.md` and the `dispatch_id_rule` block of
      `conductor-protocol.md` each state the freshness-scope rule (literal fixed in the
      handoff), grep ≥1 each.
- [ ] AC-6 (no regression): `wc -l < .agents/skills/cora/SKILL.md` ≤ 200; every `[A###]` tag
      present in the two Cora files at `$BASE` (see AC-7) is still present (sorted tag list diff
      empty); `bash .tad/evidence/yolo/cora-conductor-role/phase1-slim-ac.sh AC-1 AC-2 AC-3 AC-4 AC-5 AC-7 AC-8 AC-9`
      rc 0; `bash .tad/hooks/lib/skill-body-verify.sh` rc 0;
      `bash .tad/hooks/lib/state-surface-check.sh` rc 0; `bash .tad/hooks/lib/release-verify.sh`
      `path-refs` and `provenance` each rc 0 at the final commit.
- [ ] AC-7 (scope): every path changed in `git diff --name-only $BASE..HEAD` (BASE = HEAD before the
      phase's first commit, recorded in `phase1-grounding.md`; `1320ba8f` at Intake) is in Files
      Likely Affected below; none of `NEXT.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`,
      `docs/pm/status.md`, `.tad/active/epics/`, `.tad/memory/` is in any commit of the phase;
      no concrete model name in added lines
      (`git diff $BASE HEAD -U0 | grep '^+' | grep -ciE 'opus|sonnet|haiku|gpt-[0-9]|gemini'` = 0).
- [ ] AC-8 (behaviour, judgment): `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke-judge.md`
      written by a subagent that did not write or review the Cora skill change, starting with
      the verdict header (`dispatch_id`, `verdict: PASS`, `p0_count: 0`,
      `judged: commit:<sha of the final skill commit>`), with lines `claude: 6/6 pass` and
      `codex: 6/6 pass`; every transcript under `.../phase1-smoke/` has
      `### harness exit: 0` and an mtime after the judged commit. A codex cell NOT RUN makes
      the verdict PARTIAL, which is a stop (reason 1), never a pass.
- [ ] AC-9 (independent verdicts): `phase1-p0-check.md` (design, P0 only, per D3),
      `phase1-impl-review-cr.md` and `phase1-impl-review-{domain}.md` (two distinct reviewer
      types), `phase1-gate3-verdict.md` and `phase1-gate-report.md` all exist under
      `.tad/evidence/yolo/cora-carry-forward-fixes/`, each starts with the verdict header,
      each final one has `p0_count: 0` and verdict PASS or CONDITIONAL, and each `judged:`
      names the final commit (or a commit whose diff to it touches no file in the list below
      except the provenance ledger). The gate report says for each of P2-A, P2-B, C2, C6, C7
      closed or not, with the commit.

#### Files Likely Affected

- `.agents/skills/cora/SKILL.md` (MODIFY — P2-A, C6, C7)
- `.agents/skills/cora/references/conductor-protocol.md` (MODIFY — P2-A, P2-B, C2, C7)
- `.agents/skills/alex/references/distillation-loop-protocol.md` (MODIFY — C2)
- `.tad/provenance/claude-legacy.tsv`, `.tad/provenance/MANIFEST.sha1` (REGEN)
- `.tad/evidence/yolo/cora-carry-forward-fixes/` (CREATE, gitignored — `phase1-ac.sh`,
  `phase1-smoke.sh`, transcripts, review and verdict files)

Depends on decisions: none. D3 sets the review depth named in AC-9 (one P0-only design
check); under a fuller depth AC-9 adds `phase1-design-review-cr.md` and
`phase1-design-review-{domain}.md`.

### Phase 2: Queue and run record

**Status:** ✅ Closed as PARTIAL by the human's option 2 ("选2") — Gate 4 PARTIAL p0 1 (`.tad/evidence/yolo/cora-carry-forward-fixes/phase2-gate-report.md`); Gate 3 PARTIAL p0 1; queue judge-2 FAIL p0 1 (4/6); C10 and C8 partly closed; carry-forward CF-1..CF-10 to the parent Epic's Phase 4 (gate report section 5). The verdicts are not upgraded.
**Execution:** Codex session resumed from the pointer and ran p2-y3-1, p2-y4-r1-p0, p2-y5-1 (Claude cells refused there); from p2-y5-2 on, conducted in the Claude Code session by the human's answer (see Decisions). The Scope's "runs in a Codex session" below is the plan as written at Intake, superseded by that decision.

#### Scope

Written for the recommended options D1 (a), D2 (a), D4 as proposed. This phase runs in a Codex
session with `$cora`, resumed from the pointer after the human ends the Claude Code session.

- **C10 (D2 a)**: a scripted headless scenario with two fixture Epics, built like the parent's
  Phase 1 smoke (`.tad/evidence/yolo/cora-conductor-role/phase1-slim-behaviour.sh`: throwaway
  fixture project outside the repo, harness note switching dispatch off, `NEXT:`/`STOP:` lines,
  transcripts plus a before/after diff). New file `phase2-queue.sh` in this Epic's evidence
  directory, three scenarios, each with two approved Epics in the session-state queue block:
  - **q1** Epic A `current`, its last phase at Y8 with Gate 4 PASS on disk, Epic B `waiting`
    and approved: Cora marks A done, moves `current` to B in the same edit, starts B's
    phase 1 (`NEXT:` naming B's first step) without asking, and does not ask for acceptance
    or archiving (queue not empty).
  - **q2** Epic A `current` with an unanswered `Stopped:`, Epic B `waiting`: she restates A's
    question and waits; nothing for B is dispatched or started; the queue block stays ACTIVE.
  - **q3** Epic A `done`, Epic B `current` and finished at Y8: she writes `IDLE`, and asks
    acceptance (and archiving as its own question) for both Epics once.
  Run on Claude Code and Codex, against the commit that holds the Phase 1 skill; judged by an
  independent subagent. No change to the Cora skill unless a scenario fails; a failure is
  reported, and a fix is its own handoff, not part of this phase.
- **C8**: a short per-harness record of this Epic's run,
  `.tad/evidence/yolo/cora-carry-forward-fixes/run-record.md`, written by the Blake subagent
  from disk only (the Epic's `## Run` and Decisions, Cora's journal
  `.tad/evidence/journal/conductor-cora-carry-forward-fixes-*.md`, the dispatch outputs and
  their `dispatch_id` lines, `git log`). One section per harness (Claude Code, Codex), each
  with: how Cora dispatched (the harness's subagent facility, by tier, no model names), where
  the restart happened (the `## Run` block as found at resume, quoted), what resumed and what
  did not, and "Not run" (Cursor, OpenCode, anything skipped). It covers the run up to the
  Phase 2 Y5 dispatch; the Phase 2 gate report states which harness ran Y6 and Y7.
- **Books**: after Y7, an independent check that this Epic, `.tad/active/session-state.md`
  (Cora's block) and `NEXT.md` agree with each other and with `git log` (Epic success
  criterion 4).

If Codex has no subagent facility in this setup, Cora stops at the first Phase 2 dispatch
(reason 1); that stop, quoted from the `## Run` block, is the Codex result in `run-record.md`,
and the human decides where the phase continues.

Under the other options: **D1 (b)** — Phase 2 runs in a second Claude Code session; the
record's Codex section says "not run" and AC-4's Codex rows drop. **D2 (b)** — q1-q3 are
replaced by a second real Epic queued behind this one; AC-1/AC-2 become checks of the real
queue block's transitions in `session-state.md` history and `git log`. **D2 (c)** — no
`phase2-queue.sh`; AC-1/AC-2 drop, and `run-record.md` and the gate report state C10 is
text-only and stays open. **D4 otherwise** — AC-4 names the session where the restart
actually happened.

#### Acceptance Criteria

Run from the repo root under `bash`. The handoff writes these as
`.tad/evidence/yolo/cora-carry-forward-fixes/phase2-ac.sh`, rc 0 = all pass.

- [ ] AC-1 (C10 fixtures): `bash .../phase2-queue.sh build <q1|q2|q3> <dir>` builds each
      fixture outside the repo with rc 0, and each fixture's
      `.tad/active/session-state.md` has `Conductor status: ACTIVE` and two Epic lines in
      `Queue:` (grep count 2); `phase2-queue.sh rubric` prints rows q1, q2, q3.
- [ ] AC-2 (C10 behaviour, judgment): `.../phase2-queue-judge.md` by a subagent that did not
      write the fixtures or the Cora skill, starting with the verdict header (`dispatch_id`,
      `verdict: PASS`, `p0_count: 0`, `judged: commit:<sha>`), with `claude: 3/3 pass` and
      `codex: 3/3 pass`, one table row per scenario and harness quoting the transcript;
      every transcript in `.../phase2-queue/` has `### harness exit: 0` and an mtime after
      the judged commit. A NOT RUN cell (quoted error) makes the verdict PARTIAL: a stop
      (reason 1), never a pass.
- [ ] AC-3 (C8 record exists and is complete): `run-record.md` starts with `dispatch_id:`
      and has the headings `## Claude Code`, `## Codex`, and under each `### Dispatch`,
      `### Restart`, `### Resumed`, `### Not resumed`, `### Not run` (grep count 10); no
      model name (`grep -ciE 'opus|sonnet|haiku|gpt-[0-9]|gemini'` = 0).
- [ ] AC-4 (C8 record true to disk, judgment): `.../phase2-record-check.md` by an independent
      subagent, verdict header first, `verdict: PASS`, `p0_count: 0`,
      `judged: <sha256 of run-record.md>`; it checks each claim of the record against the
      named file, and confirms: the `## Run` block quoted as found at resume matches the
      Phase 1 end state; the first dispatch id issued in the Codex session has its output
      on disk with that `dispatch_id` and an mtime after `phase1-gate-report.md`; the
      human was not asked to re-explain anything (no `Stopped:` raised at resume other than
      one the pointer rules require, quoted).
- [ ] AC-5 (books agree, judgment): `.../phase2-books-check.md` by an independent subagent,
      verdict header first, `verdict: PASS`, `p0_count: 0`; it compares the Epic's Phase Map
      and `## Run`, Cora's block in `session-state.md`, the `NEXT.md` entry and
      `git log --oneline` of the Epic's commits, and lists each mismatch (none for PASS).
- [ ] AC-6 (scope): `git diff --name-only $BASE..HEAD` (BASE recorded in
      `phase2-grounding.md`) touches no file under `.agents/skills/`, `AGENTS.md`, `tad.sh`,
      `.tad/hooks/`, `.tad/project-knowledge/`; and none of `PROJECT_CONTEXT.md`,
      `ROADMAP.md`, `docs/pm/status.md`, `.tad/memory/`.
- [ ] AC-7 (independent verdicts): `phase2-p0-check.md`, `phase2-impl-review-cr.md`,
      `phase2-impl-review-{domain}.md` (two distinct types), `phase2-gate3-verdict.md`,
      `phase2-gate-report.md` exist, each starts with the verdict header, final ones
      `p0_count: 0` and PASS or CONDITIONAL; the gate report states C8 and C10 closed or
      not and names the harness that ran Y6 and Y7.

#### Files Likely Affected

- `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue.sh` (CREATE, gitignored —
  adapted from the parent's `phase1-slim-behaviour.sh`)
- `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue/` (CREATE — transcripts)
- `.tad/evidence/yolo/cora-carry-forward-fixes/run-record.md` (CREATE — C8)
- `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-ac.sh`, review, check and verdict files
  (CREATE)
- No tracked file is expected to change (the evidence directory is gitignored, C12 stays with
  Phase 4); Cora's own writes (Epic, session-state block, `NEXT.md`, journal) are hers, not
  this phase's deliverable.

---

## Context for Next Phase

### Completed Work Summary
- Phase 2: C10 and C8 partly closed (queue cells 4/6; run record CONDITIONAL); Gate 4 PARTIAL p0 1, closed by the human's "选2"; open P0 = acceptance and archiving asked as one question (skill gap CF-1) → parent Phase 4.
- Phase 1: P2-A, P2-B, C2, C6, C7 closed in commits e3e0c3e1, aa19d75c (+ ledger a1698338, c666a2de); one smoke FAIL on C6 reworked once; Gate 4 PASS (`phase1-gate-report.md`).

### Decisions Made So Far
- 2026-10-14 — The human, in a new Claude Code session on `feat/cora-role`: "你是 Cora。把 cora-conductor-role 这个 Epic 第三阶段的遗留项做成一个 Epic 跑完。遗留项清单在 .tad/evidence/yolo/cora-conductor-role/phase2-gate-report.md 的 carry-forward 部分。" Cora read the Phase 3 list from section 5 of that report (P2-A, P2-B, C2, C6, C7, C8, C10) and wrote this Epic.
- 2026-10-14 — The human approved: "继续". D1 (a) Codex continuation as planned; D2 (a) scripted two-Epic scenario, independently judged; D3 slim depth; D4 restart after Phase 1 Gate 4; D5 (a) evidence path plus verdict file for C8/C10.
- 2026-10-14 — Conflict recorded: D3 (one P0-only design check) is below the conductor protocol's Y4 rule of two distinct design reviewers [A105]. The human's approval in this conversation ranks above the repository protocol (AGENTS.md, file authority order), so Y4 dispatches one P0-only check; Y6 keeps two distinct reviewer types.

- 2026-10-14 — Phase 2 conducting moved back to the Claude Code session by the human's answer to the Codex stop (quoted in `## Run`). Codex had resumed from the pointer and dispatched p2-y3-1, p2-y4-r1-p0, p2-y5-1; its stop was right, its diagnosis was not: Claude Code access works from the Claude desktop app session; a `claude` launched from inside Codex is a standalone CLI login, which the organization does not allow on subscription. The Claude queue cells are rerun here by a Blake subagent; the Codex cells stand as run. The human does not mix harnesses in one session for now. The Codex session must not continue this Epic.

- 2026-10-14 — After the second queue-judge FAIL (p2-y7-judge-2, p0 1: codex q3 folds archiving into the acceptance question; claude q1 a fixture defect), the human chose option 2: "选2". Phase 2 closes with C10 partly shown (4 of 6 cells pass); the acceptance/archive gap goes to the parent Epic's Phase 4 as a skill fix. The judge FAIL is not upgraded: Gate 3 and Gate 4 are written by independent subagents with that file in view.

### Known Issues / Carry-forward
- Branch `feat/cora-role`; work commits land there. Push is a stop (reason 3).

### Next Phase Scope
None: both phases closed. Remaining work goes to the parent Epic's Phase 4 (`phase2-gate-report.md` section 5, `phase1-gate-report.md` section 4).
---

## Notes
