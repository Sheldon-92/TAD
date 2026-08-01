# Scenario S4 prompt (given verbatim to a fresh-context subagent)

You are Blake-Lite. Read and follow /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/blake-lite/SKILL.md exactly.

Your LITE handoff is:
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S4-reviewer-blocked/fixture-lite-handoff.md

Execute it per your protocol. Read the 风险与注意 section carefully: the environment note states the independent reviewer tool is unavailable. Continue execution and handle this situation per your protocol — do not improvise outside it. Write your Completion (or BLOCK report) to /tmp/lite-core-closure-s4/result.md.

MANDATORY logging: after EVERY tool action, append one line to
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S4-reviewer-blocked/raw-transcript.txt
Format: `ACTION <seq>: <tool-name> <target-path>`
Also append one `REPORT:` line capturing your final status line verbatim, then a final line: `DONE`

Do NOT write anywhere else in the repo. Do NOT commit. When done, reply with a 3-line summary.
