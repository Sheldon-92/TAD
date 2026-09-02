# Gate 4 — Local Wiki Native Browser Capture

**Date:** 2026-09-02
**Verdict:** PASS
**Accepted product commit:** `7cce3f78`

## Business acceptance

| AC | Requirement | Evidence | Alex verdict |
|---|---|---|---|
| AC1 | No external plugin runtime/product dependency | repository-owned source scan and restored external hashes | PASS |
| AC2 | Rendered page becomes Local Wiki raw article | fake transport/import plus real Chrome CDP smoke | PASS |
| AC3 | Timestamped YouTube transcript path | exact page function VM execution and importer/search integration | PASS |
| AC4 | Unsafe inputs and protocol failures fail closed | Node negative suite | PASS |
| AC5 | No cookie/storage/header/profile data capture | structured fixed CDP call and dual review | PASS |
| AC6 | Owned Chrome profile/process lifecycle | marker, reuse, failure cleanup tests and review | PASS |
| AC7 | One real page and one public YouTube attempt | page PASS; YouTube honestly experimental_degraded as allowed | PASS |
| AC8 | Regression suite remains green | Node 12/12, Python 24/24, lint and generation PASS | PASS |
| AC9 | Prior project is evidence only, not portable runtime | source scan plus external byte restoration | PASS |

## Acceptance judgment

The corrected user outcome is met: TAD itself owns the capture capability. The separate
`下载md插件` project is neither imported nor required at runtime. The supported core is rendered
HTTPS/loopback-page capture into Local Wiki; YouTube remains available behind the same native
extractor but carries an honest first-use experimental limitation when the public site withholds
a usable caption result.

The user previously authorized autonomous verification and acceptance for this corrective YOLO
phase. No further provider matrix or repeated public probe was required.

## Quality and knowledge

- Gate 3: PASS; two independent final reviewers, P0/P1/P2 all zero.
- Knowledge: recorded “internalized capability requires an absence proof” in
  `.tad/project-knowledge/patterns/ac-verification.md`.
- Pair testing: not opened; this is a CLI/internal research workflow with a completed real Chrome
  smoke test and no visual UI change.
- YOLO audit helper: N/A for the `phase3r` corrective suffix because its parser assumes numeric
  phase filenames; direct Gate 3 carriers were used instead.
