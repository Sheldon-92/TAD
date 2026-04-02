# Usability Audit — FlowPM SaaS PM Tool

## 1. Automated Accessibility Check (pa11y WCAG 2.1 AA)

| File | Total Violations | Key Issues |
|---|---|---|
| wireframe.html | 54 | Contrast failures (49), missing form labels (5) |
| component-showcase.html | 49 | Contrast failures (majority), some missing ARIA |
| responsive-wireframe.html | 16 | Contrast failures, missing labels |

### Top Violation Categories

1. **Contrast ratio failures (WCAG 1.4.3)** — ~90% of all violations
   - `--muted` (#999) text on white: 2.85:1 (requires 4.5:1) — affects issue IDs, section titles, placeholder-style text
   - Avatar initials on colored backgrounds: 3.58:1 — below AA for normal text
   - Column count badges (#999 on #eee): 2.46:1 — severely below threshold
   - **Root cause**: Wireframe uses grayscale palette (#999, #ccc) that's too light. Design tokens file has WCAG-passing values, but wireframe HTML uses wireframe-specific palette that was not contrast-checked.

2. **Missing form labels (WCAG 1.3.1, 4.1.2)** — 5 violations
   - Settings page inputs use `<label class="settings-label">` but not wrapped in `<label for="">` structure
   - Command palette search input has no label
   - Toggle button has no accessible name

3. **No missing alt text or landmark issues** — The semantic HTML structure (nav, main, aside) is correct.

## 2. Nielsen Heuristic Evaluation

### H1: Visibility of System Status — Score: 4/5
**Good**: Active sidebar item highlighted. Active tab clearly marked. Board column counts show issue numbers. Command palette shows recent items.
**Finding**: No loading states demonstrated in wireframe — when board is loading, user sees nothing. Need skeleton states for board columns.
**Improvement**: Add skeleton loading state to board view.

### H2: Match Between System and Real World — Score: 5/5
**Good**: Terminology matches developer expectations: "Issues" (not "Tickets"), "Board" (Kanban is universal), "Cycles" (sprint alternative), priorities use universal icons. Status flow (Todo → In Progress → In Review → Done) matches standard dev workflow.
**No issues found.**

### H3: User Control and Freedom — Score: 4/5
**Good**: Escape key closes modals and panels (implemented). Back navigation in issue detail. Cancel buttons present on destructive modals.
**Finding**: No undo capability demonstrated. Interaction spec specifies "Undo" on destructive toast, but wireframe doesn't show it.
**Improvement**: Add undo toast to wireframe demo.

### H4: Consistency and Standards — Score: 4/5
**Good**: Consistent button styles, consistent card format, sidebar items all behave the same. Follows platform conventions (Cmd+K for search, Escape to close).
**Finding**: Wireframe uses grayscale-only (B&W convention), but the component showcase uses design tokens with color. The two feel disconnected — a reviewer looking at both would be confused about which is authoritative.
**Improvement**: This is expected at this design stage (wireframe → visual design is a progression). Add a note to wireframe header clarifying "B&W wireframe — see component-showcase.html for visual design."

### H5: Error Prevention — Score: 3/5
**Good**: Delete project has confirmation modal with clear warning text. Danger zone visually separated in settings.
**Finding (P0)**: No confirmation for bulk issue deletion. Interaction spec says "destructive actions require confirmation" but the My Issues page shows checkboxes for multi-select with no demonstrated bulk action confirmation flow.
**Finding**: Settings page "Delete Workspace" button is visually close to other settings — could be accidentally clicked. Should have additional friction (e.g., type workspace name to confirm).
**Improvement**: Add bulk delete confirmation modal. Add type-to-confirm for workspace deletion.

### H6: Recognition Rather Than Recall — Score: 5/5
**Good**: All navigation items visible in sidebar. Priority icons are visual (bars, not just text). Status shown with colored dots + text. Filter and group-by options accessible via buttons (not hidden behind menu).
**No issues found.**

### H7: Flexibility and Efficiency of Use — Score: 4/5
**Good**: Extensive keyboard shortcuts (Cmd+K, Cmd+C, arrow navigation, number keys for priority). Command palette serves as both search and command center. Filter and group-by for power users.
**Finding**: No shortcut for switching between projects. Indie devs often work across 2-3 projects — project switching should be Cmd+P or similar.
**Improvement**: Add Cmd+P or project switching to command palette.

### H8: Aesthetic and Minimalist Design — Score: 4/5
**Good**: Board cards show only essential info (ID, title, priority, assignee). Sidebar is clean with 6 items. Settings page is well-organized with sections.
**Finding**: Board page has 4 actions in topbar (Search, Filter, Group by, + Issue) — the Filter and Group by could be consolidated or secondary. For an indie dev tool, 4 visible actions may be one too many.
**Improvement**: Collapse Filter + Group by into a single "View options" dropdown.

### H9: Help Users Recognize, Diagnose, and Recover from Errors — Score: 3/5
**Good**: Toast design includes action buttons (Retry for errors). Input error states show specific messages.
**Finding (P0)**: No error state demonstrated for failed board load, failed drag-and-drop (API error), or offline state. Interaction spec mentions these but wireframe doesn't show them.
**Improvement**: Add error empty state for board load failure. Add "Retry" CTA.

### H10: Help and Documentation — Score: 2/5
**Finding (P0)**: No onboarding flow, no keyboard shortcut reference overlay (Cmd+/ is specified but not shown), no tooltips on sidebar icons in collapsed mode, no help menu or documentation link.
**Improvement**: Add Cmd+/ shortcut overlay. Add tooltips to collapsed sidebar icons. Add "?" help item in sidebar bottom.

### Summary Scores
| Heuristic | Score | Status |
|---|---|---|
| H1: System Status | 4/5 | OK |
| H2: Real World Match | 5/5 | Excellent |
| H3: User Control | 4/5 | OK |
| H4: Consistency | 4/5 | OK |
| H5: Error Prevention | 3/5 | P0 |
| H6: Recognition | 5/5 | Excellent |
| H7: Flexibility | 4/5 | OK |
| H8: Minimalism | 4/5 | OK |
| H9: Error Recovery | 3/5 | P0 |
| H10: Help & Docs | 2/5 | P0 |

**Average: 3.8/5**

## 3. Role-Based UI Evaluation

### Question: "If a Viewer sees an Edit button but can't edit — bad UX. Should hide or disable?"

**Analysis**: For this PM tool with 4 roles (Owner/Admin/Member/Viewer):

| Element | Viewer Should See | Reasoning |
|---|---|---|
| Issue detail fields | Read-only (no edit affordance) | **Hide** edit controls entirely. Showing grayed-out edit buttons creates false expectations. |
| "+ Issue" button | **Hidden** | Viewers cannot create — showing a disabled button is confusing ("why can't I?") |
| Settings menu item | **Hidden entirely** for workspace settings; **Show** for personal notification settings | Mixed: viewers need notification prefs but not workspace config |
| Drag-and-drop on board | **Disabled** (cards not draggable) | Since viewers see the board, cards should not respond to drag attempts. Add cursor: default. |
| Delete buttons | **Hidden** | Never show destructive actions to users who can't use them |
| Comment section | **Visible** for Member+; **Hidden** for Viewer | Viewers should see activity log but not comment input |

**Recommendation**: Use the **"hide if never allowed, disable if sometimes allowed"** pattern:
- Permanently unavailable actions (Viewer can never create issues) → **hide**
- Temporarily unavailable (Member can edit, but issue is locked by another user) → **disable with explanation tooltip**

**Current wireframe gap**: The wireframe does not demonstrate role-based UI differences. This is a P1 issue — should create a "Viewer mode" wireframe variant.

## 4. Cognitive Load Assessment — Board Page

**Elements competing for attention on the Board page:**

1. Sidebar navigation (6 items + sub-items)
2. Topbar (project name + 4 action buttons)
3. View tabs (Board / Backlog / Timeline)
4. 4 Kanban columns each with:
   - Column header (status name + count + add button)
   - 2-4 issue cards each with (ID + title + priority + assignee)
5. Total interactive elements visible: ~35-40

**Cognitive load assessment (Miller's 7±2 rule):**
- Primary attention layer: 4 columns (within 7±2) — PASS
- Per-column: 2-4 cards (within 7±2) — PASS
- Per-card: 4 info items (ID, title, priority, assignee) — PASS
- Sidebar: 6 items (within 7±2) — PASS
- Topbar: 4 actions — PASS

**Overall**: The board page is within acceptable cognitive load. The Linear-style minimal approach successfully limits information per visual unit.

**Risk area**: When a column has 10+ cards, vertical scrolling within columns creates hidden information. Consider: auto-collapse Done column, limit visible cards to 7 with "Show N more" toggle.

## 5. Improvement Priority List

| # | Issue | Severity | Source | Fix |
|---|---|---|---|---|
| 1 | Contrast failures: #999 text on white backgrounds (2.85:1) | P0 | pa11y | Change `--muted` from #999 to #767676 in wireframe CSS. Already correct in design-tokens.css (#78869B). |
| 2 | Missing form labels in Settings | P0 | pa11y | Wrap inputs in `<label>` or add `aria-label` attributes. |
| 3 | No help/onboarding flow | P0 | H10 | Add Cmd+/ keyboard shortcut overlay, help link in sidebar, first-use onboarding. |
| 4 | No error recovery states in wireframe | P0 | H9 | Add board load error, drag-drop error, and offline state wireframes. |
| 5 | No bulk delete confirmation | P0 | H5 | Add confirmation modal for bulk destructive operations. |
| 6 | Avatar text contrast (3.58:1) | P1 | pa11y | Use darker avatar backgrounds or larger/bolder text. Avatars with images bypass this. |
| 7 | No role-based UI variants | P1 | Role analysis | Create Viewer-mode wireframe showing hidden/disabled elements. |
| 8 | Toggle button missing accessible name | P1 | pa11y | Add `aria-label="Toggle auto-assign"` to toggle buttons. |
| 9 | Command palette input missing label | P1 | pa11y | Add `aria-label="Search issues and commands"`. |
| 10 | No project switching shortcut | P2 | H7 | Add Cmd+P for project switching in command palette. |
| 11 | Board topbar has 4 actions | P2 | H8 | Consolidate Filter + Group by into "View options" dropdown. |
| 12 | Done column should auto-collapse | P2 | Cognitive load | Collapse Done column when >5 items, show "Show N more". |

**P0 count: 5** (must fix before design handoff)
**P1 count: 4** (should fix)
**P2 count: 3** (nice to have)
