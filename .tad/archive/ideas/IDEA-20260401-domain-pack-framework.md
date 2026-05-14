---
title: Domain Pack Framework — Extensible Domain Support for TAD
date: 2026-04-01
status: promoted
scope: large
---

## Summary & Problem

TAD is currently a software-development-only framework. Users want to apply TAD's quality process (Alex→Handoff→Blake→Gates) to other domains: hardware product design, game development, industrial design, legal consulting, financial analysis, etc.

The core insight: Claude already HAS domain knowledge. What's missing is the ability to ACT in a domain — the right tools, workflow, standards, and verification.

## Proposed Solution

**Domain Pack** = a YAML configuration file that provides domain-specific phases, each with tools, workflow, standards, and review criteria. NOT a knowledge base.

**Architecture**:
- Domain Pack = "phase library" — each pack provides phases that can be composed into Epics
- Cross-domain projects compose phases from multiple packs
- TAD Core (Alex/Blake/Gates/Epic) is unchanged — Domain Pack only changes WHAT happens inside each phase
- Loading via SessionStart hook (domain detection) + on-demand YAML reading

**Key Design Principles** (validated through discussion + expert review):
1. Context not Constraint: Provide domain context, NOT persona limitations during execution
2. Tools + Workflow + Standards + Verification > Knowledge injection
3. Review phase uses Persona + Checklist (hybrid) — implemented as Skill(fork, Haiku) + PostToolUse hook
4. CLI-first tools (MCP only for stateful/remote)
5. Phase libraries are composable across domains

**Schema (per phase)**:
```yaml
phases:
  phase-name:
    tools: [{name, install, verify}]
    output: {files, deliverable}
    verify: {automated: [{cmd, expect}], manual: [checklist]}
    socratic: [Alex questions for this phase]
    reviewers: [{persona, checklist}]  # → implemented as Skill(fork) + Hook
```

## Open Questions

- Which domain to build first as PoC?
- How to handle domain YAML growing too large (500+ lines)?
- Phase dependency/input contracts (inter-phase data flow)
- Context budget management when multiple packs loaded
- Tool namespace conflicts across domains

## Expert Review Summary

- Product: Architecture right, validate with real project first. Lead with "quality gates for any domain."
- Architect: Map reviewers to Skill/Hook execution. Use SessionStart for detection. Watch context budget.
- Both: CLI-first is reasonable given industry trend toward CLI tools.

## Implementation Plan

Two-phase Epic:
1. Framework: domain.yaml schema, loading mechanism, TAD integration (hooks + Alex/Blake behavior)
2. First Pack: One complete domain.yaml + integration test

## Promoted To

(Not yet promoted — awaiting Epic creation)
