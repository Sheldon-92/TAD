---
handoff: HANDOFF-20260601-codex-parity-phase2-catchup.md
completed_by: Blake
completed_at: 2026-06-01
gate3_verdict:
---

# COMPLETION: Codex-Edition Parity — Phase 2 (Catch-up)

## Summary

Upgraded `parity-check.sh` Layer 2 from a global constraint count floor to **per-must-cover-owner-body presence** (position-aware). Validated with 3 anti-theater dogfood cases. Regenerated both live Codex editions (`codex-alex-skill.md` + `codex-blake-skill.md`) to full v2.20.0 parity, verified by the upgraded gate. Headless probe via `codex exec` passed in 175s.

## Implementation Steps Completed

1. **Step 1 — parity-check.sh Layer 2 upgrade**: Replaced global floor + bare presence checks with per-(category, owner) body-count comparison. Bodies parsed by col-0 keys (any kind). 0-source categories SKIP. Pin table self-validation. Fail-CLOSED on parse errors. Legacy L116-130 gates removed.

2. **Step 2 — Gate validation (3 dogfood cases)**:
   - **2a Plain deletion**: Deleted `express_path_protocol` forbidden_implementations from source copy → exit 1, naming `express_path_protocol: codex=0 < source=1`. PASS.
   - **2b Compensation**: Same deletion + 2 surplus forbidden_implementations in `on_start` section → STILL exit 1 (surplus in different section cannot mask express loss). PASS.
   - **2c Pin table**: All 8 pins matched (4 alex + 4 blake): forbidden_implementations 12/6, anti_rat 6/0, NOT_via_alex_auto 5/0, honest_partial 0/4. PASS.

3. **Step 3 — regen-procedure.md hardening**: Added Step D (post-emit per-owner SAFETY self-verify, bounded ≤2 re-emit rounds → honest_partial on persistent failure).

4. **Step 4 — codex-alex-skill.md regeneration**: Based on P1 edition, added missing SAFETY sections (cross_model_awareness, research_plan_protocol with 3 NOT_via_alex_auto, on_start with 2 anti_rat), 8 missing protocol stubs, Layer 3 markers. Atomic mv after parity-check exit 0. Size: 46KB ≤ 102KB.

5. **Step 5 — codex-blake-skill.md regeneration**: Added cross_model_invocation (forbidden_implementations), ralph_loop_execution (forbidden_implementations), fixed execution_checklist (1→3 mentions), honest_partial_protocol (1→2 with END marker), on_start with honest_partial refs, exit_protocol + domain_pack_trace_protocol stubs. Atomic mv. Size: 29KB ≤ 41KB.

6. **Step 6 — Headless probe**:
   - `claude -p`: FAIL (224s, 2KB — model produced analysis, not raw file)
   - `codex exec --full-auto`: PASS (175s, 47KB, parity-check exit 0 all 3 layers)
   - Recurring human-touch time: ~175s (~3 min) — within ≤5min

7. **Step 7 — Verify + commit**: Both launchers dry-run exit 0. Independent spot-read confirmed SAFETY blocks + feature tracks. Committed `4881bc1` (impl) + `774ce53` (AC fixes) + `fb43be2` (P1-1 fix).

## Deviations from Plan

- **Layer 3 feature markers source-conditioned**: Added source-check to feature marker loop — markers not in source are SKIPped. Required because blake source doesn't have `research_complexity`/`step4_5` (alex-specific). Not in original handoff but necessary for AC4 PASS.
- **P1-2 (header self-counting) deferred to P3**: Reviewer agreed current behavior is symmetric and pins are calibrated. Will fix when P3 hardens for release gate.

## Evidence Checklist

- [x] `.tad/evidence/reviews/blake/codex-parity-phase2-catchup/spec-compliance.md`
- [x] `.tad/evidence/reviews/blake/codex-parity-phase2-catchup/code-reviewer.md`
- [x] `.tad/evidence/spikes/codex-parity/p2-constraint-trace.md`
- [x] `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen-headless.md`
- [x] `.tad/codex/codex-alex-skill.md` (regenerated, parity exit 0)
- [x] `.tad/codex/codex-blake-skill.md` (regenerated, parity exit 0)
- [x] `.tad/evidence/spikes/codex-parity/parity-check.sh` (Layer 2 upgraded)
- [x] `.tad/evidence/spikes/codex-parity/regen-procedure.md` (Step D hardened)
- [x] `.tad/evidence/spikes/codex-parity/parity-criterion.md` (pin table added)

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Category:** architecture

**Summary:** Feature marker source-conditioning for cross-agent parity checks. When a parity check gates BOTH alex and blake editions, hardcoded markers that are agent-specific (e.g., `research_complexity` is alex-only) cause false failures on the other agent's edition. Fix: check markers only if `grep -ci "$marker" "$SOURCE" > 0`. Also: `claude -p` with 326KB input produces analysis not raw file — `codex exec` is the reliable headless regen path.

## Reflexion History

无 reflexion（Layer 1 不适用此 task_type: mixed shell/markdown 任务 — 无 build/test/lint/tsc）。
