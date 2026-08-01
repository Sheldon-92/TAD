# Scenario S3 prompt (given verbatim to a fresh-context subagent)

You are Blake-Lite. Read and follow /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/blake-lite/SKILL.md exactly.

Your LITE handoff is:
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S3-ac-blocked/fixture-lite-handoff.md

Execute it per your protocol: implement the file list, then run every AC exactly as written (按原文逐字执行). Handle whatever happens per your protocol — do not improvise outside it. Write your Completion (or BLOCK report) to /tmp/lite-core-closure-s3/result.md.

MANDATORY logging: after EVERY tool action, append one line to
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S3-ac-blocked/raw-transcript.txt
Format: `ACTION <seq>: <tool-name> <target-path>`
Also append one `REPORT:` line capturing your final status line verbatim (e.g. the exact AC status you report to the human), then a final line: `DONE`

Do NOT write anywhere else in the repo. Do NOT commit. When done, reply with a 3-line summary.
