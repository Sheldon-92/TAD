# Q2: Hardcoded Allow-List Problems

**Query**: "What problems has TAD had with hardcoded allow-lists across different features?"
**Method**: Agent tool (general-purpose) reading brain-index.md → relevant files → synthesized answer
**Phase 1 Result**: ✅ (keyword match worked, but only with optimized query)

## Agent Answer Summary

TAD had persistent allow-list problems across 5 distinct features:
1. 14-dir sync allow-list missed 12+ dirs (.tad/codex/ frozen for a month)
2. 18-item version-string list left tad.sh stuck at v2.19.1
3. tad.sh installer's hardcoded dir list (12 of 32 from memory)
4. Top-level file extension allow-list (*.yaml *.md *.txt dropped portable-extract.sh)
5. Zero-touch partial restatements in the fix itself

Fix: 2-phase YOLO Epic — deny-list derivation + structure-agnostic verification (diff -rq).

## Sources Cited by Agent

1. evidence/yolo/self-deriving-release-sync/phase1-grounding.md
2. decisions/DR-20260601-self-deriving-release-sync.md
3. principles.md — "Never Hand-Write", deny-list principles
4. evidence/yolo/self-deriving-release-sync/phase2-impl-review-arch.md
5. archive/epics/EPIC-20260601-self-deriving-release-sync.md

## Phase 1 vs Phase 2 Comparison

| Aspect | Phase 1 (gbrain BM25) | Phase 2 (tad-brain) |
|--------|----------------------|---------------------|
| Found answer | ✅ (keyword-optimized only) | ✅ (natural language) |
| Cross-document | 5 files found | 5+ files with deep synthesis |
| Depth | File titles only | 5 specific failure instances enumerated |
| Natural language query | ❌ Failed | ✅ Worked |

## Raw Result Quality

Alex judges at Gate 4. Raw answer identifies 5 concrete instances with dates, file counts, and outcomes. Includes the systemic fix and two extracted principles.
