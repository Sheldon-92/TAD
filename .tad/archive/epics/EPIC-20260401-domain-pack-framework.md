# Epic: Domain Pack Framework — Extensible Domain Support

**Epic ID**: EPIC-20260401-domain-pack-framework
**Created**: 2026-04-01
**Owner**: Alex

---

## Objective

Build the Domain Pack framework that enables TAD to work in any professional domain (not just software development). Domain Packs are YAML configurations that define domain-specific capabilities, tools, workflows, standards, and review criteria. First pack: Product Definition.

## Success Criteria
- [ ] tools-registry.yaml created with ≥10 tools (install + usage + example for each)
- [ ] product-definition.yaml rewritten with real tool chains (referencing registry)
- [ ] TAD integration: Alex can load a Domain Pack and adjust behavior (socratic dimensions, gate criteria)
- [ ] End-to-end test: run one capability from Product Definition pack using real tools
- [ ] Documentation: how to create a new Domain Pack

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Tool Research | ✅ Done | HANDOFF-20260401-domain-pack-tool-research.md | 6 area reports + SUMMARY, 10 tools in 3 tiers |
| 1 | Implementation | ✅ Done | HANDOFF-20260401-domain-pack-implementation.md | registry 11 tools + product-def rewrite + hook detection + E2E test |
| 2 | Validation | ✅ Done | HANDOFF-20260401-domain-pack-loading-fix.md | Hook fix + self-test 10/10 PASS + Sober Creator synced |

### Phase Dependencies
- Phase 0 → Phase 1 (tool research informs registry and pack content)
- Phase 1 → Phase 2 (implementation before validation)

### Derived Status
- **Status**: In Progress (Phase 0 done)
- **Progress**: 1/3

---

## Context for Next Phase

### Completed Work Summary
- Phase 0: Tool research — 20+ tools evaluated, 5 tested, 10 recommended in 3 tiers

### Decisions Made So Far
- Domain Pack = capabilities + tool references + workflow + standards + reviewers
- Tools registry separate from domain packs (shared, maintainable)
- CLI-first (7/10 recommended tools are CLI)
- Capability menu model (not fixed linear phases)
- No persona constraints during execution, persona+checklist for review
- Context not constraint: provide domain context, not knowledge limitations
- Tool details must be complete enough for Claude to use unknown tools

### Known Issues / Carry-forward
- Figma MCP free = 6 uses/month (design tooling gap)
- Mermaid CLI fails in sandbox (use D2 instead)
- tools-registry.yaml not yet created (Phase 1 deliverable)
- product-definition.yaml exists as draft (needs rewrite with real tools)

### Next Phase Scope
Phase 1: Create tools-registry.yaml + rewrite product-definition.yaml + Alex integration logic
