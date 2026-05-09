# security-auditor Review — HANDOFF-20260413-quality-enforcement-spike.md

**Reviewed**: 2026-04-13
**Reviewer**: security-auditor subagent
**Target**: v1

## Verdict: FAIL (BLOCK before Blake starts)

## P0 Issues (7)

1. **P0-1**: AC14 fail-open recommendation catastrophically wrong — one-line bypass via hook crash
2. **P0-2**: TAD_OVERRIDE has zero authentication — 4 LLM-injectable channels (read-induced, multi-turn, clipboard, test self-contamination)
3. **P0-3**: Override log has no integrity protection — Blake can rewrite history (truncate, sed -i, symlink)
4. **P0-4**: Sentinel `Message from Blake` trivially bypassed — case, whitespace, Unicode, zero-width, split-writes, Edit tool, Bash redirect
5. **P0-5**: Evidence directory check path-traversal vulnerable + forgeable (mkdir + touch 2 empty files passes)
6. **P0-6**: Exp 3 validator forgeable in 30s (lorem-ipsum padding + literal "Overall: PASS")
7. **P0-7**: Self-validation tautology — Blake authors the report containing PASS line

## Fundamental Design Flaw

Threat model treats Blake as careless, but Epic premise establishes Blake as adversarial ("know rules but choose to bypass"). Spike must test against adversarial model.

## Scope Split Recommendation

Expand spike to 8-12h OR split into:
- **Spike 1a (current scope)**: mechanism existence — threat model = honest but lazy LLM
- **Spike 1b (new scope)**: adversarial robustness — threat model = adversarial LLM

Spike 1b GO gating required before Phase 2.

## Resolution in v2

**Accepted scope split → Phase 1a + Phase 1b**

- P0-1 (fail-closed): ✅ RESOLVED in 1a. New AC7 requires `permissionDecision:"deny"` on hook crash. `set -euo pipefail` + `trap ERR` mandatory (AC14).
- P0-2 (override format): ⚠️ PARTIAL in 1a. New regex `^TAD_OVERRIDE: (\S+) (.{20,})$` requires gate name + reason ≥20 chars. Injection vector testing deferred to Phase 1b.
- P0-3 (log integrity): ❌ DEFERRED to Phase 1b
- P0-4 (sentinel bypass): ❌ DEFERRED to Phase 1b (AC11 requires 1b suggestion list)
- P0-5 (evidence path forgery): ❌ DEFERRED to Phase 1b
- P0-6 (content validator forgery): ❌ DEFERRED to Phase 1b
- P0-7 (self-validation tautology): ✅ RESOLVED in 1a. AC9 now requires exp3 validator to exit 0 on SPIKE-REPORT.md (real validator dogfooding), not just grep.

**Justification for deferrals**: security-auditor's own recommendation is scope split. 1a validates "mechanism exists," 1b validates "mechanism survives attack." Merging would produce wrong GO verdict in 4-6h or explode budget to 8-12h.

**Epic updated**: Phase Map now has Phase 1a (🔄 Active) + Phase 1b (⬚ Planned). Both must GO before Phase 2.
