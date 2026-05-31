# Classification Smoke — Effort-Scaling Ladder (AC4.4 Blake portion)

**Handoff:** HANDOFF-20260531-research-engine-wire-phase4
**Date:** 2026-05-31
**Scope:** Mechanical trace of the Phase 0class effort-scaling ladder added to
`research_plan_protocol` (alex/SKILL.md). One sample research item per complexity
tier, showing it routes to the correct `(run_dynamic_seeds, run_adversarial_challenge)`
booleans. (NOT a live `*research-plan` run — that is an Alex command, deferred to Gate 4.)

## Ladder under test (from alex/SKILL.md Phase 0class)

Ordered, mutually exclusive — classify as the LOWEST tier whose EXPLICIT trigger is met;
default `comparison` when ambiguous (NOT complex).

| Complexity | EXPLICIT trigger | run_dynamic_seeds | run_adversarial_challenge |
|------------|------------------|-------------------|----------------------------|
| simple     | single fact / narrow API or syntax lookup / 1 KR | off | off |
| comparison (DEFAULT) | compares-and-recommends across >=2 named options/tools | on | off |
| complex    | >=3 distinct incomplete KRs OR explicit landscape/survey scope | on | on |

## Trace (3 sample items, one per tier)

```
Item 1 (simple): 'What is the exact CLI flag for yq in-place edit?'
  -- single fact / narrow API lookup, 1 KR
  tier=simple     run_dynamic_seeds=off run_adversarial_challenge=off

Item 2 (comparison, DEFAULT): 'Compare Vercel vs Netlify vs Fly.io for a Next.js app and recommend one'
  -- compares-and-recommends across >=2 named tools
  tier=comparison run_dynamic_seeds=on  run_adversarial_challenge=off

Item 3 (complex): 'Survey the 2026 AI-agent memory landscape across retrieval, eval, and cost KRs (all incomplete)'
  -- >=3 incomplete KRs + landscape scope
  tier=complex    run_dynamic_seeds=on  run_adversarial_challenge=on
```

## Result

All three items route to the booleans the ladder specifies:

- **simple** -> no dynamic seeds, no adversarial challenge (baseline seed tree STILL runs -- see AC4.1b note: Phase 4 Step 1 is never gated).
- **comparison** (the ambiguity default) -> dynamic seeds ON, challenge OFF.
- **complex** -> dynamic seeds ON, challenge ON (auto-run sanctioned by DR-20260531 carve-out, displayed + overridable in Phase 0class Step 2).

The trace mirrors the SKILL.md table 1:1. PASS for the mechanical-smoke portion of AC4.4.
The real seed-origin fire criterion is Gate-4-deferred (Alex runs `*research-plan`).
