# Q4: Safety Patterns and Interactions

**Query**: "What are TAD's key safety patterns and how do they interact to prevent quality drift?"
**Method**: Agent tool (general-purpose) reading brain-index.md → relevant files → synthesized answer
**Phase 1 Result**: ❌ (BM25 couldn't distinguish "SAFETY" marker from common word)

## Agent Answer Summary

4-layer defense system:
- **Layer 1 — Structural Separation**: Two-Agent System + Terminal Isolation prevent self-review
- **Layer 2 — Four-Gate Quality System**: Mandatory checkpoints with responsibility matrix (Gate 3=technical, Gate 4=business)
- **Layer 3 — Verification Integrity**: Claims Need Carriers, AC drift prevention, behavioral-eval discrimination, grep-c SAFETY count vs line-set diff
- **Layer 4 — Drift Detection**: Path Layering (3 independent defenses), Circular Trigger Test, compact recovery

Cross-cutting interactions: Mechanical Enforcement calibration (smoke alarm vs fire suppressor), Deny-List at every granularity, Decouple Detect-from-Heal, Knowledge distillation by structural stranger.

## Sources Cited by Agent

1. principles.md — 10+ principles cited (Two-Agent, Four-Gate, Path Layering, Express, Mechanical Enforcement, Circular Trigger, grep-c, Global-Count, Deny-List, Knowledge Distill)
2. patterns/gate-design.md — 6 patterns (Responsibility Matrix, Gate 4 Integrity, honest_partial, Claims Need Carriers, Decouple, AC-Driven)
3. patterns/ac-verification.md — AC Design Rules, Verification Drift, Self-Leak, Behavioral-Fixture Discrimination
4. patterns/pack-evaluation.md — Anti-Slop, Cross-Model, Discriminative-Field
5. patterns/memory-and-learning.md — Drift-Check, Compact Recovery, trace emission

## Phase 1 vs Phase 2 Comparison

| Aspect | Phase 1 (gbrain BM25) | Phase 2 (tad-brain) |
|--------|----------------------|---------------------|
| Found answer | ❌ No | ✅ Yes |
| SAFETY entries found | 0 | 10+ principles + 15+ patterns |
| Synthesis quality | None | 4-layer model with interactions |
| Cross-document | Failed | 5 files deeply read |

## Raw Result Quality

Alex judges at Gate 4. Raw answer provides a structured 4-layer model showing how patterns interact, including cross-cutting mechanisms that prevent the safety system from undermining itself.
