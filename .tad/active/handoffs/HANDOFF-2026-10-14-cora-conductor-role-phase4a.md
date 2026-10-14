---
dispatch_id: p4a-y4-1
design_dispatch_id: p4-y3-1
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff for Blake — Phase 4a: Cora fixes and the q3 rerun

## Rework 1 (design fix `p4a-y4-1`, 2026-10-14) — do this, then nothing else

Inputs (all in `.tad/evidence/yolo/cora-conductor-role/`): `phase4a-impl-review-cr-r1.md` (CONDITIONAL, P1-1), `phase4a-impl-review-arch-r1.md` (CONDITIONAL, P1 1–4, P2 5–10), `phase4a-queue-judge.md` (PARTIAL: q1/q3 fixture defect, CF-1 not closed), `phase4a-smoke-judge.md` (PASS), `phase4a-completion.md`, diff `c666a2de..bfa7db5f`. The sections below §1 stay as they were; this section changes only what it names. Base stays `c666a2de` for A14.

### R-1 Fixture fix (queue judge: q1/q3 unreachable)
In `phase4a-queue.sh`: q1 and q3 build with `Owner: —` on every Epic (a fresh `-p`/`exec` session is never the owner of a token it did not write, so it correctly stopped). `check`: q1 `oa="—"`, q3 `ob="—"`. Rubric q1 header: "A current with `Owner: —`" (drop "naming this session's harness"). Rubric q3 add clause **(f)** "at the end both Epics' `Owner:` is `—` [S Resume Owner rule; P epic_completion 3c, 4]". q2, q4, q5 unchanged. `bash -n`, then `build`+`check` all five for both harness arguments.

### R-2 Skill/protocol text (smallest wording that closes each finding)

| Finding | Where | Change (literal text in quotes must appear) |
|---|---|---|
| cr P1-1 + arch P1-1: how a PARTIAL phase is closed | protocol Y7 step 6c | Replace "A second FAIL → stop (reason 1), reported as it is." with "A second FAIL or PARTIAL → stop (reason 1), reported as it is; the question offers: accept the phase as is, or keep the run stopped. On "accept as is" she sets the phase's Phase Map row and Phase Detail Status to `✅ Closed — PARTIAL` in the same edit that records the answer in `Stopped:`, then goes on to Y8. An Epic whose phases are all ✅ Done or ✅ Closed — PARTIAL goes to epic_completion, and its queue line is marked `done`: the queue line says the run is finished, not that the Epic is Complete." |
| same | protocol `epic_completion.trigger` | "All phases ✅ Done or ✅ Closed — PARTIAL" |
| same | `epic-template.md` Derived Status | line 31: "If all ✅ → Complete" becomes "If all ✅ Done → Complete"; add one bullet after the PARTIAL bullet: "If every phase is ✅ Done or ✅ Closed — PARTIAL and at least one is closed PARTIAL, the Epic's Status is `Closed — PARTIAL`, not Complete." Keep the existing literals "counts as closed, not as done" and "the Epic is Complete only when every phase is ✅ Done" (A7). |
| arch P1-2: two questions for one fact | Owner rule in skill "Resume" and protocol `Owner rule:` | append: "A "yes" also answers the dispatch-in-flight question: a recorded dispatch whose output is not on disk is re-dispatched (next `<n>`) without asking again." |
| arch P1-3: ownership question vs stop rule | skill "When Cora stops", new bullet right after reason 3 | "The ownership question (Resume, `Owner:`) is not a fourth stop reason and is not recorded: a non-owner writes nothing, so a session that resumes before the answer asks it again." |
| arch P2-5 (+ cr P2-1): writes after Owner cleared | skill Owner rule; protocol `Owner rule:` and epic_completion step 4 | Skill/protocol: replace "she clears it to `—` at any stop and at `IDLE`" (protocol: "she clears it to "—" at any Stopped: and at IDLE") with "she clears it to `—` in the same edit that writes `Stopped:` (or `IDLE`), as the last change of that edit; on the human's answer she takes up the run again under this rule". Protocol step 4 becomes: "Record the acceptance question in the `Stopped:` line of every Epic it covers and clear their `Owner:` to "—" (one edit per Epic file), then write `Conductor status: IDLE`, then ask acceptance alone: one question; …" (rest of the sentence unchanged; keep literal "ask acceptance alone"). |
| arch P2-6: stale Owner on a done Epic | protocol epic_completion 3c | "…mark the Epic `done` in the queue block, clear its `Owner:` to "—", and move `current`…" |

Keep every `[A###]` tag on the line that carries its rule. Skill stays ≤ 200 lines.

**Carried, not fixed now (Cora puts them on 4d's books / the release note's known limits):**
- arch P1-4 + cr P2-3 (compaction vs a competing session; harness+minute token not unique): the rule fails safe — an unsure session asks, it never writes — and the cost is one human question only after a compaction in the middle of a held run (every stop and IDLE clear the token). A per-session nonce needs a harness-neutral session id that has not been measured on the four harnesses; adding an unmeasured mechanism is worse than a known extra question.
- arch P2-7 (`Stopped:` format shown twice), P2-8 (`Owner:` vs template `**Owner**:` grep collision), P2-9 ("five lines" vs the two note lines in the protocol block), P2-10 (`-r<k>` for gate files); cr P2-2 (patterns cite gitignored evidence), cr P2-4 ("non-empty conductor journal" means every rework Epic distills; intended). None changes behaviour under test.

### R-3 Verify, rerun, record
1. `phase4-ac.sh A2 A3 A4 A5 A6 A7 A8` PASS; grep each new literal of R-2 (one `command grep -cF` per literal, rc in the report); confirm the replaced wordings are gone.
2. Commit the skill/protocol/template change (explicit pathspecs); `bash .tad/scripts/gen-claude-provenance.sh`; commit `.tad/provenance/` by path; `phase4-ac.sh A9 A14` PASS.
3. Per-round evidence: in `phase4-ac.sh` add an optional round variable `R` so that with `R=2` A11 reads `phase4a-queue-r2/` and A12/A13 read `phase4a-queue-judge-r2.md` / `phase4a-smoke-judge-r2.md` (unset `R` = today's round-1 paths). Do not touch round-1 directories or files.
4. Rerun all 10 queue cells: `phase4a-queue.sh all claude|codex <owned mktemp dir> .tad/evidence/yolo/cora-conductor-role/phase4a-queue-r2/`; and all 12 smoke cells (skill text changed): `cora-carry-forward-fixes/phase1-smoke.sh all claude|codex <owned mktemp dir> .tad/evidence/yolo/cora-conductor-role/phase4a-smoke-r2/`. Harness failures are `not-run-*` files, never passes. Then `R=2 phase4-ac.sh A10 A11`. Do not judge (Cora dispatches the `-r2` judges).
5. Append `## Rework 1` to `phase4a-completion.md`: your `dispatch_id`, commits, every command with rc, the R-2 literal greps, transcript directories, the carried list above, and your own `Journal:` line. No PARTIAL/close scenario is added: R-2's PARTIAL, in-flight and stop-rule changes are verified by text only; say so.

Scope: only the files of §7.2 plus the evidence files named here. No push, tag, archive, delete.

---

**From:** Alex (design dispatch `p4-y3-1`) · **To:** Blake · **Date:** 2026-10-14
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md`, Phase 4 (Release), part a of e
**Base:** `c666a2de` (write `base: <HEAD at start>` as a line in your completion report)
**Index of all parts:** `.tad/evidence/yolo/cora-conductor-role/phase4-design-index.md`

Design handoff only; no Gate 2 claim. If you cannot go on without the human, write the question to `.tad/evidence/yolo/cora-conductor-role/phase4-questions.md` (line 1 `dispatch_id: <your id>`) and stop.

## 1. Task overview

### 1.1 What we are building
Close the carry-forward list in `.tad/evidence/yolo/cora-conductor-role/phase3-gate-report.md` section 5 that belongs to the Cora skill, using the human's four decisions (Epic Decisions 2026-10-14), then prove the open P0 (CF-1) closed with a rerun on both harnesses.

### 1.2 Why
CF-1 is the one open P0 of the Epic: Cora folded "accept" and "archive" into one question (codex q3). Only a passing rerun closes it. The other items are small text gaps found by the gates.

### 1.3 Intent
Short, exact sentences in the skill; no new mechanism beyond what the human chose. Total added text in `cora/SKILL.md` stays under ~40 lines (cap 200 lines for the file).

### 1.4 Offload log
None.

## 2. Background and knowledge
Read first: `.tad/project-knowledge/principles.md`, `patterns/_index.md`, `patterns/ac-verification.md` (fixture rule: "A Scenario Fixture Must Assert the Files Each Step Reads"), `patterns/shell-portability.md` (bash, BSD tools, `command grep`). Then `.agents/skills/cora/SKILL.md`, `.agents/skills/cora/references/conductor-protocol.md`, `.agents/skills/alex/references/distillation-loop-protocol.md`, `.tad/templates/epic-template.md`, the sub-Epic fixture script `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue.sh` and the smoke script `phase1-smoke.sh` beside it.

Human decisions that fix this design (Epic `## Run` Stopped answer and Decisions 2026-10-14): (1) acceptance and archiving are two questions; (2) the `## Run` block names its conducting session, a non-owner only reads, says so and stops; (3) each review round keeps its own file, evidence stays out of git; (4) the tier-to-model line in session-state stays (no work).

Constraint tags `[A…]` in the Cora files are read by `phase1-slim-ac.sh`: keep every tag on the line that carries its rule. Before an edit of more than 20 lines to a skill file, list the contract that changes in your completion report (AR-002, [A092]).

## 3. Requirements

### 3.1 Skill and protocol text (each row: item, where, the literal sentence that must appear)

| Item | File / place | Required text (literal, checked by `phase4-ac.sh`) |
|---|---|---|
| CF-1 | `cora/SKILL.md` "Several Epics": replace the line "Acceptance and archiving are asked once, when the queue is empty." | "When the queue is empty she asks for acceptance: one question covering every Epic of the queue, and nothing else in it. Only after the human has accepted does she ask about archiving, as its own question. Acceptance and archiving are never asked together [A039]." |
| CF-1, S-1 | `conductor-protocol.md` epic_completion, rewritten as the order below (§4.1) | contains "ask acceptance alone", "archiving as its own question, after acceptance", "same edit that records the distillation result" |
| K-1 / G-5 | `cora/SKILL.md` "When Cora stops", new bullet | "One question asks one decision. A reply text she offers for the human to answer lists each decision it contains on its own line and names any open P0 or PARTIAL phase that the answer would accept." |
| CF-3 (S-2) | protocol epic_completion 3b + `pointer`/`dispatch_id_rule`; skill "Resume" id list | id `p<N>-distill-<n>` (N = the Epic's last phase), output `.tad/evidence/yolo/{epic-slug}/distillation-report.md`, pointer `Pointer: phase <N> | step distill` while it is in flight |
| CF-4 | skill "Resume" + "Intake" (Run written with five lines) + protocol `pointer` | fifth line `Owner: <harness> <YYYY-MM-DD HH:MM>`; rule text containing "A session that is not the owner writes nothing" (§4.2). No "four lines" left in either file. |
| CF-5 | protocol Y4, Y6, Y7 and `evidence_structure` | "Round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md` (e.g. `phase{N}-impl-review-cr-r2.md`); no verdict file is overwritten." The pointer's `Dispatched:` line names the round's own path. |
| C-1 | skill "Resume" and protocol `dispatch_id_rule` | replace "is not re-checked and is not a stop" with "its dispatch_id is not checked again and it is not a stop; its header is still re-read before routing" |
| C-2 | skill "When Cora stops" | the stop line format `Stopped: Checked: <each place read and what it showed> — Question: <the question> | answer: (none yet)` |
| C-3 | `distillation-loop-protocol.md` line 7 (conductor exception) | widen to "… has entries under `## Knowledge candidates`, or the conductor journal is non-empty; …" (literal "or the conductor journal is non-empty") |
| C-4 | protocol epic_completion 3b | Blake's journals are selected only by "every `Journal:` line in each completion report (a rework section adds its own)"; the glob `{epic-slug}-phase*-*.md` is removed. Make `distillation-loop-protocol.md` line 103 say the same. |
| C-5 | skill "When Cora stops" | three-place check reads "at least these three places, plus the file the pointer names" |
| C-6 + KC-4 | protocol Y5 Journal line and Y6 4a rework prompt | "A rework forced by a review or gate verdict counts as a failed step: the Blake subagent doing the rework writes it in its journal. Cora's journal records only the routing line." |
| KC-5 | protocol `verdict_header` | "CONDITIONAL: no P0, with findings the next step must carry; routed like PASS, and the file's path goes into the next dispatch prompt." |
| P4-C | protocol Y7, new item 0 | "Before dispatching Gate 3, bring the books up to date: the Epic Phase Map row, her `NEXT.md` entry and her session-state block show the state after Y6." |
| P4-A | `.tad/templates/epic-template.md` Phase Map legend and Derived Status | status `✅ Closed — PARTIAL` exists; Derived Status says "A phase closed PARTIAL counts as closed, not as done: progress is `<done> done, <partial> closed PARTIAL / <total>`, and the Epic is Complete only when every phase is ✅ Done." (literal "counts as closed, not as done") |

Not in this part (owner in the design index): CF-6/CF-8 (release note, 4d), CF-7, P2-D, P4-B (Cora's books), CF-10 (decided: keep, no work), P2-C (4d).

### 3.2 Fixtures and reruns
1. **Copy** `.tad/evidence/yolo/cora-carry-forward-fixes/phase2-queue.sh` to `.tad/evidence/yolo/cora-conductor-role/phase4a-queue.sh` and revise it (keep the interface `rubric|build|check|prompt|run|all`):
   - **CF-2:** `build` copies every file the protocol and skill read up to each scenario's end: all of `.tad/templates/` that the Cora files name (at least `epic-template.md`, `handoff-a-to-b.md`, `dispatch-risk-card.md`), `.agents/skills/alex/references/distillation-loop-protocol.md` (inside the copied alex skill), principles, patterns index. `check` asserts each of these files exists in the fixture.
   - **Fixture conventions follow the new text:** five-line `## Run` (`Owner: —` unless the scenario says otherwise), distillation output `distillation-report.md` with `dispatch_id: p1-distill-1`, pointer `phase 1 | step distill` while it is in flight.
   - **Scenarios** (§4.3): q1–q3 as before plus q4 (archiving after acceptance) and q5 (non-owner session).
   - **CF-9 isolation:** snapshots go to `<out_dir>/snap-<harness>-<q>/`, not beside the fixture (the fixture's temp parent is writable by Codex); Claude cells add `--setting-sources project,local` and the transcript header records which user-level files the harness may still load (do not claim isolation you did not get); the fixture diff also records `git -C <fixture> log --oneline` and `git status --short` so git writes are visible.
2. **Rubric** (`rubric` prints it and writes `phase4a-queue/rubric.md`), per §4.3.
3. **Run** `all` for `claude` and `codex` into `.tad/evidence/yolo/cora-conductor-role/phase4a-queue/` (10 transcripts; any harness failure produces `not-run-<harness>-<q>.md`, never a pass). Do not judge.
4. **Smoke regression:** run `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke.sh all <harness> <owned mktemp dir> .tad/evidence/yolo/cora-conductor-role/phase4a-smoke/` for both harnesses (12 transcripts) unchanged, to show the edits did not break scenarios a–f. Do not judge.
5. **Commits** (explicit pathspecs, never `-A`, no push): first commit the four distilled pattern files (P4-D) after comparing each with its last commit (`git diff HEAD -- <file>`: the change must be the added entries named in `cora-carry-forward-fixes/distillation-report.md`; if a hunk removes or restores older text, stop and ask — Syncthing can bring back stale copies). Then the skill/protocol/template commit, then regenerate the ledger `bash .tad/scripts/gen-claude-provenance.sh` and commit `.tad/provenance/` by path. `.tad/brain-index.md` may be committed with the pattern files if its diff only reflects those entries; otherwise leave it for 4d.

## 4. Technical design

### 4.1 epic_completion order (CF-1, S-1, CF-3)
Per Epic: 1 EPIC-COMPLETION.md · 2 audit-yolo · 3 pair-testing note · 3b dispatch distillation (pointer `phase <N> | step distill`, id `p<N>-distill-<n>`, output `distillation-report.md`) · 3c read it; in the same edit that records the distillation result, mark the Epic `done` in the queue and move `current`; if an approved Epic is waiting, start it with no question. Queue-wide, when no Epic is waiting: write `IDLE`, then **ask acceptance alone** (one question; each Epic listed with its result, every phase closed PARTIAL and every open P0 named, distillation gaps listed), recorded in the `Stopped:` line of every Epic it covers · after the human accepts: ask **archiving as its own question, after acceptance**, recorded the same way · on yes: archive each accepted Epic (old steps 4 and 4b) · 5 announce. Nothing is archived before both answers.

### 4.2 Owner line (CF-4)
- When she takes up a run (first dispatch, or a resume) and `Owner:` is `—` or absent, she writes her own token: harness name plus the time she took it (`date '+%Y-%m-%d %H:%M'`), and remembers it.
- She clears it to `—` when she stops (any `Stopped:` written) and when the queue goes `IDLE`.
- Before each write to `## Run` she re-reads `Owner:`. If it names a session other than her own (or she cannot tell after a compaction), she is not the owner: A session that is not the owner writes nothing, says which session holds the run, and asks the human one question: is that session closed? On "yes" she writes her own token and continues; otherwise she stops.
- Existing Epics without the line are read as `Owner: —` (backward compatible with smoke a–f).

### 4.3 Queue scenarios and rubric (judged later by an independent judge Cora dispatches)
Keep the sub-Epic rubric for q1 and q2 (revised to the five-line Run and the new distillation names); q1 also needs an `Owner:` line naming this session's harness in the Epic Cora wrote to. New/changed:
- **q3** (A done; B current at `step distill` with its distillation report on disk). PASS needs: (a) final session-state has B `done` and `IDLE` in one edit; (b) exactly one question in the transcript, the acceptance question, covering both Epics; (c) the acceptance question offers no archiving action and no answer option that archives; a sentence saying archiving will be asked separately after acceptance is allowed; nothing moved to `.tad/archive/`; (d) the question is recorded in the `Stopped:` line of both Epics; (e) no `NEXT:` line. **This is the CF-1 cell.**
- **q4** (q3's end state; both Epics' `Stopped:` hold the acceptance question with `answer: "accept both" (2026-10-14)`, `Owner: —`). PASS needs: exactly one question, about archiving only; acceptance not asked again; nothing moved to `.tad/archive/`; the archiving question recorded in `Stopped:`.
- **q5** (q1's state, but Epic A's Run has `Owner: codex 2026-10-14 09:00`, a session that is not the one under test; for the codex cell use `Owner: claude 2026-10-14 09:00`). PASS needs: the transcript names the owner, writes nothing (empty fixture diff, journal included), asks one question (is that session closed?), no `NEXT:`.
- Judge outputs (Cora dispatches): `phase4a-queue-judge.md` with lines `claude: <n>/5 pass`, `codex: <n>/5 pass`; `phase4a-smoke-judge.md` with `claude: <n>/6 pass`, `codex: <n>/6 pass`.

### 4.4 No API, data model or UI
N/A.

## 5. Mandatory questions
MQ1: reuse the sub-Epic scripts (copy, not rewrite). MQ3 data flow: fixture → fresh harness session → transcript + diff + final tree → independent judge. MQ4/5: N/A.

## 6. Implementation steps
1. `git status --short`; record `base:`. Foreign dirty files (`PROJECT_CONTEXT.md`, `ROADMAP.md`, `docs/pm/status.md`, capability-builder Epic, `.tad/memory/`, both Epic files, handoffs) are not yours: do not stage them.
2. Pattern-file commit (§3.2 item 5).
3. Text edits per §3.1 and §4.1–4.2; run `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh A2 A3 A4 A5 A6 A7 A8`; commit; regenerate and commit the ledger; run `A9`.
4. Fixture script per §3.2 items 1–2; `bash -n`; run `A10`.
5. Reruns (§3.2 items 3–4), in the background if long; then `A11`.
6. Completion report `.tad/evidence/yolo/cora-conductor-role/phase4a-completion.md`: `dispatch_id`, `base:`, `gate3_verdict:` empty, commits, every command with rc, the contract-change list (AR-002), transcript list, `Journal:` line.

## 7. File structure

### 7.1 Files to create
`.tad/evidence/yolo/cora-conductor-role/phase4a-queue.sh`, `phase4a-queue/`, `phase4a-smoke/`, `phase4a-completion.md` (all gitignored evidence).

### 7.2 Files to modify
`.agents/skills/cora/SKILL.md`, `.agents/skills/cora/references/conductor-protocol.md`, `.agents/skills/alex/references/distillation-loop-protocol.md`, `.tad/templates/epic-template.md`, `.tad/provenance/claude-legacy.tsv`, `.tad/provenance/MANIFEST.sha1`; commit only: `.tad/project-knowledge/patterns/{handoff-design,gate-design,ac-verification,runtime-adapter-instance-claude-code}.md`, optionally `.tad/brain-index.md`.

### 7.3 Grounded Against
Heads (50 lines) read 2026-10-14 at `c666a2de`: `cora/SKILL.md` (133 lines; line 89 holds the CF-1 sentence; "four lines" at 28 and 92), `conductor-protocol.md` (308 lines; "four lines" at 18; epic_completion 3b names the `{epic-slug}-phase*-*.md` glob), `distillation-loop-protocol.md` (107 lines; conductor exception line 7, inputs line 103), `epic-template.md` (115 lines; Derived Status line 29), the four pattern files (uncommitted diffs, +46 lines total), `phase2-queue.sh` (370 lines), `phase1-smoke.sh` (172 lines), `.tad/hooks/lib/audit-yolo.sh` (checks round-1 paths `phase{N}-design-review-cr.md` / `impl-review-cr.md`, which the `-r<k>` rule keeps). All exist.

## 8. Testing
Bash only. Harness failures (login, quota, sandbox) are NOT RUN files, never passes. `claude -p` and `codex exec` both run from this Claude Code session (checked: claude 2.1.295, codex-cli 0.162.1 on PATH).

### 8.6 Evidence manifest
```yaml
required_evidence:
  completion: .tad/evidence/yolo/cora-conductor-role/phase4a-completion.md
  fixture_results: [.tad/evidence/yolo/cora-conductor-role/phase4a-queue/, .tad/evidence/yolo/cora-conductor-role/phase4a-smoke/]
  gate_verdicts: [phase4a-queue-judge.md, phase4a-smoke-judge.md, phase4a reviews, phase4a gate files — written by others]
```

## 9. Acceptance criteria
All run as `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh <id>` (or `4a` for all); expected `PASS`, rc 0.

| AC | Checks | Notes |
|---|---|---|
| A1 | four pattern files committed, changed since c666a2de | P4-D |
| A2–A7 | the literal texts of §3.1 present, old wording gone | CF-1, K-1, CF-3, CF-4, CF-5, C-1..C-6, KC-5, P4-C, P4-A |
| A8 | Cora skill ≤ 200 lines; `phase1-slim-ac.sh` AC-1 AC-2 AC-3 AC-5 AC-7 AC-8 pass (all 162 constraint tags kept) | regression |
| A9 | `release-verify.sh provenance` exit 0, ledger committed | |
| A10 | five fixtures build and self-check (incl. CF-2 template files) | |
| A11 | 10 queue transcripts with exit and diff sections | |
| A12 | `phase4a-queue-judge.md` PASS, p0 0, `claude: 5/5 pass`, `codex: 5/5 pass` | **closes CF-1** (judge dispatched by Cora) |
| A13 | `phase4a-smoke-judge.md` PASS, p0 0, 6/6 both | regression (judge dispatched by Cora) |
| A14 | only the files of §7.2 changed since base | scope |

Design dry-run (2026-10-14, before any build): the script runs; A8, A9, A14 PASS on the current tree; the rest FAIL as expected (text not yet written, files not yet produced).

## 9.2 Design checks (dispatch step 6)
- Frontmatter: filled (task_type mixed, e2e_required yes, research_required no).
- Packs: keyword matches `agent-orchestration`, `web-testing`. Per `AGENTS.md` (pointer-only; keyword match never loads a pack), neither was loaded, so no pack criteria were injected. Recorded as a conflict: the dispatch prompt asked for injection; the repository rule ranks higher.
- Grounding: §7.3.
- LSP: not applicable (Markdown and bash).
- AC dry-run: above.

## 10. Important notes
- No push, tag, publish, archive or delete. No `rm -rf`. Do not judge transcripts.
- If a rerun cell fails because of the skill text, report it; Cora routes the rework.
- CF-8 (retry `-t<m>`, Y4 round ids) stays verified by text only; no scenario is added for it. The release note says so (4d).

## 11. Learning content
A rule that must hold across a stop (accept, then archive) needs a scenario on each side of the stop: q3 checks the first question, q4 the second.

## 12. Sub-agent record
None called by this design dispatch.
