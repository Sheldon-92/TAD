#!/usr/bin/env bash
# audit-yolo.sh — YOLO execution audit: verifies all TAD process artifacts
# No hook registration. No settings.json. Pure CLI tool.
# Usage:  bash .tad/hooks/lib/audit-yolo.sh <epic-slug>
# Exit:   0 = all pass | 1 = has failures | 2 = usage error
# Deps:   bash + find + grep + stat + wc + git (no jq/yq/python)
# Note:   npm test failure is WARN (may be pre-existing) per handoff §2.2 design decision

set -euo pipefail
IFS=$'\n\t'

# ── ANSI colors ────────────────────────────────────────────────────────
_green="" _yellow="" _red="" _bold="" _reset=""
if [ -z "${NO_COLOR:-}" ] && [ -t 1 ]; then
  _green=$'\033[32m'; _yellow=$'\033[33m'; _red=$'\033[31m'
  _bold=$'\033[1m'; _reset=$'\033[0m'
fi

FAIL_COUNT=0
WARN_COUNT=0
PASS_COUNT=0
TOTAL_COUNT=0

_pass() { TOTAL_COUNT=$((TOTAL_COUNT+1)); PASS_COUNT=$((PASS_COUNT+1)); printf '  %s✅%s %s\n' "$_green" "$_reset" "$*"; }
_fail() { TOTAL_COUNT=$((TOTAL_COUNT+1)); FAIL_COUNT=$((FAIL_COUNT+1)); printf '  %s❌%s %s\n' "$_red" "$_reset" "$*"; }
_warn() { WARN_COUNT=$((WARN_COUNT+1)); printf '  %s⚠️%s  %s\n' "$_yellow" "$_reset" "$*"; }
_err()  { printf '%s%s%s\n' "$_red" "$*" "$_reset" >&2; }
_hdr()  { printf '\n%s%s%s\n' "$_bold" "$*" "$_reset"; }

# ── BSD/GNU stat mtime (epoch seconds) ─────────────────────────────────
if stat --version >/dev/null 2>&1; then
  stat_mtime() { stat -c%Y -- "$1" 2>/dev/null || echo 0; }
else
  stat_mtime() { stat -f%m -- "$1" 2>/dev/null || echo 0; }
fi

# ── Usage ──────────────────────────────────────────────────────────────
if [ $# -lt 1 ] || [ -z "$1" ]; then
  _err "Usage: bash audit-yolo.sh <epic-slug>"
  _err "Example: bash audit-yolo.sh yolo-mode"
  exit 2
fi

SLUG="$1"
EVIDENCE_DIR=".tad/evidence/yolo/${SLUG}"

if [ ! -d "$EVIDENCE_DIR" ]; then
  _err "Evidence directory not found: ${EVIDENCE_DIR}"
  exit 2
fi

# ── Detect phases (using array to avoid IFS word-split issues) ─────────
PHASES_ARR=()
for f in "${EVIDENCE_DIR}"/phase*-grounding.md; do
  [ -f "$f" ] || continue
  n=$(basename "$f" | sed -E 's/^phase([0-9]+)-.*/\1/')
  PHASES_ARR+=("$n")
done
# Sort + deduplicate
if [ ${#PHASES_ARR[@]} -gt 0 ]; then
  IFS=$'\n' PHASES_ARR=($(printf '%s\n' "${PHASES_ARR[@]}" | sort -un)); unset IFS
  IFS=$'\n\t'
fi
PHASE_COUNT=${#PHASES_ARR[@]}

if [ "$PHASE_COUNT" -eq 0 ]; then
  _err "No phases detected in ${EVIDENCE_DIR} (no phase*-grounding.md files)"
  exit 2
fi

printf '%saudit-yolo:%s %s (%s phases detected)\n' "$_bold" "$_reset" "$SLUG" "$PHASE_COUNT"

# ── Helper: find handoff/completion in active or archive ───────────────
# Uses -print -quit to avoid SIGPIPE with pipefail; anchors pattern with .md suffix
find_handoff() {
  local pattern="$1"
  local result=""
  [ -d .tad/active/handoffs ] && result=$(find .tad/active/handoffs -name "HANDOFF-*-${pattern}.md" -type f -print -quit 2>/dev/null) || true
  if [ -z "$result" ] && [ -d .tad/archive/handoffs ]; then
    result=$(find .tad/archive/handoffs -name "HANDOFF-*-${pattern}.md" -type f -print -quit 2>/dev/null) || true
  fi
  echo "$result"
}

find_completion() {
  local pattern="$1"
  local result=""
  [ -d .tad/active/handoffs ] && result=$(find .tad/active/handoffs -name "COMPLETION-*-${pattern}.md" -type f -print -quit 2>/dev/null) || true
  if [ -z "$result" ] && [ -d .tad/archive/handoffs ]; then
    result=$(find .tad/archive/handoffs -name "COMPLETION-*-${pattern}.md" -type f -print -quit 2>/dev/null) || true
  fi
  echo "$result"
}

# ══════════════════════════════════════════════════════════════════════
# DIMENSION 1: Artifact Chain — "文件都在吗？"
# ══════════════════════════════════════════════════════════════════════

for n in "${PHASES_ARR[@]}"; do
  _hdr "Phase ${n}:"

  # 6 evidence files per phase
  if [ -f "${EVIDENCE_DIR}/phase${n}-grounding.md" ]; then
    lines=$(wc -l < "${EVIDENCE_DIR}/phase${n}-grounding.md" | tr -d ' ')
    _pass "grounding.md exists (${lines} lines)"
  else
    _fail "phase${n}-grounding.md missing"
  fi

  # Design reviews (≥2 files: cr + domain)
  cr_design="${EVIDENCE_DIR}/phase${n}-design-review-cr.md"
  if [ -f "$cr_design" ]; then
    lines=$(wc -l < "$cr_design" | tr -d ' ')
    _pass "design-review-cr.md exists (${lines} lines)"
  else
    _fail "phase${n}-design-review-cr.md missing"
  fi

  domain_design_count=$(find "$EVIDENCE_DIR" -name "phase${n}-design-review-*.md" -not -name "*-cr.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  domain_design_count=${domain_design_count:-0}
  if [ "$domain_design_count" -ge 1 ]; then
    _pass "design-review domain expert exists (${domain_design_count} file(s))"
  else
    _fail "phase${n}-design-review-{domain}.md missing (need ≥1 domain expert review)"
  fi

  # Impl reviews (≥2 files: cr + domain)
  cr_impl="${EVIDENCE_DIR}/phase${n}-impl-review-cr.md"
  if [ -f "$cr_impl" ]; then
    lines=$(wc -l < "$cr_impl" | tr -d ' ')
    _pass "impl-review-cr.md exists (${lines} lines)"
  else
    _fail "phase${n}-impl-review-cr.md missing"
  fi

  domain_impl_count=$(find "$EVIDENCE_DIR" -name "phase${n}-impl-review-*.md" -not -name "*-cr.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  domain_impl_count=${domain_impl_count:-0}
  if [ "$domain_impl_count" -ge 1 ]; then
    _pass "impl-review domain expert exists (${domain_impl_count} file(s))"
  else
    _fail "phase${n}-impl-review-{domain}.md missing (need ≥1 domain expert review)"
  fi

  # Gate report
  gate="${EVIDENCE_DIR}/phase${n}-gate-report.md"
  if [ -f "$gate" ]; then
    _pass "gate-report.md exists"
  else
    _fail "phase${n}-gate-report.md missing"
  fi

  # Handoff + Completion (active or archive)
  hf=$(find_handoff "${SLUG}-phase${n}")
  if [ -n "$hf" ]; then
    location="active"
    echo "$hf" | grep -q "archive" && location="archive"
    _pass "HANDOFF found in ${location}"
  else
    _fail "HANDOFF for ${SLUG}-phase${n} not found in active/ or archive/"
  fi

  cf=$(find_completion "${SLUG}-phase${n}")
  if [ -n "$cf" ]; then
    location="active"
    echo "$cf" | grep -q "archive" && location="archive"
    _pass "COMPLETION found in ${location}"
  else
    _fail "COMPLETION for ${SLUG}-phase${n} not found in active/ or archive/"
  fi

  # Git commit (case-insensitive)
  commit=$(git log --oneline -i --grep="YOLO Phase ${n}" 2>/dev/null | sed -n '1p')
  if [ -n "$commit" ]; then
    sha=$(echo "$commit" | cut -d' ' -f1)
    _pass "Git commit found: ${sha}"
  else
    _fail "No git commit for Phase ${n} (grep: 'YOLO Phase ${n}')"
  fi
done

# Epic-level files
_hdr "Epic-level:"

if [ -f "${EVIDENCE_DIR}/EPIC-COMPLETION.md" ]; then
  _pass "EPIC-COMPLETION.md exists"
else
  _fail "EPIC-COMPLETION.md missing"
fi

# ══════════════════════════════════════════════════════════════════════
# DIMENSION 2: Content Authenticity — "不是空壳吗？"
# ══════════════════════════════════════════════════════════════════════

for n in "${PHASES_ARR[@]}"; do
  # Design review: min lines + P0/P1/P2 classification
  cr_design="${EVIDENCE_DIR}/phase${n}-design-review-cr.md"
  if [ -f "$cr_design" ]; then
    review_lines=$(wc -l < "$cr_design" | tr -d ' ')
    review_lines=${review_lines:-0}
    if [ "$review_lines" -ge 20 ]; then
      _pass "Phase ${n} design review ≥20 lines (${review_lines})"
    else
      _fail "Phase ${n} design review too short (${review_lines} lines, need ≥20)"
    fi
    if grep -qE '(^|[^A-Za-z0-9])P[012]([^A-Za-z0-9]|$)|## P0|## P1|## P2|no issues|no critical' "$cr_design" 2>/dev/null; then
      _pass "Phase ${n} design review has P0/P1/P2 classification"
    else
      _fail "Phase ${n} design review missing P0/P1/P2 classification"
    fi
  fi

  # Impl review: min lines + P0/P1/P2 classification (symmetric with design review)
  cr_impl="${EVIDENCE_DIR}/phase${n}-impl-review-cr.md"
  if [ -f "$cr_impl" ]; then
    review_lines=$(wc -l < "$cr_impl" | tr -d ' ')
    review_lines=${review_lines:-0}
    if [ "$review_lines" -ge 20 ]; then
      _pass "Phase ${n} impl review ≥20 lines (${review_lines})"
    else
      _fail "Phase ${n} impl review too short (${review_lines} lines, need ≥20)"
    fi
    if grep -qE '(^|[^A-Za-z0-9])P[012]([^A-Za-z0-9]|$)|## P0|## P1|## P2|no issues|no critical' "$cr_impl" 2>/dev/null; then
      _pass "Phase ${n} impl review has P0/P1/P2 classification"
    else
      _fail "Phase ${n} impl review missing P0/P1/P2 classification"
    fi
  fi

  # Completion has AC table
  cf=$(find_completion "${SLUG}-phase${n}")
  if [ -n "$cf" ]; then
    if grep -qE "\| *AC" "$cf" 2>/dev/null; then
      _pass "Phase ${n} completion has AC table"
    else
      _fail "Phase ${n} completion missing AC table"
    fi
  fi

  # Gate report has verdict + KA
  gate="${EVIDENCE_DIR}/phase${n}-gate-report.md"
  if [ -f "$gate" ]; then
    if grep -qiE "PASS|FAIL|PARTIAL" "$gate" 2>/dev/null; then
      _pass "Phase ${n} gate report has verdict"
    else
      _fail "Phase ${n} gate report missing verdict"
    fi
    if grep -qiE "Knowledge Assessment|KA:|no new discover" "$gate" 2>/dev/null; then
      _pass "Phase ${n} gate report has KA section"
    else
      _fail "Phase ${n} gate report missing Knowledge Assessment"
    fi
  fi

  # AC count cross-check (warn only)
  hf=$(find_handoff "${SLUG}-phase${n}")
  if [ -n "$hf" ] && [ -n "$cf" ]; then
    handoff_acs=$(grep -cE '^\- \[(x| )\]' "$hf" 2>/dev/null || echo 0)
    completion_acs=$(grep -cE '\| *AC' "$cf" 2>/dev/null || echo 0)
    handoff_acs=${handoff_acs:-0}
    completion_acs=${completion_acs:-0}
    diff=$((handoff_acs - completion_acs))
    diff=${diff#-}
    if [ "$diff" -le 2 ]; then
      _pass "Phase ${n} AC count match (handoff=${handoff_acs}, completion=${completion_acs})"
    else
      _warn "Phase ${n} AC count mismatch (handoff=${handoff_acs}, completion=${completion_acs}, diff=${diff})"
    fi
  fi
done

# ══════════════════════════════════════════════════════════════════════
# DIMENSION 3: Code Verification — "客观重跑"
# ══════════════════════════════════════════════════════════════════════

_hdr "Code Verification:"

if [ -f "tsconfig.json" ]; then
  if npx tsc --noEmit >/dev/null 2>&1; then
    _pass "tsc --noEmit passed"
  else
    _fail "tsc --noEmit failed"
  fi
else
  _warn "No tsconfig.json — skipping tsc check"
fi

if [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  if npm test >/dev/null 2>&1; then
    _pass "npm test passed"
  else
    _warn "npm test failed (may be pre-existing)"
  fi
else
  _warn "No test script in package.json — skipping npm test"
fi

# ══════════════════════════════════════════════════════════════════════
# DIMENSION 4: Timing — "顺序对吗？"
# ══════════════════════════════════════════════════════════════════════

_hdr "Timing:"

prev_gate_time=0
for n in "${PHASES_ARR[@]}"; do
  grounding="${EVIDENCE_DIR}/phase${n}-grounding.md"
  cr_design="${EVIDENCE_DIR}/phase${n}-design-review-cr.md"
  cr_impl="${EVIDENCE_DIR}/phase${n}-impl-review-cr.md"
  gate="${EVIDENCE_DIR}/phase${n}-gate-report.md"

  if [ -f "$grounding" ] && [ -f "$cr_design" ] && [ -f "$gate" ]; then
    t_g=$(stat_mtime "$grounding")
    t_r=$(stat_mtime "$cr_design")
    t_i=0
    [ -f "$cr_impl" ] && t_i=$(stat_mtime "$cr_impl")
    t_gate=$(stat_mtime "$gate")

    order_ok=true
    if [ "$t_g" -gt "$t_r" ]; then
      _warn "Phase ${n}: grounding timestamp > design review timestamp"
      order_ok=false
    fi
    if [ "$t_i" -gt 0 ] && [ "$t_r" -gt "$t_i" ]; then
      _warn "Phase ${n}: design review timestamp > impl review timestamp"
      order_ok=false
    fi
    if [ "$t_i" -gt 0 ] && [ "$t_i" -gt "$t_gate" ]; then
      _warn "Phase ${n}: impl review timestamp > gate timestamp"
      order_ok=false
    elif [ "$t_r" -gt "$t_gate" ]; then
      _warn "Phase ${n}: design review timestamp > gate timestamp"
      order_ok=false
    fi
    if [ "$order_ok" = true ]; then
      _pass "Phase ${n} file order correct (grounding → review → impl-review → gate)"
    fi

    # Cross-phase ordering: Phase N gate before Phase N+1 grounding
    if [ "$prev_gate_time" -gt 0 ] && [ "$t_g" -lt "$prev_gate_time" ]; then
      _warn "Phase ${n}: grounding timestamp < previous phase gate timestamp (cross-phase order)"
    fi
    prev_gate_time=$t_gate
  fi
done

# Epic Phase status
epic_file=""
if [ -d .tad/active/epics ]; then
  epic_file=$(find .tad/active/epics -name "EPIC-*${SLUG}*" -type f -print -quit 2>/dev/null) || true
fi
if [ -z "$epic_file" ] && [ -d .tad/archive/epics ]; then
  epic_file=$(find .tad/archive/epics -name "EPIC-*${SLUG}*" -type f -print -quit 2>/dev/null) || true
fi

if [ -n "$epic_file" ]; then
  planned=$(grep -c "⬚ Planned" "$epic_file" 2>/dev/null || echo 0)
  active=$(grep -c "🔄 Active" "$epic_file" 2>/dev/null || echo 0)
  planned=${planned:-0}
  active=${active:-0}
  if [ "$planned" -eq 0 ] && [ "$active" -eq 0 ]; then
    _pass "All phases Done in Epic file"
  else
    _fail "Epic has non-Done phases: ${planned} planned, ${active} active"
  fi
else
  _warn "Epic file not found for slug '${SLUG}'"
fi

# ══════════════════════════════════════════════════════════════════════
# RESULT
# ══════════════════════════════════════════════════════════════════════

printf '\n%s━━━━━━━━━━━━━━━━━━━━━%s\n' "$_bold" "$_reset"
if [ "$FAIL_COUNT" -eq 0 ]; then
  printf '%sRESULT: PASS%s (%d/%d checks, %d warnings)\n' "$_green" "$_reset" "$PASS_COUNT" "$TOTAL_COUNT" "$WARN_COUNT"
  exit 0
else
  printf '%sRESULT: FAIL%s (%d/%d checks passed, %d failed, %d warnings)\n' "$_red" "$_reset" "$PASS_COUNT" "$TOTAL_COUNT" "$FAIL_COUNT" "$WARN_COUNT"
  exit 1
fi
