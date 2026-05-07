# Web UI Design SKILL.md — Research Findings
> Source: NotebookLM notebook `fd4f9117` (80+ sources: deep research + GitHub awesome-lists + tool repos + company design systems)
> Date: 2026-05-07 | Round 1: 9 capability questions | Round 2: 4 gap-fill questions

---

## C1: Information Architecture

### Tools
- **Mermaid CLI**: `npm install -g @mermaid-js/mermaid-cli` → `mmdc -i input.mmd -o output.svg`
- **D2**: `curl -fsSL https://d2lang.com/install.sh | sh` → `d2 architecture.d2 output.svg`
- **next-sitemap**: `npm install next-sitemap` → `npx next-sitemap` (Next.js specific)

### Navigation Decision Framework
| Pattern | When | Breakpoint |
|---------|------|-----------|
| Bottom Tab Bar | Mobile, ≤5 core actions, thumb-friendly | ≤480px |
| Hamburger | Mobile, >5 items | ≤768px |
| Top Bar / Horizontal | Desktop | >768px |
| Sidebar | Large content apps | >1024px |
| Mega Menu | Massive content | >1200px |
| Breadcrumbs | Deep content (>3 levels) | All |

### Touch Targets
- Minimum 44x44px for all interactive elements

### Breakpoints (2026 standard)
- Mobile: <480px (base styles, no media query)
- Tablet: 481px–768px
- Small Desktop: 769px–1024px
- Large Screen: ≥1200px

---

## C2: Wireframing

### Headless Component Libraries (structural wireframing in code)
| Library | Type | Install |
|---------|------|---------|
| Ark UI | Headless, framework-agnostic | `npm install @ark-ui/react` |
| Headless UI | Headless, Tailwind-native | `npm install @headlessui/react` |
| Base UI | Headless, unstyled | `npm install @mui/base` |
| DaisyUI | Tailwind plugin, CSS-only | `npm install daisyui` |

### AI Wireframing Tools
- **Anima Playground**: prompt → React app, MCP integration with Claude Code
- **Builder.io Visual Copilot**: CLI tool to analyze codebase patterns and generate matching code
- **v0.dev**: prompt → React component (Vercel)

### Workflow: Prompt → Wireframe HTML
1. Context ingestion (read design tokens, constraints via MCP)
2. Structural generation (unstyled React/HTML DOM tree)
3. Apply headless primitives (Ark UI / React Aria for functional placeholders)
4. Post-conversion cleanup (semantic HTML, relative units, purge unused CSS)

---

## C3: Visual Design

### Design Token Tools
| Tool | Install | Build |
|------|---------|-------|
| Style Dictionary | `npm install -D style-dictionary` | `npx style-dictionary build` |
| Open Props | (npm package) | `npm run gen:op`, `npm run bundle` |
| Tokens Studio | `yarn --frozen-lockfile` | `yarn build` |

### Color Rules
- **60-30-10 Rule**: 60% dominant, 30% secondary, 10% accent
- **APCA** (replaces 4.5:1 ratio): LC ≥60 for body text, ≥45 for headlines

### Typography
- **Fluid**: `font-size: clamp(1rem, 0.5vw + 0.875rem, 1.125rem)`
- 1-2 typefaces max, scale: 12/16/24/32px
- Line height: 1.4–1.6
- Spacing: 4pt/8pt system

### Anti-AI-Slop Patterns
| Anti-Pattern | Fix |
|-------------|-----|
| Div soup + hardcoded pixels | Semantic HTML + relative units (rem, vw) |
| Primitive token names (blue-500) | Semantic naming (color-button-background-brand) |
| Purple/blue gradient explosion | One primary + one accent + neutrals |
| Sluggish animations | ≤100ms feedback, ≤300ms transitions |

### Bold Aesthetic Directions
- Asymmetric/layered layouts (not rigid grids)
- Container queries for component-level responsive
- First-class dark mode via tokens
- Purposeful glassmorphism/neumorphism with APCA compliance

---

## C4: Interaction Design

### Animation Libraries
| Library | Install |
|---------|---------|
| Framer Motion | `npm install framer-motion` |
| Lottie | `npm install lottie-react` |
| GSAP | `npm install gsap` |

### Timing Rules
- ≤100ms: immediate feedback (button press, hover)
- ≤300ms: transitions, celebratory animations

### Accessible Interaction Libraries
| Library | Purpose |
|---------|---------|
| React Aria (Adobe) | Hooks for keyboard, focus, screen reader |
| Radix UI Primitives | Unstyled components with built-in a11y |

### Gestures
- Framer Motion has built-in drag/tap/hover/focus
- @use-gesture/react for complex pinch/swipe

### Loading States
- Skeleton screens (preserve layout structure)
- Progressive/lazy loading (`loading="lazy"`)
- Contextual progress indicators with text ("Uploading... 80%")

---

## C5: Design System

### Component Library Selection Matrix (2026)
| Library | Type | A11y | Bundle | Framework |
|---------|------|------|--------|-----------|
| shadcn/ui | Copy-paste | AAA | 10-20KB | React/Next.js + Tailwind |
| Radix UI | Headless | AAA | 3-5KB/component | React |
| Headless UI | Headless | AAA | ~4KB/component | React, Vue + Tailwind |
| Ark UI | Headless | AAA | ~3KB/component | React, Vue, Solid, Svelte |
| DaisyUI | CSS Plugin | Good | ~20KB | Framework-agnostic + Tailwind |
| MUI | Styled | AA | 100-200KB | React |
| Chakra UI | Styled | AA+ | ~40KB | React |
| Mantine | Styled | AA | ~60KB | React |

### Setup Workflow
```bash
npx shadcn-ui@latest init
npm install tailwindcss @headlessui/react
npm install -D style-dictionary
npx style-dictionary init basic
npx style-dictionary build
npx shadcn-ui@latest add button dialog dropdown-menu
npx storybook@latest init
```

### Token Architecture (3 levels)
1. **Primitive**: raw values (blue-500: #0070f3)
2. **Semantic**: intent-based (brand.default → refs primitive)
3. **Component**: specific overrides (button.primary.background → refs semantic)

### Tailwind Integration
Map semantic CSS variables to Tailwind config: `brand: { DEFAULT: "var(--color-semantic-brand-default)" }`

---

## C6: Responsive Design

### Container Queries vs Media Queries
- **Media Queries**: macro layouts (page structure, viewport-based)
- **Container Queries**: micro layouts (component adapts to parent container)

### Fluid Typography Presets
```css
--text-base: clamp(1rem, 0.5vw + 0.875rem, 1.125rem);
--text-xl: clamp(1.5rem, 2vw + 1rem, 3rem);
```

### Responsive Image Pattern
```html
<picture>
  <source type="image/avif" srcset="hero-400.avif 400w, hero-800.avif 800w">
  <img src="hero-800.webp" srcset="..." loading="lazy" alt="...">
</picture>
```

### Auto-fit Grid (no media query needed)
```css
grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
```

---

## C7: Usability Review

### CLI Tools
| Tool | Install | Command |
|------|---------|---------|
| axe-core CLI | `npm install -g @axe-core/cli` | `axe https://site.com --tags wcag2aa --exit` |
| Lighthouse CI | `npm install -g @lhci/cli` | `lhci autorun` |
| Pa11y | `npm install -g pa11y` | `pa11y https://site.com --standard WCAG2AA` |
| Chromatic | (npx) | `npx chromatic` |

### Automated Checklist (AI agent can run)
1. Semantic HTML check (no div soup)
2. Unit conversion check (no hardcoded px → use rem/vw)
3. CSS bloat check (PurgeCSS/UnCSS)
4. Color proportion check (60-30-10)
5. Tap target check (≥44x44px)
6. Contrast check (APCA LC scores)

---

## C8: Design System Documentation

### Storybook Setup
```bash
npx storybook@latest init
# autodocs in .storybook/main.js: docs: { autodocs: 'tag' }
```

### Google design.md Required Sections
1. Overview (1-2 sentences)
2. Anatomy (structural breakdown)
3. Properties/API (variants, sizes, states)
4. Behavior (interaction states, motion rules)
5. Accessibility (ARIA roles, keyboard, focus)
6. Do/Don't (visual usage rules)

### Token Documentation
- Auto-generate Markdown tables from JSON tokens via Node script
- Style Dictionary build outputs platform-specific code

### Auto-doc Tools
- `react-docgen`: `npx react-docgen src/components/Button.tsx -o docs/ButtonAPI.json`
- Storybook autodocs: reads JSDoc/TypeScript interfaces automatically

---

## C9: Design Iteration Decisions

### Design ADR Template
- Title, Date, Status (Proposed/Accepted/Rejected/Deprecated)
- Context (user need/friction)
- Decision (specific pattern/token/rule adopted)
- Consequences (measurable impact)

### A/B Testing
- PostHog: `npm install posthog-js` (feature flags + variants)
- Vercel Edge Middleware (Next.js, no client flicker)

### AI Agent Review Checklist (measurable)
1. Semantic HTML ✓
2. Relative units ✓
3. 60-30-10 color proportions ✓
4. 44px tap targets ✓
5. APCA contrast scores ✓

### Design Token Version Control
- Tokens Studio → sync to GitHub as JSON → PR on token change
- Style Dictionary builds platform-specific code from versioned JSON

---

# Round 2: Gap-Fill Research (2026-05-07)

## G1: Real Design System Patterns (Polaris, Primer, Spectrum, Geist, Ant Design)

### Common Architecture
- **Monorepo** with package workspaces (Lerna/Yarn/Turbo/pnpm)
- Separate packages: `polaris-react`, `polaris-tokens`, `polaris-icons` pattern
- Strict separation: components / tokens / docs / tests

### Token Architecture
- Standalone token packages (decoupled from component code, independently versioned)
- Ant Design: theme-aware preset tokens (hover/active states adapt to theme)

### Testing Strategy
- **Visual Regression**: Chromatic (Adobe Spectrum), Storybook VRT + Playwright (GitHub Primer), image snapshots + Puppeteer (Ant Design)
- **Accessibility**: CI/CD GitHub Actions (Primer), WAI-ARIA compliance testing (Spectrum)

### Theming / Dark Mode
- Adobe Spectrum: components automatically adapt for dark mode
- Vercel Geist: system/light/dark toggle
- Ant Design: CSS-in-JS engine for deep customization

### Component API Patterns
- Adobe: 3-layer split (React Stately → React Aria → React Spectrum)
- GitHub Primer: shifting responsive logic from JS props to native CSS (CSS Anchor Positioning)
- Ant Design: TypeScript-anchored props with decoupled rc-components

---

## G2: Claude Code Capabilities for UI Design

### CAN DO (FULLY_CLI)
- Generate production-grade HTML/CSS/React/Vue code
- Read design data via MCP
- Run CLI tools (Style Dictionary, axe-core, PurgeCSS, shadcn-ui)
- Post-conversion cleanup (semantic HTML, relative units, purge unused CSS)

### CANNOT DO
- Detect 60-75% of accessibility issues (only 25-40% automated)
- Anticipate edge cases (happy-path bias)
- Conduct real usability testing
- Visually "see" rendering — needs human or visual regression tool

### Anthropic Anti-AI-Slop Rules
1. Ban Inter/Roboto/Arial/system fonts → use distinctive font pairings
2. Ban purple gradients on white → commit to cohesive theme with dominant + accent
3. Ban scattered micro-interactions → one well-orchestrated page load reveal
4. Enforce bold aesthetic commitment (brutalist / retro-futuristic / luxury / etc.)
5. Enforce unexpected spatial composition (asymmetry, overlap, diagonal flow)
6. Ban solid backgrounds → noise textures, gradient meshes, grain overlays

### Recommended AI Agent Workflow
1. Vision (Design Thinking) → bold aesthetic direction
2. Token Establishment → semantic 60-30-10 palette via MCP/manual
3. Structural Generation → headless components + Tailwind
4. Motion → staggered reveals, high-impact moments only
5. Post-Conversion Cleanup → semantic HTML, relative units, purge CSS
6. Audit → axe-core, APCA contrast, manual keyboard testing note

---

## G3: Tool Chain Verification Matrix

| Tool | CLI Status | Test Command |
|------|-----------|-------------|
| Style Dictionary | FULLY_CLI | `npx style-dictionary --version` |
| axe-core CLI | FULLY_CLI | `npx axe --version` |
| Lighthouse CI | FULLY_CLI | `npx lhci --version` |
| Pa11y | FULLY_CLI | `npx pa11y --version` |
| Mermaid CLI | FULLY_CLI | `npx mmdc -V` |
| D2 | FULLY_CLI | `d2 version` |
| PurgeCSS | FULLY_CLI | `npx purgecss --version` |
| shadcn-ui CLI | FULLY_CLI | `npx shadcn-ui@latest --help` |
| Tailwind CLI | FULLY_CLI | `npx tailwindcss --help` |
| PostCSS | FULLY_CLI | `npx postcss --version` |
| react-docgen | FULLY_CLI | `npx react-docgen --version` |
| Builder.io CLI | FULLY_CLI | `npx @builder.io/cli --version` |
| Anima MCP | FULLY_CLI | `npx @animaapp/mcp-server --help` |
| open-props | FULLY_CLI | `npm ls open-props` |
| Storybook | PARTIAL_CLI | init+build CLI, view needs browser |
| Chromatic | PARTIAL_CLI | `npx chromatic` starts test, diff review in web GUI |
| v0.dev | PARTIAL_CLI | `npx v0 add` pulls components, generation is web-only |
| Tokens Studio | GUI_ONLY | Figma plugin only (outputs JSON to git) |

---

## G4: SKILL.md Structure Analysis

### Anthropic SKILL Structure (~400-500 words)
1. Metadata/frontmatter (name, description, license)
2. Design Thinking (pre-execution: purpose, tone, constraints, differentiation)
3. Frontend Aesthetics Guidelines (typography, color, motion, spatial, backgrounds)
4. Anti-Patterns (NEVER rules, capitalized)
5. Final Directives (match complexity to vision)

### Key Insight: Vision → Execution → Validation Pipeline
- **Vision (Anthropic approach)**: HOW to design — bold aesthetics, anti-slop, emotional direction
- **Execution (our approach)**: WHAT tools to use — CLI commands, token architecture, component scaffolding
- **Validation (bridge)**: axe-core for accessibility, PurgeCSS for cleanup, Chromatic for visual regression

### Recommended SKILL.md Sections
1. Identity & Objective
2. Context Ingestion (Design Thinking — Anthropic style)
3. Toolchain & Scaffolding (CLI commands)
4. Aesthetic Rules & Token Architecture (anti-slop + 60-30-10 + APCA)
5. Interactive & Motion Guidelines (timing rules, container queries, fluid typography)
6. Automated Auditing & Refinement (post-generation checklist)

---

# Round 3: GitHub Deep Dive (2026-05-07)
> Sources expanded to 119 (added 16 brand DESIGN.md files + 4 subagent definitions + 12 awesome-lists)

## DESIGN.md Standard Structure (from 16 brand files)

All brand DESIGN.md files share a **9-section structure**:
1. Visual Theme & Atmosphere
2. Color Palette & Roles (semantic names + hex + functional roles)
3. Typography Rules (font families, fallbacks, OpenType features, hierarchy tables)
4. Component Stylings (buttons, inputs, cards, nav + interactive states)
5. Layout Principles (spacing scale, grid, whitespace rhythm)
6. Depth & Elevation (shadow tokens, borders, surface hierarchy)
7. Do's and Don'ts (strict guardrails + anti-patterns)
8. Responsive Behavior (breakpoints, touch targets, component collapsing)
9. Agent Prompt Guide (reusable prompts, quick color reference, iteration instructions FOR the LLM)

### Best Examples

**Vercel** — minimalist, achromatic, shadow-as-border:
- Colors: Pure White (#ffffff) + Vercel Black (#171717) + workflow accents (Ship Red #ff5b4f, Preview Pink #de1d8d, Develop Blue #0a72ef)
- Typography: Geist Sans/Mono, aggressive negative letter-spacing (-2.4px at 48px), 3-weight system (400/500/600)
- Elevation: signature `rgba(0,0,0,0.08) 0px 0px 0px 1px` shadow-as-border + 4-layer shadow stack

**Stripe** — luxurious fintech precision:
- Colors: Stripe Purple (#533afd), Deep Navy (#061b31), blue-tinted shadows `rgba(50,50,93,0.25)`
- Typography: sohne-var with OpenType `"ss01"`, weight 300 for massive display headlines, `"tnum"` for financial data
- Spacing: ultra-dense at small end (1,2,4,6,8,10,11,12px) for data tables

### What Makes DESIGN.md Actionable
- Token + Rule + Rationale in one file (not just hex codes)
- Built-in Agent Prompt Guide (section 9) with pre-written prompts
- Strict Do's/Don'ts as anti-hallucination guardrails
- Markdown native — LLMs read it natively, no parsing needed

## Subagent Role Division

| Subagent | Role | Does NOT do |
|----------|------|------------|
| Design Bridge | Translator — reads DESIGN.md, extracts brand DNA, formats as instructions | Build UI or write code |
| UI Designer | Architect — creates visual systems, tokens, interaction patterns, specs | Ship production code |
| Frontend Developer | Engineer — implements production React/Vue/Angular code | Design decisions |
| UI/UX Tester | QA — simulates real user interactions, visual alignment, defect reports | Fix bugs |

## Top 10 Ecosystem Tools (from awesome-lists)

1. **memoire** — MCP server for shadcn-native design CI (diagnose UI debt, extract tokens, export registries)
2. **Style Dictionary** — JSON tokens → platform-specific CSS/iOS/Android
3. **shadcn-zod-form** — generates shadcn forms from Zod schemas
4. **Prettier Plugin for Tailwind** — auto-sorts utility classes
5. **Tokens Studio** — Figma → JSON → Git sync
6. **RustyWind** — Rust CLI for sorting Tailwind classes at scale
7. **Img2m3** — Material Design 3 → Tailwind CSS v4 bridge
8. **Theo** — Salesforce token transformer
9. **Design Tokens Validator** — validates against DTCG spec
10. **designgui** — AI-powered CSS variables editor in Chrome

## Class-less CSS Frameworks (optimal for AI code generation)

For AI agents that generate semantic HTML, class-less frameworks auto-style `<nav>`, `<main>`, `<button>` etc.:
- **Pico.css** — elegant, auto dark mode
- **MVP.css** — minimalist
- **Simple.css** — lightweight

## Storybook Must-Have Addons

Docs, Accessibility (a11y), Actions, Backgrounds, Viewport, Measure & Outline, Controls, Source

## CSS Framework Stalled (avoid in 2026)

Semantic UI, Material Components Web, Tachyons, Bourbon, Water.css, sanitize.css — all inactive >1 year
