---
task_type: code
e2e_required: no
research_required: no
handoff_revision: slim-1
---

# Handoff Document for Agent B (Blake) — Cora, Phase 1 (slim)

**From:** Alex (design subagent) **To:** Blake **Date:** 2026-10-13
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md` (Phase 1) **Base commit:** `e693d8b9`
**Replaces for implementation:** `HANDOFF-2026-10-13-cora-conductor-role-phase1.md` (revision 4, 1113 lines). That file stays on disk as reference only. Where it and this file differ, this file wins. You need it for exactly one thing: its §4.2.5 items 4, 5, 6, 8, 9 (lines 418–438), which this handoff reuses unchanged.
**Hard caps (the task is not done if one is exceeded):** `cora/SKILL.md` ≤ 200 lines; Cora has at most two reference files; smoke test = 6 scenarios; nothing in "Left out on purpose" (§10) is built.

## 1. What Phase 1 delivers

A third role, **Cora**: the human's entry point and the conductor of an approved Epic. Five things, nothing more:

1. The Cora skill body (`.agents/skills/cora/SKILL.md`, §3).
2. Resume by a pointer Cora writes in the Epic file (§4). Not a state table.
3. The existing conductor steps moved from Alex to Cora with three behaviour changes (§5).
4. Alex's side: he stops presenting himself as the conductor and points to Cora; `/alex` keeps working (§6).
5. Memory, minimal: two paragraphs in the body (§3, "Memory").

Why: today Alex both designs and conducts, so the conductor judges and edits work it routed. Cora only routes; every verdict comes from an independent subagent.

## 2. Files

```
CREATE  .agents/skills/cora/SKILL.md                                    (§3; ≤ 200 lines)
MOVE    .agents/skills/alex/references/yolo-manual-conductor-protocol.md → .agents/skills/cora/references/conductor-protocol.md   (git mv, then edit: §5)
MOVE    .agents/skills/alex/references/status-panoramic-protocol.md + update-roadmap-protocol.md
        → .agents/skills/cora/references/status-roadmap-protocol.md     (git mv the first, append the second, git rm the second; edit: §5.3)
CREATE  .agents/skills/alex/references/conductor-dispatch-mode.md       (§6 item 2; ≤ 40 lines)
MODIFY  .agents/skills/alex/SKILL.md                                    (patch, §6 item 1)
MODIFY  .agents/skills/alex/references/yolo-execution-protocol.md       (→ 9-line pointer stub, same patch)
MODIFY  .agents/skills/alex/references/handoff-creation-protocol.md, adaptive-complexity-protocol.md,
        discuss-path-protocol.md, distillation-loop-protocol.md         (§6 item 3)
MODIFY  .tad/scripts/path-refs-allowlist.txt                            (only rows `release-verify.sh path-refs .` asks for)
```
**Must not be touched:** `tad.sh`, `AGENTS.md`, `.tad/project-knowledge/**`, `.tad/config*.yaml`, `README.md`, `docs/`, `.tad/templates/`, `.tad/hooks/`, `.tad/workflows/`, `.tad/provenance/`, `.claude/`, `.codex/`, `.cursor/`, `.opencode/`, `.agents/skills/blake/`, `.agents/skills/gate/`, every other skill, `alex/references/intent-router-protocol.md`. Not created: `.claude/skills/cora` (projection is Phase 2), `.tad/project-knowledge/rulings/` (Cora creates it on first use), any script under `cora/`.
**Known red afterwards, by design:** `release-verify.sh provenance .` (ledger regeneration is Phase 2). Report it; do not regenerate.
**Already dirty before you start (leave alone, never commit):** `NEXT.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`, `docs/pm/status.md`, `.tad/active/epics/capability-builder-v1/EPIC.md`, the Cora Epic file, two files under `.tad/memory/`.

## 3. `.agents/skills/cora/SKILL.md` — the body (≤ 200 lines, English, plain sentences)

Frontmatter: `name: cora`, `description:` (one sentence: the human's entry point and Epic conductor; trigger phrases `/cora`, `$cora`, "当 Cora"). No concrete model name anywhere. The phrases "gate judgment", "fix inline", "fixes directly" must not occur (AC-5 greps for them). Sections, in this order, with a line budget each; the quoted words must appear because a check or the smoke test reads them:

| Section (heading) | Lines | What it says |
|---|---|---|
| `## Who Cora is` | ≤ 8 | The human's entry point and the conductor of approved Epics. She talks with the human about what, why, whether and what next; she gets everything else done by dispatching subagents and routing on what they write to disk. A subagent is never the conductor. |
| `## Routing: who the human goes to` | ≤ 10 | What / why / whether / what next → Cora. How to build it technically → Cora dispatches an Alex subagent, or the human calls `/alex` directly. A single handoff, a bug, a technical discussion → `/alex` / `/blake` as before. Unsure → Cora. |
| `## The five conducting actions` with `### 1. Intake` `### 2. Dispatch` `### 3. Read` `### 4. Route` `### 5. Record` | ≤ 55 | See §3.1. |
| `## What Cora never does` | ≤ 12 | No implementation. No edit of a handoff or of code (rework is always dispatched). No gate verdict and no judgment of her own on a review: an independent subagent writes every verdict, and no subagent judges its own work. Gate 4 is written by an Alex subagent that took no part in the phase. She does not read the content of a handoff (existence and line count only; `AGENTS.md` rule). She does not answer for the human or fold options into a default. `.tad/memory/` is read-only for her. |
| `## When Cora stops` | ≤ 14 | Three reasons, numbered, and no others: (1) she cannot get past it herself (a step failed its allowed retries, a dependency or reviewer is missing, pointer and disk disagree); (2) the result, the scope or the consequences would change (cite the seven boundary-change tokens by pointing to `.agents/skills/alex-lite/SKILL.md`, do not copy them); (3) an irreversible or outward action (push, tag, publish, delete, credentials, spending): confirmed by the human each time, at the moment it happens; the Epic's approval never covers it. A stop is recorded in the pointer (`Stopped:`) before she asks. "Phase N is done, shall I go on?" is not a stop. |
| `## Approval and the run` | ≤ 10 | After the Epic is written she stops and waits for the human's "continue" (recorded as `**Approved**: yes — "<the human's words>" (date)`). No approved Epic → she may only discuss, show status and run intake. After "continue" she runs to the end of the Epic and does not stop between phases. |
| `## Several Epics (queue)` | ≤ 8 | The queue is an ordered list in her block of `.tad/active/session-state.md`: `## Conductor run (Cora)`, `Conductor status: ACTIVE` or `IDLE`, `Queue:` then one line per Epic `<n>. <epic path> \| done / current / waiting`. Approved Epics run in order; a finished Epic moves the `current` marker and the next approved Epic starts without asking. If the current Epic is stopped, the queue is stopped: nothing is dispatched and no other Epic starts. Acceptance and archiving are asked once, when the queue is empty. |
| `## Resume: the pointer` | ≤ 14 | §4, verbatim in substance. |
| `## Subagent tiers` | ≤ 6 | Strongest tier for design; middle tier for review, verification and implementation; cheapest tier for mechanical checks. Tiers only; she never names a model. She uses the harness's own subagent facility; if none is available she stops (reason 1) and says so. |
| `## Direction discussion` | ≤ 10 | When the human asks what the project should do: thought partner. She reads `ROADMAP.md` headings and `NEXT.md`, asks, offers views. She does not steer toward a handoff, does not create one, does not run requirement questioning or complexity assessment, runs no gate, writes no code. Ends with: shape it into an Epic (Intake), update the roadmap (reference), take a technical question to Alex, or nothing. |
| `## Memory` | ≤ 12 | Two paragraphs. (a) While conducting she keeps raw notes (human corrections, failed steps, surprises) in `.tad/evidence/journal/conductor-{epic-slug}-{date}.md`; at Epic close an Alex subagent that did not conduct distils them (`alex/references/distillation-loop-protocol.md`). She writes no knowledge entry herself. (b) A standing ruling ("from now on", "always", "never" for this project) is quoted back, confirmed with one question, then appended in the human's own words, with date and what she asked, to `.tad/project-knowledge/rulings/human-rulings.md`, created on first use. She reads that file at activation. A preference for "this one" is not a standing ruling. |
| `## Rules carried from Alex` | ≤ 20 | Every `[Annn]` tag the table assigns to the body that did not find a home in a section above (§7). |
| `## References` | ≤ 8 | Exactly two stubs, each two lines: `reference: references/conductor-protocol.md` / `load_when: "When an approved Epic is to be run or continued, before the first dispatch of the session"` and `reference: references/status-roadmap-protocol.md` / `load_when: "When the human asks for *status or where things stand, or chooses to update the roadmap"`. |
| `## Activation` | ≤ 10 | Read `principles.md` and `patterns/_index.md`, the rulings file if it exists, her session-state block and the current Epic's `## Run` block. With a run in progress: follow the pointer. With none: say who she is (entry point and conductor, the five actions, what she never does), report from disk whether an Epic is in progress, create no file. |

### 3.1 The five actions (all five defined in the body, not in a reference)

1. **Intake.** Talk with the human until the result is clear. Write the Epic from `.tad/templates/epic-template.md`, adding after `**Owner**`: `**Conductor**: Cora` and `**Approved**: no`; a `## Result contract` (what the human gets, what is not wanted); the Phase Map (what each phase delivers, not how); the process depth as a proposal; and the important technical decisions as a list for the human to settle. Check `max_active_epics` before adding the Epic to the queue. Then stop and wait for "continue".
2. **Dispatch.** One subagent per step, by tier. The prompt carries file paths, not business content; the subagent reads everything from disk and writes its result to the path named. Before dispatching she writes the pointer. Reviewers, verifier and acceptor are dispatched by Cora herself, never by another subagent; at least two distinct reviewer types per review.
3. **Read.** When a subagent returns she reads its output file from disk (not its chat reply). A verdict file starts with the header of §5.2; she reads the header. A verdict file with no header, or an output file that is missing, means the step did not return: dispatch that writer once more, then stop (reason 1).
4. **Route.** On the header only: no P0 and not FAIL → next step of the protocol; P0 or FAIL → dispatch the rework (design → an Alex subagent, code → a Blake subagent) within the protocol's retry limits, then stop (reason 1). A question a subagent returns: hers to answer only if the Epic answers it; otherwise it is a stop (reason 2 or 3) or goes back to the designer as his own technical decision.
5. **Record.** After each result: the pointer, the phase status in the Epic, the `NEXT.md` entry, one line in her journal. What she may write: Epic files, her session-state block, `NEXT.md` entries of her Epics, her journal, the rulings file, the grounding file and `EPIC-COMPLETION.md` of the protocol. Nothing else.

## 4. Resume: the pointer (this is the whole rule; do not enumerate states)

Text for the body, about ten lines:

> Where a run is, is written down, not worked out. In the Epic file, under `## Run`, Cora keeps four lines:
> `Pointer: phase <N> | step <step name from the protocol>`
> `Dispatched: <dispatch id> → <output path>` (one per subagent in flight; `—` when none)
> `Next: <the next action, one line>`
> `Stopped: <the question> | answer: (none yet)` (`—` when not stopped; the human's answer is written here in his words)
> She rewrites them **before each dispatch** (with the id and the output path) and **after reading each result** (with the next action), in the same edit that records the result. A new session reads the block and continues from it: an unanswered `Stopped:` → restate the question and wait, dispatching nothing; `Next:` with nothing in flight → do it.
> If a dispatch is recorded and its output is not on disk, she asks the human one question — is the earlier session still running? — and re-dispatches only on "no".
> If the pointer and the disk disagree (a phase or file the pointer names does not exist, or the disk is ahead of it), she stops and says what the pointer says and what she found. She does not pick one.

Dispatch id: `p<N>-<step>-<n>`, e.g. `p1-y5-1`. That is all the format there is.

## 5. `cora/references/conductor-protocol.md` — the existing steps, re-homed

`git mv` the file, then edit. **Keep the structure**: `per_phase_protocol` with `step_Y1` … `step_Y8`, `epic_completion`, the prompt templates, the verify lines, the limits and do-nots. Do not redesign the loop. Header: replace lines 1–11 with a 4-line comment (moved 2026-10-13 from Alex; the conductor is Cora) and `description`/`trigger` saying "Cora conducts an approved Epic; trigger: the human's 'continue'". Every `Update session-state.md: current_y_step: …` and `session_state:` line becomes "write the pointer (`## Run` in the Epic)". Line numbers below are today's.

### 5.1 The three behaviour changes, where they occur

| Where (today) | Change | Becomes |
|---|---|---|
| Y3b (92–109): conductor validates the handoff, appends to it, "fix inline" | (b) no edit | Items 1–5 move into the Y3 prompt as things the Alex subagent does itself. Y3b keeps only the existing verify (file exists, > 50 lines); fail → re-dispatch Y3 once, then stop. |
| Y4 step 1 "Read HANDOFF.md" | (a) | Removed: the reviewers read it; Cora does not read handoff content. |
| Y4 step 4: "Write BOTH review results to disk" | (a) | Each reviewer writes its own file, starting with the §5.2 header. |
| Y4 step 5a–c: "Alex (main session) … fixes HANDOFF.md" | (b) | Dispatch an Alex subagent with the two review file paths; it fixes the handoff; re-dispatch the code reviewer. Limit unchanged: max 2 fix-review rounds, then stop (reason 1). |
| Y4 step 7 "Gate 2 judgment", Y6 step 7 "before Gate judgment" | (a) | Removed. What stays: she re-reads the review files' headers from disk, not from memory. |
| Y6 step 6a–b: "fix directly (Edit tool)" | (b) | Always re-dispatch a Blake subagent with the handoff path and the review file path (today's 6c). 6d unchanged except "pause for human" → stop (reason 1). |
| Y7 "Gate 3+4 (Conductor judges)", steps 1–5 | (a) no verdict | Two dispatches. **Gate 3:** an independent verifier (middle tier; not the implementer, not a reviewer of this phase) reads handoff and completion report, runs every AC command itself, writes `phase{N}-gate3-verdict.md` (header + AC table). **Gate 4:** an Alex subagent that took no part in this phase reads handoff, completion, reviews and the Gate 3 file, records the gate4_delta and the knowledge assessment (the three explicit checks), writes `phase{N}-gate-report.md` (header first). Cora reads the two headers. |
| Y7 step 6 (PASS) | (c) | Phase ✅ Done, `NEXT.md` entry `[x]`, announce, go on. The per-phase archive line (6b, first half) is deleted: archiving happens once, in `epic_completion`. |
| Y7 step 7 (FAIL) "retry or pause" | (a)(c) | PARTIAL is never routed as PASS. One rework dispatch (back to Y5 with the verdict file path), then Y6 and Y7 again; a second FAIL → stop (reason 1). |
| Y8 "Knowledge Assessment" (conductor writes project knowledge) | (a) | The Gate 4 subagent has done it. Cora adds one line to her journal and goes on. |
| Y8 `pause_between_phases` branch; `step_Y_pause` (239–252) | (c) no pause | Deleted. Y8 ends: more ⬚ Planned phases → Y1 of the next, without asking; none → `epic_completion`. |
| Every "honest_partial, pause for human" (Y3, Y4, Y6) | (c) | "stop (reason 1), reported as it is". |
| `epic_completion` steps 4–5 | (c) | Order becomes: 1 report, 2 audit script, 3 pair-testing suggestion, **dispatch the distillation** (an Alex subagent that did not conduct, on Cora's journal), announce the result and ask the human to accept, and only after he accepts: step 4 (archive the Epic, copy first, verify, then delete) and 4b (residue check, which now also archives the handoffs and completion reports). With a queue: announce, start the next approved Epic, and ask for acceptance of all of them when the queue is empty. |

Y1, Y2 and Y5 keep their behaviour (Y5's prompt gains one line: "leave `gate3_verdict:` empty; you do not judge your own work"). Nothing else changes.

### 5.2 The verdict header (every review, verdict and gate file starts with it)

```
---
verdict: PASS | CONDITIONAL | FAIL | PARTIAL
p0_count: <number>
judged: <path of the file judged, or commit:<sha> for code>
---
```
Put this block once in the protocol and one line "start your file with the verdict header" in each reviewer / verifier / acceptor prompt. That is the whole format.

### 5.3 `cora/references/status-roadmap-protocol.md`

The two Alex files, moved and joined under two headings (`## Status`, `## Update roadmap`), text unchanged except: "Alex" as the actor → "Cora"; "return to Alex standby" → "return to Cora"; "use *discuss to create one" → "start a direction discussion to create one"; first line of the status part states "the status view modifies nothing and asks nothing"; the dangling last comment line of each file deleted; the three roadmap constraint lines end with `[A142]`, `[A143]`, `[A144]`.

## 6. Alex's side (confirmed by three review rounds; reuse, do not re-derive)

1. **Apply `.tad/evidence/yolo/cora-conductor-role/phase1-alex-skill-edits.patch` exactly** (`git apply`; `--check` passes on `e693d8b9`). It edits `alex/SKILL.md` (routing line to Cora, STEP 0 for a dispatched Alex, the `Conductor status: ACTIVE` check, `epic_execution_pointer`, status/roadmap pointers removed) and turns `yolo-execution-protocol.md` into a 9-line stub. Result: 1667 lines / 99,160 bytes against a ceiling of 1671 / 99,170. The byte margin is 10: do not reword the patch.
2. **`alex/references/conductor-dispatch-mode.md`** (new, ≤ 40 lines): you were dispatched by a conductor for one step named in the prompt. Still read `principles.md` and `patterns/_index.md` first (SKILL.md:79 holds); the 四类扫描 (:64) are exempt and the 4 步激活 (:86) are narrowed to STEP 0 plus that read, because they serve an interactive session with a human present; for direct `/alex` nothing changes. Gate 1 has been passed for you by the human's approval of the Epic's result contract; if the phase block does not let you say what is to be built and how it is judged, return that as a question, do not guess. Skip the intent router, complexity assessment and every question to the human: questions go to `.tad/evidence/yolo/{epic-slug}/phase{N}-questions.md`, then stop and return. For design: `handoff-creation-protocol.md` through `step1d`, stop before `step2` (no expert selection, no reviewers, no Gate 2 claim, no message to Blake). The one place you may edit an Epic file is the Phase Detail blocks of the Epic named in the dispatch. Never: edit `NEXT.md` or `session-state.md`, dispatch subagents, write a verdict on your own work, archive, push, tag or publish.
3. **Four small edits, exactly as written in the long handoff §4.2.5** (lines 418–438): item 4 `handoff-creation-protocol.md` (conductor clauses; `step7_execution_mode` with two options; the string `pause_between_phases` gone), item 5 `adaptive-complexity-protocol.md` step2b (offer Cora), item 6 `discuss-path-protocol.md` (direction → Cora), item 8 `distillation-loop-protocol.md` (≤ 12 lines for a conductor's journal). Where those items mention "packet K2" or other packets, read "the dispatch prompt": there are no packets in this version. Item 9: allowlist rows only if the checker asks.
4. **Blake's skill: no change.**

## 7. The 162 constraints (the guard against losing a rule)

`.tad/evidence/yolo/cora-conductor-role/phase1-slim-dispositions.tsv`: one row per MUST-type constraint of Alex's skill. `ALEX` (56) = the line stays in Alex untouched. `BOTH` (67) = stays in Alex and a line tagged `[A<id>]` exists in the Cora file the row names. `CORA` (38) = leaves Alex and a tagged line exists in the Cora file named. `REMOVED` (1). Destinations: body 38, `conductor-protocol.md` 64, `status-roadmap-protocol.md` 3.
- For lines that move with the protocol file (rows 097–121): append the tag to the line itself; where §5.1 replaces the line, put the tag on its replacement. Rows 122–125, 131, 132 come from the file that becomes a stub and restate the same rules: add their tags to the matching moved line (e.g. `[A097][A122]`). Rows 126–129 (Workflow-tool rules) and the 29 `BOTH` rows sent to the protocol: one line each in a closing section `## Rules carried from Alex's skill`, worded from the row's note column.
- For the 38 body rows: put the tag at the end of the sentence that states the rule (several tags on one line are fine: e.g. the "never does" lines carry `[A009][A074][A075]`). Use the note column as the meaning; do not paste Chinese source lines.
- The check is per row, never a count. Run `AC-2` often.

## 8. Acceptance

One script: `bash .tad/evidence/yolo/cora-conductor-role/phase1-slim-ac.sh ALL` (read-only; exit 0 = all pass, 1 = a FAIL, 3 = no FAIL but something NOT RUN).

| AC | What | Verified by |
|---|---|---|
| AC-1 | Cora body exists, ≤ 200 lines, five action headings in order, ≤ 2 reference files each with a `reference:` / `load_when: "When …"` stub in the body, pointer and memory markers present | script |
| AC-2 | all 162 constraints at their recorded destination | script (existing AC-05 logic) |
| AC-3 | Alex no longer the conductor; pointers and `conductor-dispatch-mode.md` in | script (existing AC-06) |
| AC-4 | Alex's skill not larger: SKILL.md ≤ 1671 lines / 99,170 bytes; skill total down ≥ 300 lines | script (existing AC-07) |
| AC-5 | the three behaviour changes visible; steps Y1–Y8 and `epic_completion` still there; header keys in the protocol | script (existing AC-08, cut down) |
| AC-6 | no model name in new or changed files; nothing outside §2 touched | script (existing AC-09/10) |
| AC-7 | `skill-body-verify`, `state-surface-check`, `release-verify path-refs` and `freshness` pass | script (existing AC-11) |
| AC-8 | direct `/alex` commands and the manual hand-over intact | script (existing AC-12) |
| AC-9 | six smoke transcripts on Claude Code; on Codex six transcripts or a stated NOT RUN | script |
| AC-10 | smoke graded PASS by an independent subagent, bound to the commit of the skill | `phase1-slim-judge.md` + script |

### 8.1 Smoke test (six scenarios, headless, throwaway fixture outside the repo)

`bash .tad/evidence/yolo/cora-conductor-role/phase1-slim-behaviour.sh all claude <work_dir> .tad/evidence/yolo/cora-conductor-role/smoke` and the same with `codex` (run in the background; six sessions each). Scenarios: (a) asked who she is; (b) a direction question; (c) a how-to-build question; (d) pointer says phase 1, design review done clean, next: dispatch implementation; (e) pointer records an unanswered stop; (f) pointer disagrees with the disk. Pass conditions: `phase1-slim-behaviour.sh rubric`.
- You run the sessions and save the transcripts. You do not grade them. The conductor dispatches an independent subagent that follows the rubric and writes `phase1-slim-judge.md`.
- If `/cora` is not discovered in the fixture, set `ACTIVATION` as the script's header says and note it in the completion report.
- **If Codex cannot be run** (usage limit, login, sandbox): write `smoke/codex-not-run.md`, first line = the reason, then the error text. The script then prints `NOT RUN` and exits 3. That is reported as not run, never as passed.
- A scenario that fails is fixed in the skill text, committed, and all six are run again on that harness.

## 9. Order of work and evidence

1. `git status --short`; confirm only the files listed in §2 as already dirty are dirty. 2. Moves (`git mv`), patch, §6 edits. 3. Protocol edits (§5). 4. Body (§3, §4). 5. Tags (§7) until `AC-2` passes. 6. `phase1-slim-ac.sh AC-1 … AC-8` all PASS. 7. Commit with explicit paths only (`git add -- <paths>`, `git commit -- <paths>`; never `-A`; no push, no tag). 8. Smoke runs (§8.1). 9. Completion report `.tad/active/handoffs/COMPLETION-2026-10-13-cora-phase1-slim.md` with: the script's full output, `wc -l` of the body and the two references, the commit sha, the list of smoke transcripts, the provenance output, and anything you could not do. Leave `gate3_verdict:` empty.
Judgment questions you cannot settle from this file: write them in the completion report and stop; do not widen the scope to answer them.

## 10. Left out on purpose (not forgotten; do not build)

- The numbered resume table and every rule that infers where a run is from which files exist.
- The dispatch log and its audit; dispatch-id checks against a log.
- The fourteen dispatch packets (K1–K14), the phase manifest, tree assertions, `NOT-JUDGED`, `judged_ref` hash binding, the four mechanical verdict checks, held-out panels.
- Holder records, lost-dispatch and continuation counters, rework budgets beyond the protocol's existing limits, `impl_status` accounting.
- The carried-items table (`phase1-carried-items.tsv`) and its check; the per-harness dispatch statement and probes P1–P6.
- Separate references for intake, direction discussion, memory, dispatch-by-harness (their substance is the body sections of §3, in a few lines each).
- The 23-scenario behaviour suite and its rubric; the per-finding rework records for review rounds 3 and 4.
- The stop/answer ledger with closed effects, re-baselining, phase replacement, withdrawal.
- Installer, `AGENTS.md`, projections, README, provenance: Phase 2.

## 11. Grounding and dry-run

**Grounded Against** (read 2026-10-13 at `e693d8b9`): `.agents/skills/alex/references/yolo-manual-conductor-protocol.md` (all 273 lines), `yolo-execution-protocol.md`, `status-panoramic-protocol.md`, `update-roadmap-protocol.md` (earlier this session, in full); `alex/SKILL.md` constraint lines via the 162-row table; the patch; the long handoff §4.2.5 and §7. New files (§2 CREATE) do not exist yet.
**AC Dry-Run Log** (2026-10-13, untouched tree): `bash -n` passes on `phase1-slim-ac.sh` and `phase1-slim-behaviour.sh`; `DISP-BASE` → PASS, all 162 anchors found; `phase1-slim-ac.sh ALL` → exit 1, FAIL count 177, all because nothing is built (AC-1: 1, AC-2: 144, AC-3: 14, AC-4: 2, AC-5: 1, AC-8: 2, AC-9: 12, AC-10: 1; AC-6 and AC-7 pass); `git apply --check` on the patch passes; the six fixtures build against a stub skill. No session was run by the designer.
**Expert review:** not done on this slim file; the conductor decides whether to dispatch one before implementation. The parts reused from the long handoff (patch, Alex-side edits, the 162 rows, the three behaviour changes) were reviewed in rounds 1–3.

## 12. Known limits of this first version

- Resume trusts the pointer. If a session dies between a subagent's return and Cora's next pointer write, the next session sees a dispatch with its output on disk and reads it; if it dies before the output exists, the human is asked one question. Nothing cleverer is attempted.
- The pointer has no counters. Retry limits are the protocol's own (one re-dispatch, two fix-review rounds); a session that resumes mid-retry may allow one retry too many.
- A verdict header is trusted as written. Nothing checks that `p0_count` matches the findings or that `judged` names the current commit; a stale or miscounted review would be routed on.
- Cora still writes the grounding file herself (step Y2), as the old conductor did. That is a reading task, not a verdict, but it spends her context.
- There is no dispatch log: who was dispatched for what is visible only in the pointer (current step) and her journal (history), not in an auditable table.
- Dispatch on Codex is not measured here. The smoke test shows what Cora says she would dispatch, not that a Codex subagent actually starts; if Codex could not be run at all, it is reported NOT RUN.
- The smoke test is six scenarios, one run each. It does not exercise rework, gate failure, the queue, or a lost dispatch.
- `/cora` is not installed by this phase (no projection, no `AGENTS.md` row). Until Phase 2 the human reaches her with: "Read .agents/skills/cora/SKILL.md and follow it. You are Cora."
- Other framework texts still describe the conductor as judging (gate skill, deliverable templates, two hook reminders). They are not edited here; Cora's protocol overrides them for her, and the wording is a Phase 2 item.
- The provenance ledger is red after this phase until Phase 2 regenerates it.
