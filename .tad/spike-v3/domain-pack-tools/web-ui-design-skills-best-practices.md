# Web UI Design Skills Best Practices — Research Summary

**Sources**: 8 GitHub repositories + 2 reference guidelines researched (2026-04-01)
**Purpose**: Reference for web-ui-design.yaml domain pack creation

---

## Repositories Analyzed

| Repo | Stars | Last Updated | Key Focus |
|------|-------|-------------|-----------|
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | ~16.9k | 2026-03 | Comprehensive design intelligence: 50+ styles, 161 palettes, 99 UX guidelines, 10 stacks |
| [carmahhawwari/ui-design-brain](https://github.com/carmahhawwari/ui-design-brain) | ~200+ | 2026-03 | 60 component patterns with best practices, layout patterns, anti-patterns, 5 presets |
| [Magdoub/claude-wireframe-skill](https://github.com/Magdoub/claude-wireframe-skill) | ~500+ | 2026-02 | B&W wireframe prototyping with 5 parallel UX approaches + color variants |
| [vercel-labs/agent-skills (web-design-guidelines)](https://github.com/vercel-labs/agent-skills) | ~2k+ | 2026-03 | 100+ audit rules: accessibility, performance, UX from Web Interface Guidelines |
| [wilwaldon/Claude-Code-Frontend-Design-Toolkit](https://github.com/wilwaldon/Claude-Code-Frontend-Design-Toolkit) | ~1k+ | 2026-02 | Meta-collection: 70+ tools across 10 categories for frontend design quality |
| [Owl-Listener/designer-skills](https://github.com/Owl-Listener/designer-skills) | ~418 | 2026-03 | 63 skills + 27 commands in 8 plugins covering full design lifecycle |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | ~1k+ | 2026-03 | 220+ skills including UX Researcher, UI Design, a11y Auditor, Design System Architect |
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | ~5k+ | 2026-03 | Community .cursorrules collection including React/shadcn/Tailwind UI patterns |

---

## By Capability

### Information Architecture

**Best step design** (from Owl-Listener/designer-skills):
- `/ux-strategy:frame-problem` — Structure the design challenge before jumping to solutions
- `/ux-strategy:strategize` — Complete UX strategy development with user flows
- `/ux-strategy:benchmark` — Competitive analysis for navigation patterns
- `/design-research:discover` — Full research discovery cycle
- `/design-research:synthesize` — Research data analysis into actionable IA

**Best frameworks**:
- User Flow vs Sitemap methodology: create user flows FIRST (paths/actions), THEN organize site structure around them (from IA research)
- Card sorting and tree testing for navigation validation (Optimal Workshop methodology)
- Progressive Disclosure pattern for complex information hierarchies (Magdoub wireframe skill)
- Hub-and-Spoke pattern for task-centric applications
- Search-First pattern for content-heavy applications

**Quality standards** (from ui-ux-pro-max):
- Bottom navigation max 5 items; use labels with icons
- Web: use breadcrumbs for 3+ level deep hierarchies
- All key screens reachable via deep link / URL
- Current location must be visually highlighted
- Primary nav vs secondary nav must be clearly separated
- Navigation placement must stay same across all pages
- Core navigation must remain reachable from deep pages

**Anti-patterns**:
- Don't mix Tab + Sidebar + Bottom Nav at same hierarchy level (ui-ux-pro-max)
- Modals must not be used for primary navigation flows (ui-ux-pro-max)
- Hamburger menu on desktop — use visible navigation when space allows (ui-design-brain)
- Never silently reset navigation stack or unexpectedly jump to home (ui-ux-pro-max)
- Bottom nav is for top-level screens only; never nest sub-navigation inside (ui-ux-pro-max)

---

### Wireframing

**Best step design** (from Magdoub/claude-wireframe-skill):
1. **Codebase Research**: Scan CSS/JS/templates extracting navigation structure, layout patterns (grid/sidebar/full-width/card), content hierarchy, interactive elements, responsive breakpoints
2. **Screenshot Collection**: Request 2-3 screenshots of key pages; confirm target platform (Mobile/Desktop/Web/Both)
3. **Design Context Creation**: Document app overview, target platform, layout patterns, navigation, page types, interaction patterns, content hierarchy, UX conventions in `design-context.md`
4. **Feature Parsing**: Extract feature description, identify optimization intent ("more conversions," "less drop-offs," "better discoverability")
5. **Generate 5 UX Approaches**:
   - Option 1: Safe — replicate existing patterns from design context
   - Options 2-5: Choose from Progressive Disclosure, Dashboard-First, Wizard/Step-by-Step, Hub-and-Spoke, Split View, Card-Based, Conversational, Kanban, Timeline, Search-First, etc.
6. **B&W Wireframe Rules**: Strict palette (#000, #333, #666, #999, #ccc, #eee, #fff), system fonts only, no external dependencies, solid borders only, annotations (1)(2)(3) visible on wireframe
7. **Color Variants Phase**: 5 parallel agents add Clean (flat color, no effects) + Polished (gradients, shadows, animations, Google Fonts) variants
8. **Scoring**: Compact scoring table per option (name, 1-line description, 1-5 stars) + recommendation rationale

**Best frameworks**:
- 5-option divergent exploration: 1 safe + 4 exploratory approaches
- UX philosophy labeling: each option gets a named design philosophy (Progressive Disclosure, Command Palette, Feed-Based, etc.)
- 3-tier visual fidelity: Wireframe (B&W) -> Clean (flat color) -> Polished (full treatment)

**Quality standards**:
- One HTML structure shared across all sub-tabs via class toggle
- Variant CSS overrides only: color, background, border-color, box-shadow, font-family, transition
- Max 200 lines per variant CSS
- Interactive elements in wireframes: clickable tabs, typeable inputs, hover states
- No dark backgrounds in Polished variant — keep light/white base

**Anti-patterns** (from wireframe skill):
- Decorative borders overlapping content — add adequate padding/margin
- Full-width sections clipped by parent containers
- Flat backgrounds where gradients specified — use high-contrast gradient stops
- Content escaping browser frame — use overflow: hidden
- Dark mode in Polished — NEVER use dark backgrounds (#0a-#2f range)

---

### Visual Design

**Best step design** (from ui-ux-pro-max):
1. **Analyze Requirements**: Extract product type, target audience, style keywords, tech stack
2. **Generate Design System**: Run design system generator with multi-dimensional keywords (product + industry + tone + density)
3. **Persist Design System**: Create MASTER.md (global source of truth) + pages/ folder for page-specific overrides
4. **Supplement with Detailed Searches**: Deep-dive into style, color, typography, UX domains as needed
5. **Apply Stack Guidelines**: Get implementation-specific guidance for chosen framework

**Color palette creation** (from ui-ux-pro-max + ui-design-brain):
- Define semantic color tokens: primary, secondary, error, surface, on-surface
- Don't use raw hex in components — always use tokens
- Dark mode uses desaturated/lighter tonal variants, NOT inverted colors
- Test contrast separately for each mode
- Foreground/background pairs must meet 4.5:1 (AA) or 7:1 (AAA)
- Functional color (error red, success green) must include icon/text — never color-only meaning
- One strong color moment — start with neutral palette, introduce one confident accent (ui-design-brain)

**Typography system** (from ui-ux-pro-max):
- Line-height: 1.5-1.75 for body text
- Limit to 65-75 characters per line (mobile 35-60)
- Consistent type scale: 12, 14, 16, 18, 24, 32
- Font-weight hierarchy: Bold headings (600-700), Regular body (400), Medium labels (500)
- Use tabular/monospaced figures for data columns, prices, timers
- Minimum 16px body text on mobile (avoids iOS auto-zoom)

**Design presets** (from ui-design-brain):
1. **Modern SaaS** (default): Neutral palette + one strong accent, 8px grid, generous whitespace
2. **Apple-level Minimal**: Near-monochrome warm grays, large type hierarchy, tight tracking, micro-interactions 150-250ms
3. **Enterprise/Corporate**: Information-dense, compact spacing (4/8/12/16/24px), robust forms, full keyboard nav
4. **Creative/Portfolio**: Bold, expressive, asymmetric layouts, dramatic scale contrast, editorial typography
5. **Data Dashboard**: Data-dense, optimized for scannability, consistent vertical alignment, KPI -> trend -> detail hierarchy

**Best frameworks**:
- OKLCH color mathematics for harmonious palettes (Frontend Design Toolkit)
- Semantic token mapping: design tokens aren't just hex codes but represent decisions about how a system scales
- Master + Overrides pattern: global design system + page-specific deviations

**Anti-patterns** (from ui-design-brain):
- Purple-on-white gradients / Inter+Roboto defaults / evenly-spaced card grids (generic aesthetic)
- Rainbow badges — every status a different bright color with no semantic meaning
- Equal-weight buttons — must establish primary/secondary/tertiary hierarchy
- No emojis as structural icons — use vector-based SVG icons (Lucide, Heroicons)
- Mixing filled and outline icons at same hierarchy level
- Mixing thick and thin stroke styles arbitrarily

---

### Interaction Design

**Best step design** (from Owl-Listener/designer-skills + ui-ux-pro-max):
- `/interaction-design:design-interaction` — Full interaction flow design
- `/interaction-design:map-states` — State machine modeling for UI states
- `/interaction-design:error-flow` — Error handling design patterns

**Micro-interaction standards** (from ui-ux-pro-max):
- 150-300ms for micro-interactions; complex transitions <=400ms; avoid >500ms
- Use transform/opacity only; never animate width/height/top/left
- Use ease-out for entering, ease-in for exiting; avoid linear for UI transitions
- Exit animations shorter than enter (~60-70% of enter duration)
- Stagger list/grid item entrance by 30-50ms per item
- Animations must be interruptible; user tap/gesture cancels immediately
- Never block user input during animation
- Every animation must express cause-effect relationship, not decorative
- Prefer spring/physics-based curves for natural feel
- Subtle scale (0.95-1.05) on press for tappable cards/buttons
- Forward navigation animates left/up; backward animates right/down
- Modals/sheets animate from trigger source (scale+fade or slide-in)
- Fading elements should not linger below opacity 0.2

**Touch & interaction** (from ui-ux-pro-max):
- Minimum touch targets: 44x44pt (Apple) / 48x48dp (Material)
- 8px/8dp minimum gap between targets
- Click/tap for primary interactions; don't rely on hover alone
- Disable buttons during async operations; show spinner or progress
- Use touch-action: manipulation to reduce 300ms delay
- Haptic feedback for confirmations; avoid overuse
- Show clear swipe action affordance (chevron, label, tutorial)
- Use movement threshold before starting drag (prevent accidental drags)

**Vercel Web Interface Guidelines interaction rules**:
- `touch-action: manipulation` on touch targets
- Set `-webkit-tap-highlight-color` intentionally
- `overscroll-behavior: contain` in modals/drawers
- Disable text selection during drag, use `inert`
- `autoFocus` sparingly — desktop only, single primary input
- Honor `prefers-reduced-motion`
- Never `transition: all` — be explicit about animated properties
- Animations interruptible

**Anti-patterns** (Vercel guidelines):
- `user-scalable=no` or `maximum-scale=1` — never disable zoom
- `onPaste` with `preventDefault` — never block paste
- `transition: all` — always be explicit
- `outline-none` without replacement focus state
- Inline `onClick` navigation without `<a>` — use semantic elements

---

### Design System

**Best step design** (from Owl-Listener/designer-skills):
- `/design-systems:audit-system` — System consistency review
- `/design-systems:create-component` — Component specification with variants, states, accessibility
- `/design-systems:tokenize` — Extract design tokens from existing code

**Component specification pattern** (from ui-design-brain, 60 components):

Each component entry includes:
- **Aliases**: Alternative names for recognition
- **Description**: Concise purpose statement
- **Best practices**: 3-8 guidelines covering accessibility, sizing, behavior
- **Common layouts**: 2-4 implementation patterns

**Top 15 component rules** (from ui-design-brain):

| Component | Key Rule |
|-----------|----------|
| Button | Verb-first labels ("Save changes" not "Submit"); one primary per section |
| Card | Media -> title -> meta -> action; shadow OR border, not both |
| Modal | Trap focus; X + Cancel + Escape to close; return focus on close |
| Navigation | 5-7 items max; clear active state |
| Table | Sticky header; right-align numbers; sortable columns |
| Tabs | 2-7 tabs; active indicator; accordion on mobile |
| Form | Single column; labels above; inline validation on blur |
| Toast | Auto-dismiss 4-6s; undo action for destructive ops; stack newest on top |
| Alert | Semantic colors + icon; max 2 sentences |
| Drawer | Right for detail, left for nav; 320-480px desktop width |
| Search input | Cmd/Ctrl+K shortcut; debounce 200-300ms |
| Empty state | Illustration + headline + CTA; positive framing |
| Skeleton | Match actual layout shape; shimmer animation; show after 300ms delay |
| Badge | 1-2 words; pill shape for status; limited color palette |
| Dropdown menu | 7+/-2 items; destructive actions last in red |

**Design token standards** (from Frontend Design Toolkit):
- Single `--brand-hue` variable controls entire palette via OKLCH mathematics
- Semantic color mapping: primary, secondary, error, surface, on-surface
- Tailwind v4 `@theme` blocks with OKLCH color space
- Token hierarchy: global tokens -> semantic tokens -> component tokens
- Design tokens represent decisions about how a system scales, not just hex codes

**Icon standards** (from ui-ux-pro-max):
- Vector-only assets (SVG or platform vector icons)
- Icon sizes as design tokens (icon-sm, icon-md=24pt, icon-lg)
- Consistent stroke width within same visual layer
- One icon style per hierarchy level (filled vs outline discipline)
- Touch target minimum 44x44pt interactive area (use hitSlop if icon smaller)
- Icon contrast: WCAG 4.5:1 for small elements, 3:1 for larger UI glyphs

**Quality standards for "done"** (from ui-design-brain):
- Output matches expectations from a senior product designer at a top SaaS company
- Clean visual rhythm with intentional asymmetry
- Obvious interactive affordances (hover, focus, active states)
- Graceful edge cases (empty states, loading, error)
- Responsive without breakpoint artifacts

---

### Responsive Design

**Best step design** (from ui-ux-pro-max + Owl-Listener):
- `/ui-design:responsive-audit` — Review responsive behavior across breakpoints

**Breakpoint system** (from ui-ux-pro-max):
- Mobile-first design, then scale up
- Systematic breakpoints: 375 / 768 / 1024 / 1440
- `width=device-width initial-scale=1` (never disable zoom)
- Minimum 16px body text on mobile (avoids iOS auto-zoom)
- Mobile 35-60 chars per line; desktop 60-75 chars
- No horizontal scroll on mobile; content fits viewport width

**Spacing system** (from ui-ux-pro-max + ui-design-brain):
- 4pt/8dp incremental spacing system (Material Design)
- Define layered z-index scale: 0 / 10 / 20 / 40 / 100 / 1000
- Consistent max-width on desktop (max-w-6xl / 7xl)
- Section spacing hierarchy: 16/24/32/48 by hierarchy level
- Prefer `min-h-dvh` over `100vh` on mobile

**Layout rules** (from ui-ux-pro-max):
- Fixed navbar/bottom bar must reserve safe padding for underlying content
- Avoid nested scroll regions that interfere with main scroll
- Show core content first on mobile; fold or hide secondary content
- Establish hierarchy via size, spacing, contrast — not color alone
- Large screens (>=1024px) prefer sidebar; small screens use bottom/top nav
- Adaptive gutters by breakpoint — increase horizontal insets on larger widths

**Vercel safe area rules**:
- Full-bleed layouts use `env(safe-area-inset-*)`
- Prevent unwanted scrollbars
- Flex/grid over JS measurement
- Safe-area compliance for headers, tab bars, CTA bars

**Anti-patterns**:
- Same narrow gutter on all device sizes/orientations
- Full-width long text on tablets (hurts readability)
- Scroll content obscured by sticky headers/footers without insets
- `100vh` on mobile (use `dvh` instead)

---

### Usability Review / Audit

**Best step design** (from Vercel web-design-guidelines):
1. Fetch latest guidelines (100+ rules dynamically loaded)
2. Read target files specified by user
3. Validate against ALL rules
4. Report issues in `file:line` format — terse findings, state issue + location

**Audit categories** (from Vercel Web Interface Guidelines, 100+ rules):

| Category | Key Rules Count | Focus |
|----------|----------------|-------|
| Accessibility | ~15 rules | aria-label, semantic HTML, keyboard handlers, headings, skip link |
| Focus States | ~4 rules | focus-visible:ring, never outline-none without replacement, :focus-within |
| Forms | ~15 rules | autocomplete, correct input types, inline errors, unsaved warning |
| Animation | ~6 rules | prefers-reduced-motion, transform/opacity only, interruptible |
| Typography | ~6 rules | curly quotes, non-breaking spaces, tabular-nums, text-wrap: balance |
| Content Handling | ~4 rules | overflow handling, empty states, flex min-w-0 |
| Images | ~3 rules | explicit width/height, lazy loading, fetchpriority |
| Performance | ~6 rules | virtualize 50+ item lists, batch DOM reads, preconnect, font preload |
| Navigation & State | ~4 rules | URL reflects state, deep-link stateful UI, destructive action confirmation |
| Touch & Interaction | ~5 rules | touch-action, tap-highlight, overscroll-behavior, inert |
| Dark Mode | ~3 rules | color-scheme: dark, theme-color meta, explicit select colors |
| Content & Copy | ~8 rules | active voice, Title Case, numerals, specific labels, error messages with fix |

**Heuristic evaluation** (from Owl-Listener/designer-skills):
- `/prototyping-testing:evaluate` — Heuristic evaluation against established frameworks
- `/prototyping-testing:test-plan` — Testing framework creation
- `/prototyping-testing:experiment` — A/B experiment design

**Quality standards for passing audit**:
- All interactive elements have :hover, :focus-visible, :active, :disabled states
- Color contrast ratio >= 4.5:1 for normal text, >= 3:1 for large text
- All form inputs have visible labels (not placeholder-only)
- All images have explicit width/height dimensions
- All icon-only buttons have aria-label
- URL reflects current UI state (filters, tabs, pagination)
- `prefers-reduced-motion` honored for all animations
- Lists with 50+ items are virtualized
- Critical fonts preloaded with font-display: swap

**Pre-delivery checklist** (from ui-ux-pro-max — comprehensive):

Visual Quality:
- [ ] No emojis as icons (use SVG)
- [ ] All icons from consistent family and style
- [ ] Semantic theme tokens used consistently (no ad-hoc hex)
- [ ] Pressed-state visuals do not shift layout

Interaction:
- [ ] All tappable elements provide pressed feedback
- [ ] Touch targets >= 44x44pt iOS / 48x48dp Android
- [ ] Micro-interaction timing 150-300ms with native easing
- [ ] Disabled states visually clear and non-interactive
- [ ] Screen reader focus order matches visual order

Light/Dark Mode:
- [ ] Primary text contrast >= 4.5:1 in both modes
- [ ] Secondary text contrast >= 3:1 in both modes
- [ ] Both themes tested before delivery

Layout:
- [ ] Safe areas respected for headers, tab bars, bottom CTA
- [ ] Verified on small phone, large phone, tablet (portrait + landscape)
- [ ] 4/8dp spacing rhythm maintained
- [ ] Long-form text readable on larger devices

Accessibility:
- [ ] All meaningful images/icons have accessibility labels
- [ ] Form fields have labels, hints, clear error messages
- [ ] Color not the only indicator
- [ ] Reduced motion and dynamic text size supported

---

## Cross-Cutting Standards (Referenced by Multiple Sources)

### WCAG 2.1 AA Compliance (Universal)
- Normal text: minimum 4.5:1 contrast ratio
- Large text (18px+ or 14px+ bold): minimum 3:1 contrast ratio
- Focus indicators: 2-4px visible rings on all interactive elements
- Full keyboard navigation with tab order matching visual order
- Sequential heading hierarchy (h1-h6, no skips)
- Information must not rely on color alone
- Support system text scaling; avoid truncation
- Respect `prefers-reduced-motion`
- Skip-to-main-content links for keyboard users

### Performance (Referenced by 3+ repos)
- Skeleton screens preferred over spinners (show after 300ms)
- Lazy load below-fold content
- Virtualize lists with 50+ items
- WebP/AVIF with responsive images (srcset/sizes)
- font-display: swap to avoid invisible text
- Inline critical CSS, lazy load the rest
- Keep per-frame work under ~16ms for 60fps
- Provide visual feedback within 100ms of tap

### Platform-Specific (from ui-ux-pro-max)
- iOS: use bottom Tab Bar, Dynamic Type, safe areas
- Android: use Top App Bar, Material state layers, 48dp targets
- Web: breadcrumbs for 3+ levels, URL state reflection
- Respect platform idioms: navigation, controls, typography, motion

---

## Methodology References Across Sources

| Framework/Methodology | Referenced By |
|-----------------------|--------------|
| WCAG 2.1 AA / 2.2 | All repos |
| Material Design 3 | ui-ux-pro-max, ui-design-brain |
| Apple Human Interface Guidelines | ui-ux-pro-max |
| Atomic Design (Brad Frost) | alirezarezvani/claude-skills |
| Jakob Nielsen's 10 Heuristics | Owl-Listener (evaluate command) |
| Fitts's Law | alirezarezvani/claude-skills |
| Hick's Law | alirezarezvani/claude-skills |
| Gestalt Principles | alirezarezvani/claude-skills |
| OKLCH Color Mathematics | Frontend Design Toolkit |
| 8px Grid System | ui-ux-pro-max, ui-design-brain |
| Progressive Disclosure | Magdoub wireframe skill |
| Don Norman's Design Principles | Owl-Listener (Wondelai skills) |
| Cialdini (Persuasion) | Owl-Listener (Wondelai UX/Growth) |

---

## Key Takeaways for Domain Pack Design

1. **Step-driven workflow works**: The most effective skills (ui-ux-pro-max, wireframe) follow explicit multi-step workflows: analyze -> generate system -> supplement -> implement
2. **Component-level knowledge is high value**: ui-design-brain's per-component best practices + anti-patterns pattern is the most actionable format
3. **Presets accelerate decisions**: Having 4-5 named design directions (Modern SaaS, Enterprise, Creative, etc.) prevents analysis paralysis
4. **Checklists close the loop**: Pre-delivery checklists with specific thresholds (4.5:1 contrast, 44px targets, 150-300ms timing) make "done" measurable
5. **Anti-patterns prevent common mistakes**: Every good skill lists explicit anti-patterns (10 from ui-design-brain, 12+ from Vercel guidelines)
6. **Dynamic rule loading**: Vercel's approach of fetching latest rules via URL ensures guidelines stay current
7. **Separation of concerns**: Design system (tokens + rules) is separate from design review (audit against rules) — different tools for different workflow stages
8. **Master + Overrides pattern**: Global design system with page-specific deviations (ui-ux-pro-max) is the right persistence model
