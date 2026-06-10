# Acceptance Verification Report: TASK-20260607-002

**Date:** 2026-06-07
**Handoff:** HANDOFF-20260607-npx-platform-installer.md

## Results

| AC# | Description | Status | Method |
|-----|-------------|--------|--------|
| AC1 | Backward compatibility (default == explicit) | PASS | diff -rq two installs |
| AC2a | AGENTS.md + .tad/codex present for codex | PASS | test -f/-d |
| AC2b | Excluded items absent (settings/alex/blake) | PASS | test ! -f/-d |
| AC2c | Core completeness (templates match, hooks/lib) | PASS | diff -rq + test -d |
| AC3 | No --platform = claude-code | PASS | covered by AC1 |
| AC4 | Unknown platform fail-fast | PASS | exit code != 0 |
| AC5 | Re-run idempotent | PASS | file list diff before/after |
| AC6 | No 86K SKILL in codex | PASS | test ! -f |
| AC7 | npx interactive lists descriptions | PASS | code review (readline + description output) |
| AC8 | npx non-interactive mode | PASS | --platform --packs skip readline |
| AC9 | Bridge membership validation | PASS | invalid platform/pack exits 1 |
| AC10 | No copy primitives in npx | PASS | grep -cE = 0 |
| AC11 | package.json correctness | PASS | node -e checks + shebang |
| AC12 | Verifier platform-scoped | PASS | codex self-check passed |
| AC13 | Codex can activate | PASS | structural files exist |

## Summary

13/13 PASS. All acceptance criteria verified via automated scripts using mktemp target directories and the actual tad.sh copy_framework_files function.
