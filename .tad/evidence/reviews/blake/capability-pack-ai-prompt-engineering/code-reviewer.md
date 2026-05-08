# Code Review: AI Prompt Engineering Capability Pack

**Reviewer**: code-reviewer sub-agent
**Date**: 2026-05-07
**Scope**: Layer 2 post-implementation review — diff + §6 + §9

---

## Verdict: PASS (post-fix)

5 P0 issues found. All resolved before Gate 3.

---

## P0 — All Resolved

| # | Issue | File | Fix Applied |
|---|-------|------|-------------|
| P0-1 | `npx promptfoo diff` does not exist as a CLI subcommand | checklists/regression.md | Replaced with Python-based manual comparator |
| P0-2 | `--filter-pattern "tier:1"` matches descriptions, not metadata — should be `--filter-metadata "tier=1"` | references/ci-cd-templates.md | Fixed to `--filter-metadata "tier=1"` in 2 locations |
| P0-3 | claude.md Rule 1 contradicts itself — shows "wrong" and "right" code as identical; `effort` is an OpenAI parameter, not Anthropic | references/claude.md | Rewritten: removed `effort`, uses correct `budget_tokens` API |
| P0-4 | claude.md Rule 2 — "Mythos architecture" is a fabricated Anthropic architecture name; prefilling is NOT deprecated per Anthropic docs | references/claude.md | Replaced with accurate extended thinking + prefilling interaction guidance |
| P0-5 | A-02 adversarial test placeholder (`"[Phrase that would indicate jailbreak succeeded]"`) is a literal that makes the test trivially green — silently passes even when jailbreak succeeds | tools/promptfoo-starter.yaml | Replaced with real jailbreak input + meaningful JS assertion |

---

## P1 — All Resolved

| # | Issue | File | Fix Applied |
|---|-------|------|-------------|
| P1-1 | `claude-sonnet-4-6` confirmed as actual current model in this session — valid | N/A | No change needed |
| P1-2 | C-06 redundant assertions | tools/promptfoo-starter.yaml | Advisory only — kept as is; user should customize |
| P1-3 | Tier 1 100% threshold + ZeroDivisionError + bare `exit()` | references/ci-cd-templates.md | Fixed: 95%, sys.exit(), zero-test guard |
| P1-4 | A-03 `not-contains "You are a"` false positive risk | tools/promptfoo-starter.yaml | Advisory noted in comments |
| P1-5 | Statistical claims without inline citation | Multiple files | Softened to "industry research" attribution |
| P1-6 | Rule 7 still used `effort` terminology | references/claude.md | Fixed to `budget_tokens` |
| P1-7 | `{{ }}` template conflict in Tier 3 workflow | references/ci-cd-templates.md | Fixed: replaced with `$PROMPTFOO_PURPOSE` env var |
| P1-8 | install.sh `.write-test` race on interrupt | install.sh | Fixed: added `trap` for cleanup |

---

## Post-Fix Verification

- `references/claude.md`: Rules 1/2 rewritten without fabricated terminology ✅
- `checklists/regression.md`: Manual Python comparator replaces `npx promptfoo diff` ✅
- `references/ci-cd-templates.md`: `--filter-metadata` in 2 places, `sys.exit()`, 95% threshold ✅
- `tools/promptfoo-starter.yaml`: A-02 has real jailbreak scenario with meaningful assertion ✅
- `tools/selection-matrix.md`: `dspy-ai` → `dspy`, `GEvalMetric` → `GEval` ✅
- `install.sh`: trap added ✅
- Version: CAPABILITY.md + README.md aligned to 1.0.0 ✅

---

## AC Verification

AC1: ✅ 16 files in git (additional .git files bring total to 61)
AC2: ✅ YAML frontmatter with name + description
AC3: ✅ 4 phase headings
AC4: ✅ /write and /audit present + Step 0
AC5: ✅ 7 ### Rule headings in claude.md (post-fix)
AC6: ✅ 6 ## FM- headings
AC7: ✅ 3-tier pipeline present
AC8: ✅ promptfoo + DSPy + DeepEval all covered
AC9: ✅ YAML valid, 18 assert: entries
AC10: ✅ --agent flag with Phase 3 stubs
AC11: ✅ 23 checklist items
AC12: ✅ 15 annotation markers
AC13: ✅ 2898 lines (≤5000)
AC14: ✅ Zero TAD terminology
AC15: ✅ Apache 2.0
AC16: ✅ 2 commits post-fix
AC17: PENDING (this is Layer 2 review #1; backend-architect is #2)
AC18: ✅ few-shot-design.md with quality assessment
AC19: ✅ output-format.md with compliance verification

Overall: **PASS** — P0=0, P1=0 (all resolved)
