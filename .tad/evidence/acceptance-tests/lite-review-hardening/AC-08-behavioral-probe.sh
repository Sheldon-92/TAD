#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
REPORT=.tad/evidence/acceptance-tests/lite-review-hardening/ac8-probe-report.md
[ -f "$REPORT" ] || { echo "FAIL: missing $REPORT"; exit 1; }
fail=0
head -1 "$REPORT" | grep -Eq 'model=' || { echo 'FAIL: report first line lacks reviewer model identity'; fail=1; }
awk 'seen { if ($0 ~ /^## /) exit; print } /^## 执行证据$/ { seen=1 }' "$REPORT" > /tmp/lite-review-hardening-ac8-evidence.out
grep -q 'toy-defect\.sh' /tmp/lite-review-hardening-ac8-evidence.out || { echo 'FAIL: execution evidence lacks toy-defect.sh command'; fail=1; }
grep -q 'NOT_READY' /tmp/lite-review-hardening-ac8-evidence.out || { echo 'FAIL: execution evidence lacks raw NOT_READY output'; fail=1; }
grep -qiE 'toy-defect\.sh|NOT_READY|exit[ =]1|comment-only' "$REPORT" || { echo 'FAIL: report did not catch toy defect'; fail=1; }
if awk '/^(P[012]|[-*] P[012]|[-*] \[P[012]\])/{if ($0 !~ /执行实证|阅读推断/) bad=1} END{exit bad+0}' "$REPORT"; then :; else echo 'FAIL: finding without execution/read inference label'; fail=1; fi
if [ "$fail" -eq 0 ]; then echo 'PASS: AC8 behavioral execution probe report'; else exit 1; fi
