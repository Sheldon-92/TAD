# Architecture Review: LSP Code Understanding Integration

**Reviewer:** backend-architect (Layer 2)
**Date:** 2026-05-14
**Handoff:** HANDOFF-20260514-lsp-code-understanding.md

## Verdict: PASS (after P0 fixes)

2 P0 found and resolved. 4 P1 (3 resolved, 1 confirmed correct). 4 P2 advisory.

## P0 Findings (all resolved)

### P0-1: 1_5c exit path bypasses 1_5d for non-research tasks (Stale Transition Arrow)
- **File:** blake/SKILL.md line 575
- **Issue:** `proceed to 1_6_tdd_check` written before 1_5d existed — skips blast radius for ALL non-research tasks
- **Resolution:** Changed to `proceed to 1_5d_lsp_blast_radius`
- **Pattern:** Same class as architecture.md "Protocol State-Machine Design" (2026-05-02)

### P0-2: Blake inlines provision protocol — semantic drift risk
- **File:** blake/SKILL.md lines 643-651
- **Issue:** Inline 5-sub-step summary already subtly different from canonical (missing retry step)
- **Resolution:** Replaced with cross-reference: "Follow lsp_provision_protocol per Alex SKILL"

## P1 Findings

### P1-1: lsp-language-map.yaml belongs in .tad/guides/ — CONFIRMED CORRECT
- No change needed. Lookup table consumed on-demand, not framework config.

### P1-2: Alex step1c_lsp auto-modifies §6 without user confirmation for large scope changes
- Noted for future enhancement. Current behavior acceptable for v1 (Alex owns scope).

### P1-3: No compact_recovery on Alex step1c_lsp
- **Resolution:** Added compact_recovery field (idempotent re-run safe)

### P1-4: Single-language limitation undocumented
- **Resolution:** Added known_limitations field to Alex step1c_lsp

## P2 Findings (advisory)
- P2-1: Tool quick reference sections byte-identical (correct)
- P2-2: forbidden_implementations correctly asymmetric between agents
- P2-3: step1d trigger text correctly updated
- P2-4: Emoji usage consistent with existing Blake patterns
