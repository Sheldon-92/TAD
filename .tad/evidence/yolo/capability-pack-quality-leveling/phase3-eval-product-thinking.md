# Phase 3 Behavioral Discriminative Eval — product-thinking

**Pack**: product-thinking
**Date**: 2026-06-13
**Fixture**: `.claude/skills/product-thinking/examples/pressure-test-verdict.md`

## Fixture Parameters

- `discriminative_pattern`: `/pressure-test|PIVOT|KILL|product.?type adapter|ASSUMPTION`
- `min_discriminative`: 2
- `min_marker_count`: 2

## Scenario (from fixture Input)

> "I want to build a SaaS app that helps freelancers auto-generate invoices
> from their calendar. Is this a good idea? Should I build it?"

## Method

Produced two answers to the same scenario:
- **WITH-PACK**: applied SKILL.md `/pressure-test` protocol — product-type
  adapter detection (software), 6 adversarial forcing rounds with real-data
  search, FACT/ASSUMPTION recording, terminal BUILD/PIVOT/KILL verdict.
- **CONTROL**: generalist product-advice answer with NO pack loaded — soft
  encouragement, generic "do market research / build an MVP" guidance.

Applied the discriminative pattern: `grep -oE PATTERN | sort -u | wc -l`.

## Results

| Output | Distinct markers matched | Disc count |
|--------|--------------------------|------------|
| WITH-PACK | `/pressure-test`, `ASSUMPTION`, `PIVOT` | **3** |
| CONTROL | (none) | **0** |

Verification command:
```bash
PAT='/pressure-test|PIVOT|KILL|product.?type adapter|ASSUMPTION'
grep -oE "$PAT" with-pack-output.md | sort -u | wc -l   # → 3
grep -oE "$PAT" control-output.md   | sort -u | wc -l   # → 0
```

## Gate Decision

- WITH-PACK disc (3) >= min_discriminative (2) → PASS
- CONTROL disc (0) < min_discriminative (2) → PASS (control stays below floor)

**discriminative_pass = TRUE**

The control answer deliberately addresses the same idea (competitors, market
research, MVP, pricing) but never produces the pack-specific markers: no
adversarial `/pressure-test` protocol, no `PIVOT/KILL` verdict, no
`ASSUMPTION` evidence recording. The pack's adversarial-diagnosis behavior is
genuinely discriminative, not just keyword stuffing — the control gives soft
"it could work" encouragement, which is exactly the default the pack replaces.
