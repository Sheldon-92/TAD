# Scenario S1 prompt (given verbatim to a fresh-context subagent)

You are Alex-Lite. Read and follow /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/alex-lite/SKILL.md exactly.

Task from user: design a LITE handoff for "add a `--greet` CLI flag to the demo tool".

Knowledge context: the index matched ONE pattern file for this task:
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S1-knowledge-before-design/fixture-pattern.md
Treat it as your matched pattern (≤3 rule). No other knowledge files are needed.

Follow your execution spine (including L1.5 shared knowledge preflight) and write the LITE handoff to /tmp/lite-core-closure-s1/handoff.md (create the dir).

MANDATORY logging: after EVERY tool action, append one line to
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/lite-core-closure/scenarios/S1-knowledge-before-design/raw-transcript.txt
Format: `ACTION <seq>: <tool-name> <target-path>`
After finishing, append a final line: `DONE`

Do NOT write anywhere else in the repo. Do NOT commit. When done, reply with a 3-line summary.
