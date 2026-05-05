# Epic: Security Domain Pack Chain — 5-Pack Security Coverage

**Epic ID**: EPIC-20260403-security-domain-pack-chain
**Created**: 2026-04-03
**Owner**: Alex

---

## Objective

Build 5 security Domain Packs (supply-chain-security, code-security, ai-security, compliance, security-monitoring) that provide systematic security coverage across all TAD-managed projects. Packs are cross-domain (not tied to Web/Mobile/AI/HW) with ecosystem-adaptive tool_ref. Integrates with existing security-auditor subagent and Gate 3 flow.

## Success Criteria
- [ ] 5 Domain Pack YAML files created in .tad/domains/
- [ ] tools-registry.yaml updated with all security CLI tools (est. 15-20 new tools)
- [ ] Each pack has 5-7 capabilities with research-backed workflow steps
- [ ] Cross-domain design: tool_ref adapts to npm/pip/cargo/go ecosystems
- [ ] E2E validation: simulated vulnerable project + real project audit
- [ ] DOMAIN-PACK-ROADMAP.md Phase 5 updated to reflect completion
- [ ] Integration: security-auditor can reference pack checklists

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Security Tool Research | ✅ Done | HANDOFF-20260403-security-tool-research.md | 6 research files, 40 tools, 25 capabilities (commit e2c325a) |
| 1 | Core Packs: supply-chain + code-security | ✅ Done | HANDOFF-20260404-security-core-packs.md | supply-chain 644L + code-security 881L + 24 tools (commit 39e8017) |
| 2 | Specialized Packs: ai-security + compliance | ⬚ Planned | — | 2 YAML packs + tools-registry updates |
| 3 | Monitoring + TAD Integration | ⬚ Planned | — | security-monitoring pack + security-auditor integration |
| 4 | E2E Validation | ⬚ Planned | — | Simulated vuln project audit + real project audit |

### Phase Dependencies
- Phase 0 → Phase 1 (research informs tool selection and capability design)
- Phase 1 → Phase 2 (core packs establish patterns for specialized packs)
- Phase 1+2 → Phase 3 (monitoring references all other packs; integration requires packs to exist)
- Phase 1+2+3 → Phase 4 (E2E tests all 5 packs)

### Derived Status
- **Status**: Paused (Phase 0+1 done, awaiting real-project validation before Phase 2)
- **Progress**: 2/5

---

## Context for Next Phase

### Completed Work Summary
- Phase 0: Security Tool Research — 1,986 lines across 6 files. 40 tools evaluated, 25 capabilities designed.
- Phase 1: Core Packs — supply-chain-security.yaml (644L, 5 caps) + code-security.yaml (881L, 5 caps) + 24 tools in registry (+369 lines). Commit 39e8017.

### Decisions Made So Far
- Cross-domain design: 通用 Pack + 生态变体 (tool_ref adapts to npm/pip/cargo/go)
- Integration: 独立工具 + 流程集成 (packs work standalone AND feed into Gate/security-auditor)
- Phase grouping: Core (supply-chain + code) → Specialized (ai + compliance) → Monitoring + Integration → E2E
- Research depth: Personal experience (litellm event) as seed + GitHub/OWASP research expansion
- Validation: Simulated vulnerable project + real project audit combined

### Known Issues / Carry-forward
- AI Security tools are the most immature (Garak + Promptfoo cover ~70% of OWASP LLM Top 10)
- Compliance CLI tools are scarce (Drata/Vanta are SaaS-only; Fides is the only CLI privacy tool)
- Existing security-audit SKILL.md already has P0-P3 checklist — new packs deepen, not replace
- web-deployment pack already has security_hardening capability — avoid overlap

### Next Phase Scope
⏸️ PAUSED — Run a real-project security audit using the 2 completed packs before deciding on Phase 2.
Resume criteria: User runs supply-chain + code-security audit on an actual project and confirms the packs provide meaningful value beyond generic checklists.
If value confirmed → Phase 2 (ai-security + compliance).
If value insufficient → Evaluate whether to iterate on Phase 1 packs or deprioritize Phase 2-4.

---

## Notes
- This is Phase 5 of the overall DOMAIN-PACK-ROADMAP.md
- User's litellm 1.82.7/1.82.8 poisoning experience (2026-03-24) is a key reference for supply-chain-security
- Architecture knowledge: "Domain Pack Research: Workflow Steps > Quality Criteria Text" (2026-04-03) — prioritize new steps with tool_ref over text-only criteria
