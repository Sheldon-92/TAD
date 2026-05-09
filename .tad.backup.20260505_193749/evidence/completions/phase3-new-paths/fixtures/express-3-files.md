# Fixture: *express handoff at the 3-file limit (P3.1 AC-P3.1-a, AC-P3.1-c)
# Purpose: Verify *express scope_constraints.file_count_max = 3 is enforced as upper bound (no warning).

---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: ["src/styles"]
skip_knowledge_assessment: yes
---

# Handoff: Fix typo in welcome banner (Express)

**Type**: *express (user explicitly typed `*express`)
**Files**: 3 (at limit)

## 6. Files to Modify
1. `src/components/WelcomeBanner.tsx` — fix typo "wlcome" → "welcome"
2. `src/components/__tests__/WelcomeBanner.test.tsx` — update assertion
3. `CHANGELOG.md` — add user-visible fix entry

## 9. Acceptance Criteria
- [ ] Typo fixed in 3 places (component + test + changelog)
- [ ] code-reviewer expert review PASS (no P0/P1)
- [ ] Build/test/lint all green

## 10. Audit Trail (P1.5 dogfood — express still includes it)
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | None — straightforward typo fix | N/A | Resolved |

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Express vs Standard | *express (≤3 files) | Single-line typo; no architectural impact |
