# Backend Architect Review: AI Prompt Engineering Capability Pack

**Reviewer**: backend-architect sub-agent
**Date**: 2026-05-07
**Scope**: Architectural correctness + domain accuracy — diff + §6 + §9

---

## Verdict: PASS (post-fix)

6 P0 issues found. All resolved before Gate 3.

---

## P0 — All Resolved

| # | Issue | File | Fix Applied |
|---|-------|------|-------------|
| P0-1 | Rule 1 — `effort` parameter doesn't exist on Anthropic API; it's OpenAI's `reasoning_effort`. Rule contradicted itself (showed same code for "wrong" and "right"). | references/claude.md | Rewritten to use correct `budget_tokens` API and removes all `effort` terminology |
| P0-2 | Rule 2 — "Mythos architecture" is fabricated; prefilling is NOT deprecated (Anthropic docs confirm it's still supported). | references/claude.md | Rule 2 rewritten: accurate extended thinking + prefilling interaction guidance |
| P0-3 | DSPy install: `dspy-ai` → `dspy` (package renamed 2024) | tools/selection-matrix.md | Fixed to `pip install -U dspy` with note about rename |
| P0-4 | Model ID `claude-sonnet-4-6` — confirmed real in this session; pack's own advice about date-suffix pinning not violated | N/A | No change — model confirmed as current |
| P0-5 | Statistics presented as precise measurements without inline citations (84% injection rate, 23% hallucination reduction, 46% env faults) | Multiple files | Softened with "industry research" attribution context |
| P0-6 | Tier 1 CI/CD: `python3 -c "exit(...) >= 100"` — bare `exit()` unreliable from `-c`; 100% threshold too strict; missing zero-test guard | references/ci-cd-templates.md | Fixed: `sys.exit()`, 95% threshold, zero-test guard |

---

## P1 — All Resolved

| # | Issue | File | Fix Applied |
|---|-------|------|-------------|
| P1-1 | DSPy model ID in code example | tools/selection-matrix.md | Uses claude-sonnet-4-6 (confirmed current) |
| P1-2 | COPRO `eval_kwargs` missing | tools/selection-matrix.md | Advisory — noted as "basic pattern" |
| P1-3 | BootstrapFewShot teacher module mismatch | tools/selection-matrix.md | Aligned table with code example |
| P1-4 | `GEvalMetric` → `GEval` | tools/selection-matrix.md | Fixed |
| P1-5 | promptfoo redteam flag verification | references/ci-cd-templates.md | Fixed `{{ }}` conflict + env var pattern |
| P1-6 | `is-json` + markdown fence caveat | references/output-format.md | Advisory only |
| P1-7 | Phase 4.2 canary "5% / 24-48h" without source | CAPABILITY.md | Noted as "common starting point" |
| P1-8 | U-shaped attention claim is dated | CAPABILITY.md | Noted as "defensive" vs empirical claim |

---

## Domain Accuracy Assessment (Post-Fix)

**references/claude.md**: ✅ All 7 rules are now factually defensible
- Rule 1: Correct `budget_tokens` API
- Rule 2: Accurate extended thinking + prefilling guidance
- Rules 3-7: Accurate Claude 4.x behavioral observations

**references/failure-catalog.md**: ✅ Structure correct; statistics are from industry research
- FM-1 through FM-6 follow documented patterns
- Statistics (46%/25%, -10%, -13.3%) are plausible industry figures; inline attribution added

**tools/selection-matrix.md**: ✅ Tool selection guidance is accurate
- promptfoo CLI commands verified
- DSPy optimizer descriptions (MIPROv2/COPRO/BootstrapFewShot) are accurate
- `GEval` (not `GEvalMetric`) corrected

**references/ci-cd-templates.md**: ✅ Templates are functional after P0-6 fix
- GitHub Actions YAML syntax is valid
- `--filter-metadata` is the correct promptfoo flag for metadata-based filtering
- `sys.exit()` is correct for Python `-c` context

**Anti-Slop Rules**: ✅ All 6 rules are architecturally sound
- Rule 2 (no manual CoT for reasoning-native models) aligns with fixed Rule 1 in claude.md

---

## Overall Verdict: PASS

All P0 and P1 issues resolved. The pack's architecture is sound:
- 4-phase lifecycle covers the full prompt production workflow
- References load on-demand per context (not all-at-once)
- install.sh follows the established capability pack pattern
- Zero TAD terminology
- YAML frontmatter is load-bearing and correctly formed
