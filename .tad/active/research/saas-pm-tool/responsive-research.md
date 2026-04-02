# Responsive Design Research — FlowPM

## 1. Target User Device Distribution [ASSUMPTION]

Indie developers primarily use:
- **Desktop (70-80%)**: Primary work environment. Coding + PM tool side by side.
- **Mobile (15-20%)**: Quick triage, notifications, status checks on the go.
- **Tablet (5-10%)**: Occasional use, similar to desktop or mobile depending on context.

[ASSUMPTION] Based on typical dev tool usage patterns. No specific analytics data available. Linear and GitHub report >70% desktop usage for their developer audiences.

**Implication**: Desktop-first design with functional mobile experience (not just "responsive" — must be actually usable for quick actions).

## 2. Layout Shifts Per Page Per Breakpoint

### Board (Kanban)
| Breakpoint | Layout | Key Changes |
|---|---|---|
| 375px (mobile) | **Swipe between single columns** | One column visible at a time. Swipe left/right to change column. Column count indicator at top (dots). No drag-and-drop (tap to change status via dropdown instead). |
| 768px (tablet) | **2 columns visible + horizontal scroll** | Side-by-side columns, horizontally scrollable. Drag-and-drop enabled. Sidebar collapsed to icon mode. |
| 1024px (small desktop) | **3-4 columns + collapsed sidebar** | Full board visible. Sidebar auto-collapsed (48px). Issue cards show full metadata. |
| 1440px (desktop) | **All columns + expanded sidebar** | Full board + expanded sidebar (220px). Side panel for issue detail (520px) can open without hiding board. |

**Key mobile challenge — Kanban board**: Horizontal scroll of full columns is unusable on phones (too much panning). Solution: **Single-column swipe** (like Trello mobile) — user sees one column at a time and swipes to navigate. This is the proven mobile pattern for Kanban (Trello, Linear mobile both use this approach).

### Issue Detail
| Breakpoint | Layout | Key Changes |
|---|---|---|
| 375px | Full-screen page | Issue opens as full page. Back button to return to board. Fields stacked vertically. |
| 768px | Full-screen page | Same as mobile but wider fields. Two-column layout for metadata fields. |
| 1024px | Side panel (480px) | Opens as right panel over board. Board visible underneath (dimmed). |
| 1440px | Side panel (520px) | Opens as right panel. Board fully interactive alongside. |

### Settings
| Breakpoint | Layout | Key Changes |
|---|---|---|
| 375px | Full-width stacked | Single column. Tabs become horizontal scroll. Form fields full width. |
| 768px | Centered content (max-w 600px) | Comfortable reading width. Tabs visible without scroll. |
| 1024px+ | Centered content (max-w 720px) | Same as tablet. Settings don't need wide layout. |

### My Issues (List)
| Breakpoint | Layout | Key Changes |
|---|---|---|
| 375px | Simplified cards | Each issue as a card (title + priority + status). No table columns. Tap to open detail. |
| 768px | Compact table | Table with key columns (ID, Title, Priority, Project). Horizontal scroll for extras. |
| 1024px+ | Full table | All columns visible. Checkbox column for bulk selection. |

**Key mobile challenge — Timeline/Gantt**: Gantt charts require horizontal space. On mobile: **Replace with a simplified list view** showing issue title + date range + progress bar (vertically stacked). The timeline visualization is desktop-only — forcing it on mobile creates an unusable mini-chart. Linear mobile similarly omits timeline views.

## 3. Breakpoint Decisions

| Token | Value | Rationale |
|---|---|---|
| sm | 375px | iPhone SE/mini and most phones in portrait. Base mobile breakpoint. |
| md | 768px | iPad portrait, large phones landscape. First breakpoint where sidebar can appear. |
| lg | 1024px | iPad landscape, small laptops. Full app layout possible. |
| xl | 1440px | Standard desktop monitors. Full sidebar + content + panel. |

**Why these specific values:**
- **375px** (not 320px): iPhone SE is 375px. Sub-375 devices are <2% of market [ASSUMPTION]. Not worth optimizing below 375.
- **768px** (not 640px): iPad portrait is the first screen size where a sidebar makes sense. At 640px the sidebar would consume too much horizontal space.
- **1024px** (not 1280px): At 1024px we can fit collapsed sidebar (48px) + full board. Many developers use 13" laptops (1024-1440px effective width with browser chrome).
- **1440px** (not 1920px): Standard "comfortable" desktop. At this width we can show sidebar + board + detail panel simultaneously.

## 4. Responsive Rules

### Navigation
- **<768px**: Bottom tab bar (5 items: My Issues, Board, Inbox, Search, Menu)
  - Tab bar is 56px height (44px touch targets + 12px safe area)
  - Menu opens full-screen overlay with all nav items
- **>=768px**: Left sidebar (collapsed 48px or expanded 220px)
  - Auto-expanded at >=1024px if user hasn't manually collapsed
  - Toggle button always visible

### Spacing
- **375px**: 16px page padding, 8px element gap
- **768px**: 20px page padding, 12px element gap
- **1024px+**: 24px page padding, 16px element gap

### Typography
- All breakpoints: minimum 16px for body text on mobile (prevents iOS auto-zoom)
- Desktop: 14px base is acceptable (no auto-zoom on desktop)
- Mobile inputs: 16px minimum font-size (prevents iOS zoom on focus)

### Touch Targets
- All interactive elements: minimum 44x44pt on mobile
- Desktop: 32px minimum (mouse precision is higher)

### Safe Areas
- `padding-bottom: env(safe-area-inset-bottom)` on bottom tab bar
- `padding-top: env(safe-area-inset-top)` on status bar area
- Use `100dvh` not `100vh` for full-height mobile layouts
