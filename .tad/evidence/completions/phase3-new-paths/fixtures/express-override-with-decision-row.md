# Fixture: *express scope override with mandatory §11 row (P3.1 AC-P3.1-i)
# Purpose: User picked override option; §11 MUST contain a Decision row with reason.
# Gate 2 check: if §11 missing override row → FAIL.

---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: ["src/components"]
skip_knowledge_assessment: yes
---

# Handoff: Toast refactor (Express, override approved)

## 6. Files to Modify (5)
1. `src/components/Toast.tsx`
2. `src/components/Toast.test.tsx`
3. `src/components/ToastProvider.tsx`
4. `src/hooks/useToast.ts`
5. `src/styles/toast.css`

## 9. Acceptance Criteria
- [ ] All 5 files updated with new toast variant API
- [ ] code-reviewer expert review PASS

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | *express scope override | Standard TAD / split handoffs / override single | **OVERRIDE: keep as single *express** | User reason: "5 files are tightly coupled — one toast variant API change touches all 5; splitting would create artificial review boundaries with no review value. Reviewer would see all 5 anyway." |

⚠️ This Decision row is REQUIRED for Gate 2 to pass when *express scope_constraints
override is chosen. Removing this row → Gate 2 FAIL (per AC-P3.1-i fixture).
