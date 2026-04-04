#!/bin/bash
# TAD PreToolUse Hook — Gate 3/4 Prerequisite Check
# Gate 3: Requires COMPLETION report (BLOCK if missing)
# Gate 4: Warns if no COMPLETION (does not BLOCK)
# Cold start safe: missing evidence dir = ALLOW with warning
# Exit 0 = ALLOW, Exit 2 = BLOCK
# Must complete in <500ms (no network calls).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Read stdin JSON from Claude Code
read_stdin_json

# Extract tool name and skill details
TOOL_NAME=$(get_json_field ".tool_name" || echo "")
SKILL_NAME=$(get_json_field ".tool_input.skill" || echo "")
SKILL_ARGS=$(get_json_field ".tool_input.args" || echo "")

# Only check when invoking Skill tool with "gate" in skill name
if [ "$TOOL_NAME" != "Skill" ] || [[ "$SKILL_NAME" != *"gate"* ]]; then
  output_empty
  exit 0
fi

# Check if TAD is initialized
if [ ! -d ".tad" ]; then
  output_empty
  exit 0
fi

# Extract gate number from args (first digit found)
GATE_NUM=$(echo "$SKILL_ARGS" | grep -oE '^[0-9]+' | head -1)

if [ "$GATE_NUM" = "3" ]; then
  # Gate 3 prerequisite: COMPLETION report must exist

  # Cold start safety: if handoffs dir doesn't exist, ALLOW (first-time project)
  if [ ! -d ".tad/active/handoffs" ]; then
    output_response "PreToolUse" "First-time project: no handoffs directory. Gate 3 will proceed but completion evidence is recommended."
    exit 0
  fi

  # Check for COMPLETION report
  COMPLETION=$(safe_count ".tad/active/handoffs/COMPLETION-*.md")

  if [ "$COMPLETION" = "0" ]; then
    echo "Cannot run Gate 3: no COMPLETION report found in .tad/active/handoffs/. Run *complete first to generate the completion report." >&2
    exit 2  # BLOCK
  fi

  # === Comprehensive evidence checks (Phase 4) ===
  # General evidence missing = WARNING (remind but don't block)
  # Conditional evidence (e2e/research) missing = BLOCK (exit 2)
  # Boolean flag controls BLOCK, not grep on string content

  WARNINGS=""
  HAS_BLOCK=0

  # Locate COMPLETION file for -newer comparison
  COMPLETION_FILE=$(ls .tad/active/handoffs/COMPLETION-*.md 2>/dev/null | head -1)

  # Check 1: Recent evidence files
  if [ -n "$COMPLETION_FILE" ]; then
    EVIDENCE_COUNT=$(find .tad/evidence -maxdepth 2 -name "*.md" -newer "$COMPLETION_FILE" 2>/dev/null | wc -l | tr -d ' ')
  else
    EVIDENCE_COUNT=0
  fi
  if [ "$EVIDENCE_COUNT" = "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: No recent evidence files found in .tad/evidence/. Did you complete expert review and acceptance verification?"
  fi

  # Check 2: Ralph Loop state file
  RALPH_COUNT=$(find .tad/evidence/ralph-loops -maxdepth 1 -name "*_state.yaml" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$RALPH_COUNT" = "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: No Ralph Loop state file found. Did you run *develop with Ralph Loop?"
  fi

  # Check 3: Read handoff frontmatter for conditional fields
  # Locate handoff: extract Handoff ID from COMPLETION report, fallback to ls
  HANDOFF_FILE=""
  if [ -n "$COMPLETION_FILE" ]; then
    HANDOFF_ID=$(grep -o '\*\*Handoff ID:\*\* [^ ]*' "$COMPLETION_FILE" 2>/dev/null | sed 's/\*\*Handoff ID:\*\* //' | tr -d '[:space:]')
    if [ -n "$HANDOFF_ID" ] && [ -f ".tad/active/handoffs/${HANDOFF_ID}" ]; then
      HANDOFF_FILE=".tad/active/handoffs/${HANDOFF_ID}"
    fi
  fi
  # Fallback: scan directory
  if [ -z "$HANDOFF_FILE" ]; then
    HANDOFF_FILE=$(ls .tad/active/handoffs/HANDOFF-*.md 2>/dev/null | head -1)
  fi

  if [ -n "$HANDOFF_FILE" ]; then
    # Parse only frontmatter area (first 10 lines) to avoid matching examples in body
    E2E_REQ=$(head -10 "$HANDOFF_FILE" | grep '^e2e_required:' | awk '{print $2}')
    RESEARCH_REQ=$(head -10 "$HANDOFF_FILE" | grep '^research_required:' | awk '{print $2}')

    # Check 3a: E2E evidence (conditional — BLOCK)
    if [ "$E2E_REQ" = "yes" ]; then
      E2E_EVIDENCE=$(find .tad/evidence -maxdepth 2 -name "*e2e*" -o -name "*E2E*" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$E2E_EVIDENCE" = "0" ]; then
        WARNINGS="${WARNINGS}"$'\n'"BLOCKED: Handoff requires E2E (e2e_required: yes) but no E2E evidence found. Gate 3 cannot pass."
        HAS_BLOCK=1
      fi
    fi

    # Check 3b: Research files (conditional — BLOCK)
    if [ "$RESEARCH_REQ" = "yes" ]; then
      RESEARCH_EVIDENCE=$(find .tad/evidence -maxdepth 2 -name "*research*" -o -name "*best-practices*" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$RESEARCH_EVIDENCE" = "0" ]; then
        WARNINGS="${WARNINGS}"$'\n'"BLOCKED: Handoff requires research (research_required: yes) but no research evidence found. Gate 3 cannot pass."
        HAS_BLOCK=1
      fi
    fi
  fi

  # Check 4: Git working tree (uncommitted changes outside .tad/)
  GIT_DIRTY=$(git status --porcelain -- ':!.tad/' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$GIT_DIRTY" != "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Uncommitted changes detected outside .tad/. Did you commit implementation code?"
  fi

  # Check 5: Evidence file content valid (non-empty/non-stub)
  MIN_SIZE=100  # bytes — below this threshold = empty file/template
  if [ -d ".tad/evidence/reviews" ]; then
    EMPTY_EVIDENCE=0
    for f in .tad/evidence/reviews/*.md; do
      [ -f "$f" ] || continue
      FSIZE=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo "0")
      if [ "$FSIZE" -lt "$MIN_SIZE" ]; then
        EMPTY_EVIDENCE=$((EMPTY_EVIDENCE + 1))
      fi
    done
    if [ "$EMPTY_EVIDENCE" -gt 0 ]; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: ${EMPTY_EVIDENCE} evidence file(s) in .tad/evidence/reviews/ are under ${MIN_SIZE} bytes — possibly empty stubs."
    fi
  fi

  # Check 6: Knowledge Assessment filled (not template default "Yes / No" on same line)
  if [ -n "$COMPLETION_FILE" ]; then
    KA_LINE=$(grep '是否有新发现\|New discoveries' "$COMPLETION_FILE" 2>/dev/null | head -1)
    if [ -n "$KA_LINE" ]; then
      HAS_YES=$(echo "$KA_LINE" | grep -c 'Yes' || echo "0")
      HAS_NO=$(echo "$KA_LINE" | grep -c 'No' || echo "0")
      if [ "$HAS_YES" -gt 0 ] && [ "$HAS_NO" -gt 0 ]; then
        WARNINGS="${WARNINGS}"$'\n'"WARNING: Knowledge Assessment appears unfilled (template default detected). Gate 3 requires choosing Yes or No."
      fi
    else
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Knowledge Assessment section not found in completion report."
    fi
  fi

  # Check 7: Evidence Checklist has checked items (not all [ ])
  if [ -n "$COMPLETION_FILE" ]; then
    CHECKED=$(grep -c '\[x\]' "$COMPLETION_FILE" 2>/dev/null || echo "0")
    UNCHECKED=$(grep -c '\[ \]' "$COMPLETION_FILE" 2>/dev/null || echo "0")
    TOTAL=$((CHECKED + UNCHECKED))
    if [ "$TOTAL" -gt 0 ] && [ "$CHECKED" = "0" ]; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Evidence Checklist has ${UNCHECKED} unchecked items and 0 checked items. Did you complete the checklist?"
    fi
  fi

  # Check 8: Gate 3 v2 result not FAIL or unfilled template
  if [ -n "$COMPLETION_FILE" ]; then
    GATE3_RESULT=$(grep 'Gate 3.*结果\|Gate 3.*Result' "$COMPLETION_FILE" 2>/dev/null | head -1)
    if [ -n "$GATE3_RESULT" ]; then
      if echo "$GATE3_RESULT" | grep -q "FAIL"; then
        WARNINGS="${WARNINGS}"$'\n'"BLOCKED: Completion report shows Gate 3 FAIL. Cannot proceed."
        HAS_BLOCK=1
      elif echo "$GATE3_RESULT" | grep -q "PASS"; then
        : # OK
      else
        WARNINGS="${WARNINGS}"$'\n'"WARNING: Gate 3 result line found but doesn't contain PASS or FAIL — may be unfilled template."
      fi
    fi
  fi

  # Check 9: AC count vs verification script count
  if [ -n "$HANDOFF_FILE" ]; then
    AC_COUNT=$(sed -n '/## .*Acceptance Criteria/,/^## /p' "$HANDOFF_FILE" 2>/dev/null | grep -c '^\- \[' || echo "0")
    SCRIPT_COUNT=$(find .tad/evidence/acceptance-tests -name "AC-*" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$AC_COUNT" -gt 0 ] && [ "$SCRIPT_COUNT" -gt 0 ] && [ "$SCRIPT_COUNT" -lt "$AC_COUNT" ]; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Handoff has ${AC_COUNT} acceptance criteria but only ${SCRIPT_COUNT} verification scripts found. Some ACs may not have been verified."
    fi
  fi

  # Check 10: Ralph Loop state shows layer2 completed (not just file exists)
  RALPH_STATE=$(ls .tad/evidence/ralph-loops/*_state.yaml 2>/dev/null | head -1)
  if [ -n "$RALPH_STATE" ]; then
    L2_DONE=$(grep '^last_completed_layer:.*layer2' "$RALPH_STATE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$L2_DONE" = "0" ]; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Ralph Loop state exists but last_completed_layer is not layer2. Did Layer 2 expert review complete?"
    fi
  fi

  # Check 11: Expert review files ≥ 2 (code-reviewer required + 1 domain)
  if [ -d ".tad/evidence/reviews" ]; then
    REVIEW_COUNT=$(find .tad/evidence/reviews -maxdepth 1 -name "*.md" -size +100c 2>/dev/null | wc -l | tr -d ' ')
    if [ "$REVIEW_COUNT" -lt 2 ]; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Only ${REVIEW_COUNT} expert review file(s) found (≥2 required: code-reviewer + domain expert)."
    fi
  fi

  # Check 12: Commit hash not a placeholder
  if [ -n "$COMPLETION_FILE" ]; then
    COMMIT_LINE=$(grep -i 'commit.*hash\|changes committed' "$COMPLETION_FILE" 2>/dev/null | head -1)
    if [ -n "$COMMIT_LINE" ]; then
      if echo "$COMMIT_LINE" | grep -qE '\[hash\]|\[NONE\]|\[commit[_ ]'; then
        WARNINGS="${WARNINGS}"$'\n'"WARNING: Commit hash in completion report appears to be a placeholder. Did you commit implementation changes?"
      fi
    fi
  fi

  # Output results
  if [ "$HAS_BLOCK" = "1" ]; then
    echo "Gate 3 BLOCKED: Required evidence missing.${WARNINGS}" >&2
    exit 2
  elif [ -n "$WARNINGS" ]; then
    output_response "PreToolUse" "Gate 3 prerequisites met (COMPLETION found). Please review these warnings before proceeding:${WARNINGS}"
  else
    output_response "PreToolUse" "Gate 3 prerequisites met. COMPLETION report and evidence checks passed."
  fi
  exit 0

elif [ "$GATE_NUM" = "4" ]; then
  # Gate 4: warn if no COMPLETION, but don't BLOCK (Alex-side responsibility)
  COMPLETION=$(safe_count ".tad/active/handoffs/COMPLETION-*.md")

  if [ "$COMPLETION" = "0" ]; then
    output_response "PreToolUse" "Warning: no completion report found. Gate 4 typically requires Gate 3 to pass first."
  else
    output_response "PreToolUse" "Gate 4 prerequisites met. Completion report found."
  fi
  exit 0

else
  # Gate 1, 2, or other → allow without checks
  output_empty
  exit 0
fi
