# Layer 2 — Test Runner Review (Group 2)
## TASK-20260902-TAD-UPDATE-V2431 — TAD v2.43.1 backup repair + tad-update

**Reviewer:** test-runner (independent subagent)
**Date:** 2026-09-02

## Suite results (exact numbers, run on the real tree)

| Suite | Result |
|---|---|
| `--case backup` | 6 PASS / 0 FAIL |
| `--case states` | 13 PASS / 0 FAIL |
| `--case consent` | 9 PASS / 0 FAIL |
| `--case download-safety` | 16 PASS / 0 FAIL |
| `--case opencode-preservation` | 10 PASS / 0 FAIL |
| `--case full-upgrade` | 8 PASS / 0 FAIL |
| `--case release-gates` | 7 PASS / 0 FAIL |
| `detect-state-fixture.sh` | 22 passed / 0 failed |
| `migration-fixtures/run-fixtures.sh` | 23/23 |
| `gate-exercise.sh` | blocked unmanifested delete as expected |

Total: 69/69 tad-update-fixture assertions + 45 downstream assertions, all green.

## Mutation probes (temp copies, real files untouched)

- (a) `cp -R` → `cp -r` in tad.sh: `--case full-upgrade` RED ("upgrade install failed").
- (b) updater no-TTY `exit 3` → `exit 0`: `--case consent` RED.
- (c) removed `opencode_preflight` call: `--case opencode-preservation` RED (7/4).

## Determinism

Network-free: mock curl first in PATH intercepts all 4 URL classes; unhandled URLs
fail closed (exit 22). Only real-URL string is the deliberate env-override probe.

## Quality notes (both addressed by Blake)

1. `--case backup` gained an integration-level cp-R negative control (b2: runs the
   real `backup_existing` extracted from tad.sh against a symlink-bearing project —
   verified to go red on a cp-r regression).
2. BSD-tar basename-class `--exclude='./scripts'` removed from `make_src_tarball`
   (verified it silently stripped `.tad/scripts/` from fixture tarballs); remaining
   excludes empirically verified collision-free.

## Verdict

**PASS** (100% pass; negative controls discriminative; deterministic)
