# Requirement clarification

One method for every piece of work, in Cora and in direct `/alex`. It takes the requirement out of the human's head in blocks he can correct. The obligations (clarify first, playback confirmed, ask only the unclear blocks) are stated in the Cora and Alex bodies; this file holds the method.

## 1. When and how deep
- It applies to every work request, at every tier Cora or Alex runs. Depth is set by whether the request itself is clear, not by tier.
- Decompose first. Ask only the blocks still unclear, until every block is clear or is written down as an assumption.
- A clear request leaves no unclear block: zero questions, and the per-block playback is still shown and confirmed.
- The three doors: a requirement can arrive already looking clarified through one of three doors, and each still gets the per-block playback and the `playback confirmed:` line. (1) One grown out of a discussion (a direction discussion or talk that turned into "do it"). (2) One Cora assembled herself (for example her own A–E list of fixes that he answers with "do it"): it is her list, not his playback. (3) One relayed from another session or agent. None of them is a reason to skip step 1 of the Triage list.

## 2. Decompose
- Show the blocks. Never announce a problem type.
- Big blocks first; an unclear block is split further.
- Use the matching table in `decomposition-tables.md`; with no match, decompose on the spot.
- A block for the done check (how the result is judged) is always present, and so is a block for what he does not want; they are recorded as the lines `- **Done check**: …` and `- **Not wanted**: …` (a letter prefix such as `- **E. Done check**:` is fine).

## 3. Ask
- One block at a time, at most 4 questions per block.
- A block she can look up (a file, a line, current behaviour) she reads it before asking; the view-first rule is for judgment questions.
- Before the options, Cora states her own professional view on the question, with its reason, in plain words. She does not open with "what do you suggest?" or any bare menu: the human came to hear her judgment.
- Each question then has concrete options that show the current understanding, one marked "recommended" (kept as answered; the anchoring risk is watched), and "other". Options are numbered. They exist for him to correct her, not to replace her judgment: the marked option is the view she just gave.
- When he hands a question back ("你的建议呢", "you decide"), she answers with her recommendation and its reason, and carries on from it. She never asks the same question again. A handed-back question is logged in the Q→A log as `→ handed back; logged as her recommendation: <it>`.
- An answer through "other": restate that block in one line in his words, and update the Q→A log.

## 4. Playback and start
- Per-block playback: one line per block, in his words, numbered. Blocks that were not asked appear as assumptions.
- The playback goes out in the same message as the tier and the plan (tier, plan, estimate, depth line, task list): one message, one reply. He confirms before any work starts, also when he says "just do it" (then there are no questions, but the playback is still confirmed).
- The confirmation is a choice, not a bare verification question: "confirm all / change block N / other". On "change block N" only that block is re-played and the plan is stated again, in the same message.
- For a simple or reversible matter that one reply is the only question before start; she writes the record line `playback confirmed: "<his words>"` (his confirming reply, verbatim) and starts in that turn. An Epic still waits for "continue" after Intake; a one-way handoff gets its start question as its own message after that reply.
- Unsure whether he is discussing or asking for work: ask which, as a choice question. No clarification and no work start before the answer.

## 5. Record
- Epic: `## Requirement` (one line per block in his words, including the lines `- **Done check**: …` and `- **Not wanted**: …`), then `### Q→A log`, then `### Assumptions (not asked; Gate 4 lists them)`. A handoff-tier Epic gets the same section, copied from the confirmed playback.
- Simple tier: the journal entry fields `blocks:` (including `Done check` and `Not wanted`), `qa:`, `assumptions:`.
- Direct `/alex` without an Epic: handoff `### 1.5 Requirement`: block lines including `- **Done check**: …` and `- **Not wanted**: …`, then `#### Q→A log` and `#### Assumptions (not asked; Gate 4 lists them)`. A direct `/alex` that creates an Epic runs this method first and writes `## Requirement` before the Phase Map.
- Gate 1: the four conditions in `.tad/gates/gate-canonical-checklist.md`; his confirmed playback plus Alex's "can design from it"; the format, including the record line `playback confirmed: "<his words>"`, is checked by `gate1-format-check.sh`.
- If the request is a pure explanation or lookup that creates no work, no record is written.

## 6. Downstream
- A designer's question is answered from the requirement first, citing the requirement line. Only what it cannot answer and that fails the Low-stakes test (cora SKILL.md Route and spend) goes to the human, asking only that block; what passes it Cora decides with a `decided:` line.
- The design review and Gate 4 check against the requirement (wired in Phases 2-3).
- A requirement found wrong or changed mid-run: stop, ask only that block again, update its line and the Q→A log. Other blocks stay untouched.
- Process depth (full, standard, light, skip) sets ceremony, not questions. Even at skip, the one-line-per-block playback is shown and confirmed; skip only drops the handoff and the gates' ceremony.

## 7. Relation to rules
- Clarification questions and the confirmed playback come before any run. They are not a stop of a run and not "blocking the human": the stop reasons govern execution only.
- In a direction discussion only discussion happens; work starts when he says to do it, then clarification begins, then playback with tier and plan in one message.
- Direct `/alex` uses this method; it replaces the earlier inquiry protocol and the menu-style elicitation skill.

## 8. Forbidden
- Macro or "hypothetical" questions, including the "pre-mortem" question ("if you are disappointed in three weeks, why?").
- "Paragraph" playback: a block of prose to approve instead of one line per block.
- Fixed question slots that ignore the kind of problem.
- A question that shows options without Cora's own view and reason first, or that is asked again after he handed it back.
- A "minimum" number of rounds or questions.
- A 0-9 "meta-menu" of elicitation methods.
- A bare verification question ("X 对吗?").

## 9. No question tool
Where the harness has no question tool, write the numbered options and "other" as plain text, then stop and wait (AGENTS.md "Interaction decisions"). Never pick a default for him.

## Notes
- Conflict, resolved: principle "AI/Human Judgment Domain Awareness" prefers choice questions over "对吗?" verification and warns about anchoring. The human's own answers A3 (playback confirmed), C3 (recommended on every question) and D3 rank above it (AGENTS.md "File authority order", rank 1 over rank 2). The method keeps the principle's intent: the playback is one line per block so he corrects a block, never approves a paragraph; section 4 offers "change block N".
