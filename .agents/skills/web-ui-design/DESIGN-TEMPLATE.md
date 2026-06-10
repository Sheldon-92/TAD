# [PROJECT NAME] Design System

> Project-specific DESIGN.md following the 9-section standard.
> Fill each section with values specific to your brand/project.
> This file is consumed by AI agents to maintain design consistency.

**Version**: 1.0.0
**Last Updated**: [DATE]
**Design Direction**: [YOUR AESTHETIC — e.g., "Brutalist", "Luxury", "Organic"]

---

## 1. Visual Theme & Atmosphere

<!-- Describe the emotional direction and visual feeling of this design system. -->
<!-- Be specific. "Clean and minimal" is not enough. -->

**Aesthetic Direction**: [One of: Brutalist / Retro-futuristic / Luxury / Organic / Art Deco / Maximalist / other]

**Emotional Target**: [How should users feel? e.g., "Confident and precise, like a professional tool. No decoration — every element earns its place."]

**Visual Keywords**: [3–5 adjectives, e.g., "Raw, structured, intentional, typographic"]

**Anti-patterns for this brand**: [What this design explicitly avoids, e.g., "No rounded corners, no gradients, no decorative icons"]

---

## 2. Color Palette & Roles

<!-- Use semantic names + hex values + functional roles. -->
<!-- Follow 60-30-10 rule: 60% dominant, 30% secondary, 10% accent. -->

### Primary Palette

| Role | Semantic Name | Value | Usage |
|------|--------------|-------|-------|
| Background (60%) | `color-background-base` | `#______` | Page background, large surfaces |
| Surface (30%) | `color-surface-elevated` | `#______` | Cards, sidebars, panels |
| Action (10%) | `color-action-primary` | `#______` | CTAs, links, active states |
| Text Primary | `color-text-primary` | `#______` | Body copy, headings |
| Text Secondary | `color-text-secondary` | `#______` | Labels, captions, metadata |
| Border | `color-border-default` | `#______` | Dividers, input borders |

### State Colors

| State | Value | Usage |
|-------|-------|-------|
| Success | `#______` | Confirmations, success messages |
| Warning | `#______` | Caution states |
| Error | `#______` | Errors, destructive actions |
| Info | `#______` | Informational messages |

### Dark Mode

| Light Value | Dark Value | Token Name |
|-------------|-----------|-----------|
| `#______` | `#______` | `color-background-base` |
| `#______` | `#______` | `color-surface-elevated` |

---

## 3. Typography Rules

### Typefaces

| Role | Family | Fallback | Source |
|------|--------|---------|--------|
| Display / Headings | `______` | `serif` | [Google Fonts / CDN / local] |
| Body | `______` | `sans-serif` | [Google Fonts / CDN / local] |
| Monospace | `______` | `monospace` | [for code blocks] |

### Type Scale

| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|------------|-------|
| Display | `clamp(2rem, 4vw + 1rem, 4.5rem)` | 300 | 1.1 | Hero headlines |
| Heading 1 | `clamp(1.75rem, 3vw + 0.5rem, 3rem)` | 500 | 1.2 | Page titles |
| Heading 2 | `clamp(1.25rem, 2vw + 0.5rem, 1.75rem)` | 500 | 1.3 | Section headers |
| Body | `clamp(1rem, 0.5vw + 0.875rem, 1.125rem)` | 400 | 1.6 | All body copy |
| Label | `0.875rem` | 500 | 1.4 | Form labels, UI elements |
| Caption | `0.75rem` | 400 | 1.5 | Metadata, timestamps |

### OpenType Features

```css
/* Apply project-specific OpenType features here */
.display-text {
  font-feature-settings: "ss01", "cv02"; /* Example: stylistic sets */
}
.financial-data {
  font-feature-settings: "tnum"; /* Tabular numbers for data tables */
}
```

---

## 4. Component Stylings

<!-- Define styling rules for core UI components. Be specific. -->

### Buttons

```css
/* Primary Button */
.btn-primary {
  background: var(--color-action-primary);
  color: var(--color-text-on-action);
  border-radius: ____px; /* e.g., 0px for brutalist, 8px for organic */
  padding: ____px ____px;
  font-weight: 500;
  transition: background-color 80ms ease;
}
```

| State | Background | Text | Border |
|-------|-----------|------|--------|
| Default | `#______` | `#______` | none |
| Hover | `#______` | `#______` | none |
| Active | `#______` | `#______` | none |
| Disabled | `#______` | `#______` | none |

### Inputs

```css
.input {
  border: 1px solid var(--color-border-default);
  border-radius: ____px;
  padding: ____px ____px;
  background: var(--color-surface-elevated);
}
.input:focus {
  outline: 2px solid var(--color-action-primary);
  outline-offset: 2px;
}
```

### Cards

```css
.card {
  background: var(--color-surface-elevated);
  border-radius: ____px;
  padding: ____px;
  /* Shadow: choose one */
  box-shadow: ____; /* e.g., rgba(0,0,0,0.08) 0px 0px 0px 1px */
}
```

### Navigation

[Describe navigation component styling: height, active state, hover state, mobile behavior]

---

## 5. Layout Principles

### Spacing Scale

Base unit: ____px (typically 4px or 8px)

| Token | Value | Usage |
|-------|-------|-------|
| `spacing-1` | ____px | Tight spacing |
| `spacing-2` | ____px | Element padding |
| `spacing-4` | ____px | Component padding |
| `spacing-8` | ____px | Section padding |
| `spacing-16` | ____px | Page sections |

### Grid

```css
.container {
  max-width: ____px; /* e.g., 1200px or 1440px */
  padding: 0 var(--spacing-4);
  margin: 0 auto;
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-4);
}
```

### Whitespace Philosophy

[Describe the whitespace approach: generous/dense/balanced, and why]

---

## 6. Depth & Elevation

### Shadow System

| Level | Shadow | Usage |
|-------|--------|-------|
| Flat | `none` | Cards in dark surfaces |
| Low | `____` | Default card elevation |
| Medium | `____` | Dropdowns, popovers |
| High | `____` | Modals, dialogs |
| Overlay | `____` | Drawers, sidesheets |

Example (Vercel-style shadow-as-border):
```css
--shadow-low:    rgba(0,0,0,0.08) 0px 0px 0px 1px;
--shadow-medium: rgba(0,0,0,0.08) 0px 0px 0px 1px, rgba(0,0,0,0.04) 0px 2px 4px;
--shadow-high:   rgba(0,0,0,0.12) 0px 4px 24px;
```

### Border Radius

| Scale | Value | Usage |
|-------|-------|-------|
| None | `0px` | Brutalist elements |
| Small | `2px` | Input borders, tags |
| Default | `8px` | Cards, buttons |
| Large | `16px` | Modals, large containers |
| Full | `9999px` | Pills, avatars |

---

## 7. Do's and Don'ts

### Do's

- [ ] Use semantic color token names (not primitive hex codes directly in components)
- [ ] Maintain 60-30-10 color proportions across all views
- [ ] Use fluid typography (`clamp()`) instead of fixed `px` font sizes
- [ ] Apply APCA contrast: LC ≥60 for body text, ≥45 for large text
- [ ] Use `container-type: inline-size` for component-level responsive behavior
- [ ] Test all interactive elements with keyboard only
- [ ] Include visible `:focus-visible` styles on every interactive element
- [ ] [Add project-specific rules here]

### Don'ts

- [ ] Never use Inter, Roboto, or Arial as primary typeface (anti-slop rule)
- [ ] Never use purple/blue gradient on white as a primary design pattern
- [ ] Never scatter micro-interactions — max one high-impact animation per page
- [ ] Never use `outline: none` without a `focus-visible` replacement
- [ ] Never hardcode hex colors in component styles (use tokens)
- [ ] Never use breakpoints alone for component responsiveness (use container queries)
- [ ] [Add project-specific anti-patterns here]

---

## 8. Responsive Behavior

### Breakpoints

| Name | Range | Intent |
|------|-------|--------|
| Mobile | `< 480px` | Base styles — no media query needed |
| Tablet | `481px – 768px` | `@media (min-width: 481px)` |
| Desktop | `769px – 1024px` | `@media (min-width: 769px)` |
| Wide | `≥ 1200px` | `@media (min-width: 1200px)` |

### Component Collapsing Rules

| Component | Mobile | Desktop |
|-----------|--------|---------|
| Navigation | Bottom tab bar / hamburger | Top nav / sidebar |
| Data table | Horizontal scroll / card stack | Full table |
| Sidebar | Drawer (off-canvas) | Fixed visible |
| Hero | Full-height stacked | Split layout |

### Touch Targets

All interactive elements: **minimum 44×44px** on touch devices.

```css
@media (pointer: coarse) {
  .interactive-element {
    min-height: 44px;
    min-width: 44px;
  }
}
```

---

## 9. Agent Prompt Guide

<!-- Reusable prompts for AI agents working with this design system. -->
<!-- Include the values from sections 2-6 in shorthand for quick reference. -->

### Quick Reference for Agents

```
Primary: #______ (60% — background)
Secondary: #______ (30% — surfaces)
Accent: #______ (10% — actions)
Text: #______ / #______ (primary / secondary)

Heading font: ______
Body font: ______
Base size: clamp(1rem, 0.5vw + 0.875rem, 1.125rem)

Spacing base: ____px
Border radius: ____px default
Shadow: ______
```

### Starter Prompts

**Building a new component:**
"Build a [component name] using the design system. Use tokens from the :root CSS
variables. Follow [AESTHETIC DIRECTION] aesthetic. Apply APCA contrast rules."

**Adding a new section:**
"Add a [section type] section. Follow the 60-30-10 color distribution.
Use the typography scale defined in DESIGN.md. No flat solid backgrounds."

**Design review:**
"Review this UI component against the design system rules in DESIGN.md.
Check: token usage (no raw hex), 60-30-10 proportions, fluid typography,
44px tap targets, focus-visible styles."

**Iteration instruction:**
"The [component] needs to feel more [aesthetic direction]. Keep the token
structure but adjust [specific property: shadow / spacing / typography weight]."
