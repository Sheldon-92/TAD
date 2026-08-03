#!/bin/bash
# AC-08 — brain-index skill-tree fallback in copied scratch roots.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac8.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
BEFORE=$(md5 -q "$ROOT/.tad/brain-index.md")

make_scratch() {
  local tree="$1"
  mkdir -p "$tree/.tad/hooks/lib" "$tree/.tad/project-knowledge/patterns" \
    "$tree/.tad/active/handoffs" "$tree/.tad/active/epics" "$tree/.tad/archive/handoffs" \
    "$tree/.tad/evidence" "$tree/.tad/decisions"
  cp "$ROOT/.tad/hooks/lib/brain-index-gen.sh" "$tree/.tad/hooks/lib/brain-index-gen.sh"
  printf '%s\n' '## Principles' > "$tree/.tad/project-knowledge/principles.md"
  printf '%s\n' '# patterns' > "$tree/.tad/project-knowledge/patterns/_index.md"
}

CODEX_ONLY="$TMP/codex-only"
make_scratch "$CODEX_ONLY"
mkdir -p "$CODEX_ONLY/.agents/skills/probe"
printf '%s\n' 'Probe skill summary.' > "$CODEX_ONLY/.agents/skills/probe/SKILL.md"
(cd "$CODEX_ONLY" && /bin/bash .tad/hooks/lib/brain-index-gen.sh >/dev/null)
grep -F -q -e '## Skills' "$CODEX_ONLY/.tad/brain-index.md"
grep -F -q -e '| probe |' "$CODEX_ONLY/.tad/brain-index.md"

NO_SKILLS="$TMP/no-skills"
make_scratch "$NO_SKILLS"
(cd "$NO_SKILLS" && /bin/bash .tad/hooks/lib/brain-index-gen.sh >/dev/null)
grep -F -q -e '## Skills' "$NO_SKILLS/.tad/brain-index.md"
grep -F -q -e '(no skills tree found)' "$NO_SKILLS/.tad/brain-index.md"

AFTER=$(md5 -q "$ROOT/.tad/brain-index.md")
[ "$BEFORE" = "$AFTER" ]
[ -z "$(git -C "$ROOT" diff --stat -- .tad/brain-index.md)" ]

printf '%s\n' 'AC-08 PASS: copied Codex-only tree uses .agents/skills; missing both trees emits explicit marker; repo index is unchanged.'
