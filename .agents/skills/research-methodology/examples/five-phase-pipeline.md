---
name: five-phase-pipeline
description: "Tests 5-phase Plan→Source→Curate→Analyze→Output pipeline + GitHub-First sourcing + T1/T2/T3 tier ratio + saturation detection + QCE output"
pack: research-methodology
tests_rules:
  - "5-phase pipeline (Plan→Source→Curate→Analyze→Output) with human gates H1/H2/H3"
  - "GitHub-First sourcing strategy"
  - "Curate: T1/T2/T3 tier ratio (T1 ≥ 0.30)"
  - "Saturation detection (SATURATED/DIMINISHING/CONTINUE)"
  - "QCE-structured output + extracted ACs"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "search the web"/"summarize
# findings". The named Plan→Source→Curate→Analyze→Output machine, GitHub-First sourcing,
# T1/T2/T3 tier ratio, SATURATED/DIMINISHING states, and QCE output are pack introductions.
discriminative_pattern: "GitHub-First|SATURATED|DIMINISHING|QCE|Plan→Source|T1/T2/T3"
min_discriminative: 3
---

# Fixture: Five-Phase Research Pipeline

## Input Scenario

"研究一下 2025 年开源 AI agent 编排框架的 landscape，对比主流方案，给我一份结论。"

## Expected Markers

When an AI agent processes the Input Scenario with the research-methodology pack loaded,
the output MUST contain these markers:

1. **5-phase pipeline with gates** [structural]: the agent structures the work as Plan→Source→Curate→Analyze→Output with the named human gates, not an ad-hoc WebSearch dump
   grep pattern: `PLAN|SOURCE|CURATE|ANALYZE|OUTPUT|GATE H[1-3]|problem tree|question tree`
2. **GitHub-First sourcing**: the pack's specific sourcing order (awesome-lists → company repos → tools → docs → articles)
   grep pattern: `[Gg]it[Hh]ub.?[Ff]irst|awesome.?list|company repo|sourcing strategy`
3. **Tier ratio curation**: the T1/T2/T3 scoring with the ≥0.30 T1 threshold
   grep pattern: `T1|T2|T3|tier1.?ratio|0\.30|tier (1|one)|official/academic`
4. **Saturation detection + QCE output**: the pack's loop-stop signals and output format
   grep pattern: `SATURATED|DIMINISHING|CONTINUE|saturation|QCE|extracted? ACs?`

## Verification Command

```bash
grep -oE 'PLAN|SOURCE|CURATE|ANALYZE|OUTPUT|GATE H[1-3]|problem tree|GitHub.?First|awesome.?list|company repo|T1|T2|T3|tier1.?ratio|0\.30|SATURATED|DIMINISHING|CONTINUE|saturation|QCE|extracted ACs' five-phase-pipeline-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Plan→Source→Curate→Analyze→Output + GATE H1/H2/H3" (the pack's named 5-phase state machine)
- ✅ "GitHub-First sourcing (awesome-lists → repos → docs)" (the pack's specific sourcing order)
- ✅ "T1/T2/T3 tier ratio ≥ 0.30" (the pack's source-quality threshold)
- ✅ "SATURATED/DIMINISHING/CONTINUE + QCE output" (the pack's saturation states and output format)
- ❌ "search the web" (the generic default the pack replaces with structured sourcing)
- ❌ "compare the frameworks" (restates the input)
- ❌ "summarize findings" (generic, non-discriminative)
