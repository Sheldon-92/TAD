# Backend Architect Review — Cross-Model Phase 0 Spikes

**Date**: 2026-05-03
**Reviewer**: backend-architect subagent

## Findings

### P0
- P0-BA: No production code-reviewer baseline for Spike A (comparing two non-incumbents). **FIXED**: production code-reviewer run on same commit; three-way comparison table added to SPIKE-REPORT.

### P1
- P1-BA-1: Quota accounting undefined ("≤20/month" needs counter location, reset boundary, enforcement layer, 19→warn/20→fallback behavior). **FIXED**: Phase 1 architecture spec updated with `.tad/state/codex-image-budget.json`, calendar reset, release-runbook enforcement.
- P1-BA-2: Auth failure mode unspecified for Codex. **FIXED**: Phase 1 architecture spec updated: detect non-zero exit → log + Mermaid fallback → non-blocking.
- P1-BA-3: Regex flavor pinning missing from Spike B retest spec. **FIXED**: Phase 2 retest conditions updated: prompt must specify "POSIX ERE, no lookahead" + grep -E smoke test per regex.
- P1-BA-4: Multi-language retest plan insufficient (no pre-registration, no seeded bugs, no blind scoring). **FIXED**: Retest plan updated with all 4 requirements.

### P2
- P2-BA: Codex stderr noise contract (exit code, not stderr). **ACKNOWLEDGED**: documented in Key Discoveries #4.

## Overall Verdict: PASS (all P0 and P1 fixed)
