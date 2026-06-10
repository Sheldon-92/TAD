# Code Review: Friction Protocol Phase 2 — Advisory Checker

**Reviewer**: code-reviewer (shell portability + parsing correctness specialist)
**Date**: 2026-06-10
**Scope**: `.tad/hooks/lib/friction-status-check.sh`, 4 fixtures, `run-all.sh`, Gate SKILL advisory text
**Verdict**: P0: 1, P1: 3, P2: 2

---

## Summary

The implementation is a well-structured advisory smoke alarm that correctly respects its design constraints: no hook registration, no settings modification, advisory-only exit codes, and BSD/macOS-safe shell. The fixtures pass and the script handles spaces-in-paths, empty files, and malformed markdown gracefully. However, the header-row skip logic has a false-negative bug that can hide BLOCKED rows from detection in real reports.

---

## P0 — Critical Issues (Must Fix)

### P0-1: Header-row skip filter causes false negatives on data rows containing "Status" or "Friction Point"

**File**: `.tad/hooks/lib/friction-status-check.sh`, lines 108-112
**Severity**: P0 — false negative on real reports (the class of bug this script exists to catch)

The header/separator row filter uses substring globbing:

```bash
case "$line" in
  *'---'*) continue ;;
  *'Friction Point'*) continue ;;
  *'Status'*) continue ;;
esac
```

This skips ANY table row where the word "Status" or "Friction Point" appears in ANY cell — including data rows. Concrete failure: a friction point named "Check Status endpoint" or "API Status monitor" with Status = BLOCKED is silently skipped. Verified by test:

```
| Check Status endpoint | BLOCKED | Could not reach |
```

This row is skipped entirely because `*'Status'*` matches, producing a false negative — exactly the class of failure this tool was built to prevent.

**Fix**: Replace the substring glob with a positional check that only matches when the second cell (Status column) literally equals "Status" — which is the header cell value:

```bash
# Replace lines 108-112 with:
case "$line" in
  *'---'*) continue ;;
esac
# Skip header row by checking if Status column IS the header label
header_check=$(printf '%s' "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3}')
case "$header_check" in
  "Status"|"Friction Point") continue ;;
esac
```

Or more simply, skip only the first non-separator table row (the header):

```bash
# After entering the table, skip the first non-separator pipe row
first_data_row=true
# ... inside the |*) case:
case "$line" in
  *'---'*) continue ;;
esac
if [ "$first_data_row" = true ]; then
  first_data_row=false
  continue  # skip header row
fi
```

---

## P1 — Important Issues (Should Fix)

### P1-1: Section detection uses whole-file grep instead of heading-scoped check

**File**: `.tad/hooks/lib/friction-status-check.sh`, line 80
**Severity**: P1 — false positive suppression and mislocated section parsing

```bash
if grep -q 'Friction Status' "$file" 2>/dev/null; then
  has_friction_section=true
fi
```

This triggers on "Friction Status" appearing anywhere in the file — including prose like "The Friction Status was reviewed." When that happens:
1. Check 1 (missing section) is suppressed even though no actual Friction Status heading exists.
2. Check 2 (BLOCKED row) enters the section parser, which then also triggers on the prose mention and can scan an unrelated table in a different section.

Verified: a file with "Friction Status" in a non-heading paragraph and a BLOCKED table in a different section produces a false positive BLOCKED warning.

**Fix**: Scope the check to markdown headings:

```bash
if grep -q '^#.*Friction Status' "$file" 2>/dev/null; then
  has_friction_section=true
fi
```

And similarly, the section parser's entry condition on line 94 should match headings only:

```bash
case "$line" in
  '#'*Friction\ Status*|'#'*"Friction Status"*)
    in_section=true
    continue
    ;;
esac
```

### P1-2: Section parser `*"Friction Status"*` glob matches non-heading lines

**File**: `.tad/hooks/lib/friction-status-check.sh`, line 94
**Severity**: P1 — same root cause as P1-1 but in the line-by-line parser

The `case "$line" in *"Friction Status"*)` pattern matches any line containing that substring, not just headings. If a report has "See Friction Status above" in prose followed by a table, the parser enters section mode at the wrong point.

**Fix**: Require the line to start with `#`:

```bash
case "$line" in
  '#'*"Friction Status"*)
    in_section=true
    continue
    ;;
esac
```

### P1-3: `grep -q 'pending\|to be filled'` uses BRE alternation which some POSIX shells may handle differently

**File**: `.tad/hooks/lib/friction-status-check.sh`, line 131
**Severity**: P1 — shell portability risk

```bash
if grep -q 'Gate 3 v2.*pending\|Gate 3 v2.*to be filled' "$file" 2>/dev/null; then
```

While macOS `grep` supports BRE `\|` alternation, this is technically a GNU extension to BRE. POSIX BRE does not guarantee `\|`. For strict portability per the script's own safety header ("BSD/macOS-safe shell only"), use `grep -E` (ERE) which standardizes `|`:

```bash
if grep -Eq 'Gate 3 v2.*pending|Gate 3 v2.*to be filled' "$file" 2>/dev/null; then
```

Same applies to line 136 `'\- \[ \].*Gate 3 v2'` — this one is fine as-is (no alternation), just noting for consistency.

---

## P2 — Suggestions (Consider)

### P2-1: Fixture harness does not test the empty-file or nonexistent-file edge cases

**File**: `.tad/evidence/fixtures/friction-status-check/run-all.sh`
**Severity**: P2 — coverage gap, not a correctness issue

The harness covers the 4 primary cases well. Consider adding:

```bash
check "nonexistent file" \
  "/nonexistent/path/report.md" \
  1 \
  "WARN"

check "empty file" \
  "/dev/null" \
  0 \
  "RESULT: clean"
```

These edge cases were manually verified during this review and work correctly, but codifying them prevents regression.

### P2-2: Multiple BLOCKED rows produce identical warning messages with no row identification

**File**: `.tad/hooks/lib/friction-status-check.sh`, lines 116-119
**Severity**: P2 — minor UX improvement

When a report has multiple BLOCKED rows, the warnings are identical:
```
WARN [file]: Gate 3 PASS but Friction Status has unresolved BLOCKED row
WARN [file]: Gate 3 PASS but Friction Status has unresolved BLOCKED row
```

Consider including the friction point name (first cell) in the message:

```bash
friction_point=$(printf '%s' "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
warn "$file" "Gate 3 PASS but Friction Status has unresolved BLOCKED row: $friction_point"
```

---

## Positive Observations

1. **Advisory boundary is clean**: No hook registration, no settings modification, no `set -e`, no fail-closed behavior. The script strictly respects the "smoke alarm not fire suppressor" design.

2. **Space-in-path handling is correct**: The `FILE_LIST` temp file approach with `IFS= read -r` correctly handles paths with spaces, unlike a naive `for file in $(find ...)` pattern.

3. **Fixtures are minimal and focused**: Each fixture tests exactly one failure mode with a minimal report structure. The harness verifies both exit code and output text.

4. **SKILL.md changes are appropriate**: The advisory text is placed near the relevant protocol blocks without modifying any blocking semantics. Both `.agents` and `.claude` mirrors are kept in sync.

5. **BLOCKED_RESOLVED does not false-positive**: The exact string match `[ "$status_cell" = "BLOCKED" ]` correctly distinguishes BLOCKED from BLOCKED_RESOLVED or similar compound statuses.

6. **Graceful degradation**: Empty files, nonexistent files, and malformed markdown all produce appropriate behavior without crashes or stack traces.

---

## Required Actions Before Gate 3

| # | Severity | Finding | Action |
|---|----------|---------|--------|
| P0-1 | P0 | Header-row filter causes false negatives | Fix the `*'Status'*`/`*'Friction Point'*` glob to scope to header-cell position only |
| P1-1 | P1 | Section detection matches prose, not just headings | Add `^#` anchor to the grep pattern |
| P1-2 | P1 | Section parser enters on non-heading lines | Add `'#'*` prefix to the case pattern |
| P1-3 | P1 | BRE `\|` not guaranteed POSIX-portable | Switch to `grep -E` for alternation patterns |
| P2-1 | P2 | Missing edge-case fixtures | Optional: add nonexistent/empty fixtures |
| P2-2 | P2 | Duplicate BLOCKED warnings lack row context | Optional: include friction point name |

**Blocking for Gate 3**: P0-1 must be fixed. P1-1 and P1-2 should be fixed (they share a root cause). P1-3 should be fixed as a one-character change.
