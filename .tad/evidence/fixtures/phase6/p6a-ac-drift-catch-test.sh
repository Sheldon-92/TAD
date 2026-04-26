#!/bin/bash
# p6a-ac-drift-catch-test.sh — 3 regression cases reproducing Phase 5 / 4 / CR-P0-1 AC drift bugs
# (FR5, Phase 6-A.1, 2026-04-25)
#
# Each case asserts the bug IS reproduced (output ≠ Expected). PASS marker per case
# means "step1d Sub-rule 1/2/3 would have caught this at handoff drafting".
#
# Usage: bash .tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh
# Exit:  0 on all 3 PASS; non-zero count on failures
#
# Design philosophy (CR-P1-4 fix): regression test, NOT catch simulation.
# We reproduce the actual buggy command on a known fixture, assert the buggy
# output ≠ what the AC said it should produce. Step1d would have run the same
# command + caught the same mismatch BEFORE the handoff shipped.

set -u

PASS=0
FAIL=0
FAIL_DETAILS=""

emit_pass() {
  PASS=$((PASS + 1))
  printf "  PASS: %s\n" "$1"
}
emit_fail() {
  FAIL=$((FAIL + 1))
  FAIL_DETAILS="${FAIL_DETAILS}  FAIL: $1\n    detail: $2\n"
  printf "  FAIL: %s\n    detail: %s\n" "$1" "$2"
}

echo "═══ p6a-ac-drift-catch-test — 3 regression cases ═══"

# ── Case 1: Phase 5 AC-G2 grep -n single-file 2-field output ─────────────
# Bug reproduction: AC's regex `^[^:]+:[0-9]+:[[:space:]]*exit 0[[:space:]]*$`
# expects 3-field FILE:LINE:CONTENT, but `grep -n` on single file gives
# 2-field LINE:CONTENT. Result: regex matches NOTHING; all "exit 0" lines
# wrongly counted as "non-exit-0". Correct AC needs `grep -nH` for 3-field
# OR simpler 2-field regex.
echo ""
echo "─── Case 1: Phase 5 AC-G2 grep -n 2-field reproduction ───"
TMP1=$(mktemp /tmp/p6a-case1.XXXXXX.sh)
cat > "$TMP1" <<'EOT'
#!/bin/bash
echo "test"
  exit 0
exit 0
EOT
# Buggy command from Phase 5 §9.2 row 14:
#   grep -nE '^[[:space:]]*exit [0-9]+' file | grep -vE '^[^:]+:[0-9]+:...'
# On single file, grep -n outputs LINE:CONTENT (2-field), regex expects 3-field.
buggy_count=$(grep -nE '^[[:space:]]*exit [0-9]+' "$TMP1" | grep -vE '^[^:]+:[0-9]+:[[:space:]]*exit 0[[:space:]]*$' | wc -l | tr -d ' ')
# AC said: 0 (only exit 0 lines should pass through)
# Buggy actual: 2 (both exit 0 lines wrongly counted as non-exit-0)
if [ "$buggy_count" != "0" ]; then
  emit_pass "Case 1 (Phase 5 AC-G2 reproduction): buggy command outputs $buggy_count instead of 0 — drift caught"
else
  emit_fail "Case 1" "buggy command produced expected 0; reproduction failed"
fi
rm -f "$TMP1"

# ── Case 2: Phase 4 Anti-Epic-1 grep scope without --exclude-dir ─────────
# Bug reproduction: Phase 4 AC-G1 expected `grep -rE 'PreToolUse|...'` against
# .tad/project-knowledge/*.md to return 0 hits. But architecture.md has dozens
# of legitimate historical doc entries about hooks/PreToolUse → returned 36 hits.
# A narrowed grep against just the Phase 4 modified files would have shown 0.
echo ""
echo "─── Case 2: Phase 4 Anti-Epic-1 wide grep over historical doc ───"
TMP2_DIR=$(mktemp -d)
mkdir -p "$TMP2_DIR/historical"
mkdir -p "$TMP2_DIR/phase4-modified"
cat > "$TMP2_DIR/historical/architecture.md" <<'EOT'
### Hooks Are Production-Ready - 2026-03-31
- PostToolUse / PreToolUse command hooks work as documented
- Settings.json accepts the event without error
EOT
cat > "$TMP2_DIR/phase4-modified/code-security.yaml" <<'EOT'
quality_criteria:
  - "DAST scans must not disrupt prod"
  - "SAST-DAST cross-reference completed"
EOT

# Wide grep (the Phase 4 buggy AC scope):
wide_hits=$(grep -rE 'PreToolUse|UserPromptSubmit|hookSpecificOutput' "$TMP2_DIR" 2>/dev/null | wc -l | tr -d ' ')
# Narrowed grep (what the AC actually intended):
narrow_hits=$(grep -rE 'PreToolUse|UserPromptSubmit|hookSpecificOutput' "$TMP2_DIR/phase4-modified" 2>/dev/null | wc -l | tr -d ' ')

if [ "$wide_hits" != "0" ] && [ "$narrow_hits" = "0" ]; then
  emit_pass "Case 2 (Phase 4 Anti-Epic-1 reproduction): wide grep=$wide_hits hits, narrow grep=$narrow_hits — drift caught (wide AC was wrong)"
else
  emit_fail "Case 2" "wide=$wide_hits narrow=$narrow_hits; reproduction failed"
fi
rm -rf "$TMP2_DIR"

# ── Case 3: CR-P0-1 markdown-table pipe-escape ───────────────────────────
# Bug reproduction: rendered markdown table cell `grep -cE 'a\|b'` un-escapes
# at runtime depending on shell — the literal `\|` in BRE means "pipe character"
# in some greps but in POSIX -E it means "literal |" only when escaped, AND
# in the markdown rendering the `\|` IS the cell-escape so it should be `|`
# when run. Step1d Sub-rule 1: dry-run from RAW form, not rendered.
echo ""
echo "─── Case 3: CR-P0-1 markdown pipe-escape reproduction ───"
# In bash, `'a\|b'` keeps backslash literal. grep -cE on `a\|b` expects literal
# string "a|b" in alternation form. But on `a|b` (raw), it's regex alternation
# matching either 'a' or 'b' on a line.
escaped_count=$(printf 'a\nb\n' | grep -cE 'a\|b')      # rendered form
raw_count=$(printf 'a\nb\n' | grep -cE 'a|b')           # raw form

# Expected: rendered form returns 0 (looking for literal "a|b" not present);
# raw form returns 2 (matches "a" and "b" lines).
if [ "$escaped_count" = "0" ] && [ "$raw_count" = "2" ]; then
  emit_pass "Case 3 (CR-P0-1 pipe-escape reproduction): rendered=$escaped_count raw=$raw_count — drift caught"
else
  emit_fail "Case 3" "rendered=$escaped_count raw=$raw_count; reproduction unclear"
fi

# ── Summary ──────────────────────────────────────────────────────────────
echo ""
echo "═══ Result: $PASS PASS, $FAIL FAIL ═══"
if [ "$FAIL" -gt 0 ]; then
  printf "%b" "$FAIL_DETAILS"
  exit 1
fi
exit 0
