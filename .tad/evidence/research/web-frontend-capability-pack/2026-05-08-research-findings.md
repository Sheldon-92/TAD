# Web Frontend Capability Pack — Research Findings

> NotebookLM notebook: `430044a7-d808-4a70-9969-24e00c92da8d`
> 299 sources (14 manual GitHub + 52 deep research + auto-import)
> Date: 2026-05-08
> Research plan: 1 objective + 4 sub-objectives + 8 questions

---

## Research Objective

**Decision**: What expert-level frontend engineering judgment should the pack encode?
**Assumption**: AI agents can already write React/Vue code. The pack's value is "write it well" — production-grade architecture, performance, accessibility, and design system integration decisions.

---

## Sub-Objective 1: Component Architecture Judgment

### Key Findings

**Three dominant composition patterns in 2026:**
1. **Headless UI (Radix, React Aria)** — unstyled primitives, full styling control, accessibility built-in. Right when teams want custom component libraries from scratch.
2. **Web Components (Shopify Polaris direction)** — technology-agnostic. Right when design system must work across frameworks.
3. **Atomic Design** — atoms → molecules → organisms. Standard approach for scalable, accessible component libraries.

**Component splitting heuristics:**
- "If it doesn't need `useState` or `useEffect`, it can probably be a Server Component" (RSC rule)
- **Thin Client Rule**: push interactivity as far down the component tree as possible. Root/structural = Server Components. `'use client'` only on leaf components (buttons, modals, forms)
- **50-component threshold**: once an app grows past 50 components without strict boundaries → spaghetti code (Feature-Sliced Design reference)
- **Micro-frontend threshold**: avoid if <10 developers. Only split when 10+ developers with distinct business domains

**Anti-patterns:**
- Centralizing all state globally → unrelated keystrokes re-render data-backed lists
- Passing entire objects as props → forces child re-renders even when data unchanged. **Fix**: keep props primitive
- Deep reactivity on large datasets (Vue) → use `shallowRef()` for 50+ item arrays (40% memory reduction)

---

## Sub-Objective 2: State & Data Flow Decisions

### State Management Selection Matrix (2026)

| Tool | State Type | Best For | Key Threshold |
|------|-----------|----------|---------------|
| **Zustand** | Client/UI | Most projects — theme, modals, navigation | Simplest API, 0 providers, tiny bundle |
| **Jotai** | Client/UI | Complex interdependent state — forms, spreadsheets | Atomic model, derived values |
| **Redux Toolkit** | Client/UI | High complexity requiring time-travel debugging | Large teams needing strict patterns |
| **TanStack Query** | Server | Remote data — caching, revalidation, dedup | De facto standard for server state |
| **React Context** | Client/UI | Simple global values to avoid prop drilling | Small apps only; lacks targeted re-renders |
| **Signals** | Client/UI | Performance-critical with high-frequency updates | Granular DOM updates, component function doesn't rerun |

**Recommended 2026 stack**: TanStack Query (server) + Zustand (client) + Jotai (forms)

### Top State Management Bugs
1. **Mixing remote data + UI flags in same store** → keystroke re-renders API-backed lists
2. **Centralizing everything globally by default** → Rule: prefer local state, lift only when necessary
3. **Stuffing business logic into UI state** → Decouple UI layer; UI passes events, state syncs back
4. **AI-amplified inconsistency** — if state conventions aren't explicitly defined, AI agents dangerously mix local/global/server caches

---

## Sub-Objective 3: Design System → Code Bridge

### W3C DTCG Token Consumption Workflow
1. **Export**: Figma natively exports DTCG-format tokens (stable spec 2025.10)
2. **Sync**: Figma Code Connect + MCP server → auto-pull tokens into code editor; changes push back
3. **Transform**: Style Dictionary processes token JSON → CSS/JS/iOS/Android
   - `config.json`: define `source` (token file globs), `platforms`, `transformGroup`, `buildPath`
   - CLI: `style-dictionary build`
4. **Output**: CSS custom properties, Tailwind config, or platform-native styles

### Styling Approach Characteristics (not a strict matrix)
- **Tailwind CSS**: Rapid prototyping, AI-generated workflows, headless component libraries. Gap between utility-first and design systems has narrowed.
- **CSS Modules**: Component-driven architecture needing strict encapsulation. Auto-generates unique class names (prevents conflicts).
- **Modern CSS (vanilla)**: Performance-critical, logic-heavy UIs. Container Queries, custom properties for dark mode, native animation capabilities reduce JS reliance.
- **CSS-in-JS**: Supported by design-to-code tools but sources don't provide strong adoption criteria.

### DESIGN.md as Input Contract
- VoltAgent awesome-design-md: 68+ brand DESIGN.md files (Stripe, Linear, Notion, etc.)
- Markdown is the format LLMs read best — `border-radius: 12px` has zero ambiguity vs screenshots
- Any agent that reads project files can consume them (Claude Code, Cursor, Codex, Gemini CLI)

---

## Sub-Objective 4: Quality Assurance

### Core Web Vitals Thresholds (2026)
| Metric | Target | What It Measures |
|--------|--------|-----------------|
| **LCP** | < 2.5s | Largest Contentful Paint (hero element speed) |
| **INP** | < 200ms | Interaction to Next Paint (replaced FID) |
| **CLS** | < 0.1 | Cumulative Layout Shift (visual stability) |

**CLI tools**: Google Lighthouse (CLI mode), web-vitals library

### Top Accessibility Failures (axe-core/Lighthouse)
1. Missing/empty `alt` on images
2. Insufficient color contrast (WCAG 1.4.3)
3. Missing form labels
4. Improper heading structure
5. Missing document language declaration
6. ARIA misconfiguration
7. Keyboard focus issues

**Fix patterns:**
- **Default to semantic HTML** — use native elements before ARIA
- When custom components needed: bind `role`, `aria-*` states explicitly (e.g., `role="progressbar"` + `aria-valuenow`)
- **Automation catches only 20-40% of a11y bugs** → remaining 60-80% requires manual screen-reader + disabled user testing

### Frontend Testing Strategy (2026)
| Layer | Tool | When | Ratio |
|-------|------|------|-------|
| **Unit** (highest ROI) | Vitest + jest-axe + sa11y | Component behavior, focus APIs, ARIA states | Most tests here |
| **Component/Integration** | Storybook + React Testing Library | Real browser rules, color contrast, user interactions | Medium coverage |
| **E2E** (use sparingly) | Playwright | Multi-page workflows, happy path only | Fewest tests |

**Key rules:**
- Test user interactions, not internal state (RTL philosophy)
- E2E tests are a "trap" if overused — flakiness and noise
- Use `data-testid` or ARIA roles as locators, never brittle CSS selectors

---

## Synthesis: Proposed Capability Dimensions

Based on research, the web-frontend pack should organize judgment rules into these facets:

1. **Component Architecture** — composition patterns, splitting heuristics, RSC decisions
2. **State Management** — selection matrix, server vs client separation, anti-patterns
3. **Design Token Consumption** — DTCG workflow, Style Dictionary pipeline, DESIGN.md contract
4. **Styling Strategy** — Tailwind vs CSS Modules vs vanilla decision tree
5. **Performance** — CWV thresholds, rendering optimization, bundle analysis
6. **Accessibility** — top failures + fix patterns, automation limits, semantic HTML rules
7. **Testing Strategy** — pyramid ratio, tool selection, behavioral testing philosophy
8. **Build & Deploy** — code splitting, lazy loading, RSC/SSR decisions (from component architecture)

Estimated: 35-45 judgment rules across 7-8 facets.
