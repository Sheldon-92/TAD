# Information Architecture Research — Todo App

## 1. Competitive Navigation Analysis

### Reference Products Analyzed

| Product | Nav Pattern | Top-Level Items | Depth | Core Interaction |
|---------|------------|-----------------|-------|-----------------|
| Todoist | Flat sidebar | 5 (Inbox, Today, Upcoming, Filters, Projects) | 2 levels (projects have sub-projects) | Click to expand, drag to reorder |
| Apple Reminders | Hub-and-Spoke | 4 (Today, Scheduled, All, Flagged) + Custom Lists | 2 levels | Tap list → see tasks |
| Microsoft To Do | Flat sidebar | 5 (My Day, Important, Planned, Assigned, Tasks) + Custom Lists | 2 levels | Click list → tasks |

**Pattern**: All 3 products use a **flat navigation** with <=5 smart/system views + user-created lists. Depth is consistently 2 levels (list → tasks). No product uses tree-form deeper than 2 levels for basic todo.

Sources:
- [Tubik Studio — Upper App Case Study](https://blog.tubikstudio.com/case-study-upper-app-ui-design-for-to-do-list/)
- [Medium — Designing a Simple Todo App](https://medium.com/product-manager-journal/designing-a-simple-todo-app-b4d4ed9300a4)
- [Medium — UX Case Study: To-Do list app](https://medium.com/@iasallehsani/ux-case-study-to-do-list-app-d851f50d5c3d)

### Navigation Pattern Selection
- **Flat navigation** is the clear winner for todo apps. All 3 references use it.
- Reason: Todo apps have limited distinct content types (tasks, lists, settings). Tasks are the singular focus. Hub-and-Spoke or tree hierarchy adds unnecessary complexity.
- Mobile: Bottom tab bar (3-4 items). Desktop: Sidebar (5-7 items).

---

## 2. Content Inventory

| Content/Function | Type | User Frequency | Priority |
|-----------------|------|---------------|----------|
| Task List (main view) | Page | High (every session) | P0 |
| Add Task | Modal/Inline | High | P0 |
| Complete Task (checkbox) | Inline action | High | P0 |
| Edit Task | Modal/Inline | Medium | P0 |
| Delete Task | Inline action (swipe/menu) | Low | P1 |
| Filter Tasks (All/Active/Completed) | Tab/Toggle | Medium | P0 |
| Search Tasks | Inline (top bar) | Medium | P1 |
| Settings | Page | Low | P2 |
| Empty State | Inline | Low (first use) | P1 |

All high-frequency functions (view list, add, complete, filter) must be reachable from the main view with 0-1 taps.

---

## 3. User Flow Analysis

### Flow 1: Add Task (core — must be <=3 steps)
1. User is on Task List → taps "+" button (always visible)
2. Input field appears (inline or modal) → user types task title
3. User taps "Add" or presses Enter → task appears in list
- Decision point: None (simple create). Optional: set due date before confirming.
- Success state: Task appears at top/bottom of list with subtle animation.

### Flow 2: Complete Task (core — must be 1 step)
1. User taps checkbox next to task → task marked complete with strikethrough animation
- Post-action: Task moves to "Completed" section or disappears (based on filter).
- Undo: Toast with "Undo" for 4s.

### Flow 3: Filter Tasks (core — must be 1 step)
1. User taps filter tab (All / Active / Completed) → list updates instantly
- No page navigation needed. Tabs are always visible above the list.

### Flow 4: Edit Task (must be <=3 steps)
1. User taps on task text → task enters edit mode (inline)
2. User modifies text → taps "Save" or presses Enter
3. Task updates in place.
- Alternative: Tap task → detail modal → edit fields → save.

### Flow 5: Delete Task (must be <=2 steps)
1. User swipes left on task (mobile) or hovers and clicks delete icon (desktop)
2. Confirmation: "Delete task?" → Confirm
- Destructive action: Must have confirmation or undo toast.

---

## 4. Navigation Structure Derivation

### Selected Pattern: Flat Navigation (Single-Page Focus)
**Rationale**: Based on competitive analysis, all 3 reference products use flat navigation. Todo app has only 2 distinct page types (Task List, Settings). A single-page app with inline actions is optimal.

### Navigation Structure:
- **Mobile (Bottom Tab Bar)**: 3 items
  1. Tasks (main view — task list + filters + add)
  2. Search
  3. Settings
- **Desktop (Sidebar)**: 4 items
  1. All Tasks
  2. Active
  3. Completed
  4. Settings

### Validation:
- Add Task: 1 tap from main view (FAB button) ✅
- Complete Task: 1 tap (checkbox) ✅
- Filter: 1 tap (tab switch) ✅
- Edit: 1 tap (tap task text) ✅
- Delete: 1-2 taps (swipe or menu) ✅
- Settings: 1 tap (nav item) ✅
- All high-frequency functions <=2 clicks ✅
