#!/bin/bash
# AC-10a — startup-health positive compact branch and honest missing-field branch.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac10a.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
TREE="$TMP/project"
mkdir -p "$TREE/.tad/hooks/lib" "$TREE/.tad/active/handoffs" "$TREE/.tad/active/epics"
for rel in .tad/hooks/startup-health.sh .tad/hooks/lib/common.sh .tad/hooks/lib/hook-envelope.sh; do
  cp "$ROOT/$rel" "$TREE/$rel"
done
printf '%s\n' 'version: "2.39.0"' > "$TREE/.tad/config.yaml"

COMPACT=$(cd "$TREE" && printf '%s' '{"hook_event_name":"SessionStart","source":"compact"}' | /bin/bash .tad/hooks/startup-health.sh)
printf '%s\n' "$COMPACT" | grep -F -q -e 'Post-compact: read .tad/active/session-state.md'

MISSING=$(cd "$TREE" && printf '%s' '{"hook_event_name":"SessionStart"}' | /bin/bash .tad/hooks/startup-health.sh)
if printf '%s\n' "$MISSING" | grep -F -q -e 'Post-compact:'; then
  echo 'BLOCK: missing source field triggered positive compact reminder' >&2
  exit 1
fi
printf '%s\n' "$MISSING" | grep -F -q -e 'TAD v2.39.0'
grep -F -q -e 'Layer-1 self-check in' "$ROOT/.tad/guides/hooks-platform-mapping.md"
grep -F -q -e 'Critical Rules is the only detection layer' "$ROOT/.tad/guides/hooks-platform-mapping.md"

printf '%s\n' 'AC-10a PASS: compact discriminator reminds; missing discriminator stays honest and routes to Layer-1 self-check.'
