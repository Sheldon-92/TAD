#!/bin/bash
# AC-07 — constrained SKILL/reference diff, forward Source-header completeness,
# and two-tree parity. The lite MD5s are a regression guard only.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac7.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

FILES=(
  .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md
  .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md
  .claude/skills/alex/references/*.md .agents/skills/alex/references/*.md
  .claude/skills/blake/references/*.md .agents/skills/blake/references/*.md
)

DIFF="$TMP/skill.diff"
git -C "$ROOT" diff --unified=0 -- "${FILES[@]}" > "$DIFF"
while IFS= read -r line; do
  case "$line" in
    '+++'*|'---'*) continue ;;
    '+'*|'-'*) body="${line#?}" ;;
    *) continue ;;
  esac
  case "$body" in
    '# Source: .claude/skills/alex/SKILL.md'|\#\ Source:\ .claude/skills/alex/SKILL.md\ lines\ *|\#\ Source:\ .claude/skills/blake/SKILL.md|\#\ Source:\ .claude/skills/blake/SKILL.md\ lines\ *) ;;
    '# Source: skills/alex/SKILL.md (platform tree)'|\#\ Source:\ skills/blake/SKILL.md\ \(platform\ tree\)) ;;
    *'Extract via `awk'*) ;;
    *'Extract via `for f in .claude/skills/'*) ;;
    *'scan .claude/skills/'*|*'scan the platform skill tree'*) ;;
    *'skill_path: ".claude/skills/'*|*'skill_path: "skills/'*|*'resolve under .claude/skills/ or .agents/skills/ per platform'*|*'resolve skills/*/SKILL.md under .claude/skills/ or .agents/skills/ per platform'*) ;;
    *'scope: ".tad/project-knowledge/*.md, .claude/skills/*/SKILL.md'*|*'scope: ".tad/project-knowledge/*.md, skills/*/SKILL.md, and .tad/hooks/lib/*.sh"'*) ;;
    *'Check availability: .claude/skills/{name}/SKILL.md'*|*'Check availability: for f in .claude/skills/{name}/SKILL.md .agents/skills/{name}/SKILL.md'*|*'If available: Read SKILL.md/CAPABILITY.md'*|*'If available: Read "$available_path"'*) ;;
    *'create .claude/skills/{slug}/SKILL.md from the SCAND'*|*'Proposed Skill Outline (project-local; NOT TAD-master unless working in TAD repo)'*|*'create in the authority skill tree (`.claude/skills/` if it'*|*'exists, otherwise `.agents/skills/`) from the SCAND'*|*'(project-local; NOT TAD-master unless working in TAD repo), then mirror with'*|*'`parity --fix` when both trees exist'*) ;;
    *'读取 .claude/skills/code-review/SKILL.md]'*|*'读取 code-review skill（从 .claude/skills/ 或 .agents/skills/ 解析）]'*) ;;
    *'Workflow is invocable only from a Claude harness'*) ;;
    *) echo "BLOCK: unregistered SKILL/reference diff line: $line" >&2; exit 1 ;;
  esac
done < "$DIFF"

# Forward completeness: baseline had 38 old headers; the after tree has none.
[ "$(rg -n '^# Source: \.claude' "$ROOT/.claude/skills" "$ROOT/.agents/skills" | wc -l | tr -d ' ')" -eq 0 ]
[ "$(rg -n '^# Source: skills/(alex|blake)/SKILL\.md \(platform tree\)$' "$ROOT/.claude/skills" "$ROOT/.agents/skills" | wc -l | tr -d ' ')" -eq 38 ]

# Entries 1, 2, and 7 have their platform-neutral anchors.
for anchor in \
  'for f in .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md' \
  'for f in .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md' \
  'scope: ".tad/project-knowledge/*.md, skills/*/SKILL.md, and .tad/hooks/lib/*.sh"' \
  'Check availability: for f in .claude/skills/{name}/SKILL.md .agents/skills/{name}/SKILL.md' \
  'create in the authority skill tree'; do
  rg -F -q -e "$anchor" "$ROOT/.claude/skills/alex/SKILL.md" "$ROOT/.claude/skills/blake/SKILL.md"
done
[ "$(rg -F -e 'skill_path: "skills/' "$ROOT/.claude/skills/alex/SKILL.md" | wc -l | tr -d ' ')" -eq 3 ]
grep -F -q -e '读取 code-review skill（从 .claude/skills/ 或 .agents/skills/ 解析）' "$ROOT/.claude/skills/alex/SKILL.md"
grep -F -q -e 'create .claude/workflows/{slug}.workflow.js skeleton' "$ROOT/.claude/skills/blake/SKILL.md"

# Codex-only scratch: both extraction loops must select .agents when .claude is absent.
for role in alex blake; do
  mkdir -p "$TMP/codex-only/.agents/skills/$role"
  cp "$ROOT/.agents/skills/$role/SKILL.md" "$TMP/codex-only/.agents/skills/$role/SKILL.md"
  if [ "$role" = alex ]; then
    OUT=$(cd "$TMP/codex-only" && for f in .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; do [ -f "$f" ] && { awk '/^<!-- anti_rationalization_registry:BEGIN -->$/{f=1;next}/^<!-- anti_rationalization_registry:END -->$/{f=0}f' "$f" | sed -n '/^```yaml$/,/^```$/p' | sed '1d;$d'; break; }; done)
    printf '%s\n' "$OUT" | grep -F -q -e 'anti_rationalization_registry:'
  else
    OUT=$(cd "$TMP/codex-only" && for f in .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md; do [ -f "$f" ] && { awk '/^<!-- honest_partial_protocol:BEGIN -->$/{f=1;next}/^<!-- honest_partial_protocol:END -->$/{f=0}f' "$f" | sed -n '/^```yaml$/,/^```$/p' | sed '1d;$d'; break; }; done)
    printf '%s\n' "$OUT" | grep -F -q -e 'honest_partial_protocol:'
  fi
done

# Parity is the byte-identity assertion; lite MD5s are only sentinels.
bash "$ROOT/.tad/hooks/lib/release-verify.sh" parity "$ROOT" >/dev/null
for pair in \
  '.claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md a55d37738775322062ebebc6e078851b' \
  '.claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md dc7699fa33e0439874fea1c2e25463a7'; do
  set -- $pair
  [ "$(md5 -q "$ROOT/$1")" = "$3" ]
  [ "$(md5 -q "$ROOT/$2")" = "$3" ]
done

printf '%s\n' 'AC-07 PASS: registered line-set only, 38→0 old Source headers, codex-only anchors, parity, and lite guards verified.'
