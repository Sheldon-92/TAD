#!/usr/bin/env bash
# skill-body-verify.sh — verify Blake + Alex SKILL.md bodies contain execution-discipline markers
# Exit 0 = all checks pass, Exit 1 = at least one check failed

set -euo pipefail

DEFAULT_SKILL=".agents/skills/blake/SKILL.md"
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
SAFETY_FLOOR=70
echo "Safety keywords: $SAFETY_COUNT (floor: $SAFETY_FLOOR)"
if [ "$SAFETY_COUNT" -lt "$SAFETY_FLOOR" ]; then
  echo "FAIL: Safety keyword count $SAFETY_COUNT < $SAFETY_FLOOR"
  FAIL=1
else
  echo "  OK: Safety keyword count meets floor"
fi

echo "---"

# Negative presence: inlined refs must NOT be recreated
BLAKE_REFS=".agents/skills/blake/references"
for ref in completion-protocol.md execution-checklist.md ralph-loop.md; do
  if [[ -f "$BLAKE_REFS/$ref" ]]; then
    echo "FAIL: $ref was re-extracted (must stay inlined in body)"
    FAIL=1
  else
    echo "  OK: $ref not present (correctly inlined)"
  fi
done

echo "---"

if [ "$IS_CUSTOM_PATH" = true ]; then
  echo "SKIP: source-consistency checks (custom path — marker+safety only)"
else
  # v3.0.0: single skill tree (.agents/skills is the sole source) — no mirror
  # comparison remains. Assert the canonical blake body exists and is non-empty.
  AGENTS_SKILL=".agents/skills/blake/SKILL.md"
  REF_DIR=".agents/skills/blake/references"

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

# ============================================================
# Alex section (added 2026-07-12 — skill-body-reference-boundary re-audit)
# Overrides for mutation testing only:
#   ALEX_SKILL_PATH — alternate alex SKILL.md (marker + non-circularity checks only)
#   ALEX_REFS_DIR   — alternate references/ dir (negative-presence check only)
# ============================================================

DEFAULT_ALEX_SKILL=".agents/skills/alex/SKILL.md"
DEFAULT_ALEX_REFS=".agents/skills/alex/references"
ALEX_SKILL="${ALEX_SKILL_PATH:-$DEFAULT_ALEX_SKILL}"
ALEX_REFS="${ALEX_REFS_DIR:-$DEFAULT_ALEX_REFS}"
ALEX_IS_CUSTOM=false
if [ "$ALEX_SKILL" != "$DEFAULT_ALEX_SKILL" ] || [ "$ALEX_REFS" != "$DEFAULT_ALEX_REFS" ]; then
  ALEX_IS_CUSTOM=true
fi

echo "Checking: $ALEX_SKILL"
echo "---"

if [ ! -f "$ALEX_SKILL" ]; then
  echo "FAIL: File not found: $ALEX_SKILL"
  FAIL=1
else
  # Positive body markers — body-kept protocols must stay inlined
  declare -a ALEX_MARKERS=(
    "research_unified_protocol:"
    "distillation_loop:"
    "note_blocking_taxonomy"
    "read_feedback_protocol:"
    "MANDATORY: Socratic Inquiry Protocol"
    "anti_rationalization_registry:"
    "NOT_via_alex_auto: true"
  )
  declare -a ALEX_LABELS=(
    "research_unified_protocol (research routing table)"
    "distillation_loop (Gate 4 KA distillation trigger)"
    "note_blocking_taxonomy (3-layer blocking taxonomy)"
    "read_feedback_protocol (feedback read protocol)"
    "Socratic Inquiry Protocol (MANDATORY body header)"
    "anti_rationalization_registry (AR registry block)"
    "NOT_via_alex_auto (AR-001 grep anchor)"
  )

  for i in "${!ALEX_MARKERS[@]}"; do
    pattern="${ALEX_MARKERS[$i]}"
    label="${ALEX_LABELS[$i]}"
    count=$(grep -cF "$pattern" "$ALEX_SKILL" 2>/dev/null || true)
    if [ "$count" -eq 0 ]; then
      echo "FAIL: Missing alex marker — $label (pattern: $pattern)"
      FAIL=1
    else
      echo "  OK: $label ($count occurrences)"
    fi
  done

  echo "---"

  # Generic non-circularity smoke test: every load_when must name an
  # independently-knowable trigger (a *command token or an explicit event phrase).
  LW_TOTAL=0
  LW_BAD=0
  while IFS= read -r lw_line; do
    LW_TOTAL=$((LW_TOTAL + 1))
    if ! printf '%s\n' "$lw_line" | grep -qE '\*[a-z-]+' && \
       ! printf '%s\n' "$lw_line" | grep -qE 'When|invoked|entered|returns|begins|selected|Read the reference'; then
      echo "FAIL: circular-risk load_when (no *command token, no event phrase):"
      echo "      $lw_line"
      LW_BAD=$((LW_BAD + 1))
      FAIL=1
    fi
  done < <(grep -E '^[[:space:]]*load_when:' "$ALEX_SKILL" || true)
  if [ "$LW_BAD" -eq 0 ]; then
    echo "  OK: non-circularity smoke test ($LW_TOTAL load_when lines, 0 circular-risk)"
  fi
fi

echo "---"

# Negative presence: body-kept alex protocols must never be silently re-extracted
for ref in research-unified-protocol.md read-feedback-protocol.md feedback-collector-protocol.md; do
  if [ -f "$ALEX_REFS/$ref" ]; then
    echo "FAIL: $ref was re-extracted (must stay inlined in alex body)"
    FAIL=1
  else
    echo "  OK: $ref not present (correctly inlined)"
  fi
done

echo "---"

if [ "$ALEX_IS_CUSTOM" = true ]; then
  echo "SKIP: alex source-consistency + gate checks (custom path — marker/negative-presence only)"
else
  # v3.0.0: single skill tree — the alex body IS the canonical source.
  AGENTS_ALEX_SKILL=".agents/skills/alex/SKILL.md"
  if [ -s "$AGENTS_ALEX_SKILL" ]; then
    echo "  OK: alex canonical SKILL.md present and non-empty"
  else
    echo "FAIL: alex canonical SKILL.md missing or empty at $AGENTS_ALEX_SKILL"
    FAIL=1
  fi

  # TEMP exclusion (2026-07-12): distillation-loop-protocol.md is mid-flight in the
  # memory-redirect handoff (parallel session). REMOVE the -x exclusion after it lands.
  AGENTS_ALEX_REFS=".agents/skills/alex/references"
  if [ -d "$AGENTS_ALEX_REFS" ]; then
    if [ -f "$AGENTS_ALEX_REFS/research-track-protocol.md" ]; then
      echo "  OK: alex canonical references/ present"
    else
      echo "FAIL: alex canonical references/ missing anchor file at $AGENTS_ALEX_REFS"
      FAIL=1
    fi
  else
    echo "WARN: alex references dir not found at $AGENTS_ALEX_REFS (skipping)"
  fi

  # gate/SKILL.md must have NO references/ dir (extraction without verifier coverage is forbidden)
  for gate_refs in .agents/skills/gate/references .agents/skills/gate/references; do
    if [ -d "$gate_refs" ]; then
      echo "FAIL: $gate_refs exists — gate/SKILL.md was extracted without verifier coverage"
      FAIL=1
    else
      echo "  OK: $gate_refs absent (gate body fully inlined)"
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
