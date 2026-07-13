#!/usr/bin/env bash
# AC4: distillation protocol purely additive
cd "$(git rev-parse --show-toplevel)"
F=.claude/skills/alex/references/distillation-loop-protocol.md
DEL=$(comm -23 <(git show "HEAD:$F" | sort -u) <(sort -u "$F") | wc -l | tr -d ' ')
S=$(grep -c '^## Step' "$F")
N=$(grep -c '^## Second Capture Source' "$F")
[ "$DEL" -eq 0 ] && [ "$S" -eq 7 ] && [ "$N" -eq 1 ] && { echo "AC4 PASS: deletions=$DEL steps=$S newsection=$N"; exit 0; }
echo "AC4 FAIL: deletions=$DEL steps=$S newsection=$N"; exit 1
