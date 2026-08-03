#!/bin/bash
# AC-00 — spike precondition. This script checks evidence presence and honest
# terminal mappings; it never promotes a fixture or document into runtime evidence.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
DIR="$ROOT/.tad/evidence/acceptance-tests/codex-knowledge-ingress"

for report in spike-c.md spike-d.md spike-e.md; do
  [ -s "$DIR/$report" ] || { echo "BLOCK: missing $report" >&2; exit 1; }
done
grep -F -e 'honest no-delivery' "$DIR/spike-c.md" >/dev/null
grep -F -e 'no wiring' "$DIR/spike-d.md" >/dev/null
grep -F -e 'empty harness-signal set' "$DIR/spike-e.md" >/dev/null

SCRATCH="$DIR/spike-work"
[ "$(git -C "$SCRATCH" rev-list --count HEAD)" -ge 2 ]
git -C "$SCRATCH" log --format='%h %s' -2 | grep -F -e 'spike: add compaction probe' >/dev/null
git -C "$SCRATCH" log --format='%h %s' -2 | grep -F -e 'spike: establish Codex hook capture scratch' >/dev/null

printf '%s\n' 'AC-00 PASS: C/D/E real probes are recorded with honest no-delivery mappings.'
