#!/bin/bash
# AC-05 — Spike D three-way mapping, no unsupported wiring, and snapshot contract.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
DIR="$ROOT/.tad/evidence/acceptance-tests/codex-knowledge-ingress"
LEDGER="$ROOT/.tad/runtime-compat/codex.md"
MAPPING="$ROOT/.tad/guides/hooks-platform-mapping.md"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac5.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

for term in \
  'honest no-delivery' \
  'no wiring' \
  'fire unmeasured' \
  'no docs-only verified claim'; do
  grep -F -q -e "$term" "$DIR/spike-d.md"
done

CONTEXT_LINE=$(grep -F -e '| context_compaction |' "$LEDGER")
grep -F -q -e 'spike-d.md' <<< "$CONTEXT_LINE"
grep -F -q -e 'verified_partial' <<< "$CONTEXT_LINE"
grep -F -q -e 'yes' <<< "$CONTEXT_LINE"
if printf '%s\n' "$CONTEXT_LINE" | grep -F -q -e 'docs-only'; then
  if printf '%s\n' "$CONTEXT_LINE" | grep -F -q -e '| verified |'; then
    echo 'BLOCK: docs-only evidence is marked verified' >&2
    exit 1
  fi
fi
grep -F -q -e 'no PreCompact consumer is wired' "$MAPPING"

# The selected unsupported/no-delivery branch must not add a PreCompact entry
# to either lock-step generator.
if rg -n 'PreCompact' "$ROOT/.codex/hooks.json" "$ROOT/tad.sh" >/dev/null; then
  echo 'BLOCK: unsupported Spike D branch was wired' >&2
  exit 1
fi

# Snapshot behavior is still independently smoke-tested: exactly eight lines,
# unavailable fallback, and no trigger=unknown sentinel.
TREE="$TMP/tree"
mkdir -p "$TREE/.tad/hooks" "$TREE/.tad/active/handoffs" "$TREE/.tad/active/epics" "$TREE/.tad/evidence"
cp "$ROOT/.tad/hooks/precompact-session-snapshot.sh" "$TREE/.tad/hooks/"
(cd "$TREE" && printf '%s' '{}' | /bin/bash .tad/hooks/precompact-session-snapshot.sh)
SNAP=$(find "$TREE/.tad/active/precompact" -name 'snapshot-*.md' -type f -print | head -1)
[ -n "$SNAP" ]
[ "$(wc -l < "$SNAP" | tr -d ' ')" -eq 8 ]
grep -F -q -e 'Trigger: (unavailable: no-trigger-field)' "$SNAP"
if grep -F -q -e 'trigger=unknown' "$SNAP"; then
  echo 'BLOCK: trigger=unknown sentinel present' >&2
  exit 1
fi

printf '%s\n' 'AC-05 PASS: Spike D honest branch is recorded, untested fire stays partial, no wiring was added, and snapshots remain legal.'
