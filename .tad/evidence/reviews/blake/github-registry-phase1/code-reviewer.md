# Code Review — github-registry-phase1
**Reviewer**: code-reviewer subagent
**Date**: 2026-05-04
**Task**: TASK-20260504-004

## Round 1 Findings (2 P0, 0 P1, 4 P2)

| Severity | ID | Description | Status |
|----------|----|-------------|--------|
| P0 | CR-P0-1 | `gh api` calls in `add` command used camelCase (`.stargazersCount`, `.fullName`) — GitHub REST API is snake_case (`.stargazers_count`, `.full_name`). Silent null result at runtime. | Fixed |
| P0 | CR-P0-2 | `notebook` Step 4 used `gh api .../contents/` which only returns ROOT-level entries. Subdirectory paths (docs/*.md, src/index.*) are inaccessible. Fixed to recursive tree API `git/trees/{branch}?recursive=1`. | Fixed |
| P2 | CR-P2-1 | Version check `awk '{print $NF}'` fragile if output format changes. Advisory — acceptable for v0.3.4. | Noted |
| P2 | CR-P2-2 | Explore Step 4 fallback text implies second API call rather than reusing Step 2 raw markdown. Advisory. | Noted |
| P2 | CR-P2-3 | `created_by` field in research-notebooks REGISTRY is an extension field. No circular dependency risk — YAML accepts unknown fields gracefully. | Noted |
| P2 | CR-P2-4 | "book lists" in REGISTRY description is literal translation artifact from 书单. Advisory. | Noted |

## Verified Spec Items (All PASS)
- Absolute notebooklm path: ✅
- `Accept: application/vnd.github.raw+json` header: ✅
- `notebooklm create` first, then `-n <id>`: ✅
- `--type text` for code files: ✅
- `default_branch` queried via gh api (not hardcoded 'main'): ✅
- Source limit check (>50): ✅
- Both registries updated: ✅
- DovAmir/awesome-design-patterns in Architecture only (per BA-P1-2): ✅
- REGISTRY.yaml: 24 domains, 50 entries, all schema fields valid: ✅

## Round 2 Verdict
After P0 fixes applied: P0=0, P1=0 → **PASS**
