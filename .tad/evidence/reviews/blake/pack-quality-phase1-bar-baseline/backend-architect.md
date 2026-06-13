# Methodology / Architecture Review — Phase 1
Reviewer: backend-architect subagent (independent)
Date: 2026-06-13

VERDICT: PASS — no P0/P1; 3 P2 (Phase-2 improvements, non-blocking).
Adversarial answers:
1. Rubric genuinely discriminative — both neg-controls real, reproduced, FAIL; Layer A control spans all 10 criteria; self-leak found+cleaned = control is exercised not decorative.
2. 0/2/5 sound, NOT single-ended — 0-2 anchor uses independent "LLM-restatable-without-research" test (does not reference golds); two ends anchored by different mechanisms; specN = defensible counted tiebreaker.
3. Batching defensible — boundary packs justified (§2.1); 7/5/5/4 honors "never pin a count"; golds-excluded correct (can't upgrade the ruler); advisory/re-rank-at-batch-entry hedge right.
4. No double-counting — §0 attribution traced clean: CONSUMES/PRODUCES→A5 only; fixture→A8 while behavioral result→separate disc column; specN→Layer B only; disc/fixture columns are display-only flags.
5. Caveats honest — no-fixture→LOW applied symmetrically; single-reviewer+specN-noise disclosed (§2.2); behavioral WITH/CONTROL eval honestly DEFERRED to Phase 2-5 DoD, not faked.
P2-1: specN gameable in theory by numeric noise → Phase 2 batch-entry must record ≥1 reading-vs-specN divergence.  [recorded in BASELINE §4]
P2-2: Layer A grep-shaped → don't read LA≥7 as standalone quality signal.  [recorded in BASELINE §4]
P2-3: ±1-2 specN doc/live drift → tolerance noted.  [fixed]
