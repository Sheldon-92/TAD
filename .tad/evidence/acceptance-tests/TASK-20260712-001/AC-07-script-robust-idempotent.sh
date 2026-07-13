#!/usr/bin/env bash
# AC7: script robustness + idempotency + revert round-trip
cd "$(git rev-parse --show-toplevel)"
S=.tad/hooks/lib/memory-redirect.sh
bash -n "$S" || { echo "AC7 FAIL syntax"; exit 1; }
bash "$S" --status >/dev/null || { echo "AC7 FAIL status"; exit 1; }
bash "$S" --enable >/dev/null || { echo "AC7 FAIL 2nd enable"; exit 1; }   # idempotent re-enable
bash .tad/evidence/acceptance-tests/TASK-20260712-001/AC-01-settings-deep-equal.sh >/dev/null || { echo "AC7 FAIL AC1-after-reenable"; exit 1; }
bash .tad/evidence/acceptance-tests/TASK-20260712-001/AC-02-migration-content-complete.sh >/dev/null || { echo "AC7 FAIL AC2-after-reenable"; exit 1; }
jq -S .permissions .claude/settings.local.json > /tmp/ac7-perm-pre-revert.json
bash "$S" --revert >/dev/null || { echo "AC7 FAIL revert"; exit 1; }
V=$(jq -r '.autoMemoryDirectory // "ABSENT"' .claude/settings.local.json)
[ "$V" = "ABSENT" ] || { echo "AC7 FAIL: key still present after revert"; exit 1; }
jq -S .permissions .claude/settings.local.json > /tmp/ac7-perm-post-revert.json
diff /tmp/ac7-perm-pre-revert.json /tmp/ac7-perm-post-revert.json || { echo "AC7 FAIL: permissions changed by revert"; exit 1; }
bash "$S" --enable >/dev/null || { echo "AC7 FAIL re-enable"; exit 1; }
echo "AC7 PASS: syntax/status/idempotent-enable/revert-roundtrip all OK"
