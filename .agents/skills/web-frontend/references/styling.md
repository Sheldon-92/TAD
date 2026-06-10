# Styling Strategy Judgment Rules

> React-first. [Vue] and [Svelte] equivalents noted in brackets.

---

## Rule 1: Styling Approach Selection

**When**: Starting a new component or application and choosing between Tailwind CSS, CSS Modules, and vanilla CSS.

**Decision**: Use this decision framework:

| Situation | Approach | Reason |
|-----------|----------|--------|
| Rapid prototyping, AI-assisted development | **Tailwind CSS** | Utility-first, AI generates consistent class names, no naming decisions |
| Component library with strict style encapsulation | **CSS Modules** | Auto-scoped class names eliminate conflicts, co-located styles |
| Complex, performance-critical animations / logic-heavy UIs | **Vanilla CSS (Modern)** | Container Queries, custom properties, native animations reduce JS bundle |
| Design token integration without custom Tailwind config | **CSS Modules + custom properties** | Tokens as `:root` variables, consumed via `var(--token)` |

**Threshold**: Pick ONE primary approach per project. Mixing Tailwind + CSS-in-JS + vanilla in the same codebase creates style conflicts and maintenance overhead. CSS Modules + custom properties is the safest combination for design system integration.

**Anti-pattern**:
```typescript
// ❌ Three styling systems in one component — maintenance nightmare
const Button = styled.button`  // CSS-in-JS
  ${tw`flex items-center`}     // Tailwind-in-styled
  border: 1px solid ${theme.colors.border};  // custom prop
`
```

**Source**: [Tailwind CSS — Utility-First Fundamentals](https://tailwindcss.com/docs/utility-first); [CSS Modules — GitHub](https://github.com/css-modules/css-modules); Research finding: "Gap between utility-first and design systems has narrowed (2026)"

[Vue: same decision matrix; scoped styles in SFCs (`<style scoped>`) ≈ CSS Modules]
[Svelte: `<style>` in `.svelte` files is automatically scoped — equivalent to CSS Modules]

---

## Rule 2: Responsive Design — Mobile-First with Breakpoint Tokens

**When**: Writing any component that must work across screen sizes.

**Decision**: Write mobile styles first, then add breakpoint overrides for larger screens. Use exactly 4 breakpoints (mobile default, sm/768px, lg/1024px, xl/1280px). Avoid custom breakpoints per component.

**Threshold**: 
- >4 distinct breakpoints in a project → consolidate
- Any component with >3 media queries → redesign using Container Queries instead
- Components that only change layout (not content) at breakpoints → use CSS Grid/Flexbox auto-flow

**Anti-pattern**:
```css
/* ❌ Desktop-first with many custom breakpoints */
.card { width: 400px; }                       /* Desktop default */
@media (max-width: 1200px) { .card { width: 350px; } }
@media (max-width: 900px) { .card { width: 300px; } }
@media (max-width: 600px) { .card { width: 100%; } }

/* ✅ Mobile-first with standard breakpoints */
.card { width: 100%; }                        /* Mobile default */
@media (min-width: 768px) { .card { width: 300px; } }
@media (min-width: 1024px) { .card { width: 400px; } }
```

```typescript
// ✅ Tailwind mobile-first equivalents
<div className="w-full sm:w-72 lg:w-96" />
```

**Source**: [Tailwind CSS — Responsive Design](https://tailwindcss.com/docs/responsive-design); [MDN — Mobile-first responsive design](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout/Responsive_Design)

[Vue: same breakpoint conventions; use VueTailwind or custom CSS]
[Svelte: same conventions; Svelte's `<style>` blocks support standard media queries]

---

## Rule 3: Container Queries over Media Queries for Component-Level Responsiveness

**When**: A component needs to change its layout based on the size of its CONTAINER (not the viewport).

**Decision**: Use CSS Container Queries (`@container`). Media queries measure viewport width; container queries measure the component's parent width. This is correct for reusable components used in sidebars, modals, and different page areas.

**Threshold**: If a component changes layout when placed in a sidebar vs a main content area, use Container Queries. Media queries would require context-dependent overrides at every usage site.

**Browser support**: Container Queries are supported in all modern browsers (2023+). Safe to use without fallback.

**Anti-pattern**:
```css
/* ❌ Media query — layout breaks when component is in a narrow sidebar */
.card { display: flex; flex-direction: row; }
@media (max-width: 600px) { .card { flex-direction: column; } }
/* BUG: card stays row even in 250px sidebar at 1440px viewport */

/* ✅ Container Query — responds to the actual available space */
.card-wrapper {
  container-type: inline-size;
  container-name: card;
}
.card { display: flex; flex-direction: column; }
@container card (min-width: 400px) { .card { flex-direction: row; } }
```

**Source**: [MDN — CSS Container Queries](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment/Container_queries); [Google web.dev — Container Queries](https://web.dev/articles/cq-stable)

[Vue: identical CSS feature — no framework differences]
[Svelte: identical CSS feature — works in `<style>` blocks]

---

## Rule 4: Dark Mode Without Component Duplication

**When**: Adding dark mode support to a styled component.

**Decision**: Never add dark mode styles inside component CSS. Dark mode belongs in the token layer (`:root` with `[data-theme="dark"]` override). See `references/design-tokens.md` Rule 6 for the full pipeline.

**Threshold**: If dark mode implementation requires touching more than 1 file (the token/CSS-variables file), the approach is wrong.

**Anti-pattern**:
```css
/* ❌ Component-level dark mode — every new component needs dark styles */
.Button.css:
.button { background: white; color: black; }
.button:where([data-theme="dark"] *) { background: #1a1a1a; color: white; }

/* ✅ Token-only dark mode — components never change */
globals.css / tokens.css:
:root { --color-surface: #ffffff; --color-text: #111827; }
[data-theme="dark"] { --color-surface: #111827; --color-text: #f9fafb; }

Button.module.css:
.button { background: var(--color-surface); color: var(--color-text); }
/* No dark mode class — token swap handles it */
```

**Source**: [Style Dictionary — Dark Mode Theming](https://styledictionary.com/getting-started/); [W3C DTCG format — Mode switching](https://tr.designtokens.org/format/)

---

## Rule 5: CSS Modules — Co-location and Naming Rules

**When**: Using CSS Modules for component styling.

**Decision**: Co-locate `.module.css` with the component file. Use camelCase for class names (matches JavaScript import). Never use global selectors inside `.module.css` — use `:global(.class)` only for third-party library overrides.

**Threshold**: 
- If `.module.css` file is not adjacent to the component → move it
- If class names use kebab-case (`my-button`) instead of camelCase (`myButton`) → refactor (import as `styles['my-button']` is error-prone)
- If `:global()` wrappers cover >10% of the CSS file → the styles should be in `globals.css`

**Anti-pattern**:
```
// ❌ Centralized styles folder — unclear ownership
src/
  styles/
    Button.module.css     → far from Button.tsx
    Header.module.css
    UserCard.module.css
    
// ✅ Co-located styles
src/components/ui/
  Button.tsx
  Button.module.css      → right next to it
  Button.test.tsx
```

```css
/* ❌ kebab-case class names */
.my-button { }          /* styles['my-button'] — fragile string key */
.primary-variant { }

/* ✅ camelCase class names */
.myButton { }           /* styles.myButton — safe property access */
.primaryVariant { }
```

**Source**: [CSS Modules specification](https://github.com/css-modules/css-modules); [Next.js — CSS Modules](https://nextjs.org/docs/app/building-your-application/styling/css-modules)

[Vue: `<style scoped>` achieves the same auto-scoping; use `:deep()` for third-party overrides instead of `:global()`]
[Svelte: built-in scoped styles; use `:global()` sparingly for same reasons]
