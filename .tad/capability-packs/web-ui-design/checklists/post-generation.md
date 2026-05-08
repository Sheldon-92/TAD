# Post-Generation Checklist

Run after AI generates any UI code. Catches the most common AI generation anti-patterns.

---

## Semantic HTML

- [ ] No `<div>` used as a landmark (has a semantic alternative: `<main>`, `<nav>`, `<header>`, `<footer>`, `<section>`, `<article>`, `<aside>`)
- [ ] No `<div onClick>` without `role="button"` + keyboard handler (or just use `<button>`)
- [ ] No `<span>` used for block-level content (use `<p>`, `<li>`, etc.)
- [ ] Lists use `<ul>` or `<ol>` (not `<div>` with items)
- [ ] Tables use `<table>` with `<th scope>` headers (not CSS grids pretending to be tables)

```bash
# Check for div-soup patterns
grep -r "onClick.*div\|div.*onClick" src/ --include="*.tsx" --include="*.jsx" | \
  grep -v "role=" | wc -l
```

---

## Units

- [ ] No hardcoded `px` for font sizes (use `rem` or `clamp()`)
- [ ] No hardcoded `px` for spacing (use `rem`, `em`, or CSS variables)
- [ ] Borders and outlines can use `px` (fine for 1-2px values)
- [ ] Media query breakpoints use `em` or `rem` (not `px` — avoids zoom inconsistencies)

```bash
# Hardcoded pixel font sizes (should be 0)
grep -r "font-size: [0-9]*px" src/ --include="*.css" --include="*.scss" | \
  grep -v "var(\|clamp(\|calc("

# Hardcoded pixel margin/padding (review each)
grep -r "margin: [0-9]*px\|padding: [0-9]*px" src/ --include="*.css" | \
  grep -v "var(\|0px\|1px\|2px"
```

---

## CSS Cleanup

- [ ] Unused CSS classes removed (PurgeCSS run)
- [ ] No duplicate property declarations for the same selector
- [ ] No vendor prefixes for properties with ≥95% browser support (check caniuse.com)
- [ ] No inline `style=""` attributes in production components

```bash
# Remove unused CSS
purgecss --css dist/styles.css --content dist/**/*.html dist/**/*.js \
  --output dist/styles.purged.css

# Compare file sizes
echo "Original:" && wc -c dist/styles.css
echo "Purged:" && wc -c dist/styles.purged.css

# Check for inline styles
grep -r 'style="' src/ --include="*.tsx" --include="*.jsx" --include="*.html" | wc -l
```

---

## Color Tokens

- [ ] No hardcoded hex colors in component files (use CSS variables)
- [ ] No `color: black` or `color: white` (use semantic tokens)
- [ ] No `background: #fff` (use `var(--color-background-base)`)

```bash
# Find hardcoded colors in component styles
grep -r "color: #\|background: #\|border-color: #" src/ --include="*.css" | \
  grep -v ":root\|\/\*\|var(" | wc -l

# Find hardcoded colors in component JSX
grep -r 'color: "#\|backgroundColor: "#' src/ --include="*.tsx" --include="*.jsx" | wc -l
```

---

## Images and Assets

- [ ] All images have descriptive `alt` attributes
- [ ] Decorative images have `alt=""` + `aria-hidden="true"`
- [ ] No base64-encoded images > 1KB (use external files)
- [ ] SVG icons inlined only if they need to be themed (otherwise use `<img>` or `<use>`)

```bash
# Images without alt
grep -r "<img" src/ --include="*.html" --include="*.tsx" --include="*.jsx" | \
  grep -v "alt=" | wc -l

# Large base64 images (anything > 1KB is suspicious)
grep -r "data:image" src/ --include="*.css" --include="*.tsx" | \
  awk 'length($0) > 1000 {count++} END {print count+0 " large base64 images"}'
```

---

## Interactive Elements

- [ ] All `<button>` elements have type attribute (`type="button"` or `type="submit"`)
- [ ] All form inputs have associated `<label>` elements
- [ ] No placeholder-only form inputs (placeholder disappears on focus)
- [ ] Focus styles not hidden (`outline: none` has `:focus-visible` replacement)

```bash
# Buttons without explicit type (can accidentally submit forms)
grep -r "<button" src/ --include="*.tsx" --include="*.jsx" --include="*.html" | \
  grep -v "type=" | wc -l

# outline: none without focus-visible replacement
grep -r "outline: none\|outline:0" src/ --include="*.css" | \
  grep -v "focus-visible" | wc -l
```

---

## Performance Hygiene

- [ ] No `position: fixed` used for decorative elements
- [ ] No CSS animations on layout properties (`width`, `height`, `top`, `left`) — use `transform` instead
- [ ] `will-change` used sparingly (only on elements that animate)
- [ ] Images are not loaded in `<head>` (they should lazy-load in `<body>`)

```bash
# Detect layout-thrashing animations (anti-pattern — should animate transform/opacity)
grep -r "transition:.*width\|transition:.*height\|transition:.*top\|transition:.*left" \
  src/ --include="*.css" | grep -v "max-width\|min-width" | wc -l
```

---

## Quick Full Audit

```bash
echo "=== Post-Generation Audit ==="
echo ""

echo "1. Semantic HTML (div onclick, should be 0):"
grep -r "onClick.*div\|div.*onClick" src/ --include="*.tsx" 2>/dev/null | grep -v "role=" | wc -l

echo "2. Hardcoded pixel fonts (should be 0):"
grep -r "font-size: [0-9]*px" src/ --include="*.css" 2>/dev/null | grep -v "var(\|clamp(" | wc -l

echo "3. Hardcoded hex colors in components (should be 0):"
grep -r "color: #\|background: #" src/ --include="*.css" 2>/dev/null | grep -v ":root\|var(" | wc -l

echo "4. Images missing alt (should be 0):"
grep -r "<img" src/ --include="*.tsx" 2>/dev/null | grep -v "alt=" | wc -l

echo "5. Focus styles hidden without replacement (should be 0):"
grep -r "outline: none\|outline:0" src/ --include="*.css" 2>/dev/null | grep -v "focus-visible" | wc -l

echo "6. Unused CSS (purge ratio):"
if [ -f dist/styles.css ]; then
  purgecss --css dist/styles.css --content "dist/**/*.html" --output /tmp/purged-check.css 2>/dev/null
  orig=$(wc -c < dist/styles.css)
  purged=$(wc -c < /tmp/purged-check.css 2>/dev/null || echo $orig)
  echo "  $orig → $purged bytes ($(( (orig - purged) * 100 / orig ))% reducible)"
else
  echo "  No dist/styles.css — skipping"
fi
```
