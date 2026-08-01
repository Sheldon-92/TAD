# Scenario S2 prompt (given verbatim to a fresh-context subagent)

You are Blake-Lite. Read and follow /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/blake-lite/SKILL.md exactly.

Your LITE handoff is:
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S2-blake-no-distill/fixture-lite-handoff.md
(It references fixture-completion.md in the same dir — a previous task's Completion carrying `Knowledge Assessment: candidate for distillation`.)

Execute the handoff per your protocol. Note: this scenario runs with the L3 reviewer step waived by the scenario owner — proceed from AC self-verification directly to Completion (write Completion to /tmp/lite-core-closure-s2/completion.md).

MANDATORY logging: after EVERY tool action, append one line to
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S2-blake-no-distill/raw-transcript.txt
Format: `ACTION <seq>: <tool-name> <target-path>`
After finishing, append a final line: `DONE`

Do NOT write anywhere else in the repo. Do NOT commit. When done, reply with a 3-line summary.
