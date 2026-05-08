# Brand Token Examples

Real design system token values from production brands.
Use as **reference only** — these are not defaults for your project.

> Tokens sourced from public design systems and open-source documentation.

---

## Vercel — Minimalist Achromatic

**Aesthetic direction**: Achromatic precision, shadows-as-borders, negative space.

### Colors

| Token Name | Value | Usage |
|-----------|-------|-------|
| `color-background-base` | `#ffffff` | Page background (light) |
| `color-background-base-dark` | `#000000` | Page background (dark) |
| `color-text-primary` | `#171717` | Body text, headings |
| `color-text-secondary` | `#888888` | Metadata, captions |
| `color-action-ship` | `#ff5b4f` | Ship/deploy actions (red) |
| `color-action-preview` | `#de1d8d` | Preview states (pink) |
| `color-action-develop` | `#0a72ef` | Development states (blue) |
| `color-border-default` | `rgba(0,0,0,0.08)` | Borders via box-shadow |

### Typography

| Property | Value |
|---------|-------|
| Primary font | `Geist Sans` |
| Monospace font | `Geist Mono` |
| Letter spacing (display) | `-2.4px` at 48px |
| Weight system | `400 / 500 / 600` |

### Elevation (Shadow-as-Border Pattern)

```css
--shadow-border: rgba(0,0,0,0.08) 0px 0px 0px 1px;
--shadow-low:    rgba(0,0,0,0.08) 0px 0px 0px 1px,
                 rgba(0,0,0,0.04) 0px 2px 4px;
--shadow-medium: rgba(0,0,0,0.08) 0px 0px 0px 1px,
                 rgba(0,0,0,0.08) 0px 4px 16px;
--shadow-high:   rgba(0,0,0,0.12) 0px 4px 24px;
```

---

## Stripe — Fintech Precision

**Aesthetic direction**: Luxury fintech, blue-tinted depth, typographic precision.

### Colors

| Token Name | Value | Usage |
|-----------|-------|-------|
| `color-brand-primary` | `#533afd` | Stripe purple — CTAs, links |
| `color-background-base` | `#ffffff` | Page background |
| `color-background-dark` | `#061b31` | Deep navy — dark sections |
| `color-text-primary` | `#0a2540` | Near-black blue — body text |
| `color-text-secondary` | `#425466` | Secondary text |
| `color-action-primary` | `#635bff` | Button/link blue-purple |
| `color-accent-cyan` | `#00d4ff` | Accent for light backgrounds |

### Typography

| Property | Value |
|---------|-------|
| Primary font | `sohne-var` |
| OpenType features | `"ss01"` (stylistic set 1) |
| Display weight | `300` (light, large headlines) |
| Financial data | `font-feature-settings: "tnum"` |

### Shadows (Blue-Tinted)

```css
--shadow-card: rgba(50,50,93,0.25) 0px 13px 27px -5px,
               rgba(0,0,0,0.3) 0px 8px 16px -8px;
--shadow-low:  rgba(50,50,93,0.11) 0px 2px 5px 0px,
               rgba(0,0,0,0.08) 0px 1px 1px 0px;
```

### Dense Spacing (Data Tables)

Stripe uses ultra-dense spacing at small end for data-rich interfaces:

```css
--spacing-0-5: 1px;
--spacing-1:   2px;
--spacing-2:   4px;
--spacing-3:   6px;
--spacing-4:   8px;
--spacing-5:   10px;
--spacing-5-5: 11px;
--spacing-6:   12px;
```

---

## Linear — Precision Productivity

**Aesthetic direction**: Dark-first, focused, power-user precision.

### Colors

| Token Name | Value | Usage |
|-----------|-------|-------|
| `color-brand-primary` | `#5e6ad2` | Linear violet — primary action |
| `color-background-base` | `#1a1a1a` | Page background (dark) |
| `color-surface-elevated` | `#222222` | Cards, panels |
| `color-surface-overlay` | `#2e2e2e` | Hover states, overlays |
| `color-text-primary` | `#e8e8e8` | Primary text |
| `color-text-secondary` | `#8e8e8e` | Secondary, metadata |
| `color-border-default` | `rgba(255,255,255,0.08)` | Subtle borders |
| `color-accent-green` | `#4caf50` | Success, completed states |

### Typography

| Property | Value |
|---------|-------|
| Primary font | `-apple-system, BlinkMacSystemFont` |
| Heading sizes | `13/14/16/20/24px` (dense scale) |
| Body | `14px` base size |
| Line height | `1.4` (dense) |

### Spacing (Keyboard-First, Dense)

```css
--spacing-1: 4px;
--spacing-2: 8px;
--spacing-3: 12px;
--spacing-4: 16px;
--spacing-6: 24px;
--spacing-8: 32px;
```

---

## How to Adapt Reference Tokens

To adapt any of these patterns to your project:

1. **Keep the structure** (primitive → semantic → component) from `examples/starter-tokens.json`
2. **Replace primitive values** with your brand colors
3. **Map semantic roles** to your primitive values
4. **Compile** via `bash tools/tokens-to-css.sh your-tokens.json > tokens.css`

Example adaptation:
```json
{
  "primitive": {
    "brand-primary": "#533afd",
    "surface-dark": "#061b31"
  },
  "semantic": {
    "color-action-primary": { "value": "var(--primitive-brand-primary)" },
    "color-background-dark": { "value": "var(--primitive-surface-dark)" }
  }
}
```

---

## Token Naming Conventions by Brand

| Brand | Naming Style | Example |
|-------|-------------|---------|
| Stripe | Contextual | `--colorBackground`, `--colorPrimary` |
| Vercel | Semantic + level | `--ds-background-100`, `--ds-blue-900` |
| Linear | Role-based | `--color-text-primary`, `--color-surface-1` |
| Shopify Polaris | Component-aware | `--p-color-bg-surface`, `--p-color-text` |

The convention in this pack (from `examples/starter-tokens.json`):
`--{level}-{role}-{modifier}` e.g., `--semantic-color-action-primary`
