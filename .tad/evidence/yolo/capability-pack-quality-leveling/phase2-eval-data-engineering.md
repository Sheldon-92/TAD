# Phase 2 Behavioral Discriminative Eval — data-engineering

**Date**: 2026-06-13
**Pack**: data-engineering (v0.1.0)
**Fixture**: `.claude/skills/data-engineering/examples/data-engineering-fixture.md`
**Scenario**: `rag-feature-pipeline-review` — customer-support AI RAG + feature pipeline

## Fixture parameters

- `discriminative_pattern`: `train.?serve skew|recall collapse|Reciprocal Rank Fusion|RRF|k ?= ?60|\[40, ?80\]|ACORN|is_current ?= ?true|missing.?field trap|pre.?filter|SCD Type 2|graph islanding|94x|streaming engine`
- `min_discriminative`: 4

## Method

1. Took the fixture Input Scenario verbatim.
2. Produced a **WITH-PACK** answer applying `data-engineering/SKILL.md` rules (Train-Serve Skew cross-cutting rule + VEC1/VEC3/VEC4 + TRN3 + DIM4 + P0/P1/P2 output format).
3. Produced a **CONTROL** answer as a generalist with NO pack (generic "keep consistent / add filtering / use Polars / store history" advice).
4. Applied the discriminative pattern (`grep -oiE PATTERN | sort -u | wc -l`) to both.

## Results

| Answer | Distinct discriminative markers |
|--------|--------------------------------|
| WITH-PACK | **14** |
| CONTROL | **0** |

### WITH-PACK matched markers
`train-serve skew`, `recall collapse`, `pre-filter`, `Reciprocal Rank Fusion`, `RRF`, `k = 60` / `k=60`, `[40, 80]`, `ACORN`, `graph islanding`, `streaming engine`, `94x`, `SCD Type 2`, `is_current = true`

(Note: the count of 14 is slightly inflated by case-insensitive alias forms — `RRF` vs `Reciprocal Rank Fusion`, `k = 60` vs `k=60` — but the distinct underlying pack concepts number ~11, all well above threshold.)

### CONTROL matched markers
None. The generalist answer used only non-discriminative generic nouns the fixture's Anti-Slop Check explicitly excludes: "keep consistent", "feature store", "add metadata filtering", "use Polars it's faster", "store the history".

## Gate decision

```
discriminative_pass = (with_pack 14 >= min 4) AND (control 0 < min 4) = TRUE
```

**PASS** — the pack produces pack-specific markers (named failure modes + specific numbers from refreshed sources) that a no-pack control does not emit. The discriminative gate cleanly separates with-pack from control.

## Verification command (reproducible)

```bash
PATTERN='train.?serve skew|recall collapse|Reciprocal Rank Fusion|RRF|k ?= ?60|\[40, ?80\]|ACORN|is_current ?= ?true|missing.?field trap|pre.?filter|SCD Type 2|graph islanding|94x|streaming engine'
grep -oiE "$PATTERN" with-pack.md  | sort -u | wc -l   # -> 14
grep -oiE "$PATTERN" control.md     | sort -u | wc -l   # -> 0
```
