# Design System Architecture Patterns

Patterns from production design systems: Shopify Polaris, GitHub Primer, Adobe Spectrum.
Use these as templates when building your own design system infrastructure.

---

## Common Architecture: Monorepo Package Separation

All major design systems use monorepo with strict package boundaries:

```
my-design-system/
├── packages/
│   ├── tokens/          ← design tokens (independently versioned)
│   ├── icons/           ← icon assets
│   ├── react/           ← React components
│   ├── vue/             ← Vue components (if multi-framework)
│   └── docs/            ← Storybook documentation
├── apps/
│   └── storybook/       ← documentation app
└── tools/
    └── build/           ← shared build scripts
```

**Key principle**: tokens package is independently versioned and published.
Components depend on tokens; tokens don't depend on components.

---

## Shopify Polaris Pattern

**Packages**: `polaris-react`, `polaris-tokens`, `polaris-icons`
**Key insight**: token package ships standalone, consumed by apps without React.

### Token Architecture

```
polaris-tokens/
├── src/
│   ├── themes/
│   │   ├── base.ts        ← light theme (default)
│   │   └── dark.ts        ← dark theme overrides
│   └── index.ts
└── dist/
    ├── tokens.css         ← CSS custom properties
    ├── tokens.json        ← raw JSON for tooling
    └── index.js           ← JS exports
```

### Theme-Aware Token Pattern

```css
/* Light theme (default) */
:root {
  --p-color-bg-surface: #ffffff;
  --p-color-text: #1a1a1a;
  --p-color-border: rgba(0,0,0,0.12);
}

/* Dark theme override */
[data-polaris-theme="dark"] {
  --p-color-bg-surface: #1a1a1a;
  --p-color-text: #e8e8e8;
  --p-color-border: rgba(255,255,255,0.12);
}
```

---

## GitHub Primer Pattern

**Key insight**: shifting from JS-prop responsiveness to native CSS (Container Queries, CSS Anchor Positioning).

### CSS-First Responsive Components

```css
/* Primer approach: components adapt via CSS, not JS props */
.Box {
  container-type: inline-size;
}

@container (min-width: 544px) {
  .Box-item { flex-direction: row; }
}

@container (max-width: 543px) {
  .Box-item { flex-direction: column; }
}
```

### Visual Regression Testing Setup (Primer uses Playwright)

```json
{
  "scripts": {
    "vrt": "playwright test --config=vrt.config.ts",
    "vrt:update": "playwright test --config=vrt.config.ts --update-snapshots"
  }
}
```

---

## Adobe Spectrum Pattern

**Key insight**: 3-layer architecture — logic / accessibility / visual are separated.

```
React Stately     → State management (no UI)
React Aria        → Accessibility behavior (keyboard, ARIA, focus)
React Spectrum    → Visual components (uses Stately + Aria)
```

**Why this matters for AI agents**: you can use React Aria alone (no Spectrum styling)
to get accessibility without design opinions:

```bash
npm install react-aria
# Hooks only — bring your own styling
```

### Automatic Dark Mode

```css
/* Spectrum approach: components adapt automatically via tokens */
:root {
  color-scheme: light dark;
}

@media (prefers-color-scheme: dark) {
  :root {
    --spectrum-global-color-gray-50: rgb(29, 29, 29);
    --spectrum-global-color-gray-75: rgb(38, 38, 38);
  }
}
```

---

## Testing Strategies by Design System

| Design System | Visual Regression | Accessibility CI | E2E |
|--------------|------------------|-----------------|-----|
| Shopify Polaris | Chromatic | GitHub Actions + axe | — |
| GitHub Primer | Playwright snapshots | GitHub Actions | Playwright |
| Adobe Spectrum | Chromatic + Storybook VRT | WAI-ARIA compliance | — |
| Ant Design | image-snapshot + Puppeteer | — | — |
| Vercel Geist | Chromatic | — | — |

---

## Token Versioning Pattern

Treat token changes like API changes — they affect every consumer.

```bash
# Tag token releases
git tag tokens-v1.2.0
git push origin tags/tokens-v1.2.0

# Patch: non-breaking value adjustment (e.g., color tweak within same hue)
git tag tokens-v1.2.1

# Minor: new tokens added (backward compatible)
git tag tokens-v1.3.0

# Major: token renamed or removed (breaking change)
git tag tokens-v2.0.0
```

### Automated Token Change Detection

```bash
# Compare token sets between versions
git show tokens-v1.1.0:examples/starter-tokens.json > /tmp/tokens-old.json
diff <(jq -r 'path(..) | join(".")' /tmp/tokens-old.json | sort) \
     <(jq -r 'path(..) | join(".")' examples/starter-tokens.json | sort)
```

---

## Component API Patterns

### Radix/Ark: Compound Components

```jsx
// Compound component pattern — predictable, composable
<Dialog.Root>
  <Dialog.Trigger asChild>
    <button>Open</button>
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Title>Title</Dialog.Title>
    <Dialog.Description>Description</Dialog.Description>
    <Dialog.Close>Close</Dialog.Close>
  </Dialog.Content>
</Dialog.Root>
```

### Ant Design: TypeScript-Anchored Props

```tsx
interface ButtonProps {
  type?: 'primary' | 'default' | 'dashed' | 'link' | 'text';
  size?: 'large' | 'middle' | 'small';
  loading?: boolean | { delay?: number };
  icon?: ReactNode;
  onClick?: (event: React.MouseEvent) => void;
}
```

---

## Design System Documentation: Must-Have Storybook Addons

Install these for a production-grade Storybook:

```bash
npm install --save-dev \
  @storybook/addon-docs \
  @storybook/addon-a11y \
  @storybook/addon-actions \
  @storybook/addon-backgrounds \
  @storybook/addon-viewport \
  @storybook/addon-controls
```

Storybook config (`/.storybook/main.js`):

```js
module.exports = {
  addons: [
    '@storybook/addon-docs',
    '@storybook/addon-a11y',
    '@storybook/addon-actions',
    '@storybook/addon-backgrounds',
    '@storybook/addon-viewport',
    '@storybook/addon-controls',
  ],
  docs: { autodocs: 'tag' },
};
```

---

## Inactive Frameworks to Avoid (2026)

These CSS frameworks are stalled — do not start new projects with them:

| Framework | Status | Last significant release |
|-----------|--------|-------------------------|
| Semantic UI | Inactive | 2018 |
| Material Components Web | Deprecated | 2022 |
| Tachyons | Inactive | 2019 |
| Bourbon | Archived | 2021 |
| Water.css | Unmaintained | 2021 |
| sanitize.css | Unmaintained | 2022 |
