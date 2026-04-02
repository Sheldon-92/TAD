# Information Architecture Research — SaaS PM Tool for Indie Devs

## 1. Competitor Navigation Analysis

### Linear (Source: linear.app/now/how-we-redesigned-the-linear-ui)
- **Pattern**: Left sidebar (collapsible) + main content area
- **Top-level nav items**: ~6 (My Issues, Projects, Teams, Cycles, Views, Settings)
- **Hierarchy depth**: 2 levels (Workspace > Team > Project > Issue)
- **Key design**: Sidebar dimmed vs content area bright; keyboard-first (Cmd+K omnisearch)
- **Mobile**: Bottom tab bar (customizable since Jan 2026)
- **Visual**: Minimalist, low visual noise, speed-focused

### Jira (Source: atlassian.com/software/jira)
- **Pattern**: Left sidebar (persistent) + top project nav + main content
- **Top-level nav items**: ~8+ (Your Work, Projects, Filters, Dashboards, People, Apps, Plans, Settings)
- **Hierarchy depth**: 3+ levels (Organization > Project > Board/Backlog > Issue)
- **Key design**: Dense with controls, nested menus, highly configurable
- **Mobile**: Simplified app with bottom nav
- **Visual**: Blue accent, information-dense, enterprise-oriented

### Asana (Source: asana.com/guide/help/fundamentals/navigating-asana)
- **Pattern**: Left sidebar (auto-collapse or pinned) + main content
- **Top-level nav items**: ~5 (My Tasks, Inbox, Dashboard, Teams/Projects, Reporting)
- **Hierarchy depth**: 2-3 levels (My Views > Teams > Projects > Tasks)
- **Key design**: Sidebar organized by Teams; user can curate/reorder; recent focus on "mode of work" navigation
- **Mobile**: Bottom tab bar
- **Visual**: Coral-pink accent, friendly, approachable

### Notion (Source: notion.so)
- **Pattern**: Left sidebar (tree/page hierarchy) + main content canvas
- **Top-level nav items**: ~4 (Search, Workspace pages, Shared, Private)
- **Hierarchy depth**: Unlimited (nested pages)
- **Key design**: Free-form page hierarchy; databases as views; no fixed navigation structure
- **Mobile**: Simplified sidebar as overlay
- **Visual**: Black-white, clean, content-focused

## 2. Navigation Pattern Decision: WHY Sidebar (Not Top Nav)

**Decision: Collapsible left sidebar**

**Evidence-based reasoning:**
1. **All 4 competitors use left sidebar** — Linear, Jira, Asana, Notion all converge on this pattern. This is not coincidence: PM tools have deep hierarchies (Workspace > Project > Board > Issue) that need persistent vertical space. Top nav caps out at ~7 items and cannot show hierarchy depth.
2. **Vertical real estate for deep navigation**: PM tools need to show: team, multiple projects, boards within projects, saved views/filters. A sidebar can display 15-20 items; top nav is limited to ~7 without dropdowns.
3. **Keyboard-driven users expect sidebar**: Linear's success with indie devs is partly attributed to keyboard-first navigation (Cmd+K) combined with a scannable sidebar. Our target users (indie devs) are keyboard-heavy.
4. **Sidebar collapse for focus mode**: Both Linear and Asana support collapsing sidebar to maximize content area — essential for board/kanban views that need horizontal space.

**Why NOT top nav:**
- Top nav works for marketing sites or apps with <5 flat pages (e.g., a simple CRM)
- PM tools have hierarchical navigation (workspace > project > view) — top nav cannot express this without mega-menus, which increase cognitive load
- Horizontal space is precious for board views (Kanban columns) — a top nav wastes vertical space AND doesn't help with hierarchy

## 3. Content Inventory

| Content/Function | Type | User Frequency | Priority | Notes |
|---|---|---|---|---|
| Board/Kanban View | Page | High (daily) | P0 | Core workflow for issue tracking |
| Issue Detail | Panel/Page | High (daily) | P0 | View/edit individual issues |
| Issue List/Backlog | Page | High (daily) | P0 | Bulk view of all issues |
| Create Issue | Modal | High (daily) | P0 | Quick creation is critical |
| Search (Cmd+K) | Modal overlay | High (daily) | P0 | Global search + command palette |
| Projects List | Page | Medium (weekly) | P1 | Navigate between projects |
| Timeline/Gantt | Page | Medium (weekly) | P1 | Visual project timeline |
| Settings (Project) | Page | Low (monthly) | P2 | Labels, statuses, workflows |
| Settings (Workspace) | Page | Low (monthly) | P2 | Members, billing, integrations |
| Team/Members | Page | Low (monthly) | P2 | Manage team permissions |
| Notifications/Inbox | Panel/Page | Medium (daily) | P1 | Activity feed, mentions |
| My Issues | Page | High (daily) | P0 | Personal issue dashboard |
| Cycles/Sprints | Page | Medium (weekly) | P1 | Sprint planning |
| Billing | Page | Low (rarely) | P3 | Subscription management |
| Integrations | Page | Low (rarely) | P3 | GitHub, Slack connections |

## 4. Navigation Structure (Derived)

**Left Sidebar (6 primary items — within the 7-item rule):**

1. **My Issues** — Personal dashboard (assigned to me, created by me, watching)
2. **Projects** — Expandable tree: each project has sub-items (Board, Backlog, Timeline)
3. **Inbox** — Notifications, mentions, updates
4. **Cycles** — Sprint/cycle planning and tracking
5. **Views** — Saved custom filters and views
6. **Settings** — Workspace, billing, integrations (bottom-pinned)

**High-frequency reachability check:**
- Board view: Sidebar > Project > Board = 2 clicks (PASS)
- Create issue: Cmd+C or "+" button always visible = 1 action (PASS)
- Search: Cmd+K anywhere = 1 action (PASS)
- Issue detail: Click any issue from board/list = 1 click from board (PASS)
- My Issues: Sidebar top item = 1 click (PASS)

## 5. User Roles & Navigation Differences

| Role | Sees in Nav | Hidden/Disabled |
|---|---|---|
| Owner | Everything | Nothing |
| Admin | Everything except Billing details | Billing shows "Contact Owner" |
| Member | Projects, My Issues, Inbox, Views, Cycles | Settings (project-level only), no workspace settings |
| Viewer | Projects (read-only), My mentions in Inbox | No create buttons, no settings, no cycles management |
