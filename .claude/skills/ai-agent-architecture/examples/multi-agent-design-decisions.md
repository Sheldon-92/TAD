---
name: multi-agent-design-decisions
description: "Tests D1-D10 decision-navigator output + scoping questions + production-disaster mapping for a new multi-agent system"
pack: ai-agent-architecture
tests_rules:
  - "/design Phase 0 — 5 scoping questions"
  - "Phase 1 — D1-D10 decision walk"
  - "D10 — production disasters / incident mapping"
  - "Architecture Decision Document output"
min_marker_count: 3
---

# Fixture: Multi-Agent System Design Decisions

## Input Scenario

"I'm designing a new multi-agent system that ingests untrusted email and third-party API data, runs long stateful sessions, and will serve >1K sessions/day in production. Walk me through the architecture."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-agent-architecture pack loaded,
the output MUST contain these markers:

1. **Decision IDs (D1-D10)** [structural]: the agent walks the numbered decision navigator (D1 complexity, D2 coordination, D3 memory, D5 permissions …) rather than giving freeform advice
   grep pattern: `D[1-9]0?[ ]*(—|-|:|\()|Decision [1-9]`
2. **Mandatory permission/dual-agent trigger**: because input is untrusted external data, the pack mandates the D5 MCP checklist + dual-agent architecture
   grep pattern: `dual.?agent|MCP checklist|untrusted (external )?(input|data)|D5`
3. **Production-disaster / incident mapping**: the pack attaches a named production failure to each skipped decision
   grep pattern: `[Ii]ncident #[0-9]|production disaster|Architecture (Decision|Audit) (Document|Report)`
4. **Scoping answers drive applicability**: explicit "Applicable decisions / Skipped because …" framing
   grep pattern: `[Aa]pplicable decisions|SKIPPED — |stateful|coordination topology`

## Verification Command

```bash
grep -oE 'D[1-9]0?[ ]*(—|-|:|\()|Decision [1-9]|dual.?agent|MCP checklist|untrusted external|Incident #[0-9]|production disaster|Architecture Decision Document|Applicable decisions|SKIPPED — |coordination topology' multi-agent-design-decisions-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "D5 / MCP checklist / dual-agent" (the pack's specific permission decision triggered by untrusted input)
- ✅ "Incident #N" (pack maps each decision to a numbered production disaster — no-pack agent invents none)
- ✅ "Architecture Decision Document" (the pack's structured output artifact)
- ✅ "D1-D10" numbered decision IDs (the pack's navigator scaffold)
- ❌ "use a good architecture" (generic — any agent says this)
- ❌ "multi-agent" (in the input, not discriminative)
- ❌ "scalable" (generic buzzword any agent emits)
