# Phase 2 Behavioral Discriminative Eval — agent-orchestration

**Date**: 2026-06-13
**Pack**: agent-orchestration (v0.1.0)
**Fixture**: `.claude/skills/agent-orchestration/examples/agent-orchestration-fixture.md`
**Method**: WITH-PACK vs CONTROL answer on the fixture scenario, scored by the fixture's `discriminative_pattern` (case-sensitive `grep -oE | sort -u | wc -l`, matching the fixture's own Verification Command convention).

---

## Fixture Parameters

- `discriminative_pattern`:
  ```
  1 ?- ?\(1 ?- ?p\)\^s|63\.4%|99\.3%|n\(n ?- ?1\)|O\(n.?2\)|event[ -]sourc|complexity cliff|20.?40% token|8.?12 (round|turn)|15x|90\.2%|single.?writer|42%.*spec|MAST
  ```
- `min_discriminative`: 3
- Pattern is restricted to PACK-SPECIFIC markers (named rules, research figures/formulas). It deliberately excludes generic agent vocabulary ("multi-agent", "checkpoint", "retry"), severity tags, and words echoed from the input scenario ("300 steps", "10 agents").

## Scenario (from fixture)

> "I'm building an autonomous research agent that runs about 300 sequential tool/LLM steps per task. I'm using a fully-connected swarm of 10 specialist agents that hand off to each other with no shared context, and I wrap everything in a try/except retry loop so it restarts if it crashes. It keeps producing incoherent final reports and sometimes stops before finishing. I figure I'll just upgrade to a bigger model. Review my orchestration design and tell me why it's failing."

---

## WITH-PACK Answer

Produced by applying `SKILL.md` rules (Complexity Cliff cross-cutting rule, SUP3/SUP4, DUR1/DUR2, OW1/OW3, FM1/FM2/FM5 MAST). Computed P(fail) = 1-(1-p)^s, applied n(n-1) swarm surface, mandated Temporal event-sourcing, named single-writer coherence root cause, cited MAST 42/37/21 split, rejected "bigger model".

(Full text archived at `/tmp/ao-with-pack.md` during the eval run.)

## CONTROL Answer

Generalist review with NO pack: "too many agents / no shared context", "retry loop too blunt — add error handling and checkpoints", "make it more reliable", "a bigger model probably won't fix this — it's architecture", "use an established multi-agent framework". All generic; no pack formula, named rule, or research figure.

(Full text archived at `/tmp/ao-control.md` during the eval run.)

---

## Scoring (case-sensitive `grep -oE PATTERN | sort -u | wc -l`)

| Answer | Unique discriminative markers |
|--------|-------------------------------|
| WITH-PACK | **14** |
| CONTROL | **0** |

WITH-PACK markers hit: `1 - (1 - p)^s`, `63.4%`, `99.3%`, `complexity cliff`, `n(n-1)`, `O(n^2)`, `event-sourc`, `20-40% token`, `8-12 round`, `15x`, `90.2%`, `single-writer`, `42%...spec`, `MAST`.

CONTROL markers hit: none — the generalist answer reaches for exactly the generic phrasings the fixture's Anti-Slop Check flags as non-discriminative.

---

## Verdict

- with-pack disc (14) >= min_discriminative (3) ✅
- control disc (0) < min_discriminative (3) ✅
- **discriminative_pass = TRUE**

The pack produces materially different, research-grounded orchestration judgment that a no-pack generalist does not. The discriminative gate cleanly separates the two populations (14 vs 0), so the marker set is not leaking into generic output.
