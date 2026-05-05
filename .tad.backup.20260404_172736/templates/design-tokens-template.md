# Design Tokens Export Template

> Template for exporting selected design options as structured Design Tokens.
> Alex generates these files after user selection in the Playground.
> Blake uses these tokens as the single source of truth for implementation.

---

## Output Files

After user selection, Alex exports two files to the playground output directory:

1. `design-tokens.css` — CSS Custom Properties format
2. `design-tokens.json` — JSON format (convertible to Tailwind/other framework configs)

---

## 1. CSS Custom Properties Format (`design-tokens.css`)

```css
/* ============================================
   Design Tokens - {Project Name}
   Generated: {YYYY-MM-DD}
   Source: Playground selection by user
   Direction: {Selected Direction Name}
   ============================================ */

:root {
  /* ---- Colors ---- */
  --color-primary: {value};          /* Primary actions, links */
  --color-primary-hover: {value};    /* Primary hover state */
  --color-secondary: {value};        /* Secondary actions */
  --color-secondary-hover: {value};  /* Secondary hover state */
  --color-accent: {value};           /* Highlights, badges */
  --color-background: {value};       /* Page background */
  --color-surface: {value};          /* Card/panel background */
  --color-text: {value};             /* Body text */
  --color-text-secondary: {value};   /* Secondary/muted text */
  --color-border: {value};           /* Borders, dividers */
  --color-error: {value};            /* Error states */
  --color-success: {value};          /* Success states */
  --color-warning: {value};          /* Warning states */
  --color-info: {value};             /* Info states */

  /* ---- Typography ---- */
  /* Recommended web font: {Font Name} (import separately if desired) */
  --font-heading: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --font-body: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --font-mono: ui-monospace, 'SF Mono', SFMono-Regular, Menlo, monospace;

  --font-size-h1: {value};    /* weight: {value}, line-height: {value} */
  --font-size-h2: {value};    /* weight: {value}, line-height: {value} */
  --font-size-h3: {value};    /* weight: {value}, line-height: {value} */
  --font-size-h4: {value};    /* weight: {value}, line-height: {value} */
  --font-size-body: {value};  /* weight: {value}, line-height: {value} */
  --font-size-small: {value}; /* weight: {value}, line-height: {value} */
  --font-size-caption: {value}; /* weight: {value}, line-height: {value} */

  --font-weight-regular: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  --font-weight-extrabold: 800;

  --line-height-tight: 1.2;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;

  /* ---- Spacing ---- */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-2xl: 48px;
  --spacing-3xl: 64px;

  /* ---- Borders ---- */
  --radius-sm: {value};
  --radius-md: {value};
  --radius-lg: {value};
  --radius-xl: {value};
  --radius-full: 9999px;

  --border-width: 1px;
  --border-style: solid;

  /* ---- Shadows ---- */
  --shadow-sm: {value};
  --shadow-md: {value};
  --shadow-lg: {value};
  --shadow-xl: {value};

  /* ---- Transitions ---- */
  --transition-fast: 0.15s ease;
  --transition-normal: 0.2s ease;
  --transition-slow: 0.3s ease;
}

/* Dark mode overrides */
[data-theme="dark"] {
  --color-primary: {value};
  --color-background: {value};
  --color-surface: {value};
  --color-text: {value};
  --color-text-secondary: {value};
  --color-border: {value};
  /* ... override all theme-dependent tokens ... */
}
```

---

## 2. JSON Format (`design-tokens.json`)

```json
{
  "meta": {
    "project": "{Project Name}",
    "generated": "{YYYY-MM-DD}",
    "direction": "{Selected Direction Name}",
    "source": "TAD Playground"
  },
  "colors": {
    "primary":          {"value": "#XXXXXX", "usage": "Primary actions, links"},
    "primary-hover":    {"value": "#XXXXXX", "usage": "Primary hover state"},
    "secondary":        {"value": "#XXXXXX", "usage": "Secondary actions"},
    "secondary-hover":  {"value": "#XXXXXX", "usage": "Secondary hover state"},
    "accent":           {"value": "#XXXXXX", "usage": "Highlights, badges"},
    "background":       {"value": "#XXXXXX", "usage": "Page background"},
    "surface":          {"value": "#XXXXXX", "usage": "Card/panel background"},
    "text":             {"value": "#XXXXXX", "usage": "Body text"},
    "text-secondary":   {"value": "#XXXXXX", "usage": "Secondary/muted text"},
    "border":           {"value": "#XXXXXX", "usage": "Borders, dividers"},
    "error":            {"value": "#XXXXXX", "usage": "Error states"},
    "success":          {"value": "#XXXXXX", "usage": "Success states"},
    "warning":          {"value": "#XXXXXX", "usage": "Warning states"},
    "info":             {"value": "#XXXXXX", "usage": "Info states"}
  },
  "colors-dark": {
    "primary":          {"value": "#XXXXXX"},
    "background":       {"value": "#XXXXXX"},
    "surface":          {"value": "#XXXXXX"},
    "text":             {"value": "#XXXXXX"},
    "text-secondary":   {"value": "#XXXXXX"},
    "border":           {"value": "#XXXXXX"}
  },
  "typography": {
    "font-heading":  {"value": "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif", "recommended": "{Web Font Name}"},
    "font-body":     {"value": "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif", "recommended": "{Web Font Name}"},
    "font-mono":     {"value": "ui-monospace, 'SF Mono', SFMono-Regular, Menlo, monospace"},
    "scale": {
      "h1":      {"size": "2.25rem", "weight": "800", "line-height": "1.2"},
      "h2":      {"size": "1.875rem", "weight": "700", "line-height": "1.25"},
      "h3":      {"size": "1.5rem", "weight": "600", "line-height": "1.3"},
      "h4":      {"size": "1.25rem", "weight": "600", "line-height": "1.35"},
      "body":    {"size": "1rem", "weight": "400", "line-height": "1.5"},
      "small":   {"size": "0.875rem", "weight": "400", "line-height": "1.5"},
      "caption": {"size": "0.75rem", "weight": "400", "line-height": "1.5"}
    }
  },
  "spacing": {
    "xs": "4px", "sm": "8px", "md": "16px", "lg": "24px",
    "xl": "32px", "2xl": "48px", "3xl": "64px"
  },
  "borders": {
    "radius-sm": "{value}", "radius-md": "{value}",
    "radius-lg": "{value}", "radius-xl": "{value}",
    "radius-full": "9999px",
    "width": "1px"
  },
  "shadows": {
    "sm": "{value}",
    "md": "{value}",
    "lg": "{value}",
    "xl": "{value}"
  },
  "transitions": {
    "fast": "0.15s ease",
    "normal": "0.2s ease",
    "slow": "0.3s ease"
  }
}
```

---

## 3. Naming Convention

| Category | Prefix | Example |
|----------|--------|---------|
| Colors | `--color-` | `--color-primary`, `--color-text-secondary` |
| Typography | `--font-` / `--font-size-` / `--font-weight-` | `--font-heading`, `--font-size-h1` |
| Spacing | `--spacing-` | `--spacing-md`, `--spacing-xl` |
| Borders | `--radius-` / `--border-` | `--radius-md`, `--border-width` |
| Shadows | `--shadow-` | `--shadow-sm`, `--shadow-lg` |
| Transitions | `--transition-` | `--transition-normal` |
| Line height | `--line-height-` | `--line-height-tight` |

---

## 4. Usage Notes for Blake

- **Import**: Link or import `design-tokens.css` in the project's global styles
- **Reference**: Use `var(--token-name)` throughout component styles
- **Dark mode**: Toggle via `data-theme="dark"` on `<html>` element
- **Framework conversion**: Use `design-tokens.json` to generate Tailwind config or other framework-specific configuration
- **Deviation**: Any deviation from Design Tokens must be documented with rationale in the completion report

---

## 5. Tailwind CSS Conversion Reference

When the project uses Tailwind CSS, convert JSON tokens to `tailwind.config.js`:

```javascript
// tailwind.config.js (generated from design-tokens.json)
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        secondary: 'var(--color-secondary)',
        accent: 'var(--color-accent)',
        surface: 'var(--color-surface)',
        // ... map all color tokens
      },
      fontFamily: {
        heading: ['var(--font-heading)'],
        body: ['var(--font-body)'],
        mono: ['var(--font-mono)'],
      },
      borderRadius: {
        sm: 'var(--radius-sm)',
        md: 'var(--radius-md)',
        lg: 'var(--radius-lg)',
      },
      boxShadow: {
        sm: 'var(--shadow-sm)',
        md: 'var(--shadow-md)',
        lg: 'var(--shadow-lg)',
      },
      spacing: {
        xs: 'var(--spacing-xs)',
        sm: 'var(--spacing-sm)',
        md: 'var(--spacing-md)',
        lg: 'var(--spacing-lg)',
        xl: 'var(--spacing-xl)',
      },
    },
  },
}
```
