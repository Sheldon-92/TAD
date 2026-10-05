# Layer 2 — Code Review (Group 1)
## TASK-20260902-TAD-UPDATE-V2431 — TAD v2.43.1 backup repair + tad-update

**Reviewer:** code-reviewer (independent subagent)
**Date:** 2026-09-02
**Scope:** tad.sh (diff), .tad/scripts/tad-update.sh (new), .tad/tests/tad-update-fixture.sh (new),
.tad/tests/upgrade-acceptance.sh (diff), .tad/hooks/lib/release-verify.sh (diff), entrypoints,
.tad/migrations/2.43.0-to-2.43.1.yaml (new)

## Round 1 findings

| ID | Severity | File | Issue |
|----|----------|------|-------|
| F1 | P1 | tad.sh (preflight / EXIT trap) | Plain-installer preflight abort leaves downloaded `TAD-main/` in the project root: preflight exits before NEED_ROLLBACK is armed, and the non-pinned cleanup only runs on the main-flow success path. Fixture digest excludes TAD-main so no AC caught it. |
| F2 | P2 | tad.sh (download_pinned_source) | Pinned binding fail-open when tag archive lacks `.tad/version.txt`: derive_target_version's literal fallback leaves TARGET_VERSION at the pre-seeded expected value, so the match check passes without proving the archive version. |

Verified clean in R1: bash -n on all shipped scripts; all fixture cases green; skills
byte-identical; no `curl | bash`/`--force`; mktemp templates end in XXXXXX; consent
boundary; pinned skips probe; unique backups; version gates; justified release-verify/
upgrade-acceptance exemptions; carriers at 2.43.1.

## Fixes applied (Blake)

- F1: EXIT trap now also removes a download-created `TAD_SRC` when
  `TAD_SRC_DOWNLOADED=1` (guarded; success-path double cleanup no-ops). Fixture
  gained a direct `[ ! -d TAD-main ]` residue assertion in `--case opencode-preservation`.
- F2: explicit `[ ! -f .tad/version.txt ]` fail-closed check before
  `derive_target_version`. Fixture gained "no-version archive refused + zero mutation"
  assertions in `--case download-safety`.

## Round 2 (re-review)

- F1 RESOLVED (code + fixture + independent reproduction).
- F2 RESOLVED (code + fixture + independent reproduction).
- No new issues: double-cleanup guard-safe in all paths; residue assertion is direct,
  not digest-hidden; trap ordering disjoint; `bash -n` clean.

## Verdict

**P0: 0 · P1: 0 · P2: 0 → PASS**
