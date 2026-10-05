# Gate 4 Acceptance — Capability Builder v1 Phase 2+3 (merged)

**Handoff**: `HANDOFF-20260903-capability-builder-phase23-evolve-package.md` (archived)
**Completion**: `COMPLETION-20260903-capability-builder-phase23-evolve-package.md` (archived)
**Design**: `DESIGN-20260903-capability-builder-phase23-evolve-package.md` (archived)
**Task ID**: `TASK-20260903-BUILDER-P23`
**Gate-4 reviewer**: Alex | **Date**: 2026-09-03 | **Mode**: YOLO (human blanket-authorized; all changes local + reversible; no release action)
**Verdict**: ✅ **PASS** — accepted at implementation commit; human retains one-tap revert (all deltas in `git log`, nothing pushed).

## 1. Business acceptance (requirement alignment)

- `$capability-builder evolve` live with trigger discipline: 5 approved triggers, `NO_TRIGGER_NO_WRITES` proven (E3). No scheduled-refresh backdoor (out-of-scope stops intact). ✅
- Eval-runner resource bounds shipped for the elevated P2 (size + wall-clock + pattern caps, advisory exit-0 kept, 20+-fixture corpus regression-free via E2a+E2b). ✅
- `$capability-builder package` explicit one-Skill/one-Plugin: manifest valid, byte-identical projection, isolated evidence, no marketplace writes (forbidden-root probes), failure atomic (rc=2 + trees unchanged). No MCP/App (not requested → absent). ✅
- Core unchanged: R1 fence empty + closed-world new-files-only-§7 (Alex reran post-commit smoke: E1 + mirror `diff -rq` green on `bba6ce84`). ✅
- Gate chain integrity: Gate 2 (dual FAIL→dual CONDITIONAL, 0 P0) → Gate 3 (Layer-1 10/10 + Layer-2 dual + fix-round re-verified) → this Gate 4. Two handoff errata found and corrected openly (P4 target, E1 timing claim) — evidence of working gates, not broken ones. ✅

## 2. Accepted commit

**`bba6ce84`** — `feat(TAD): Capability Builder v1 Phase 2 evolve + Phase 3 package (merged handoff, Gate 3 PASS 10/10)`.
Scope: 3 modified + 6 created framework files (§7 exactly) + evidence (gitignored, local).
NOT published / pushed / tagged / synced (no release step exists for this track; framework-health ban untouched).

## 3. Knowledge Assessment — distill DECISION: APPROVED, staged (not yet applied)

- **Candidate**: "Advisory assertion tools must bound their own match calls (size cap + wall-clock guard + pattern-length cap): fixtures are untrusted input — an unbounded `grep -oE` turns one bad fixture into a hang. Guard chain `gtimeout → timeout → perl-alarm → SKIP`; validity probes run UNDER the guard, not before it; no-op fallback forbidden for catastrophic inputs."
- **Variabilize test**: PASSES — applies to any grep-based assertion tool (`pack-eval-runner.sh`, `scan-collisions.sh`, dream/trace scanners), not just this handoff.
- **Target**: append to `.tad/project-knowledge/patterns/shell-portability.md` as a `###` entry with `failure_mode` (P0-1 history: first E1 attempt was empirically vacuous on this host's DFA grep).
- **Why staged, not applied**: `shell-portability.md` is inside this handoff's R1 fence — editing it post-acceptance would retroactively dirty the scope proof. Application rides the next knowledge-maintenance pass (`*knowledge-maintain`), which re-verifies the fence independently.
- Phase-1-style accepted P2s carried in COMPLETION §"Accepted non-blocking P2s" (worst-case header per-path qualification; `awk --` hygiene; timeout-path group-kill on foreign hosts; gitignored-baseline methodology note).

## 4. Residuals / carries

- Phase 4 (Voice Studio dogfood) remains deferred to the Voice Studio boundary — needs human resume + concrete downstream need (Epic constraint unchanged).
- Remaining P2 backlog: stale-lock recovery, large-tree hash cost (regex bounds now DONE).
- Epic status after this acceptance: 3/4 phases Done (Create ✅, Evolve ✅, Package ✅, Dogfood ⬚).
