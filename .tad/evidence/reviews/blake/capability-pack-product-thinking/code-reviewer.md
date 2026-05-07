# Code Review — capability-pack-product-thinking

**Reviewer**: code-reviewer (sub-agent)
**Date**: 2026-05-07
**Overall**: PASS after P0 + P1 fixes

---

## Findings

### P0 (Resolved)

| # | Issue | File | Resolution |
|---|-------|------|-----------|
| P0-1 | install.sh .gitignore write fired on --global install, could corrupt unrelated repo | install.sh line 145 | Added `[[ "$TARGET_DIR" != "$HOME"* ]]` guard |
| P0-2 | define.md session.json mapping used `selected_variant.reduce` (not object, but integer index) + "inverted" core_assumption undefined | define.md Step 1 mapping table | Fixed to `variants[selected_variant-1].reduce`; added "combined" string case note |

### P1 (Resolved)

| # | Issue | Resolution |
|---|-------|-----------|
| P1-3 | Round 5 search queries too generic | Replaced with specific site: filter queries |
| P1-4 | Round 4 "affirm" phrase breaks adversarial design | Changed to "test the claim" framing |
| P1-5 | Step 7 verdict logic: confidence ≥7 + 1 flaw had no clear verdict | Added explicit rule: flaw downgrades BUILD→PIVOT regardless of confidence |
| P1-6 | shotgun.md competitor search used full paragraph as search placeholder | Changed to keyword-extraction instruction |

### P2 (Resolved)

| # | Issue | Resolution |
|---|-------|-----------|
| P2-7 | software.md Polymarket for software is a stretch | Demoted to fallback note |
| P2-9 | Severity guide vs pressure-test.md "pivot could fix" qualifier mismatch | Aligned fatal-flaws.md severity table |

**Unremediated P2**: P2-8 (tool-registry.md not explicitly referenced in skills) — acceptable, README links to it.
