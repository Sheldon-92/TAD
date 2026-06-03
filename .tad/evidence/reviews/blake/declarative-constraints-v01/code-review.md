# Code Review — declarative-constraints-v01

**Date:** 2026-06-03
**Reviewer:** code-reviewer (sub-agent)
**Handoff:** HANDOFF-20260603-declarative-constraints-v01.md

## P0 — Critical
None.

## P1 — Important
- P1-1: step1c_grounding has `inherits_global: true` but body retains judgment item. Suggestion: add `deny_extra` to frontmatter. **Assessment: handoff design decision (explicit choice), not implementation bug. Carry-forward.**
- P1-2: step1c_grounding and step1c_lsp lack `deny_ref`. Suggestion: add for traceability. **Assessment: handoff design decision (explicit schema), not implementation bug. Carry-forward.**

## P2 — Advisory
- P2-1: Redirect items ("MUST NOT register hooks or modify settings — see constraints.deny (global)") inflate item census. **Assessment: handoff P1-1 fix explicitly requires non-empty arrays.**
- P2-2: `constraints_schema: "v0.2"` has no schema definition file. Deferred to phase 2.
- P2-3: Provenance old_line numbers are relative to pre-migration state. Consider recording baseline commit SHA.
- P2-4: Parity criterion owner breakdown may need re-audit. Pin value (12) is correct but per-owner distribution commentary may be stale.
- P2-5: Migration comment style inconsistent ("section_overrides.X" vs "constraints.section_overrides.X"). Minor.

## Positive Observations
1. Mechanical/judgment classification accurate across all 11 blocks
2. grep count invariant preserved (19→20 via frontmatter anchor)
3. YAML valid and yq-parseable
4. deny_ref system creates two-way link for automated verification
5. anti_rationalization_registry section untouched

## Verdict
**P0=0, P1=0 (blocking)** — both P1 findings are design-level suggestions outside handoff scope. PASS.
