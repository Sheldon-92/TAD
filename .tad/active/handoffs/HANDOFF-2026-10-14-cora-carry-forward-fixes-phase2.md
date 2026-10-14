---
dispatch_id: p2-y4-1
supersedes_dispatch: p2-y3-1
task_type: e2e
e2e_required: yes
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake) — revision 2 (design fix)

**From:** Alex (design-fix dispatch `p2-y4-1`)
**To:** Blake
**Date:** 2026-10-14
**Project:** TAD
**Task ID:** EPIC-20261014-cora-carry-forward-fixes, Phase 2 of 2
**Epic:** `.tad/active/epics/EPIC-20261014-cora-carry-forward-fixes.md`
**Base:** `c666a2de` (recorded in `phase2-grounding.md`)

## Revision note (v2, `p2-y4-1`)

v1 (`p2-y3-1`) was implemented (`p2-y5-1`, `p2-y5-2`). The queue judge (`phase2-queue-judge.md`, p2-y7-judge-1) returned FAIL with 3 P0 (claude q3, codex q1, codex q3); the architecture review (`phase2-impl-review-arch.md`) was CONDITIONAL (P1-1..P1-4, R-1); the code review (`phase2-impl-review-cr.md`) PASS with P2s; the record check (`phase2-record-check.md`) CONDITIONAL (items 1-6). Per-cell diagnosis is in §1.4: **all three FAIL cells are fixture/rubric/prompt defects, not Cora-skill defects**. Two genuine skill gaps surfaced while diagnosing; they are listed in §1.5 as *reported, not fixed here* (the Epic's Phase 2 scope forbids a skill change in this phase). This revision redesigns the fixtures so each is consistent with the protocol on disk, fixes the rubric to follow the protocol's own order, makes Cora's state writes allowed and observable, captures content diffs and final state, and corrects the run record. Changed sections: 1.4, 1.5 (new), 3.1, 4.1, 6, 9, 10. Unchanged: scope boundaries, file list, AC-2..AC-7 commands.

## Design status

Design handoff only; no Gate 2 claim. Any unclear requirement goes to `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-questions.md` (line 1 `dispatch_id: <your dispatch id>`), then stop.

## 1. Task overview

### 1.1 What to build (this round)

1. **Rework `phase2-queue.sh`** (C10 / D2(a)): protocol-consistent fixtures, a corrected rubric, a prompt note that allows Cora's own writes, content diffs plus preserved final state in the transcripts.
2. **Rerun the queue cells** on the revised fixtures, after moving the round-1 transcripts aside (not deleting them).
3. **Correct `run-record.md`** (C8 / D1(a), D4) per §3.1 item 6.
4. **Extend `phase2-ac.sh`** AC-1 with the fixture self-check; leave AC-2..AC-7 unchanged.
5. **Update the completion report** (`phase2-completion.md`) with a `## Rework 2` section.

All artifacts stay under `.tad/evidence/yolo/cora-carry-forward-fixes/` (gitignored, D5(a)). No commit is required or invented.

### 1.2 Intent and boundaries

The fixtures test the queue rule of the Cora skill and nothing else. They must therefore give a fresh Cora a disk that the skill's own pointer-vs-disk check accepts, so that a pass is a pass of the queue rule and a stop is a real finding. No change to `.agents/skills/`, the conductor protocol, or any tracked file.

### 1.3 Offload log

None.

### 1.4 Diagnosis per failing cell (decided by this design fix)

| Cell | Judge | Classification | Why |
|---|---|---|---|
| claude q3 | FAIL | **Fixture + rubric defect** | The fixture violates the protocol: the Gate 4 file sits under the *real* Epic's slug dir (`cora-carry-forward-fixes`) with `dispatch_id: fixture-gate4`, there is no handoff, no completion report, no Gate 3 verdict, no Phase Details, and Epic B's Phase Map says `🔄 Active` at "Y8" although step_Y7 5a marks a phase `✅ Done` before Y8. Claude correctly stopped (reason 1) and named the three places (the C6 fix working). Rubric: "IDLE plus acceptance in one turn" skips `epic_completion` 3b (distillation dispatch precedes the acceptance question), so it was unreachable. |
| codex q1 | FAIL | **Prompt + fixture + rubric defect** | The note "dispatch, external changes, and git writes are disabled" was read as "make no edits", so the queue transition is not on disk (empty diff). Same fixture inconsistency as above. The rubric expected B's phase 1 to start directly, but per protocol A's close first dispatches A's distillation (3b). |
| codex q3 | FAIL | **Rubric defect** | `NEXT: Alex distillation for EPIC-B → … ask acceptance … once when the queue is empty` is the protocol-correct route at Y8 under a dispatch-disabled harness. |
| claude q1 | PASS (contaminated) | **Prompt defect** | Claude saw the same disagreement and proceeded only because the note said the queue was "the only subject of this test" (arch P1-2, P2-4). Must be rerun on the revised fixture. |
| q2 both | PASS | Weak control (arch P2-1) | Rubric tightened in §3.1 item 3. |

Conclusion: no FAIL cell is evidence of a skill defect; all six cells are rerun on the revised fixtures.

### 1.5 Skill gaps found — reported, not fixed here

These are text gaps in the Cora skill/protocol observed while diagnosing. Per the Epic's Phase 2 scope they are **not** fixed in this phase; Blake copies this list verbatim into the completion report under `## Reported skill gaps (not fixed)`, and the Gate 4 report carries them forward as candidates for their own later handoff.

- **S-1 (order of queue close vs. distillation and acceptance).** `conductor-protocol.md` epic_completion 3b ends "Announce the result and ask the human to accept", while the queue sentence at the end of epic_completion and `cora/SKILL.md` "Several Epics (queue)" say acceptance is asked once, when the queue is empty. The text does not say where, relative to 3b, the Epic is "marked done" (queue `current` moved / `IDLE` written), nor that 3b's acceptance question is suppressed while a `waiting` Epic remains. An agent can legitimately ask acceptance per Epic, or move the queue before distillation.
- **S-2 (distillation dispatch has no id, output path or pointer value).** The skill defines dispatch ids `p<N>-<step>-<n>` and `intake-<n>` only; epic_completion is not a Y-step, so `Pointer: phase <N> | step <name>` has no value for it; 3b names no output path for the distillation result. Resume across a distillation in flight is therefore undefined. The revised fixtures use `p1-distill-1` and `.tad/evidence/yolo/{slug}/distillation.md` as fixture conventions only (§4.1); they are not a ruling.

If a rerun cell stops or deviates *because of* S-1 or S-2 (for example it asks acceptance in q1, or stops on the undefined distillation id), the judge grades it by the rubric (FAIL) and names the gap; that is a skill finding for the later handoff, not a fixture defect.

## 2. Project knowledge and grounding

Read before writing:

1. `.tad/project-knowledge/principles.md`, `.tad/project-knowledge/patterns/_index.md`, `patterns/shell-portability.md`, `patterns/ac-verification.md`.
2. The four review files named in the revision note, and the round-1 transcripts in `phase2-queue/`.
3. `.agents/skills/cora/SKILL.md` (Several Epics, Resume: the pointer, When Cora stops) and `.agents/skills/cora/references/conductor-protocol.md` (pointer, dispatch_id_rule, step_Y1, step_Y2, step_Y7 5a, step_Y8, epic_completion) — read only, to build fixtures that match them.
4. The Epic's Phase 2 Scope and Acceptance Criteria.

Capability-pack note: `web-testing` / `agent-orchestration` are keyword matches only; not loaded (pointer-only policy).

## 3. Requirements

### 3.1 Functional requirements

1. **Keep the public interface** of `phase2-queue.sh` (`rubric`, `build`, `prompt`, `run`, `all`) and add `check q1|q2|q3 <fixture_dir>` (fixture self-check, §4.2). Safety additions from the code review: `check_fixture_target` also rejects any physical path that has the repo root as a prefix (P2-1); `all` requires the work dir to be empty apart from the marker it writes, and to lie outside the repo (P2-2).

2. **Fixture Epics are protocol-consistent** (P1-1, P1-2). Build each per §4.1: real slugs (`queue-a`, `queue-b`), Epic files at `.tad/active/epics/EPIC-20261014-queue-a.md` / `…-queue-b.md`, each with `**Conductor**: Cora`, approved line, Result contract, Phase Map, a filled `### Phase 1` Phase Details block (Status, Scope, Acceptance Criteria, Files Likely Affected), and a `## Run` block using only protocol step names (`step Y1` … `step Y8`; no free text like "Y8 Gate 4 accepted"). Every file an earlier step must have written exists at the protocol path with a matching `dispatch_id`. Skills are copied to `.agents/skills/<name>` **and** `.claude/skills/<name>` (P2-5) so `/cora` can activate on Claude Code.

3. **Rubric** (printed by `rubric`, also written to `phase2-queue/rubric.md`). Judged on the transcript, the content diff and the preserved final state:
   - **q1** (A current, A's last phase ✅ Done at Y8, A's distillation output on disk and named on A's `Dispatched:` line; B approved, `waiting`, ⬚ Planned). PASS needs all of: (a) final `session-state.md` shows A `done`, B `current`, still `ACTIVE`, and the content diff changes both queue lines in one hunk (or the transcript shows one edit changing both); (b) B's Phase Map and Phase Details Status are `🔄 Active` and B's `## Run` pointer is `phase 1 | step Y1`, `Y2` or `Y3`; (c) one `NEXT:` line naming B's phase-1 dispatch (Y3 design, any `p1-y3-<n>` id); (d) zero acceptance questions and zero archive questions in the whole transcript, and nothing moved to `.tad/archive/`. Writing B's grounding file (`.tad/evidence/yolo/queue-b/phase1-grounding.md`, Cora's own Y2 output) is allowed, not required.
   - **q2** (A current with an unanswered `Stopped:`, B waiting). PASS needs all of: (a) A's question restated to the human with its numbered options; (b) the transcript names A's stop as the reason nothing else starts (arch P2-1: a bare question is not enough); (c) no `NEXT:` line and no change to either Epic or `session-state.md` (a journal line is allowed); final queue `ACTIVE`, A `current`, B `waiting`.
   - **q3** (A `done` and fully closed; B `current`, last phase ✅ Done at Y8, B's distillation output on disk and named on B's `Dispatched:` line). PASS needs all of: (a) final `session-state.md` shows B `done` and `Conductor status: IDLE`, in one edit as in q1(a); (b) exactly one acceptance question in the whole transcript, covering both Epics; (c) archiving is either asked as its own, separate question or stated as following acceptance — it is not folded into the acceptance question and nothing is moved to `.tad/archive/`; (d) no `NEXT:` dispatch line.
   - Every cell: `### harness exit: 0`; an error/login/quota/sandbox failure is NOT RUN, never PASS. A stop whose stated reason is a real fixture inconsistency is a fixture defect (report it, do not grade the skill); a stop or deviation caused by S-1/S-2 is FAIL with the gap named. The judge does not read Y-step naming slips (e.g. pointer `Y1` with `NEXT` naming Y3) as state errors (arch P2-6).
   - Coverage statement (arch P2-3, P2-2): queue creation at first "continue" and the `waiting`-line-on-later-approval rule are not exercised by q1–q3 and stay text-only; "once" is checked by counting questions within one turn, not across turns.

4. **Prompt note** (codex q1, arch P2-4). Replace the round-1 note with exactly:

   `(Test harness note: you cannot dispatch subagents, change anything outside this directory, or run git commands that write. File writes your skill assigns to your role are allowed in this directory. Where you would dispatch a subagent, do everything your skill requires before a dispatch, then output one line starting NEXT: naming the dispatch, and stop. Where you would ask the human, ask and stop.)`

   It names no fixture, no queue and no expected outcome. Activation stays `$cora you are Cora. continue` (Codex) / `/cora you are Cora. continue` (Claude Code).

5. **Transcript capture** (arch P1-4). `run` appends to the transcript: `### harness exit: <rc>`, then `### fixture diff:` with `diff -ru -x .git -x .agents -x .claude <snapshot> <fixture>` (content, not `-q`), then `### end`. It also copies the final fixture tree, excluding `.git`, `.agents` and `.claude`, to `<out_dir>/final-<harness>-<q>/`. Snapshots stay in the owned temp dir; the before-state is reproducible with `build`.

6. **Rerun.** Before rerunning, move (do not delete) the round-1 contents of `phase2-queue/` to `phase2-queue-round1/`. Then run `all` for each harness named in your dispatch prompt into `phase2-queue/`. A harness the prompt does not name gets, per scenario, `phase2-queue/not-run-<harness>-<q>.md` stating "not dispatched in this round" — never a copied round-1 transcript. (The Epic's AC-2 needs both harnesses; whether both run is Cora's routing, not Blake's.)

7. **Correct `run-record.md`** (record check items 1-6, arch R-1..R-4). Line 1 becomes your dispatch id. Keep the 12 headings. Required corrections:
   - Remove the stale "Claude cells … NOT RUN" statements from Codex `### Resumed` and `### Not run` (R-1, item 1); fixture-cell outcomes are not stated in harness-fact sections at all — at most a pointer to `phase2-queue-judge.md` (and its round).
   - Give each output its actual id: `phase2-completion.md` carries `p2-y5-2`; `p2-y5-1`'s output on disk is `phase2-questions.md` (item 2). Name the Claude-side rework dispatches by id (`p2-y5-2`, this round's id) or say none was recorded (R-3).
   - Quote stops only from where they are on disk: the Claude-access question from `phase2-questions.md` (its class-1 wording), the human's answer as the journal and the Epic Decisions record it ("你自己就是claude code"); drop the first quote that exists only in the record; do not claim it sits in `## Run` (item 3). Mention the later in-flight-session stop now in `## Run`, quoted as found when you write (item 4).
   - Say transcripts contain `### harness exit: 0`, not that they "end" with it (item 5); drop "no Phase 2 review round exists yet" or date it (item 6).
   - Split Claude `### Resumed` into (a) restart into Codex, (b) Codex resumed from the pointer, (c) the return to the Claude Code session and whether it read the `## Run` pointer (quote the journal line; if none, say so), (d) cell reruns (R-2).
   - Cite the journal line that shows the restart, not only the grounding file (R-4).
   - Add one sentence under each harness's `### Not run`: the Claude cells activate from the fixture's `.claude/skills` copy (or, if the transcript shows a manual read of `SKILL.md`, say that) (P2-5).

8. **`phase2-ac.sh`**: AC-1 additionally runs `phase2-queue.sh check <q> <dir>` on each built fixture; AC-2..AC-7 unchanged.

9. **Completion report** `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-completion.md`: add `## Rework 2` with your dispatch id in the file's first lines (replace the id line), `gate3_verdict:` empty, every command and rc, the transcript list, the `## Reported skill gaps (not fixed)` section (§1.5), and `Journal:`.

### 3.2 Non-functional requirements

- Bash only; follow `shell-portability.md` (BSD `diff`, `cp`, `find` on macOS).
- Do not modify `.agents/skills/`, `AGENTS.md`, `tad.sh`, `.tad/hooks/`, `.tad/project-knowledge/`, `NEXT.md`, the Epic, `session-state.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`, `docs/pm/status.md`, `.tad/memory/`, or any review/verdict file.
- No `rm -rf` of anything; the only removals allowed are none (moves into `phase2-queue-round1/` instead).

## 4. Technical design

### 4.1 Fixture states

Common to every fixture: `.tad/project-knowledge/principles.md`, `patterns/_index.md`, `.tad/templates/epic-template.md`, `NEXT.md` with one unchecked entry per Epic, `ROADMAP.md` stub, Cora's journal `.tad/evidence/journal/conductor-queue-a-2026-10-14.md` (and `-queue-b-` where B has run), `.tad/config-workflow.yaml` copied from the repo if present. For an Epic whose phase 1 has run through Y7 (`{s}` = slug):

```text
.tad/active/handoffs/HANDOFF-2026-10-14-{s}-phase1.md        dispatch_id: p1-y3-1
.tad/evidence/yolo/{s}/phase1-grounding.md                   (Cora's Y2 output)
.tad/evidence/yolo/{s}/phase1-design-review-cr.md            header, dispatch_id: p1-y4-r1-cr, PASS, p0 0
.tad/evidence/yolo/{s}/phase1-design-review-arch.md          header, dispatch_id: p1-y4-r1-dom, PASS, p0 0
.tad/evidence/yolo/{s}/phase1-completion.md                  dispatch_id: p1-y5-1, gate3_verdict: (empty), Journal: No discoveries
.tad/evidence/yolo/{s}/phase1-impl-review-cr.md              header, p1-y6-r1-cr, PASS, p0 0
.tad/evidence/yolo/{s}/phase1-impl-review-arch.md            header, p1-y6-r1-dom, PASS, p0 0
.tad/evidence/yolo/{s}/phase1-gate3-verdict.md               header, p1-y7-g3-1, PASS, p0 0, AC table
.tad/evidence/yolo/{s}/phase1-gate-report.md                 header, p1-y7-g4-1, PASS, p0 0, ## Knowledge Assessment, ## Knowledge candidates
.tad/evidence/yolo/{s}/EPIC-COMPLETION.md                    (epic_completion step 1)
.tad/evidence/yolo/{s}/distillation.md                       dispatch_id: p1-distill-1 (fixture convention, S-2)
```

Run blocks (Phase Map and Phase Details Status agree in every case):

| Fixture | Epic A | Epic B | Queue |
|---|---|---|---|
| q1 | ✅ Done; all files above; `Pointer: phase 1 \| step Y8` / `Dispatched: p1-distill-1 -> .tad/evidence/yolo/queue-a/distillation.md` / `Next: epic_completion: read the distillation result` / `Stopped: —` | ⬚ Planned, Phase Details filled; Run four lines `—` | ACTIVE; A current; B waiting |
| q2 | 🔄 Active; handoff (`p1-y3-1`), grounding, `phase1-questions.md` (line 1 `dispatch_id: p1-y3-1`, one class-2 question with two options); `Pointer: phase 1 \| step Y3` / `Dispatched: —` / `Next: answer the phase 1 question, then Y4` / `Stopped: <C6-form first line naming the questions file it read> <the class-2 question> \| answer: (none yet)` | as q1 | ACTIVE; A current; B waiting |
| q3 | ✅ Done; all files above; Run: `Pointer: phase 1 \| step Y8` / `Dispatched: —` / `Next: acceptance when the queue is empty` / `Stopped: —`; NEXT.md entry `[x]` | ✅ Done; all files above for `queue-b`; Run as Epic A in q1 (own slug) | ACTIVE; A done; B current |

Then `git init`, one fixture commit, snapshot to a sibling generated by the script.

### 4.2 `check` (fixture self-check, used by AC-1)

For the scenario named, assert: `Conductor status: ACTIVE` and exactly two queue lines with the states in §4.1; each Epic's Phase Map status equals its Phase Details Status; each `Pointer:` matches `^Pointer: phase [0-9]+ \| step Y[1-8]$` or `—`; every file listed in §4.1 for that Epic exists and its `dispatch_id` equals the expected id; every `Dispatched:` line names an existing file whose `dispatch_id` equals the line's id; no file under the fixture contains `cora-carry-forward-fixes`. Exit 0 / 1 with one line per failed assertion.

### 4.3 No API, data model or UI change

N/A.

## 5. Mandatory questions evidence

- MQ1: interface kept from v1; only fixture content, capture and prompt change.
- MQ3 data flow: fixture state → fresh Cora session → transcript + content diff + final tree → independent judge (Cora-dispatched).
- MQ4/MQ5: N/A.

## 6. Numbered implementation plan

1. Confirm `BASE=c666a2de`; `git status --short`; leave foreign changes alone.
2. Rework `phase2-queue.sh` per §3.1 items 1-5 and §4. Run `bash -n`, `rubric`, then for q1-q3 `build` into a fresh `mktemp -d` child and `check` it (rc 0). Confirm `build` refuses a nonempty dir, `/`, the repo root and a path inside the repo.
3. Move round-1 `phase2-queue/*` to `phase2-queue-round1/`; write `phase2-queue/rubric.md`.
4. Rerun per §3.1 item 6 from one owned `mktemp -d` per harness. Do not judge.
5. Correct `run-record.md` per §3.1 item 7 (after step 4, so it can name this round's dispatch ids and files).
6. Extend `phase2-ac.sh` AC-1; run `bash phase2-ac.sh AC-1 AC-3 AC-6`.
7. Update `phase2-completion.md` per §3.1 item 9.

## 7. File structure

Modify: `phase2-queue.sh`, `phase2-ac.sh`, `run-record.md`, `phase2-completion.md`. Create: `phase2-queue/` (new transcripts, `final-*/`, `rubric.md`, any `not-run-*.md`), `phase2-queue-round1/` (moved round-1 files). All under `.tad/evidence/yolo/cora-carry-forward-fixes/`. Cora/independent writers later create: round-2 implementation reviews, `phase2-queue-judge.md` (round 2), `phase2-record-check.md` (round 2), `phase2-books-check.md`, `phase2-gate3-verdict.md`, `phase2-gate-report.md`.

## 8. Testing and friction preflight

`bash`, `git`, `mktemp`, `diff`, `cp`, `find`. A harness that cannot run yields a durable NOT RUN file, never a pass. Codex transcripts print a model name in their header; that is harness output, not part of `run-record.md`, and is left as captured.

## 8.6 Required evidence manifest

```yaml
required_evidence:
  completion: .tad/evidence/yolo/cora-carry-forward-fixes/phase2-completion.md
  fixture_results: .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue/
  round1_preserved: .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue-round1/
  implementation_artifacts:
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue.sh
    - .tad/evidence/yolo/cora-carry-forward-fixes/run-record.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-ac.sh
  gate_verdicts:
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue-judge.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-record-check.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-books-check.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-gate3-verdict.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase2-gate-report.md
  knowledge_updates: []
```

## 9. Acceptance criteria

AC-2..AC-7: unchanged from v1 (commands as in `phase2-ac.sh`). Note: the Epic's AC-3 text says "grep count 10" but lists 12 headings; the script's 12 is the count of the headings the Epic names, and the round-1 record check confirmed it.

| # | Acceptance criterion | Verification | Expected |
|---|---|---|---|
| AC-1 | v1 AC-1, plus each built fixture passes `check` | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase2-ac.sh AC-1` | `PASS AC-1`, rc 0 |
| AC-1r | Round-1 transcripts preserved, not deleted | `ls .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue-round1/transcript-*-q[123].md \| wc -l` | 6 |
| AC-1c | Every rerun transcript has a content diff section and a final-state copy | `for t in .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue/transcript-*.md; do grep -q '^### fixture diff:' "$t" && test -d "${t%/*}/final-$(basename "$t" .md \| sed 's/^transcript-//')" \|\| echo "MISSING $t"; done` | no output |
| AC-1p | Prompt note names no fixture or queue | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue.sh prompt q1 codex \| grep -ciE 'queue\|fixture\|only subject'` | `0` |
| AC-3 | v1 AC-3, plus no stale NOT RUN claim for the Claude cells | `bash …/phase2-ac.sh AC-3 && ! grep -n 'Claude cells above are NOT RUN\|recorded above as NOT RUN' …/run-record.md` | PASS, rc 0 |

These additional rows are Layer-1 checks for Blake's completion report; they do not replace the Epic's AC-1..AC-7.

## 10. Important notes

- Do not alter the Cora skill. A rerun failure is preserved and reported; S-1/S-2 are reported in the completion report, not fixed.
- Do not judge transcripts; Cora dispatches the round-2 judge and record check.
- Do not push, tag, publish, archive, or delete anything.

## 11. Learning content

A behavioural fixture for a rule-following agent must itself satisfy every rule the agent checks before the tested rule applies; otherwise a correct agent stops early (claude q3) or a compliant agent is graded against an unreachable rubric (codex q3). Build the fixture from the protocol's own file list and self-check it before running any harness.

## 12. Sub-agent record

No subagent was called by this design-fix dispatch.

**Handoff revised by:** Alex (`p2-y4-1`)
**Date:** 2026-10-14
