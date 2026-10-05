# Layer 2 Group 0 — Spec Compliance Review (OCR review habits)

**Handoff:** `.tad/active/handoffs/HANDOFF-20260914-ocr-review-habits.md` (§6/§9/§10 scope only)
**Date:** 2026-09-14
**Reviewer:** independent sub-agent (Group 0, did not implement)
**Commit under review:** `c48e5620` — `docs(ocr): paste optional K1-K5 Layer 2 review habits into tax-cut SSOT + pattern + spec format (TASK-20260914-OCR-REVIEW-HABITS)`

## Method

Each §9.1 Verification Method executed verbatim against the working tree at HEAD. Pre-existing dirty files outside §6.2 (§10 FALSE_POSITIVE class) do not affect the §9.1 checks, which read only the three target files and the HEAD commit.

## Per-AC results

| AC# | Expected | Actual | Result |
|-----|----------|--------|--------|
| 1 | exit 0 | `test -f docs/process-tax-cut.md` exit 0 | SATISFIED |
| 2 | exit 0 | `test -f .tad/project-knowledge/patterns/process-tax-cut.md` exit 0 | SATISFIED |
| 3 | exit 0 | `test -f .tad/templates/output-formats/spec-compliance-format.md` exit 0 | SATISFIED |
| 4 | exit 0, teeth HIT (guide) | `Alex ≠ Blake stays` HIT, exit 0 | SATISFIED |
| 5 | exit 0, teeth HIT (pattern) | `Alex ≠ Blake stays` HIT, exit 0 | SATISFIED |
| 6 | grep exit 1, EXIT:1 | `grep -F docs/process-tax-cut tad.sh` no hits, exit 1; EXIT:1 | SATISFIED |
| 7 | exit 0 | `## 4) Optional Layer 2 review habits (OCR thin borrow)` HIT, exit 0 | SATISFIED |
| 8 | exit 0, printed 7 | printed 7, exit 0 | SATISFIED |
| 9 | exit 0, printed 7 | printed 7, exit 0 | SATISFIED |
| 10 | exit 0, printed 8 | printed 8 (incl. `if drift, docs win`), exit 0 | SATISFIED |
| 11 | exit 0, SUBJ contains OCR-REVIEW-HABITS, required ⊆ names ⊆ §6.2 | SUBJ contains OCR-REVIEW-HABITS; names = exactly the 4 §6.2 paths | SATISFIED |
| 12 | exit 0, ok_id true, HITS=[] | ok_id true, HITS=[] | SATISFIED |
| 13 | exit 0, fence len >0, a==b==c | printed 1281, a==b==c true, `falsify-only` in body | SATISFIED |

Total: 13 SATISFIED, 0 NOT_SATISFIED, 0 PARTIALLY_SATISFIED.

## Note (non-blocking)

Pattern §4 heading carries a suffix (`— paste into Layer 2 reviewer prompt`) while the guide matches the AC7 string exactly. AC8/AC9 use prefix `find()`, so both still print 7 and exit 0. No AC fails on this.

## P0 / P1 / P2

- P0: none.
- P1: none.
- P2: heading-suffix note above (advisory only).

verdict: PASS
