# Q1: Terminal Isolation Design Decision

**Query**: "Why did TAD choose terminal isolation instead of shared state for Alex and Blake?"
**Method**: Agent tool (general-purpose) reading brain-index.md → relevant files → synthesized answer
**Phase 1 Result**: ❌ (answer was in CLAUDE.md, outside gbrain's index)

## Agent Answer Summary

TAD chose terminal isolation because self-review has no second perspective — a single agent doing both design and implementation rationalizes its own shortcuts. Terminal isolation enforces separation structurally: Alex cannot execute code and Blake cannot change designs. A secondary benefit emerged: Alex serves as a "structural stranger" for knowledge distillation (curse of knowledge principle).

## Sources Cited by Agent

1. CLAUDE.md §4 "Terminal 隔離"
2. principles.md — "Two-Agent System", "Express Handoff is NOT Review-Exemption", "Knowledge Is Forged at Distill"
3. config-agents.yaml — terminal_isolation config + agent_teams constraint
4. architecture.md — Two-Agent System failure_mode
5. patterns/handoff-design.md — "Cognitive Firewall: Embed Into Existing Flows"

## Phase 1 vs Phase 2 Comparison

| Aspect | Phase 1 (gbrain BM25) | Phase 2 (tad-brain) |
|--------|----------------------|---------------------|
| Found answer | ❌ No | ✅ Yes |
| Cross-document | No | 5 files synthesized |
| Key fix | CLAUDE.md now indexed | Agent reads all sources |
| Citations | None relevant | 5 specific file references |

## Raw Result Quality

Alex judges at Gate 4. Raw answer includes 5-point enumeration with specific failure mode citations and design rationale chain.
