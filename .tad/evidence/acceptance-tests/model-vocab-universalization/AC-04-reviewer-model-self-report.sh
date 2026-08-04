#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

fail=0
check_file() {
  local file="$1"
  local model_count required_count
  model_count="$(grep -F -c -e "Model: harness=" "$file" 2>/dev/null || true)"
  required_count="$(grep -F -c -e "REQUIRED OUTPUT" "$file" 2>/dev/null || true)"
  if [ "$model_count" -lt 1 ] || [ "$required_count" -lt 1 ]; then
    echo "FAIL AC4: $file model=$model_count required=$required_count"
    fail=1
  fi
}

for file in \
  .claude/skills/blake/SKILL.md \
  .agents/skills/blake/SKILL.md \
  .claude/skills/alex/references/handoff-creation-protocol.md \
  .agents/skills/alex/references/handoff-creation-protocol.md \
  .claude/workflows/handoff-review.workflow.js; do
  check_file "$file"
done

blake_segment="$(awk '/expert_prompt_template:/{inside=1} inside{print} inside && /NOT ALLOWED:/{exit}' .claude/skills/blake/SKILL.md)"
if [ "$(printf '%s\n' "$blake_segment" | grep -F -c -e "REQUIRED OUTPUT" || true)" -lt 1 ]; then
  echo "FAIL AC4: Blake expert_prompt_template segment lacks REQUIRED OUTPUT"
  fail=1
fi
if [ "$(printf '%s\n' "$blake_segment" | grep -F -c -e "Model: harness=" || true)" -lt 1 ]; then
  echo "FAIL AC4: Blake expert_prompt_template segment lacks model self-report"
  fail=1
fi

alex_segment="$(awk '/expert_prompt_template: \|/{inside=1} inside{print} inside && /OUTPUT FORMAT:/{exit}' .claude/skills/alex/references/handoff-creation-protocol.md)"
if [ "$(printf '%s\n' "$alex_segment" | grep -F -c -e "REQUIRED OUTPUT" || true)" -lt 1 ]; then
  echo "FAIL AC4: Alex expert_prompt_template segment lacks REQUIRED OUTPUT"
  fail=1
fi
if [ "$(printf '%s\n' "$alex_segment" | grep -F -c -e "Model: harness=" || true)" -lt 1 ]; then
  echo "FAIL AC4: Alex expert_prompt_template segment lacks model self-report"
  fail=1
fi

if [ "$(grep -F -c -e "semantic port of expert_prompt_template" .claude/workflows/handoff-review.workflow.js || true)" -ne 1 ]; then
  echo "FAIL AC4: workflow INV-4 annotation is not the single semantic-port note"
  fail=1
fi

review_dir=".tad/evidence/reviews/blake/model-vocabulary-universalization"
review_files="$(find "$review_dir" -maxdepth 1 -type f -name '*.md' -print | LC_ALL=C sort)"
known_reviewers=0
if [ -z "$review_files" ]; then
  echo "FAIL AC4: no persisted reviewer reports found"
  fail=1
fi
while IFS= read -r report; do
  [ -n "$report" ] || continue
  first_line="$(sed -n '1p' "$report")"
  if ! printf '%s\n' "$first_line" |
       grep -Eq -e '^Model: harness=(claude-code|codex|other) \| model=[^|]+ \| route=(host|native|unknown)$'; then
    echo "FAIL AC4: invalid first-line model provenance in $report"
    fail=1
  fi
  case "$report" in
    */code-reviewer.md|*/security-auditor.md|*/test-runner.md|*/spec-compliance-reviewer.md|*/backend-architect.md|*/performance-optimizer.md|*/ux-expert-reviewer.md|*/api-designer.md|*/data-analyst.md|*/bug-hunter.md|*/refactor-specialist.md|*/devops-engineer.md|*/database-expert.md|*/frontend-specialist.md|*/docs-writer.md|*/config-manager.md|*/config-manager-review.md)
      known_reviewers=$((known_reviewers + 1)) ;;
  esac
done <<< "$review_files"
if [ "$known_reviewers" -lt 2 ]; then
  echo "FAIL AC4: fewer than two known persisted reviewer reports ($known_reviewers)"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "AC4 PASS: reviewer carriers and persisted first-line model provenance are valid"
