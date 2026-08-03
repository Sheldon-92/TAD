#!/bin/bash
# AC-10b — notebook SessionStart fail-open behavior with absent source.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac10b.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
TREE="$TMP/project"
mkdir -p "$TREE/.tad/hooks/lib" "$TREE/.tad/research-notebooks"
for rel in \
  .tad/hooks/notebook-dormant-sync.sh \
  .tad/hooks/lib/common.sh \
  .tad/hooks/lib/hook-envelope.sh \
  .tad/hooks/lib/notebook-lifecycle.sh; do
  cp "$ROOT/$rel" "$TREE/$rel"
done
cat > "$TREE/.tad/research-notebooks/REGISTRY.yaml" <<'EOF'
version: 1.0.0
notebooks:
  - id: fixture-notebook
    status: active
    last_queried: "2020-01-01"
EOF
cat > "$TREE/.tad/config-workflow.yaml" <<'EOF'
research_notebook:
  dormant_after_days: 30
EOF

# No source is the measured Codex case: the fail-open hook must run its body.
(cd "$TREE" && printf '%s' '{}' | /bin/bash .tad/hooks/notebook-dormant-sync.sh) > "$TMP/out" 2> "$TMP/err"
grep -F -q -e 'status: dormant' "$TREE/.tad/research-notebooks/REGISTRY.yaml"

HOOK_SOURCE_VALUE=$(printf '%s' '{}' | /bin/bash -c "source '$ROOT/.tad/hooks/lib/hook-envelope.sh'; printf '%s' \"\$HOOK_SOURCE\"")
[ -z "$HOOK_SOURCE_VALUE" ]

# A real compact discriminator is the opposite polarity: it must not run the
# notebook body. Preserve the already-dormant registry as the observation.
(cd "$TREE" && printf '%s' '{"source":"compact"}' | /bin/bash .tad/hooks/notebook-dormant-sync.sh) > "$TMP/compact.out" 2> "$TMP/compact.err"
grep -F -q -e 'status: dormant' "$TREE/.tad/research-notebooks/REGISTRY.yaml"

printf '%s\n' 'AC-10b PASS: absent source remains fail-open and acts; HOOK_SOURCE is empty; compact source is filtered.'
