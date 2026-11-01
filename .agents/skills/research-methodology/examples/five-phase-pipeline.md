---
name: five-phase-pipeline
description: "Tests the 5-phase research pipeline (Plan→Source→Curate→Analyze→Output): problem tree decomposition, GitHub-First sourcing, dead-end registry check, T1/T2/T3 source tiering, saturation detection, PIVOT/REFINE logic, QCE output + AC extraction"
pack: research-methodology
tests_rules:
  - "Phase 1 PLAN: decompose the question into a problem tree of >=3 sub-questions; check the dead-end registry before finalizing"
  - "Phase 2 SOURCE: GitHub-First source strategy"
  - "Phase 3 CURATE: score sources T1 (official/academic) / T2 (industry) / T3 (community); T1 ratio >= 0.30 gate"
  - "Phase 4 ANALYZE: ask loop with saturation detection; PIVOT (max 3) / REFINE decision logic; ask-round budget 10"
  - "Phase 5 OUTPUT: QCE-structured report + extracted AC list; research-state.yaml session tracking"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "research",
# "search the web", "compare options", "summarize findings" (any agent emits these).
# The five phase names as a pipeline, the problem tree, the dead-end registry, the
# saturation check, PIVOT/REFINE, the QCE output format and the state file are the
# pack's own machinery a no-pack agent does not produce.
discriminative_pattern: "QCE|dead-end|problem tree|saturation|PIVOT|NotebookLM|research-state"
min_discriminative: 3
---

# Fixture: Five-Phase Research Pipeline

## Input Scenario

"Research the landscape of open-source tools for automated code review, and tell me which one we should adopt. I need more than a feature list: I want to know how the options differ on accuracy, self-hosting, and maintenance health, what the known dead ends are (approaches that look promising but fail in practice), and a final recommendation I can act on. Take your time and be thorough — use multiple sources and stop when more searching stops adding new findings."

## Expected Markers

When an AI agent processes the Input Scenario with the research-methodology pack loaded,
the output MUST contain these markers:

1. **Problem tree decomposition** [structural]: the agent decomposes the question into ≥3 sub-questions (options / accuracy / self-hosting / maintenance) before searching, instead of searching the raw question
   grep pattern: `problem tree|sub-question`
2. **Dead-end registry check**: before finalizing the plan, the agent checks the dead-end registry for prior refuted angles on the sub-questions
   grep pattern: `dead-end`
3. **GitHub-First sourcing + tier curation**: sources are gathered GitHub-First and scored T1/T2/T3 with a T1 ratio gate (≥ 0.30)
   grep pattern: `GitHub-First|T1|tier`
4. **Saturation detection in the analyze loop**: the agent tracks new findings per round and stops (or pivots) when the loop saturates, instead of searching indefinitely; PIVOT/REFINE named when the angle changes
   grep pattern: `saturation|SATURATED|PIVOT|REFINE`
5. **QCE output + session state**: the deliverable is a QCE-structured report with an extracted AC list, tracked in research-state.yaml through the five phases
   grep pattern: `QCE|research-state|Phase [1-5]`

## Verification Command

```bash
grep -oE 'problem tree|sub-question|dead-end|GitHub-First|T1|tier|saturation|SATURATED|PIVOT|REFINE|QCE|research-state|Phase [1-5]|NotebookLM' five-phase-pipeline-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "problem tree of sub-questions + dead-end registry check before searching" (the pack's Phase 1 machinery)
- ✅ "saturation detection — stop when new findings per round dry up; PIVOT/REFINE" (the pack's Phase 4 loop control)
- ✅ "QCE report + extracted ACs, state in research-state.yaml" (the pack's Phase 5 output contract)
- ✅ "T1/T2/T3 tiering with T1 ratio ≥ 0.30" (the pack's Phase 3 quality gate)
- ❌ "let me search the web for code review tools" (generic — no pipeline, no state)
- ❌ "here is a comparison table" (generic deliverable — no QCE structure, no AC extraction)
