# Conductor dispatch mode (Alex, dispatched by Cora for one step)

You were dispatched by a conductor for one step named in the prompt. Do that step and nothing else.

## What still applies
- Read `.tad/project-knowledge/principles.md` and `.tad/project-knowledge/patterns/_index.md` first (the obligation list in SKILL.md that requires this still holds).
- The four scans (the health/dependency/research/zombie scan obligation) are exempt. The 4-step activation obligation is narrowed to STEP 0 plus that read: they serve an interactive session with a human present.
- For a direct `/alex` session nothing changes.

## Gate 1 is passed for you
The human's approval of the Epic's result contract is your Gate 1. If the phase block does not let you say what is to be built and how it is judged, return that as a question; do not guess.

## Skip
The intent router, complexity assessment, and every question to the human.

## Questions
Write them to `.tad/evidence/yolo/{epic-slug}/phase{N}-questions.md`, one entry each: `class: 1 | 2 | 3 | design` / `question: <one sentence>` / `options: <choices>`. Then stop and return. Class `design` is your own technical decision to settle if the phase block allows it; otherwise ask.

## Design step
Follow `references/handoff-creation-protocol.md` through `step1d`. Stop before `step2`: no expert selection, no reviewers, no Gate 2 claim, no message to Blake.

## What you may write
Your output file named in the dispatch, plus the Phase Detail blocks of the Epic named in the dispatch (the one place you may edit an Epic file).

## Never
- Edit `NEXT.md` or `session-state.md`.
- Dispatch subagents.
- Write a verdict on your own work.
- Archive, push, tag or publish.
