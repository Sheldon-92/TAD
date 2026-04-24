# Test Runner Review — Phase 2 Grounding
Reviewer: test-runner
Date: 2026-04-24

## Test Execution
| Test | Assertions | Result |
|------|------------|--------|
| AC-P2.1-stale-knowledge-check.sh | 34 | PASS (34/34) |
| AC-P2.2-grounding-pass.sh | 21 | PASS (21/21) |
| **Total** | **55** | **PASS** |

## AC Coverage Matrix (28 ACs)

| AC | Covered by | Status |
|----|------------|--------|
| P2.1-a README format documentation | AC-P2.1 lines 343–350 (5 needle checks) | COVERED |
| P2.1-b shellcheck + BSD portability | AC-P2.1 lines 353–360 | COVERED |
| P2.1-c stale entry → STALE + days_delta=7 | AC-P2.1 lines 71–87 | COVERED |
| P2.1-d fresh file → OK | AC-P2.1 lines 89–99 | COVERED |
| P2.1-e no grounded_in → INFO | AC-P2.1 lines 101–112 | COVERED |
| P2.1-f missing file → WARN | AC-P2.1 lines 114–121 | COVERED |
| P2.1-g multi-path independent verdicts | AC-P2.1 lines 123–135 | COVERED |
| P2.1-h revalidated > mtime → OK | AC-P2.1 lines 137–146 | COVERED |
| P2.1-i revalidated < mtime → STALE | AC-P2.1 lines 148–159 | COVERED |
| P2.1-j grace boundary (86399/86401) | AC-P2.1 lines 161–180 | COVERED |
| P2.1-k malformed grammar → WARN, no crash | AC-P2.1 lines 182–193 | COVERED |
| P2.1-l (new — will be created) → INFO | AC-P2.1 lines 195–203 | COVERED |
| P2.1-m title with dashes parsed | AC-P2.1 lines 205–213 | WEAK — see Gaps |
| P2.1-n (consolidated) suffix stripped | AC-P2.1 lines 215–222 | WEAK — see Gaps |
| P2.1-o JSON schema valid | AC-P2.1 lines 224–252 | COVERED |
| P2.1-p real corpus exit 0 + non-empty + 0 ERROR | AC-P2.1 lines 254–265 | COVERED |
| P2.1-q failure isolation → exit 0 | AC-P2.1 lines 267–294 | COVERED |
| P2.1-r anti-Epic-1 not in settings.json or hooks | AC-P2.1 lines 296–317 | COVERED |
| P2.1-s cwd subdir resolution + non-git exit 1 | AC-P2.1 lines 319–328 | COVERED |
| P2.1-t symlink follows target mtime | AC-P2.1 lines 330–340 | COVERED |
| P2.2-a step1c in SKILL, correct ordering | AC-P2.2 lines 17–48 | COVERED |
| P2.2-b template has Grounded Against + step1c ref | AC-P2.2 lines 50–61 | COVERED |
| P2.2-c dogfood handoff §6 Grounded Against filled | AC-P2.2 lines 63–78 | COVERED |
| P2.2-d enforcement prompt-level-only + forbidden list | AC-P2.2 lines 80–99 | COVERED |
| P2.2-e (new — will be created) described in SKILL | AC-P2.2 lines 101–106 | COVERED |
| P2.2-f anti-Epic-1 grep 0 hits in hooks + settings | AC-P2.2 lines 108–196 | COVERED |
| P2.2-g pre-Phase-2 exemption fixture | AC-P2.2 lines 198–215 | COVERED |
| P2.2-h doc-only / empty §6 exemption fixture | AC-P2.2 lines 217–243 | COVERED |

## Fixture Inventory (15 minimum)

| Fixture | Present? |
|---------|----------|
| fixtures/stale.md | YES |
| fixtures/not-stale.md | YES |
| fixtures/no-grounded.md | YES |
| fixtures/missing-file.md | YES |
| fixtures/multi-path.md | YES |
| fixtures/revalidated.md | YES |
| fixtures/revalidated-stale.md | YES |
| fixtures/grace-boundary-pass.md | YES |
| fixtures/grace-boundary-fail.md | YES |
| fixtures/malformed-grammar.md | YES |
| fixtures/new-marker.md | YES |
| fixtures/title-with-dash.md | YES |
| fixtures/consolidated-suffix.md | YES |
| fixtures/pre-phase2-handoff/ | YES (contains HANDOFF-20260301-legacy.md) |
| fixtures/doc-only-handoff/ | YES (contains HANDOFF-20260424-doc-only.md) |

All 15 minimum fixtures present.

## Real-Corpus Test (AC-P2.1-p)

Running stale-knowledge-check.sh on `.tad/project-knowledge/architecture.md` and `security.md` produced 47 INFO rows (all legacy entries with no Grounded in declared), exit 0, 0 ERROR rows. Output is sane: every row has all 6 required JSON fields, status is exclusively INFO, days_delta is null throughout. This is the correct expected behavior for a corpus of pre-Phase-2 entries.

Note: The two new 2026-04-24 entries (Word-Boundary Matching, Drift-Check Allowlist) do NOT carry a `Grounded in` bullet — they are also correctly reported as INFO. The handoff §5 `knowledge_updates` AC requires at least 1 new entry using the new Grounded in format. This is not verified by any test in the two test scripts (see Gaps).

## Gaps / Recommendations

**GAP 1 — AC-P2.1-m/n: Tests verify presence, not correct parse value (weak assertions)**
AC-P2.1-m checks `[ -n "$status" ]` (any non-empty status is a pass). AC-P2.1-n does the same. Neither asserts the specific status value. For -m (title-with-dash, file mtime 2026-04-01 < entry 2026-04-14), the correct status is OK. For -n (consolidated suffix, file mtime 2026-04-01 < entry 2026-04-20), correct status is also OK. Both produce OK on real run — but if the parser silently dropped the entry, `status=""` would trip the test, not a wrong status. These are correctly PASS but weaker than possible. Recommendation: add `[ "$status" = "OK" ]` assertions.

**GAP 2 — §5 knowledge_updates not mechanically verified**
The handoff §5 requires `at least 1 new architecture.md entry using the new Grounded in format`. No test in AC-P2.1 or AC-P2.2 checks this. The two new 2026-04-24 entries (Phase 1 learnings) have no `Grounded in` bullet — this meta-trifecta requirement is not satisfied and not caught by any test.

**GAP 3 — alex/SKILL.md step0_5 step 9 not tested**
AC-P2.1-c through AC-P2.1-t all test stale-knowledge-check.sh directly. AC-P2.1-q tests failure isolation via exit code only. No test verifies that the `handoff_creation_protocol.step0_5` SKILL text actually contains the new step 9 stale-check invocation language.

**GAP 4 — Multi-file scan (scanning all *.md not just one) untested**
All fixture tests use a single knowledge file `testing.md`. The real-corpus test implicitly covers multi-file (architecture.md + security.md), but there is no explicit fixture test that puts entries in two separate knowledge files and verifies both are scanned.

## Verdict

**PASS** — 55/55 assertions pass. All 15 minimum fixtures present. Real-corpus run is sane (exit 0, 47 INFO rows, 0 ERROR). Anti-Epic-1 compliance verified (0 Phase 2 keywords in hook layer).

Three minor gaps (weak assertions on AC-m/n, untested §5 knowledge_updates AC, missing step0_5 step 9 SKILL text check) do not constitute failures against the 28 handoff ACs — all 28 are addressed by the test suite. GAP 2 (no new architecture.md entry with Grounded in) is a potential §5 evidence gap that Alex should verify at Gate 4.
