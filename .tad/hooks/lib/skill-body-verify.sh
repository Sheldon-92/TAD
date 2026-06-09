#!/usr/bin/env bash
# skill-body-verify.sh — verify Blake SKILL.md body contains execution-discipline markers
# Exit 0 = all checks pass, Exit 1 = at least one check failed

set -euo pipefail

DEFAULT_SKILL=".claude/skills/blake/SKILL.md"
SKILL_PATH="${1:-$DEFAULT_SKILL}"
IS_CUSTOM_PATH=false
if [ "$SKILL_PATH" != "$DEFAULT_SKILL" ]; then
  IS_CUSTOM_PATH=true
fi
FAIL=0

if [ ! -f "$SKILL_PATH" ]; then
  echo "FAIL: File not found: $SKILL_PATH"
  exit 1
fi

echo "Checking: $SKILL_PATH"
echo "---"

declare -a MARKERS=(
  "ralph_loop_execution"
  "Layer 2|layer_2"
  "gate3_verdict"
  "completion_report|completion_protocol"
  "task_type_branching"
  "hard_requirement_distinct_reviewers"
)

declare -a LABELS=(
  "ralph_loop_execution (Ralph Loop protocol key)"
  "Layer 2 (expert review)"
  "gate3_verdict (Gate 3 marker)"
  "completion protocol (completion protocol)"
  "task_type_branching (execution checklist)"
  "hard_requirement_distinct_reviewers (reviewer requirement)"
)

for i in "${!MARKERS[@]}"; do
  pattern="${MARKERS[$i]}"
  label="${LABELS[$i]}"
  count=$(grep -cE "$pattern" "$SKILL_PATH" 2>/dev/null || true)
  if [ "$count" -eq 0 ]; then
    echo "FAIL: Missing marker — $label (pattern: $pattern)"
    FAIL=1
  else
    echo "  OK: $label ($count occurrences)"
  fi
done

echo "---"

SAFETY_COUNT=$(grep -cE 'MUST|MANDATORY|VIOLATION' "$SKILL_PATH" 2>/dev/null || true)
SAFETY_FLOOR=77
echo "Safety keywords: $SAFETY_COUNT (floor: $SAFETY_FLOOR)"
if [ "$SAFETY_COUNT" -lt "$SAFETY_FLOOR" ]; then
  echo "FAIL: Safety keyword count $SAFETY_COUNT < $SAFETY_FLOOR"
  FAIL=1
else
  echo "  OK: Safety keyword count meets floor"
fi

echo "---"

if [ "$IS_CUSTOM_PATH" = true ]; then
  echo "SKIP: .agents/ mirror and ref-ok checks (custom path — marker+safety only)"
else
  AGENTS_SKILL=".agents/skills/blake/SKILL.md"
  REF_DIR=".claude/skills/blake/references"

  if [ -f "$DEFAULT_SKILL" ] && [ -f "$AGENTS_SKILL" ]; then
    if diff -q "$DEFAULT_SKILL" "$AGENTS_SKILL" > /dev/null 2>&1; then
      echo "  OK: .agents/ mirror is identical to .claude/ copy"
    else
      echo "FAIL: .agents/ mirror differs from .claude/ copy"
      FAIL=1
    fi
  elif [ ! -f "$AGENTS_SKILL" ]; then
    echo "WARN: .agents/ mirror not found at $AGENTS_SKILL (skipping)"
  fi

  for ref in cross-model-invocation.md notebooklm-access.md; do
    if [ -f "$REF_DIR/$ref" ]; then
      echo "  OK: Reference-ok file exists: $ref"
    else
      echo "FAIL: Reference-ok file missing: $ref"
      FAIL=1
    fi
  done
fi

echo "---"
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: ALL CHECKS PASSED"
  exit 0
else
  echo "RESULT: CHECKS FAILED"
  exit 1
fi
