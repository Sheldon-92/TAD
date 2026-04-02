# Usability Audit — Todo App

## 1. Artifacts Reviewed
- wireframe.html (B&W wireframe with interactive filtering, add, complete, delete)
- component-showcase.html (design system with 12+ components using design tokens)
- responsive-wireframe.html (4-breakpoint responsive layout)
- design-tokens.css (CSS variables)
- design-tokens.json (token definitions with contrast ratios)

## 2. Automated Accessibility Check (pa11y)

### wireframe.html — 11 errors
All errors are **contrast ratio violations** (2.85:1 where 4.5:1 required):
- `.task-count` text (#999 on #fff)
- `.task-meta` text (#999 on #fff)
- Completed task text (#999 on #fff)
- Inactive bottom nav items (#999 on #fff)
**Fix**: Change wireframe #999 to #767676 (or map to design token --color-text-secondary: #6B7280 which passes at 4.63:1)

### component-showcase.html — 7 errors
- 2x Input fields missing accessible name (label `for` not linked to input `id`)
- 2x Badge default variant contrast 4.39:1 (borderline fail)
- 1x Empty state icon contrast (decorative element)
**Fix**: Add `id` to inputs and `for` to labels. Darken badge-default text. Add `aria-hidden="true"` to decorative icon.

### responsive-wireframe.html — 0 errors
All elements pass WCAG AA. Proper ARIA roles, labels, and contrast.

## 3. Nielsen Heuristic Evaluation

| # | Heuristic | Score | Finding | Improvement |
|---|-----------|-------|---------|-------------|
| 1 | System Status Visibility | 4/5 | Task count displayed. Filter tab shows current view. Checkbox gives immediate feedback. | Add loading skeleton for async states. |
| 2 | Match Real World | 5/5 | Labels use plain language ("Add Task", "My Tasks", "Settings"). No technical jargon. | None needed. |
| 3 | User Control & Freedom | 4/5 | Escape closes add bar. Cancel in modals. Filter is reversible. | Add Undo toast for complete/delete actions. Currently no undo in wireframe. |
| 4 | Consistency & Standards | 5/5 | Consistent component styling via design tokens. Checkbox, tabs, buttons follow platform conventions. | None needed. |
| 5 | Error Prevention | 4/5 | Delete has confirmation dialog in design system. Empty input prevented in add task. | Add confirmation for "Clear Completed" in settings. |
| 6 | Recognition vs Recall | 5/5 | All actions are visible (FAB, tabs, checkboxes). No hidden menus for core functions. | None needed. |
| 7 | Flexibility & Efficiency | 3/5 | Basic keyboard navigation (Tab, Enter, Escape). No keyboard shortcuts for power users. | Add Cmd/Ctrl+N for new task. Add search shortcut. |
| 8 | Aesthetic & Minimalist | 5/5 | Clean layout, minimal chrome, focused on task content. No unnecessary decorations. | None needed. |
| 9 | Error Recovery | 3/5 | No error states shown in wireframe for failed saves. No undo for task completion. | Design error toast. Add undo mechanism. |
| 10 | Help & Documentation | 3/5 | App is simple enough to not need help. But no onboarding or empty state guidance in wireframe (design system has empty state). | Add empty state with guidance to wireframe. |

**Average Score: 4.1/5**

### P0 Issues (score < 3 = none, but flagging borderline 3s):
No heuristic scored below 3. Three scored exactly 3:
- **H7 (Flexibility)**: No keyboard shortcuts — acceptable for MVP but should be added.
- **H9 (Error Recovery)**: No undo/error states in wireframe — design system has toast component but wireframe doesn't implement it.
- **H10 (Help)**: No onboarding — low risk for simple todo app.

## 4. Improvement Plan

| # | Problem | Severity | Source | Fix | Expected Effect |
|---|---------|----------|-------|-----|----------------|
| 1 | Wireframe uses #999 for secondary text (contrast 2.85:1) | P0 | pa11y | Change to #767676 or use design token --color-text-secondary (#6B7280, 4.63:1) | WCAG AA compliance |
| 2 | Component showcase inputs missing label association | P0 | pa11y | Add `id` to inputs, `for` to labels | Screen reader accessibility |
| 3 | Badge-default contrast 4.39:1 (borderline) | P1 | pa11y | Darken badge text to #636971 | WCAG AA compliance |
| 4 | No undo mechanism for task completion/deletion | P1 | Heuristic H9 | Implement undo toast (4s) using existing Toast component | Error recovery |
| 5 | No keyboard shortcuts (Cmd+N, Cmd+K) | P1 | Heuristic H7 | Add keyboard shortcut support for new task and search | Power user efficiency |
| 6 | Empty state not implemented in wireframe | P2 | Heuristic H10 | Add empty state when task list is empty | First-use guidance |
| 7 | Decorative icon in empty state fails contrast | P2 | pa11y | Add aria-hidden="true" to decorative icon | Correct ARIA usage |
| 8 | No loading states in wireframe | P2 | Heuristic H1 | Add skeleton loading from design system | System status visibility |

### Summary
- **P0 issues**: 2 (contrast + label association) — fixable with CSS/HTML changes
- **P1 issues**: 3 (badge contrast, undo, keyboard shortcuts)
- **P2 issues**: 3 (empty state, decorative icon, loading states)
- **responsive-wireframe.html passed pa11y with 0 errors** — this is the production-quality reference
