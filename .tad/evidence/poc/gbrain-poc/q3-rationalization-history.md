# Q3: Rationalization History

**Query**: "What rationalizations have TAD agents used to justify skipping quality gates, and what was the outcome each time?"
**Commands**: 
- `$GBRAIN search "rationalization skipping quality gate"`
- `$GBRAIN search "anti_rationalization_registry"`
**Expected**: Synthesizes across anti_rationalization_registry entries + incident evidence

## Raw Results

### Search 1: "rationalization skipping quality gate"
```
[0.9545] project-knowledge/principles — TAD Methodology Principles (full file, generic match)
[0.9319] active/handoffs/handoff-20260703-gbrain-poc — current handoff (irrelevant)
[0.7199] evidence/spikes/codex-parity/codex-alex-skill.regen-headless — code snippet context
[0.6882] evidence/designs/design-20260414-phase2-enforcement-matrix — timeout implementation detail
[0.6249] templates/capability-pack-template/readme — pack template
```

### Search 2: "anti_rationalization_registry"
```
[1.0000] evidence/spikes/codex-parity/p2-constraint-trace — constraint preservation trace
[1.0000] evidence/reviews/alex/codex-parity-phase2-catchup/code-reviewer — code review of constraint system
[0.9998] evidence/spikes/codex-parity/parity-criterion — section mapping
[0.9998] hooks/lib/parity-criterion — same content (hook copy)
[0.9976] decisions/dr-20260531-ar001-research-challenge-carveout — AR-001 carve-out
```

## Evaluation

**Verdict: ❌ 无用**

**Reasoning**:
- Search 1 found principles.md but as a generic full-file match (0.95), not highlighting specific rationalization instances
- Search 2 found the constraint-tracing infrastructure (where anti_rationalization_registry is referenced as a SAFETY artifact to preserve) — NOT actual rationalization instances or outcomes
- The actual anti_rationalization entries live in Alex/Blake SKILL files (`.claude/skills/alex/SKILL.md` and `.claude/skills/blake/SKILL.md`) which are OUTSIDE .tad/ and thus NOT indexed
- Even within .tad/, rationalization incidents are documented in archived handoffs/completion reports, but the search didn't surface them because the keyword "rationalization" is not how those incidents were described
- A semantic search would understand that "⚠️ ANTI-RATIONALIZATION: 已经跑过 npm test 全部通过" IS a rationalization instance, but BM25 only matches the exact token

**Root Cause**: 
1. Relevant content (SKILL files) is outside indexed directory
2. Rationalization instances use varied natural language, not a consistent keyword — BM25 can't match semantically
