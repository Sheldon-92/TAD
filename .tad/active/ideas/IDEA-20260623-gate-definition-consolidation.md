# IDEA: Gate Definition Consolidation — Single Source of Truth

**Created**: 2026-06-23
**Source**: P2 MECE Gate Restructure expert review findings
**Status**: promoted
**Promoted To**: Epic (via *analyze — 2026-06-23)
**Scope**: large (8+ files need reconciliation)

## What

Establish a single source of truth for Gate 1-4 checklist definitions. Currently Gate checklists are duplicated and inconsistent across 8+ files:
- alex/SKILL.md (Gate 1/2/4 ownership definitions)
- gate/SKILL.md (Gate 1/2/3/4 execution definitions — DIFFERENT items from alex)
- .tad/gates/quality-gate-checklist.md (yet another set)
- .tad/config-quality.yaml (checks: lists)
- blake/SKILL.md (Blake's gate4_v2)
- acceptance-protocol.md (gate4 checklist)
- alex/SKILL.md quick-reference section (Gate 4 v2 Checklist)

## Why

MECE restructuring of Gate checklists is blocked by this structural problem. Any edit to one file's Gate items doesn't propagate to the other 7 files, causing definitions to drift. The P2 expert review found that Gate 1 has 3 COMPLETELY DIFFERENT definitions across 3 files.

## How it might work

1. Choose ONE canonical file for Gate definitions (probably gate/SKILL.md or a new .tad/gates/gate-definitions.yaml)
2. All other files REFERENCE the canonical file instead of duplicating
3. Then MECE restructure the single canonical definition
4. MECE audit results from P2 (preserved as evidence) can be applied directly

## Evidence

- Audit report: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-gate-mece-audit.md
- Code reviewer findings: 4 P0 about scattered definitions
- Backend architect findings: 3 P1 about coverage/signal issues

## Risk

- Large scope — touching 8+ files has high blast radius
- Some files serve different purposes (execution vs ownership) — may legitimately need different items
- Need to determine: is the duplication a bug or a feature? (execution vs ownership distinction)
