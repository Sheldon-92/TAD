# Wireframe Research — SaaS PM Tool

## 1. Layout Reference Analysis

### Linear — Minimal List-Based
- Board: Clean Kanban with minimal card info (title + status dot + assignee avatar)
- Issue detail: Side panel sliding from right (not full page navigation)
- Navigation: Slim sidebar (~200px), content maximized
- Density: Low — lots of whitespace, 1-2 lines per issue card
- Core interaction: Keyboard-first, drag-and-drop secondary

### Jira — Dense Panel-Based
- Board: Kanban with rich cards (title, assignee, priority, labels, story points all visible)
- Issue detail: Full-page navigation with breadcrumbs
- Navigation: Wide sidebar (~250px) with nested project trees
- Density: High — maximum information visible without clicking
- Core interaction: Mouse-heavy, many dropdown menus

### Notion — Block/Database View
- Board: Database view toggled between Table/Board/Calendar/Timeline
- Issue detail: Full page that IS the database row
- Navigation: Tree sidebar with infinite nesting
- Density: Variable — user controls via properties shown/hidden
- Core interaction: Block-based editing, slash commands

## 2. Three UX Approaches

### Approach 1: "Linear-style Minimal List" (Safe Approach)
- **UX Philosophy**: Speed and focus — show less, move faster
- **Layout**: Slim sidebar (200px) | Full-width content | Right-slide issue panel
- **Board**: Minimal cards (title + avatar + priority dot). Column headers show count only.
- **Issue detail**: Side panel overlay (480px) — never leave the board context
- **Core pattern**: Keyboard shortcuts for everything; mouse as fallback
- **Risk**: Power users wanting dense info (e.g., seeing story points, labels on cards) may feel limited

| Criterion | Score (1-5) | Rationale |
|---|---|---|
| Learning cost | 5 (very low) | Familiar pattern, minimal UI elements to learn |
| Information density | 2 (low) | Intentionally sparse — need to click for details |
| Mobile friendliness | 4 (good) | Minimal layout adapts well to small screens |
| **Total** | **11** | |

### Approach 2: "Jira-style Dense Panel" (Information-Dense)
- **UX Philosophy**: Everything visible — minimize clicks, maximize scan-ability
- **Layout**: Wide sidebar (260px) with project tree | Split main: list left + detail right
- **Board**: Rich cards showing title, assignee, priority, labels, due date, story points
- **Issue detail**: Split-pane — issue list stays visible on left, detail on right
- **Core pattern**: Persistent panels, heavy use of inline editing
- **Risk**: Overwhelming for indie devs who want simplicity; poor mobile experience

| Criterion | Score (1-5) | Rationale |
|---|---|---|
| Learning cost | 2 (high) | Many panels, dense controls, configuration-heavy |
| Information density | 5 (very high) | Everything visible without clicking |
| Mobile friendliness | 1 (poor) | Multi-panel layout doesn't work on mobile |
| **Total** | **8** | |

### Approach 3: "Context-Switch Minimal" (Hybrid — our innovation)
- **UX Philosophy**: Focused context — one task at a time, smooth transitions
- **Layout**: Collapsible sidebar (48px collapsed / 220px expanded) | Full content | Floating action panel
- **Board**: Medium-density cards (title + priority + assignee + 1 label). Clean but informative.
- **Issue detail**: Expanding card animation — card expands in-place to full detail (not a separate page or side panel)
- **Core pattern**: Cmd+K command palette as primary navigation; sidebar as secondary; smooth transitions between views
- **Risk**: In-place expansion animation may feel slow; novel pattern requires user learning

| Criterion | Score (1-5) | Rationale |
|---|---|---|
| Learning cost | 3 (medium) | Novel expand pattern needs discovery, but Cmd+K is familiar |
| Information density | 4 (good) | Medium density + full detail on expand |
| Mobile friendliness | 4 (good) | Single-column focus works well on mobile; swipe between columns |
| **Total** | **11** | |

## 3. Approach Selection

**Selected: Approach 1 (Linear-style Minimal List)** with elements from Approach 3's Cmd+K command palette.

**Reasoning:**
1. **Target user = indie devs**: They value speed over configurability. Linear's explosive growth with engineering teams validates this.
2. **Tied score (11 vs 11)**: Approach 1 and 3 tie on total, but Approach 1 scores 5 on learning cost — critical for a new product competing for adoption against established tools.
3. **Risk mitigation**: Approach 3's novel expand-in-place pattern is unvalidated. For an MVP competing against Linear/Jira, using proven patterns reduces adoption friction.
4. **Cmd+K from Approach 3**: We adopt the command palette as primary power-user navigation — this is now standard (Linear, GitHub, VS Code all use it).

**What we borrow from Approach 3**: Collapsible sidebar (48px icon-only mode) to maximize board space.
