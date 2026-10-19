# Conductor dispatch mode (Alex, dispatched by Cora for one step)

You were dispatched by a conductor for one step named in the prompt. Do that step and nothing else.

## What still applies
- Read `.tad/project-knowledge/principles.md` and `.tad/project-knowledge/patterns/_index.md` first (the obligation list in SKILL.md that requires this still holds). A file that does not exist yet counts as read and empty: say so in one line and continue.
- The four scans (the health/dependency/research/zombie scan obligation) are exempt. The 4-step activation obligation is narrowed to STEP 0 plus that read: they serve an interactive session with a human present.
- For a direct `/alex` session nothing changes.

## Gate 1 is passed for you
Gate 1 is the human's confirmed per-block playback, recorded in the Epic's `## Requirement`, plus your confirmation that you can design from it. If `## Requirement` and the phase block do not let you say what is to be built and how it is judged, return that as a question naming the block; do not guess.

## Skip
The intent router, complexity assessment, the requirement clarification (the Epic's `## Requirement` is your requirement), and every question to the human.

## Questions
Write them to `.tad/evidence/yolo/{epic-slug}/phase{N}-questions.md`, one entry each: `class: 1 | 2 | 3 | design` / `question: <one sentence>` / `options: <choices>`. Line 1 is `dispatch_id: <id>` from your prompt. Then stop and return. Class `design` is your own technical decision to settle if the phase block allows it; otherwise ask.

## Your kind of step (the prompt names it)
- Phase Details: write only the Phase Detail blocks (Scope, Acceptance Criteria, Files Likely Affected) of the Epic named.
- Design: follow `references/handoff-creation-protocol.md` through `step1d`, stop before `step2` (no expert selection, no reviewers, no Gate 2 claim, no message to Blake). Write the handoff path named and your phase's block of the Epic.
- Design fix: read the review files named; write only the handoff path named. A re-plan (the prompt says re-plan or root cause) first writes the premise file named in the prompt with the same `dispatch_id` (conductor protocol, Y4 5c); with `spike_needed: yes` it stops there and returns; a re-plan whose prompt names a spike file writes the handoff only.
- Gate 4: write the gate report only (the Knowledge Assessment and candidates under `## Knowledge candidates`); no knowledge entry, not the Epic.
- Distillation: per `distillation-loop-protocol.md`, working from the journals and gate-report candidates named; you are the only writer of entries; write its entries and the output file named.

## Never
- Edit `NEXT.md` or `session-state.md`.
- Dispatch subagents.
- Write a verdict on your own work.
- Archive, push, tag or publish.
