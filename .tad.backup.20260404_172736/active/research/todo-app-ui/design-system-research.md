# Design System Research — Todo App

## 1. Component Reference Analysis

Based on Material Design 3, shadcn/ui, and Radix UI component patterns.

### Components Needed (extracted from wireframe)
| Component | Used In | Variants Needed |
|-----------|---------|----------------|
| Button | Add task, Delete confirm, Settings | Primary, Secondary, Danger, Ghost |
| Checkbox | Task items | Unchecked, Checked |
| Input | Add task, Edit task, Search | Default, With icon |
| Card / List Item | Task items | Active, Completed |
| Tabs | Filter (All/Active/Completed) | Underline style |
| Modal / Dialog | Delete confirmation | Confirm, Form |
| Toast | Undo, Success, Error | Success, Error, Info |
| Badge | Task count | Default, Accent |
| Empty State | No tasks | With illustration text |
| FAB | Add task | Primary |
| Navigation (Bottom) | Mobile nav | 2-3 items |
| Skeleton | Loading state | List item shape |
| Dropdown | Settings menu | Standard |
| Search | Task search | With icon |
| Alert | Settings confirmations | Warning, Info |

---

## 2. Component Specifications

### Atomic Design Hierarchy

**Atoms** (standalone, no dependencies):
- Button, Checkbox, Input, Badge, Icon (SVG), Typography (text styles)

**Molecules** (composed of atoms):
- Search Bar (Input + Icon)
- Form Field (Label + Input + Error text)
- Task Item (Checkbox + Typography + Badge + Button)
- Tab (Button variant with underline indicator)

**Organisms** (composed of molecules):
- Header (Typography + Search Bar + Button)
- Task List (multiple Task Items)
- Filter Bar (multiple Tabs)
- Bottom Navigation (multiple Nav Items)
- Modal (Typography + Button group + overlay)
- Toast (Badge + Typography + Button)

### Key Component Rules
1. **Button**: Verb-first labels ("Add Task" not "Task Addition"). Max 1 Primary per viewport region.
2. **Card/Task Item**: No shadow AND border simultaneously. Use border for flat, shadow for elevated.
3. **Modal**: Focus trap on open. Close via X, Cancel, Escape. Return focus to trigger on close.
4. **Tabs**: 2-3 tabs for this app. Clear active indicator (underline, not just color).
5. **Toast**: 4s auto-dismiss. Destructive actions get Undo button. Max 1 toast visible.
6. **Empty State**: Positive messaging ("No tasks yet — add your first!"). CTA button.
7. **Checkbox**: 20x20px minimum. 44x44px touch target area.
8. **Input**: Label always visible above. Inline validation on blur. Error message below.
9. **Badge**: Pill shape, 1-2 words max. Limited color palette (primary, secondary, error, success).
10. **Skeleton**: Match actual layout shape. Shimmer animation. Show after 300ms delay.
