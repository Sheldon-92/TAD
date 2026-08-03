#!/bin/bash
# AC-01 — section-scoped AGENTS.md knowledge ingress and critical rules.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
AGENTS="$ROOT/AGENTS.md"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac1.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

extract_section() {
  local heading="$1" next_heading="$2" out="$3"
  awk -v h="$heading" -v n="$next_heading" '
    $0 == h { in_section=1 }
    in_section { print }
    in_section && $0 == n { exit }
  ' "$AGENTS" > "$out"
}

KNOWLEDGE="$TMP/knowledge.md"
CRITICAL="$TMP/critical.md"
extract_section '## Knowledge Ingress (read on activation)' '## Critical Rules (platform-equivalent of CLAUDE.md §1/§4/§4.5/§7.5)' "$KNOWLEDGE"
extract_section '## Critical Rules (platform-equivalent of CLAUDE.md §1/§4/§4.5/§7.5)' '## Lite / Standard / Full Routing（用户可读说明）' "$CRITICAL"
grep -F -q -e '## Knowledge Ingress (read on activation)' "$KNOWLEDGE"
grep -F -q -e '## Critical Rules (platform-equivalent of CLAUDE.md §1/§4/§4.5/§7.5)' "$CRITICAL"

for required in \
  .tad/project-knowledge/principles.md \
  .tad/project-knowledge/patterns/_index.md \
  .tad/brain-index.md \
  .tad/project-knowledge/frontend-design.md \
  .tad/project-knowledge/patterns/shell-portability.md; do
  test -f "$ROOT/$required"
done

# These five files are optional slots. A missing filename may occur only in an
# explicit conditional line, never as an unconditional must-read assertion.
for optional in testing.md ux.md performance.md api-integration.md mobile-platform.md; do
  if grep -F -e "$optional" "$KNOWLEDGE" | grep -v -i -q -e 'if'; then
    echo "BLOCK: optional file $optional appears outside a condition" >&2
    exit 1
  fi
done

for term in \
  '### Handoff and routing' \
  '### Role separation' \
  '### Post-compact recovery' \
  '### Memory authority'; do
  grep -F -q -e "$term" "$CRITICAL"
done
for term in \
  '/tad-maintain' \
  'Full roles ignore' \
  'blake-lite' \
  'Layer-1 self-check' \
  'Alex does not write implementation code' \
  '.tad/memory/'; do
  grep -F -q -e "$term" "$CRITICAL"
done

LINES=$(wc -l < "$KNOWLEDGE" | tr -d ' ')
LINES=$((LINES + $(wc -l < "$CRITICAL" | tr -d ' ')))
[ "$LINES" -le 80 ] || { echo "BLOCK: ingress sections exceed 80 lines ($LINES)" >&2; exit 1; }

# Explicit tokenizer: CJK runs are punctuation/whitespace-stripped and must be
# shorter than 24; ASCII runs are whitespace-delimited and must not reach 12.
if command -v perl >/dev/null 2>&1; then
  CJK=$(perl -CS -ne 's/[\s\p{P}\p{S}]+//g; while (/([\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}]{24,})/g) { print "$1\n" }' "$KNOWLEDGE")
  ASCII=$(perl -CS -ne 'while (/(?:^|\s)((?:[-A-Za-z0-9_.\/:]+\s+){11}[-A-Za-z0-9_.\/:]+)/) { print "$1\n" }' "$KNOWLEDGE")
  while IFS= read -r segment; do
    [ -n "$segment" ] || continue
    if grep -R -F -e "$segment" "$ROOT/.tad/project-knowledge" 2>/dev/null \
        | grep -vE 'https?://|^.*\.tad/|^[[:space:]]*[A-Za-z0-9_./-]+\.md'; then
      echo "BLOCK: ingress fragment occurs in project knowledge: $segment" >&2
      exit 1
    fi
  done <<EOF
$CJK
$ASCII
EOF
fi

printf '%s\n' "AC-01 PASS: scoped ingress, conditionals, critical rules, and copy guard verified ($LINES lines)."
