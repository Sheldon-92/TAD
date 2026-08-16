# IDEA: MECE Rubric for TAD Quality Gates

**Created**: 2026-06-23
**Source**: AI Tinkerers #32 — SPEAR framework by Ryan Waliany
**Status**: promoted
**Promoted To**: Epic phase (Community Pattern Adoption — 2026-06-23)
**Scope**: medium (Gate checklist redesign)

## What

Restructure TAD's Gate checklists to be MECE (Mutually Exclusive, Collectively Exhaustive), inspired by SPEAR's Assess phase. Current Gate items may overlap (not mutually exclusive) and may miss dimensions (not collectively exhaustive).

## Why

SPEAR uses a single MECE rubric with binary 10/10 pass/fail. When any item fails, execution loops back to Plan with a narrowed scope targeting that specific gap. This is more structured than TAD's current checklist approach where items can overlap and the "what to fix" signal is less precise.

## How it might work

1. Audit Gate 1-4 checklists for overlapping items (merge or split)
2. Check for missing dimensions (exhaustiveness gap analysis)
3. Each item becomes independently scorable — failure points to exactly one remediation path
4. Consider: should Gate failure narrow the retry scope (SPEAR pattern) vs. current "fix all then re-gate"?

## Evidence

- SPEAR article: https://www.edge.ceo/p/introducing-spear-the-management
- Decision brief: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-decision-brief-community-orchestration.md

## Risk

- Over-structuring Gates could add ceremony without value
- TAD's 4-gate separation already provides some MECE (each gate checks different phase)
- Need to distinguish: is the problem overlapping items WITHIN a gate, or across gates?
