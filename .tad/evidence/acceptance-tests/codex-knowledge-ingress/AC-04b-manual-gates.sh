#!/bin/bash
# AC-04b — explicit manual gate arguments and real BLOCK behavior.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac4b.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
TREE="$TMP/project"
mkdir -p "$TREE/.tad/hooks/lib" "$TREE/.tad/active/handoffs" "$TREE/.tad/evidence"
for rel in .tad/hooks/pre-gate-check.sh .tad/hooks/pre-accept-check.sh .tad/hooks/lib/common.sh .tad/hooks/lib/hook-envelope.sh; do
  cp "$ROOT/$rel" "$TREE/$rel"
done

run_empty() {
  local label="$1" script="$2" arg="$3"
  set +e
  (cd "$TREE" && /bin/bash ".tad/hooks/$script" "$arg" </dev/null) > "$TMP/$label.out" 2> "$TMP/$label.err"
  printf '%s\n' "$?" > "$TMP/$label.rc"
  set -e
}

run_empty missing-gate pre-gate-check.sh 3
[ "$(cat "$TMP/missing-gate.rc")" -eq 2 ]
grep -F -q -e 'Cannot run Gate 3' "$TMP/missing-gate.err"
run_empty missing-accept pre-accept-check.sh 4
[ "$(cat "$TMP/missing-accept.rc")" -eq 2 ]
grep -F -q -e 'Cannot accept' "$TMP/missing-accept.err"

printf '%s\n' '# valid completion fixture' > "$TREE/.tad/active/handoffs/COMPLETION-20260803-fixture.md"
run_empty valid-gate pre-gate-check.sh 3
[ "$(cat "$TMP/valid-gate.rc")" -eq 0 ]
run_empty valid-accept pre-accept-check.sh 4
[ "$(cat "$TMP/valid-accept.rc")" -eq 0 ]

set +e
(cd "$TREE" && /bin/bash .tad/hooks/pre-gate-check.sh </dev/null) > "$TMP/bare-gate.out" 2> "$TMP/bare-gate.err"
BARE_GATE_RC=$?
(cd "$TREE" && /bin/bash .tad/hooks/pre-gate-check.sh 9 </dev/null) > "$TMP/invalid-gate.out" 2> "$TMP/invalid-gate.err"
INVALID_GATE_RC=$?
(cd "$TREE" && /bin/bash .tad/hooks/pre-accept-check.sh </dev/null) > "$TMP/bare-accept.out" 2> "$TMP/bare-accept.err"
BARE_ACCEPT_RC=$?
(cd "$TREE" && /bin/bash .tad/hooks/pre-accept-check.sh 3 </dev/null) > "$TMP/invalid-accept.out" 2> "$TMP/invalid-accept.err"
INVALID_ACCEPT_RC=$?
set -e
[ "$BARE_GATE_RC" -ne 0 ] && [ "$INVALID_GATE_RC" -ne 0 ]
[ "$BARE_ACCEPT_RC" -ne 0 ] && [ "$INVALID_ACCEPT_RC" -ne 0 ]
for err in bare-gate invalid-gate bare-accept invalid-accept; do
  grep -F -q -e 'Usage:' "$TMP/$err.err"
done

printf '%s\n' 'AC-04b PASS: manual no-arg/invalid calls fail visibly; missing Completion blocks; valid Completion allows.'
