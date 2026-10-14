---
task_type: code
e2e_required: no
research_required: no
handoff_revision: slim-1-addendum-1
---
# Addendum 1 to HANDOFF-2026-10-13-cora-phase1-slim.md (Alex, dispatch D21, 2026-10-13)
Base: commit `5ee1e70b` on `feat/cora-role`. Closes CR D18 (P1-1, P1-2), ARCH D19 (P1-1..P1-4) and the judge D20 smoke failures.
Where this file and the slim handoff differ, this file wins. No new mechanism, no new file. `alex/SKILL.md` is NOT edited (10-byte margin).
Allowed beyond slim §2, one edit each: `alex/references/intent-router-protocol.md` (delete line 212), `blake/SKILL.md:496` (one clause),
`phase1-slim-behaviour.sh` (NOTE, comment lines 17-18, rubric line 53), `phase1-slim-ac.sh` (AC-10 message only). Keep every `[Annn]` tag on edited lines.

## Decisions
1. **Knowledge entry (CR P1-1).** The Gate 4 Alex subagent writes it: it did not do the work, so it is the stranger the principle asks for.
   It may append new entries (typed schema of `distillation-loop-protocol.md`) to the `.tad/project-knowledge/` file its assessment names; never
   `principles.md`, never edit or delete an existing entry. A field it cannot fill → no entry; the gap is listed in the gate report, which names
   every entry written. Y8: Cora's journal line carries the gate-report path. Add this to the Gate 4 prompt (Y7) and to dispatch-mode (item 3).
2. **`*status` (CR P1-2).** Step1 item 3 becomes "list `HANDOFF-*.md` by file name only; the date is taken from the file name". The Active Handoffs
   table has two columns (Handoff, Date); the Priority column and "extract name, date, priority" go.
3. **Every Alex dispatch fires STEP 0 (ARCH P1-1).** Each Alex prompt in the protocol (Y3, Y4 fix, Y7 Gate 4, distillation, Phase Details of item 4)
   opens with: "You are Alex, dispatched by the conductor (Cora) for one step: {kind}. Read .agents/skills/alex/references/conductor-dispatch-mode.md
   and follow it." In `conductor-dispatch-mode.md` replace "Design step" + "What you may write" with one line per kind (still ≤ 40 lines):
   - Phase Details: write only the Phase Detail blocks of the Epic named. - Design: through `step1d`; write the handoff path named and your phase's block.
   - Design fix: read the review files named; write only the handoff path named. - Gate 4: write the gate report and item 1's entries; not the Epic.
   - Distillation: per `distillation-loop-protocol.md`; write its entries and the output file named. "Never" list unchanged.
4. **Phase Detail blocks (ARCH P1-2).** At Intake, after the Phase Map and before stopping for "continue", Cora dispatches one Alex subagent
   (strongest tier, kind Phase Details) to fill Scope, Acceptance Criteria and Files Likely Affected for every phase. The human approves the Epic
   with them in view. A phase's design subagent may refine its own block (item 3). Cora writes none of their content.
5. **Queue / Conductor status (ARCH P1-3).** Stays in `.tad/active/session-state.md` (Alex's guard already reads it there; moving it would cost bytes
   in capped `alex/SKILL.md`). Cora creates the block at the first "continue" (`ACTIVE`, that Epic `current`); a later approval adds a `waiting`
   line; in the edit that marks an Epic done she moves `current`; with no `current` and no `waiting` left she writes `IDLE`. A stop leaves it ACTIVE.
   The two whole-file writers carry it over: `handoff-creation-protocol.md:156` and `blake/SKILL.md:496` gain "keep any `## Conductor run (Cora)`
   section unchanged". Block missing while an Epic's `## Run` shows a run → pointer/disk disagreement (stop, reason 1). Body + `epic_completion`.
6. **No worktree (ARCH P1-4).** Y5: delete `isolation: worktree`. Replacement: the Blake subagent works on the Epic's branch in the main tree and
   commits with explicit pathspecs (`git add -- <paths>`, `git commit -- <paths>`; never `-A`, no push).
7. **Smoke harness.** New NOTE: "(Test harness note: subagent dispatch is switched off in this session, and so is anything that changes files or git
   state outside your own rules' writes. Reading files is allowed with any tool, the shell included. Where your rules have you dispatch a subagent,
   do not do its work; write one line starting with "NEXT:" naming the step and the role, then stop. Only where your rules list a stop reason, write
   one line starting with "STOP:"; a question inside a discussion is not a stop.)" Update comment lines 17-18 to match.
   Cora Activation gains one line: "If she cannot read files, she says so in one line, still answers what she can, and dispatches nothing."
   Rubric vs AC-10: bar stays strict. Rubric line 53 reads `codex: <n>/6 pass | NOT RUN — <reason>` and adds "anything but 6/6 pass fails AC-10";
   AC-10 keeps its test and its FAIL message quotes the count found. Same wording for `claude:`.
8. **P2s to fix now (one line each).**
   - ARCH P2-1: Intake writes `## Run` with the four lines, all `—`.  - ARCH P2-2: body line "Dispatched output present but `Next:` not advanced: read its header, treat it as the result just read".
   - ARCH P2-3: Y4 step 5 and Y6 step 4 route on "P0 or FAIL" like the body; a CONDITIONAL's review file path goes into the next dispatch prompt.
   - ARCH P2-4: Y5 step 3 becomes "run the verification commands listed in the handoff"; `npx tsc` / `npm test` / `npm run lint` go.
   - ARCH P2-5: distillation gaps are not answered by the conductor: no entry, and the gap is listed in Cora's acceptance message to the human.
   - ARCH P2-6: delete `intent-router-protocol.md:212`; Approval: "continue" approves only the Epic(s) the human names.
   - ARCH P2-7: body disagreement rule adds "a file an earlier step must have written is missing" (A020).
   - CR P2-1: Intake line 27 adds "; one that surfaces mid-run is a stop (reason 1)" [A016].  - CR P2-3: fix the "otherwise as extracted" header comment.
   - Left out: CR P2-2 (YAML tail tags; nothing parses these files). CR P2-4 is closed by item 5.

## Re-run and confirm
Re-run `bash .tad/evidence/yolo/cora-conductor-role/phase1-slim-ac.sh ALL` (AC-1..AC-9 PASS; body still ≤ 200 lines) and all six smoke scenarios on
both claude and codex (the skill text changed), then a fresh independent smoke judge; commit with explicit pathspecs; update the completion report.
On the new commit D18 (code-reviewer) confirms its P1-1, P1-2 and P2s, D19 (architecture) confirms its P1-1..P1-4 and P2s, the judge confirms item 7.
