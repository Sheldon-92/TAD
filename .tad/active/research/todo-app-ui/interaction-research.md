# Interaction Design Research — Todo App

## 1. Interaction Pattern References

### Reference Analysis
Based on Material Design 3 and Apple HIG guidelines for task management interactions:

| Pattern | Source | Implementation |
|---------|--------|---------------|
| Checkbox toggle | MD3 / Apple HIG | Single tap toggles state, immediate visual feedback |
| Swipe-to-delete | Apple HIG (UIKit standard) | Left swipe reveals delete action, with confirmation |
| Inline editing | Google Tasks, Todoist | Tap text to enter edit mode, Enter to save |
| FAB (Floating Action Button) | MD3 | Primary action always visible, bottom-right |
| Toast notification | MD3 Snackbar | Auto-dismiss 4-6s, optional action (Undo) |
| Pull-to-refresh | iOS/Android native | Pull down to refresh task list |
| Tab switching | MD3 Tabs | Instant content switch, no page load |

Sources:
- Material Design 3 component guidelines (m3.material.io)
- Apple Human Interface Guidelines (developer.apple.com/design)

---

## 2. State Matrix

### Button States
| State | Visual Change | Transition |
|-------|--------------|-----------|
| Default | bg: primary, text: white | — |
| Hover | bg: primary-hover (darker) | 150ms ease |
| Focus | outline: 2px offset primary | 0ms (instant) |
| Active/Pressed | scale: 0.98, bg: primary-hover | 100ms ease |
| Disabled | opacity: 0.5, cursor: not-allowed | 150ms ease |
| Loading | spinner replaces text, disabled | 200ms ease |

### Input States
| State | Visual Change | Transition |
|-------|--------------|-----------|
| Default | border: 1px border color | — |
| Hover | border: border-strong | 150ms ease |
| Focus | border: primary, ring: 2px primary/20% | 150ms ease |
| Filled | border: border-strong | 150ms ease |
| Error | border: error, helper text red | 150ms ease |
| Disabled | bg: surface-hover, opacity: 0.6 | 150ms ease |

### Task Item (Card/List Item) States
| State | Visual Change | Transition |
|-------|--------------|-----------|
| Default | bg: surface, border-bottom | — |
| Hover | bg: surface-hover | 150ms ease |
| Active (tap) | bg: slightly darker | 100ms ease |
| Completed | text: strikethrough, color: secondary | 300ms ease |
| Editing | border: primary, input visible | 200ms ease |
| Deleting | slide left, bg: error/10% | 200ms ease-out |

### Checkbox States
| State | Visual Change | Transition |
|-------|--------------|-----------|
| Unchecked | border: secondary, bg: surface | — |
| Hover | border: primary | 150ms ease |
| Checked | bg: primary, checkmark icon | 200ms ease (scale bounce) |
| Focus | ring: 2px primary/20% | 0ms |

### Toast/Notification States
| State | Visual Change | Transition |
|-------|--------------|-----------|
| Enter | slide up from bottom | 300ms ease-out |
| Visible | solid bg, text + optional action | — |
| Exit | slide down + fade | 200ms ease-in |
| Auto-dismiss | after 4000ms | — |

### Modal States
| State | Visual Change | Transition |
|-------|--------------|-----------|
| Opening | backdrop fade in, modal scale from 0.95 | 200ms ease-out |
| Open | backdrop: black/50%, modal centered | — |
| Closing | reverse of opening | 150ms ease-in |

---

## 3. Interaction Specification

### Animation Timing Rules
- Micro-interactions (hover, focus, checkbox): **150ms** ease
- State transitions (complete task, filter switch): **200-300ms** ease
- Complex transitions (modal open/close, toast): **200-300ms** ease-out (enter), **150-200ms** ease-in (exit)
- Maximum: **400ms** — nothing slower
- Exit animation = Enter animation x 70%
- List item stagger: **30ms** between items
- Respect `prefers-reduced-motion`: reduce all animations to 0ms or use opacity-only

### Feedback Rules
- Click/tap: visual feedback within **100ms** (scale, color change, or ripple)
- Async operations: button enters loading state immediately (spinner + disabled)
- Success: Toast slides up from bottom, auto-dismiss at **4000ms**
- Error: Toast with error style, stays until dismissed OR 6000ms
- Destructive actions (delete): Confirmation dialog OR Undo toast (4000ms)

### Keyboard Navigation
| Key | Action |
|-----|--------|
| Tab | Move focus forward through interactive elements |
| Shift+Tab | Move focus backward |
| Enter | Confirm action (add task, save edit) |
| Escape | Close modal, cancel edit, close add bar |
| Space | Toggle checkbox |
| Delete/Backspace | Delete selected task (with confirmation) |

### Accessibility Requirements
- All animations respect `prefers-reduced-motion: reduce`
- Focus indicators visible on all interactive elements (2px outline)
- No `transition: all` — only transition specific properties
- Animations must be interruptible (no blocking animations)
- Tab order matches visual order (top-to-bottom, left-to-right)
- ARIA roles on all custom interactive elements
