# Design Token Judgment Rules

> React-first. Framework-agnostic for the token pipeline itself.
> These rules govern consuming DESIGN.md and W3C DTCG tokens — not creating them.

---

## Rule 1: DESIGN.md Is the Input — Read It First

**When**: Starting any frontend task on a project that has a DESIGN.md file.

**Decision**: Before writing any component, read DESIGN.md (or the tokens.json it references). Extract the values — don't invent colors, spacing, or typography from memory or conventions. Treat DESIGN.md as a contract, not a suggestion.

**Threshold**: If DESIGN.md contains a `--color-primary` value, every component in that session MUST use that value (or a token derived from it), not `#3B82F6` or `blue`. Any hardcoded color value that contradicts DESIGN.md is a violation.

**Anti-pattern**:
```typescript
// ❌ Ignoring DESIGN.md — hardcoded brand color from memory
const Button = () => (
  <button style={{ background: '#3B82F6' }}>Submit</button>
)

// ✅ Consuming DESIGN.md — use the extracted token
// From DESIGN.md: --color-primary: #1D4ED8 (the actual brand blue)
const Button = () => (
  <button className="bg-[var(--color-primary)]">Submit</button>
  // Or via Tailwind theme extension: className="bg-primary"
)
```

**Source**: [VoltAgent awesome-design-md — 68 brand DESIGN.md files](https://github.com/voltagent/awesome-design-md); [Google Labs design.md specification (Apache 2.0, alpha 2026-04-21)](https://github.com/google-labs-jules/design.md)

---

## Rule 2: W3C DTCG → Style Dictionary → CSS Pipeline

**When**: A design team exports tokens from Figma (or any DTCG-compliant tool) and the frontend needs to consume them.

**Decision**: Use Style Dictionary to transform DTCG-format token JSON into CSS custom properties. Do NOT manually copy token values from Figma — the pipeline is the source of truth.

**Threshold**: If Style Dictionary is not set up and the project uses design tokens, set it up before writing ANY styled components. Manual token copy = drift = design debt.

**Pipeline steps**:
```
1. Export: Figma → Variables → Export as JSON (DTCG format)
   Output: tokens/tokens.json
   
2. Configure Style Dictionary: config.json
   {
     "source": ["tokens/**/*.json"],
     "platforms": {
       "css": {
         "transformGroup": "css",
         "buildPath": "src/styles/",
         "files": [{ "destination": "tokens.css", "format": "css/variables" }]
       },
       "js": {
         "transformGroup": "js",
         "buildPath": "src/styles/",
         "files": [{ "destination": "tokens.js", "format": "javascript/es6" }]
       }
     }
   }
   
3. Build:
   npx style-dictionary build --config config.json
   
4. Output: src/styles/tokens.css
   :root {
     --color-primary: #1D4ED8;
     --color-secondary: #7C3AED;
     --spacing-4: 16px;
     --font-size-base: 16px;
   }
   
5. Import in globals.css:
   @import './tokens.css';
```

**Source**: [Style Dictionary — Getting Started](https://styledictionary.com/getting-started/); [W3C Design Tokens Community Group — DTCG Format Specification (2025.10)](https://www.w3.org/community/design-tokens/); [Figma — Variables REST API](https://www.figma.com/developers/api#variables)

---

## Rule 3: Token Naming Convention (DTCG Hierarchy)

**When**: Authoring or reviewing token names in tokens.json or CSS custom properties.

**Decision**: Use 3-tier hierarchy: `{category}/{variant}/{scale}`. Never use semantic shorthand that loses the category context.

**Threshold**: Every token must belong to one of the 5 canonical W3C DTCG categories: `color`, `dimension`, `fontFamily`, `fontWeight`, `duration`. Sub-categories: `color/primary`, `color/secondary`, `dimension/spacing`, `dimension/borderRadius`.

**Anti-pattern**:
```json
// ❌ Flat, ambiguous names
{
  "primary": { "$value": "#1D4ED8" },
  "large": { "$value": "16px" },
  "fast": { "$value": "150ms" }
}

// ✅ DTCG hierarchy — context is unambiguous
{
  "color": {
    "primary": {
      "default": { "$value": "#1D4ED8", "$type": "color" },
      "hover": { "$value": "#1E40AF", "$type": "color" }
    }
  },
  "dimension": {
    "spacing": {
      "4": { "$value": "16px", "$type": "dimension" },
      "8": { "$value": "32px", "$type": "dimension" }
    },
    "borderRadius": {
      "sm": { "$value": "4px", "$type": "dimension" },
      "md": { "$value": "8px", "$type": "dimension" }
    }
  },
  "duration": {
    "fast": { "$value": "150ms", "$type": "duration" },
    "normal": { "$value": "300ms", "$type": "duration" }
  }
}
```

**Source**: [W3C DTCG Format Specification — Token Types](https://tr.designtokens.org/format/#types); [Style Dictionary — Token Naming](https://styledictionary.com/info/tokens/)

---

## Rule 4: Tailwind Token Integration

**When**: A project uses Tailwind CSS and has design tokens from DESIGN.md or a token pipeline.

**Decision**: Feed tokens into `tailwind.config.ts`'s `theme.extend`. Do NOT use Tailwind's default palette for brand colors — the DESIGN.md values override.

**Threshold**: If DESIGN.md exists with color/spacing values AND the project uses Tailwind, `tailwind.config.ts` MUST reference those values. Any component using hardcoded Tailwind color classes (e.g., `bg-blue-600`) instead of semantic tokens (e.g., `bg-primary`) is a violation if a primary color token is defined.

**Anti-pattern**:
```typescript
// ❌ Hardcoded Tailwind defaults — ignores DESIGN.md brand values
<button className="bg-blue-600 text-white px-4 py-2 rounded-lg">

// ✅ Semantic tokens mapped from DESIGN.md
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',    // From tokens.css
        secondary: 'var(--color-secondary)',
      },
      spacing: {
        // Import from Style Dictionary output if numeric tokens available
      },
      borderRadius: {
        md: 'var(--dimension-border-radius-md)',
      },
    },
  },
}

// Component uses semantic class names
<button className="bg-primary text-white px-4 py-2 rounded-md">
```

**Source**: [Tailwind CSS — Using CSS Variables with Tailwind](https://tailwindcss.com/docs/customizing-colors#using-css-variables); [Style Dictionary — Tailwind CSS Integration](https://styledictionary.com/getting-started/using-the-output-in-your-project/)

---

## Rule 5: Token Pipeline Automation (Figma Sync)

**When**: A design team actively makes changes in Figma and the frontend needs to stay in sync.

**Decision**: Automate the Figma → tokens.json → CSS pipeline using Figma Code Connect or Figma's Variables REST API. Manual export = tokens drift within one sprint.

**Threshold**: If design makes >1 token change per week, manual export is not sustainable. Automate via:
- Figma Variables REST API polling (free tier: 5 req/min)
- GitHub Action: `figma-tokens-sync` runs on merge to main
- Or: Tokens Studio plugin (open source) with GitHub sync

**Anti-pattern**:
```
// ❌ Manual process — tokens drift guaranteed
1. Designer changes --color-primary in Figma
2. Developer manually exports tokens (3-5 days delay)
3. Frontend uses old color for a sprint

// ✅ Automated pipeline
GitHub Action: on push to design branch
  → fetch variables from Figma API
  → write tokens.json
  → run style-dictionary build
  → commit tokens.css
  → PR auto-created for review
```

**Source**: [Figma REST API — Variables](https://www.figma.com/developers/api#variables-endpoints); [Figma Code Connect (open source)](https://github.com/figma/code-connect); [Amazon Style Dictionary — GitHub Action integration](https://github.com/amzn/style-dictionary)

---

## Rule 6: Dark Mode via CSS Custom Properties

**When**: Implementing dark mode in a project that uses design tokens.

**Decision**: Implement dark mode by swapping CSS custom property values under a `[data-theme="dark"]` selector or `@media (prefers-color-scheme: dark)`. Never duplicate component styles for dark mode.

**Threshold**: If dark mode requires adding a `.dark:bg-*` class to more than 5 components, the implementation is wrong. Dark mode should be zero-component-code changes — only token values change.

**Anti-pattern**:
```css
/* ❌ Per-component dark mode — multiplies every time a new component is added */
.button { background: white; }
.dark .button { background: #1a1a1a; }

/* ✅ Token-level dark mode — zero component changes */
:root {
  --color-surface: #ffffff;
  --color-text: #111827;
}
[data-theme="dark"], @media (prefers-color-scheme: dark) {
  --color-surface: #111827;
  --color-text: #f9fafb;
}
.button { background: var(--color-surface); color: var(--color-text); }
/* No dark mode class needed on .button */
```

**Source**: [Style Dictionary — Dark Mode Theming](https://styledictionary.com/getting-started/using-the-output-in-your-project/); [W3C DTCG — Color Scheme Tokens (mode switching)](https://tr.designtokens.org/format/)
