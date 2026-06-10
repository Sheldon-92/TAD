# Backend Architect Review: Friction Protocol Phase 2

**Reviewer**: backend-architect
**Date**: 2026-06-10
**Scope**: Advisory checker `.tad/hooks/lib/friction-status-check.sh`, fixtures, Gate SKILL integration
**Focus**: Advisory boundary, integration placement, Phase 1 consistency, scope boundary, existing script patterns

---

## Summary

Phase 2 delivers a well-scoped advisory checker that aligns with the TAD principle "Mechanical Enforcement Rejected on Single-User CLI." The script is correctly structured as a smoke alarm, properly exits 0/1, and has no hook registrations. Two correctness bugs were found (P1 severity) and one observation (P2). No P0 issues.

---

## Finding 1 (P1): `head -20` frontmatter window misses `gate3_verdict` on line 21+

**Location**: `.tad/hooks/lib/friction-status-check.sh`, line 69

**Problem**: The frontmatter detection uses `head -20 "$file" | grep -q '^gate3_verdict:'` which only scans the first 20 lines. If the YAML frontmatter has more than ~18 key-value pairs (the `---` delimiters consume 2 lines), `gate3_verdict: pass` falls outside the window. When this happens, `gate3_pass` stays false and all Gate-3-PASS-conditional checks silently pass -- the exact "blocked-as-pass" scenario the tool exists to catch.

**Reproduction**:
```bash
# Create a file with gate3_verdict on line 21
printf '%s\n' "---" "title: big" "l3: x" "l4: x" "l5: x" "l6: x" "l7: x" \
  "l8: x" "l9: x" "l10: x" "l11: x" "l12: x" "l13: x" "l14: x" "l15: x" \
  "l16: x" "l17: x" "l18: x" "l19: x" "l20: x" "gate3_verdict: pass" "---" \
  "# Report" "## Friction Status" "| P | Status |" "|---|---|" \
  "| Dep | BLOCKED |" > /tmp/deep_fm.md
bash .tad/hooks/lib/friction-status-check.sh /tmp/deep_fm.md
# Actual: "Friction Status has unresolved BLOCKED row" (no "Gate 3 PASS" prefix)
# Expected: "Gate 3 PASS but Friction Status has unresolved BLOCKED row"
```

The warning for BLOCKED still fires (because Check 2 runs unconditionally when a BLOCKED row is found), but Check 1 (missing Friction Status under PASS) and Check 3 (pending text mismatch) would produce false negatives.

**Fix**: Replace `head -20` with an awk/sed extraction of the YAML frontmatter block (from first `---` to second `---`), then grep within that block. Example:
```bash
if awk '/^---$/{n++; if(n==2) exit} n==1{print}' "$file" | grep -q '^gate3_verdict:[[:space:]]*pass'; then
  gate3_pass=true
fi
```

This is bounded by the frontmatter block size (typically <50 lines in TAD) rather than an arbitrary line count.

**Severity**: P1 -- the current TAD completion template has ~10 frontmatter keys, so `head -20` works today. But the frontmatter grows when new fields are added, and the failure is silent (false negative on exactly the scenario the tool is designed to catch).

---

## Finding 2 (P1): Header-row skip filter produces false negatives for data rows containing "Status" or "Friction Point"

**Location**: `.tad/hooks/lib/friction-status-check.sh`, lines 108-111

**Problem**: The header/separator skip logic uses broad substring matches:
```bash
case "$line" in
  *'---'*) continue ;;
  *'Friction Point'*) continue ;;
  *'Status'*) continue ;;
esac
```

The `*'Status'*` pattern matches ANY table row containing the word "Status" anywhere -- including a data row whose Friction Point name contains "Status" (e.g., "Status page deploy", "Auth Status check"). This causes the row to be skipped entirely, creating a false negative where a BLOCKED row is silently ignored.

**Reproduction**:
```bash
printf '---\ngate3_verdict: pass\n---\n# Report\n## Friction Status\n| Friction Point | Status | Action |\n|---|---|---|\n| Status page deploy | BLOCKED | stuck |\n' > /tmp/status_name.md
bash .tad/hooks/lib/friction-status-check.sh /tmp/status_name.md
# Actual: RESULT: clean (exit 0)
# Expected: WARN with BLOCKED row
```

**Fix**: Instead of substring-matching individual words, match the FIRST table row more precisely. The header row always has "Status" as its own cell content. A safer approach is to skip only the first non-separator table row encountered in the section:
```bash
header_skipped=false
# ... inside the table row case:
if [ "$header_skipped" = false ]; then
  header_skipped=true
  continue
fi
```

Or match the exact header pattern more narrowly by checking that the Status cell contains exactly the word "Status" and nothing else (i.e., it IS the header label, not data containing "Status" as a substring).

**Severity**: P1 -- unlikely in current TAD practice (friction points are not typically named "Status"), but the fix is trivial and the failure mode is exactly the false-negative this tool must prevent.

---

## Finding 3 (P2): No `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` evidence checks

**Location**: `.tad/hooks/lib/friction-status-check.sh`, lines 88-126

**Observation**: The Gate SKILL Phase 1 protocol (lines 136-140 of gate/SKILL.md) requires that `DEGRADED_WITH_APPROVAL` rows have approval source/date/risk in the evidence cell, and `EQUIVALENT_SUBSTITUTE` rows have replacement description/equivalence reasoning. The advisory checker does not inspect these statuses at all -- they pass silently.

**Assessment**: The handoff (section 8.3, edge cases) explicitly notes this is not required for Phase 2 AC. This is correctly scoped as a carry-forward, not a gap. Documenting it here for completeness so a future Phase 3 can add evidence-cell validation for these statuses.

**Severity**: P2 (acknowledged scope limitation, not a bug).

---

## Review Dimension: Advisory Boundary

**Verdict**: PASS

Evidence:
1. **No hook registration**: `grep -r 'friction-status-check' .claude/ .agents/ --include='*.json' --include='*.yaml'` returns nothing.
2. **No settings.json modification**: `git diff -- .claude/settings.json` is empty.
3. **Exit semantics**: Script exits 0 (clean) or 1 (warnings). No exit 2, no `set -e`, no uncaught failures.
4. **Safety header**: Lines 17-24 explicitly document the smoke-alarm constraint with 4 MUST NOT rules.
5. **Crash resistance**: Tested with nonexistent file (warns, does not crash), empty file (clean exit), `/dev/null` (clean exit).

---

## Review Dimension: Integration Placement

**Verdict**: PASS

Evidence:
1. Gate SKILL changes are additive -- a new `optional_advisory_checker` key under existing `Friction_Status_Check` (Gate 3) and `Gate4_Friction_Review` (Gate 4) blocks. Neither block's `blocking_rule` or `process` steps were modified.
2. The advisory text explicitly says "must not be registered as a hook or added to settings."
3. Both `.agents/skills/gate/SKILL.md` and `.claude/skills/gate/SKILL.md` mirrors are in sync (identical diff).

---

## Review Dimension: Phase 1 Consistency

**Verdict**: PASS with P1 caveats above

The checker detects exactly the three problem classes Phase 1 was designed to prevent:
1. BLOCKED row under Gate 3 PASS (Check 2, line 88-126) -- works correctly modulo the P1 header-skip bug.
2. Missing Friction Status section under Gate 3 PASS (Check 1, line 78-86) -- works correctly modulo the P1 `head -20` bug.
3. Verdict/prose/checklist mismatch (Check 3, line 128-139) -- works correctly.

The enum values are consistent with Phase 1 definitions in the Gate SKILL.

---

## Review Dimension: Scope Boundary

**Verdict**: PASS

The changeset is exactly:
- 1 new script: `.tad/hooks/lib/friction-status-check.sh`
- 4 fixture files + 1 fixture harness
- 2 mirror Gate SKILL additions (advisory text only)
- Trace entries + NEXT.md bookkeeping

No new protocol semantics, no enum changes, no hook registrations, no settings modifications.

---

## Review Dimension: Existing Script Patterns

**Verdict**: PASS

Comparison with `verify-ac-commands.sh` and `pack-registry-driftcheck.sh`:

| Pattern | `verify-ac-commands.sh` | `friction-status-check.sh` | Match? |
|---------|------------------------|---------------------------|--------|
| Shebang | `#!/usr/bin/env bash` | `#!/usr/bin/env bash` | Yes |
| Safety header comment block | Present (lines 12-22) | Present (lines 17-24) | Yes |
| SMOKE ALARM declaration | Yes | Yes | Yes |
| MUST NOT hook registration | Yes (4 items) | Yes (4 items) | Yes |
| BSD/macOS safety note | Yes | Yes | Yes |
| Exit semantics | Always 0 (advisory) | 0 or 1 (advisory) | Acceptable divergence -- `verify-ac-commands.sh` always exits 0 because it is a linter; this checker uses 1 for "warnings detected" which matches `pack-registry-driftcheck.sh` |
| No `set -e` | Correct (not present) | Correct (not present) | Yes |
| Temp file cleanup | `trap cleanup EXIT` | `trap '...' EXIT` | Yes (inline vs function, both valid) |
| Repo root resolution | From script dir | From script dir | Yes |
| `mktemp` with fallback | Yes | Yes | Yes |

---

## Fixture Quality

All 4 fixtures are minimal, focused, and exercise distinct failure modes:
- `pass.md`: clean report with READY + NOT_APPLICABLE_WITH_REASON statuses
- `blocked-as-pass.md`: PASS markers with BLOCKED row
- `missing-friction-status.md`: PASS markers, no Friction Status heading
- `pending-text-mismatch.md`: frontmatter pass with pending prose and unchecked checklist

`run-all.sh` verifies both exit code and output text for each fixture, which is a stronger assertion than exit-code-only.

Missing fixture (not required by AC but recommended): a fixture with a friction point name containing the word "Status" to guard against regression of Finding 2 after fix.

---

## Summary Table

| # | Severity | Finding | Blocking? |
|---|----------|---------|-----------|
| 1 | P1 | `head -20` misses frontmatter `gate3_verdict` beyond line 20 | No (works for current template; fix before next release) |
| 2 | P1 | Header-skip `*'Status'*` glob causes false negatives for data rows containing "Status" | No (unlikely in current practice; fix before next release) |
| 3 | P2 | No evidence-cell checks for DEGRADED_WITH_APPROVAL / EQUIVALENT_SUBSTITUTE | No (acknowledged scope limitation) |

**Overall Assessment**: The advisory checker is architecturally sound and correctly respects the smoke-alarm boundary. The two P1 findings are correctness bugs in edge cases that do not affect current TAD completion report shapes but should be fixed before the script is relied upon in production workflows. Recommend fixing both P1s before Gate 3 acceptance or documenting them as carry-forwards with explicit regression fixtures.
