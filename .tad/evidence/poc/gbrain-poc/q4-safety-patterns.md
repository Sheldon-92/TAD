# Q4: Safety Patterns and Interactions

**Query**: "What are TAD's key safety patterns and how do they interact to prevent quality drift?"
**Commands**:
- `$GBRAIN search "safety patterns quality drift prevention"`
- `$GBRAIN search "SAFETY entry principles pattern interaction"`
**Expected**: Synthesizes across SAFETY entries in principles.md + pattern files, not just listing them

## Raw Results

### Search 1: "safety patterns quality drift prevention"
```
[0.9985] active/handoffs/handoff-20260703-gbrain-poc — current handoff (irrelevant)
[0.8096] spike-v3/domain-pack-tools/ai-agent-architecture-skills-best-practices — external reference
[0.3968] evidence/research/agent-pack-factory/agent-orchestration/findings — agent orchestration research
[0.3598] archive/epics/epic-20260424-tad-self-upgrade-from-consumers — rubric/anti-pattern mention
```

### Search 2: "SAFETY entry principles pattern interaction"
```
[0.9891] active/handoffs/handoff-20260703-gbrain-poc — current handoff (irrelevant)
[0.4958] archive/handoffs/handoff-20260602-knowledge-lifecycle-phase1 — knowledge lifecycle mention
```

## Evaluation

**Verdict: ❌ 无用**

**Reasoning**:
- Top result in both searches was the current handoff itself (which mentions the query text verbatim) — classic BM25 self-reference problem
- Did NOT find principles.md despite it containing 12 SAFETY-marked entries
- Did NOT find any pattern files (gate-design.md, ac-verification.md, etc.)
- The query requires understanding that "⚠️ SAFETY ENTRY" is a marker indicating safety-critical content — BM25 treats "SAFETY" as a generic English word
- No synthesis possible: results are scattered and irrelevant

**Root Cause**: 
1. "SAFETY" as a domain-specific marker is not distinguished from the common English word by BM25
2. principles.md is a large file (~15KB) — tsvector averages over the full document, so the term frequency for "safety" is diluted
3. The query asks for INTERACTION between patterns — a purely synthetic question that keyword search cannot address
