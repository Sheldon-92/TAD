---
task_type: code
e2e_required: no
research_required: no
handoff_revision: slim-1-addendum-2
---
# Addendum 2 to the Cora Phase 1 slim handoff (Alex, dispatch D26, 2026-10-13). Base `b9bdfb60`. Last rework of Phase 1.
Supersedes addendum-1 where they differ. Closes ARCH r2 P1-1..P1-3 and P2-1..P2-4, CR r2 P2-1, P2-2. Files: `cora/SKILL.md`, `cora/references/conductor-protocol.md`,
`alex/references/conductor-dispatch-mode.md`, `alex/references/handoff-creation-protocol.md`. `alex/SKILL.md` does not change. Keep every `[Annn]` tag.

1. **Opening sentence in the body (ARCH P1-1).** Cora's body, section `### 2. Dispatch`, gets the one-line opening used for every Alex dispatch:
   "You are Alex, dispatched by the conductor (Cora) for one step: {kind}. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it."
   The Intake dispatch (kind Phase Details, id `intake-<n>`) uses it, writes questions to `.tad/evidence/yolo/{epic-slug}/intake-questions.md`, and returns
   `.tad/evidence/yolo/{epic-slug}/intake-details.md` (dispatch_id line, then the phases it filled). Cora checks that file exists; she does not judge the blocks.
2. **Knowledge (ARCH P1-2).** The Gate 4 subagent writes NO knowledge entry. Its gate report keeps the Knowledge Assessment (three checks, A007/A088/A095)
   and lists candidate discoveries under `## Knowledge candidates`. The Epic-close distillation (Alex that did not conduct) reads Blake's journals, Cora's
   journal and every gate report's candidates, applies `distillation-loop-protocol.md` (variabilize test, gaps to the human's acceptance message), and is the
   only writer of entries. This replaces addendum-1 item 1 (Gate 4 line in dispatch-mode: "write the gate report only"; Y7/Y8 prompts lose the write).
   CR D18 P1-1 stays closed: the per-phase entry now has a named owner, the Epic-close distiller, working from the candidates the gate report carries.
3. **Fresh output vs old (ARCH P1-3).** Every dispatched output file (handoff and each revision, completion report, review, verdict, gate report, intake
   details, distillation output) carries `dispatch_id: <id>` in its first lines; each prompt template that writes a file gets the line "put `dispatch_id: {id}`
   in your file's first lines". Resume rule, one line: an output counts as the result of the recorded dispatch only if its `dispatch_id` equals the pointer's;
   otherwise it is "output not on disk" (existing ask-the-human rule). A re-dispatch takes the next `<n>`. This is what Cora reads when a file has no verdict header.
4. **One-liners (P2).**
   - Epic edits by a dispatched design Alex: `handoff-creation-protocol.md:158` becomes "...do not edit it, except your own phase's Phase Detail block (skip 3 and 3b)"; dispatch-mode keeps its Design line as is.
   - Y4 step 6: "Neither a P0 nor a FAIL → proceed".  - Y5 completion-report line: "tsc result, test result" → "the results of the handoff's verification rows".
   - Dispatch id: body adds "`intake-<n>` for the Intake dispatch, which has no phase".  - Left out: CR P2-2 (YAML tail tags), the cosmetic line-1 comment of `status-roadmap-protocol.md`.

Blake re-runs `phase1-slim-ac.sh ALL` (body ≤ 200 lines) and all twelve smoke cells (claude + codex, a..f; the d/e fixture now includes the grounding file) on the new commit.
Then the architecture (D19) and code (D18) reviewers confirm on that commit, and a fresh independent judge grades the smoke; any remaining P1 stops the run for the human.
