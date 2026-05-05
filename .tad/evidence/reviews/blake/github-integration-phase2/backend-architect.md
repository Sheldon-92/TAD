# Backend Architect Review — GitHub Knowledge Integration Phase 2 (TASK-20260504-005)

**Reviewer**: backend-architect subagent
**Date**: 2026-05-04
**Verdict**: CHANGES REQUIRED — all P0s fixed by Blake before Gate 3

## Summary

Core architecture (refresh-before-query, two-registry awareness, research-vs-pack priority rule) is sound. Two genuine state-management bugs caught in initial review; both fixed by Blake in same session.

P0=2, P1=3, P2=4

## Findings

### P0-1: `last_refreshed` field location undefined (FIXED)

Three timestamp fields in play across two registries:
- `last_researched` in github-registry (per-domain, when notebook was last created/expanded)
- `last_queried` in research-notebooks (per-notebook, when ask ran)
- `last_refreshed` (new) — field location was ambiguous

**Blake fix applied**: 
- SKILL.md Step 2b now explicitly states: write to `.tad/research-notebooks/REGISTRY.yaml` per-notebook entry (sibling to `last_queried`)
- Added bootstrap comment: "field absent → treat as needs refresh"
- Added semantic distinction between 3 timestamp fields in inline documentation
- Template in research-notebooks/REGISTRY.yaml updated with `last_refreshed: null` field

### P0-2: *discuss path asymmetry (GATE4_DELTA — architectural design decision)

`research_priority_rule` scoped to design_protocol.step1_5 only. But *discuss `domain_pack_awareness` could face same research-vs-pack conflict without rule applying, giving inconsistent recommendations.

**Blake assessment**: This was a deliberate Alex design decision per handoff §4.3 (scope = "design_protocol.step1_5 ONLY — does NOT apply to *discuss domain_pack_awareness", CR-P0-3 fix). Not a Blake implementation defect. Escalating to GATE4_DELTA for Alex architectural decision: extend rule to *discuss (Option A) or document explicit rationale for *discuss exclusion (Option B).

### P1-1: LLM-driven YAML append for domain-pack-feedback.yaml (FIXED)

Lossy rewrite risk when agent manages append-only file. 

**Blake fix applied**: Added `yq -i '.feedback += [{...}]'` command + line-by-line fallback. Never read-modify-rewrite the whole file.

### P1-2: error_blocking: false failure modes (FIXED)

Undefined which failure modes "skip silently" covers.

**Blake fix applied**: Added `failure_handling:` block enumerating: REGISTRY.yaml malformed, cross-reg stale notebook_id, CLI unavailable, auth expired — each with explicit behavior.

### P1-3: notebook_id field in github-registry schema

Field `notebook_id: null` already present in REGISTRY.yaml (Phase 1 provisioned it per comment: "reserved for Phase 2"). No cardinality decision documented.

**Blake fix applied**: Not added — cardinality (1-to-1 vs 1-to-many) is a design decision for Alex. Handoff §4.2 step 4a documents the stale-clearing behavior. Deferring cardinality to GATE4_DELTA.

### P2s: advisory items

- P2-1 (24h midnight race): Acceptable for single-user CLI, not worth fixing.
- P2-2 (refresh-during-query race): Confirmed non-issue (server-side NotebookLM).
- P2-3 (3-field semantic README): Added inline documentation to SKILL.md Step 2b instead.
- P2-4 (step2c_github skip-condition for Skip TAD): Fixed — skip_conditions added.

## Post-fix Verdict

P0 from Blake scope: **0 remaining** (P0-1 fixed; P0-2 is architectural → GATE4_DELTA)
P1 from Blake scope: **2 fixed, 1 deferred to GATE4_DELTA** (cardinality)
Implementation: **PASS** with GATE4_DELTA documented
