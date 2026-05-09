# Code Review: research-methodology-upgrade (STORM + Elicit + Auto Source + Adaptive)
**Reviewer**: code-reviewer sub-agent
**Date**: 2026-05-09
**Handoff**: HANDOFF-20260509-research-methodology-upgrade.md
**Verdict**: PASS (after P1-1 fix) — final P0=0, P1=0, P2=3

## P1-1 Found + Fixed
Tunnel detection off-by-one: `current_depth >= 2 AND strategies_used[-1] == strategies_used[-2]` fails when strategies_used has only 1 element (after first loop iteration, [-2] is out-of-bounds).
**Fix**: Changed to `current_depth >= 3 AND len(strategies_used) >= 2 AND strategies_used[-1] == strategies_used[-2] AND strategies_used[-1] != "perspective_shift"`. Folded consecutive guard into ELIF, removed dead Else branch, added is_dynamic origin note.

## P2 Advisory (open)
P2-1: Inner consecutive guard semantics clarified by folding into ELIF (resolved as part of P1-1 fix).
P2-2: Dead `Else (no handler match)` branch — removed.
P2-3: `is_dynamic` origin tag — added note to Step 2.5.

## AC Verification
| AC | Result |
|----|--------|
| AC1 perspective_shift ≥3 | 4 ✅ |
| AC2 3-tier fallback | Tier 1/2/3 present ✅ |
| AC3 tunnel detection | strategies_used[-1] == strategies_used[-2] ✅ |
| AC4 PHASE 4.5 | 1 ✅ |
| AC5 ONLY inside *research-plan | 1 ✅ |
| AC6 5 academic filters | all 5 on same line ✅ |
| AC7 after fast+deep fail | 2 ✅ |
| AC8 Max URLs: 3 | 1 ✅ |
| AC9 source-preprocessor.sh | 1 ✅ |
| AC10 MAX_DYNAMIC_SEEDS: 2 | 1 ✅ |
| AC11 AskUserQuestion | present ✅ |
| AC12 append to end | 2 ✅ |
| AC13 6-strategy priority list | 2 ✅ |
| AC14 only 2 files | confirmed ✅ |
