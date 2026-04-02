# Interaction Specification — FlowPM

## 1. State Matrix — Core Components

### Button
| State | Visual Change | Transition |
|---|---|---|
| Default | bg: primary, text: white, border-radius: 6px | — |
| Hover | bg: primary-hover, cursor: pointer | 150ms ease |
| Focus | 2px outline offset 2px (color: primary-light) | instant |
| Active/Pressed | bg: primary-hover, scale(0.98) | 100ms |
| Disabled | bg: border, text: text-muted, cursor: not-allowed | — |
| Loading | bg: primary, spinner icon replaces text, pointer-events: none | 200ms |

### Input
| State | Visual Change | Transition |
|---|---|---|
| Default | border: border, bg: surface | — |
| Hover | border: border-strong | 150ms |
| Focus | border: primary, shadow: 0 0 0 3px primary-light | 150ms |
| Filled | border: border, text: text | — |
| Error | border: error, bg: error-light (subtle), error message below | 200ms |
| Disabled | bg: sidebar, text: text-muted, cursor: not-allowed | — |

### Issue Card (on Board)
| State | Visual Change | Transition |
|---|---|---|
| Default | bg: surface, border: border, shadow: none | — |
| Hover | border: border-strong, shadow: sm | 150ms |
| Focus (keyboard) | 2px outline offset 2px (primary) | instant |
| Selected | bg: primary-light, border: primary | 150ms |
| Dragging | shadow: lg, opacity: 0.9, scale(1.02), cursor: grabbing | 200ms |
| Drop target | 2px dashed border primary, bg: primary-light | 200ms |

### Modal
| State | Visual Change | Transition |
|---|---|---|
| Opening | overlay: opacity 0→0.3, modal: scale(0.95)→1 + opacity 0→1 | 200ms |
| Open | overlay: bg rgba(0,0,0,0.3), modal: centered, shadow: xl | — |
| Closing | reverse of opening | 140ms (70% of open) |
| Closed | removed from DOM/hidden | — |

### Toast/Notification
| State | Visual Change | Transition |
|---|---|---|
| Entering | translate-y 100%→0, opacity 0→1 | 300ms ease-out |
| Visible | fixed bottom-right, shadow: md, auto-dismiss timer | 5000ms display |
| Dismissing | translate-x 100%, opacity→0 | 200ms ease-in |
| Stacking | new toast pushes existing up by toast-height + 8px gap | 200ms |

## 2. Drag-and-Drop State Machine (Kanban Board)

```
IDLE
  → [mouseenter card] → HOVER
  
HOVER
  → [mouseleave] → IDLE
  → [mousedown + hold 150ms] → GRAB

GRAB
  → [mouseup before move] → IDLE (was a click, not drag)
  → [mousemove > 5px threshold] → DRAGGING

DRAGGING
  → [card follows cursor with 12px offset]
  → [original position shows placeholder (dashed border, same height)]
  → [cursor: grabbing on body]
  → [enter column drop zone] → OVER_TARGET
  → [mouseup outside any column] → CANCEL → IDLE (card returns to origin, 200ms ease)
  → [Escape key] → CANCEL → IDLE

OVER_TARGET
  → [column highlights: bg primary-light, border primary dashed]
  → [insertion indicator shows between cards (2px solid primary line)]
  → [leave column] → DRAGGING
  → [mouseup] → DROP

DROP
  → [card placed at insertion point]
  → [placeholder removed]
  → REORDER_ANIMATION

REORDER_ANIMATION
  → [other cards shift to fill/make space, 200ms ease]
  → [dropped card settles into position, 150ms ease]
  → SETTLED

SETTLED
  → [API call to persist new order/status]
  → [optimistic update — card already in new position]
  → [on API error: card returns to original position + error toast]
  → IDLE
```

## 3. Keyboard Shortcuts

### Global (available everywhere)
| Shortcut | Action |
|---|---|
| Cmd+K | Open command palette / global search |
| Cmd+C | Quick create new issue |
| Cmd+, | Open settings |
| Cmd+/ | Show keyboard shortcut help |
| Escape | Close modal / panel / palette |

### Board View
| Shortcut | Action |
|---|---|
| Arrow Left/Right | Move focus between columns |
| Arrow Up/Down | Move focus between cards in column |
| Enter | Open focused card in side panel |
| Space | Select/deselect focused card (multi-select) |
| D | Open drag mode for focused card → then arrows to reposition + Enter to drop |
| 1/2/3/4 | Set priority (1=Urgent, 2=High, 3=Medium, 4=Low) for selected issue |
| A | Assign to self |
| L | Open label picker |

### Issue Detail Panel
| Shortcut | Action |
|---|---|
| Escape | Close panel |
| Cmd+Enter | Submit comment |
| Tab | Move between fields |
| S | Change status (opens picker) |
| P | Change priority (opens picker) |

### List View
| Shortcut | Action |
|---|---|
| J / Arrow Down | Move to next issue |
| K / Arrow Up | Move to previous issue |
| X | Select/deselect issue (bulk mode) |
| Cmd+A | Select all visible issues |
| Backspace/Delete | Move selected to trash (with confirmation for >1) |

## 4. Real-Time Collaboration States

### Cursor Presence
- **Own cursor**: Not shown (natural)
- **Others' cursors**: Colored dot + name label (appears on hover) at their viewport position
- **Colors**: Auto-assigned from a 6-color palette, consistent per user within session
- **Stale**: If no activity for 60s, cursor fades to 30% opacity. After 5min, removed.

### Concurrent Editing
| Scenario | Behavior |
|---|---|
| Same issue, different fields | Both edits apply independently. Fields show colored border matching editor's cursor color while being edited. |
| Same field, same issue | Last-write-wins with conflict indicator: "Alex is also editing this field" banner appears. On save, if conflict detected, show diff modal: "Your version / Their version / Merged" |
| Card being dragged by another | Card shows locked indicator (colored border + "{User} is moving this"). Other users cannot drag it. |
| Column reorder | Atomic operation — first drag wins, subsequent attempts see updated order on drop. |

### Presence Indicators
- **Board**: Small avatars at column headers showing who is viewing that column
- **Issue panel**: "Alex is viewing" or "Alex, Jordan are viewing" at top of panel
- **Typing indicator**: "Alex is typing..." in comment section, debounced at 2s

## 5. Bulk Operation States

```
NORMAL_MODE
  → [click checkbox on issue OR press X on focused issue] → SELECT_MODE

SELECT_MODE
  → [bulk action bar slides up from bottom: "2 selected" + action buttons]
  → [click more checkboxes / Shift+click for range select] → multi-select count updates
  → [Cmd+A selects all visible]
  → [click action button] → BULK_ACTION_MENU
  → [Escape or click "Cancel"] → NORMAL_MODE (all deselected)

BULK_ACTION_MENU
  → [available actions: Change Status, Change Priority, Assign, Add Label, Move to Project, Delete]
  → [select action] → CONFIRM

CONFIRM
  → [for non-destructive: apply immediately, show toast "Updated 5 issues"]
  → [for destructive (Delete): show confirmation modal "Delete 5 issues? This cannot be undone."]
  → [on confirm] → apply + toast + return to NORMAL_MODE
  → [on cancel] → return to SELECT_MODE (selection preserved)
```

## 6. Animation Timing Rules

| Category | Duration | Easing | Examples |
|---|---|---|---|
| Micro-interaction | 150ms | ease | Button hover, input focus |
| State change | 200ms | ease | Card select, toast appear |
| Layout shift | 300ms | ease-out | Panel slide, modal open |
| Exit animation | 70% of enter | ease-in | Modal close=140ms, panel close=210ms |
| Stagger (lists) | 30ms per item | ease | Board cards loading, search results |
| Maximum | 400ms | — | Never exceed this |

### prefers-reduced-motion
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## 7. Feedback Rules

| Trigger | Feedback | Timing |
|---|---|---|
| Any click/tap | Visual state change (hover→active) | <100ms |
| Async operation start | Button disabled + spinner | immediate |
| Async success | Toast "Issue created" (auto-dismiss 5s) | on completion |
| Async error | Toast with error + "Retry" action (persist until dismissed) | on failure |
| Destructive action | Confirmation modal with red CTA | before action |
| Destructive success | Toast with "Undo" button (8s window) | after action |
| Drag start | Cursor: grabbing, card lifts (shadow) | 150ms after mousedown |
| Invalid drop | Card returns to origin with bounce | 200ms |
