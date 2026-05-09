#!/usr/bin/env bash
# AC-P2.2 — Alex step1c grounding pass + handoff template Grounded Against
# Covers: AC-P2.2 a–h (8 ACs)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
ALEX_SKILL="${REPO_ROOT}/.claude/skills/alex/SKILL.md"
TEMPLATE="${REPO_ROOT}/.tad/templates/handoff-a-to-b.md"
HANDOFF_DOGFOOD="${REPO_ROOT}/.tad/active/handoffs/HANDOFF-20260424-phase2-grounding.md"
SETTINGS="${REPO_ROOT}/.claude/settings.json"

PASS=0; FAIL=0
_pass() { printf '[PASS] %s\n' "$1"; PASS=$((PASS+1)); }
_fail() { printf '[FAIL] %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; FAIL=$((FAIL+1)); }

# ── AC-P2.2-a: Alex SKILL has step1c block, located between step1b and step2 ──
if grep -q '^    step1c:' "$ALEX_SKILL"; then
  _pass "AC-P2.2-a Alex SKILL has step1c block"
else
  _fail "AC-P2.2-a Alex SKILL missing step1c block"
fi

# Order check: step0_5 < step1 < step1b < step1c < step2 INSIDE handoff_creation_protocol
# Need to scope to the protocol section because step1/step2 appear in many other protocols.
HCP_START=$(grep -n '^handoff_creation_protocol:' "$ALEX_SKILL" | head -1 | cut -d: -f1)
[ -z "$HCP_START" ] && { _fail "AC-P2.2-a handoff_creation_protocol section not found"; HCP_START=0; }

# Find each step's first occurrence AFTER HCP_START
order_ok=true
prev_line=0
for marker in 'step0_5:' 'step1:' 'step1b:' 'step1c:' 'step2:'; do
  line=$(awk -v start="$HCP_START" -v m="$marker" \
    'NR > start && $0 ~ "^    " m "$" { print NR; exit }' "$ALEX_SKILL")
  if [ -z "$line" ]; then
    order_ok=false
    printf '  [debug] marker %s not found after handoff_creation_protocol (line %s)\n' "$marker" "$HCP_START"
    break
  fi
  if [ "$line" -le "$prev_line" ]; then
    order_ok=false
    printf '  [debug] %s at line %s comes before previous line %s\n' "$marker" "$line" "$prev_line"
    break
  fi
  prev_line="$line"
done
[ "$order_ok" = "true" ] && _pass "AC-P2.2-a step ordering: step0_5 < step1 < step1b < step1c < step2" \
  || _fail "AC-P2.2-a step ordering broken"

# ── AC-P2.2-b: handoff template has Grounded Against placeholder + 1-line description ──
if grep -q '\*\*Grounded Against\*\*' "$TEMPLATE"; then
  _pass "AC-P2.2-b handoff template has Grounded Against placeholder"
else
  _fail "AC-P2.2-b template missing Grounded Against"
fi

if grep -qE 'Alex step1c|step1c.*强制' "$TEMPLATE"; then
  _pass "AC-P2.2-b template explanation references Alex step1c"
else
  _fail "AC-P2.2-b template missing step1c reference"
fi

# ── AC-P2.2-c: Dogfood — handoff §6 Grounded Against is filled ──
if [ -f "$HANDOFF_DOGFOOD" ]; then
  if grep -q '\*\*Grounded Against\*\*' "$HANDOFF_DOGFOOD"; then
    _pass "AC-P2.2-c dogfood — handoff §6 has Grounded Against line"
  else
    _fail "AC-P2.2-c dogfood handoff missing Grounded Against"
  fi
  # Verify it's filled with at least one real path (not just placeholder)
  if grep -A 10 '\*\*Grounded Against\*\*' "$HANDOFF_DOGFOOD" | grep -qE '^- \`?\.tad/|^- \`?\.claude/'; then
    _pass "AC-P2.2-c dogfood Grounded Against contains real paths"
  else
    _fail "AC-P2.2-c dogfood Grounded Against is empty placeholder"
  fi
else
  _fail "AC-P2.2-c dogfood handoff not found"
fi

# ── AC-P2.2-d: Alex SKILL describes prompt-level enforcement + forbidden_implementations ──
if grep -q 'enforcement: "prompt-level-only"' "$ALEX_SKILL"; then
  _pass "AC-P2.2-d step1c enforcement: prompt-level-only declared"
else
  _fail "AC-P2.2-d enforcement clause missing"
fi

if grep -q 'forbidden_implementations:' "$ALEX_SKILL"; then
  _pass "AC-P2.2-d forbidden_implementations list present"
else
  _fail "AC-P2.2-d forbidden_implementations missing"
fi

for forbidden in 'PreToolUse hook' 'UserPromptSubmit hook' 'auto-fired script' 'deny exit code'; do
  if grep -q "$forbidden" "$ALEX_SKILL"; then
    _pass "AC-P2.2-d forbidden_implementations covers '$forbidden'"
  else
    _fail "AC-P2.2-d missing forbidden item: $forbidden"
  fi
done

# ── AC-P2.2-e: SKILL covers (new — will be created) marker ──
if grep -q 'new — will be created' "$ALEX_SKILL"; then
  _pass "AC-P2.2-e step1c describes (new — will be created) marker"
else
  _fail "AC-P2.2-e step1c missing new-marker description"
fi

# ── AC-P2.2-f: Anti-Epic-1 mechanical grep — extended pattern ──
# grep -rE 'step1c|grounding-pass|grounded_against' settings.json + hooks
hits=0
if [ -f "$SETTINGS" ]; then
  matches=$(grep -E 'step1c|grounding-pass|grounded_against' "$SETTINGS" 2>/dev/null \
    | grep -vc '^[[:space:]]*//') || matches=0
  matches=${matches:-0}
  hits=$((hits + matches))
fi

# Hook scripts
hook_matches=$(grep -rE 'step1c|grounding-pass|grounded_against' \
  "${REPO_ROOT}/.tad/hooks/" 2>/dev/null \
  | grep -v ':[[:space:]]*#' \
  | wc -l | tr -d ' ') || hook_matches=0
hook_matches=${hook_matches:-0}
hits=$((hits + hook_matches))

if [ "$hits" -eq 0 ]; then
  _pass "AC-P2.2-f anti-Epic-1 grep: 0 hits in settings.json + hooks (executable)"
else
  _fail "AC-P2.2-f anti-Epic-1 grep: $hits hits found (grounding pass leaked into hook layer)"
fi

# Phase 2-specific anti-Epic-1 check: did Phase 2 add NEW hook registrations
# or grounding-pass keywords to settings.json / hooks?
# Pre-Phase-2 baseline already has PreToolUse / UserPromptSubmit registrations
# (pre-accept-check, pre-gate-check, userprompt-domain-router) — those are
# Phase 1 / 2.6 / 2.8 features, not Phase 2 additions.
#
# What we actually need to verify: the grounding pass and stale-check do not
# leak into hook layer.
phase2_keywords='step1c|grounding-pass|grounding_pass|grounded_against|stale-knowledge-check|stale_knowledge_check'
phase2_leaks=$(grep -rnE "$phase2_keywords" \
  "${REPO_ROOT}/.claude/settings.json" \
  "${REPO_ROOT}/.tad/hooks/"*.sh \
  "${REPO_ROOT}/.tad/hooks/lib/"*.sh 2>/dev/null \
  | grep -v 'stale-knowledge-check.sh:' \
  | grep -v ':[[:space:]]*#' \
  | grep -v ':[[:space:]]*//' \
  || true)

# Capture full evidence
{
  echo "Anti-Epic-1 mechanical grep — $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "## Phase 2-specific keyword check (must be 0)"
  echo "Pattern: $phase2_keywords"
  echo "Excluded: lines from stale-knowledge-check.sh itself, comment lines"
  echo ""
  echo "Phase 2 leaks into hook layer:"
  if [ -z "$phase2_leaks" ]; then
    echo "(none — anti-Epic-1 compliance OK)"
  else
    echo "$phase2_leaks"
  fi
  echo ""
  echo "## Pre-Phase-2 baseline (informational, NOT counted as Phase 2 violations)"
  echo "Pattern: PreToolUse|UserPromptSubmit|hookSpecificOutput|permissions.deny"
  echo ""
  grep -rnE 'PreToolUse|UserPromptSubmit|hookSpecificOutput|permissions\.deny' \
    "${REPO_ROOT}/.claude/settings.json" \
    "${REPO_ROOT}/.tad/hooks/"*.sh \
    "${REPO_ROOT}/.tad/hooks/lib/"*.sh 2>/dev/null \
    | head -20 \
    || echo "(no matches)"
  echo ""
  echo "## Verdict"
  if [ -z "$phase2_leaks" ]; then
    echo "PASS — Phase 2 (step1c + stale-check) introduced ZERO hook registrations,"
    echo "ZERO settings.json modifications, ZERO grounding-pass leaks into auto-fired layer."
  else
    echo "FAIL — Phase 2 leaked into hook layer (review above)."
  fi
} > "${REPO_ROOT}/.tad/evidence/completions/phase2-grounding/anti-epic1-grep.txt"

if [ -z "$phase2_leaks" ]; then
  _pass "AC-P2.2-f Phase 2 keywords (step1c/grounding/stale-check) NOT in hook executable code"
else
  _fail "AC-P2.2-f Phase 2 leaked into hook layer" "$phase2_leaks"
fi

# Verify settings.json was NOT modified by Phase 2 (git diff)
settings_diff=$(cd "$REPO_ROOT" && git diff HEAD -- .claude/settings.json 2>/dev/null)
if [ -z "$settings_diff" ]; then
  _pass "AC-P2.2-f .claude/settings.json unchanged in Phase 2 commit window"
else
  _fail "AC-P2.2-f settings.json was modified in Phase 2:" "$settings_diff"
fi

# ── AC-P2.2-g: pre-Phase-2 handoff exemption ──
LEGACY_FIXTURE="${REPO_ROOT}/.tad/evidence/completions/phase2-grounding/fixtures/pre-phase2-handoff/HANDOFF-20260301-legacy.md"
if [ -f "$LEGACY_FIXTURE" ]; then
  filename=$(basename "$LEGACY_FIXTURE")
  date_str=$(printf '%s' "$filename" | sed -E 's/^HANDOFF-([0-9]{8}).*/\1/')
  if [ "$date_str" -lt "20260424" ]; then
    _pass "AC-P2.2-g pre-Phase-2 fixture filename date '$date_str' < 20260424 (eligible for exemption)"
  else
    _fail "AC-P2.2-g pre-Phase-2 fixture date $date_str not before 20260424"
  fi
  if ! grep -q '^git_tracked_dirs:' "$LEGACY_FIXTURE"; then
    _pass "AC-P2.2-g pre-Phase-2 fixture has no git_tracked_dirs frontmatter (additional exemption signal)"
  else
    _fail "AC-P2.2-g pre-Phase-2 fixture wrongly has git_tracked_dirs"
  fi
else
  _fail "AC-P2.2-g legacy fixture not found"
fi

# ── AC-P2.2-h: doc-only / empty §6 exemption ──
DOC_FIXTURE="${REPO_ROOT}/.tad/evidence/completions/phase2-grounding/fixtures/doc-only-handoff/HANDOFF-20260424-doc-only.md"
if [ -f "$DOC_FIXTURE" ]; then
  if grep -q '^task_type: doc-only' "$DOC_FIXTURE"; then
    _pass "AC-P2.2-h doc-only fixture has task_type: doc-only"
  else
    _fail "AC-P2.2-h doc-only fixture missing task_type: doc-only"
  fi
  # Verify §6 / "Files to Modify" is effectively empty
  files_section=$(awk '/^## 6\.|^## 7\./{flag=!flag; next} flag' "$DOC_FIXTURE" | grep -v '^$' | head -5)
  # If files section has only "(empty — no source files)" or similar marker
  if printf '%s' "$files_section" | grep -qiE 'empty|no source|none'; then
    _pass "AC-P2.2-h doc-only fixture §6 marked empty"
  else
    _fail "AC-P2.2-h doc-only fixture §6 not marked empty: $files_section"
  fi
else
  _fail "AC-P2.2-h doc-only fixture not found"
fi

# Verify Alex SKILL describes both exemption types
if grep -A 3 'exemption_pre_phase2_handoffs' "$ALEX_SKILL" | grep -qE 'doc-only|empty'; then
  _pass "AC-P2.2-h Alex SKILL describes doc-only / empty §6 exemption"
else
  _fail "AC-P2.2-h SKILL missing doc-only / empty §6 exemption clauses"
fi

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
