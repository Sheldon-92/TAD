# Fixture: *express handoff EXCEEDING 3-file limit (P3.1 AC-P3.1-c)
# Purpose: Verify scope_constraints.over_limit_action triggers AskUserQuestion with 3 options.
#
# Expected behavior:
#   1. Alex detects file_count_max=3 violated (5 files in §6)
#   2. Alex MUST present AskUserQuestion with 3 options:
#      - "降到 Standard TAD (Recommended for >3 files)"
#      - "拆成多个 *express handoffs (each ≤3 files)"
#      - "我理解但坚持 *express 单 handoff (override — 解释原因)"
#   3. If user chooses override → §11 MUST contain a Decision row with user reason
#   4. Gate 2 verifies §11 has the override row; missing → Gate 2 FAIL

---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: ["src/components"]
skip_knowledge_assessment: yes
---

# Handoff: Refactor Toast notification (Express, OVER LIMIT)

**Type**: *express (user typed `*express`, but file count exceeds limit)

## 6. Files to Modify (5 — EXCEEDS *express limit)
1. `src/components/Toast.tsx`
2. `src/components/Toast.test.tsx`
3. `src/components/ToastProvider.tsx`
4. `src/hooks/useToast.ts`
5. `src/styles/toast.css`

## Expected Alex behavior at this point
[Alex pauses and runs AskUserQuestion per scope_constraints.over_limit_action]

— END OF FIXTURE —
The handoff would not normally proceed past §6 in the unmodified state.
This file documents the EXPECTED warning path, not a saved handoff.
