# state-surface-fixture — negative control for state-surface-check.sh

This tree is a deliberately stale mini-repo. Running

    bash .tad/hooks/lib/state-surface-check.sh --repo .tad/tests/state-surface-fixture

MUST exit 1, with FAIL items pointing at the version declarations:

- check1: NEXT.md header says 2.44.5, fixture .tad/version.txt says 3.0.0
- check3: AGENTS.md carries `(v9.9)` and the bold-colon negative-control
  line `**Version**: 9.9` — the widened declaration pattern must hit the
  bold-colon form, or that form becomes a permanent blind spot
  (design §2.2 mechanism 2, Gate 2 revision R1).
- check2 / check4 / check5 pass in this tree (correct ROADMAP header,
  no "3.1" forms, index-block path exists), proving the failures are
  scoped to the planted version defects, not the whole tree.

Running the same script against the real repo root MUST exit 0.
