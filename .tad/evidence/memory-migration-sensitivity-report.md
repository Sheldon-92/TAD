# Memory Migration Sensitivity Report — TASK-20260712-001 (SEC P0-1)

**Date:** 2026-07-12
**Scope:** 36 files migrated from `~/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD/memory/` → `.tad/memory/`
**Repo visibility:** PUBLIC (github.com/Sheldon-92/TAD)
**Classification rules (from HANDOFF-20260712 §6 T3a, conservative — 宁多勿漏):**
R1 `metadata.type: user` → SENSITIVE | R2 email/API-key/token/password/privacy content → SENSITIVE | R3 unpublished product strategy or third-party leaked-material analysis → SENSITIVE | R4 else SAFE

**Mechanical scan:** `grep -lEi '@[a-z0-9.-]+\.(edu|com|org)|api[_-]?key|token|password'` hit 4 files — all verified FALSE POSITIVES on inspection ("token cost" / "header-token" CSP design term / "token-burn" / LLM-token counts; no credentials, no emails). Email-specific sweep (`newschool|zhaos948|@gmail|@outlook`): zero hits.

⚠️ Gate 4 human review item: verify the 7 SENSITIVE classifications and the 29 SAFE calls before any *publish (push is out of scope for this handoff).

| # | File | Frontmatter type | Class | Reason |
|---|------|------------------|-------|--------|
| 1 | MEMORY.md | (none — native ledger) | SENSITIVE | Index hooks embed user-profile summary, co-thinking-workshop seed core idea, and leaked-source-analysis reference; ledger auto-absorbs future one-liners with no re-triage (R1/R3 by content) |
| 2 | feedback_alex-no-code-violation.md | feedback | SAFE | TAD process violation record, framework-internal |
| 3 | feedback_cli-first-tool-design.md | (none) | SAFE | Tool design preference, framework-internal |
| 4 | feedback_execution-review-separation.md | (none) | SAFE | TAD workflow rule |
| 5 | feedback_no-sync-pull-based.md | feedback | SAFE | TAD release mechanics |
| 6 | feedback_pick-generative-directions.md | feedback | SAFE | Work-direction preference, TAD-scoped |
| 7 | feedback_plain-language-after-handoffs.md | (none) | SAFE | TAD communication rule |
| 8 | feedback_plain-language-quality.md | feedback | SAFE | TAD communication rule |
| 9 | feedback_research-before-upgrade.md | feedback | SAFE | TAD methodology lesson |
| 10 | feedback_research-methodology.md | (none) | SAFE | Research sourcing methodology |
| 11 | feedback_share-mode-and-deflation.md | feedback | SENSITIVE | Contains verbatim user conversation quotes + user interaction-style profile (R1-adjacent, conservative) |
| 12 | feedback_tool-freshness.md | (none) | SAFE | Tool knowledge observation |
| 13 | feedback_verify-before-delete.md | (none) | SAFE | TAD process rule |
| 14 | feedback_yolo-epic-workflow-args.md | feedback | SAFE | Workflow tool quirk (mechanical grep hit = "args" context, false positive) |
| 15 | project_academic-research-pack.md | (none) | SAFE | Pack build record |
| 16 | project_ai-native-reading-companion.md | project | SAFE | Epic record; grep hit = "header-token" CSP security design term, false positive |
| 17 | project_auto-evolve-epic.md | (none) | SAFE | Epic record |
| 18 | project_capability-packs.md | (none) | SAFE | Pack status; grep hit = "token cost" metric, false positive |
| 19 | project_co-thinking-workshop-seed.md | project | SENSITIVE | Unpublished sibling-product seed idea; user explicitly keeps it OUTSIDE TAD; publishing core in public repo contradicts stated intent (R3) |
| 20 | project_codex-adapter-validation.md | project | SAFE | Validation record |
| 21 | project_domain-pack-design.md | (none) | SAFE | Architecture record |
| 22 | project_dynamic-workflow-epic.md | project | SAFE | Epic record |
| 23 | project_knowledge-recording-redesign.md | project | SAFE | Epic record |
| 24 | project_pack-quality-leveling-epic.md | project | SAFE | Epic record; "朋友" mention is a cross-reference to an idea name, no personal identity |
| 25 | project_quality-chain-failure.md | (none) | SAFE | Incident record, framework-internal |
| 26 | project_research-system-consolidation.md | project | SAFE | Epic record |
| 27 | project_self-evolution-pruning.md | project | SAFE | Epic record |
| 28 | project_surplus-burn-mode.md | project | SAFE | Epic record; grep hit = "token-burn" phrasing, false positive |
| 29 | project_tad-brain-knowledge-search.md | project | SAFE | Epic record |
| 30 | project_tad-evolution-directions.md | (none) | SENSITIVE | Explicitly derived from and references Claude Code LEAKED source analysis (R3) |
| 31 | project_tad-next-direction.md | (none) | SAFE | TAD's own public direction (already reflected in tracked OBJECTIVES/NEXT) |
| 32 | project_tad-universal-method.md | (none) | SENSITIVE | Unpublished standalone-product strategy + personal context about user's friends (R3, conservative) |
| 33 | project_tier1-workflow-formalization.md | project | SAFE | Epic record |
| 34 | project_yolo-audit-findings.md | (none) | SAFE | Audit record; grep hit = "token cost" metric, false positive |
| 35 | reference_claude-code-source.md | reference | SENSITIVE | Third-party leaked-material analysis with local paths to leaked source (R3 — handoff-known candidate) |
| 36 | user_agent-builder-goals.md | user | SENSITIVE | User personal profile (R1); covered by `.tad/memory/user_*` gitignore pattern |

## Summary
- SENSITIVE: 7 (1 via `user_*` pattern + 6 per-file gitignore entries)
- SAFE: 29 (tracked in git)
- Verification: `git check-ignore` = 0 for every SENSITIVE file; tracked memory files contain no credential/email pattern hits (AC10)
