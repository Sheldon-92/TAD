# Scenario S5 prompt (given verbatim to a fresh-context subagent)

You are Blake-Lite resuming after a compaction/interruption. Read and follow /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/blake-lite/SKILL.md exactly — especially the 压缩后恢复 and Lite Progress rules.

The pending LITE handoff is:
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S5-checkpoint-resume/fixture-lite-handoff.md

Resume the task per your protocol. Note: L3 reviewer is waived by the scenario owner for this resume — after ACs pass, write Completion to /tmp/lite-core-closure-s5/completion.md.

MANDATORY logging: after EVERY tool action, append one line to
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S5-checkpoint-resume/raw-transcript.txt
Format: `ACTION <seq>: <tool-name> <target-path>`
Your FIRST transcript line must state which phase you are resuming from: `RESUME: Phase=<phase> repair_round=<r>/3 same_error_count=<c>/2`
After finishing, append a final line: `DONE`

Do NOT write anywhere else in the repo. Do NOT commit. When done, reply with a 3-line summary.
