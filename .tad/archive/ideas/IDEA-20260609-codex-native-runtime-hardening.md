# Idea: Codex Native Runtime Hardening

**Created:** 2026-06-09
**Status:** promoted
**Priority:** P1 after EPIC-20260609-skill-body-reference-boundary
**Source:** Codex review of TAD v2.26 cross-platform unification
**Promoted to:** EPIC-20260609-dual-platform-native-runtime-architecture

---

## Summary

After the P0 SKILL body/reference quality-chain fix lands, harden TAD's Codex runtime by adopting Codex-native project configuration and agent primitives instead of relying only on `.agents/skills/` plus `AGENTS.md`.

## Why

TAD v2.26 made Codex a first-class platform at the skill-loading layer, but it does not yet fully use Codex-native capabilities:
- no project-level `.codex/config.toml` policy
- no `.codex/agents/` custom agents for reviewers/specialists
- no explicit Codex native `review`, MCP, Cloud task, profile, approval, or sandbox strategy
- limited automated regression coverage beyond activation/dogfood runs

## Candidate Epic: Codex Native Runtime Hardening

### Phase 1: Config Policy
- Design `.codex/config.toml` strategy for TAD projects.
- Decide which settings are project-owned vs user-owned.
- Cover hooks enablement, sandbox, approval policy, profiles, and strict-config behavior.
- Preserve user secrets and auth outside the project.

### Phase 2: Codex Custom Agents
- Evaluate `.codex/agents/` for `code-reviewer`, `backend-architect`, `testing-reviewer`, and possibly `Blake`.
- Compare custom agents vs skills-only behavior.
- Define permission boundaries and prompt loading rules.

### Phase 3: Native Tooling Integration
- Evaluate Codex `review` for Layer 2 code review.
- Evaluate Codex MCP registration strategy.
- Decide whether Codex Cloud tasks belong in TAD's execution model or only as optional offload.

### Phase 4: Regression Harness
- Build repeatable Codex regression suite:
  `$alex activation → handoff → $blake implementation → Gate 3 → Gate 4 → trace/evidence`.
- Run n=3 stability checks before claiming platform parity.
- Store evidence under `.tad/evidence/codex-regression/`.

## Relationship to Current P0 Epic

Do not start this until `EPIC-20260609-skill-body-reference-boundary` is accepted. That Epic fixes the quality chain. This idea upgrades Codex-native platform depth after the chain is reliable again.

## Promotion Trigger

Promote to active Epic after:
- v2.27.0 body/reference fix is released and synced
- Codex full-cycle regression passes at least once
- active Epic count allows another Epic without exceeding TAD concurrency policy
