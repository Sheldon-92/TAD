---
impl_status: complete
gate3_verdict:
---

# Completion report: Cora Phase 1 (slim), dispatch D17

Branch `feat/cora-role` (from `main` at `e693d8b9`). Commit `5ee1e70b`. Not pushed. impl_status: complete (AC-10 needs the independent smoke judge; see below).

## Files
- CREATED: `.agents/skills/cora/SKILL.md` (125 lines), `.agents/skills/alex/references/conductor-dispatch-mode.md` (29 lines)
- MOVED (git mv, then edited): `alex/references/yolo-manual-conductor-protocol.md` -> `cora/references/conductor-protocol.md` (302 lines); `alex/references/status-panoramic-protocol.md` -> `cora/references/status-roadmap-protocol.md` (115 lines, with `update-roadmap-protocol.md` appended)
- DELETED: `.agents/skills/alex/references/update-roadmap-protocol.md` (joined into status-roadmap-protocol.md)
- MODIFIED: `alex/SKILL.md` and `alex/references/yolo-execution-protocol.md` (patch applied unchanged), `handoff-creation-protocol.md`, `adaptive-complexity-protocol.md`, `discuss-path-protocol.md`, `distillation-loop-protocol.md`, `.tad/scripts/path-refs-allowlist.txt` (2 rows)
- Not committed, evidence only: `.tad/evidence/yolo/cora-conductor-role/smoke/` (12 transcripts), `phase1-slim-ac-output.txt`, `.tad/evidence/journal/cora-phase1-slim-2026-10-13.md`.

## Acceptance (final output in phase1-slim-ac-output.txt)
AC-1 PASS (125 lines, 2 references), AC-2 PASS (162/162), AC-3 PASS, AC-4 PASS (alex SKILL.md 1667 lines / 99160 bytes; skill total 7112 lines / 420851 bytes), AC-5 PASS, AC-6 PASS, AC-7 PASS (provenance red as declared, not counted), AC-8 PASS, AC-9 PASS, AC-10 FAIL only because `phase1-slim-judge.md` does not exist yet. Exit 1; FAIL count 1; NOT RUN 0.
Provenance: `release-verify.sh provenance .` fails ("10 index entries not in the ledger"); ledger not regenerated (Phase 2).

## Ten notes
1. Body came to 125 lines, no trimming needed.
2. Questions format chosen: `class: 1|2|3|design` / `question:` / `options:` in `phase{N}-questions.md`; defined in the protocol (`questions_file`), in `conductor-dispatch-mode.md`, and in the Y3 and Y5 prompts.
3. Added to Cora's "Approval and the run": an Epic with no `**Conductor**: Cora` line was made by Alex; she asks before taking it over.
4. "packet" read as "dispatch prompt"; patch applied before item 6, so `epic_execution_pointer` existed.
5. Grepped `pause_between_phases|半自动|Phase Pause|要继续 Phase` in alex/ and cora/: no hits.
6. Edited by heading names, not line numbers.
7. Noted: the skill commit is `5ee1e70b`; any skill change after it makes the judge stale. I made none after it.
8. Nothing under `.tad/evidence` was added with `-f`; evidence files are untracked/ignored.
9. Tag placement checked by hand: listed every tag with its line for all 105 non-ALEX rows. Found one real trap: the protocol's header comment contained the literal `[A097]` and the substring test would have passed on it; reworded. Tags that share a line (A026/A029, A054/A055, A028/A021, A074/A075 etc.) sit on lines that state both rules. A132 also tagged on the Y6 reviewer line.
10. `CHANGELOG.md` and `.tad/provenance/claude-legacy.tsv` left alone.

## Deviations and judgment calls
- `update-roadmap` trigger said "User selects 'Update ROADMAP' from *discuss exit_protocol", which no longer exists. I changed it to "The human chooses to update the roadmap (at the end of a direction discussion)". Handoff said text unchanged except the listed edits; this is the one extra edit.
- The protocol's `[A142]`-style tags in the roadmap constraints follow the closing quote, so those YAML list items are not strict YAML. Handoff said "end with".
- `conductor-dispatch-mode.md` cites SKILL.md rules by name, not by line number (the patch shifted lines by one).
- Y6 4a: "Cora never fixes code herself" added to the rework line; Y2 grounding stays with Cora as the handoff says.
- In the protocol I added `pointer`, `verdict_header`, `questions_file` blocks and a `workflow_path` block holding rows 126-129 plus a closing "Rules carried from Alex's skill" list of the BOTH rows, per section 7.
- A pre-existing `STALE-ALLOW` warning (allowlist line 67, NEXT.md) is printed by path-refs; not mine, path-refs passes.

## Smoke runs
Claude Code 2.1.295: six transcripts, all harness exit 0. Codex 0.159.3: six transcripts, all exit 0. Both run via `phase1-slim-behaviour.sh all`, fixtures in the scratchpad. Not graded by me.
Things the judge should look at: (1) Codex a and e: the harness note switches off the shell, and Codex reads files only through the shell, so Codex stopped on "activation blocked" and, in e, did not restate the recorded push question (likely fail for e). This is a harness limit, not a skill-text fault; I did not change the script or the skill. (2) Claude d rewrote the fixture pointer to Y5 and registered dispatch p1-y5-1 before emitting NEXT, and noted that no subagent actually started; it also continued although phase1-grounding.md was absent. (3) Claude b ends with a STOP line though it is a discussion. (4) `ACTIVATION` was not overridden: `/cora` and `$cora` were discovered.

## Layer 1 limits
Not verified: any subagent dispatch really working; the Cora protocol run end to end; Codex file access with the shell on; the YAML validity of tagged lines; the pre-existing dirty files are byte-identical (shasum before/after).

# Rework 1 (D22, addendum 1) - commit b9bdfb60 (on top of 5ee1e70b, not amended)
impl_status: complete (AC-5..AC-9 pass after the rework; AC-10 and AC-6 as below). `alex/SKILL.md` is byte-identical to 5ee1e70b. `gate3_verdict:` still empty.

| Addendum item | Change |
|---|---|
| 1 Knowledge entry (CR P1-1) | `conductor-protocol.md:218` Gate 4 prompt: the Alex subagent writes entries, rules for principles.md and gaps, report names entries; `:237` Y8 journal line carries the gate-report path; `conductor-dispatch-mode.md` Gate 4 line |
| 2 *status (CR P1-2) | `status-roadmap-protocol.md:19` handoffs listed by file name only, date from the name; Priority column and "priority" removed from the table |
| 3 STEP 0 on every Alex dispatch (ARCH P1-1) | opener added to Y3 (`conductor-protocol.md:91`), Y4 fix (`:140`), Gate 4 (`:212`), distillation (`:250`); Phase Details dispatch in `cora/SKILL.md:29`; `conductor-dispatch-mode.md` now one line per kind (30 lines) |
| 4 Phase Detail blocks (ARCH P1-2) | `cora/SKILL.md:29` Intake dispatches an Alex subagent for Phase Details before stopping for "continue" |
| 5 Queue block (ARCH P1-3) | `cora/SKILL.md:83` lifecycle (create at first continue, waiting line, move current, IDLE, missing block = disagreement); `conductor-protocol.md:261` epic_completion; "keep any `## Conductor run (Cora)` section unchanged" added at `handoff-creation-protocol.md:156` and `blake/SKILL.md:496` |
| 6 No worktree (ARCH P1-4) | `conductor-protocol.md` Y5: `isolation: worktree` removed; main tree, Epic branch, explicit pathspecs |
| 7 Smoke harness | `phase1-slim-behaviour.sh` NOTE, comment lines, rubric line; `phase1-slim-ac.sh` AC-10 messages only; `cora/SKILL.md:130` cannot-read-files line (these two scripts are under gitignored `.tad/evidence`, not in the commit) |
| 8 P2s | ARCH P2-1 `SKILL.md:28`; P2-2 `:99`; P2-3 `conductor-protocol.md:139,192`; P2-4 `:158`; P2-5 `:251` plus `distillation-loop-protocol.md` (conductor no longer answers gaps; they go to her acceptance message); P2-6 `intent-router-protocol.md` line 212 deleted and `SKILL.md:79`; P2-7 `SKILL.md:100`; CR P2-1 `SKILL.md:27`; CR P2-3 header comment `conductor-protocol.md:3` |

Extra: allowlist row for `conductor-protocol.md` -> `.tad/active/session-state.md` (path-refs asked for it, new reference).

## Acceptance after rework (phase1-slim-ac-output.txt)
AC-1 PASS (131 lines), AC-2 PASS, AC-3 PASS, AC-4 PASS, AC-5 PASS, AC-7 PASS, AC-8 PASS, AC-9 PASS.
AC-6 FAIL, conflict with the addendum's explicit allowance (check not changed): `FAIL AC-6: file outside the Phase 1 set was changed: .agents/skills/alex/references/intent-router-protocol.md` and `... .agents/skills/blake/SKILL.md`.
AC-10 FAIL until the new judge runs: old judge file reports stale commit, `codex ... count found '3/6 pass'`, `smoke verdict is 'FAIL'`.
Wording note: first AC-5 run caught my own header comment containing "phase pause"; reworded.

## Smoke re-run (new harness note, new skill text)
Claude Code: 6 transcripts, exit 0. Codex: 6 transcripts, exit 0 (Codex now reads files). Previous round kept in `smoke-round1/`. Ungraded.
For the judge: Codex f edited the fixture Epic's `Stopped:` line through a python write (a permitted Cora write); Claude d stopped on the missing grounding file as reason 1.
Dirty files (5 modified) compared by shasum before/after: unchanged.

# Rework 2 (D27, addendum 2) - commit ad6feb80 (on top of b9bdfb60, not amended)
impl_status: complete. Only the four named files changed; `alex/SKILL.md` byte-identical to b9bdfb60. `gate3_verdict:` empty.

| Addendum-2 item | Change |
|---|---|
| 1 Opener in the body + Intake dispatch | `cora/SKILL.md` Dispatch section (opener line) and Intake Phase Details line (id `intake-<n>`, `intake-questions.md`, `intake-details.md`, existence check only) |
| 2 Knowledge | `conductor-protocol.md` Gate 4 prompt ("Write no knowledge entry", `## Knowledge candidates`), Y8 line, epic_completion 3b (distiller reads Blake journals, Cora journal, gate-report candidates; only writer); `conductor-dispatch-mode.md` Gate 4 and Distillation lines |
| 3 dispatch_id freshness | `conductor-protocol.md:34-36` `dispatch_id_rule` block plus "put dispatch_id in your file's first lines" in the Y3 handoff, Y4 fix, Y4/Y6 reviewer, Y5 completion, Gate 3, Gate 4 and distillation prompts; `cora/SKILL.md` Resume line (id must equal the pointer's, else "not on disk", re-dispatch takes next n) |
| 4 one-liners | `handoff-creation-protocol.md` epic_linkage ("except your own phase's Phase Detail block"); Y4 step 6 "Neither a P0 nor a FAIL"; Y5 "the results of the handoff's verification rows"; `cora/SKILL.md` dispatch id `intake-<n>` |

Placement choice: dispatch_id is a key inside the verdict header / frontmatter block when the file has one, else line 1 (stated in the rule block).

## Acceptance (phase1-slim-ac-output.txt)
AC-1 PASS (132 lines), AC-2, AC-3, AC-4, AC-5, AC-6 (scope check now passes, 20 paths), AC-7, AC-8, AC-9 PASS. AC-10 FAIL: stale judged commit, old judge says claude `5/6 pass`, verdict FAIL; clears only with a new judge. No check/addendum conflict this round.

## Smoke
Claude Code 6/6 and Codex 6/6 transcripts produced on ad6feb80, all exit 0, in `smoke/`; previous set kept in `smoke-round2/` (round 1 in `smoke-round1/`). Ungraded. Dirty files compared by shasum: unchanged.
