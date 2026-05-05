# Playground Curation & Assembly Guide

> Reference guide for Alex when curating and assembling the Frontend Design Playground.
> Alex acts as curator (not designer) - selecting and organizing from pre-built references.

---

## 1. Alex's Role

- Do NOT design from scratch - select and combine from design-curations.yaml + search results
- Guarantee quality floor through pre-vetted design system references
- Ensure coherence within each direction (palette + font + components must harmonize)

### 1.1 User-Facing Language

When communicating with users, use approachable language:

| Internal Term | User-Facing Alternative |
|---------------|------------------------|
| "Alex acts as a curator" | "Alex presents design options from award-winning products and top design systems" |
| "curated palette" | "color scheme inspired by {product_name}" |
| "Research Notes" | "Inspiration Sources" |
| "curation reference database" | "design best practices from industry leaders" |

Sidebar title: **"Inspiration Sources"** with subtitle **"Design backed by industry best practices"**

---

## 2. Curation Flow

### Step 1: Read design-curations.yaml
- Load `.tad/references/design-curations.yaml`
- Identify relevant `design_systems`, `color_palettes`, `font_pairings`, `component_presets`

### Step 2: Match industry_template
- Determine project type (SaaS dashboard, consumer app, landing page, mobile web)
- Read matching `industry_templates` entry for recommended combinations
- Note `avoid` list to prevent mismatched elements

### Step 3: Runtime Search Supplement
- Execute at least 3 WebSearch queries using templates from industry_template.search_queries
- WebFetch 1-2 high-quality result pages for detailed design element extraction
- Compare findings with pre-built library: supplement new, replace outdated
- If search fails entirely: use pre-built library only, note "SEARCH_FALLBACK" in research notes

### Step 4: Assemble 2-3 Coherent Directions
- Each direction = 1 palette + 1 font_pairing + 1 component_preset
- Ensure visible difference between directions (not 3 variations of the same style)
- Label each with clear name, description, best_for tags, reference products

### Step 5: Fill playground-template.html
- Copy template to `.tad/active/playground/PLAYGROUND-{date}-{slug}/`
- Replace `{{placeholders}}` with actual values
- Replace CSS Custom Properties in `:root` with direction A values
- Fill direction B and C tab panels with their respective content
- Fill Inspiration Sources sidebar with reference links and rationale

---

## 3. Template Fill Specification

### CSS Custom Properties Replacement

Replace the `:root` block with Direction A's curated values:

```css
:root {
  --color-primary: {palette.light.primary};
  --color-secondary: {palette.light.secondary};
  --color-accent: {palette.light.accent};
  --color-background: {palette.light.background};
  --color-surface: {palette.light.surface};
  --color-text: {palette.light.text};
  --color-text-secondary: {palette.light.text_secondary};
  --color-border: {palette.light.border};
  --color-error: {palette.light.error};
  --color-success: {palette.light.success};
  --color-warning: {palette.light.warning};
  /* ... typography, spacing, radius, shadow from selected preset */
}
```

For dark mode, replace the `[data-theme="dark"]` block with corresponding dark palette values.

### Placeholder Reference

| Placeholder | Source |
|-------------|--------|
| `{{PROJECT_NAME}}` | From project context |
| `{{DIRECTION_A_NAME}}` | e.g., "Cool Minimal" - from assembled direction |
| `{{DIRECTION_A_DESCRIPTION}}` | 1-sentence style description |
| `{{BEST_FOR_N}}` | From palette.best_for or industry_template match |
| `{{REFERENCE_PRODUCTS_A}}` | From industry_template.reference_products |
| `{{WHY_A_WORKS}}` | 1-2 sentence rationale tied to project type |
| `{{PRIMARY_HEX}}` etc. | Actual hex values from curated palette |
| `{{CONTRAST_RATIO}}` | Calculated WCAG contrast ratio |
| `{{FONT_HEADING}}` | From font_pairings selection |
| `{{SOURCE_URL_N}}` | Reference links from research |
| `{{SOURCE_RATIONALE_N}}` | 1-sentence explanation per source |

### Research Notes in Sidebar

Fill the Inspiration Sources sidebar with:
- Group by direction (Direction A / B / C)
- Each source: clickable link + 1-sentence rationale
- Default: collapsed; expands for selected direction

---

## 4. Quality Checklist

### Direction Quality
- [ ] 2-3 directions with visible style differences
- [ ] Each direction internally coherent (palette + font + components harmonize)
- [ ] Each direction has clear name + description + best_for tags
- [ ] Recommended badge on industry_template best match

### Color Quality
- [ ] All text-on-background combinations meet WCAG AA (>= 4.5:1 for normal text)
- [ ] Large text (18px bold / 24px) meets >= 3:1
- [ ] Both light and dark mode values provided
- [ ] Contrast ratios annotated in color swatches

### Template Integrity
- [ ] All `{{placeholders}}` replaced with actual values
- [ ] All CSS Custom Properties have concrete values
- [ ] Tab switching works for all sections
- [ ] Theme toggle switches between light/dark correctly
- [ ] Sidebar opens/closes with proper ARIA states
- [ ] All interactive components functional

### Accessibility (WCAG AA)
- [ ] Skip navigation link present and functional
- [ ] All interactive elements keyboard-reachable via Tab
- [ ] Focus rings visible: `outline: 2px solid var(--color-primary); outline-offset: 2px`
- [ ] ARIA labels on all controls (tabs, toggles, buttons, sidebar)
- [ ] Semantic HTML (nav, main, section, aside, button)
- [ ] Heading hierarchy correct (h1 > h2 > h3, no skipping)
- [ ] Tab groups use role="tablist", role="tab", role="tabpanel"
- [ ] Theme toggle uses role="switch" + aria-pressed
- [ ] Escape closes sidebar

---

## 5. Export & Persist

After user confirms their direction choice:

### Design Tokens Export
- Use `.tad/templates/design-tokens-template.md` as the export format
- Fill with the selected direction's CSS Custom Properties + JSON tokens
- Save to playground directory as `DESIGN_TOKENS.md`

### Project Knowledge Entry
- Create/append to `.tad/project-knowledge/frontend-design.md`
- Record: selected direction name, palette, font pairing, component preset
- Format: standard project-knowledge entry with date + rationale
- If file does not exist, create it with the first entry

---

## 6. Local Server Launch

```bash
# Start local server in the playground directory
npx serve .tad/active/playground/PLAYGROUND-{date}-{slug}/ -p 3333

# If port 3333 is in use, try another
npx serve .tad/active/playground/PLAYGROUND-{date}-{slug}/ -p 3334
```

Tell user: "Open http://localhost:3333 in your browser to preview the design directions."

### Port Selection Strategy
1. Try port 3333 first
2. If occupied, increment: 3334, 3335...
3. Report actual port to user

---

## 7. Error Recovery

| Scenario | Action |
|----------|--------|
| Template fill produces broken HTML | Validate HTML structure before serving; fix missing closing tags |
| All search queries return low quality | Use pre-built library only; mark "SEARCH_FALLBACK" in notes |
| Contrast ratio fails WCAG AA | Adjust color lightness/darkness until passing; never ship non-compliant |
| Directions look too similar | Re-select from different palette/font families; ensure distinct moods |
| File exceeds 200KB | Remove unused placeholder content; compress inline SVGs if any |
| npx serve not available | Fall back to `python3 -m http.server 3333` or direct file:// |

---

## 8. Reusable Code Snippets

### Contrast Ratio Calculation (reference)
```
Relative luminance L = 0.2126 * R + 0.7152 * G + 0.0722 * B
(where R, G, B are linearized sRGB values)

Contrast ratio = (L1 + 0.05) / (L2 + 0.05)
where L1 is lighter, L2 is darker

WCAG AA: normal text >= 4.5:1, large text >= 3:1
```

### System Font Stack
```css
/* Sans-serif with CJK support */
font-family: system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue',
             'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;

/* Monospace */
font-family: ui-monospace, 'SF Mono', SFMono-Regular, Menlo, Consolas, monospace;
```
