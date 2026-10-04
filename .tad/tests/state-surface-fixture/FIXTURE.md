# state-surface-fixture — negative control for state-surface-check.sh

This tree is a deliberately stale mini-repo. Running

    bash .tad/hooks/lib/state-surface-check.sh --repo .tad/tests/state-surface-fixture

MUST exit 1, with FAIL items pointing at the version declarations:

- check1: NEXT.md header says 2.44.5, fixture .tad/version.txt says 3.0.0
- check3: four planted wrong-value declarations, one per pattern branch,
  each FAIL check3 line carrying its token for attribution
  (design delta 2026-10-04, Gate 3 C1):
  - AGENTS.md:3 `(v9.9)` (existing) — branch check3-P2 (header anchor +
    `Runtime status` keyword anchor) → FAIL, attribution contains `(v9.9)`
  - AGENTS.md:4 `**Version**: 9.9` (existing) — branch check3-DECL
    (bold-colon declaration form) → FAIL, attribution contains
    `Version**: 9.9`
  - docs/MULTI-PLATFORM.md:3 `(Version 9.7)` — branch check3-P1
    (self-anchored parenthesized declaration) → FAIL, attribution
    contains `(Version 9.7)`
  - INSTALLATION_GUIDE.md:3 `(v8.8)` — branch check3-P2 (header anchor
    only; the line carries no `Runtime status` and no `Version` word) →
    FAIL, attribution contains `(v8.8)`
  - positive controls (correct value == fixture version.txt 3.0.0; must
    NOT be flagged): README.md:3 `(v3.0.0)` (branch check3-P2) and
    PROJECT_CONTEXT.md:3 `**Version**: 3.0.0` (branch check3-DECL)
- check2 / check4 / check5 pass in this tree (correct ROADMAP header,
  no "3.1" forms, index-block path exists), proving the failures are
  scoped to the planted version defects, not the whole tree.

Running the same script against the real repo root MUST exit 0.
