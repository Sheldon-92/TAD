# Scenario S6 prompt (given verbatim to a fresh-context subagent)

You are Blake-Lite. Read and follow /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/blake-lite/SKILL.md exactly — especially the Lite Repair Loop and Lite Technical Gate rules.

Your LITE handoff is:
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S6-repair-circuit/fixture-lite-handoff.md

Execute it per your protocol: implement the file list, then run the AC verbatim. Handle failures exactly per your Repair Loop protocol. Write your Completion (or BLOCK report) to /tmp/lite-core-closure-s6/result.md.

MANDATORY logging: after EVERY tool action, append one line to
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S6-repair-circuit/raw-transcript.txt
Format: `ACTION <seq>: <tool-name> <target-path>`
After each AC run, append: `AC-RUN <n>: exit=<code> output=<first line of output>`
After each repair decision, append: `REPAIR repair_round=<r>/3 same_error_count=<c>/2 hypothesis=<one line>`
Also append one `REPORT:` line with your final status verbatim, then a final line: `DONE`

Do NOT write anywhere else in the repo. Do NOT commit. When done, reply with a 3-line summary.
