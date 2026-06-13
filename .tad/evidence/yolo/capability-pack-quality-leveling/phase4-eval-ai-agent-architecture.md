# Phase 4 Behavioral Discriminative Eval — ai-agent-architecture

**Date**: 2026-06-13
**Pack**: ai-agent-architecture
**Fixture**: `.claude/skills/ai-agent-architecture/examples/multi-agent-design-decisions.md`

## Fixture parameters

- **discriminative_pattern**: `D(10|[1-9])([^0-9]|$)|Architecture Decision Document|Incident #|dual-agent`
- **min_discriminative**: 3
- **Method**: `grep -oE PATTERN | sort -u | wc -l` against WITH-PACK and CONTROL answers.

## Scenario (from fixture Input)

"I'm designing a new multi-agent system that ingests untrusted email and third-party API data, runs long stateful sessions, and will serve >1K sessions/day in production. Walk me through the architecture."

## Answers produced

- WITH-PACK (`/tmp/aaa-with-pack-output.md`): applied SKILL.md `/design` mode — Step 0 scoping (5 Qs), Step 1 D1–D10 decision walk, dual-agent quarantine trigger fired (untrusted external input ⇒ D5 MCP checklist mandatory), numbered Incident # disaster mapping, and the named Architecture Decision Document artifact.
- CONTROL (`/tmp/aaa-control-output.md`): generalist senior-engineer answer with NO pack — freeform headings (Security, State, Scalability, Coordination, Observability, Testing), generic buzzwords ("scalable", "use a good architecture"), no decision IDs, no named artifact, no incident mapping.

## Discriminative measurement

| Answer | Unique discriminative markers | Pass threshold (≥3) |
|--------|-------------------------------|---------------------|
| WITH-PACK | **23** | PASS |
| CONTROL | **0** | (must be <3 → 0 confirms separation) |

WITH-PACK matched: `Architecture Decision Document`, `D1`–`D10` navigator IDs, `dual-agent`, `Incident #`.
CONTROL matched: none — the generalist answer emits zero pack-unique scaffolds.

## Verdict

- with_pack_disc = 23 ≥ min_discriminative (3) ✅
- control_disc = 0 < min_discriminative (3) ✅
- **discriminative_pass = true**

The pack produces strongly discriminative behavior: the decision-navigator IDs, the dual-agent untrusted-input safety trigger, the numbered production-disaster mapping, and the structured Architecture Decision Document are all pack-unique and entirely absent from a competent generalist answer. Clean separation (23 vs 0).
