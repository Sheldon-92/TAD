# Layer 2 — Spec Compliance Review (Group 0)
## TASK-20260902-TAD-UPDATE-V2431 — TAD v2.43.1 backup repair + tad-update

**Reviewer:** spec-compliance-reviewer (independent subagent)
**Date:** 2026-09-02
**Handoff:** .tad/active/handoffs/HANDOFF-20260902-tad-update-v2431.md

## AC Status (all verified by executing the handoff's exact commands)

| AC | Result | Evidence |
|----|--------|----------|
| AC1 | PASS | Negative control: lowercase `cp -r` on dangling symlink → `No such file or directory`, rc=1 |
| AC2 | PASS | `--case backup` 5/5: link preserved; snapshots identical; pre-existing migration recovery survives; unique new snapshot; end-state present |
| AC3 | PASS | `--case states` 13/13: newer/equal/older/malformed/unavailable + claude-code/codex/both/explicit/ambiguous |
| AC4 | PASS | `--case consent` 9/9: no-TTY exit 3 + "confirmation required"; --check zero calls; --yes exactly once; no --force |
| AC5 | PASS | `--case download-safety` 14/14 (later 16/16): payload/extraction/binding fail-closed; pinned ignores mutable-main; exit 42 propagated; temp cleaned; env override ignored |
| AC6 | PASS | cmp parity + helper-ref present + forbidden substrings absent, exit 0 |
| AC7 | PASS | opencode command exists, helper-ref + updater-only label, forbidden absent, exit 0 |
| AC8 | PASS | `--case opencode-preservation` 9/9 (later 10/10 with residue assertion): preservation + preflight + rollback |
| AC9 | PASS | `--case full-upgrade` 8/8: 2.43.0→2.43.1 + upgrade-acceptance + detect-state + migration suites |
| AC10 | PASS | `--case release-gates` 7/7: canonical order 123456 asserted |
| AC11 | PASS | version.txt=2.43.1, package.json=2.43.1, version gate + version-sweep PASS |
| AC12 | PASS | `bash -n` exit 0 |
| AC13 | PASS | doc grep loop exit 0 |
| AC14 | SKIP | Post-Gate-4 by design (`--case remote-release` without commit confirmed clean SKIP) |

## FR Compliance

- FR-1 PASS (cp -R + unique dests; migration unique path; backup immediately pre-mutation)
- FR-2: ONE P1 FOUND — BSD mktemp template ending in `.sh` creates a literal fixed
  filename (concurrent updaters collide; killed runs block later runs). FIXED by Blake
  (template now ends in XXXXXX); consent/download-safety/states re-verified.
- FR-3/FR-4/FR-5 PASS.

## Verdict

- NOT_SATISFIED: 0
- PARTIALLY_SATISFIED: 0
- **PASS**
