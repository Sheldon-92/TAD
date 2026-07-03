# Q5: Methodology Coverage Gaps

**Query**: "What areas of TAD methodology lack principle or pattern coverage?"
**Method**: Agent tool (general-purpose) reading brain-index.md → ALL pattern/principle files → gap analysis
**Phase 1 Result**: ❌ (zero search results; think requires API key)

## Agent Answer Summary

6 significant coverage gaps identified:

1. **Socratic Elicitation** — Rule 0 BLOCKING gate, tad-elicit skill exists, but zero principle/pattern on what makes elicitation effective, when to stop, failure modes
2. **Epic Lifecycle Management** — Scattered fragments but no unified pattern for: when Epic vs direct handoff, phase boundary scoping, cancellation criteria, Epic-level pivots
3. **Terminal Isolation Operations** — Design rationale covered, but no pattern on: operational failure modes, accidental isolation breaks, human bridge edge cases, evidence/failures/ has 0 files
4. **Error Recovery and Violation Handling** — CLAUDE.md §5 is one line; no pattern on violation types, graceful mid-task recovery, partial work preservation
5. **User Communication Patterns** — Memory entries exist (Plain Language) but not formalized; human is the sole bridge, communication is load-bearing
6. **Cross-Project Distribution Strategy** — Mechanical sync covered, but no strategic layer: when to trigger sync, customization conflicts, version compatibility

## Sources Cited by Agent

1. brain-index.md — Full index scan
2. CLAUDE.md — Sections 1-7
3. principles.md — All 15 entries
4. patterns/gate-design.md — 14 entries
5. patterns/handoff-design.md — 16 entries
6. patterns/memory-and-learning.md, ac-verification.md, pack-build-rules.md, pack-evaluation.md, research-methodology.md, hook-contracts.md, shell-portability.md

## Phase 1 vs Phase 2 Comparison

| Aspect | Phase 1 (gbrain BM25) | Phase 2 (tad-brain) |
|--------|----------------------|---------------------|
| Found answer | ❌ (zero results) | ✅ Yes |
| Analytical depth | None (needs LLM) | 6 specific gaps with evidence |
| Coverage reasoning | Impossible for retrieval | Agent read ALL files and reasoned about absence |
| Actionable | No | Each gap has specific what's-missing |

## Raw Result Quality

Alex judges at Gate 4 (especially this one — per handoff §4.3 Q5 note). Raw answer reads all 9 pattern files + principles + CLAUDE.md and identifies gaps by reasoning about what IS covered vs what is NOT.
