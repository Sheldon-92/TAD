# Wireframe Research — Todo App

## 1. Layout Reference Analysis

### Reference Products Layout Patterns
| Product | Layout | Core Interaction | Mobile Pattern |
|---------|--------|-----------------|---------------|
| Todoist | List-based, left sidebar | Click to expand projects, inline add | Bottom tabs, full-width list |
| Apple Reminders | List groups on home, flat list inside | Tap list → tasks, inline add | Cards for smart lists, flat list for custom |
| Microsoft To Do | List sidebar + task detail panel | Click list → tasks, click task → detail panel | Bottom tabs, full-width list |
| Google Tasks | Minimal list, FAB for add | Inline editing, drag reorder | Single list view, FAB |

**Dominant pattern**: List-based layout with inline task management. No product uses card/grid for individual tasks — lists are the universal pattern for todo items.

Sources:
- [Dribbble — Todo List Designs](https://dribbble.com/tags/todo_list)
- [Mockplus — 25 Great To-Do List App UI Designs](https://www.mockplus.com/resource/post/25-great-to-do-list-app-ui-designs-for-your-inspiration)

---

## 2. Three UX Approaches

### Approach 1: Safe — Classic List (validated pattern)
**UX Philosophy**: Single-column task list with inline actions. Proven by Todoist, Apple Reminders, Google Tasks.
- Filter tabs at top (All / Active / Completed)
- Each task: checkbox + title + optional due date
- FAB (floating action button) for add
- Inline edit on tap

| Criterion | Score (1-5) |
|-----------|-------------|
| Learning Cost | 5 (extremely familiar) |
| Information Density | 3 (one task per row, moderate) |
| Mobile Adaptability | 5 (list is inherently mobile-friendly) |
| **Total** | **13** |

**Risk**: Generic, no differentiation. But for a simple todo app, differentiation is not a goal.

### Approach 2: Explore A — Kanban Board
**UX Philosophy**: Visual columns for task states (To Do / In Progress / Done). Inspired by Trello/Notion boards.
- 3 columns side-by-side on desktop
- Drag-and-drop between columns to change status
- Cards show task title + metadata

| Criterion | Score (1-5) |
|-----------|-------------|
| Learning Cost | 3 (familiar to power users, new to casual users) |
| Information Density | 4 (see all states at once) |
| Mobile Adaptability | 2 (columns collapse to tabs on mobile, loses spatial overview) |
| **Total** | **9** |

**Risk**: Overkill for a simple todo. Kanban implies workflow stages that simple tasks may not have. Mobile experience degrades.

### Approach 3: Explore B — Search-First / Command Palette
**UX Philosophy**: Minimal chrome, keyboard-driven. Inspired by Things 3 and Linear.
- Large search/command bar at top
- Task list below, filtered by search
- Keyboard shortcuts for all actions (Cmd+N to add, etc.)
- Clean typography-focused design

| Criterion | Score (1-5) |
|-----------|-------------|
| Learning Cost | 2 (requires learning shortcuts) |
| Information Density | 4 (minimal chrome = more content space) |
| Mobile Adaptability | 3 (search works but shortcuts don't translate) |
| **Total** | **9** |

**Risk**: High barrier for non-technical users. Mobile experience lacks keyboard shortcuts.

---

## 3. Approach Selection

### Selected: Approach 1 — Classic List

**Rationale**:
1. **Highest total score** (13 vs 9 vs 9) driven by superior learning cost and mobile adaptability.
2. **Target user**: General consumer, not power users — learning cost must be minimal.
3. **Core scenario**: Quick task capture and completion — frequency demands efficiency, which the classic list pattern delivers with 1-tap add and 1-tap complete.
4. **All 3 competitor references** use this pattern, confirming user expectation.
5. **Simple todo scope** does not benefit from Kanban (no workflow stages) or Command Palette (no complex search needs).

The classic list is not boring — it is battle-tested. For a simple todo app, the safest approach IS the best approach.
