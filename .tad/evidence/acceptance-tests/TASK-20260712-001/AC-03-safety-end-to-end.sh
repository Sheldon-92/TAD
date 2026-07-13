#!/usr/bin/env bash
# AC3: memory in BOTH deny-lists + drift gate + sync-set exclusion
cd "$(git rev-parse --show-toplevel)"
A=$(bash .tad/hooks/lib/derive-sync-set.sh --zero-touch | grep -cx memory)
B=$(sed -n '/^TAD_ZERO_TOUCH="/,/"$/p' tad.sh | grep -cx 'memory\|memory"')
bash tad.sh --verify-denylist >/dev/null 2>&1; C=$?
D=$(bash .tad/hooks/lib/derive-sync-set.sh --dirs | grep -cx memory || true)
[ "$A" -eq 1 ] && [ "$B" -ge 1 ] && [ "$C" -eq 0 ] && [ "$D" -eq 0 ] && { echo "AC3 PASS: lib=$A tadsh=$B gate_exit=$C dirs=$D"; exit 0; }
echo "AC3 FAIL: lib=$A tadsh=$B gate_exit=$C dirs=$D"; exit 1
