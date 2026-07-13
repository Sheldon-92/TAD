---
name: Domain Pack Design Model
description: Complete Domain Pack architecture — tools + workflow + standards + review (persona + checklist). Validated against Claude Code source patterns.
type: project
---

Domain Pack = Action Configuration for any professional domain. NOT a knowledge base.

**Core Model (validated against Claude Code source)**:

```
Execution Layer (做事):
  ① Domain Context — "this project is PCB design" (activates knowledge, no persona constraint)
  ② Tools — CLI/MCP tools the agent can use (kicad-cli, platformio, etc.)
  ③ Workflow — phased process with verification at each step
  ④ Standards — quantitative "done" criteria

Review Layer (检验):
  ⑤ Persona + Checklist — specialized reviewer with explicit check items
     (persona sets direction, checklist ensures completeness)
```

**What's validated by Claude Code source**:
- Tools > Knowledge for enabling action (high confidence)
- Role persona valid, domain persona constrains execution (high confidence)
- Framework enforcement > model self-discipline (high confidence)
- Domain context helpful without persona constraint (medium confidence)

**What's our extrapolation**:
- Domain-specific workflow phases (source only has generic flow)
- Persona + Checklist hybrid for review (source leans toward checklist only)
- Domain Pack as loadable YAML config (our design, not from source)

**Key Principle**: "做事不设限，审查设视角"
- Execution: provide context + tools, NOT persona constraints
- Review: provide persona direction + checklist items

**Minimal Domain Pack structure**:
```yaml
domain.yaml:
  context: "what this domain is about" (1 line)
  tools: [name, actions, verify command]
  workflow: [phases with verify steps]
  standards: [quantitative criteria]
  reviewers: [persona + checklist per gate]
```

**Expert Review Findings (2026-04-01)**:
- Product expert: Architecture right, but validate with real project. CLI assumption challenged (rebutted: CLI trend is clear).
- Architect expert: reviewers need mapping to Skill(fork) or Hook, not raw YAML data. Use SessionStart hook for domain detection. Watch context budget (1% limit for skill listings). Use permissions.deny + hook for phase isolation.
- Both: Don't over-generalize before validating one real domain.

**Architecture corrections from expert review**:
- reviewers.persona → implement as Skill (fork mode, Haiku model)
- reviewers.checklist → inject via PostToolUse hook additionalContext
- tools.install → advisory only, not auto-executed
- Domain detection → SessionStart hook (shell script checks project files)
- Phase dependencies → add `inputs:` field per phase
- Context management → load domain YAML on-demand via hook, not into skill prompt

**Next steps (decided 2026-04-01)**:
1. Build Domain Pack framework (schema + loading mechanism + TAD integration)
2. Create first Domain Pack (domain TBD)
This will be a new Epic.

**Applicable domains discussed**: software product design, hardware product design, game design, industrial design, legal consulting, financial investment, testing & QA.
