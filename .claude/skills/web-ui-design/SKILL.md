---
name: web-ui-design
description: Web UI design capability pack. Guides AI agents through a Vision → Execution → Validation pipeline across 9 design capabilities: information architecture, wireframing, visual design with anti-slop token system, interaction design, design system selection, responsive design, usability review, design system documentation, and design iteration decisions. Includes 14 verified CLI tools, anti-AI-slop rules (based on Anthropic frontend-design SKILL, Apache 2.0), and a bash+jq token compiler (no npm required). Use for any UI build, refactor, or accessibility audit task.
keywords: ["UI", "UX", "design", "frontend", "interface", "visual design", "设计", "界面", "布局", "色彩", "设计系统", "wireframe", "accessibility"]
type: reference-based
---

**CONSUMES**: User UI task + optional brand guidelines or existing design
**PRODUCES**: DESIGN.md + design tokens + visual spec + accessibility audit results

# Web UI Design Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: MIT (derived Anthropic anti-slop rules: Apache 2.0 — see LICENSE-ATTRIBUTION.md)

---

## How This Works

This pack gives AI coding agents a complete web UI design workflow — from architecture
through validation. It combines:
- Committed aesthetic direction (Anthropic anti-slop philosophy)
- Verified CLI toolchain (14 FULLY_CLI tools tested)
- Design token architecture (primitive → semantic → component)
- Automated quality validation

**What it does**: Guides the agent through a Vision → Execution → Validation pipeline
for every design capability. Each step has concrete CLI commands — no theory-only sections.

**What it doesn't do**: Visual rendering, real usability testing with users, or Figma
plugin operations. AI agents can automate 25–40% of accessibility checks; the rest
requires human review.

---

## Entry Protocol

Use this decision tree before starting any design task:

```
Are you building UI from scratch?
  YES → Start at C1 (Information Architecture)

Do you have an existing design to implement?
  YES → Start at C5 (Design System) — skip C1/C2

Are you reviewing existing UI for quality?
  YES → Start at C7 (Usability Review) — skip everything else

Are you adding a single component to an existing system?
  YES → Skip C1/C2/C6/C9 — use C3 + C5 + C7 only

Is the agent on a limited-context model (<200K tokens)?
  YES → Load only the capabilities you need by section marker
```

### Minimum Viable Path

The minimum viable path: for most projects, these three capabilities cover 80% of needs:

1. **C3** — Visual Design (tokens + aesthetic direction)
2. **C5** — Design System (component selection + setup)
3. **C7** — Usability Review (automated quality check)

### Stop-Early Rules

Use these rules to stop early and skip unnecessary capabilities:

- If the user asked for a **single component** → skip C1, C2, C6, C9
- If the user said **"quick prototype"** → skip C8, C9
- If the project has **no public-facing users** → skip C1 navigation framework
- If the codebase already has a **design system** → skip C2, C5 setup

### Token Budget (for smaller-context agents)

Each capability is marked with its `## Capability N` header. Load only the
sections you need by extracting between those markers:

```bash
awk '/^### 3\./,/^### 4\./' CAPABILITY.md
```

---

## Anti-AI-Slop Rules

> Based on Anthropic frontend-design SKILL (Apache 2.0). Applies to ALL capabilities.

### The 6 Core Rules

**Rule 1 — Font Prohibition**
NEVER use Inter, Roboto, Arial, or system-ui as the primary typeface.
These are corpus defaults. Choose distinctive font pairings: a slab serif +
grotesque, a geometric + humanist, or a display face for headings.
```bash
# Check for banned fonts in CSS
grep -r "Inter\|Roboto\|Arial\|system-ui" src/ --include="*.css" --include="*.scss"
```

**Rule 2 — Gradient Prohibition**
NEVER use purple/blue gradient on white as a hero or CTA design.
This is the single most AI-identifiable pattern. Commit to a cohesive theme:
dominant + one accent + neutrals. If gradients are used, make them unexpected
(diagonal, mesh, noise-overlaid).
```bash
# Check for generic gradient patterns
grep -r "linear-gradient.*purple\|linear-gradient.*#[6-9][0-9A-Fa-f][0-9A-Fa-f]" src/
```

**Rule 3 — Animation Prohibition**
NEVER scatter micro-interactions across every element.
Choose ONE high-impact moment (page load, primary CTA, key transition).
Make that one moment excellent. Everything else: instant or ≤100ms.
```bash
# Audit animation count — should be low
grep -r "animation\|transition" src/ --include="*.css" | wc -l
```

**Rule 4 — Aesthetic Commitment**
ALWAYS commit to a bold aesthetic direction before writing any code.
Options: brutalist / retro-futuristic / luxury / organic / art deco / maximalist.
Neutral "clean" is not a direction. State it explicitly: "This UI is brutalist."

**Rule 5 — Spatial Composition**
ALWAYS use unexpected spatial composition: asymmetric layouts, overlapping
elements, diagonal flow, purposeful whitespace imbalance.
Rigid 12-column grids with equal-height cards = AI-slop.

**Rule 6 — Background Prohibition**
NEVER use a flat solid background for hero sections or landing pages.
Use noise textures, gradient meshes, grain overlays, or geometric patterns.
Solid #ffffff / #f5f5f5 backgrounds signal zero design thinking.

### Expanded Anti-Slop Rules

**Rule 7 — Primitive Token Names**
NEVER name tokens `blue-500`, `gray-100`, `red-error`. These leak implementation
details into semantic contexts. Use intent-based names: `color-button-background-brand`,
`color-feedback-error-default`, `color-surface-secondary`.

**Rule 8 — Equal-Weight Typography**
NEVER use the same font-weight for all text. Establish a 3-weight system minimum:
light (300) for display, regular (400) for body, medium/semibold (500/600) for UI labels.

**Rule 9 — Icon Soup**
NEVER use icons without accompanying text for primary actions. Icons alone fail
accessibility and comprehension tests. Text alone is always better than icon alone.

**Rule 10 — Breakpoint-Only Responsiveness**
NEVER use only media queries for component responsiveness. Use container queries
for components so they adapt to their parent context, not just viewport width.
```css
@container (min-width: 400px) { /* component-level responsive */ }
```

---

## Capabilities

### 1. Information Architecture

#### Vision

Before any pixel is placed, map the content structure and navigation pattern.
Users fail not because of styling but because of unclear hierarchy and
unreachable information.

Key questions:
- What are the 3–5 core user tasks?
- How many navigation levels are needed?
- What content must be within 2 clicks of the entry point?

#### Execution

**Step 1: Map user flows with Mermaid**

Install:
```bash
npm install -g @mermaid-js/mermaid-cli
```

Test:
```bash
mmdc -V
```

Use:
```bash
# Create flow diagram
cat > flows.mmd << 'EOF'
flowchart TD
    A[Landing] --> B[Browse]
    A --> C[Search]
    B --> D[Product Detail]
    C --> D
    D --> E[Checkout]
EOF
mmdc -i flows.mmd -o flows.svg
```

**Step 2: Map architecture with D2**

Install:
```bash
curl -fsSL https://d2lang.com/install.sh | sh
```

Test:
```bash
d2 version
```

Use:
```bash
cat > arch.d2 << 'EOF'
landing: Landing Page
dashboard: Dashboard
settings: Settings
landing -> dashboard: authenticated
dashboard -> settings: user
EOF
d2 arch.d2 arch.svg
```

**Step 3: Select navigation pattern**

Use this matrix to choose:

| Pattern | When | Max breakpoint |
|---------|------|---------------|
| Bottom Tab Bar | Mobile, ≤5 core actions, thumb zone | ≤480px |
| Hamburger / Drawer | Mobile, >5 items | ≤768px |
| Top Navigation Bar | Desktop, ≤7 items | >768px |
| Sidebar | Content-heavy apps, secondary nav | >1024px |
| Mega Menu | Large catalog, many categories | >1200px |
| Breadcrumbs | Deep content hierarchy (>3 levels) | All |

#### Validation

```bash
# Count navigation levels — should be ≤3 for most apps
grep -r "<nav\|role=\"navigation\"" src/ | wc -l

# Verify core flows are documented
ls flows.svg arch.svg 2>/dev/null && echo "Flow diagrams present" || echo "Missing diagrams"
```

Criteria:
- Core user tasks completable in ≤5 steps
- High-frequency items within 2 clicks of landing
- Navigation pattern matches device context (mobile vs desktop)

---

### 2. Wireframing

#### Vision

Build structure before style. A wireframe is a layout hypothesis — it proves
that content fits and flows before any visual treatment is applied.

Wireframe in code, not mockup tools: it's faster, version-controllable, and
directly verifiable with accessibility tools.

#### Execution

**Step 1: Scaffold with class-less CSS for instant semantic structure**

Pico.css auto-styles semantic HTML — no classes required:
```bash
npm install @picocss/pico
```

```html
<!-- Instant structured layout — no CSS classes needed -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="node_modules/@picocss/pico/css/pico.min.css">
</head>
<body>
  <header><nav><ul><li><a href="/">Logo</a></li></ul></nav></header>
  <main>
    <h1>Page Title</h1>
    <section><article>Content area</article></section>
  </main>
  <footer>Footer</footer>
</body>
</html>
```

**Step 2: Add headless components for interactive wireframe elements**

Install:
```bash
npm install @ark-ui/react
```

Test:
```bash
node -e "require('@ark-ui/react'); console.log('Ark UI installed')"
```

Use (framework-agnostic pattern via web components):
```bash
# Ark UI provides React, Vue, Solid, Svelte adapters
# Universal install for React:
npm install @ark-ui/react
```

If React:
```jsx
import { Dialog } from "@ark-ui/react";
// Provides accessible modal structure without styling
```

If Vue:
```bash
npm install @ark-ui/vue
```

**Step 3: Validate semantic HTML structure**

```bash
# Install axe-core CLI for semantic audit
npm install -g @axe-core/cli

# Run structural check on local dev server
axe http://localhost:3000 --tags best-practice
```

#### Validation

```bash
# Confirm no div soup — check heading hierarchy
grep -r "<h[1-6]" src/ | awk -F'<h' '{print $2}' | sort | uniq -c

# Check for ARIA landmarks
grep -r "role=\"main\|role=\"navigation\|role=\"banner\|<main\|<nav\|<header\|<footer" src/ | wc -l
```

Criteria:
- Semantic HTML5 landmarks present (main, nav, header, footer)
- No `<div>` where a semantic element exists
- Heading hierarchy is sequential (no jumping from h1 to h4)

---

### 3. Visual Design

#### Vision

Commit to a specific aesthetic direction before opening any design tool.
"Clean and modern" is not a direction — it is the absence of a direction.

Choose one:
- **Brutalist**: raw structure, exposed grid, monospace, stark contrast
- **Retro-futuristic**: neon accents, dark base, scan-line textures
- **Luxury**: generous whitespace, muted palette, refined typography
- **Organic**: curved containers, earthy palette, nature-inspired motion
- **Art Deco**: geometric ornament, gold accents, symmetry with flair
- **Maximalist**: dense information, layered patterns, bold color juxtaposition

State it explicitly before generating any code. The aesthetic direction determines
every token value you set.

#### Execution

**Step 1: Build token architecture (3 levels)**

> **Token file structure note**: `examples/starter-tokens.json` uses a flat `primitive`
> layer (`"gray-50": "#f9fafb"`) rather than sub-grouped categories
> (`"color": {"gray-50": ...}`). This is intentional for the Level 0 bash+jq compiler
> simplicity. If you use Level 1 Style Dictionary, you may want to sub-group by category
> (`color`, `size`, `font`, `radius`) and update the compiler accordingly. See
> `references/design-system-patterns.md` for production design system patterns.

Level 0 — No npm required (bash+jq):
```bash
# Use included tools/tokens-to-css.sh
bash tools/tokens-to-css.sh examples/starter-tokens.json > tokens.css
```

Level 1 — Node available:

Install:
```bash
npm install -D style-dictionary
```

Test:
```bash
npx style-dictionary --version
```

Use:
```bash
# Initialize Style Dictionary config
cat > sd.config.json << 'EOF'
{
  "source": ["tokens/**/*.json"],
  "platforms": {
    "css": {
      "transformGroup": "css",
      "buildPath": "dist/",
      "files": [{ "destination": "tokens.css", "format": "css/variables" }]
    }
  }
}
EOF
npx style-dictionary build --config sd.config.json
```

**Step 2: Apply 60-30-10 color rule**

60% — dominant neutral (background, surfaces)
30% — secondary brand color (cards, sidebars)
10% — accent action color (CTAs, links, highlights)

```css
:root {
  /* Level 1: Primitive */
  --primitive-slate-900: #0f172a;
  --primitive-slate-100: #f1f5f9;
  --primitive-violet-600: #7c3aed;
  --primitive-amber-400: #fbbf24;

  /* Level 2: Semantic (60-30-10) */
  --color-background-base: var(--primitive-slate-900);     /* 60% */
  --color-surface-elevated: #1e293b;                       /* 30% */
  --color-action-primary: var(--primitive-violet-600);     /* 10% */
  --color-highlight: var(--primitive-amber-400);

  /* Level 3: Component */
  --button-background-primary: var(--color-action-primary);
  --button-text-primary: var(--primitive-slate-100);
}
```

**Step 3: Set fluid typography scale**

```css
:root {
  --text-xs:   clamp(0.75rem,  0.25vw + 0.6875rem,  0.875rem);
  --text-sm:   clamp(0.875rem, 0.25vw + 0.8125rem,  1rem);
  --text-base: clamp(1rem,     0.5vw  + 0.875rem,   1.125rem);
  --text-lg:   clamp(1.125rem, 0.75vw + 0.9375rem,  1.375rem);
  --text-xl:   clamp(1.5rem,   2vw   + 1rem,        3rem);
  --text-2xl:  clamp(2rem,     4vw   + 1rem,        4.5rem);
}
```

**Step 4: Validate contrast with APCA**

```bash
# Install Pa11y for contrast checking
npm install -g pa11y

# Run against local dev server
pa11y http://localhost:3000 --standard WCAG2AA
```

#### Validation

```bash
# Check for primitive token names (should return 0 for clean semantic naming)
grep -r "blue-[0-9]\|red-[0-9]\|gray-[0-9]" src/styles/ | grep -v "primitive" | wc -l

# Verify fluid typography is set (not fixed px)
grep -r "font-size:.*[0-9]px" src/styles/ | grep -v "clamp\|var(" | wc -l
```

Criteria:
- All semantic tokens reference primitive tokens (no hard-coded hex in components)
- APCA LC ≥60 for body text, ≥45 for large text
- Fluid typography set (no fixed px font sizes in semantic layer)

---

### 4. Interaction Design

#### Vision

Motion should communicate, not decorate. Every animation must answer:
"Does this help the user understand what just happened?"

Timing rules:
- ≤100ms: immediate feedback (button press, hover state, checkbox toggle)
- 100–300ms: transitions, panel open/close, tab switches
- ≥300ms: celebratory / onboarding animations only — used sparingly

#### Execution

**Step 1: Set universal CSS transitions (no library needed)**

```css
/* Base interaction tokens */
:root {
  --duration-instant:    80ms;
  --duration-fast:       150ms;
  --duration-normal:     250ms;
  --duration-slow:       400ms;
  --easing-standard:     cubic-bezier(0.4, 0, 0.2, 1);
  --easing-decelerate:   cubic-bezier(0, 0, 0.2, 1);
  --easing-accelerate:   cubic-bezier(0.4, 0, 1, 1);
}

button {
  transition: background-color var(--duration-instant) var(--easing-standard),
              transform var(--duration-instant) var(--easing-standard);
}
button:hover  { transform: translateY(-1px); }
button:active { transform: translateY(0); }
```

**Step 2: Universal accessible interactions (no framework required)**

Native HTML `<dialog>` and CSS handle the majority of interaction patterns:

```html
<!-- Accessible dialog — no JS library needed -->
<dialog id="modal">
  <button autofocus onclick="document.getElementById('modal').close()">Close</button>
  <p>Content</p>
</dialog>
<button onclick="document.getElementById('modal').showModal()">Open</button>
```

```css
/* Loading states — pure CSS spinner */
@keyframes spin { to { transform: rotate(360deg); } }
.loading { animation: spin var(--duration-normal) linear infinite; }

/* Skeleton screens — pure CSS */
.skeleton {
  background: linear-gradient(90deg, #e0e0e0 25%, #f5f5f5 50%, #e0e0e0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
```

For complex animations (no framework):
```bash
npm install motion
```

```js
import { animate } from "motion";
// framework-agnostic Web Animations API wrapper
animate("#element", { opacity: [0, 1], y: [20, 0] }, { duration: 0.25 });
```

If React: (primary recommendation for accessibility)

Install:
```bash
npm install react-aria
```

Test:
```bash
node -e "require('react-aria'); console.log('React Aria installed')"
```

```jsx
import { useButton } from 'react-aria';
// Provides keyboard, focus, pointer event handling with full a11y
```

If React: (rich animations — use sparingly, one high-impact animation per page)
```bash
npm install framer-motion
```

```jsx
import { motion } from "framer-motion";
// Use sparingly — one high-impact animation per page
const reveal = { hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0 } };
<motion.section variants={reveal} initial="hidden" animate="visible">
```

**Step 3: Set up keyboard navigation**

```bash
# Install Radix UI primitives (built-in keyboard navigation)
npm install @radix-ui/react-focus-trap @radix-ui/react-roving-focus
```

```css
/* Visible focus rings — NEVER hide focus outline */
:focus-visible {
  outline: 2px solid var(--color-action-primary);
  outline-offset: 2px;
}
```

**Step 4: Audit keyboard accessibility**

```bash
# Run axe for keyboard navigation issues
axe http://localhost:3000 --tags wcag2a --exit
```

#### Validation

```bash
# Count total animation rules — keep it low
grep -r "@keyframes\|animation:" src/ --include="*.css" | wc -l

# Verify focus styles not hidden
grep -r "outline: none\|outline:0" src/ --include="*.css" | grep -v "focus-visible" | wc -l
```

Criteria:
- No `outline: none` without `:focus-visible` replacement
- All interactive elements reachable and operable by keyboard
- Animation count ≤5 distinct keyframe animations per page

---

### 5. Design System

#### Vision

A design system is not a component library — it is a shared language.
The goal is to make the right thing easy and the wrong thing hard.

Component selection priority:
1. **Headless + accessible** (Ark UI, Radix UI) — maximum flexibility
2. **CSS-only + framework-agnostic** (DaisyUI) — zero JS overhead
3. **Opinionated styled** (shadcn/ui) — best for React + Tailwind projects

#### Execution

**Step 1: Initialize token-first design system (framework-agnostic)**

Install Style Dictionary:
```bash
npm install -D style-dictionary
```

Use:
```bash
npx style-dictionary init basic
npx style-dictionary build
```

**Step 2: Add component library**

Universal (no framework required):

Install:
```bash
npm install @ark-ui/react  # React adapter (also: @ark-ui/vue, @ark-ui/solid)
```

Test:
```bash
node -e "require('@ark-ui/react'); console.log('Ark UI ready')"
```

If React + Tailwind (shadcn/ui — copy-paste model):
```bash
npx shadcn-ui@latest init
npx shadcn-ui@latest add button dialog dropdown-menu input
```

If CSS-only (DaisyUI):
```bash
npm install daisyui
# Add to tailwind.config.js plugins: [require("daisyui")]
```

**Step 3: Set up Storybook (component library SETUP)**

Install:
```bash
npx storybook@latest init
```

Test:
```bash
npm run storybook -- --ci
```

Use:
```bash
# Start Storybook
npm run storybook
```

#### Validation

```bash
# Verify Storybook builds (headless, no browser needed)
npx build-storybook --quiet 2>&1 | tail -5

# Check component count
find src/components -name "*.stories.*" | wc -l
```

Criteria:
- Component library chosen from matrix (see `tools/component-matrix.md`)
- Design tokens wired into component styles (not hardcoded values)
- Storybook initialized and builds successfully

---

### 6. Responsive Design

#### Vision

Mobile-first means writing base styles for mobile, then adding complexity
for larger screens. Container queries mean components adapt to their
container — not just the viewport.

The goal: UI that works at any size without breakpoint math.

#### Execution

**Step 1: Set up fluid typography (no media queries needed)**

```css
:root {
  --text-base: clamp(1rem, 0.5vw + 0.875rem, 1.125rem);
  --text-xl:   clamp(1.5rem, 2vw + 1rem, 3rem);
  --text-2xl:  clamp(2rem, 4vw + 1rem, 4.5rem);
}
body { font-size: var(--text-base); }
```

**Step 2: Implement auto-fit grid (no breakpoints for cards)**

```css
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-4);
}
```

**Step 3: Add container queries for component responsiveness**

```css
.card-container { container-type: inline-size; }

@container (min-width: 400px) {
  .card { flex-direction: row; }
}
@container (max-width: 399px) {
  .card { flex-direction: column; }
}
```

**Step 4: Set responsive images**

```html
<picture>
  <source type="image/avif"
    srcset="hero-400.avif 400w, hero-800.avif 800w, hero-1200.avif 1200w"
    sizes="(max-width: 480px) 100vw, (max-width: 1024px) 80vw, 1200px">
  <img src="hero-800.webp" loading="lazy" alt="Descriptive alt text">
</picture>
```

**Step 5: Test responsive behavior**

Install Lighthouse CI:
```bash
npm install -g @lhci/cli
```

Test:
```bash
lhci --version
```

Use:
```bash
# Create lhci config
cat > lighthouserc.json << 'EOF'
{
  "ci": {
    "collect": { "url": ["http://localhost:3000"] },
    "assert": { "preset": "lighthouse:recommended" }
  }
}
EOF
lhci autorun
```

#### Validation

```bash
# Check for fixed-width containers (anti-pattern)
grep -r "width: [0-9]*px" src/ --include="*.css" | grep -v "max-width\|min-width\|border\|outline" | wc -l

# Check that tap targets are large enough (min 44px)
grep -r "height: [0-9]*px\|min-height: [0-9]*px" src/ --include="*.css" | \
  awk -F'[:px]' '{if($2+0 < 44 && $2+0 > 0) print $0}' | wc -l
```

Criteria:
- All 4 breakpoints tested (mobile <480, tablet 481-768, desktop 769-1024, wide ≥1200)
- Touch targets ≥44×44px for all interactive elements
- No hardcoded container widths in component styles

---

### 7. Usability Review

#### Vision

Automated tools catch 25–40% of accessibility issues. The remaining
60–75% require human review. Know the boundary.

What AI agents can automate:
1. Semantic HTML check (landmark elements, heading hierarchy)
2. Color contrast check (APCA/WCAG ratio)
3. Touch target size
4. Keyboard focus order
5. ARIA label presence
6. CSS unit check (rem vs px)

What requires human review:
- Screen reader experience (VoiceOver, NVDA)
- Cognitive load and comprehension
- Real user task completion
- Context-appropriate motion sensitivity

#### Execution

**Step 1: Run axe-core (primary accessibility audit)**

Install:
```bash
npm install -g @axe-core/cli
```

Test:
```bash
axe --version
```

Use:
```bash
# Full WCAG 2.1 AA audit
axe http://localhost:3000 --tags wcag2a,wcag2aa --exit

# Get structured JSON output
axe http://localhost:3000 --tags wcag2aa --reporter json > axe-report.json
```

**Step 2: Run Lighthouse CI (performance + accessibility)**

Install:
```bash
npm install -g @lhci/cli
```

Use:
```bash
lhci autorun
```

**Step 3: Run Pa11y (additional checks, different rule engine)**

Install:
```bash
npm install -g pa11y
```

Test:
```bash
pa11y --version
```

Use:
```bash
# Run against multiple pages
pa11y http://localhost:3000 --standard WCAG2AA --reporter cli
pa11y http://localhost:3000/products --standard WCAG2AA

# Save report
pa11y http://localhost:3000 --reporter json > pa11y-report.json
```

**Step 4: Run CSS unit audit (no px in semantic layer)**

```bash
# Count hardcoded px values in component styles
grep -r "font-size: [0-9]*px\|margin: [0-9]*px\|padding: [0-9]*px" src/ \
  --include="*.css" --include="*.scss" | grep -v "var(\|clamp(\|calc(" | wc -l
```

**Step 5: Run PurgeCSS to check CSS bloat**

Install:
```bash
npm install -g purgecss
```

Test:
```bash
purgecss --version
```

Use:
```bash
purgecss --css dist/styles.css --content dist/**/*.html dist/**/*.js \
  --output dist/styles.purged.css
# Compare sizes
wc -c dist/styles.css dist/styles.purged.css
```

#### Validation

```bash
# All automated checks must pass (exit code 0)
axe http://localhost:3000 --tags wcag2aa --exit && echo "axe: PASS"
pa11y http://localhost:3000 --standard WCAG2AA && echo "pa11y: PASS"

# Summarize findings
cat axe-report.json | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'axe violations: {len(d.get(\"violations\",[]))}')"
```

Criteria:
- axe-core: zero critical + serious violations
- Lighthouse accessibility score ≥90
- Pa11y: zero WCAG AA failures
- Manual review checklist in `checklists/accessibility.md` completed

---

### 8. Design System Documentation

#### Vision

Documentation that's separate from the component is documentation that
will be out of date in 3 months. Automate what can be automated;
write narrative for what cannot.

Must-have documentation:
- Props/API table (auto-generated)
- Usage example (code block + rendered preview)
- Do/Don't visual rules
- ARIA roles and keyboard behavior

#### Execution

**Step 1: Configure Storybook autodocs (CONFIGURATION — C5 owns SETUP)**

After Storybook is initialized (C5), configure autodocs:

```bash
# .storybook/main.js
cat >> .storybook/main.js << 'EOF'
// Enable autodocs for all stories tagged with 'autodocs'
module.exports = {
  docs: { autodocs: 'tag' }
}
EOF
```

Install essential addons:
```bash
npm install --save-dev \
  @storybook/addon-docs \
  @storybook/addon-a11y \
  @storybook/addon-actions \
  @storybook/addon-viewport
```

Use (start documentation build):
```bash
npx build-storybook
```

**Step 2: Generate component API docs**

Install:
```bash
npm install -g react-docgen
```

Test:
```bash
npx react-docgen --version
```

Use:
```bash
# Extract props documentation
npx react-docgen src/components/Button.tsx -o docs/ButtonAPI.json

# Generate for all components
find src/components -name "*.tsx" | \
  xargs -I{} npx react-docgen {} -o docs/{}.json 2>/dev/null
```

If React: Storybook reads TypeScript interfaces automatically via `@storybook/addon-docs`.

**Step 3: Generate design.md for the project**

Use `DESIGN-TEMPLATE.md` as the template. Fill each of the 9 sections:
1. Visual Theme & Atmosphere
2. Color Palette & Roles
3. Typography Rules
4. Component Stylings
5. Layout Principles
6. Depth & Elevation
7. Do's and Don'ts
8. Responsive Behavior
9. Agent Prompt Guide

```bash
# Copy template to project
cp DESIGN-TEMPLATE.md PROJECT_NAME.DESIGN.md
# Edit each section with project-specific values
```

**Step 4: Export token documentation**

```bash
# Generate Markdown table from tokens JSON
python3 -c "
import json
tokens = json.load(open('examples/starter-tokens.json'))
for level, entries in tokens.items():
    print(f'## {level.capitalize()} Tokens')
    print('| Token | Value |')
    print('|-------|-------|')
    for k, v in entries.items():
        val = v.get('value', v) if isinstance(v, dict) else v
        print(f'| {k} | {val} |')
    print()
" > docs/tokens.md
```

#### Validation

```bash
# Verify Storybook builds
npx build-storybook --quiet && echo "Storybook: PASS"

# Check each component has a story
find src/components -name "*.tsx" | while read f; do
  base="${f%.tsx}"
  ls "${base}.stories.tsx" "${base}.stories.ts" 2>/dev/null || \
    echo "Missing story: $f"
done
```

Criteria:
- Every component has a Storybook story with autodocs tag
- Props table auto-generated (no manual API docs)
- DESIGN.md present in project root
- Do/Don't examples for each component

---

### 9. Design Iteration Decisions

#### Vision

Design decisions that aren't documented are design decisions that will
be re-litigated. Use Architecture Decision Record (ADR) format, adapted
for design: Context + Decision + Measurable Consequence.

#### Execution

**Step 1: Create design ADR for each significant decision**

```bash
mkdir -p decisions
cat > decisions/001-aesthetic-direction.md << 'EOF'
# Design Decision 001: Aesthetic Direction

**Date**: YYYY-MM-DD
**Status**: Accepted

## Context
[User need or friction that prompted this decision]

## Decision
[Specific pattern, token value, or rule adopted — be concrete]
Example: "Using brutalist aesthetic with Syne Mono + Space Grotesk typefaces,
#FF3B30 as single accent against #0A0A0A background"

## Consequences
[Measurable impact — A/B test result, user feedback, metric change]
Example: "Hero bounce rate dropped 12% after switching from Inter to Syne Mono"
EOF
```

**Step 2: Set up A/B testing for design decisions**

Install PostHog:
```bash
npm install posthog-js
```

Test:
```bash
node -e "require('posthog-js'); console.log('PostHog installed')"
```

Use:
```bash
# Initialize PostHog with feature flags for design variants
# In your app entry point:
cat > posthog-init.js << 'EOF'
import posthog from 'posthog-js'
posthog.init('YOUR_PROJECT_KEY', { api_host: 'https://app.posthog.com' })
// Check variant in component:
// const variant = posthog.getFeatureFlag('hero-design-test') // 'control' | 'variant-a'
EOF
```

**Step 3: Version design tokens via Git**

```bash
# Tag token versions
git tag tokens-v1.0.0
git push origin tags/tokens-v1.0.0

# Compare token changes between versions
git diff tokens-v1.0.0 tokens-v2.0.0 -- examples/starter-tokens.json
```

**Step 4: Run measurable design review**

```bash
# Full automated checklist
echo "=== Design Review Checklist ==="
echo "1. Semantic HTML check:"
axe http://localhost:3000 --tags best-practice --exit && echo "PASS" || echo "FAIL"

echo "2. Relative units check (should be 0):"
grep -r "font-size: [0-9]*px" src/ --include="*.css" | grep -v "var(\|clamp(" | wc -l

echo "3. Color proportions (60-30-10) — manual check required"

echo "4. Touch targets (44px min) check:"
grep -r "height: [1-3][0-9]px" src/ --include="*.css" | wc -l

echo "5. Contrast check:"
pa11y http://localhost:3000 --standard WCAG2AA 2>&1 | grep -c "^Issue" || echo "0 issues"
```

#### Validation

```bash
# Decision log should grow — check it exists
ls decisions/0*.md 2>/dev/null | wc -l

# Token versions should be tagged
git tag | grep "tokens-v" | wc -l
```

Criteria:
- One ADR per significant design decision (color, typography, navigation, component choice)
- A/B test set up for any non-obvious UI choices
- Token changes tracked in Git with version tags
- No undocumented design reversals

---

## Agent Loading Guide

### Phase 1: Claude Code

After running `bash install.sh`, this file is available at:
```
.claude/skills/web-ui-design/SKILL.md
```

To activate in a conversation:
- Claude Code loads skills automatically from `.claude/skills/`
- Reference specific capabilities: "Use C3 and C7 from the web-ui-design pack"
- Or run the full pipeline: "Design this UI using the web-ui-design capability pack"

### Phase 3 (Future — Interfaces Reserved)

The `## Capability N` markers in this file are designed for splitting
into per-capability files for smaller-context agents:

```bash
# Extract single capability
awk '/^### 3\./,/^### 4\./' CAPABILITY.md > c3-visual-design.md
```

Planned support:
- **Codex**: reference in `AGENTS.md`
- **Cursor**: embed in `.cursorrules` or `.cursor/rules/`
- **Gemini CLI**: pass via `-p` with context file
- **Generic**: drop `CAPABILITY.md` in project root
