#!/usr/bin/env bash
# AC2: content-level complete migration; old dir untouched (36)
cd "$(git rev-parse --show-toplevel)"
OLD="$HOME/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD/memory"
D=$(diff -rq "$OLD" .tad/memory 2>&1 | grep -c "Only in $OLD" || true)
N=$(ls "$OLD" | wc -l | tr -d ' ')
[ "$D" -eq 0 ] && [ "$N" -eq 36 ] && { echo "AC2 PASS: 0 missing-from-target; old dir count=$N"; exit 0; }
echo "AC2 FAIL: missing=$D old_count=$N"; exit 1
